({
    doInit : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var params = component.get("v.studentId");
        helper.initLoadData(component, params);
    },
    
    handleSave : function(component, event, helper) {
        var requiredFields = component.find("requiredField");
        var allValid = true;
        requiredFields.forEach(function(field) {
            if (!field.checkValidity()) {
                field.showHelpMessageIfInvalid();
                allValid = false;
            }
        });
        if (!allValid) {
            return;
        } 
        helper.toggleSpinner(component, event);
        helper.updateStudent(component);
    },

    handleBack : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    }
})