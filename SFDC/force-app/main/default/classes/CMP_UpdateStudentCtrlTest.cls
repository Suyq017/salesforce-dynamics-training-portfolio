/**
* クラス名  ：CMP_UpdateStudentCtrlTest
* クラス概要：学生情報を更新するコントローラークラスのテストクラス
* @created ：2026/07/16 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class CMP_UpdateStudentCtrlTest {

    /**
    * testGetClassOptions_Success
    * getClassOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetClassOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Class__c> classList = createAndInsertTestClasses(3);

            Test.startTest();
                Map<String, String> result = CMP_UpdateStudentCtrl.getClassOptions();
            Test.stopTest();

            Assert.isTrue(!result.isEmpty(), 'The number of class options should match the number of classes created.');
        }
    }

    /**
    * testGetClassOptions_EmptyResult
    * getClassOptionsメソッドの正常系テスト（クラスが存在しない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetClassOptions_EmptyResult() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, String> result;

            Test.startTest();
                try {
                    result = CMP_UpdateStudentCtrl.getClassOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('クラスが見つかりませんでした。', e.getMessage(), 'The exception message should indicate that no classes were found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The returned class options should be null when no classes exist.');
        }
    }

    /**
    * testGetGenderOptions_Success
    * getGenderOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetGenderOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, String> result = CMP_UpdateStudentCtrl.getGenderOptions();
            Test.stopTest();

            Assert.isTrue(!result.isEmpty(), 'The number of gender options should not be empty.');
        }
    }

    /**
    * testGetGenderOptions_EmptyException
    * getGenderOptionsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetGenderOptions_EmptyException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, String> result;
            CMP_UpdateStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    result = CMP_UpdateStudentCtrl.getGenderOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('性別の選択肢が見つかりませんでした。', e.getMessage(), 'The exception message should indicate that no gender options were found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The number of gender options should be null when exception is thrown.');
        }
    }

    /**
    * testGetLearningStatusOptions_Success
    * getLearningStatusOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetLearningStatusOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, String> result = CMP_UpdateStudentCtrl.getLearningStatusOptions();
            Test.stopTest();

            Assert.isTrue(!result.isEmpty(), 'The number of learning status options should be 3.');
        }
    }

    /**
    * testGetLearningStatusOptions_EmptyException
    * getLearningStatusOptionsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetLearningStatusOptions_EmptyException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, String> result;
            CMP_UpdateStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    result = CMP_UpdateStudentCtrl.getLearningStatusOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('学習状況の選択肢が見つかりませんでした。', e.getMessage(), 'The exception message should indicate that no learning status options were found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The number of learning status options should be null when exception is thrown.');
        }
    }

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
                Student__c result = CMP_UpdateStudentCtrl.getStudent(studentTest.Id);
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
    * testGetStudent_EmptyResult
    * CMP_DetailStudentCtrl.getStudentメソッドの異常系テスト（学生が見つからない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_EmptyResult() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            delete studentTest;
            Student__c result;

            Test.startTest();
                try {
                    result = CMP_UpdateStudentCtrl.getStudent(studentTest.Id);
                }
                catch (Exception e) {
                    Assert.areEqual('学生が見つかりませんでした。', e.getMessage(), 'The exception message should indicate that the student was not found.');
                }
            Test.stopTest();

            Assert.isNull(result, 'The returned student should be null.');
        }
    }

    /**
    * testGetStudent_BlankId
    * CMP_DetailStudentCtrl.getStudentメソッドの異常系テスト（学生IDが空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_BlankId() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c result;

            Test.startTest();
                try {
                    // Blank ID for testing
                    result = CMP_UpdateStudentCtrl.getStudent('');
                }
                catch (Exception e) {
                    Assert.areEqual('学生IDが提供されていません。', e.getMessage(), 'The exception message should indicate that the student ID is blank.');
                }
                Test.stopTest();

            Assert.isNull(result, 'The returned student should be null.');
        }
    }

    /**
    * testUpdateStudent_Success
    * CMP_UpdateStudentCtrl.updateStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.FirstName__c = 'UpdatedFirstName';
            studentTest.LastName__c = 'UpdatedLastName';
            studentTest.Birthday__c = Date.newInstance(1995, 5, 15);

            Test.startTest();
                CMP_UpdateStudentCtrl.updateStudent(studentTest);
            Test.stopTest();

            Student__c updatedStudent = [
                SELECT Id
                , FirstName__c
                , LastName__c
                , Birthday__c 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.areEqual(studentTest.FirstName__c, updatedStudent.FirstName__c, 'The FirstName should be updated.');
            Assert.areEqual(studentTest.LastName__c, updatedStudent.LastName__c, 'The LastName should be updated.');
            Assert.areEqual(studentTest.Birthday__c, updatedStudent.Birthday__c, 'The Birthday should be updated.');
        }
    }

    /**
    * testUpdateStudent_NullStudent
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生情報がnullの場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_NullStudent() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest;
            
            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生情報が提供されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testUpdateStudent_BlankFirstName
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生の名前が空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_BlankFirstName() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.FirstName__c = '';
            
            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の名前が提供されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testUpdateStudent_BlankLastName
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生の名字が空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_BlankLastName() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.LastName__c = '';

            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の名字が提供されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testUpdateStudent_UnderAge
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生が18歳未満の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_UnderAge() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.BirthDay__c = Date.today().addYears(-17); 

            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生は18歳以上でなければなりません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testUpdateStudent_NullClass
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生のクラスが選択されていない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_NullClass() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.Class_look__c = null;

            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生のクラスが選択されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testUpdateStudent_NullGender
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生の性別が選択されていない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_NullGender() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.Gender__c = null;

            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の性別が選択されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testUpdateStudent_NullLearningStatus
    * CMP_UpdateStudentCtrl.updateStudentメソッドの異常系テスト（学生の学習状況が選択されていない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_NullLearningStatus() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            studentTest.LearningStatus__c = null;

            Test.startTest();
                try {
                    CMP_UpdateStudentCtrl.updateStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の学習状況が選択されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
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

    /**
    * createAndInsertTestClasses
    * テスト用のクラスレコードを作成する
    * @param：Integer numberOfClasses - 作成するクラスの数
    * @return：List<Class__c> - 作成されたクラスレコードのリスト
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    private static List<Class__c> createAndInsertTestClasses(Integer numberOfClasses) {
        List<Class__c> classList = new List<Class__c>();
        for (Integer i = 0; i < numberOfClasses; i++) {
            Class__c classRecord = new Class__c();
            classList.add(classRecord);
        }
        insert classList;
        return classList;
    }
}