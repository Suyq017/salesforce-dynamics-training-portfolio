({
    handleSearch : function(component, event) {
        var evt = component.getEvent("EVT_Search");
        evt.setParams({
            studentCodeSearch: component.get("v.studentCodeSearch"),
            studentNameSearch: component.get("v.studentNameSearch"),
            classSearch: component.get("v.classSearch"),
            genderSearch: component.get("v.genderSearch"),
            birthdaySearch: component.get("v.birthdaySearch"),
            dayOfBirthSearch: component.get("v.dayOfBirthSearch"),
            monthOfBirthSearch: component.get("v.monthOfBirthSearch"),
            yearOfBirthSearch: component.get("v.yearOfBirthSearch")
        });
        evt.fire();

    },

    openCreateStudentModal : function(component) {
        var helper = this;
        $A.createComponent(
            "c:CMP_CreateStudent",
            {}, 
            function(content, status, errorMessage) {
                if(status === 'SUCCESS') {
                    var overlayLib = component.find('overlayLib');
                    overlayLib.showCustomModal({
                        body : content,
                        showCloseButton : true,
                        closeCallback: $A.getCallback(function() {
                            helper.toggleSpinner(component, event);
                            helper.fetchStudentsWithoutResetPageCurrent(component);
                        })
                    });
                } else if (status === 'ERROR') {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errorMessage,
                        type: "error"
                    }).fire();
                }
            }
        );
    },

    handleDateChange : function(component, event) {
    },

    handleBirthdayChange : function(component, event) {},

    handleSearchChange : function(component, event) {}
})