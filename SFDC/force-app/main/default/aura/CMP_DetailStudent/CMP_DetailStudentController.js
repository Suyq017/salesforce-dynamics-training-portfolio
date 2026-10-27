({
    doInit : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var pageReference = component.get("v.pageReference");
        if (!component.get("v.isModal") 
            && pageReference != null
            && pageReference.state != null
            && pageReference.state.c__studentId != null) {
            var params = pageReference.state.c__studentId;
        }
        else {
            var params = component.get("v.studentId");
        }
        helper.initGetInfoStudent(component, params);
    },

    handleClose : function(component, event, helper) {
        if (component.get("v.isModal")) {
            component.find("overlayLib").notifyClose();
        }
        else {
            var navService = component.find("navService");
                navService.navigate({
                    type: "standard__component",
                    attributes: {
                        "componentName": "c__CMP_SearchStudent"
                    }
                });
        }
    },

    openClassPage : function(component, event, helper) {
        var navService = component.find("navService");

        navService.navigate({
            type: "standard__recordPage",
            attributes: {
                recordId: component.get("v.student.Class_look__c"),
                objectApiName: "Class__c",
                actionName: "view"
            }
        });
    }
})