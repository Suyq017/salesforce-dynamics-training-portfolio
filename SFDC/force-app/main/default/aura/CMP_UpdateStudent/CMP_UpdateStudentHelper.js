({
    /**
     * 関数名：initLoadData
     * @param なし
     * @return 学生の性別、学習状況、クラスの選択肢を取得し、学生情報をロード
     */
    initLoadData : function(component, params) {
        var getGenderOptionsAction = component.get("c.getGenderOptions");
        getGenderOptionsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var genderOptions = response.getReturnValue();
                var options = [];
                for (var key in genderOptions) {
                    options.push({ label: genderOptions[key], value: key });
                }
                component.set("v.genderOptions", options);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        });
        $A.enqueueAction(getGenderOptionsAction);
        
        var getLearningStatusOptionsAction = component.get("c.getLearningStatusOptions");
        getLearningStatusOptionsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var learningStatusOptions = response.getReturnValue();
                var options = [];
                for (var key in learningStatusOptions) {
                    options.push({ label: learningStatusOptions[key], value: key });
                }
                component.set("v.learningStatusOptions", options);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        });
        $A.enqueueAction(getLearningStatusOptionsAction);
        
        var getClassOptionsAction = component.get("c.getClassOptions");
        getClassOptionsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var classOptions = response.getReturnValue();
                var options = [];
                for (var key in classOptions) {
                    options.push({ label: classOptions[key], value: key });
                }
                component.set("v.classOptions", options);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        });
        $A.enqueueAction(getClassOptionsAction);
        
        var getStudentAction = component.get("c.getStudent");
        getStudentAction.setParams({
            id : params
        });
        getStudentAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.student", response.getReturnValue());
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    $A.get("e.force:showToast").setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"
                    }).fire();
                }
            }
        this.toggleSpinner(component, event);
        });
        $A.enqueueAction(getStudentAction);
    },

    /**
     * 関数名：updateStudent
     * @param なし
     * @return 学生情報を保存し、成功またはエラーメッセージを表示
     */
    updateStudent : function(component) {
        var updateAction = component.get("c.updateStudent");
        updateAction.setParams({
            student : component.get("v.student")
        });
        updateAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:showToast").setParams({
                    title: "Success",
                    message: "学生情報が保存されました。",
                    type: "success"
                }).fire();
                component.find("overlayLib").notifyClose();
            } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        $A.get("e.force:showToast").setParams({
                            title: "Error",
                            message: errors[0].message,
                            type: "error"
                        }).fire();
                    }
                }
        this.toggleSpinner(component, event);
        });
        $A.enqueueAction(updateAction);
    },

    /**
     * 関数名：toggleSpinner
     * @param なし
     * @return スピナーの表示/非表示を切り替える
     */
    toggleSpinner : function(component, event) {
        component.set("v.spinner", !component.get("v.spinner"));
    }
})