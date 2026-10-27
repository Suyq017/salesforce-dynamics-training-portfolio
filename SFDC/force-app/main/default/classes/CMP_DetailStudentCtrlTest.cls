/**
* クラス名  ：CMP_DetailStudentCtrlTest
* クラス概要：学生の詳細情報を取得するコントローラークラスのテストクラス
* @created ：2026/07/16 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class CMP_DetailStudentCtrlTest {

    /**
    * testGetStudent_Success
    * CMP_DetailStudentCtrl.getStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();

            Test.startTest();
                Student__c result = CMP_DetailStudentCtrl.getStudent(studentTest.Id);
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
    * CMP_DetailStudentCtrl.getStudentメソッドの異常系テスト（学生が見つからない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_EmptyResultException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            delete studentTest;
            Student__c result;

            Test.startTest();
                try {
                    result = CMP_DetailStudentCtrl.getStudent(studentTest.Id);
                }
                catch (Exception e) {
                    Assert.areEqual('学生が見つかりませんでした。', e.getMessage(), 'The exception message should indicate that the student was not found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The returned student should be null.');
        }
    }

    /**
    * testGetStudent_BlankIdException
    * CMP_DetailStudentCtrl.getStudentメソッドの異常系テスト（学生IDが空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_BlankIdException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c result;

            Test.startTest();
                try {
                    // Blank ID for testing
                    result = CMP_DetailStudentCtrl.getStudent('');
                }
                catch (Exception e) {
                    Assert.areEqual('学生IDが提供されていません。', e.getMessage(), 'The exception message should indicate that the student ID is blank.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The returned student should be null.');
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
    * createAndInsertTestStudent
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