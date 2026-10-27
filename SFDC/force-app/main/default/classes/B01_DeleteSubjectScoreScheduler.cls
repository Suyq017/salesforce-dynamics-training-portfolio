/**
* クラス名  : B01_DeleteSubjectScoreScheduler
* クラス概要: 学生の得点を削除するバッチ処理をスケジュールするクラス
* @created : 2026/07/06 Nguyen Ngoc Quy
* @modified: 2026/07/20 Nguyen Ngoc Quy
*/
public class B01_DeleteSubjectScoreScheduler implements Schedulable {

    // 2026/07/20 Nguyen Ngoc Quy Add start
    @TestVisible
    private static Boolean throwException = false;
    // 2026/07/20 Nguyen Ngoc Quy Add end

    private static final INTEGER DEFAULT_BATCH_SIZE = 200;
    private static final String SCHEDULER_BATCHLOG_NAME = 'B01_スケジューラバッチ';
    private static final String ERROR_RESULT = 'Error';
    /**
    * execute
    * スケジュールされたバッチ処理を実行するメソッド
    * @param: SchedulableContext SC - スケジュールコンテキスト
    * @return: なし
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public void execute(SchedulableContext sc) {
        try {
            // 2026/07/20 Nguyen Ngoc Quy Add start
            ThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

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
            createErrorBatchLog(e.getMessage());
        }
    }

    /**
    * createErrorBatchLog
    * バッチ処理のエラーログを作成するヘルパーメソッド
    * @param: String errorMessage - エラーメッセージ
    * @return: なし
    * @created: 2026/07/06 Nguyen Ngoc Quy
    * @modified:
    */
    private static void createErrorBatchLog(String errorMessage) {
        BatchLog__c newBatchLog = new BatchLog__c(
            Name = SCHEDULER_BATCHLOG_NAME,
            StartTime__c = System.now(),
            EndTime__c = System.now(),
            Result__c = ERROR_RESULT,
            ErrorMessage__c = errorMessage
        );
        insert newBatchLog;
    }

    // 2026/07/20 Nguyen Ngoc Quy Add start
    /**
    * ThrowExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static void ThrowExceptionForTesting() {
        if (throwException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * クラス名  : CustomException
    * クラス概要: カスタム例外クラス
    * @created : 2026/07/20 Nguyen Ngoc Quy
    * @modified: 
    */
    class CustomException extends Exception {}
    // 2026/07/20 Nguyen Ngoc Quy Add end
}