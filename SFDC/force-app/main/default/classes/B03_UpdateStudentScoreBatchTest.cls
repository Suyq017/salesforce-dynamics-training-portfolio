/**
* クラス名  : B03_UpdateStudentScoreBatchTest
* クラス概要: SubjectScore__cオブジェクトを削除するバッチ処理
* @created : 2026/07/17 Nguyen Ngoc Quy
* @modified: 
*/
@isTest
private class B03_UpdateStudentScoreBatchTest {

    /**
    * testB03_UpdateStudentScoreBatch_Success
    * B03_UpdateStudentScoreBatchの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();

            Test.startTest();
                Database.executeBatch(new B03_UpdateStudentScoreBatch(),1);
            Test.stopTest();

            Student__c studentRecord = [
                SELECT Id
                , GPAScore__c
                , TotalCredit__c 
                FROM Student__c 
                LIMIT 1
            ];

            Assert.isTrue(studentRecord.GPAScore__c != null, 'GPAScore__c should be updated after executing the batch.');
            Assert.isTrue(studentRecord.TotalCredit__c != null, 'TotalCredit__c should be updated after executing the batch.');
        }
    }

    /**
    * testB03_UpdateStudentScoreBatch_StartException
    * B03_UpdateStudentScoreBatchのstartメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_StartException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B03_UpdateStudentScoreBatch.startThrowException = true;

            Test.startTest();
                try {
                    Database.executeBatch(new B03_UpdateStudentScoreBatch(),1);
                } 
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should match the expected message.');
                }
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Error', batchLogs[0].Result__c, 'BatchLog__c Result should be Error.');
        }
    }

    /**
    * testB03_UpdateStudentScoreBatch_ExecuteException
    * B03_UpdateStudentScoreBatchのexecuteメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_ExecuteException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B03_UpdateStudentScoreBatch.executeThrowException = true;

            Test.startTest();
                Database.executeBatch(new B03_UpdateStudentScoreBatch(),1);
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Error', batchLogs[0].Result__c, 'BatchLog__c Result should be Error.');
        }
    }

    /**
    * testB03_UpdateStudentScoreBatch_FinishException
    * B03_UpdateStudentScoreBatchのfinishメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_FinishException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B03_UpdateStudentScoreBatch.finishThrowException = true;

            Test.startTest();
                try {
                    Database.executeBatch(new B03_UpdateStudentScoreBatch(),1);
                } 
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should match the expected message.');
                }
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Error', batchLogs[0].Result__c, 'BatchLog__c Result should be Error.');
        }
    }

    /**
    * testB03_UpdateStudentScoreBatch_EmptyListSubjectScore
    * B03_UpdateStudentScoreBatchの正常系テスト（SubjectScore__cが空の場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_EmptyListSubjectScore() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<SubjectScore__c> listSubjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            delete listSubjectScores;

            Test.startTest();
                Database.executeBatch(new B03_UpdateStudentScoreBatch(),1); 
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
        }
    }

    /**
    * testB03_UpdateStudentScoreBatch_InvalidListSubjectScore
    * B03_UpdateStudentScoreBatchの正常系テスト（SubjectScore__cのStudent_look__cがnullの場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_InvalidListSubjectScore() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<SubjectScore__c> listSubjectScores = [
                SELECT Id, Subject_look__c 
                FROM SubjectScore__c
            ];
            listSubjectScores[0].Subject_look__c = null;
            for (SubjectScore__c subjectScore : listSubjectScores) {
                subjectScore.AverageScore__c = null;
            }
            update listSubjectScores;

            Test.startTest();
                Database.executeBatch(new B03_UpdateStudentScoreBatch(),1); 
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
        }
    }

    /**
    * testB03_UpdateStudentScoreBatch_DuplicateSubjectScores
    * B03_UpdateStudentScoreBatchの正常系テスト（SubjectScore__cのStudent_look__cがnullの場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB03_UpdateStudentScoreBatch_DuplicateSubjectScores() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            Semester__c semesterTest = new Semester__c(
                Name = 'Test Semester 2'
                , StartDate__c = Date.newInstance(2026, 7, 1)
                , EndDate__c = Date.newInstance(2026, 12, 31)
            );
            insert semesterTest;

            List<SubjectScore__c> listSubjectScores = [
                SELECT Id, Student_look__c, Subject_look__c 
                FROM SubjectScore__c
            ];
            SubjectScore__c duplicateSubjectScore = new SubjectScore__c(
                Student_look__c = listSubjectScores[0].Student_look__c,
                Subject_look__c = listSubjectScores[0].Subject_look__c,
                Semester_look__c = semesterTest.Id
            );
            insert duplicateSubjectScore;
            List<Score__c> listScores = createTestScores(duplicateSubjectScore);
            insert listScores;

            Test.startTest();
                Database.executeBatch(new B03_UpdateStudentScoreBatch(),1); 
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id, Result__c, StartTime__c, EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
        }
    }

    /**
    * initSetup
    * テストデータの初期設定を行う
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    private static void initSetup() {
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
    }

    /**
    * createTestUser
    * 概要：テスト用のユーザーを作成する
    * @param：なし
    * @return：User - 作成されたユーザー
    * @created：2026/07/17 Nguyen Ngoc Quy
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
    * createTestScores
    * テスト用のスコアレコードを作成する
    * @param：SubjectScore__c subjectScoreRecord - 作成するスコアレコードに関連付けるSubjectScore__cレコード
    * @return：List<Score__c> - 作成されたスコアレコードのリスト
    * @created：2026/07/17 Nguyen Ngoc Quy
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