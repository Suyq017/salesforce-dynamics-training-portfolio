/**
* クラス名  : B03_UpdateStudentScoreBatch
* クラス概要: 学生の得点を更新するバッチクラス
* @created : 2026/07/06 Nguyen Ngoc Quy
* @modified: 2026/07/20 Nguyen Ngoc Quy
*/
public without sharing class B03_UpdateStudentScoreBatch implements Database.Batchable<SObject>, Database.Stateful {
    private static final String BATCHLOG_NAME = 'B03_学生得点更新バッチ';
    private static final String ERROR_RESULT = 'Error';
    private static final String SUCCESS_RESULT = 'Success';
    private static final String ENROLLED_LEARNING_STATUS = 'Enrolled';
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
    * SubjectScore__cオブジェクトの更新バッチの開始処理, batchLog__cレコードを作成する
    * @param: Database.BatchableContext bc - バッチコンテキスト
    * @return: Database.QueryLocator - バッチ処理の対象となるレコードのクエリロケータ
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        try {
            // Insert a new BatchLog__c record
            this.batchLog = insertBatchLog();

            // 2026/07/20 Nguyen Ngoc Quy Add start
            startThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

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
    * SubjectScore__cオブジェクトの更新バッチの実行処理
    * @param: Database.BatchableContext bc - バッチコンテキスト, List<Student__c> listStudents - Student__cオブジェクトのリスト
    * @return: なし
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified:
    */
    public void execute(Database.BatchableContext bc, List<Student__c> listStudents){

        Set<Id> studentIds = (new Map<Id, Student__c>(listStudents)).keySet();
        
        List<SubjectScore__c> listSubjectScores = fetchSubjectScoreList(studentIds);
        if (listSubjectScores == null || listSubjectScores.isEmpty()) {
            return;
        }
        
        // Create a map studentId -> (subjectId -> SubjectScore__c) to store the highest score for each subject of each student
        Map<Id, Map<Id, SubjectScore__c>> mapStudentToSubjectScores = new Map<Id, Map<Id, SubjectScore__c>>();
        for (SubjectScore__c subjectScore : listSubjectScores) {
            if (subjectScore.Student_look__c == null || subjectScore.Subject_look__c == null) {
                continue;
            }
            // if the map hasn't contained the student, put the student and the SubjectScore into the map
            if (!mapStudentToSubjectScores.containsKey(subjectScore.Student_look__c)) {
                mapStudentToSubjectScores.put(subjectScore.Student_look__c, new Map<Id, SubjectScore__c>());
                mapStudentToSubjectScores.get(subjectScore.Student_look__c).put(subjectScore.Subject_look__c, subjectScore);
            } 
            // if the map has contained the student, we check if the student already has a score for this subject
            else {
                // If the student already has a score for this subject, we only keep the highest score (the first one in the list is the highest due to the ORDER BY clause in the SOQL query)
                if (mapStudentToSubjectScores.get(subjectScore.Student_look__c).containsKey(subjectScore.Subject_look__c)) {
                    continue;
                }
                // If the student does not have a score for this subject yet, we add it to the map
                mapStudentToSubjectScores.get(subjectScore.Student_look__c).put(subjectScore.Subject_look__c, subjectScore);
            }
        }

        // Calculate the GPA score and total credits for each student
        for (Student__c student : listStudents) {
            if (mapStudentToSubjectScores.get(student.Id) != null) {
                Decimal gpaScore = 0;
                Decimal totalCredits = 0;
                for (SubjectScore__c subjectScore : mapStudentToSubjectScores.get(student.Id).values()) {
                    if (subjectScore.AverageScore__c == null || subjectScore.Subject_look__r.CourseCredit__c == null) {
                        continue;
                    }
                    gpaScore += subjectScore.AverageScore__c * subjectScore.Subject_look__r.CourseCredit__c;
                    totalCredits += subjectScore.Subject_look__r.CourseCredit__c;
                }

                if (totalCredits != 0) {
                    gpaScore = gpaScore / totalCredits;
                } else {
                    gpaScore = 0;
                }

                student.GPAScore__c = gpaScore.setScale(2, RoundingMode.HALF_UP);
                student.TotalCredit__c = totalCredits;
            }
        }
        if (listStudents != null && !listStudents.isEmpty()) {
            update listStudents;
        }
    }

    /**
    * finish
    * バッチ処理の終了処理, batchLog__cレコードを更新する
    * @param: Database.BatchableContext bc - バッチコンテキスト
    * @return: なし
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified:
    */
    public void finish(Database.BatchableContext bc){
        try {
            // 2026/07/20 Nguyen Ngoc Quy Add start
            finishThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end
            
            List<AsyncApexJob> jobs = [
                SELECT Id
                , NumberOfErrors
                , ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
                LIMIT 1
            ];
            if (!jobs.isEmpty()) {
                AsyncApexJob job = jobs[0];
                // 2026/07/20 Nguyen Ngoc Quy Modify start
                // if (job.NumberOfErrors > 0) {
                // updateBatchLog(this.batchLog, ERROR_RESULT, job.ExtendedStatus);
                if (job.NumberOfErrors > 0 || (Test.isRunningTest() && executeThrowException)) {
                    updateBatchLog(this.batchLog, ERROR_RESULT, job.ExtendedStatus);
                    return;
                }
                // 2026/07/20 Nguyen Ngoc Quy Modify end
                if (job.NumberOfErrors == 0) {
                    updateBatchLog(this.batchLog, SUCCESS_RESULT, null);
                }
            }
        }
        catch (Exception e) {
            updateBatchLog(this.batchLog, ERROR_RESULT, e.getMessage());
        }
    }

    /**
    * fetchSubjectScoreList
    * 指定された学生IDに基づいてSubjectScore__cオブジェクトのリストを取得する
    * @param: Set<Id> studentIds - 学生IDのセット
    * @return: List<SubjectScore__c> - 取得したSubjectScore__cオブジェクトのリスト
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified:
    */
    private static List<SubjectScore__c> fetchSubjectScoreList(Set<Id> setstudentIds) {
        List<SubjectScore__c> listSubjectScores = [
            SELECT Id
                , AverageScore__c
                , Subject_look__r.CourseCredit__c
                , Subject_look__c
                , Student_look__c
            FROM SubjectScore__c
            WHERE Student_look__c IN :setstudentIds
            ORDER BY Student_look__c, Subject_look__c, AverageScore__c DESC NULLS LAST
        ];
        return listSubjectScores;
    }

    /**
    * insertBatchLog
    * batchLog__cレコードを挿入する
    * @param: なし
    * @return: BatchLog__c - 挿入されたbatchLog__cレコード
    * @created: 2026/07/06 Nguyen Ngoc Quy
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
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified:
    */
    private static void updateBatchLog(BatchLog__c batchLog, String result, String errorMessage) {
        batchLog.EndTime__c = System.now();
        batchLog.Result__c = result;
        batchLog.ErrorMessage__c = errorMessage;
        update batchLog;
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