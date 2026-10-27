({
    openSearchStudentModal : function(component, event) {
        
    },

    handleSearch : function(component, event, helper) {
        helper.handleSearch(component, event);
    },

    handleDateChange : function(component, event, helper) {
        helper.handleDateChange(component, event);
    },

    handleBirthdayChange : function(component, event, helper) {
        helper.handleBirthdayChange(component, event);
    },

    handleSearchChange : function(component, event, helper) {
        helper.handleSearchChange(component, event);
    },

    handleCreateStudent : function(component, event, helper) {
        helper.openCreateStudentModal(component);
    },
})