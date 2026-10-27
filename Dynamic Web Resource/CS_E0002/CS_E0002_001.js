var CS_E0002_001 = window.CS_E0002_001 || {};
(function () {
    // Schema name
    var GPASCORE_SCHEMA_NAME = "ksvc_dcn_gpascore";
    var CLASSIFICATION_SCHEMA_NAME = "ksvc_opt_classification";

    // Global variables
    var GPAScore;
    var Classification;

    // CS_E0002_001_onSelect
    // Calculate the classification based on the GPA score and set the value in the form
    this.CS_E0002_001_onSelect = function (Control) {
        var formContext = Control;
        GPAScore = formContext.getAttribute(GPASCORE_SCHEMA_NAME).getValue();
        if (GPAScore === null || GPAScore === undefined || GPAScore < 0 || GPAScore > 10) {
            Classification = null;
        } else if (GPAScore >= 8.2 && GPAScore <= 10) {
            Classification = "A";
        } else if (GPAScore >= 6.5 && GPAScore < 8.2) {
            Classification = "B";
        } else if (GPAScore >= 4.9 && GPAScore < 6.5) {
            Classification = "C";
        } else if (GPAScore >= 0 && GPAScore < 4.9) {
            Classification = "D";
        }
        formContext.getAttribute(CLASSIFICATION_SCHEMA_NAME).setValue(this.getClassificationValue(formContext, Classification));
    };

    // getClassificationValue
    // Get the classification value based on the classification text
    this.getClassificationValue = function (formContext, classificationText) {
        var classificationOption = formContext.getAttribute(CLASSIFICATION_SCHEMA_NAME).getOptions();
        if (!classificationOption || classificationOption.length === 0) {
            return null;
        }
        var classification = classificationOption.find(function (option) {
            return option.text === classificationText;
        }) ?? null;
        return classification?.value ?? null;
    };
}).call(CS_E0002_001);