/**
 * lwc_UpdateStudent.js
 * 学生情報を更新するためのLWCコンポーネントのJavaScriptファイルです。
 * @created 2026/06/22 Nguyen Ngoc Quy
 * @modified 2026/07/13 Nguyen Ngoc Quy
 */
import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateStudent from '@salesforce/apex/LWC_UpdateStudentCtrl.updateStudent';
import getStudentDetail from '@salesforce/apex/LWC_UpdateStudentCtrl.getStudentDetail';
import fetchOptions from '@salesforce/apex/LWC_UpdateStudentCtrl.fetchOptions';

export default class Lwc_UpdateStudent extends LightningElement {
    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = '不明なエラーが発生しました。';
    // 2026/07/13 Nguyen Ngoc Quy Add End

    // 2026/07/14 Nguyen Ngoc Quy Delete Start
    // MIN_AGE = 18;
    // 2026/07/14 Nguyen Ngoc Quy Delete End
    
    student;
    
    tempStudent;

    spinner = false;
    classOptions = [];
    learningStatusOptions = [];
    genderOptions = [];
    isOpened = false;
    studentId;

    /**
     * fetchStudentDetail
     * 学生詳細情報を取得します。
     * @param StudentId 学生ID
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    async fetchStudentDetail() {
        try {
            const result = await getStudentDetail({ studentId: this.studentId });
            this.student = result;
            
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生情報の取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

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
            this.tempStudent = this.student;
            this.student = null;
            this.spinner = true;
            await updateStudent({ student: this.tempStudent });
            this.showToast('Success', '学生情報が正常に更新されました。', 'success');
            this.isOpened = false;
            this.tempStudent.Gender__c = this.genderOptions.find(option => option.value === this.tempStudent.Gender__c)?.label || '';
            this.dispatchEvent(new CustomEvent('studentupdatedsuccessfully', { detail: { newStudent: this.tempStudent } }));
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生情報の更新に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
            this.student = this.tempStudent;
        }
        finally {
            this.spinner = false;
        }
    }

    // 2026/07/09 Nguyen Ngoc Quy Delete Start
    // /**
    //  * validateForm
    //  * フォームの入力を検証します。
    //  * @param なし
    //  * @return boolean 入力が有効かどうか
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
    //         this.showToast('Error', '生年月日から計算された年齢は' + this.MIN_AGE + '歳以上である必要があります。', 'error');
    //     }
    //     return isValid;
    // }

    // /**
    //  * getAge
    //  * 生年月日から年齢を計算します。
    //  * @param dateString 生年月日
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
        this.isOpened = false;
        this.resetForm();
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
    }

    /**
     * handleInputChange
     * フォームの入力変更を処理します。
     * @param event イベントオブジェクト
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
                this.student.Class_look__r.Name = this.classOptions.find(option => option.value === value)?.label || '';
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
    async openModal(studentId) {
        try {
            this.isOpened = true;
            this.spinner = true;
            if (this.classOptions.length === 0 || this.learningStatusOptions.length === 0 || this.genderOptions.length === 0) {
                await this.fetchOptions();
            }
            this.studentId = studentId;
            await this.fetchStudentDetail();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
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

    /**
     * resetForm
     * フォームをリセットします。
     * @param なし
     * @return なし
     * @created 2026/06/26 Nguyen Ngoc Quy
     */
    resetForm() {
        this.student = null;
        this.spinner = false;
        this.isOpened = false;
        this.studentId = null;
    }
}