({
    handleDelete : function(component, event, helper) {
        var evt = $A.get("e.c:EVT_DeleteConfirm");
        if (evt) {
            evt.setParams({ Confirm: true , studentIds: component.get("v.studentIds") });
            evt.fire();
            component.find("overlayLib").notifyClose();
        }
    },

    handleClose : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    }
})