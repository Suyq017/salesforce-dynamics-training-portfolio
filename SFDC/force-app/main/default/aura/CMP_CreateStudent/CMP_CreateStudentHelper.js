({
    /**
     * 関数名：initLoadOptions
     * @param なし
     * @return 性別、学習状況、クラスの選択肢一覧
     */
    initLoadOptions : function(component) {
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
        this.toggleSpinner(component, event);
        });
        $A.enqueueAction(getClassOptionsAction);
    },

    /**
     * 関数名：saveStudent
     * @param なし
     * @return 学生情報を保存し、成功またはエラーメッセージを表示
     */
    saveStudent : function(component) {
        var saveAction = component.get("c.saveStudent");
        saveAction.setParams({
            student : component.get("v.student")
        });
        saveAction.setCallback(this, function(response) {
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
        $A.enqueueAction(saveAction);
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