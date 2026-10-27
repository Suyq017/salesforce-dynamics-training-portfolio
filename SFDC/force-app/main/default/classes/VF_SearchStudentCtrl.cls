/**
* クラス名   ：VF_SearchStudentCtrl
* クラス概要 ：学生を検索する
* @created  ：2026/06/05 Nguyen Ngoc Quy
* @modified ：2026/07/20 Nguyen Ngoc Quy
*/
public with sharing class VF_SearchStudentCtrl {

    // 2026/07/21 Nguyen Ngoc Quy Add Start
    @TestVisible
    private Boolean throwException = false;
    // 2026/07/21 Nguyen Ngoc Quy Add End

    public class SearchKey {
        public string studentCode { get; set; }
        public string studentName { get; set; }
        public string studentClass { get; set; }
        public string studentGender { get; set; }
        public Date studentBirthday { get; set; }
        public string dayOfBirth { get; set; }
        public string monthOfBirth { get; set; }
        public string yearOfBirth { get; set; }
        public Boolean isEmpty() {
            return String.isBlank(studentCode) 
                && String.isBlank(studentName) 
                && String.isBlank(studentClass) 
                && String.isBlank(studentGender) 
                && studentBirthday == null 
                && String.isBlank(dayOfBirth) 
                && String.isBlank(monthOfBirth) 
                && String.isBlank(yearOfBirth);
        }
    }

    public class StudentWrapper {
        public Student__c student { get; set; }
        public Boolean isSelected { get; set; }

        public StudentWrapper(Student__c student) {
            this.student = student;
            this.isSelected = false;
        }
    }

    public List<StudentWrapper> studentsPaginated { get; set; }
    public List<student__c> students { get; set; }
    public List<StudentWrapper> studentsWrapper { get; set; }
    public SearchKey searchKey { get; set; }
    public String studentId { get; set; }
    public List<Integer> pageNumbers { get; set; }
    public Integer totalPages { get; set; }
    public Integer totalRecords { get; set; }
    public Integer currentPage { get; set; }
    public List<SelectOption> classOptions { get; set; }
    public List<SelectOption> genderOptions { get; set; }
    public List<SelectOption> dateOptions { get; set; }
    public List<SelectOption> monthOptions { get; set; }
    public List<SelectOption> yearOptions { get; set; }
    public Boolean showDeleteConfirm { get; set; }  
    public Boolean selectAll { get; set; }

    private StudentManageSetting__c setting { get; set; }
    private Integer maxRecords { get; set; }
    private Integer pageSize { get; set; }
    private List<Student__c> searchedStudents { get; set; }
    private Set<String> selectedIds { get; set; }
    // 2026/07/20 Nguyen Ngoc Quy Modify Start
    // private Boolean multiDelete { get; set; 
    @TestVisible
    private Boolean multiDelete { get; set; }
    // 2026/07/20 Nguyen Ngoc Quy Modify End
    
    private static final Integer DEFAULT_PAGE_SIZE = 5;
    private static final Integer DEFAULT_MAX_RECORDS = 2000;

    public VF_SearchStudentCtrl() {
        searchedStudents = new List<Student__c>();
        studentsPaginated = new List<StudentWrapper>();
        studentsWrapper = new List<StudentWrapper>();
        students = new List<Student__c>();
        pageNumbers = new List<Integer>();
        selectedIds = new Set<String>();
        searchKey = new SearchKey();
        setting = StudentManageSetting__c.getInstance();
        getRecordPerPage();
        getMaxRecords();
        currentPage = 1;
        getTotalPageNumberAndRecord();
        getPageNumbers();
        getStudentsPaginated(currentPage);
        classOptions = getClassOptions();
        genderOptions = getGenderOptions();
        dateOptions = getDatePickerOptions('day');
        monthOptions = getDatePickerOptions('month');
        yearOptions = getDatePickerOptions('year');
        selectAll = false;
        multiDelete = false;
    }

	/**
    * getTotalPageNumber
    * 学生の総ページ数を計算する
    * @param：なし  
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/06/08 Nguyen Ngoc Quy
    */
    private void getTotalPageNumberAndRecord() {
        if (searchedStudents.isEmpty() && searchKey.isEmpty()) {
            totalRecords = [SELECT COUNT() FROM Student__c LIMIT :maxRecords];
        } else {
            totalRecords = searchedStudents.size();
        }
        totalPages = (totalRecords + pageSize - 1) / pageSize;
        if (totalPages == 0) totalPages = 1;
    }

    /**
    * getPageNumbers
    * ページ番号のリストを生成する
    * @param：なし  
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/06/08 Nguyen Ngoc Quy
    */
    private void getPageNumbers() {
        pageNumbers = new List<Integer>();

        if (totalPages <= 5) {
            for (Integer i = 1; i <= totalPages; i++) {
                pageNumbers.add(i);
            }
            return;
        }

        Integer startPage;
        if (currentPage <= 3) {
            startPage = 1;
        } else if (currentPage >= totalPages - 2) {
            startPage = totalPages - 4;
        } else {
            startPage = currentPage - 2;
        }

        for (Integer i = startPage; i < startPage + 5; i++) {
            pageNumbers.add(i);
        }
    }

    /**
    * saveSelectedIds
    * 現在のページで選択されている学生のIDを保存する
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/06/10 Nguyen Ngoc Quy
    */
    private void saveSelectedIds() {
        for (StudentWrapper w : studentsPaginated) {
            if (w.isSelected) {
                selectedIds.add(w.student.Id);
            } else {
                selectedIds.remove(w.student.Id);
            }
        }
    }

    /**
    * getStudentsPaginated
    * 学生をページネーションで取得する
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    private void getStudentsPaginated(Integer pageNumber) {
        // 2026/07/21 Nguyen Ngoc Quy Modify Start
        // try {            
        //     studentsPaginated = new List<StudentWrapper>();
        //     queryAllStudents();
            
        //     Integer offset = (pageNumber - 1) * pageSize;
        //     List<Student__c> pageRecords = new List<Student__c>();

        //     //Search Case
        //     if (!searchKey.isEmpty()) {
        //         for (Integer i = offset; i < Math.min(offset + pageSize, searchedStudents.size()); i++) {
        //             pageRecords.add(searchedStudents[i]);
        //         }
        //     } else { //Normal Case
        //         for(Integer i = offset; i < offset + pageSize; i++) {
        //             if (i >= students.size()) break;
        //             pageRecords.add(students[i]);
        //         }
        //     }

        //     for (Student__c s : pageRecords) {
        //         StudentWrapper w = new StudentWrapper(s);
        //         w.isSelected = selectedIds.contains(s.Id);
        //         studentsPaginated.add(w);
        //     }
        // } catch (Exception e) {
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        // }         
        studentsPaginated = new List<StudentWrapper>();
        queryAllStudents();
        
        Integer offset = (pageNumber - 1) * pageSize;
        List<Student__c> pageRecords = new List<Student__c>();

        //Search Case
        if (!searchKey.isEmpty()) {
            for (Integer i = offset; i < Math.min(offset + pageSize, searchedStudents.size()); i++) {
                pageRecords.add(searchedStudents[i]);
            }
        } else { //Normal Case
            for(Integer i = offset; i < offset + pageSize; i++) {
                if (i >= students.size()) break;
                pageRecords.add(students[i]);
            }
        }

        for (Student__c s : pageRecords) {
            StudentWrapper w = new StudentWrapper(s);
            w.isSelected = selectedIds.contains(s.Id);
            studentsPaginated.add(w);
        }
        // 2026/07/21 Nguyen Ngoc Quy Modify end
    }

    /**
    * queryAllStudents
    * 学生を全件取得する（検索条件なし）
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    private void queryAllStudents() {
        // 2026/07/21 Nguyen Ngoc Quy Modify Start
        // try {
        //     students = [SELECT Id, StudentCode__c, LastName__c, FirstName__c, Birthday__c, Gender__c, Class_look__r.Name 
        //     FROM Student__c 
        //     ORDER BY StudentCode__c ASC LIMIT :maxRecords];
        //     if (students.size() == maxRecords) {
        //         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '最大レコード数に達しました。検索条件を追加して結果を絞り込んでください。'));
        //     }
        // } catch (Exception e) {
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        // }
        students = [
            SELECT Id
            , StudentCode__c
            , LastName__c
            , FirstName__c
            , Birthday__c
            , Gender__c
            , Class_look__r.Name 
            FROM Student__c 
            ORDER BY StudentCode__c ASC 
            LIMIT :maxRecords
        ];
        if (students.size() == maxRecords) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '最大レコード数に達しました。検索条件を追加して結果を絞り込んでください。'));
        }
        // 2026/07/21 Nguyen Ngoc Quy Modify End
    }
    /**
    * goToPage
    * ページ番号に基づいて学生を取得する
    * @param：なし  
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void goToPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End
            
            saveSelectedIds();
            getStudentsPaginated(currentPage);
            getPageNumbers();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * goToFirstPage
    * 最初のページに移動する
    * @param：なし  
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void goToFirstPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            saveSelectedIds();
            currentPage = 1;
            getStudentsPaginated(currentPage);
            getPageNumbers();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * goToLastPage
    * 最後のページに移動する
    * @param：なし  
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void goToLastPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            saveSelectedIds();
            currentPage = totalPages;
            getStudentsPaginated(currentPage);
            getPageNumbers();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * goToPreviousPage
    * 前のページに移動する
    * @param：なし  
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void goToPreviousPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            saveSelectedIds();
            if (currentPage > 1) {
                currentPage--;
                getStudentsPaginated(currentPage);
                getPageNumbers();
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
     * goToNextPage
     * 次のページに移動する
     * @param：なし
     * @return：なし
     * @created：2026/06/05 Nguyen Ngoc Quy
     * @modified：2026/07/21 Nguyen Ngoc Quy
     */
    public void goToNextPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            saveSelectedIds();
            if (currentPage < totalPages) {
                currentPage++;
                getStudentsPaginated(currentPage);
                getPageNumbers();
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * getSelectedCount
    * 概要：選択されている学生の数を取得する
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public Integer getSelectedCount() {
        // 2026/07/21 Nguyen Ngoc Quy Modify Start
        // saveSelectedIds();
        // return selectedIds.size();
        try {
            throwExceptionForTesting();

            saveSelectedIds();
            return selectedIds.size();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
            return 0;
        }
        // 2026/07/21 Nguyen Ngoc Quy Modify End
    }

    /**
    * searchStudents
    * フォームから学生を検索する
    * @param：なし
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void searchStudents() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            String query =
            'SELECT Id, StudentCode__c, LastName__c, FirstName__c, Birthday__c, Gender__c, Class_look__r.Name ' +
            'FROM Student__c WHERE Id != null';
            if (String.isNotBlank(searchKey.studentCode)) {
                query += ' AND StudentCode__c LIKE \'%' + String.escapeSingleQuotes(searchKey.studentCode) + '%\'';
            }
            if (String.isNotBlank(searchKey.studentName)) {
                query += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(searchKey.studentName) + '%\' OR FirstName__c LIKE \'%' + String.escapeSingleQuotes(searchKey.studentName) + '%\')';
            }
            if (String.isNotBlank(searchKey.studentClass)) {
                query += ' AND Class_look__c = \'' + String.escapeSingleQuotes(searchKey.studentClass) + '\'';
            }
            if (String.isNotBlank(searchKey.studentGender)) {
                query += ' AND Gender__c = \'' + String.escapeSingleQuotes(searchKey.studentGender) + '\'';
            }
            if (searchKey.studentBirthday != null) {
                query += ' AND Birthday__c = ' + String.valueOf(searchKey.studentBirthday);
            }
            if (String.isNotBlank(searchKey.dayOfBirth)) {
                query += ' AND DAY_IN_MONTH(Birthday__c) = ' + String.escapeSingleQuotes(searchKey.dayOfBirth);
            }
            if (String.isNotBlank(searchKey.monthOfBirth)) {
                query += ' AND CALENDAR_MONTH(Birthday__c) = ' + String.escapeSingleQuotes(searchKey.monthOfBirth);
            }
            if (String.isNotBlank(searchKey.yearOfBirth)) {
                query += ' AND CALENDAR_YEAR(Birthday__c) = ' + String.escapeSingleQuotes(searchKey.yearOfBirth);
            }
            query += ' ORDER BY StudentCode__c ASC LIMIT ' + maxRecords;
            searchedStudents = Database.query(query);
            selectedIds.clear();
            currentPage = 1;
            getTotalPageNumberAndRecord();
            getPageNumbers();
            getStudentsPaginated(currentPage);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * openCreateStudentPage
    * 学生登録ページのポップアップを開きます。
    * @param：なし
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public PageReference openCreateStudentPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            PageReference pageRef = Page.VF_CreateStudent;
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
            return null;
        }
    }

    /**
    * openEditStudentPage
    * 学生編集ページのポップアップを開きます。
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public PageReference openEditStudentPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            if (String.isNotBlank(studentId)) {
                PageReference pageRef = Page.VF_UpdateStudent;
                pageRef.getParameters().put('Id', studentId);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '学生が選択されていません。'));
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
            return null;
        }
    }

    /**
    * openStudentDetailPage
    * 学生詳細ページのポップアップを開きます。
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public PageReference openStudentDetailPage() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            if (String.isNotBlank(studentId)) {
                PageReference pageRef = Page.VF_DetailStudent;
                pageRef.getParameters().put('Id', studentId);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '学生が選択されていません。'));
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
            return null;
        }
    }

    /**
    * clearSearch
    * 検索条件をクリアする
    * @param：なし
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void clearSearch() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            searchKey = new SearchKey();
            searchedStudents = new List<Student__c>();
            selectedIds.clear();
            currentPage = 1;
            getTotalPageNumberAndRecord();
            getPageNumbers();
            getStudentsPaginated(currentPage);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * deleteStudents
    * 学生を削除する
    * @param：なし
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void deleteStudents() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End
            
            saveSelectedIds();
            if (selectedIds.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '学生が選択されていません。'));
                return;
            }
            List<Student__c> toDelete = [SELECT Id FROM Student__c WHERE Id IN :selectedIds];
            Integer count = toDelete.size();
            Integer tempCurrentPage = currentPage;
            delete toDelete;
            selectedIds.clear();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count + '件の学生が正常に削除されました。'));
            searchStudents();
            gettotalPageNumberAndRecord();
            currentPage = tempCurrentPage;
            if (currentPage > totalPages) {
                gotoLastPage();
            } else {
                currentPage = tempCurrentPage;
            }
            getPageNumbers();
            getStudentsPaginated(currentPage);
            closeDeleteConfirm();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * deleteStudent
    * 学生を削除する
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void deleteStudent() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End
            
            if (multiDelete) {
                deleteStudents();
                multiDelete = false;
                return;
            }
            if (String.isNotBlank(studentId)) {
                List<Student__c> studentToDelete = [SELECT Id FROM Student__c WHERE Id = :studentId LIMIT 1];
                if (!studentToDelete.isEmpty()) {
                    Integer tempCurrentPage = currentPage;
                    delete studentToDelete[0];
                    selectedIds.remove(studentId);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '学生が正常に削除されました。'));
                    searchStudents();
                    getTotalPageNumberAndRecord();
                    currentPage = tempCurrentPage;
                    if (currentPage > totalPages) {
                        goToLastPage();
                    } else {                        
                        currentPage = tempCurrentPage;
                    }
                    getPageNumbers();
                    getStudentsPaginated(currentPage);
                    closeDeleteConfirm();
                }
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '学生が選択されていません。'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * getMaxRecords
    * 学生の最大レコード数を取得する
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/06/08 Nguyen Ngoc Quy
    */
    private void getMaxRecords() {
        if (setting != null && setting.S_MaxRecord__c != null && setting.S_MaxRecord__c > 0) {
            maxRecords = Integer.valueOf(setting.S_MaxRecord__c);
        } else {
            maxRecords = DEFAULT_MAX_RECORDS;
        }
    }

    /**
    * getRecordPerPage
    * 学生のページあたりのレコード数を取得る
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/06/08 Nguyen Ngoc Quy
    */
    private void getRecordPerPage() {
        if (setting != null && setting.S_RecordPerPage__c != null && setting.S_RecordPerPage__c > 0) {
            pageSize = Integer.valueOf(setting.S_RecordPerPage__c);
        } else {
            pageSize = DEFAULT_PAGE_SIZE;
        }
    }

    /**
    * getDatePickerOptions
    * 日付ピッカーの選択肢を生成する
    * @param：type - 'day', 'month', 'year' のいずれかを指定して、日、月、年の選択肢を生成する
    * @return：オプションのリスト
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/06/11 Nguyen Ngoc Quy
    */
    private List<SelectOption> getDatePickerOptions(string type){
        List<SelectOption> options = new List<SelectOption>();
        if(type == 'day'){
            for (Integer i = 1; i <= 31; i++) {
                String value = String.valueOf(i).leftPad(2, '0');
                options.add(new SelectOption(value, value));
            }
        } else if(type == 'month'){
            for (Integer i = 1; i <= 12; i++) {
                String value = String.valueOf(i).leftPad(2, '0');
                options.add(new SelectOption(value, value));
            }
        } else if(type == 'year'){
            Integer currentYear = Date.today().year();
            for (Integer i = currentYear; i >= 1900; i--) {
                options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }
        return options;
    }

    /**
    * getClassOptions
    * クラスの選択肢を生成する
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/06/11 Nguyen Ngoc Quy
    */
    private List<SelectOption> getClassOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Class__c cls : [SELECT Id, Name FROM Class__c ORDER BY Name]) {
            options.add(new SelectOption(cls.Id, cls.Name));
        }
        return options;
    }

    /**
    * getGenderOptions
    * 性別の選択肢を生成する
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/06/11 Nguyen Ngoc Quy
    */
    private List<SelectOption> getGenderOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Student__c.Gender__c.getDescribe();
        for(Schema.PicklistEntry entry : fieldResult.getPicklistValues()){
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }

    /**
    * openDeleteConfirm
    * 削除確認のポップアップを開く
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void openDeleteConfirm() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            showDeleteConfirm = true;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * openDeleteMultipleConfirm
    * 削除確認のポップアップを開く
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void openDeleteMultipleConfirm() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            if (getSelectedCount() > 0) {
                showDeleteConfirm = true;
                multiDelete = true;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '学生が選択されていません。'));
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * closeDeleteConfirm
    * 削除確認のポップアップを閉じる
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void closeDeleteConfirm() {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            multiDelete = false;
            showDeleteConfirm = false;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
    }

    /**
    * toggleSelectAll
    * 全選択/全解除の切り替えを行う
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/07/21 Nguyen Ngoc Quy
    */
    public void toggleSelectAll(){
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            Boolean newValue = selectAll;
            if (!searchKey.isEmpty()){
                for(student__c s : searchedStudents){
                    StudentWrapper w = new StudentWrapper(s);
                    w.isSelected = newValue;
                    if(newValue){
                        selectedIds.add(w.student.Id);
                    } else {
                        selectedIds.remove(w.student.Id);
                    }
                }
            } else {
                for(student__c s : students){
                    StudentWrapper w = new StudentWrapper(s);
                    w.isSelected = newValue;
                    if(newValue){
                        selectedIds.add(w.student.Id);
                    } else {
                        selectedIds.remove(w.student.Id);
                    }
                }
            }
            for (StudentWrapper w : studentsPaginated){
                w.isSelected = newValue;
                if (newValue){
                    selectedIds.add(w.student.Id);
                } else {
                    selectedIds.remove(w.student.Id);
                }
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
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
    private void throwExceptionForTesting() {
        if (throwException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * クラス名  ：CustomException
    * クラス概要：テスト用のカスタム例外クラス
    * @created ：2026/07/21 Nguyen Ngoc Quy
    * @modified：
    */
    class CustomException extends Exception {}
    // 2026/07/21 Nguyen Ngoc Quy Add End
}