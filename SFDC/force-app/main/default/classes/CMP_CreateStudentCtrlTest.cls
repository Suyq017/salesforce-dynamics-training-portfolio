/**
* クラス名：CMP_CreateStudentCtrlTest
* クラス概要：学生のクラス選択肢を取得するコントローラークラスのテスト
* @created：2026/07/21 Nguyen Ngoc Quy
* @modified: 2026/07/21 Nguyen Ngoc Quy
*/
@isTest
private class CMP_CreateStudentCtrlTest {

    /**
    * testGetClassOptions_Success
    * getClassOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetClassOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Class__c> testClasses = createAndInsertTestClasses(3);

            Test.startTest();
                Map<String, String> classOptions = CMP_CreateStudentCtrl.getClassOptions();
            Test.stopTest();

            Assert.isNotNull(classOptions, 'Class options must not be null');
            Assert.isTrue(!classOptions.isEmpty(), 'Class options must not be empty');
            Assert.isTrue(classOptions.size() == 3, 'Class options size should match the number of inserted classes');
        }
    }

    /**
    * testGetClassOptions_EmptyClassException
    * getClassOptionsメソッドのクラスが存在しない場合のテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetClassOptions_EmptyClassException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.getClassOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('クラスが見つかりませんでした。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();
        }
    }

    /**
    * testGetGenderOptions_Success
    * getGenderOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetGenderOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, String> genderOptions = CMP_CreateStudentCtrl.getGenderOptions();
            Test.stopTest();

            Assert.isNotNull(genderOptions, 'Gender options must not be null');
        }
    }

    /**
    * testGetGenderOptions_Exception
    * getGenderOptionsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetGenderOptions_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            CMP_CreateStudentCtrl.throwException = true;
            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.getGenderOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('性別の選択肢が見つかりませんでした。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();
        }
    }

    /**
    * testGetLearningStatusOptions_Success
    * getLearningStatusOptionsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetLearningStatusOptions_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, String> learningStatusOptions = CMP_CreateStudentCtrl.getLearningStatusOptions();
            Test.stopTest();

            Assert.isNotNull(learningStatusOptions, 'Learning status options must not be null');
        }
    }

    /**
    * testGetLearningStatusOptions_Exception
    * getLearningStatusOptionsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetLearningStatusOptions_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            CMP_CreateStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.getLearningStatusOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('学習状況の選択肢が見つかりませんでした。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_Success
    * CMP_CreateStudentCtrl.saveStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = new Student__c(
                Firstname__c = 'TestFirstName'
                , LastName__c = 'TestLastName'
                , Birthday__c = Date.newInstance(1990, 1, 1)
                , Gender__c = 'Male'
                , Class_look__c = createAndInsertTestClasses(1)[0].Id
                , LearningStatus__c = 'Enrolled'
            );

            Test.startTest();
                CMP_CreateStudentCtrl.saveStudent(studentTest);
            Test.stopTest();

            List<Student__c> savedStudent = [
                SELECT Id
                , FirstName__c
                , LastName__c
                , Birthday__c 
                FROM Student__c 
                WHERE Id = :studentTest.Id 
                LIMIT 1
            ];
            Assert.isTrue(savedStudent != null, 'The student should be saved successfully.');
            Assert.isTrue(!savedStudent.isEmpty(), 'The saved student record should not be empty.');
        }
    }

    /**
    * testSaveStudent_NullStudent
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生情報がnullの場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_NullStudent() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest;
            
            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生情報が提供されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_BlankFirstName
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生の名前が空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_BlankFirstName() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = new Student__c(
                Firstname__c = ''
                , LastName__c = 'TestLastName'
                , Birthday__c = Date.newInstance(1990, 1, 1)
                , Gender__c = 'Male'
                , Class_look__c = createAndInsertTestClasses(1)[0].Id
                , LearningStatus__c = 'Enrolled'
            );
            
            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の名前が提供されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_BlankLastName
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生の名字が空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_BlankLastName() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = new Student__c(
                Firstname__c = 'TestFirstName'
                , LastName__c = ''
                , Birthday__c = Date.newInstance(1990, 1, 1)
                , Gender__c = 'Male'
                , Class_look__c = createAndInsertTestClasses(1)[0].Id
                , LearningStatus__c = 'Enrolled'
            );

            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の名字が提供されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_UnderAge
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生が18歳未満の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_UnderAge() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createTestStudent();
            studentTest.BirthDay__c = Date.today(); 

            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生は18歳以上でなければなりません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_NullClass
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生のクラスが選択されていない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_NullClass() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createTestStudent();
            studentTest.Class_look__c = null;

            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生のクラスが選択されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_NullGender
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生の性別が選択されていない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_NullGender() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createTestStudent();
            studentTest.Gender__c = null;

            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
                }
                catch (Exception e) {
                    Assert.areEqual('学生の性別が選択されていません。', e.getMessage(), 'The exception message should indicate that the student information is null.');
                }
            Test.stopTest();
        }
    }

    /**
    * testSaveStudent_NullLearningStatus
    * CMP_CreateStudentCtrl.saveStudentメソッドの異常系テスト（学生の学習状況が選択されていない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_NullLearningStatus() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createTestStudent();
            studentTest.LearningStatus__c = null;

            Test.startTest();
                try {
                    CMP_CreateStudentCtrl.saveStudent(studentTest);
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

    /**
    * createAndInsertTestClasses
    * テスト用のクラスレコードを作成する
    * @param：Integer numberOfClasses - 作成するクラスレコードの数
    * @return：List<Class__c> - 作成されたクラスレコードのリスト
    * @created：2026/07/21 Nguyen Ngoc Quy
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