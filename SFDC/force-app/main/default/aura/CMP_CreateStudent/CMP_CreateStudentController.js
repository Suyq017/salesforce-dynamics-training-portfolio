({
    doInit : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.initLoadOptions(component);
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
        helper.saveStudent(component);
    },

    handleBack : function(component, event, helper) {
        helper.navigateToSearchPage(component);
    },

    handleClose : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
})