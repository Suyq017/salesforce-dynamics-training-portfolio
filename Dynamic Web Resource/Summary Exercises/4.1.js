var SummaryExercise = window.SummaryExercise || {};
(function () {
    // Define some global variables
    var myUniqueId = new Date().getTime().toString(); // Define an ID for the notification
    var currentUserName = Xrm.Utility.getGlobalContext().userSettings.userName; // get current user name
    var message = currentUserName + ": Student JavaScript code in action!";

    // Code to run in the form OnLoad event
    this.formOnLoad = function (executionContext) {
        var formContext = executionContext.getFormContext();

        // Display the form level notification as an INFO
        formContext.ui.setFormNotification(message, "INFO", myUniqueId);

        // Wait for 5 seconds before clearing the notification
        window.setTimeout(function () { formContext.ui.clearFormNotification(myUniqueId); }, 5000);
    }

    // Code to run in the column OnChange event 
    this.attributeOnChange = function (executionContext) {
        var formContext = executionContext.getFormContext();

        formContext.getAttribute("ksvc_slt_studentname").addOnChange(function () {
            SummaryExercise.setGender(formContext);
        });
    }

    this.setGender = function (formContext) {
        var studentFullName = formContext.getAttribute("ksvc_slt_studentname").getValue();
        if (studentFullName.toLowerCase().search("van") != -1) {
            formContext.getAttribute("ksvc_opt_gender").getOptions().forEach(function (option) {
                if (option.text.toLowerCase() === "male") {
                    formContext.getAttribute("ksvc_opt_gender").setValue(option.value);
                }
            });
        }
    }

    // Code to run in the form OnSave event 
    this.formOnSave = function () {
        var alertStrings = { confirmButtonLabel: "OK", text: "Record saved.", title: "Save Confirmation" };
        var alertOptions = { height: 120, width: 260 };
        // Display an alert dialog
        Xrm.Navigation.openAlertDialog(alertStrings, alertOptions).then(
            function (success) {
                console.log("Alert dialog closed");
            },
            function (error) {
                console.log(error.message);
            }
        );
    }
}).call(SummaryExercise);