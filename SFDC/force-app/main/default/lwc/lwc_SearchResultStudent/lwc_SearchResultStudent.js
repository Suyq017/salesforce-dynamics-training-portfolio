/*
 * lwc_SearchResultStudent.js
 * 学生検索結果を表示するLightning Web ComponentのJavaScriptファイルです。
 * @created 2026/06/29 Nguyen Ngoc Quy
 * @modified 2026/07/13 Nguyen Ngoc Quy
**/
import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getInitDataForSearchResult from '@salesforce/apex/LWC_SearchStudentCtrl.getInitDataForSearchResult';
import SearchResultChannel from '@salesforce/messageChannel/LWC_SearchResultChannel__c';
import SearchConditionChannel from '@salesforce/messageChannel/LWC_SearchConditionChannel__c';
import searchStudents from '@salesforce/apex/LWC_SearchStudentCtrl.searchStudents';
import deleteListStudents from '@salesforce/apex/LWC_SearchStudentCtrl.deleteListStudents';
import fetchStudentsList from '@salesforce/apex/LWC_SearchStudentCtrl.fetchStudentsList';
export default class Lwc_SearchResultStudent extends LightningElement {
    
    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = 'データの取得に失敗しました。';
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

    studentsList = [];

    @track
    studentsSearchResultList = [];
    currentPageStudentsList = [];

    currentPage = 1;
    totalPages = 1
    totalRecords = 0;
    pageNums = [];
    recordsPerPage = 5;
    maxRecord = 2000;
    isFirstPage = true;
    isLastPage = false;

    selectedStudentsCount = 0;
    selectedStudentsIdList = [];
    deleteStudentIdList = [];

    allStudentsSelected = false;

    spinner = false;
    openDeleteModal = false;

    @wire(MessageContext)
    messageContext;
    searchConditionSubscription = null;

