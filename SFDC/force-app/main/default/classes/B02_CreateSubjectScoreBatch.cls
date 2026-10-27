/**
* クラス名  : B02_CreateSubjectScoreBatch
* クラス概要: SubjectScore__cオブジェクトの作成バッチ
* @created : 2026/07/03 Nguyen Ngoc Quy
* @modified: 2026/07/20 Nguyen Ngoc Quy
*/
public without sharing class B02_CreateSubjectScoreBatch implements Database.Batchable<SObject>, Database.Stateful {

    private static final String BATCHLOG_NAME = 'B02_科目得点作成バッチ';
    private static final String ERROR_RESULT = 'Error';
    private static final String SUCCESS_RESULT = 'Success';

    private static final INTEGER DEFAULT_BATCH_SIZE = 200;

    private static final String ENROLLED_LEARNING_STATUS = 'Enrolled';

    private static final String EXAM_TYPE_PROGRESS = 'Progress';
    private static final String EXAM_TYPE_PRACTICAL = 'Practical';
    private static final String EXAM_TYPE_MIDTERM = 'Midterm Exam';
    private static final String EXAM_TYPE_FINAL = 'FinalTerm Exam';

    private static final Integer SEMESTER_LIMIT = 2;
    private static final Integer SUBJECT_LIMIT = 5;
    private static final Integer SUBJECT_CREDIT_LIMIT = 25;
    private static final Integer SCORE_MULTIPLIER = 10;
    private BatchLog__c batchLog;

    // 2026/07/20 Nguyen Ngoc Quy Add start
    @TestVisible
    private static Boolean startThrowException = false;
    @TestVisible
    private static Boolean executeThrowException = false;
    @TestVisible
    private static Boolean finishThrowException = false;
    // 2026/07/20 Nguyen Ngoc Quy Add end

    /**
    * start
    * SubjectScore__cオブジェクトの作成バッチの開始処理, batchLog__cレコードを作成する
    * @param: Database.BatchableContext bc - バッチコンテキスト
    * @return: Database.QueryLocator - SubjectScore__cオブジェクトのクエリロケータ
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        try {
            // Insert a new BatchLog__c record
            this.batchLog = insertBatchLog();

            // 2026/07/20 Nguyen Ngoc Quy Add start
            startThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end
            
            // Query to select all Student__c records
            return Database.getQueryLocator([
                SELECT Id
                , GPAScore__c
                , TotalCredit__c
                FROM Student__c
                WHERE LearningStatus__c = :ENROLLED_LEARNING_STATUS
            ]);
        }
        catch (Exception e) {
            updateBatchLog(this.batchLog, ERROR_RESULT, e.getMessage());
            System.abortJob(bc.getJobId());
            return null;
        }
    }
        
    
    /**
    * execute
    * SubjectScore__cオブジェクトの作成バッチの開始処理, batchLog__cレコードを作成する
    * @param: Database.BatchableContext bc - バッチコンテキスト, List<Student__c> listStudents - Student__cオブジェクトのリスト
    * @return: なし
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public void execute(Database.BatchableContext bc, List<Student__c> listStudents){
        // Fetch all Semester__c records
        List<Semester__c> listSemesters = fetchSemesterList();
        if (listSemesters == null || listSemesters.isEmpty()) {
            return;
        }

        // Fetch all Subject__c records
        List<Subject__c> listSubjects = fetchSubjectList();
        if (listSubjects == null || listSubjects.isEmpty()) {
            return;
        }

        // List SubjectScore__c records to be inserted
        List<SubjectScore__c> listSubjectScores = new List<SubjectScore__c>();

        // Loop through each student to create SubjectScore__c records
        for (Student__c student :  listStudents) {

            Set<Id> setSelectedSemesterIds = new Set<Id>();
            while ( setSelectedSemesterIds.size() < SEMESTER_LIMIT) {

                // If there are no more available semesters, break the loop
                if (setSelectedSemesterIds.size() >= listSemesters.size()) {
                    break;
                }

                // Get a random semester from the semesters list that has not been selected yet
                Semester__c selectedSemester = getRandomSemester(listSemesters, setSelectedSemesterIds);
                // 2026/07/20 Nguyen Ngoc Quy Delete start
                // if (selectedSemester == null) {
                //     break;
                // }
                // 2026/07/20 Nguyen Ngoc Quy Delete end
                setSelectedSemesterIds.add(selectedSemester.Id);

                Decimal totalCredit = 0;
                Set<Id> setSelectedSubjectIds = new Set<Id>();
                while ( setSelectedSubjectIds.size() < SUBJECT_LIMIT) {

                    // If the number of existing subject IDs reaches the limit or exceeds the available subjects, break the loop
                    if (setSelectedSubjectIds.size() >= listSubjects.size()) {
                        break;
                    }

                    // Get a random subject from the available list
                    Subject__c selectedSubject = getRandomSubject(listSubjects, setSelectedSubjectIds);
                    // 2026/07/20 Nguyen Ngoc Quy Delete start
                    // if (selectedSubject == null) {
                    //     break;
                    // }
                    // 2026/07/20 Nguyen Ngoc Quy Delete end
                    setSelectedSubjectIds.add(selectedSubject.Id);

                    // update total credit for the student per semester, if the total credit exceeds the limit, break the loop
                    totalCredit += selectedSubject.CourseCredit__c != null ? selectedSubject.CourseCredit__c : 0;
                    if (totalCredit > SUBJECT_CREDIT_LIMIT) {
                        break;
                    }

                    // Create a new SubjectScore__c record for the student, semester, and subject
                    SubjectScore__c subjectScore = new SubjectScore__c(
                        Semester_look__c = selectedSemester.Id,
                        Subject_look__c = selectedSubject.Id,
                        Student_look__c = student.Id
                    );
                    listSubjectScores.add(subjectScore);
                }
            }
        }

        if (!listSubjectScores.isEmpty()) {
            insert listSubjectScores;
            // After inserting SubjectScore__c records, create Score__c records for each SubjectScore__c
            List<Score__c> listScores = getScoresForSubjectScore(listSubjectScores);
            if (!listScores.isEmpty()) {
                insert listScores;
            }
        }
    }

    /**
    * finish
    * SubjectScore__cオブジェクトの作成バッチの終了処理, batchLog__cレコードを更新する
    * @param: Database.BatchableContext bc - バッチコンテキスト
    * @return: なし
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public void finish(Database.BatchableContext bc){
        try{
            // 2026/07/20 Nguyen Ngoc Quy Add start
            finishThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

            List<AsyncApexJob> listJobs = [
                SELECT Id
                , NumberOfErrors
                , ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
                LIMIT 1
            ];
            if (!listJobs.isEmpty()) {
                AsyncApexJob job = listJobs[0];
                // 2026/07/20 Nguyen Ngoc Quy Modify start
                // if (job.NumberOfErrors > 0){
                if (job.NumberOfErrors > 0 || (Test.isRunningTest() && executeThrowException)) {
                // 2026/07/20 Nguyen Ngoc Quy Modify end
                    updateBatchLog(this.batchLog, ERROR_RESULT, job.ExtendedStatus);
                    return;
                }
                if (job.NumberOfErrors == 0) {
                    updateBatchLog(this.batchLog, SUCCESS_RESULT, null);

                    StudentManageSetting__c setting = StudentManageSetting__c.getOrgDefaults();
                    Integer b03_BatchSize;
                    if (setting.B03_BatchSize__c == null || setting.B03_BatchSize__c <= 0) {
                        b03_BatchSize = DEFAULT_BATCH_SIZE;
                    } else {
                        b03_BatchSize = Integer.valueOf(setting.B03_BatchSize__c);
                    }

                    B03_UpdateStudentScoreBatch b03_UpdateStudentScoreBatch = new B03_UpdateStudentScoreBatch();
                    Database.executeBatch(b03_UpdateStudentScoreBatch, b03_BatchSize);
                }
            }
        }
        catch (Exception e) {
            updateBatchLog(this.batchLog, ERROR_RESULT, e.getMessage());
        }
    }

    /**
    * getRandomSemester
    * 指定されたリストからランダムにSemester__cオブジェクトを取得する
    * @param: List<Semester__c> listAvailableSemesters - Semester__cオブジェクトのリスト, Set<Id> setSelectedSemesterIds - 既に選択されたSemester__cオブジェクトのIDのセット
    * @return: Semester__c - ランダムに取得されたSemester__cオブジェクト
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static Semester__c getRandomSemester(List<Semester__c> listSemesters, Set<Id> setSelectedSemesterIds) {
        Semester__c semesterRecord;
        while (semesterRecord == null || setSelectedSemesterIds.contains(semesterRecord.Id)) {
            semesterRecord = listSemesters[Math.mod(Math.abs(Crypto.getRandomInteger()), listSemesters.size())];
        }
        return semesterRecord;
    }

    /**
    * getRandomSubject
    * 指定されたリストからランダムにSubject__cオブジェクトを取得する
    * @param: List<Subject__c> listSubjects - Subject__cオブジェクトのリスト, Set<Id> setSelectedSubjectIds - 既に選択されたSubject__cオブジェクトのIDのセット
    * @return: Subject__c - ランダムに取得されたSubject__cオブジェクト
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static Subject__c getRandomSubject(List<Subject__c> listSubjects, Set<Id> setSelectedSubjectIds) {
        Subject__c subjectRecord;
        while (subjectRecord == null || setSelectedSubjectIds.contains(subjectRecord.Id)) {
            subjectRecord = listSubjects[Math.mod(Math.abs(Crypto.getRandomInteger()), listSubjects.size())];
        }
        return subjectRecord;
    }

    /**
    * getScoresForSubjectScore
    * 指定されたSubjectScore__cオブジェクトのリストに基づいて、関連するScore__cオブジェクトのリストを取得する
    * @param: List<SubjectScore__c> listSubjectScores - SubjectScore__cオブジェクトのリスト
    * @return: List<Score__c> - 取得したScore__cオブジェクトのリスト
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static List<Score__c> getScoresForSubjectScore(List<SubjectScore__c> listSubjectScores) {
        List<Score__c> listScores = new List<Score__c>();
            for (SubjectScore__c subjectScore : listSubjectScores) {
                listScores.add(createRandomScore(EXAM_TYPE_PROGRESS, subjectScore.Id));
                listScores.add(createRandomScore(EXAM_TYPE_PRACTICAL, subjectScore.Id));
                listScores.add(createRandomScore(EXAM_TYPE_MIDTERM, subjectScore.Id));
                listScores.add(createRandomScore(EXAM_TYPE_FINAL, subjectScore.Id));
            }
        return listScores;
    }

    /**
    * createRandomScore
    * 指定された試験タイプに基づいてランダムなスコアを生成し、Score__cオブジェクトを作成する
    * @param: String examType - 試験タイプ, Id subjectScoreId - SubjectScore__cオブジェクトのID
    * @return: Score__c - 作成されたScore__cオブジェクト
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static Score__c createRandomScore(String examType, Id subjectScoreId) {
        Score__c score = new Score__c();
        score.Score__c = (Decimal.valueOf(Math.random() * SCORE_MULTIPLIER)).setScale(2, RoundingMode.HALF_UP);
        score.SubjectScore_look__c = subjectScoreId;
        score.ExamType__c = examType;
        return score;
    }

    /**
    * insertBatchLog
    * batchLog__cレコードを挿入する
    * @param: なし
    * @return: BatchLog__c - 挿入されたbatchLog__cレコード
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static BatchLog__c insertBatchLog() {
        BatchLog__c newBatchLog = new BatchLog__c();
        newBatchLog.Name = BATCHLOG_NAME;
        newBatchLog.StartTime__c = System.now();
        insert newBatchLog;
        return newBatchLog;
    }

    /**
    * updateBatchLog
    * batchLog__cレコードを更新する
    * @param: BatchLog__c batchLog - 更新するbatchLog__cレコード, String result - 更新する結果, String errorMessage - 更新するエラーメッセージ
    * @return: なし
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static void updateBatchLog(BatchLog__c batchLog, String result, String errorMessage) {
        batchLog.EndTime__c = System.now();
        batchLog.Result__c = result;
        batchLog.ErrorMessage__c = errorMessage;
        update batchLog;
    }

    /**
    * fetchSemesterList
    * Semester__cオブジェクトのリストを取得する
    * @param: なし
    * @return: List<Semester__c> - 取得したSemester__cオブジェクトのリスト
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static List<Semester__c> fetchSemesterList() {
        List<Semester__c> listSemesters = [
            SELECT Id
            FROM Semester__c
        ];
        return listSemesters;
    }

    /**
    * fetchSubjectList
    * Subject__cオブジェクトのリストを取得する
    * @param: なし
    * @return: List<Subject__c> - 取得したSubject__cオブジェクトのリスト
    * @created: 2026/07/03 Nguyen Ngoc Quy
    * @modified:
    */
    private static List<Subject__c> fetchSubjectList() {
        List<Subject__c> listSubjects = [
            SELECT Id
                , CourseCredit__c
            FROM Subject__c
        ];
        return listSubjects;
    }

    // 2026/07/20 Nguyen Ngoc Quy Add start
    /**
    * startThrowExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static void startThrowExceptionForTesting() {
        if (startThrowException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * finishThrowExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static void finishThrowExceptionForTesting() {
        if (finishThrowException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * クラス名  : CustomException
    * クラス概要: カスタム例外クラス
    * @created : 2026/07/20 Nguyen Ngoc Quy
    * @modified: 
    */
    class CustomException extends Exception {}
    // 2026/07/20 Nguyen Ngoc Quy Add end
}