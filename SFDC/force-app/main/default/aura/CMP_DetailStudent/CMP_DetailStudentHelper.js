({
    /**
     * 関数名：initGetInfoStudent
     * @param IDをもとに学生情報を取得する
     * @return Student__c のオブジェクトを返します
     */
    initGetInfoStudent : function(component, params) {
        var getInfoStudent = component.get("c.getStudent");
        getInfoStudent.setParams({
            id : params
        });
        getInfoStudent.setCallback(this, function(response) {
            var state = response.getState();    
            if (state === "SUCCESS") {
                component.set("v.student",  response.getReturnValue());
            } 
            else {
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
        $A.enqueueAction(getInfoStudent);
    },

    /**
     * 関数名：toggleSpinner
     * @param なし
     * @return スピナーの表示/非表示を切り替える
     */
    toggleSpinner: function (component, event) {
        component.set("v.spinner", !component.get("v.spinner"));
    }
})