    /**
     * connectedCallback
     * Lwc_SearchResultStudentコンポーネントがDOMに接続されたときに初期データを取得します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */  
    async connectedCallback() {
        try {
            this.subscribeToSearchConditionChannel();
            const data = await getInitDataForSearchResult();
            this.recordsPerPage = data.CustomSettings.RecordPerPage || this.recordsPerPage;
            this.maxRecord = data.CustomSettings.MaxRecord || this.maxRecord;
            
            this.studentsList = data.studentsList || [];
            if (this.studentsList.length === 0) {
                this.showToast('Warning', '学生が見つかりませんでした。', 'warning');
            }
            for (let student of this.studentsList) {
                student.isSelected = false;
                student.Class = student.Class_look__r? student.Class_look__r.Name : '';
            }
            this.studentsSearchResultList = this.studentsList;
            
            this.caculateTotalPagesAndTotalRecords();
            this.setBoolValueIfFirstOrLastPage();
            this.setCurrentPageStudentsList();
            this.updatePageNums();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'データの取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * disconnectedCallback
     * Lwc_SearchResultStudentコンポーネントがDOMから切断されたときに、SearchConditionChannelの購読を解除します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    disconnectedCallback() {
        this.unsubscribeFromSearchConditionChannel();
    }

    /**
     * subscribeToSearchConditionChannel
     * SearchConditionChannelを購読します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    subscribeToSearchConditionChannel() {
        if (this.searchConditionSubscription) {
            return;
        }
        this.searchConditionSubscription = subscribe(this.messageContext, SearchConditionChannel, (message) => {
            this.handleMessage(message);
        });
    }

    /**
     * unsubscribeFromSearchConditionChannel
     * SearchConditionChannelの購読を解除します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    unsubscribeFromSearchConditionChannel() {
        if (this.searchConditionSubscription) {
            unsubscribe(this.searchConditionSubscription);
            this.searchConditionSubscription = null;
        }
    }
    
    /**
     * handleMessage
     * SearchConditionChannelからのメッセージを処理します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handleMessage(message) {
        if (message.action == this.MESSAGE_CHANNEL_ACTION.SEARCH){
            this.searchKey = message.value;
            this.handleSearch();
        }
        if (message.action == this.MESSAGE_CHANNEL_ACTION.CLEAR_SEARCH){
            this.handleClearSearch();
        }
        if (message.action == this.MESSAGE_CHANNEL_ACTION.OPEN_CREATE_STUDENT_MODAL){
            this.openCreateStudentModal();
        }
        if (message.action == this.MESSAGE_CHANNEL_ACTION.OPEN_DELETE_STUDENT_CONFIRMATION_MODAL && message.value == this.MESSAGE_CHANNEL_VALUE.DELETE_LIST_SELECTED_STUDENTS) {
            this.deleteStudentIdList = this.selectedStudentsIdList;
            if (this.selectedStudentsIdList.length === 0) {
                this.showToast('Error', '削除する学生が選択されていません。', 'error');
                this.openDeleteModal = false;
                return;
            }
            this.openDeleteModal = true;
        }
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
     * caculateTotalPagesAndTotalRecords
     * 学生リストの総ページ数と総レコード数を計算します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    caculateTotalPagesAndTotalRecords() {
        this.totalRecords = this.studentsSearchResultList.length;
        this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
    }

    /**
     * setBoolValueIfFirstOrLastPage
     * 現在のページが最初のページまたは最後のページであるかどうかを判断し、isFirstPageとisLastPageの値を設定します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    setBoolValueIfFirstOrLastPage() {
        if (this.currentPage === 1 || this.totalPages === 0) {
            this.isFirstPage = true;
        } else {
            this.isFirstPage = false;
        }
        if (this.currentPage === this.totalPages || this.totalPages === 0) {
            this.isLastPage = true;
        } else {
            this.isLastPage = false;
        }
    }

    /**
     * setCurrentPageStudentsList
     * 現在のページの学生リストを設定します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    setCurrentPageStudentsList() {
        const startIndex = (this.currentPage - 1) * this.recordsPerPage;
        const endIndex = startIndex + this.recordsPerPage;
        this.currentPageStudentsList = this.studentsSearchResultList.slice(startIndex, endIndex);
    }

    /**
     * updatePageNums
     * ページ番号のリストを更新します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    updatePageNums() {
        let pageNums = [];
        if (this.totalPages <= 5) {
            for (let i = 1; i <= this.totalPages; i++) {
                pageNums.push({ value: i , variant: i === this.currentPage ? 'brand' : 'neutral' });
            }
            this.pageNums = pageNums;
            return;
        }

        let startPage;
        if (this.currentPage <= 3) {
            startPage = 1;
        } else if (this.currentPage >= this.totalPages - 2) {
            startPage = this.totalPages - 4;
        } else {
            startPage = this.currentPage - 2;
        }

        for (let i = startPage; i < startPage + 5 && i <= this.totalPages; i++) {
            pageNums.push({ value: i , variant: i === this.currentPage ? 'brand' : 'neutral' });
        }

        this.pageNums = pageNums;
    }

    /**
     * handlePageChange
     * ページ番号が変更されたときに、現在のページを更新し、表示する学生リストを更新します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handlePageChange(event) {
        const selectedPage = parseInt(event.target.value);

        if (selectedPage === this.currentPage) {
            return;
        }
        this.currentPage = selectedPage;
        this.setBoolValueIfFirstOrLastPage();
        this.setCurrentPageStudentsList();
        this.updatePageNums();
    }

    /**
     * handleFirstPage
     * 最初のページに移動します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handleFirstPage() {
        if (this.currentPage === 1) {
            return;
        }
        this.currentPage = 1;
        this.setBoolValueIfFirstOrLastPage();
        this.setCurrentPageStudentsList();
        this.updatePageNums();
    }

    /**
     * handleLastPage
     * 最後のページに移動します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handleLastPage() {
        if (this.currentPage === this.totalPages) {
            return;
        }
        this.currentPage = this.totalPages;
        this.setBoolValueIfFirstOrLastPage();
        this.setCurrentPageStudentsList();
        this.updatePageNums();
    }

    /**
     * handlePreviousPage
     * 前のページに移動します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handlePreviousPage() {
        if (this.currentPage === 1) {
            return;
        }
        if (this.currentPage>1){
            this.currentPage--;
        }
        this.setBoolValueIfFirstOrLastPage();
        this.setCurrentPageStudentsList();
        this.updatePageNums();
    }

    /**
     * handleNextPage
     * 次のページに移動します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handleNextPage() {
        if (this.currentPage === this.totalPages) {
            return;
        }
        if (this.currentPage<this.totalPages){
            this.currentPage++;
        }
        this.setBoolValueIfFirstOrLastPage();
        this.setCurrentPageStudentsList();
        this.updatePageNums();
    }

    /**
     * openDetailStudentModal
     * 学生詳細モーダルを開きます。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async openDetailStudentModal(event) {
        try {
            let detailModal = this.template.querySelector('c-lwc_-detail-student');
            let studentId = event.currentTarget.dataset.id;
            if (!studentId) {
                studentId = event.target.value;
            }
            if (detailModal) {
                await detailModal.openModal(studentId);
            }
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生詳細モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * openUpdateStudentModal
     * 学生更新モーダルを開きます。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async openUpdateStudentModal(event) {
        try {
            let updateModal = this.template.querySelector('c-lwc_-update-student');
            if (updateModal) {
                await updateModal.openModal(event.target.value);
            }
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生更新モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * handleSelectedStudent
     * 学生の選択状態を処理します。選択された学生のIDをリストに追加または削除し、選択された学生の数を更新します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handleSelectedStudent(event) {
        const studentId = event.target.name;
        const isSelected = event.target.checked;
        const student = this.studentsSearchResultList.find(s => s.Id === studentId);
        if (student) {
            student.isSelected = isSelected;
            if (isSelected) {
                this.selectedStudentsIdList.push(studentId);
            } else {
                this.selectedStudentsIdList = this.selectedStudentsIdList.filter(id => id !== studentId);
            }
            this.selectedStudentsCount = this.selectedStudentsIdList.length;

            this.allStudentsSelected = this.selectedStudentsCount === this.studentsSearchResultList.length;
        }
        publish(this.messageContext, SearchResultChannel, { action: this.MESSAGE_CHANNEL_ACTION.UPDATE_SELECTED_STUDENTS, value: this.selectedStudentsIdList });
    }
    
    /**
     * handleSelectAllStudents
     * 全ての学生の選択状態を処理します。全ての学生を選択または選択解除し、選択された学生のIDリストと選択された学生の数を更新します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    handleSelectAllStudents(event) {
        const isSelected = event.target.checked;
        this.studentsSearchResultList.forEach(student => {
            student.isSelected = isSelected;
        });
        if (isSelected) {
            this.selectedStudentsIdList = this.studentsSearchResultList.map(student => student.Id);
        } else {
            this.selectedStudentsIdList = [];
        }
        this.selectedStudentsCount = this.selectedStudentsIdList.length;
        this.allStudentsSelected = isSelected;
        publish(this.messageContext, SearchResultChannel, { action: this.MESSAGE_CHANNEL_ACTION.UPDATE_SELECTED_STUDENTS, value: this.selectedStudentsIdList });
    }
    
    /**
     * openDeleteStudentConfirmationModal
     * 学生削除確認モーダルを開きます。特定の学生を削除する場合は、その学生のIDを選択リストに追加します。選択された学生を削除する場合は、選択リストが空でないことを確認します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    openDeleteStudentConfirmationModal(event) {
        const studentId = event.target.value;
        if (!studentId) {
            this.showToast('Error', '削除する学生が選択されていません。', 'error');
            this.openDeleteModal = false;
            return;
        }
        this.deleteStudentIdList = [studentId];
        this.openDeleteModal = true;
    }


    
    /**
     * confirmDeleteStudent
     * 選択された学生を削除し、学生リストを更新します。削除が成功した場合は、トーストメッセージを表示します。削除が失敗した場合は、エラーメッセージを表示します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async confirmDeleteStudent() {
        try {
            this.openDeleteModal = false;
            this.spinner = true;
            await deleteListStudents({ studentIds: this.deleteStudentIdList });
            await this.handleSearch();
            this.showToast('Success', '学生が正常に削除されました。', 'success');
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生の削除に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * closeDeleteModal
     * 学生削除モーダルを閉じます。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */ 
    closeDeleteModal() {
        this.openDeleteModal = false;
    }

    /**
     * handleStudentCreated
     * 学生作成後に呼び出され、選択状態を初期化します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async handleStudentCreated() {
        try {
            await this.handleSearch();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生の作成後の処理に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * handleStudentUpdated
     * 学生更新後に呼び出され、選択状態を保持しつつ、学生リストを更新します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    handleStudentUpdated(event) {
        try {
            const newStudent = event.detail.newStudent;
            this.studentsSearchResultList = this.updateStudentList(this.studentsSearchResultList, newStudent);
            this.selectedStudentsIdList = this.studentsSearchResultList.filter(s => s.isSelected).map(s => s.Id);
            this.selectedStudentsCount = this.selectedStudentsIdList.length;
            this.caculateTotalPagesAndTotalRecords();
            this.setCurrentPage();
            this.setBoolValueIfFirstOrLastPage();
            this.setCurrentPageStudentsList();
            this.updatePageNums();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生の更新後の処理に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * updateStudentList
     * 学生リストを更新し、選択状態を保持します。
     * @param studentsSearchResultList 学生リスト, newStudent 更新された学生
     * @return  更新された学生リスト
     * @created 2026/06/23 Nguyen Ngoc Quy
     */ 
    updateStudentList(studentsSearchResultList, newStudent) {
        return studentsSearchResultList.map(student => {
            if (student.Id === newStudent.Id) {
                return { ...newStudent, isSelected: student.isSelected, Class: newStudent.Class_look__r ? newStudent.Class_look__r.Name : '' };
            }
            return student;
        });
    }

    /**
     * setCurrentPage
     * 現在のページを設定します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     */
    setCurrentPage(){
        this.currentPage = this.currentPage > this.totalPages ? this.totalPages : this.currentPage;
        if (this.currentPage === 0) {
            this.currentPage = 1;
        }
    }

    /**
     * handleClearSearch
     * 検索条件をクリアし、学生リストを初期状態に戻します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async handleClearSearch(){
        try {
            this.resetSearchKey();
            this.spinner = true;
            this.studentsList =  await fetchStudentsList({ maxRecords: this.maxRecord });
            for (let s of this.studentsList) {
                s.isSelected = this.selectedStudentsIdList.includes(s.Id);
                s.Class = s.Class_look__r? s.Class_look__r.Name : '';
            }
            this.studentsSearchResultList = this.studentsList;
            this.currentPage = 1;

            this.caculateTotalPagesAndTotalRecords();
            this.setBoolValueIfFirstOrLastPage();
            this.setCurrentPageStudentsList();
            this.updatePageNums();
            
            this.allStudentsSelected = this.selectedStudentsIdList.length === this.studentsSearchResultList.length;
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '検索条件のクリアに失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * handleSearch
     * 検索を実行し、検索結果を表示します。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async handleSearch() {
        try {
            this.spinner = true;
            const list = await searchStudents({
                studentCodeSearch: this.searchKey.studentCode,
                studentNameSearch: this.searchKey.studentName,
                classSearch: this.searchKey.class,
                genderSearch: this.searchKey.gender,
                birthdaySearch: this.searchKey.birthday ? new Date(this.searchKey.birthday) : null,
                dayOfBirthSearch: this.searchKey.dayOfBirth,
                monthOfBirthSearch: this.searchKey.monthOfBirth,
                yearOfBirthSearch: this.searchKey.yearOfBirth,
                maxRecords: this.maxRecord
            });
            if (list.length === 0) {
                this.showToast('Warning', '検索条件に一致する学生が見つかりませんでした。', 'warning');
            }
            for (let s of list) {
                s.isSelected = this.selectedStudentsIdList.includes(s.Id);
                s.Class = s.Class_look__r? s.Class_look__r.Name : '';
            }
            this.selectedStudentsIdList = list.filter(s => s.isSelected).map(s => s.Id);
            this.selectedStudentsCount = this.selectedStudentsIdList.length;
            this.studentsSearchResultList = list;
            this.caculateTotalPagesAndTotalRecords();
            this.setCurrentPage();
            this.setBoolValueIfFirstOrLastPage();
            this.setCurrentPageStudentsList();
            this.updatePageNums();
            
            this.allStudentsSelected = this.selectedStudentsIdList.length === this.studentsSearchResultList.length;
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '検索に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * openCreateStudentModal
     * 学生作成モーダルを開きます。
     * @param なし
     * @return なし
     * @created 2026/06/29 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async openCreateStudentModal() {
        try {
            let createModal = this.template.querySelector('c-lwc_-create-student');
            if (createModal) {
                await createModal.openModal();
            }
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : '学生作成モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
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