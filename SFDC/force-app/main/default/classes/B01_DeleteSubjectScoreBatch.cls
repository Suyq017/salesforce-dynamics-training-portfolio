/**
* クラス名  : B01_DeleteSubjectScoreBatch
* クラス概要: SubjectScore__cオブジェクトの削除バッチ
* @created : 2026/07/02 Nguyen Ngoc Quy
* @modified: 2026/07/20 Nguyen Ngoc Quy
*/
public without sharing class B01_DeleteSubjectScoreBatch implements Database.Batchable<SObject>, Database.Stateful {

    private static final String BATCHLOG_NAME = 'B01_科目得点削除バッチ';
    private static final String ERROR_RESULT = 'Error';
    private static final String SUCCESS_RESULT = 'Success';
    private static final INTEGER DEFAULT_BATCH_SIZE = 200;
    private BatchLog__c batchLog;

    // 2026/07/20 Nguyen Ngoc Quy Add start
    @TestVisible
    private static Boolean startThrowException = false;
    @TestVisible
    private static Boolean executeThrowException = false;
    @TestVisible
    private static Boolean finishThrowException = false;
    // 2026/07/20 Nguyen Ngoc Quy Add end

    /**
    * start
    * SubjectScore__cオブジェクトのクエリロケータを返す
    * @param: Database.BatchableContext bc - バッチコンテキスト
    * @return: Database.QueryLocator - SubjectScore__cオブジェクトのクエリロケータ
    * @created: 2026/07/02 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        try {
            // Insert a new BatchLog__c record
            this.batchLog = insertBatchLog();

            // 2026/07/20 Nguyen Ngoc Quy Add start
            startThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

            // Query to select all SubjectScore__c records
            return Database.getQueryLocator([
                SELECT Id
                FROM SubjectScore__c
            ]);
        }
        catch (Exception e) {
            updateBatchLog(this.batchLog, ERROR_RESULT, e.getMessage());
            System.abortJob(bc.getJobId());
            return null;
        }
    }
    
    /**
    * execute
    * delete処理を実行する
    * @param: Database.BatchableContext bc - バッチコンテキスト, List<SubjectScore__c> listSubjectScores - SubjectScore__cオブジェクトのリスト
    * @return: なし
    * @created: 2026/07/02 Nguyen Ngoc Quy
    * @modified:
    */
    public void execute(Database.BatchableContext bc, List<SubjectScore__c> listSubjectScores){
        delete listSubjectScores;
    }

    /**
    * finish
    * バッチ処理の終了処理を実行する
    * @param: Database.BatchableContext bc - バッチコンテキスト
    * @return: なし
    * @created: 2026/07/02 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    public void finish(Database.BatchableContext bc){
        try {
            // 2026/07/20 Nguyen Ngoc Quy Add start
            finishThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end
            
            List<AsyncApexJob> listJobs = [
                SELECT Id
                , NumberOfErrors
                , ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
                LIMIT 1
            ];
            if (!listJobs.isEmpty()) {
                AsyncApexJob job = listJobs[0];
                // 2026/07/20 Nguyen Ngoc Quy Modify start
                // if (job.NumberOfErrors > 0) {
                if (job.NumberOfErrors > 0 || (Test.isRunningTest() && executeThrowException)) {
                // 2026/07/20 Nguyen Ngoc Quy Modify end
                    updateBatchLog(this.batchLog, ERROR_RESULT, job.ExtendedStatus);
                    return;
                }
                if (job.NumberOfErrors == 0) {
                    updateBatchLog(this.batchLog, SUCCESS_RESULT, null);

                    StudentManageSetting__c setting = StudentManageSetting__c.getOrgDefaults();
                    Integer b02_BatchSize;
                    if (setting.B02_BatchSize__c == null || setting.B02_BatchSize__c <= 0) {
                        b02_BatchSize = DEFAULT_BATCH_SIZE;
                    } else {
                        b02_BatchSize = Integer.valueOf(setting.B02_BatchSize__c);
                    }
                    
                    B02_CreateSubjectScoreBatch b02_CreateSubjectScoreBatch = new B02_CreateSubjectScoreBatch();
                    Database.executeBatch(b02_CreateSubjectScoreBatch, b02_BatchSize);
                }
            }
        }
        catch (Exception e) {
            updateBatchLog(this.batchLog, ERROR_RESULT, e.getMessage());
        }
    }

    /**
    * insertBatchLog
    * batchLog__cレコードを挿入する
    * @param: なし
    * @return: BatchLog__c - 挿入されたbatchLog__cレコード
    * @created: 2026/07/02 Nguyen Ngoc Quy
    * @modified:
    */
    private static BatchLog__c insertBatchLog() {
        BatchLog__c newBatchLog = new BatchLog__c();
        newBatchLog.Name = BATCHLOG_NAME;
        newBatchLog.StartTime__c = System.now();
        insert newBatchLog;
        return newBatchLog;
    }
    
    /**
    * updateBatchLog
    * batchLog__cレコードを更新する
    * @param: BatchLog__c batchLog - 更新するbatchLog__cレコード, String result - 更新する結果, String errorMessage - 更新するエラーメッセージ
    * @return: なし
    * @created: 2026/07/02 Nguyen Ngoc Quy
    * @modified:
    */
    private static void updateBatchLog(BatchLog__c batchLog, String result, String errorMessage) {
        batchLog.EndTime__c = System.now();
        batchLog.Result__c = result;
        batchLog.ErrorMessage__c = errorMessage;
        update batchLog;
    }

    // 2026/07/20 Nguyen Ngoc Quy Add start
    /**
    * startThrowExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static void startThrowExceptionForTesting() {
        if (startThrowException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * finishThrowExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static void finishThrowExceptionForTesting() {
        if (finishThrowException && Test.isRunningTest()) {
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