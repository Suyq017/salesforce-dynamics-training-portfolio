/**
* クラス名  ：LWC_DetailStudentCtrlTest
* クラス概要：学生の詳細情報を取得するコントローラークラスのテストクラス
* @created ：2026/07/21 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class LWC_DetailStudentCtrlTest {
    /**
    * testGetStudent_Success
    * LWC_DetailStudentCtrl.getStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudentDetail_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();

            Test.startTest();
                Student__c result = LWC_DetailStudentCtrl.getStudentDetail(studentTest.Id);
            Test.stopTest();

            Assert.isNotNull(result, 'The returned student should not be null.');
            Assert.areEqual(studentTest.Id, result.Id, 'The returned student ID should match the test student ID.');
            Assert.areEqual(studentTest.LastName__c, result.LastName__c, 'The returned student LastName should match the test student LastName.');
            Assert.areEqual(studentTest.FirstName__c, result.FirstName__c, 'The returned student FirstName should match the test student FirstName.');
            Assert.areEqual(studentTest.Birthday__c, result.Birthday__c, 'The returned student Birthday should match the test student Birthday.');
            Assert.areEqual(studentTest.Gender__c, result.Gender__c, 'The returned student Gender should match the test student Gender.');
            Assert.areEqual(studentTest.Class_look__c, result.Class_look__c, 'The returned student Class_look should match the test student Class_look.');
            Assert.areEqual(studentTest.LearningStatus__c, result.LearningStatus__c, 'The returned student LearningStatus should match the test student LearningStatus.');
            Assert.areEqual(studentTest.StudentCode__c, result.StudentCode__c, 'The returned student StudentCode should match the test student StudentCode.');
        }
    }

    /**
    * testGetStudent_EmptyResultException
    * LWC_DetailStudentCtrl.getStudentメソッドの異常系テスト（学生が見つからない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudentDetail_EmptyResultException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            delete studentTest;
            Student__c result;

            Test.startTest();
                try {
                    result = LWC_DetailStudentCtrl.getStudentDetail(studentTest.Id);
                }
                catch (Exception e) {
                    Assert.areEqual('学生が見つかりませんでした。', e.getMessage(), 'The exception message should indicate that the student was not found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The returned student should be null.');
        }
    }

    /**
    * testFetchSubjectScoresBySemester_Sucess
    * LWC_DetailStudentCtrl.fetchSubjectScoresBySemesterメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchSubjectScoresBySemester_Sucess(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = initSetup();

            Test.startTest();
                Map<String, Object> result = LWC_DetailStudentCtrl.fetchSubjectScoresBySemester(studentTest.Id);
            Test.stopTest();

            Assert.isNotNull(result, 'The returned subject score list should not be null.');
            Assert.isTrue(!result.isEmpty(), 'The returned subject score list should not be empty.');
        }
    }

    /**
    * testFetchSubjectScoresBySemester_NullSemesterId
    * LWC_DetailStudentCtrl.fetchSubjectScoresBySemesterメソッドの正常系テスト（学期IDがnullの場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchSubjectScoresBySemester_NullSemesterId(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = initSetup();
            SubjectScore__c subjectScoreRecord = [
                SELECT Id
                , Semester_look__c 
                FROM SubjectScore__c 
                WHERE Student_look__c = :studentTest.Id 
                LIMIT 1
            ];
            subjectScoreRecord.Semester_look__c = null;
            update subjectScoreRecord;

            Test.startTest();
                Map<String, Object> result = LWC_DetailStudentCtrl.fetchSubjectScoresBySemester(studentTest.Id);
            Test.stopTest();

            Assert.isNotNull(result, 'The returned subject score list should not be null.');
            Assert.isTrue(!result.isEmpty(), 'The returned subject score list should not be empty.');
        }
    }

    /**
    * testFetchSubjectScoresBySemester_Exception
    * LWC_DetailStudentCtrl.fetchSubjectScoresBySemesterメソッドの異常系テスト（例外が発生する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchSubjectScoresBySemester_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = initSetup();
            LWC_DetailStudentCtrl.thowException = true;

            Test.startTest();
                try {
                    LWC_DetailStudentCtrl.fetchSubjectScoresBySemester(studentTest.Id);
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should indicate that a test exception occurred.');
                }
            Test.stopTest();
        }
    }

    /**
    * createTestUser
    * テスト用のユーザーを作成する
    * @param：なし
    * @return：User - 作成されたユーザー
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    private static User createTestUser() {
        Profile profile = [
            SELECT Id 
            FROM Profile 
            WHERE Name='Standard User' 
            LIMIT 1
        ];

        String uniqueName = UserInfo.getOrganizationId() + 
        Datetime.now().format('yyyyMMddHHmmssSSS') +
        Integer.valueOf(Math.rint(Math.random() * (2000000 - 1)));

        User userTest = new User(
            Alias = 'standt'
            , Email= uniqueName + '@keizu.co.jp'
            , EmailEncodingKey='UTF-8'
            , FirstName= uniqueName.substring(29, 34)
            , LastName= uniqueName.substring(30, 35)
            , LanguageLocaleKey='en_US'
            , LocaleSidKey='en_US'
            , ProfileId = profile.Id
            , TimeZoneSidKey='America/Los_Angeles'
            , UserName= uniqueName + '@ke1zu.co.jp'
        );
        insert userTest;
        return userTest;
    }

    /**
    * createAndInsertTestStudent
    * テスト用の学生レコードを作成する
    * @param：なし
    * @return：Student__c - 作成された学生レコード
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c createAndInsertTestStudent() {
        Class__c classRecord = new Class__c();
        insert classRecord;

        Student__c studentTest = new Student__c(
            Name = 'Test Student'
            , Lastname__c = 'Test'
            , FirstName__c = 'Student'
            , BirthDay__c = Date.newInstance(2000, 1, 1)
            , Gender__c = 'Male'
            , Class_look__c = classRecord.Id
            , LearningStatus__c = 'Enrolled'
        );
        insert studentTest;

        Student__c returnStudent = [
            SELECT Id
            , Name
            , LastName__c
            , FirstName__c
            , Birthday__c
            , toLabel(Gender__c)
            , Class_look__c
            , Class_look__r.Name
            , toLabel(LearningStatus__c)
            , StudentCode__c 
            FROM Student__c 
            WHERE Id = :studentTest.Id 
            LIMIT 1
        ];   
        return returnStudent;
    }

    /**
    * initSetup
    * テストデータの初期設定を行う
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified:
    */
    private static Student__c initSetup() {
        Class__c classRecord = new Class__c();
        insert classRecord;

        Student__c studentTest = new Student__c(
            Name = 'Test Student'
            , Lastname__c = 'Test'
            , FirstName__c = 'Student'
            , BirthDay__c = Date.newInstance(2000, 1, 1)
            , Gender__c = 'Male'
            , Class_look__c = classRecord.Id
            , LearningStatus__c = 'Enrolled'
        );
        insert studentTest;

        Semester__c semesterRecord = new Semester__c(
            Name = 'Test Semester'
            , StartDate__c = Date.newInstance(2026, 1, 1)
            , EndDate__c = Date.newInstance(2026, 6, 30)
        );
        insert semesterRecord;

        List<Subject__c> listSubjects = new List<Subject__c>();
        for (Integer i = 0; i < 5; i++) {
            Subject__c subject = new Subject__c(
                Name='Math' + i,
                CourseCredit__c= 3
            );
            listSubjects.add(subject);
        }
        insert listSubjects;

        List<Score__c> listScores = new List<Score__c>();
        for (Subject__c subject : listSubjects) {
            SubjectScore__c subjectScore = new SubjectScore__c(
                Student_look__c = studentTest.Id,
                Semester_look__c = semesterRecord.Id,
                Subject_look__c = subject.Id
            );
            insert subjectScore;

            List<Score__c> scores = createTestScores(subjectScore);
            listScores.addAll(scores);
        }
        
        insert listScores;
        return studentTest;
    }

    /**
    * createTestScores
    * テスト用のスコアレコードを作成する
    * @param：SubjectScore__c subjectScoreRecord - 作成するスコアレコードに関連付けるSubjectScore__cレコード
    * @return：List<Score__c> - 作成されたスコアレコードのリスト
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    private static List<Score__c> createTestScores(SubjectScore__c subjectScoreRecord) {
        List<Score__c> scores = new List<Score__c>();
        scores.add(new Score__c(
            SubjectScore_look__c = subjectScoreRecord.Id
            , ExamType__c = 'Progress'
            , Score__c = Math.random() * 10
            )
        );
        scores.add(new Score__c(
            SubjectScore_look__c = subjectScoreRecord.Id
            , ExamType__c = 'Practical'
            , Score__c = Math.random() * 10
        ));
        scores.add(new Score__c(
            SubjectScore_look__c = subjectScoreRecord.Id
            , ExamType__c = 'Midterm Exam'
            , Score__c = Math.random() * 10
        ));
        scores.add(new Score__c(
            SubjectScore_look__c = subjectScoreRecord.Id
            , ExamType__c = 'FinalTerm Exam'
            , Score__c = Math.random() * 10
        ));
        return scores;
    }
}