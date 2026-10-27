/**
* クラス名  : LWC_StudentScoreBatchLauncherCtrl
* クラス概要: 学生の得点を削除するバッチ処理を起動するコントローラークラス
* @created : 2026/07/07 Nguyen Ngoc Quy
* @modified: 2026/07/21 Nguyen Ngoc Quy
*/
public with sharing class LWC_StudentScoreBatchLauncherCtrl {
    // 2026/07/21 Nguyen Ngoc Quy Add Start
    @TestVisible
    private static Boolean throwException = false;
    // 2026/07/21 Nguyen Ngoc Quy Add End

    private static final INTEGER DEFAULT_BATCH_SIZE = 200;
    
    private static final String B01_BATCHLOG_NAME = 'B01_科目得点削除バッチ';
    private static final String B02_BATCHLOG_NAME = 'B02_科目得点作成バッチ';
    private static final String B03_BATCHLOG_NAME = 'B03_学生得点更新バッチ';
    private static final List<String> BATCHLOG_NAMES = new List<String>{B01_BATCHLOG_NAME, B02_BATCHLOG_NAME, B03_BATCHLOG_NAME};
    
    /**
    * launchBatch
    * バッチ処理を起動するメソッド
    * @param: なし
    * @return: なし
    * @created: 2026/07/07 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static void launchBatch() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End
            
            Integer b01BatchSize;
            StudentManageSetting__c setting = StudentManageSetting__c.getOrgDefaults();
            if (setting.B01_BatchSize__c == null || setting.B01_BatchSize__c <= 0) {
                b01BatchSize = DEFAULT_BATCH_SIZE;
            } else {
                b01BatchSize = Integer.valueOf(setting.B01_BatchSize__c);
            }
            B01_DeleteSubjectScoreBatch b01 = new B01_DeleteSubjectScoreBatch();
            Database.executeBatch(b01, b01BatchSize);
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * isBatchRunning
    * バッチ処理が実行中かどうかを確認するメソッド
    * @param: なし
    * @return: Boolean - バッチ処理が実行中の場合はtrue、そうでない場合はfalse
    * @created: 2026/07/07 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Boolean isBatchRunning() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            List<BatchLog__c> listBatchLogs = [
                SELECT Id
                , Result__c
                FROM BatchLog__c 
                WHERE Name IN :BATCHLOG_NAMES 
                    AND EndTime__c = null 
                    AND Result__c = null
                LIMIT 1
            ];
            return !listBatchLogs.isEmpty();
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * newMessageException
    * 例外メッセージを作成するヘルパーメソッド
    * @param: String message - 例外メッセージの内容
    * @return: AuraHandledException - 作成された例外オブジェクト
    * @created: 2026/07/07 Nguyen Ngoc Quy
    * @modified:
    */
    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    // 2026/07/21 Nguyen Ngoc Quy Add Start
    /**
    * throwExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    private static void throwExceptionForTesting() {
        if (throwException) {
            throw newMessageException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/21 Nguyen Ngoc Quy Add End
}