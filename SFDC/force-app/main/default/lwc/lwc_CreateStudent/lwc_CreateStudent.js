/**
 * lwc_CreateStudent.js
 * 学生情報を作成するためのLWCコンポーネントのJavaScriptファイルです。
 * @created 2026/06/22 Nguyen Ngoc Quy
 * @modified 2026/07/13 Nguyen Ngoc Quy
 */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveStudent from '@salesforce/apex/LWC_CreateStudentCtrl.saveStudent';
import fetchOptions from '@salesforce/apex/LWC_CreateStudentCtrl.fetchOptions';

export default class Lwc_CreateStudent extends LightningElement {
    
    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = '不明なエラーが発生しました。';
    // 2026/07/13 Nguyen Ngoc Quy Add End

    // 2026/07/14 Nguyen Ngoc Quy Delete Start
    // MIN_AGE = 18;
    // 2026/07/14 Nguyen Ngoc Quy Delete End
    
    tempStudent;
    student = {
        Lastname__c: '',
        Firstname__c: '',
        Birthday__c: null,
        Class_look__c: '',
        Gender__c: '',
        LearningStatus__c: ''
    };
    spinner = false;
    classOptions = [];
    learningStatusOptions = [];
    genderOptions = [];
    isOpened = false;

    /**
     * handleSaveStudent
     * 学生情報を保存します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    async handleSaveStudent() {
        try {
            if (this.spinner) {
                return;
            }              
            // 2026/07/09 Nguyen Ngoc Quy Delete Start
            // let isValid = this.validateForm();
            // if (!isValid) {
            //     return;
            // }
            // 2026/07/09 Nguyen Ngoc Quy Delete End
            this.spinner = true;
            this.tempStudent = this.student;
            this.student = null;
            await saveStudent({ student: this.tempStudent });
            this.showToast('Success', '学生情報が正常に保存されました。', 'success');
            this.dispatchEvent(new CustomEvent('studentcreatedsuccessfully'));
            this.isOpened = false;
            this.resetForm();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生情報の保存に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
            this.student = this.tempStudent;
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * resetForm
     * フォームをリセットします。
     * @param なし
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
     */
    resetForm() {
        this.student = {
            Lastname__c: '',
            Firstname__c: '',
            Birthday__c: null,
            Class_look__c: '',
            Gender__c: '',
            LearningStatus__c: ''
        };
    }

    // 2026/07/09 Nguyen Ngoc Quy Delete Start
    // /**
    //  * validateForm
    //  * フォームの入力値を検証します。
    //  * @param なし
    //  * @return boolean 入力値が有効かどうか
    //  * @created 2026/06/22 Nguyen Ngoc Quy
    //  */
    // validateForm(){
    //     let requiredFields = this.template.querySelectorAll('[data-field-type="requiredField"]');
    //     let birthdayField = this.template.querySelector('[data-field-type="birthdayField"]');
    //     let isValid = true;
    //     let isBirthdayValid = true;

    //     if (!birthdayField.checkValidity()) {
    //         birthdayField.reportValidity();
    //         isValid = false;
    //     } else if (this.getAge(birthdayField.value) < this.MIN_AGE) {
    //         birthdayField.reportValidity();
    //         isBirthdayValid = false;
    //         isValid = false;
    //     }

    //     requiredFields.forEach(field => {
    //         if (!field.checkValidity()) {
    //             field.reportValidity();
    //             isValid = false;
    //         }
    //     });

    //     if (!isBirthdayValid) {
    //         this.showToast('Error', '生年月日は' + this.MIN_AGE + '歳以上である必要があります。', 'error');
    //     }
    //     return isValid;
    // }

    // /**
    //  * getAge
    //  * 生年月日から年齢を計算します。
    //  * @param dateString 生年月日文字列
    //  * @return 年齢
    //  * @created 2026/06/22 Nguyen Ngoc Quy
    //  */
    // getAge(dateString) {
    //     let today = new Date();
    //     let birthDate = new Date(dateString);
    //     let age = today.getFullYear() - birthDate.getFullYear();
    //     let month = today.getMonth() - birthDate.getMonth();
    //     if (month < 0 || (month === 0 && today.getDate() < birthDate.getDate())) {
    //         age--;
    //     }
    //     return age;
    // }
    // 2026/07/09 Nguyen Ngoc Quy Delete End

    /**
     * handleClose
     * モーダルを閉じます。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     */
    handleClose() {
        this.resetForm();
        this.isOpened = false;
    }

    /**
     * fetchOptions
     * 選択肢を取得します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    async fetchOptions() {
        try {
            this.spinner = true;
            const data = await fetchOptions();
            this.genderOptions.push(...Object.keys(data.genderOptions).map(key => ({ label: data.genderOptions[key], value: key })));
            this.classOptions.push(...Object.keys(data.classOptions).map(key => ({ label: data.classOptions[key].Name, value: data.classOptions[key].Id })));
            this.learningStatusOptions.push(...Object.keys(data.learningStatusOptions).map(key => ({ label: data.learningStatusOptions[key], value: key })));
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '選択肢の取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * handleInputChange
     * 入力値の変更を処理します。
     * @param event 入力イベント
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     */
    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.value;

        switch (field) {
            case 'Lastname':
                this.student.Lastname__c = value;
                break;
            case 'Firstname':
                this.student.Firstname__c = value;
                break;
            case 'Birthday':
                this.student.Birthday__c = value;
                break;
            case 'Class':
                this.student.Class_look__c = value;
                break;
            case 'Gender':
                this.student.Gender__c = value;
                break;
            case 'LearningStatus':
                this.student.LearningStatus__c = value;
                break;
        }
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
    async openModal() {
        try {
            if (this.classOptions.length === 0 || this.learningStatusOptions.length === 0 || this.genderOptions.length === 0) {
                await this.fetchOptions();
            }
            this.isOpened = true;
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