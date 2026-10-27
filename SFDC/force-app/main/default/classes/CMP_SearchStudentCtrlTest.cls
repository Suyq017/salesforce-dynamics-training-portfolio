/**
* クラス名  ：CMP_SearchStudentCtrlTest
* クラス概要：CMP_SearchStudentCtrlのテストクラス
* @created ：2026/07/21 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class CMP_SearchStudentCtrlTest {
    /**
    * testFetchStudentsList_Success
    * fetchStudentsListメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchStudentsList_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            List<Student__c> resultList;

            Test.startTest();
                resultList = CMP_SearchStudentCtrl.fetchStudents();
            Test.stopTest();

            Assert.isNotNull(resultList, 'result List must not be null');
            Assert.isTrue(!resultList.isEmpty(), 'result List must not be empty');
        }
    }

    /**
    * testFetchStudentsList_Exception
    * fetchStudentsListメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchStudentsList_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> resultList;

            Test.startTest();
                try {
                    resultList = CMP_SearchStudentCtrl.fetchStudents();
                }
                catch (Exception e) {
                    Assert.areEqual('学生が見つかりませんでした。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();

            Assert.isNull(resultList, 'result List must be null');
        }
    }

    /**
    * testSearchStudents_Suscess
    * searchStudentsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudents_Suscess() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();

            Test.startTest();
                List<Student__c> resultList = CMP_SearchStudentCtrl.searchStudents(
                    studentRecord.StudentCode__c
                    , studentRecord.Name
                    , studentRecord.Class_look__c
                    , studentRecord.Gender__c
                    , studentRecord.BirthDay__c
                    , studentRecord.Birthday__c.day().toString()
                    , studentRecord.Birthday__c.month().toString()
                    , studentRecord.Birthday__c.year().toString()
                );
            Test.stopTest();

            Assert.isNotNull(resultList, 'result List must not be null');
            Assert.isTrue(!resultList.isEmpty(), 'result List must not be empty');
        }
    }

    /**
    * testSearchStudents_EmptySearchKey
    * searchStudentsメソッドの空の検索キーでのテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudents_EmptySearchKey() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();

            Test.startTest();
                List<Student__c> resultList = CMP_SearchStudentCtrl.searchStudents(
                    ''
                    , ''
                    , ''
                    , ''
                    , null
                    , ''
                    , ''
                    , ''
                );
            Test.stopTest();

            Assert.isNotNull(resultList, 'result List must not be null');
            Assert.isTrue(!resultList.isEmpty(), 'result List must not be empty');
        }
    }

    /**
    * testSearchStudents_Exception
    * searchStudentsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudents_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            CMP_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    CMP_SearchStudentCtrl.searchStudents(
                        ''
                        , ''
                        , ''
                        , ''
                        , null
                        , ''
                        , ''
                        , ''
                    );
                }
                catch (Exception e) {
                    Assert.areEqual('検索条件に一致する学生が見つかりませんでした。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();
        }
    }

    /**
    * testDeleteListStudents_Success
    * deleteListStudentsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteListStudents_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();

            Test.startTest();
                CMP_SearchStudentCtrl.deleteListStudents(new List<Id>{studentRecord.Id});
            Test.stopTest();

            List<Student__c> resultList = [
                SELECT Id 
                FROM Student__c 
                WHERE Id = :studentRecord.Id
            ];
            Assert.isNotNull(resultList, 'result List must not be null');
            Assert.isTrue(resultList.isEmpty(), 'result List must be empty after deletion');
        }
    }

    /**
    * testGetCustomSettings_SucessWithoutCustomSettings
    * getCustomSettingsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetCustomSettings_SucessWithoutCustomSettings(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, Decimal> customSettings = CMP_SearchStudentCtrl.getCustomSettings();
            Test.stopTest();

            Assert.isNotNull(customSettings, 'Custom settings must not be null');
            Assert.isTrue(!customSettings.isEmpty(), 'Custom settings must not be empty when no custom settings are present');
            Assert.isTrue(customSettings.get('MaxRecord') == 2000, 'Default MaxRecord should be 2000 when no custom settings are present');
            Assert.isTrue(customSettings.get('RecordPerPage') == 5, 'Default RecordPerPage should be 5 when no custom settings are present');
        }
    }

    /**
    * testGetCustomSettings_SucessWithCustomSettings
    * getCustomSettingsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetCustomSettings_SucessWithCustomSettings(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c customSetting = new StudentManageSetting__c(S_RecordPerPage__c = 10, S_MaxRecord__c = 100);
            insert customSetting;

            Test.startTest();
                Map<String, Decimal> customSettings = CMP_SearchStudentCtrl.getCustomSettings();
            Test.stopTest();

            Assert.isNotNull(customSettings, 'Custom settings must not be null');
            Assert.isTrue(!customSettings.isEmpty(), 'Custom settings must not be empty when custom settings are present');
            Assert.isTrue(customSettings.get('MaxRecord') == 100, 'Custom MaxRecord should be 100 when custom settings are present');
            Assert.isTrue(customSettings.get('RecordPerPage') == 10, 'Custom RecordPerPage should be 10 when custom settings are present');
        }
    }

    /**
    * testGetCustomSettings_Exception
    * getCustomSettingsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetCustomSettings_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            CMP_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    CMP_SearchStudentCtrl.getCustomSettings();
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();
        }
    }

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
                Map<String, String> classOptions = CMP_SearchStudentCtrl.getClassOptions();
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
                    CMP_SearchStudentCtrl.getClassOptions();
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
                Map<String, String> genderOptions = CMP_SearchStudentCtrl.getGenderOptions();
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
            CMP_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    CMP_SearchStudentCtrl.getGenderOptions();
                }
                catch (Exception e) {
                    Assert.areEqual('性別の選択肢が見つかりませんでした。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();
        }
    }

    /**
    * testDeleteListStudents_Exception
    * deleteListStudentsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteListStudents_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
            try {
                CMP_SearchStudentCtrl.deleteListStudents(new List<Id>{});
            }
            catch (Exception e) {
                Assert.areEqual('学生IDのリストが無効です。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
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