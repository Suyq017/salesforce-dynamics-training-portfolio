var CS_E0002_002 = window.CS_E0002_002 || {};
(function () {
    // Schema name
    var LEARNING_STATUS_SCHEMA_NAME = "ksvc_opt_learningstatus";

    // Learning status constants
    var LEARNING_STATUS = {
        GRADUATED : "Gradutated",
        ENROLLED: "Enrolled",
        WITHDRAWN: "Withdrawn"
    };

    // CS_E0002_002_onSave
    // Disable the learning status field if the learning status is "Graduated"
    this.CS_E0002_002_onSave = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var learningStatus = formContext.getAttribute(LEARNING_STATUS_SCHEMA_NAME)?.getText() ?? null;
        if (learningStatus == null || learningStatus !== LEARNING_STATUS.GRADUATED) {
            return;
        }
        var learningStatusControl = formContext.getControl(LEARNING_STATUS_SCHEMA_NAME) ?? null;
        if (learningStatusControl) {
            learningStatusControl.setDisabled(true);
        }
    };
}).call(CS_E0002_002);