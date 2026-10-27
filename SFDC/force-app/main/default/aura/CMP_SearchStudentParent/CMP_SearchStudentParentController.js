({
    initAction : function(component, event, helper) {
        // helper.toggleSpinner(component, event);
        helper.getCustomSettings(component);
        helper.fetchSearchKey(component);
        helper.fetchStudents(component);
    },

    handleDateChange : function(component, event, helper) {
        helper.handleDateChange(component, event);
    },

    handleBirthdayChange : function(component, event, helper) {
        helper.handleBirthdayChange(component, event);
    },

    handleSearch : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.searchStudents(component, event);
    },

    handleCreateStudent : function(component, event, helper) {
        helper.openCreateStudentModal(component);
    },

    handleClearSearch : function(component, event, helper) {
        helper.clearSearch(component);
    },

    handleFirstPage : function(component, event, helper) {
        helper.goToPage(component, 1);
    },
    
    handlePreviousPage : function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        if (currentPage > 1) {
            helper.goToPage(component, currentPage - 1);
        }
    },
    
    handleNextPage : function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = component.get("v.totalPages");
        if (currentPage < totalPages) {
            helper.goToPage(component, currentPage + 1);
        }
    },

    handleLastPage : function(component, event, helper) {
        helper.goToPage(component, component.get("v.totalPages"));
    },

    handlePageChange : function(component, event, helper) {
        var pageNum = event.getSource().get("v.value");
        helper.goToPage(component, pageNum);
    },

    handleSelectStudent : function(component, event, helper) {
        helper.handleSelectStudent(component, event);
    },

    handleSelectAll : function(component, event, helper) {
        helper.handleSelectAll(component, event);
    },

    handleViewDetail : function(component, event, helper) {
        var studentId = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        var params = {
            studentId: studentId,
            name: name
        }
        helper.viewStudentDetail(component, params);
    },

    handleViewUpdate : function(component, event, helper) {
        var studentId = event.getSource().get("v.value");
        helper.openUpdateStudentModal(component, studentId);
    },

    handleDeleteStudent : function(component, event, helper) {
        var type = event.getSource().get("v.name");
        var studentIds;
        if (type === "deleteSpecificIdStudent") {
            studentIds = [event.getSource().get("v.value")];
        } 
        else if (type === "deleteListSelectedStudents") {
            var studentsList = component.get("v.studentsList");
            studentIds = [];
            for (var i = 0; i < studentsList.length; i++) {
                if (studentsList[i].isSelected) {
                    studentIds.push(studentsList[i].Id);
                }
            }
        }
        helper.openDeleteConfirmationModal(component, studentIds);
    },

    handleSearchChange : function(component, event, helper) {
        helper.handleSearchChange(component, event);
    },

    handleDeleteStudentEvent : function(component, event, helper) {
        var confirm = event.getParam("Confirm");
        var studentIds = event.getParam("studentIds");
        if (confirm) {
            helper.deleteStudents(component, studentIds);
        }
    }
})
