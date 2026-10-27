var CS_E0002_003 = window.CS_E0002_003 || {};
(function () {
    // Intern information
    var INTERN_NAME = "Nguyen Ngoc Quy";
    var INTERN_BIRTHDAY = new Date(2004, 6, 26);
    
    // Schema name
    var STUDENTNAME_SCHEMA_NAME = "ksvc_slt_studentname";
    var GENDER_SCHEMA_NAME = "ksvc_opt_gender";
    var BIRTHDAY_SCHEMA_NAME = "ksvc_dat_birthday";
    var LEARNING_STATUS_SCHEMA_NAME = "ksvc_opt_learningstatus";

    // Learning status constants
    var LEARNING_STATUS = {
        GRADUATED : "Gradutated",
        ENROLLED: "Enrolled",
        WITHDRAWN: "Withdrawn"
    };

    // CS_E0002_003_onLoad
    // Set the intern information when the form is loaded
    this.CS_E0002_003_onLoad = function (executionContext) {
        var formContext = executionContext.getFormContext();
        if (formContext.ui.getFormType() !== 1) {
            return;
        }
        var gender = this.RandomGender(formContext);
        if (gender === null) {
            console.error("Failed to get a random gender value.");
        }
        var learningStatus = this.GetLearningStatusValue(formContext, LEARNING_STATUS.ENROLLED);
        if (learningStatus === null) {
            console.error("Failed to get the learning status value for 'Enrolled'.");
        }
        var birthday = INTERN_BIRTHDAY instanceof Date && !isNaN(INTERN_BIRTHDAY) ? INTERN_BIRTHDAY : null;

        formContext.getAttribute(GENDER_SCHEMA_NAME).setValue(gender);
        formContext.getAttribute(LEARNING_STATUS_SCHEMA_NAME).setValue(learningStatus);
        formContext.getAttribute(STUDENTNAME_SCHEMA_NAME).setValue(INTERN_NAME);
        formContext.getAttribute(BIRTHDAY_SCHEMA_NAME).setValue(birthday);
    };

    // RandomGender
    // Get a random gender value from the
    this.RandomGender = function (formContext) {
        var genderOptions = formContext.getAttribute(GENDER_SCHEMA_NAME).getOptions();
        if (!genderOptions || genderOptions.length === 0) {
            return null;
        }
        var randomIndex = Math.floor(Math.random() * genderOptions.length);
        return genderOptions[randomIndex].value;
    };

    // GetLearningStatusValue
    // Get the learning status value based on the learning status text
    this.GetLearningStatusValue = function (formContext, learningStatusText) {
        var learningStatusOption = formContext.getAttribute(LEARNING_STATUS_SCHEMA_NAME).getOptions();
        if (!learningStatusOption || learningStatusOption.length === 0) {
            return null;
        }
        var learningStatus = learningStatusOption.find(function (option) {
            return option.text === learningStatusText;
        }) ?? null;
        return learningStatus?.value ?? null;
    };
}).call(CS_E0002_003);