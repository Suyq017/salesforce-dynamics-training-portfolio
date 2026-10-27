var SummaryExercise = window.SummaryExercise || {};
(function () {
    var myUniqueId = new Date().getTime().toString(); 
    var currentUserName = Xrm.Utility.getGlobalContext().userSettings.userName; 
    var message = currentUserName + ": Student JavaScript code in action!";

    this.formOnLoad = function (executionContext) {
        var formContext = executionContext.getFormContext();
        SummaryExercise.readAndChangeStudentName(executionContext);
    };

    this.attributeOnChange = function (executionContext) {
        var formContext = executionContext.getFormContext();

        formContext.getAttribute("ksvc_slt_studentname").addOnChange(function () {
            SummaryExercise.setGender(formContext);
        });
    };

    // 4.2.8
    // Sử dụng hàm openConfirmDialog, lúc Onsave thì hiển thị confirm dialog, False thì không thực hiện xử lý lưu 
    var formSaved = false;
    var SaveMode = {
        Save: 1,
        SaveAndClose: 2,
        SaveAndNew: 59,
        Autosave: 70
    };
    this.formOnSave = function (executionContext) {
        var eventArgs = executionContext.getEventArgs();

        // Check if the save event has already been prevented from different sources (like other scripts or built-in logic)
        if (eventArgs.isDefaultPrevented()) {
            return;
        }
        
        var saveMode = eventArgs.getSaveMode();
        if (saveMode === SaveMode.Autosave) { 
            return;
        }

        // if (localStorage.getItem("formSaved") === null) {
        //     localStorage.setItem("formSaved", "false");
        // }        
        
        // if (localStorage.getItem("formSaved") === "false") {
        if (formSaved === false) {
            eventArgs.preventDefault();
        }
        // if (localStorage.getItem("formSaved") === "true") {
        if (formSaved === true) {
            // localStorage.setItem("formSaved", "false");
            formSaved = false;
            return;
        }
        var confirmStrings = { 
            text: "Are you sure you want to save this record?"
            , title: "Confirm Save"
            , confirmButtonLabel: "Yes"
            , cancelButtonLabel: "No" 
        };
        var confirmOptions = { height: 200, width: 400 };
        Xrm.Navigation.openConfirmDialog(confirmStrings, confirmOptions).then(
            function (success) {
                if (success.confirmed) {
                    // localStorage.setItem("formSaved", "true");
                    formSaved = true;
                    executionContext.getFormContext().data.save(saveMode);
                    console.log("User confirmed save.");
                } else {
                    console.log("User canceled save.");
                }
        });
    };

    // 4.2.1
    // Thực thi hàm đọc và thay đổi giá trị của field bất kỳ 
    this.readAndChangeStudentName = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var studentName = formContext.getAttribute("ksvc_slt_studentname").getValue();
        console.log("Student Name: " + studentName);
        formContext.getAttribute("ksvc_slt_studentname").setValue(studentName + " (Modified)");
    };

    // 4.2.2
    // Thực thi hàm ẩn/hiện field bất kỳ 
    this.hideFields = function (executionContext) {
        var formContext = executionContext.getFormContext();
        formContext.getControl("ksvc_opt_gender").setVisible(false);
    };

    // 4.2.3
    // Thực thi hàm chuyển field bất kỳ thành require 
    this.makeRequired = function (executionContext) {
        var formContext = executionContext.getFormContext();
        formContext.getAttribute("ksvc_opt_gender").setRequiredLevel("required");
    };

    // 4.2.4
    // Thực thi hàm hide tab bất kỳ 
    this.hideTab = function (executionContext) {
        var formContext = executionContext.getFormContext();
        formContext.ui.tabs.get("tab_1").setVisible(false);
    };

    // 4.2.5
    // Get giá trị của field bất kỳ có định dạng là singletext, rồi set vào field singletext khác 
    this.getAndSetSingleText = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var Address1_Line1 = formContext.getAttribute("address1_line1").getValue();
        console.log("Single Line Text Value: " + Address1_Line1);
        var Address1_Line2 = formContext.getAttribute("address1_line2").getValue();
        console.log("Traversed Path: " + Address1_Line2);
        formContext.getAttribute("name").setValue(Address1_Line1 + " (" + Address1_Line2 + ")");
    };

    // 4.2.6 
    // Thực hiện hàm set giá trị vào field có type Search (Lookup)
    this.setLookUpValue = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var classId = "cdcc8932-ba8b-f111-8077-002248b2d5e2";
        var classRecord = [{
            id: classId,
            entityType: "ksvc_mst_class",
        }];
        formContext.getAttribute("ksvc_lup_class").setValue(classRecord);
    };
    
    // 4.2.7
    // Thực thi hàm set giá trị vào field có type OptionSet 
    this.setOptionSetValue = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var studentFullName = formContext.getAttribute("ksvc_slt_studentname").getValue();
        if (studentFullName.toLowerCase().search("van") != -1) {
            formContext.getAttribute("ksvc_opt_gender").getOptions().forEach(function (option) {
                if (option.text.toLowerCase() === "male") {
                    formContext.getAttribute("ksvc_opt_gender").setValue(option.value);
                }
            });
        }
    };

    // 4.2.10
    // Sử dụng hàm openForm để mở 1 form khác 
    this.openAnotherForm = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var classId = formContext.getAttribute("ksvc_lup_class").getValue();

        var entityFormOptions = {};
        entityFormOptions["entityName"] = "ksvc_mst_class";
        entityFormOptions["entityId"] = classId[0].id;
        Xrm.Navigation.openForm(entityFormOptions).then(
            function (success) {
                console.log(success);
            },
            function (error) {
                console.log(error);
        });
    };

    // 4.2.11
    // Thực thi hàm tạo record con 
    this.createChildRecord = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var studentId = formContext.data.entity.getId();
        studentId = studentId.replace("{", "").replace("}", "");

        var subjectId = "{c5335b6b-c48b-f111-8077-7c1e52534e4c}";
        subjectId = subjectId.replace("{", "").replace("}", "");

        var semesterId = "{2e3d0b7e-c58b-f111-8077-7c1e52534e4c}";
        semesterId = semesterId.replace("{", "").replace("}", "");

        var subjectScoreData = {
            "ksvc_lup_student@odata.bind": `/ksvc_tra_students(${studentId})`,
            "ksvc_lup_subject@odata.bind": `/ksvc_mst_subjects(${subjectId})`,
            "ksvc_lup_semester@odata.bind": `/ksvc_mst_semesters(${semesterId})`
        };

        Xrm.WebApi.createRecord("ksvc_tra_subjectscore", subjectScoreData).then(
            function (success) {
                console.log("Subject Score record created successfully.");
            },
            function (error) {
                console.log(error.message);
            }
        );
    };

    // 4.2.12
    // Thực thi hàm update record cha 
    this.updateParentRecord = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var classId = formContext.getAttribute("ksvc_lup_class").getValue()[0].id;
        var options = "?$select=ksvc_int_numberofstudent";
        Xrm.WebApi.retrieveRecord("ksvc_mst_class", classId, options).then(
            function (record) {
                Xrm.WebApi.updateRecord("ksvc_mst_class", classId, {
                    "ksvc_int_numberofstudent": record.ksvc_int_numberofstudent + 1
                });
            }
        );
    };

    // 4.2.13
    // Thực thi hàm get rồi update record con 
    this.getAndUpdateChildRecord = function (executionContext) {
        var formContext = executionContext.getFormContext();
        var classId = formContext.data.entity.getId();
        classId = classId.replace("{", "").replace("}", "");
        var options = "?$select=ksvc_tra_studentid,ksvc_slt_studentname&$filter=_ksvc_lup_class_value eq " + classId;
        Xrm.WebApi.retrieveMultipleRecords("ksvc_tra_student", options).then(
            function (result) {
                if (result.entities.length > 0) {
                    for (var i = 0; i < result.entities.length; i++) {
                        var studentId = result.entities[i].ksvc_tra_studentid;
                        Xrm.WebApi.updateRecord("ksvc_tra_student", studentId, {
                            "ksvc_slt_studentname": "Updated Student Name of Class " + classId
                        }).then(
                            function (success) {
                                console.log("Student " + studentId + " record updated successfully.");
                            },
                            function (error) {
                                console.log(error.message);
                            }
                        );
                    }
                }
            }
        );
    };
}).call(SummaryExercise);