/**
 * lwc_DetailStudent.js
 * 学生情報の詳細を表示するためのLWCコンポーネントのJavaScriptファイルです。
 * @created 2026/06/19 Nguyen Ngoc Quy
 * @modified 2026/07/13 Nguyen Ngoc Quy
 */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getStudentDetail from '@salesforce/apex/LWC_DetailStudentCtrl.getStudentDetail';

export default class Lwc_DetailStudent extends NavigationMixin(LightningElement) {
    
    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = '不明なエラーが発生しました。';
    // 2026/07/13 Nguyen Ngoc Quy Add End
    
    student;
    spinner = false;
    isOpened = false;
    studentId;

    /**
     * fetchStudentDetail
     * 学生情報を取得します。
     * @param StudentId 学生ID
     * @return なし
     * @created 2026/06/19 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    async fetchStudentDetail() {
        try {
            this.spinner = true;
            this.student = await getStudentDetail({ studentId: this.studentId });
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modify Start
            // this.showToast('Error', error.body ? error.body.message : '学生情報の取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modify End
        }
        finally {
            this.spinner = false;
        }
    }
    
    /**
     * openClassPage
     * クラスページを開きます。
     * @param なし
     * @return なし
     * @created 2026/06/19 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    openClassPage() {
        try {
            let pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.student.Class_look__c,
                    objectApiName: 'Class__c',
                    actionName: 'view'
                },
            };
            if (this.student.Class_look__c) {
                this[NavigationMixin.Navigate](pageRef);
            } else {
                this.showToast('Error', 'クラス情報が見つかりません。クラスページに移動できません。', 'error');
            };
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'クラスページの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * handleClose
     * モーダルを閉じます。
     * @param なし
     * @return なし
     * @created 2026/06/19 Nguyen Ngoc Quy
     */
    handleClose() {
        this.isOpened = false;
        this.student = null;
    }

    /**
     * getter className
     * クラス名を取得します。
     * @param なし
     * @return string クラス名
     * @created 2026/06/19 Nguyen Ngoc Quy
     */
    get className(){
        return this.student?.Class_look__r?.Name || '';
    }

    /**
     * openModal
     * モーダルを開きます。
     * @param なし
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    @api 
    async openModal(studentId) {
        try {
            this.isOpened = true;
            this.studentId = studentId;
            await this.fetchStudentDetail();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * showToast
     * トーストメッセージを表示します。
     * @param title タイトル, message メッセージ, variant 種類
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}