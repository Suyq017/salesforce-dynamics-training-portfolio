/*
 * lwc_SearchStudent.js
 * 学生検索コンポーネントのJavaScriptコードです。
 * @created 2026/06/22 Nguyen Ngoc Quy
 * @modified 2026/07/13 Nguyen Ngoc Quy
**/
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchStudentsList from '@salesforce/apex/LWC_SearchStudentCtrl.fetchStudentsList';
import searchStudents from '@salesforce/apex/LWC_SearchStudentCtrl.searchStudents';
import deleteListStudents from '@salesforce/apex/LWC_SearchStudentCtrl.deleteListStudents';
import getInitData from '@salesforce/apex/LWC_SearchStudentCtrl.getInitData';
export default class Lwc_SearchStudent extends LightningElement {

    // 2026/07/13 Nguyen Ngoc Quy Add Start
    UNKNOWN_ERROR_MESSAGE = 'データの取得に失敗しました。';
    // 2026/07/13 Nguyen Ngoc Quy Add End


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

    studentsList = [];
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

    isNotAnySelectedStudent = true;
    isSearched = false;
    disableClearSearchButton = true;
    allStudentsSelected = false;

    spinner = false;
    openDeleteModal = false;

    /**
     * connectedCallback
     * 初期データ初期化関数。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     */
    async connectedCallback() {
        await this.initializeFunction();
    }

    /**
     * initializeFunction
     * 初期化関数。性別、クラス、日付のオプションを取得し、学生リストを取得します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */
    async initializeFunction(){
        try {
            this.spinner = true;
            const data = await getInitData();
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
        finally {
            this.spinner = false;
        }
    }

    /**
     * getDayMonthYearOptions
     * 日、月、年のオプションを生成します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * handleSearchKeyChange
     * 検索キーの変更を処理します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
     */    
    handleDateChange() {
        if ((this.searchKey.dayOfBirth 
            || this.searchKey.monthOfBirth 
            || this.searchKey.yearOfBirth) && this.searchKey.birthday) {
            this.searchKey.birthday = '';
        }
    }

    /**
     * handleClearSearch
     * 検索条件をクリアし、学生リストを初期状態に戻します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
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
            
            this.isSearched = false;
            
            this.disableClearSearchButton = true;
            this.allStudentsSelected = this.selectedStudentsIdList.length === this.studentsSearchResultList.length;

        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'データの取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * updatePageNums
     * ページ番号のリストを更新します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * @created 2026/06/22 Nguyen Ngoc Quy
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
     * handleSearch
     * 検索を実行し、検索結果を表示します。
     * @param なし
     * @return なし
     * @created 2026/06/22 Nguyen Ngoc Quy
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
            this.isSearched = true;
            this.allStudentsSelected = this.selectedStudentsIdList.length === this.studentsSearchResultList.length;
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'データの取得に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
        finally {
            this.spinner = false;
        }
    }

    /**
     * openDetailStudentModal
     * 学生詳細モーダルを開きます。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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
            // this.showToast('Error', error.body ? error.body.message : 'モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * openCreateStudentModal
     * 学生作成モーダルを開きます。
     * @param なし
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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
            // this.showToast('Error', error.body ? error.body.message : 'モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * openUpdateStudentModal
     * 学生更新モーダルを開きます。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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
            // this.showToast('Error', error.body ? error.body.message : 'モーダルの表示に失敗しました。', 'error');
            this.showToast('Error', error.body ? error.body.message : this.UNKNOWN_ERROR_MESSAGE, 'error');
            // 2026/07/13 Nguyen Ngoc Quy Modified End
        }
    }

    /**
     * handleSelectedStudent
     * 学生の選択状態を処理します。選択された学生のIDをリストに追加または削除し、選択された学生の数を更新します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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

            this.isNotAnySelectedStudent = this.selectedStudentsCount === 0;
            this.allStudentsSelected = this.selectedStudentsCount === this.studentsSearchResultList.length;
        }
    }

    /**
     * handleSelectAllStudents
     * 全ての学生の選択状態を処理します。全ての学生を選択または選択解除し、選択された学生のIDリストと選択された学生の数を更新します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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
            this.isNotAnySelectedStudent = this.selectedStudentsCount === 0;
            this.allStudentsSelected = isSelected;
    }

    /**
     * openDeleteStudentConfirmationModal
     * 学生削除確認モーダルを開きます。特定の学生を削除する場合は、その学生のIDを選択リストに追加します。選択された学生を削除する場合は、選択リストが空でないことを確認します。
     * @param event イベントオブジェクト
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
     */ 
    openDeleteStudentConfirmationModal(event) {
        this.openDeleteModal = true;
        let type = event.target.dataset.id
        if (type === 'deleteSpecificIdStudent') {
            const studentId = event.target.value;
            if (!studentId) {
                this.showToast('Error', '削除する学生が選択されていません。', 'error');
                this.openDeleteModal = false;
                return;
            }
            this.deleteStudentIdList = [studentId];
        } else if (type === 'deleteListSelectedStudents') {
            if (this.selectedStudentsIdList.length === 0) {
                this.showToast('Error', '削除する学生が選択されていません。', 'error');
                this.openDeleteModal = false;
                return;
            }
            this.deleteStudentIdList = [...this.selectedStudentsIdList];
        }
    }

    /**
     * confirmDeleteStudent
     * 選択された学生を削除し、学生リストを更新します。削除が成功した場合は、トーストメッセージを表示します。削除が失敗した場合は、エラーメッセージを表示します。
     * @param なし
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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
            // this.showToast('Error', error.body ? error.body.message : 'データの取得に失敗しました。', 'error');
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
     * @created 2026/06/23 Nguyen Ngoc Quy
     */ 
    closeDeleteModal() {
        this.openDeleteModal = false;
    }

    /**
     * handleStudentCreated
     * 学生作成後に呼び出され、選択状態を初期化します。
     * @param なし
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
     * @modified 2026/07/13 Nguyen Ngoc Quy
     */ 
    async handleStudentCreated() {
        try {
            await this.handleSearch();
        }
        catch (error) {
            // 2026/07/13 Nguyen Ngoc Quy Modified Start
            // this.showToast('Error', error.body ? error.body.message : 'データの取得に失敗しました。', 'error');
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
            // this.showToast('Error', error.body ? error.body.message : 'データの取得に失敗しました。', 'error');
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
                return { ...newStudent, isSelected: student.isSelected
                    , Class: newStudent.Class_look__r ? newStudent.Class_look__r.Name : '' };
            }
            return student;
        });
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
     * caculateTotalPagesAndTotalRecords
     * 学生リストの総ページ数と総レコード数を計算します。
     * @param なし
     * @return なし
     * @created 2026/06/23 Nguyen Ngoc Quy
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
     * @created 2026/06/23 Nguyen Ngoc Quy
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
     * @created 2026/06/23 Nguyen Ngoc Quy
     */
    setCurrentPageStudentsList() {
        const startIndex = (this.currentPage - 1) * this.recordsPerPage;
        const endIndex = startIndex + this.recordsPerPage;
        this.currentPageStudentsList = this.studentsSearchResultList.slice(startIndex, endIndex);
    }

    /**
     * setCurrentPage
     * 現在のページを設定します。
     * @param なし
     * @return なし
     * @created 2026/06/26 Nguyen Ngoc Quy
     */
    setCurrentPage(){
        this.currentPage = this.currentPage > this.totalPages ? this.totalPages : this.currentPage;
        if (this.currentPage === 0) {
            this.currentPage = 1;
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