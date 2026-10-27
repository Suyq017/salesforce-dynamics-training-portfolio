/**
* クラス名  ：LWC_CreateStudentCtrlTest
* クラス概要：LWC_CreateStudentCtrlクラスのユニットテストを実装するためのクラス
* @created ：2026/07/21 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class LWC_CreateStudentCtrlTest {

    /**
    * testSaveStudent_Success
    * LWC_CreateStudentCtrl.saveStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c student = createTestStudent();

            Test.startTest();
                LWC_CreateStudentCtrl.saveStudent(student);
            Test.stopTest();

            Student__c savedStudent = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :student.Id
                LIMIT 1
            ];
            Assert.isNotNull(savedStudent, 'Student record should be saved successfully.');
        }
    }

    /**
    * testSaveStudent_NullStudentException
    * LWC_CreateStudentCtrl.saveStudentメソッドのnull学生レコードに対するテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_NullStudentException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c student = null;

            Test.startTest();
                try {
                    LWC_CreateStudentCtrl.saveStudent(student);
                } catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('学生情報が提供されていません。'), 'Expected exception message for null student record.');
                }
            Test.stopTest();
        }
    }

    /**
    * testFetchOptions_Success
    * LWC_CreateStudentCtrl.fetchOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, Object> options = LWC_CreateStudentCtrl.fetchOptions();
            Test.stopTest();

            Assert.isNotNull(options, 'Options map should not be null.');
            Assert.isTrue(!options.isEmpty(), 'Options map should not be empty.');
            Assert.isTrue(options.containsKey('classOptions'), 'Options map should contain classOptions.');
            Assert.isTrue(options.containsKey('learningStatusOptions'), 'Options map should contain learningStatusOptions.');
            Assert.isTrue(options.containsKey('genderOptions'), 'Options map should contain genderOptions.');
        }
    }
    
    /**
    * testFetchOptions_Exception
    * LWC_CreateStudentCtrl.fetchOptionsメソッドの例外発生時のテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchOptions_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            LWC_CreateStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    LWC_CreateStudentCtrl.fetchOptions();
                } catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message for null student record.');
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
    * createTestStudent
    * テスト用の学生レコードを作成する
    * @param：なし
    * @return：Student__c - 作成された学生レコード
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c createTestStudent() {
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
        return studentTest;
    }
}