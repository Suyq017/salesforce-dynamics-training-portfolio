({
    /**
     * 関数名：fetchStudents
     * @param なし
     * @return 学生のリストをページ分けして返します。
     */
    fetchStudents : function(component) {
        var fetchStudentsAction = component.get("c.fetchStudents");
        fetchStudentsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var studentsList = response.getReturnValue();
                if (studentsList) {
                    for (var i = 0; i < studentsList.length; i++) {
                        var isSelected = false;
                        studentsList[i].isSelected = isSelected;
                    }
                    component.set("v.studentsList", studentsList);
                    component.set("v.currentPageListStudents", studentsList.slice(0, component.get("v.RecordPerPage")));
                }
                component.set("v.currentPage", 1);
                component.set("v.allSelected", false);
                component.set("v.selectedStudentsCount", 0);
                this.setTotalRecordsAndPages(component);
                this.getPageNumbers(component);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        // this.toggleSpinner(component, event);
        });
        $A.enqueueAction(fetchStudentsAction);
    },

    /**
     * 関数名：navigateToDetail
     * @param studentId 学生のID
     * @return 学生の詳細ページに遷移します。
     */
    navigateToDetail : function(component, studentId) {
        var pageReference = {
                type: "standard__component",
                attributes: {
                    "componentName": "c__CMP_DetailStudent"
                },
                state: {
                    "c__studentId": studentId
                }
            };
        component.find("navService").generateUrl(pageReference).then($A.getCallback(function(url) {
            window.open(url, "_blank");
        }), $A.getCallback(function(error) {
            $A.get("e.force:showToast").setParams({
                title: "Error",
                message: error.message,
                type: "error"
            }).fire();
        }));
    },

    /**
     * 関数名：getCustomSettings
     * @param なし
     * @return カスタム設定を返します。
     */
    getCustomSettings : function(component, callback) {
        var action = component.get("c.getCustomSettings");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var settings = [];
                settings = response.getReturnValue();
                if (settings.RecordPerPage != null) {
                    component.set("v.RecordPerPage", settings.RecordPerPage);
                } else {
                    component.set("v.RecordPerPage", 5);
                }
                if (settings.MaxRecord != null) {
                    component.set("v.MaxRecord", settings.MaxRecord);
                } else {
                    component.set("v.MaxRecord", 2000);
                }
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * 関数名：fetchSearchKey
     * @param なし
     * @return 性別とクラスの選択肢を取得して、日付の選択肢を生成します。
     */
    fetchSearchKey : function(component, callback) {
        var getGenderOptionsAction = component.get("c.getGenderOptions");
        getGenderOptionsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var genderOptions = response.getReturnValue();
                var options = [];
                for (var key in genderOptions) {
                    options.push({ label: genderOptions[key], value: key });
                }
                component.set("v.genderOptions", options);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        });
        $A.enqueueAction(getGenderOptionsAction);

        var getClassOptionsAction = component.get("c.getClassOptions");
        getClassOptionsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var classOptions = response.getReturnValue();
                var options = [];
                for (var key in classOptions) {
                    options.push({ label: classOptions[key], value: key });
                }
                component.set("v.classOptions", options);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
            var days = [];
        for (var i = 1; i <= 31; i++) {
            days.push({ label: String(i), value: String(i) });
        }
        component.set("v.dayOptions", days);

        var months = [];
        for (var j = 1; j <= 12; j++) {
            months.push({ label: String(j), value: String(j) });
        }
        component.set("v.monthOptions", months);

        var years = [];
        var currentYear = new Date().getFullYear();
        for (var k = currentYear; k >= currentYear - 100; k--) {
            years.push({ label: String(k), value: String(k) });
        }
        component.set("v.yearOptions", years);
        });
        $A.enqueueAction(getClassOptionsAction);
    },

    /**
     * handleDateChange
     * @param なし
     * @return 日付の検索条件が変更されたときに、誕生日の検索条件をクリアします。
     */
    handleDateChange : function(component, event) {
        var selectedDay = component.get("v.dayOfBirthSearch");
        var selectedMonth = component.get("v.monthOfBirthSearch");
        var selectedYear = component.get("v.yearOfBirthSearch");
        var birthdaySearch = component.get("v.birthdaySearch");
        var days = [];

        if ((selectedDay || selectedMonth || selectedYear) && birthdaySearch) {
            component.set("v.birthdaySearch", null);
        }
        this.handleSearchChange(component, event);
    },

    /**
     * handleBirthdayChange
     * @param なし
     * @return 学生のリストをページ分けして返します。
     */
    handleBirthdayChange : function(component, event) {
        var selectedDay = component.get("v.dayOfBirthSearch");
        var selectedMonth = component.get("v.monthOfBirthSearch");
        var selectedYear = component.get("v.yearOfBirthSearch");
        var birthdaySearch = component.get("v.birthdaySearch");
        if (birthdaySearch && (selectedDay || selectedMonth || selectedYear)) {
            component.set("v.monthOfBirthSearch", null);
            component.set("v.dayOfBirthSearch", null);
            component.set("v.yearOfBirthSearch", null);
        }
        this.handleSearchChange(component, event);
    },

    /**
     * searchStudents
     * @param なし
     * @return 学生のリストをページ分けして返します。
     */
    searchStudents : function(component , event) {
        var params = event.getParams();
        
        var studentCodeSearch = params.studentCodeSearch;
        var studentNameSearch = params.studentNameSearch;
        var classSearch = params.classSearch;
        var genderSearch = params.genderSearch;
        var birthdaySearch = params.birthdaySearch;
        var dayOfBirthSearch = params.dayOfBirthSearch;
        var monthOfBirthSearch = params.monthOfBirthSearch;
        var yearOfBirthSearch = params.yearOfBirthSearch;
        var action = component.get("c.searchStudents");
        action.setParams({
            studentCodeSearch: studentCodeSearch,
            studentNameSearch: studentNameSearch,
            classSearch: classSearch,
            genderSearch: genderSearch,
            birthdaySearch: birthdaySearch,
            dayOfBirthSearch: dayOfBirthSearch,
            monthOfBirthSearch: monthOfBirthSearch,
            yearOfBirthSearch: yearOfBirthSearch
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var studentsList = response.getReturnValue();
                if (studentsList.length > component.get("v.MaxRecord")) {
                    studentsList = studentsList.slice(0, component.get("v.MaxRecord"));
                }
                if (studentsList) {
                    for (var i = 0; i < studentsList.length; i++) {
                        var isSelected = false;
                        studentsList[i].isSelected = isSelected;
                    }
                    component.set("v.studentsList", studentsList);
                    component.set("v.currentPageListStudents", studentsList.slice(0, component.get("v.RecordPerPage")));
                }
                component.set("v.currentPage", 1);
                component.set("v.allSelected", false);
                component.set("v.selectedStudentsCount", 0);
                this.setTotalRecordsAndPages(component);
                this.getPageNumbers(component);
            } else {
                component.set("v.currentPageListStudents", []);
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        this.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },

    /**
     * toggleSpinner
     * @param なし
     * @return スピナーの表示/非表示を切り替えます。
     */
    toggleSpinner : function(component, event) {
        var spinner = component.get("v.spinner");
        component.set("v.spinner", !spinner);
    },

    /**
     * clearSearch
     * @param なし
     * @return 検索条件をクリアし、学生リストを再取得します。
     */
    clearSearch : function(component) {
        component.set("v.studentCodeSearch", null);
        component.set("v.studentNameSearch", null);
        component.set("v.classSearch", null);
        component.set("v.genderSearch", null);
        component.set("v.birthdaySearch", null);
        component.set("v.dayOfBirthSearch", null);
        component.set("v.monthOfBirthSearch", null);
        component.set("v.yearOfBirthSearch", null);
        component.set("v.isAnySearchkey", false);
        this.fetchStudents(component);
        this.toggleSpinner(component, event);
    },

    /**
     * getPageNumbers
     * @param なし
     * @return ページ番号のリストを返します。
     */
    getPageNumbers : function(component) {
        component.set("v.pageNums", []); 
        var totalPages = component.get("v.totalPages");
        var currentPage = component.get("v.currentPage");
        var pageNums = [];

        if (totalPages <= 5) {
            for (var i = 1; i <= totalPages; i++) {
                pageNums.push(i);
            } 
            component.set("v.pageNums", pageNums);
            return;
        }

        var startPage;
        if (currentPage <= 3) {
            startPage = 1;
        } else if (currentPage >= totalPages - 2) {
            startPage = totalPages - 4;
        } else {
            startPage = currentPage - 2;
        }

        for (var i = startPage; i < startPage + 5 && i <= totalPages; i++) {
            pageNums.push(i);
        }
        component.set("v.pageNums", pageNums);
    },

    /**
     * 関数名：goToPage
     * @param なし
     * @return 指定されたページ番号に移動し、学生のリストをページ分けして返します。
     */
    goToPage : function(component, pageNum) {
        var currentPageListStudents = component.get("v.studentsList").slice((pageNum - 1) * component.get("v.RecordPerPage"), pageNum * component.get("v.RecordPerPage"));
        component.set("v.currentPageListStudents", currentPageListStudents);
        component.set("v.currentPage", pageNum);
        this.getPageNumbers(component);
    },

    /**
     * 関数名：setTotalRecordsAndPages
     * @param なし
     * @return 合計レコード数とページ数を設定します。
     */
    setTotalRecordsAndPages : function(component) {
        component.set("v.totalRecords", 0);
        component.set("v.totalPages", 1);

        if (component.get("v.studentsList")) {
            component.set("v.totalRecords", component.get("v.studentsList").length);
            if (component.get("v.RecordPerPage") !== 0) {
                var totalPages = Math.ceil(component.get("v.totalRecords") / component.get("v.RecordPerPage"));
                if (totalPages){
                    component.set("v.totalPages", totalPages);
                }
            }
        }         
    },

    /**
     * 関数名：handleSelectStudent
     * @param なし
     * @return 学生の選択状態を更新し、全選択の状態を管理します。また、選択された学生の数をカウントして更新します。
     */
    handleSelectStudent : function(component, event) {
        if (component.get("v.allSelected") && !event.getSource().get("v.checked")) {
            component.set("v.allSelected", false);
        }
        var selectedStudentId = event.getSource().get("v.name");
        var studentsList = component.get("v.studentsList");
        var Counter = 0;
        for (var i = 0; i < studentsList.length; i++) {
            if (studentsList[i].Id === selectedStudentId) {
                studentsList[i].isSelected = event.getSource().get("v.checked");
                break;
            }
        }
        for (var j = 0; j < studentsList.length; j++) {
            if (studentsList[j].isSelected) {
                Counter++;
            }
        }
        component.set("v.studentsList", studentsList);
        component.set("v.selectedStudentsCount", Counter);
        if (Counter === studentsList.length) {
            component.set("v.allSelected", true);
        }
    },

    /**
     * 関数名：handleSelectAll
     * @param なし
     * @return 全選択のチェックボックスの状態に応じて、すべての学生の選択状態を更新します。また、選択された学生の数をカウントして更新します。
     */
    handleSelectAll : function(component, event) {
        var isChecked = event.getSource().get("v.checked");
        var studentsList = component.get("v.studentsList");
        if (studentsList) {
            for (var i = 0; i < studentsList.length; i++) {
                studentsList[i].isSelected = isChecked;
            }
            component.set("v.studentsList", studentsList);
            component.set("v.currentPageListStudents", studentsList.slice((component.get("v.currentPage") - 1) * component.get("v.RecordPerPage"), component.get("v.currentPage") * component.get("v.RecordPerPage")));
        }
        component.set("v.selectedStudentsCount", isChecked ? studentsList.length : 0);
    },

    /**
     * 関数名：viewStudentDetail
     * @param params 学生詳細画面を表示するためのパラメータ
     * @return 学生詳細画面を表示します。
     */
    viewStudentDetail : function(component, params) {
        if (params.name === "viewDetailFromCode") {
            this.navigateToDetail(component, params.studentId);
        }
        if (params.name === "viewDetailFromIcon") {
            this.openStudentDetailModal(component, params.studentId);
        }
    },

    /**
     * 関数名：openStudentDetailModal
     * @param studentId 学生詳細画面を表示するための学生ID
     * @return 学生詳細画面をモーダルで表示します。
     */
    openStudentDetailModal : function(component, studentId) {
        $A.createComponent(
            "c:CMP_DetailStudent",
            {
                studentId : studentId,
                isModal : true,
            }, 
            function(content, status, errorMessage) {
                if(status === 'SUCCESS') {
                    var overlayLib = component.find('overlayLib');
                    overlayLib.showCustomModal({
                        body : content,
                        showCloseButton : false
                    });
                } else if (status === 'ERROR') {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errorMessage,
                        type: "error"
                    }).fire();
                }
            }
        );
    },

    /**
     * 関数名：openCreateStudentModal
     * @param なし
     * @return 学生作成画面をモーダルで表示します。
     */
    openCreateStudentModal : function(component) {
        var helper = this;
        $A.createComponent(
            "c:CMP_CreateStudent",
            {}, 
            function(content, status, errorMessage) {
                if(status === 'SUCCESS') {
                    var overlayLib = component.find('overlayLib');
                    overlayLib.showCustomModal({
                        body : content,
                        showCloseButton : true,
                        closeCallback: $A.getCallback(function() {
                            helper.toggleSpinner(component, event);
                            helper.fetchStudentsWithoutResetPageCurrent(component);
                        })
                    });
                } else if (status === 'ERROR') {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errorMessage,
                        type: "error"
                    }).fire();
                }
            }
        );
    },

    /**
     * 関数名：openUpdateStudentModal
     * @param なし
     * @return 学生更新画面をモーダルで表示します。
     */
    openUpdateStudentModal : function(component, studentId) {
        var helper = this;
        var currentPage = component.get("v.currentPage");
        $A.createComponent(
            "c:CMP_UpdateStudent",
            {studentId : studentId}, 
            function(content, status, errorMessage) {
                if(status === 'SUCCESS') {
                    var overlayLib = component.find('overlayLib');
                    overlayLib.showCustomModal({
                        body : content,
                        showCloseButton : true,
                        closeCallback: $A.getCallback(function() {                            
                            helper.toggleSpinner(component, event);
                            helper.fetchStudentsWithoutResetPageCurrent(component);
                        })
                    });
                } else if (status === 'ERROR') {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errorMessage,
                        type: "error"
                    }).fire();
                }
            }
        );
    },

    /**
     * 関数名：deleteStudents
     * @param studentIds 削除する学生のIDリスト
     * @return 選択された学生情報を削除し、トーストメッセージを表示します。
     */
    deleteStudents : function(component, studentIds) {
        if (studentIds.length === 0) {
            $A.get("e.force:showToast").setParams({
                title: "Error",
                message: "削除する学生を選択してください。",
                type: "error"
            }).fire();
            return;
        }

        var deleteAction = component.get("c.deleteListStudents");
        deleteAction.setParams({ studentIds: studentIds });
        deleteAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:showToast").setParams({
                    title: "Success",
                    message: "選択された学生情報が削除されました。",
                    type: "success"
                }).fire();
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        component.set("v.selectedStudentsCount", 0);
        this.fetchStudentsWithoutResetPageCurrent(component);
        this.toggleSpinner(component, event);
        });
        $A.enqueueAction(deleteAction);
    },

    /**
     * 関数名：openDeleteConfirmationModal
     * @param studentIds 削除する学生のIDリスト
     * @return 削除確認モーダルを表示します。
     */
    openDeleteConfirmationModal : function(component, studentIds) {
        $A.createComponent(
            "c:CMP_DeleteStudent",
            { studentIds: studentIds },
            function(content, status, errorMessage) {
                if(status === 'SUCCESS') {
                    var overlayLib = component.find('overlayLib');
                    overlayLib.showCustomModal({
                        header: "学生を削除",                        
                        body : content,
                        showCloseButton : true,
                    });
                } else if (status === 'ERROR') {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errorMessage,
                        type: "error"
                    }).fire();
                }
            }
        );
    },

    /**
     * 関数名：handleSearchChange
     * @param なし
     * @return 検索条件が変更されたときに、検索条件が入力されているかどうかを判定し、isAnySearchkey属性を更新します。
     */
    handleSearchChange : function(component, event) {
        var studentCodeSearch = component.get("v.studentCodeSearch");
        var studentNameSearch = component.get("v.studentNameSearch");
        var classSearch = component.get("v.classSearch");
        var genderSearch = component.get("v.genderSearch");
        var birthdaySearch = component.get("v.birthdaySearch");
        var dayOfBirthSearch = component.get("v.dayOfBirthSearch");
        var monthOfBirthSearch = component.get("v.monthOfBirthSearch");
        var yearOfBirthSearch = component.get("v.yearOfBirthSearch");
        if (studentCodeSearch || studentNameSearch || classSearch || genderSearch || birthdaySearch || dayOfBirthSearch || monthOfBirthSearch || yearOfBirthSearch) {
            component.set("v.isAnySearchkey", true);

        } else {
            component.set("v.isAnySearchkey", false);
        }
    },

    /**
     * 関数名：fetchStudentsWithoutResetPageCurrent
     * @param なし
     * @return 学生のリストを再取得し、現在のページをリセットせずにページ分けして返します。
     */
    fetchStudentsWithoutResetPageCurrent : function(component) {
        var studentsList = component.get("v.studentsList");
        var listIDs = [];
        if (studentsList) {
            for (var i = 0; i < studentsList.length; i++) {
                if (studentsList[i].isSelected) {
                    listIDs.push(studentsList[i].Id);
                }
            }
        }

        var fetchStudentsAction = component.get("c.fetchStudents");
        fetchStudentsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var studentsList = response.getReturnValue();
                if (studentsList) {
                    var counter = 0;
                    for (var i = 0; i < studentsList.length; i++) {
                        var isSelected = listIDs && listIDs.includes(studentsList[i].Id);

                        if (isSelected) {
                            counter++;
                        }

                        studentsList[i].isSelected = isSelected;
                    }
                    component.set("v.studentsList", studentsList);
                    component.set("v.currentPageListStudents", studentsList.slice((component.get("v.currentPage") - 1) * component.get("v.RecordPerPage"), component.get("v.currentPage") * component.get("v.RecordPerPage")));
                    component.set("v.selectedStudentsCount", counter);
                    if (counter === studentsList.length && studentsList.length > 0) {
                        component.set("v.allSelected", true);
                    } else {
                        component.set("v.allSelected", false);
                    }
                }
                
                this.setTotalRecordsAndPages(component);
                this.getPageNumbers(component);
                var currentPage = component.get("v.currentPage");
                var totalPages = component.get("v.totalPages");
                if (currentPage === 0){
                    component.set("v.currentPage", 1);
                } else if (currentPage > totalPages) {
                    currentPage = totalPages;
                    component.set("v.currentPage", currentPage);
                    this.goToPage(component, component.get("v.currentPage"));
                }
            } else {
                var errors = response.getError();
                component.set("v.currentPageListStudents", []);
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        this.toggleSpinner(component, event);
        });
        $A.enqueueAction(fetchStudentsAction);
    }
})