/**
* クラス名  : B01_DeleteSubjectScoreBatch
* クラス概要: SubjectScore__cオブジェクトを削除するバッチ処理
* @created : 2026/07/17 Nguyen Ngoc Quy
* @modified: 
*/
@isTest
private class B01_DeleteSubjectScoreBatchTest {

    /**
    * testB01_DeleteSubjectScoreBatch_Success
    * B01_DeleteSubjectScoreBatchの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreBatch_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();

            Test.startTest();
                Database.executeBatch(new B01_DeleteSubjectScoreBatch(),1);
            Test.stopTest();
            
            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB01_DeleteSubjectScoreBatch_startException
    * B01_DeleteSubjectScoreBatchのstartメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreBatch_StartException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B01_DeleteSubjectScoreBatch.startThrowException = true;
            
            Test.startTest();
                try {
                    Database.executeBatch(new B01_DeleteSubjectScoreBatch(),1);
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
    * testB01_DeleteSubjectScoreBatch_ExecuteException
    * B01_DeleteSubjectScoreBatchのexecuteメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreBatch_ExecuteException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B01_DeleteSubjectScoreBatch.executeThrowException = true;

            Test.startTest();
                Database.executeBatch(new B01_DeleteSubjectScoreBatch(),1);
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
    * testB01_DeleteSubjectScoreBatch_FinishException
    * B01_DeleteSubjectScoreBatchのfinishメソッド例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreBatch_FinishException() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B01_DeleteSubjectScoreBatch.finishThrowException = true;

            Test.startTest();
                try {
                    Database.executeBatch(new B01_DeleteSubjectScoreBatch(),1);
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
    * testB01_DeleteSubjectScoreBatch_CustomSettingNotEmpty
    * B01_DeleteSubjectScoreBatchの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreBatch_CustomSettingNotEmpty() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            StudentManageSetting__c customSetting = new StudentManageSetting__c(
                B02_BatchSize__c = 1
            );
            insert customSetting;

            Test.startTest();
                Database.executeBatch(new B01_DeleteSubjectScoreBatch(),1);
            Test.stopTest();

            List<BatchLog__c> batchLogs = [
                SELECT Id
                , Result__c
                , StartTime__c
                , EndTime__c 
                FROM BatchLog__c
            ];
            Assert.isTrue(!batchLogs.isEmpty(), 'BatchLog__c records should be created.');
            Assert.areEqual('Success', batchLogs[0].Result__c, 'BatchLog__c Result should be Success.');
            Assert.isTrue(batchLogs[0].StartTime__c != null, 'BatchLog__c StartTime__c should not be null.');
            Assert.isTrue(batchLogs[0].EndTime__c != null, 'BatchLog__c EndTime__c should not be null.');
        }
    }

    /**
    * testB01_DeleteSubjectScoreScheduler_Success
    * B01_DeleteSubjectScoreSchedulerの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreScheduler_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B01_DeleteSubjectScoreScheduler scheduler = new B01_DeleteSubjectScoreScheduler();
            string sch = '0 0 0 * * ?';
            string schName = 'Test B01_DeleteSubjectScoreScheduler';


            Test.startTest();
                System.schedule(schName, sch, scheduler);
            Test.stopTest();

            CronTrigger ct = [
                SELECT Id
                , CronExpression 
                FROM CronTrigger 
                WHERE CronJobDetail.Name = :schName 
                LIMIT 1
            ];
            Assert.areEqual(sch, ct.CronExpression, 'The schedule must be set correctly.');
        }
    }

    /**
    * testB01_DeleteSubjectScoreScheduler_WithBatchSize
    * B01_DeleteSubjectScoreSchedulerの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreScheduler_WithBatchSize() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B01_DeleteSubjectScoreScheduler scheduler = new B01_DeleteSubjectScoreScheduler();
            string sch = '0 0 0 * * ?';
            string schName = 'Test B01_DeleteSubjectScoreScheduler';
            StudentManageSetting__c customSetting = new StudentManageSetting__c(
                B01_BatchSize__c = 1
            );
            insert customSetting;

            Test.startTest();
                System.schedule(schName, sch, scheduler);
            Test.stopTest();

            CronTrigger ct = [
                SELECT Id
                , CronExpression 
                FROM CronTrigger 
                WHERE CronJobDetail.Name = :schName 
                LIMIT 1
            ];
            Assert.areEqual(sch, ct.CronExpression, 'The schedule must be set correctly.');
        }
    }

    /**
    * testB01_DeleteSubjectScoreScheduler_Exception
    * B01_DeleteSubjectScoreSchedulerの例外系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    @isTest
    private static void testB01_DeleteSubjectScoreScheduler_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            initSetup();
            B01_DeleteSubjectScoreScheduler scheduler = new B01_DeleteSubjectScoreScheduler();
            string sch = '0 0 0 * * ?';
            string schName = 'Test B01_DeleteSubjectScoreScheduler';
            B01_DeleteSubjectScoreScheduler.throwException = true;

            Test.startTest();
                try {
                    System.schedule(schName, sch, scheduler);
                } 
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should match the expected message.');
                }
            Test.stopTest();
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

        Semester__c semester = new Semester__c();
        insert semester;

        Subject__c subject = new Subject__c(
            Name='Math'
            , CourseCredit__c = 3
        );
        insert subject;

        SubjectScore__c subjectScore = new SubjectScore__c(
            Semester_look__c = semester.Id,
            Subject_look__c = subject.Id,
            Student_look__c = studentTest.Id
        );
        insert subjectScore;
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