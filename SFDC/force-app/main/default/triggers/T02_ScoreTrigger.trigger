/**
* クラス名  : T02_ScoreTrigger
* クラス概要: Scoreオブジェクトのトリガー
* @created : 2026/07/01 Nguyen Ngoc Quy
* @modified: 
*/
trigger T02_ScoreTrigger on Score__c (after insert, after update) {
    StudentManageSetting__c setting = StudentManageSetting__c.getOrgDefaults();
    // if T02_InActive_flg__c is true, terminated the trigger
    if (setting.T02_InActive_flg__c) {
        return;
    }
    if (Trigger.isAfter){
        if (Trigger.isInsert){
            T02_ScoreTriggerHandler.afterInsertHandle(Trigger.new);
        } else if (Trigger.isUpdate){
            T02_ScoreTriggerHandler.afterUpdateHandle(Trigger.new);
        }
    }
}