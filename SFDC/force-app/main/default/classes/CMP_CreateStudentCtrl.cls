/**
* クラス名  ：CMP_CreateStudentCtrl
* クラス概要：学生のクラス選択肢を取得するコントローラークラス
* @created ：2026/06/12 Nguyen Ngoc Quy
* @modified：2026/007/21 Nguyen Ngoc Quy
*/
public with sharing class CMP_CreateStudentCtrl {

    // 2026/07/21 Nguyen Ngoc Quy Add Start
    @TestVisible
    private static Boolean throwException = false;
    // 2026/07/21 Nguyen Ngoc Quy Add End

    /**
    * getClassOptions
    * 学生のクラス選択肢を取得するメソッド
    * @param: なし
    * @return: クラスのIDと名前を含むMapオブジェクト
    * @created: 2026/06/12 Nguyen Ngoc Quy
    * @modified: 2026/06/12 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<string, string> getClassOptions() {
        try {
            Map<string, string> options = new Map<string, string>();
            List<Class__c> classes = [
                SELECT Id
                    , Name 
                FROM Class__c 
                ORDER BY Name
            ];
            if (classes.isEmpty()) {
                throw newMessageException('クラスが見つかりませんでした。');
            }
            for (Class__c cls : classes) {
                options.put(cls.Id, cls.Name);
            }
            return options;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }
    
    /**
    * getGenderOptions
    * 学生の性別選択肢を取得するメソッド
    * @param: なし
    * @return: 性別の値とラベルを含むMapオブジェクト
    * @created: 2026/06/12 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<string, string> getGenderOptions() {
        try {
            Map<string, string> options = new Map<string, string>();
            Schema.DescribeFieldResult fieldResult = Student__c.Gender__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            // 2026/07/21 Nguyen Ngoc Quy Modify Start
            // if (picklistEntries.isEmpty()) {
            if (picklistEntries.isEmpty() || (throwException && Test.isRunningTest())) {
            // 2026/07/21 Nguyen Ngoc Quy Modify End
                throw newMessageException('性別の選択肢が見つかりませんでした。');
            }
            for (Schema.PicklistEntry entry : picklistEntries) {
                options.put(entry.getValue(), entry.getLabel());
            }
            return options;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * getLearningStatusOptions
    * 学生の学習状況選択肢を取得するメソッド
    * @param: なし
    * @return: 学習状況の値とラベルを含むMapオブジェクト
    * @created: 2026/06/12 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<string, string> getLearningStatusOptions() {
        try {
            Map<string, string> options = new Map<string, string>();
            Schema.DescribeFieldResult fieldResult = Student__c.LearningStatus__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            // 2026/07/21 Nguyen Ngoc Quy Modify Start
            // if (picklistEntries.isEmpty()) {
            if (picklistEntries.isEmpty() || (throwException && Test.isRunningTest())) {
            // 2026/07/21 Nguyen Ngoc Quy Modify End
                throw newMessageException('学習状況の選択肢が見つかりませんでした。');
            }
            for (Schema.PicklistEntry entry : picklistEntries) {
                options.put(entry.getValue(), entry.getLabel());
            }
            return options;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }
    
    /**
    * saveStudent
    * 学生情報を保存するメソッド
    * @param: Student__c student - 保存する学生情報を含むオブジェクト
    * @return: なし
    * @created: 2026/06/15 Nguyen Ngoc Quy
    * @modified: 2026/06/15 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static void saveStudent(Student__c student) {
        try {
            if (student == null) {
                throw newMessageException('学生情報が提供されていません。');
            }
            if (String.isBlank(student.FirstName__c)) {
                throw newMessageException('学生の名前が提供されていません。');
            }
            if (String.isBlank(student.LastName__c)) {
                throw newMessageException('学生の名字が提供されていません。');
            }
            student.Name = student.LastName__c + ' ' + student.FirstName__c;
            if (student.Birthday__c != null){
                if (student.Birthday__c.addYears(18) > Date.today()) {
                    throw newMessageException('学生は18歳以上でなければなりません。');
                }
            }
            if (student.Class_look__c == null) {
                throw newMessageException('学生のクラスが選択されていません。');
            }
            if (student.Gender__c == null) {
                throw newMessageException('学生の性別が選択されていません。');
            }
            if (student.LearningStatus__c == null) {
                throw newMessageException('学生の学習状況が選択されていません。');
            }
            insert student;
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * newMessageException
    * 例外メッセージを作成するヘルパーメソッド
    * @param: String message - 例外メッセージの内容
    * @return: AuraHandledException - 作成された例外オブジェクト
    * @created: 2026/06/15 Nguyen Ngoc Quy
    * @modified: 2026/06/15 Nguyen Ngoc Quy
    */
    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
}