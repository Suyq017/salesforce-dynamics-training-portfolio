/**
* クラス名  ：T01_StudentTriggerHandlerTest
* クラス概要：T01_StudentTriggerHandlerのテストクラス
* @created ：2026/07/16 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class T01_StudentTriggerHandlerTest {
    
    private static final String GENDER_FEMALE = 'Female';
    private static final String GENDER_MALE = 'Male';
    private static final Integer VALID_AGE = 18;
    private static final Integer INVALID_AGE = 17;
    private static final String LEARNING_STATUS_ENROLLED = 'Enrolled';

    /**
    * testBeforeInsertHandle_Success
    * beforeInsertHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeInsertHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;

            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
            );

            Test.startTest();
                insert studentTest;
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(!insertedStudent.isEmpty(), 'Inserted student should be found.');
        }
    }

    /**
    * testBeforeInsertHandle_InActiveTrigger
    * beforeInsertHandleメソッドの非アクティブトリガーテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeInsertHandle_InActiveTrigger() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(T01_InActive_flg__c = true);
            insert setting;
            Class__c classRecord = new Class__c();
            insert classRecord;
            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
            );

            Test.startTest();
                insert studentTest;
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(!insertedStudent.isEmpty(), 'Inserted student should be found.');
        }
    }

    /**
    * testBeforeInsertHandle_Exception
    * beforeInsertHandleメソッドの例外系テスト（例外をスローする場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeInsertHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;

            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
            );
            T01_StudentTriggerHandler.beforeTriggerThrowException = true;

            Test.startTest();
                try {
                    insert studentTest;
                } 
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(insertedStudent.isEmpty(), 'Inserted student should not be found.');
        }
    }

    /**
    * testBeforeInsertHandle_UnderAge
    * beforeInsertHandleメソッドの例外系テスト（年齢が18歳未満の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeInsertHandle_UnderAge() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;
            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-INVALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
            );

            Test.startTest();
                try {
                    insert studentTest;
                } 
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('学生の年齢が無効です。有効な年齢は18歳以上です。'), 'Expected exception message for underage student.');
                }
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(insertedStudent.isEmpty(), 'Inserted student should not be found.');
        }
    }

    /**
    * testBeforeInsertHandle_BlankInput
    * beforeInsertHandleメソッドの例外系テスト（空の入力リスト）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeInsertHandle_BlankInput() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = null
                , FirstName__c = null
                , BirthDay__c = null
                , Gender__c = null
                , Class_look__c = null
            );

            Test.startTest();
                try {
                    insert studentTest;
                } 
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('値を入力してください'), 'Expected exception message for blank input student.');
                }
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(insertedStudent.isEmpty(), 'Inserted student should not be found.');
        }
    }

    /**
    * testBeforeUpdateHandle_Success
    * beforeUpdateHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeUpdateHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;
            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
            );
            insert studentTest;
            studentTest.Gender__c = GENDER_FEMALE;

            Test.startTest();
                update studentTest;
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Gender__c 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(!insertedStudent.isEmpty(), 'Inserted student should be found.');
            Assert.areEqual(insertedStudent[0].Gender__c, GENDER_FEMALE, 'Gender should be updated.');
        }
    }

    /**
    * testBeforeUpdateHandle_Exception
    * beforeUpdateHandleメソッドの例外系テスト（例外をスローする場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeUpdateHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;
            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
            );
            insert studentTest;
            studentTest.Gender__c = GENDER_FEMALE;
            T01_StudentTriggerHandler.beforeTriggerThrowException = true;

            Test.startTest();
                try {
                    update studentTest;
                } 
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();

            List<Student__c> insertedStudent = [
                SELECT Gender__c 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(!insertedStudent.isEmpty(), 'Inserted student should be found.');
            Assert.areEqual(insertedStudent[0].Gender__c, GENDER_MALE, 'Gender should not be updated due to exception.');
        }
    }

    /**
    * testBeforeDeleteHandle_Success
    * beforeDeleteHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeDeleteHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
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

            Test.startTest();
                delete studentTest;
            Test.stopTest();

            List<Student__c> deletedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            List<SubjectScore__c> deletedSubjectScores = [
                SELECT Id 
                FROM SubjectScore__c 
                WHERE Student_look__c = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(deletedStudent.isEmpty(), 'Deleted student should not be found.');
            Assert.isTrue(deletedSubjectScores.isEmpty(), 'SubjectScore__c records related to the deleted student should also be deleted.');
        }
    }

    /**
    * testBeforeDeleteHandle_Exception
    * beforeDeleteHandleメソッドの例外系テスト（例外をスローする場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testBeforeDeleteHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
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
            T01_StudentTriggerHandler.beforeTriggerThrowException = true;

            Test.startTest();
                try {
                    delete studentTest;
                } catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();

            List<Student__c> deletedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(!deletedStudent.isEmpty(), 'Deleted student should be found.');
        }
    }

    /**
    * testAfterInsertHandle_IncreaseNumberOfStudent
    * afterInsertHandleメソッドの正常系テスト（学生数の増加を確認）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_IncreaseNumberOfStudent() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;

            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
                , LearningStatus__c = LEARNING_STATUS_ENROLLED
            );

            Test.startTest();
                insert studentTest;
            Test.stopTest();

            Class__c insertedClass = [
                SELECT Id
                , NumberOfStudent__c 
                FROM Class__c 
                WHERE Id = :classRecord.Id 
                LIMIT 1
            ];
            Assert.isTrue(insertedClass.NumberOfStudent__c != null, 'NumberOfStudent__c should be incremented to 1 after inserting a student.');
        }
    }

    /**
    * メソッド名：testAfterInsertHandle_Exception
    * 概要：afterInsertHandleメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterInsertHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;
            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
                , LearningStatus__c = ''
            );
            T01_StudentTriggerHandler.afterTriggerThrowException = true;

            Test.startTest();
                try {
                    insert studentTest;
                }
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();

            Class__c insertedClass = [
                SELECT Id
                , NumberOfStudent__c 
                FROM Class__c 
                WHERE Id = :classRecord.Id 
                LIMIT 1
            ];
            Assert.isNull(insertedClass.NumberOfStudent__c, 'NumberOfStudent__c should be null after inserting a student.');
        }
    }

    /**
    * testAfterUpdateHandle_Success
    * afterUpdateHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterUpdateHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List <Student__c> studentList = new List<Student__c>();
            for (Integer i = 0; i < 5; i++) {
                Student__c student = createAndInsertTestStudent();
                studentList.add(student);
            }
            studentList[0].LearningStatus__c = null;

            Test.startTest();
                update studentList[0];
            Test.stopTest();

            Class__c updatedClass = [
                SELECT Id
                , NumberOfStudent__c 
                FROM Class__c 
                WHERE Id = :studentList[0].Class_look__c LIMIT 1
            ];
            Assert.isTrue(updatedClass.NumberOfStudent__c == 0, 'NumberOfStudent__c should be 0 after updating the student.');
        }
    }

    /**
    * testAfterUpdateHandle_Exception
    * afterUpdateHandleメソッドの例外系テスト（例外をスローする場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterUpdateHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.LearningStatus__c = null;
            T01_StudentTriggerHandler.afterTriggerThrowException = true;
            
            Test.startTest();
                try {
                    update studentTest;
                }
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();

            Class__c updatedClass = [
                SELECT Id
                , NumberOfStudent__c 
                FROM Class__c 
                WHERE Id = :studentTest.Class_look__c 
                LIMIT 1
            ];
            Assert.isTrue(updatedClass.NumberOfStudent__c == 1, 'NumberOfStudent__c should be 1 after updating the student.');
        }
    }

    /**
    * testAfterDeleteHandle_Success
    * afterDeleteHandleメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterDeleteHandle_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;

            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
                , LearningStatus__c = LEARNING_STATUS_ENROLLED
            );
            insert studentTest;

            Test.startTest();
                delete studentTest;
            Test.stopTest();
            
            Class__c updatedClass = [
                SELECT Id
                , NumberOfStudent__c 
                FROM Class__c 
                WHERE Id = :classRecord.Id
                LIMIT 1
            ];
            Assert.isTrue(updatedClass.NumberOfStudent__c == 0, 'NumberOfStudent__c should be decremented to 0 after deleting the student.');
        }
    }

    /**
    * testAfterDeleteHandle_Exception
    * afterDeleteHandleメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testAfterDeleteHandle_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;

            Student__c studentTest = new Student__c(
                Name = 'Test Student'
                , Lastname__c = 'Test'
                , FirstName__c = 'Student'
                , BirthDay__c = Date.today().addYears(-VALID_AGE)
                , Gender__c = GENDER_MALE
                , Class_look__c = classRecord.Id
                , LearningStatus__c = LEARNING_STATUS_ENROLLED
            );
            insert studentTest;
            T01_StudentTriggerHandler.afterTriggerThrowException = true;

            Test.startTest();
                try {
                    delete studentTest;
                }
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for test exception.');
                }
            Test.stopTest();

            Class__c updatedClass = [
                SELECT Id
                , NumberOfStudent__c 
                FROM Class__c 
                WHERE Id = :classRecord.Id 
                LIMIT 1
            ];
            Assert.isTrue(updatedClass.NumberOfStudent__c == 1, 'NumberOfStudent__c should remain as 1 after attempting to delete the student with an exception.');
        }
    }

    /**
    * createTestUser
    * テスト用のユーザーを作成する
    * @param：なし
    * @return：User - 作成されたユーザー
    * @created：2026/07/16 Nguyen Ngoc Quy
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
    * @return：Student__c - 作成された学生レコード
    * @created：2026/07/16 Nguyen Ngoc Quy
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
            , Gender__c = GENDER_MALE
            , Class_look__c = classRecord.Id
            , LearningStatus__c = LEARNING_STATUS_ENROLLED
        );
        insert studentTest;

        Student__c returnStudent = [
            SELECT Id
            , Name
            , LastName__c
            , FirstName__c
            , Birthday__c
            , Gender__c
            , Class_look__c
            , Class_look__r.Name
            , LearningStatus__c
            , StudentCode__c 
            FROM Student__c 
            WHERE Id = :studentTest.Id 
            LIMIT 1
        ];   
        return returnStudent;
    }
}