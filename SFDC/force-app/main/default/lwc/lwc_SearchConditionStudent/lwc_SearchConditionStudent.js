/*
 * lwc_SearchConditionStudent.js
 * 学生検索条件を入力するLightning Web ComponentのJavaScriptファイルです。
 * @created 2026/06/29 Nguyen Ngoc Quy
 * @modified 2026/07/13 Nguyen Ngoc Quy
**/
import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getInitDataForSearchCondition from '@salesforce/apex/LWC_SearchStudentCtrl.getInitDataForSearchCondition';
import SearchResultChannel from '@salesforce/messageChannel/LWC_SearchResultChannel__c';
import SearchConditionChannel from '@salesforce/messageChannel/LWC_SearchConditionChannel__c';
export default class Lwc_SearchConditionStudent extends LightningElement {

    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = '検索条件の初期データの取得に失敗しました。';
    // 2026/07/13 Nguyen Ngoc Quy Add End
    
    MESSAGE_CHANNEL_ACTION = {
        // Message for search with condition
        SEARCH: 'search',
        // Message for clear search condition
        CLEAR_SEARCH: 'clearSearch',
        // Message for open create student modal
        OPEN_CREATE_STUDENT_MODAL: 'openCreateStudentModal',
        // Message for open delete student confirmation modal
        OPEN_DELETE_STUDENT_CONFIRMATION_MODAL: 'openDeleteStudentConfirmationModal',
        // Message for update selected students
        UPDATE_SELECTED_STUDENTS: 'updateSelectedStudents'
    }

    MESSAGE_CHANNEL_VALUE = {
        // Value for delete list selected students
        DELETE_LIST_SELECTED_STUDENTS: 'deleteListSelectedStudents'
    }

    @track 
    searchKey = {
        studentCode: '',
        studentName: '',
        class: '',
        gender: '',
        birthday: '',
        dayOfBirth: '',
        monthOfBirth: '',
        yearOfBirth: ''
    }

    genderOptions = [];
    classOptions = []
    dayOptions = [];
    monthOptions = [];
    yearOptions = [];

    isNotAnySelectedStudent = true;

    isSearched = false;
    disableClearSearchButton = true;

    @wire(MessageContext)
    messageContext;
    searchResultSubscription = null;

