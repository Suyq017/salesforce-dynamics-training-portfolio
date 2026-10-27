/**
* クラス名  ：T02_ScoreTriggerHandlerTest
* クラス概要：T02_ScoreTriggerHandlerのテストクラス
* @created ：2026/07/17 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class T02_ScoreTriggerHandlerTest {
    
    /**
    * testAfterInsertHandle_Success
    * afterInsertHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            
            Test.startTest();
                insert scores;
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.isNotNull(insertedSubjectScore, 'SubjectScore__c record should be inserted successfully.');
            Assert.isNotNull(insertedSubjectScore.AverageScore__c, 'Inserted SubjectScore__c AverageScore__c should not be null.');
            Assert.isNotNull(insertedSubjectScore.Status__c, 'Inserted SubjectScore__c Status should not be null.');
        }
    }

    /**
    * testAfterInsertHandle_InActiveTrigger
    * afterInsertHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_InActiveTrigger() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c settings = new StudentManageSetting__c(T02_InActive_flg__c = true);
            insert settings;
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            
            Test.startTest();
                insert scores;
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.isNotNull(insertedSubjectScore, 'SubjectScore__c record should be inserted successfully.');
            Assert.isNull(insertedSubjectScore.AverageScore__c, 'Inserted SubjectScore__c AverageScore__c should be null.');
            Assert.isNull(insertedSubjectScore.Status__c, 'Inserted SubjectScore__c Status should be null.');
        }
    }

    /**
    * testAfterInsertHandle_notEnoughFourScoreValue
    * afterInsertHandleメソッドの例外系テスト（4つのスコア値が不足している場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_notEnoughFourScoreValue() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            scores.remove(0); 

            Test.startTest();
                insert scores;
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.isNotNull(insertedSubjectScore, 'SubjectScore__c record should be inserted successfully.');
            Assert.areEqual(insertedSubjectScore.AverageScore__c, subjectScoreRecord.AverageScore__c, 'Inserted SubjectScore__c AverageScore__c should be the same as the original.');
            Assert.areEqual(insertedSubjectScore.Status__c, subjectScoreRecord.Status__c, 'Inserted SubjectScore__c Status should be the same as the original.');
        }
    }

    /**
    * testAfterInsertHandle_BlankScoreType
    * afterInsertHandleメソッドの例外系テスト（スコアタイプが空白の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_BlankScoreType() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            scores[0].ExamType__c = '';

            Test.startTest();
                insert scores;
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.isNotNull(insertedSubjectScore, 'SubjectScore__c record should be inserted successfully.');
            Assert.areEqual(insertedSubjectScore.AverageScore__c, subjectScoreRecord.AverageScore__c, 'Inserted SubjectScore__c AverageScore__c should be the same as the original.');
            Assert.areEqual(insertedSubjectScore.Status__c, subjectScoreRecord.Status__c, 'Inserted SubjectScore__c Status should be the same as the original.');
        }
    }

    /**
    * testAfterInsertHandle_notEnoughScoreType
    * afterInsertHandleメソッドの例外系テスト（スコアタイプが不足している場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_notEnoughScoreType() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            scores[0].ExamType__c = 'FinalTerm Exam';
            
            Test.startTest();
                insert scores;
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.isNotNull(insertedSubjectScore, 'SubjectScore__c record should be inserted successfully.');
            Assert.areEqual(insertedSubjectScore.AverageScore__c, subjectScoreRecord.AverageScore__c, 'Inserted SubjectScore__c AverageScore__c should be the same as the original.');
            Assert.areEqual(insertedSubjectScore.Status__c, subjectScoreRecord.Status__c, 'Inserted SubjectScore__c Status should be the same as the original.');
        }
    }

    /**
    * testAfterInsertHandleTest_Exception
    * afterInsertHandleメソッドの例外系テスト（例外が発生した場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandleTest_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            T02_ScoreTriggerHandler.afterTriggerThrowException = true; 

            Test.startTest();
                try {
                    insert scores;
                } 
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.isNotNull(insertedSubjectScore, 'SubjectScore__c record should be existing even after exception.');
            Assert.isTrue(insertedSubjectScore.AverageScore__c == null, 'Inserted SubjectScore__c AverageScore__c should be null.');
            Assert.isTrue(insertedSubjectScore.Status__c == null, 'Inserted SubjectScore__c Status should be null.');
        }
    }

    /**
    * testAfterUpdateHandle_Success
    * afterUpdateHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterUpdateHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            insert scores;
            SubjectScore__c updatedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            scores[0].Score__c = Math.random() * 10; 

            Test.startTest();
                update scores[0];
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.areNotEqual(updatedSubjectScore.AverageScore__c, insertedSubjectScore.AverageScore__c, 'SubjectScore__c record should be updated successfully.');
        }
    }

    /**
    * testAfterUpdateHandle_Exception
    * afterUpdateHandleメソッドの例外系テスト（例外が発生した場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterUpdateHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            SubjectScore__c subjectScoreRecord = createTestData();
            List<Score__c> scores = createTestScores(subjectScoreRecord);
            insert scores;
            SubjectScore__c updatedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            scores[0].Score__c = Math.random() * 10;
            T02_ScoreTriggerHandler.afterTriggerThrowException = true;

            Test.startTest();
                try {
                    update scores[0];
                } 
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception during update.');
                }
            Test.stopTest();
            
            SubjectScore__c insertedSubjectScore = [
                SELECT Id
                , AverageScore__c
                , Status__c 
                FROM SubjectScore__c 
                WHERE Id = :subjectScoreRecord.Id 
                LIMIT 1
            ];
            Assert.areEqual(updatedSubjectScore.AverageScore__c, insertedSubjectScore.AverageScore__c, 'SubjectScore__c record should be updated successfully.');
            Assert.areEqual(insertedSubjectScore.Status__c, updatedSubjectScore.Status__c, 'Updated SubjectScore__c Status should be updated.');
        }
    }

    /**
    * createTestUser
    * テスト用のユーザーを作成する
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
    * createTestStudent
    * テスト用の学生レコードを作成する
    * @param：なし
    * @return：SubjectScore__c - 作成された学生レコード
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    private static SubjectScore__c createTestData() {
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

        Semester__c semesterRecord = new Semester__c();
        insert semesterRecord;

        Subject__c subjectRecord = new Subject__c();
        insert subjectRecord;

        SubjectScore__c subjectScoreRecord = new SubjectScore__c(
            Student_look__c = studentTest.Id
            , Semester_look__c = semesterRecord.Id
            , Subject_look__c = subjectRecord.Id
        );
        insert subjectScoreRecord;
        return subjectScoreRecord;
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