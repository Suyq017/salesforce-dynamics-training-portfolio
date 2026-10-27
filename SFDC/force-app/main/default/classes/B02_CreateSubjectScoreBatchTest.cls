/**
* クラス名  : B02_CreateSubjectScoreBatchTest
* クラス概要: SubjectScore__cオブジェクトを削除するバッチ処理
* @created : 2026/07/17 Nguyen Ngoc Quy
* @modified: 
*/
@isTest
private class B02_CreateSubjectScoreBatchTest {

    /**
    * testB02_CreateSubjectScoreBatch_Success
    * B02_CreateSubjectScoreBatchの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB02_CreateSubjectScoreBatch_StartException
    * B02_CreateSubjectScoreBatchのstartメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_StartException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B02_CreateSubjectScoreBatch.startThrowException = true;

            Test.startTest();
                try {
                    Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
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
    * testB02_CreateSubjectScoreBatch_ExecuteException
    * B02_CreateSubjectScoreBatchのexecuteメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_ExecuteException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B02_CreateSubjectScoreBatch.executeThrowException = true;

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
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
    * testB02_CreateSubjectScoreBatch_FinishException
    * B02_CreateSubjectScoreBatchのfinishメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_FinishException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B02_CreateSubjectScoreBatch.finishThrowException = true;

            Test.startTest();
                try {
                    Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
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
    * testB02_CreateSubjectScoreBatch_CustomSettingNotEmpty
    * B02_CreateSubjectScoreBatchの正常系テスト（CustomSettingが空でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_CustomSettingNotEmpty() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            StudentManageSetting__c customSetting = new StudentManageSetting__c(
                B03_BatchSize__c = 1
            );
            insert customSetting;

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB02_CreateSubjectScoreBatch_EmptySubject
    * B02_CreateSubjectScoreBatchの正常系テスト（CustomSettingが空でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_EmptySubject() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<Subject__c> listSubject = [
                SELECT Id 
                FROM Subject__c
            ];
            delete listSubject;

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB02_CreateSubjectScoreBatch_EmptySemester
    * B02_CreateSubjectScoreBatchの正常系テスト（CustomSettingが空でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_EmptySemester() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<Semester__c> listSemesters = [
                SELECT Id 
                FROM Semester__c
            ];
            delete listSemesters;

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB02_CreateSubjectScoreBatch_NoMoreAvailableSemesters
    * B02_CreateSubjectScoreBatchの正常系テスト（CustomSettingが空でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_NoMoreAvailableSemesters() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<Semester__c> listSemesters = [
                SELECT Id 
                FROM Semester__c
            ];
            delete listSemesters[0];

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB02_CreateSubjectScoreBatch_NoMoreAvailableSubjects
    * B02_CreateSubjectScoreBatchの正常系テスト（CustomSettingが空でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_NoMoreAvailableSubjects() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<Subject__c> listSubjects = [
                SELECT Id 
                FROM Subject__c
            ];
            delete listSubjects[0];

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB02_CreateSubjectScoreBatch_OverCreditLimit
    * B02_CreateSubjectScoreBatchの正常系テスト（CustomSettingが空でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB02_CreateSubjectScoreBatch_OverCreditLimit() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            List<Subject__c> listSubjects = [
                SELECT Id 
                FROM Subject__c
            ];
            for (Integer i = 0; i < listSubjects.size(); i++) {
                listSubjects[i].CourseCredit__c = 10;
            }
            update listSubjects;

            Test.startTest();
                Database.executeBatch(new B02_CreateSubjectScoreBatch(),1);
            Test.stopTest();

            List<SubjectScore__c> subjectScores = [
                SELECT Id 
                FROM SubjectScore__c
            ];
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!subjectScores.isEmpty(), 'SubjectScore__c records should be created.');
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
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

        List<Semester__c> listSemesters = new List<Semester__c>();
        for (Integer i = 0; i < 2; i++) {
            Semester__c semester = new Semester__c();
            listSemesters.add(semester);
        }
        insert listSemesters;

        List<Subject__c> listSubjects = new List<Subject__c>();
        for (Integer i = 0; i < 5; i++) {
            Subject__c subject = new Subject__c(
                Name='Math' + i,
                CourseCredit__c=3
            );
            listSubjects.add(subject);
        }
        insert listSubjects;
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
}