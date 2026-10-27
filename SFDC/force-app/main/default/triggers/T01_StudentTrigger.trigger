/**
* クラス名  : T01_StudentTrigger
* クラス概要: Student__cオブジェクトのトリガー
* @created : 2026/07/01 Nguyen Ngoc Quy
* @modified: 
*/
trigger T01_StudentTrigger on Student__c (before insert, before update, after insert, after update, after delete, before delete) {
    StudentManageSetting__c setting = StudentManageSetting__c.getOrgDefaults();
    // if T01_InActive_flg__c is true, terminated the trigger
    if (setting.T01_InActive_flg__c) { 
        return;
    }
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            T01_StudentTriggerHandler.beforeInsertHandle(Trigger.new);
        } else if (Trigger.isUpdate) {
            T01_StudentTriggerHandler.beforeUpdateHandle(Trigger.new);
        } else if (Trigger.isDelete) {
            T01_StudentTriggerHandler.beforeDeleteHandle(Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            T01_StudentTriggerHandler.afterInsertHandle(Trigger.new);
        } else if (Trigger.isUpdate) {
            T01_StudentTriggerHandler.afterUpdateHandle(Trigger.new, Trigger.old);
        } else if (Trigger.isDelete) {
            T01_StudentTriggerHandler.afterDeleteHandle(Trigger.old);
        }
    }
}