    /**
     * connectedCallback
     * SearchConditionStudentコンポーネントがDOMに接続されたときに初期データを取得します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    async connectedCallback() {
        try {
            this.subscribeToSearchResultChannel();
            const data = await getInitDataForSearchCondition();
            
            this.getDayMonthYearOptions();
            
            this.genderOptions = [{ label: '--なし--', value: '' }];
            this.genderOptions.push(...Object.keys(data.genderOptions).map(key => ({ label: data.genderOptions[key], value: key })));
            if (Object.keys(data.genderOptions).length === 1) {
                this.showToast('Warning', '性別の選択肢が見つかりませんでした。', 'warning');
            }
            
            this.classOptions = [{ label: '--なし--', value: '' }];
            this.classOptions.push(...Object.keys(data.classOptions).map(key => ({ label: data.classOptions[key], value: key })));
            if (Object.keys(data.classOptions).length === 1) {
                this.showToast('Warning', 'クラスが見つかりませんでした。', 'warning');
            }
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '検索条件の初期データの取得に失敗しました。', 'error');
            this.showToast('Error', this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * disconnectedCallback
     * SearchConditionStudentコンポーネントがDOMから切断されたときに、SearchResultChannelの購読を解除します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    disconnectedCallback() {
        this.unsubscribeFromSearchResultChannel();
    }

    /**
     * subscribeToSearchResultChannel
     * SearchResultChannelを購読します。
     * @param message メッセージオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    subscribeToSearchResultChannel() {
        if (this.searchResultSubscription) {
            return;
        }
        this.searchResultSubscription = subscribe(this.messageContext, SearchResultChannel, (message) => {
            this.handleMessage(message);
        });
    }

    /**
     * unsubscribeFromSearchResultChannel
     * SearchResultChannelの購読を解除します。
     * @param message メッセージオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    unsubscribeFromSearchResultChannel() {
        if (this.searchResultSubscription) {
            unsubscribe(this.searchResultSubscription);
            this.searchResultSubscription = null;
        }
    }
        
    /**
     * handleMessage
     * SearchResultChannelからのメッセージを処理します。
     * @param message メッセージオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    handleMessage(message) {
        if (message.action == this.MESSAGE_CHANNEL_ACTION.UPDATE_SELECTED_STUDENTS) {
            const selectedStudentsIdList = message.value;
            const selectedStudentsCount = selectedStudentsIdList.length;
            this.isNotAnySelectedStudent = selectedStudentsCount === 0;
        }
    }

    /**
     * getDayMonthYearOptions
     * 日、月、年のオプションを生成します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    getDayMonthYearOptions() {
        this.dayOptions = [{ label: '--なし--', value: '' }];
        this.monthOptions = [{ label: '--なし--', value: '' }];
        this.yearOptions = [{ label: '--なし--', value: '' }];
        this.dayOptions.push(...Array.from({ length: 31 }, (_, i) => ({ label: String(i + 1), value: String(i + 1) })));
        this.monthOptions.push(...Array.from({ length: 12 }, (_, i) => ({ label: String(i + 1), value: String(i + 1) })));
        const currentYear = new Date().getFullYear();
        this.yearOptions.push(...Array.from({ length: 100 }, (_, i) => ({ label: String(currentYear - i), value: String(currentYear - i) })));
    }

    /**
     * showToast
     * トーストメッセージを表示します。
     * @param title タイトル, message メッセージ, variant 種類
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    /**
     * handleSearchKeyChange
     * 検索キーの変更を処理します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    handleSearchKeyChange(event) {
        const field = event.target.name;
        this.searchKey[field] = event.target.value;

        switch (field) {
            case 'birthday':
                this.handleBirthdayChange();
                break;
            case 'dayOfBirth':
                this.handleDateChange();
                break;
            case 'monthOfBirth':
                this.handleDateChange();
                break;
            case 'yearOfBirth':
                this.handleDateChange();
                break;
        }
    
        if ((this.searchKey.studentCode.trim().length > 0)
                || (this.searchKey.studentName.trim().length > 0) 
                || (this.searchKey.class.trim().length > 0)
                || (this.searchKey.gender.trim().length > 0)
                || (this.searchKey.birthday.trim().length > 0)
                || (this.searchKey.dayOfBirth.trim().length > 0)
                || (this.searchKey.monthOfBirth.trim().length > 0)
                || (this.searchKey.yearOfBirth.trim().length > 0)
            ) {
                this.disableClearSearchButton = false;
        } else {
            if (!this.isSearched) {
                this.disableClearSearchButton = true;
            }
        }
    }

    /**
     * handleBirthdayChange
     * 生年月日が変更されたときに、日生、月生、年生の値をクリアします。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    handleBirthdayChange() {
        if (this.searchKey.birthday && (this.searchKey.dayOfBirth 
                                        || this.searchKey.monthOfBirth 
                                        || this.searchKey.yearOfBirth)) {
            this.searchKey.dayOfBirth = '';
            this.searchKey.monthOfBirth = '';
            this.searchKey.yearOfBirth = '';
        }
    }

    /**
     * handleDateChange
     * 日付選択が変更されたときに、関連する日付フィールドの値を処理します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */    
    handleDateChange() {
        if ((this.searchKey.dayOfBirth 
            || this.searchKey.monthOfBirth 
            || this.searchKey.yearOfBirth) && this.searchKey.birthday) {
            this.searchKey.birthday = '';
        }
    }

    /**
     * handleSearch
     * 検索ボタンがクリックされたときに、検索条件を処理します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */   
    handleSearch() {
        this.isSearched = true;
        publish(this.messageContext, SearchConditionChannel, {action: this.MESSAGE_CHANNEL_ACTION.SEARCH, value: this.searchKey });
    }

    /**
     * handleClearSearch
     * 検索条件のクリアボタンがクリックされたときに、検索条件をクリアします。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */  
    handleClearSearch() {
        publish(this.messageContext, SearchConditionChannel, {action: this.MESSAGE_CHANNEL_ACTION.CLEAR_SEARCH});
        this.resetSearchKey();
        this.isSearched = false;
        this.disableClearSearchButton = true;
    }

    /**
     * openCreateStudentModal
     * 新規学生作成モーダルを開くためのメッセージを送信します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */  
    openCreateStudentModal(){
        publish(this.messageContext, SearchConditionChannel, {action: this.MESSAGE_CHANNEL_ACTION.OPEN_CREATE_STUDENT_MODAL});
    }

    /**
     * openDeleteStudentConfirmationModal
     * 選択された学生の削除確認モーダルを開くためのメッセージを送信します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */  
    openDeleteStudentConfirmationModal() {
        publish(this.messageContext, SearchConditionChannel, {action: this.MESSAGE_CHANNEL_ACTION.OPEN_DELETE_STUDENT_CONFIRMATION_MODAL, value: this.MESSAGE_CHANNEL_VALUE.DELETE_LIST_SELECTED_STUDENTS});
    }

    /**
     * resetSearchKey
     * 検索キーを初期化します。
     * @param なし
     * @return なし
     * @created 2026/06/30 Nguyen Ngoc Quy
     */
    resetSearchKey() {
        this.searchKey = {
            studentCode: '',
            studentName: '',
            class: '',
            gender: '',
            birthday: '',
            dayOfBirth: '',
            monthOfBirth: '',
            yearOfBirth: ''
        }
    }
}