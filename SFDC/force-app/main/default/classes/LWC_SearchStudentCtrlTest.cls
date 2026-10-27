/**
* クラス名  ：LWC_SearchStudentCtrlTest
* クラス概要：LWC_SearchStudentCtrlのテストクラス
* @created ：2026/07/16 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class LWC_SearchStudentCtrlTest {
    private static final Integer VALID_MAX_RECORDS = 200;
    private static final Integer INVALID_NEGATIVE_MAX_RECORDS = -1;

    /**
    * testFetchStudentsList_Success
    * fetchStudentsListメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchStudentsList_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            Integer maxRecords = VALID_MAX_RECORDS;
            List<Student__c> resultList;

            Test.startTest();
                resultList = LWC_SearchStudentCtrl.fetchStudentsList(maxRecords);
            Test.stopTest();

            Assert.isNotNull(resultList, 'result List must not be null');
            Assert.isTrue(!resultList.isEmpty(), 'result List must not be empty');
        }
    }

    /**
    * testFetchStudentsList_NegativeMaxRecords
    * fetchStudentsListメソッドの負のmaxRecords値でのテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchStudentsList_NegativeMaxRecords() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            Integer maxRecords = INVALID_NEGATIVE_MAX_RECORDS;
            List<Student__c> resultList;

            Test.startTest();
                resultList = LWC_SearchStudentCtrl.fetchStudentsList(maxRecords);
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
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFetchStudentsList_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            Integer maxRecords = VALID_MAX_RECORDS;
            List<Student__c> resultList;
            LWC_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    resultList = LWC_SearchStudentCtrl.fetchStudentsList(maxRecords);
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();

            Assert.isNull(resultList, 'result List must be null');
        }
    }

    /**
    * testSearchStudents_SuscessWithNegativeMaxrecord
    * searchStudentsメソッドの負のmaxRecords値でのテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudents_SuscessWithNegativeMaxrecord() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            Integer maxRecords = INVALID_NEGATIVE_MAX_RECORDS;
            List<Student__c> resultList;

            Test.startTest();
                resultList = LWC_SearchStudentCtrl.searchStudents(studentRecord.StudentCode__c
                , studentRecord.Name
                , studentRecord.Class_look__c
                , studentRecord.Gender__c
                , studentRecord.BirthDay__c
                , studentRecord.Birthday__c.day().toString()
                , studentRecord.Birthday__c.month().toString()
                , studentRecord.Birthday__c.year().toString()
                , maxRecords);
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
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudents_EmptySearchKey() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            Integer maxRecords = INVALID_NEGATIVE_MAX_RECORDS;

            Test.startTest();
                List<Student__c> resultList = LWC_SearchStudentCtrl.searchStudents(
                    ''
                    , ''
                    , ''
                    , ''
                    , null
                    , ''
                    , ''
                    , ''
                    , null
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
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudents_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();
            Integer maxRecords = INVALID_NEGATIVE_MAX_RECORDS;
            List<Student__c> resultList;
            LWC_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    resultList = LWC_SearchStudentCtrl.searchStudents(
                        ''
                        , ''
                        , ''
                        , ''
                        , null
                        , ''
                        , ''
                        , ''
                        , null
                    );
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();

            Assert.isNull(resultList, 'result List must be null');
        }
    }

    /**
    * testDeleteListStudents_Success
    * deleteListStudentsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteListStudents_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentRecord = createAndInsertTestStudent();

            Test.startTest();
                LWC_SearchStudentCtrl.deleteListStudents(new List<Id>{studentRecord.Id});
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
    * testGetInitData_Success
    * getInitDataメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitData_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, Object> initData;
            List<Class__c> classList = createAndInsertTestClasses(3);
            StudentManageSetting__c customSetting = new StudentManageSetting__c(
                S_MaxRecord__c = 100,
                S_RecordPerPage__c = 10
            );
            insert customSetting;

            Test.startTest();
                initData = LWC_SearchStudentCtrl.getInitData();
            Test.stopTest();

            Assert.isNotNull(initData, 'Init data must not be null');
            Assert.isTrue(initData.containsKey('classOptions'), 'Init data must contain classList');
            Assert.isTrue(initData.containsKey('genderOptions'), 'Init data must contain genderList');
            Assert.isTrue(initData.containsKey('CustomSettings'), 'Init data must contain learningStatusList');
            Assert.isTrue(initData.containsKey('studentsList'), 'Init data must contain maxRecordsList');
            Assert.isTrue(((Map<String, String>)initData.get('classOptions')).keySet().size() == classList.size(), 'Init data classOptions must contain all created classes');
        }
    }

    /**
    * testGetInitData_Exception
    * getInitDataメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitData_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, Object> initData;
            List<Class__c> classList = createAndInsertTestClasses(3);
            LWC_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    initData = LWC_SearchStudentCtrl.getInitData();
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();

            Assert.isNull(initData, 'Init data must be null');
        }
    }

    /**
    * testGetInitData_NullCustomSetting
    * getInitDataメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitData_NullCustomSetting() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, Object> initData;
            List<Class__c> classList = createAndInsertTestClasses(3);

            Test.startTest();
                initData = LWC_SearchStudentCtrl.getInitData();
            Test.stopTest();

            Assert.isNotNull(initData, 'Init data must not be null');
        }
    }

    /**
    * testGetInitDataForSearchCondition_Success
    * getInitDataForSearchConditionメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitDataForSearchCondition_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, Object> initData = LWC_SearchStudentCtrl.getInitDataForSearchCondition();
            Test.stopTest();

            Assert.isNotNull(initData, 'Init data must not be null');
            Assert.isTrue(initData.containsKey('classOptions'), 'Init data must contain classList');
            Assert.isTrue(initData.containsKey('genderOptions'), 'Init data must contain genderList');
        }
    }

    /**
    * testGetInitDataForSearchCondition_Exception
    * getInitDataForSearchConditionメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitDataForSearchCondition_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, Object> initData;
            LWC_SearchStudentCtrl.throwException = true;
            List<Class__c> classList = createAndInsertTestClasses(3);

            Test.startTest();
                try {
                    initData = LWC_SearchStudentCtrl.getInitDataForSearchCondition();
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();

            Assert.isNull(initData, 'Init data must be null');
        }
    }

    /**
    * testGetInitDataForSearchResult_Success
    * getInitDataForSearchResultメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitDataForSearchResult_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Map<String, Object> initData = LWC_SearchStudentCtrl.getInitDataForSearchResult();
            Test.stopTest();

            Assert.isNotNull(initData, 'Init data must not be null');
            Assert.isTrue(initData.containsKey('CustomSettings'), 'Init data must contain learningStatusList');
            Assert.isTrue(initData.containsKey('studentsList'), 'Init data must contain maxRecordsList');
        }
    }

    /**
    * testGetInitDataForSearchResult_Exception
    * getInitDataForSearchResultメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetInitDataForSearchResult_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Map<String, Object> initData;
            List<Class__c> classList = createAndInsertTestClasses(3);
            LWC_SearchStudentCtrl.throwException = true;

            Test.startTest();
                try {
                    initData = LWC_SearchStudentCtrl.getInitDataForSearchResult();
                }
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'Expected exception message not found: ' + e.getMessage());
                }
            Test.stopTest();

            Assert.isNull(initData, 'Init data must be null');
        }
    }

    /**
    * testDeleteListStudents_Exception
    * deleteListStudentsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteListStudents_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
            try {
                LWC_SearchStudentCtrl.deleteListStudents(new List<Id>{});
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
    * @param：Integer numberOfClasses - 作成するクラスレコードの数
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