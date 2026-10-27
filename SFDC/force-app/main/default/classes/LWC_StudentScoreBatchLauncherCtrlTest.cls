/**
* クラス名  ：LWC_StudentScoreBatchLauncherCtrlTest
* クラス概要：LWC_StudentScoreBatchLauncherCtrlのテストクラス
* @created ：2026/07/21 Nguyen Ngoc Quy
* @modified：
*/
@isTest
private class LWC_StudentScoreBatchLauncherCtrlTest {

    private static final String BATCHLOG_NAME = 'B01_科目得点削除バッチ';

    /**
    * testLaunchBatch_SuccessWithoutCustomSetting
    * LWC_StudentScoreBatchLauncherCtrlのlaunchBatchメソッドの正常系テスト
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testLaunchBatch_SuccessWithoutCustomSetting() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                LWC_StudentScoreBatchLauncherCtrl.launchBatch();
            Test.stopTest();

            BatchLog__c batchLog = [
                SELECT Id 
                FROM BatchLog__c 
                WHERE Name = :BATCHLOG_NAME 
                ORDER BY StartTime__c DESC 
                LIMIT 1
            ];
            Assert.isNotNull(batchLog, 'The returned batch log should not be null.');
        }
    }

    /**
    * testLaunchBatch_SuccessWithCustomSetting
    * LWC_StudentScoreBatchLauncherCtrlのlaunchBatchメソッドの正常系テスト（カスタム設定あり）
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testLaunchBatch_SuccessWithCustomSetting() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(B01_BatchSize__c = 50);
            insert setting;

            Test.startTest();
                LWC_StudentScoreBatchLauncherCtrl.launchBatch();
            Test.stopTest();

            BatchLog__c batchLog = [
                SELECT Id 
                FROM BatchLog__c 
                WHERE Name = :BATCHLOG_NAME 
                ORDER BY StartTime__c DESC 
                LIMIT 1
            ];
            Assert.isNotNull(batchLog, 'The returned batch log should not be null.');
        }
    }

    /**
    * testLaunchBatch_Success
    * LWC_StudentScoreBatchLauncherCtrlのlaunchBatchメソッドの異常系テスト（例外発生時）
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testLaunchBatch_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            LWC_StudentScoreBatchLauncherCtrl.throwException = true;

            Test.startTest();
                try {
                    LWC_StudentScoreBatchLauncherCtrl.launchBatch();
                }
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message to contain "テスト用の例外が発生しました。", but got: ' + e.getMessage());
                }
            Test.stopTest();

            List<BatchLog__c> batchLog = [
                SELECT Id 
                FROM BatchLog__c 
                WHERE Name = :BATCHLOG_NAME 
                ORDER BY StartTime__c DESC 
                LIMIT 1
            ];
            Assert.isTrue(batchLog.isEmpty(), 'The returned batch log should be null.');
        }
    }

    /**
    * testIsBatchRunning_True
    * LWC_StudentScoreBatchLauncherCtrlのisBatchRunningメソッドの正常系テスト（バッチ処理が実行中の場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testIsBatchRunning_True(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            BatchLog__c batchLog = new BatchLog__c(
                Name = BATCHLOG_NAME
                , StartTime__c = System.now()
            );
            insert batchLog;

            Test.startTest();
                Boolean isRunning = LWC_StudentScoreBatchLauncherCtrl.isBatchRunning();
            Test.stopTest();

            Assert.isTrue(isRunning, 'Expected isBatchRunning to return true, but got false.');
        }
    }

    /**
    * testIsBatchRunning_False
    * LWC_StudentScoreBatchLauncherCtrlのisBatchRunningメソッドの正常系テスト（バッチ処理が実行中でない場合）
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testIsBatchRunning_False(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                Boolean isRunning = LWC_StudentScoreBatchLauncherCtrl.isBatchRunning();
            Test.stopTest();

            Assert.isTrue(!isRunning, 'Expected isBatchRunning to return false, but got true.');
        }
    }

    /**
    * testIsBatchRunning_Exception
    * LWC_StudentScoreBatchLauncherCtrlのisBatchRunningメソッドの異常系テスト（例外発生時）
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testIsBatchRunning_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            LWC_StudentScoreBatchLauncherCtrl.throwException = true;
            Test.startTest();
                try {
                    LWC_StudentScoreBatchLauncherCtrl.isBatchRunning();
                }
                catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外が発生しました。'), 'Expected exception message to contain "テスト用の例外が発生しました。", but got: ' + e.getMessage());
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
}