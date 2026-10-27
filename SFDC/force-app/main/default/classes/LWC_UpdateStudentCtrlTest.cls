/**
* クラス名  ：LWC_UpdateStudentCtrlTest
* クラス概要：LWC_UpdateStudentCtrlクラスのテストクラス
* @created ：2026/07/21 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class LWC_UpdateStudentCtrlTest {

    /**
    * testUpdateStudent_Success
    * LWC_UpdateStudentCtrl.updateStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c student = createAndInsertTestStudent();
            student.Lastname__c = 'UpdatedLastName';
            student.Firstname__c = 'UpdatedFirstName';

            Test.startTest();
                LWC_UpdateStudentCtrl.updateStudent(student);
            Test.stopTest();

            Student__c updatedStudent = [
                SELECT Id
                , Lastname__c
                , Firstname__c 
                FROM Student__c 
                WHERE Id = :student.Id
                LIMIT 1
            ];
            Assert.isNotNull(updatedStudent, 'Student record should be updated successfully.');
            Assert.areEqual(student.Lastname__c, updatedStudent.Lastname__c, 'Last name should be updated.');
            Assert.areEqual(student.Firstname__c, updatedStudent.Firstname__c, 'First name should be updated.');
        }
    }

    /**
    * testUpdateStudent_NullStudentException
    * LWC_UpdateStudentCtrl.updateStudentメソッドのnull学生レコードに対するテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_NullStudentException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c student = null;

            Test.startTest();
                try {
                    LWC_UpdateStudentCtrl.updateStudent(student);
                } catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('学生情報が提供されていません。'), 'Expected exception message for null student record.');
                }
            Test.stopTest();
        }
    }

    /**
    * testGetStudentDetail_Success
    * LWC_UpdateStudentCtrl.getStudentDetailメソッドの正常系テスト
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
                Student__c result = LWC_UpdateStudentCtrl.getStudentDetail(studentTest.Id);
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
    * testGetStudentDetail_EmptyResultException
    * LWC_UpdateStudentCtrl.getStudentDetailメソッドの異常系テスト（学生が見つからない場合）
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
                    result = LWC_UpdateStudentCtrl.getStudentDetail(studentTest.Id);
                }
                catch (Exception e) {
                    Assert.areEqual('学生が見つかりませんでした。', e.getMessage(), 'The exception message should indicate that the student was not found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The returned student should be null.');
        }
    }

    /**
    * testFetchOptions_Success
    * LWC_UpdateStudentCtrl.fetchOptionsメソッドの正常系テスト
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
                Map<String, Object> options = LWC_UpdateStudentCtrl.fetchOptions();
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
    * LWC_UpdateStudentCtrl.fetchOptionsメソッドの例外発生時のテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchOptions_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            LWC_UpdateStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    LWC_UpdateStudentCtrl.fetchOptions();
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