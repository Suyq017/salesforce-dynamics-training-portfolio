/*
 * lwc_StudentScoreBatchLauncher.js
 * 学生スコアバッチ起動コンポーネントのJavaScriptコードです。
 * @created 2026/07/06 Nguyen Ngoc Quy
 * @modified
**/
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import launchBatch from '@salesforce/apex/LWC_StudentScoreBatchLauncherCtrl.launchBatch';
import isBatchRunning from '@salesforce/apex/LWC_StudentScoreBatchLauncherCtrl.isBatchRunning';

export default class Lwc_StudentScoreBatchLauncher extends LightningElement {

    spinner = false;

    /**
     * handleStartButtonClicked
     * スタートボタンがクリックされたときにトーストメッセージを表示します。
     * @param なし
     * @return なし
     * @created 2026/07/06 Nguyen Ngoc Quy
     * @modified
     */
    async handleStartButtonClicked() {
        try {
            this.spinner = true;
            let isRunning = await isBatchRunning();
            // If the batch is still running, show an error toast and return
            if (isRunning) {
                this.showToast('Error', 'バッチ処理が既に実行中です。完了するまでしばらくお待ちください。', 'error');
                this.spinner = false;
                return;
            }
            // If the batch is not running, launch it and show a success toast
            await launchBatch();
            this.showToast('Success', 'バッチジョブが正常に開始されました。', 'success');
            this.spinner = false;
        }
        catch (error) {
            this.showToast('Error', error.body ? error.body.message : 'エラーが発生しました。', 'error');
            this.spinner = false;
        }  
    }

    /**
     * showToast
     * トーストメッセージを表示します。
     * @param title タイトル, message メッセージ, variant 種類
     * @return なし
     * @created 2026/07/06 Nguyen Ngoc Quy
     * @modified
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}