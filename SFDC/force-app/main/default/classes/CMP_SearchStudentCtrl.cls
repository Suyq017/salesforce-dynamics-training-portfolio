/**
* クラス名  ：CMP_SearchStudentCtrl
* クラス概要：学生を検索するためのApexコントローラークラス
* @created ：2026/06/16 Nguyen Ngoc Quy
* @modified：2026/07/21 Nguyen Ngoc Quy
*/
public with sharing class CMP_SearchStudentCtrl {
    
    // 2026/07/21 Nguyen Ngoc Quy Add Start
    @TestVisible
    private static Boolean throwException = false;
    // 2026/07/21 Nguyen Ngoc Quy Add End

    /**
    * fetchStudents
    * Student__cオブジェクトから学生のリストを取得するメソッド
    * @param: なし
    * @return: List<Student__c> - 学生のリスト
    * @created: 2026/06/16 Nguyen Ngoc Quy
    * @modified:
    */
    @AuraEnabled
    public static List<Student__c> fetchStudents() {
        try {
            List<Student__c> students = new List<Student__c>();
            students = [
                SELECT Id
                    , StudentCode__c
                    , Lastname__c
                    , Firstname__c
                    , Birthday__c
                    , Gender__c
                    , Class_look__r.Name
                FROM Student__c 
                ORDER BY StudentCode__c 
                ASC
                ];
            if (students.isEmpty()) {
                throw newMessageException('学生が見つかりませんでした。');
            }
            return students;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * newMessageException
    * 例外メッセージを作成するヘルパーメソッド
    * @param: String message - 例外メッセージの内容
    * @return: AuraHandledException - 作成された例外オブジェクト
    * @created: 2026/06/16 Nguyen Ngoc Quy
    * @modified: 2026/06/16 Nguyen Ngoc Quy
    */
    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    /**
    * getCustomSettings
    * StudentManageSetting__cオブジェクトからカスタム設定のリストを取得するメソッド
    * @param: なし
    * @return: List<StudentManageSetting__c> - カスタム設定のリスト
    * @created: 2026/06/16 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<String, Decimal> getCustomSettings(){
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            Map<String, Decimal> settings = new Map<String, Decimal>();
            StudentManageSetting__c studentSetting = StudentManageSetting__c.getOrgDefaults();
            if (studentSetting != null && studentSetting.S_RecordPerPage__c != null && studentSetting.S_RecordPerPage__c > 0) {
                settings.put('RecordPerPage', studentSetting.S_RecordPerPage__c);
            } else {
                settings.put('RecordPerPage', 5);
            }
            if (studentSetting != null && studentSetting.S_MaxRecord__c != null && studentSetting.S_MaxRecord__c > 0) {
                settings.put('MaxRecord', studentSetting.S_MaxRecord__c);
            } else {
                settings.put('MaxRecord', 2000);
            }
            return settings;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * getClassOptions
    * 学生のクラス選択肢を取得するメソッド
    * @param: なし
    * @return: クラスのIDと名前を含むMapオブジェクト
    * @created: 2026/06/16 Nguyen Ngoc Quy
    * @modified: 
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
    * @created: 2026/06/16 Nguyen Ngoc Quy
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
    * searchStudents
    * SOQLクエリを使用して学生を検索するメソッド
    * @param: なし
    * @return: 学生のリスト
    * @created: 2026/06/16 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static List<Student__c> searchStudents(string studentCodeSearch, string studentNameSearch, string classSearch, string genderSearch, Date birthdaySearch, String dayOfBirthSearch, String monthOfBirthSearch, String yearOfBirthSearch) {
        try {
            String SOQL = 'SELECT Id, StudentCode__c, Lastname__c, Firstname__c, Birthday__c, Gender__c, Class_look__r.Name FROM Student__c WHERE Id != null';

            if (String.isNotBlank(studentCodeSearch)) {
                SOQL += ' AND StudentCode__c LIKE \'%' + String.escapeSingleQuotes(studentCodeSearch) + '%\'';
            }
            if (String.isNotBlank(studentNameSearch)) {
                SOQL += ' AND Name LIKE \'%' + String.escapeSingleQuotes(studentNameSearch) + '%\'';
            }
            if (String.isNotBlank(classSearch)) {
                SOQL += ' AND Class_look__c = \'' + String.escapeSingleQuotes(classSearch) + '\'';
            }
            if (String.isNotBlank(genderSearch)) {
                SOQL += ' AND Gender__c = \'' + String.escapeSingleQuotes(genderSearch) + '\'';
            }
            if (birthdaySearch != null) {
                SOQL += ' AND Birthday__c = ' + String.valueOf(birthdaySearch);
            }
            if (String.isNotBlank(dayOfBirthSearch)) {
                SOQL += ' AND DAY_IN_MONTH(Birthday__c) = ' + String.escapeSingleQuotes(dayOfBirthSearch);
            }
            if (String.isNotBlank(monthOfBirthSearch)) {
                SOQL += ' AND CALENDAR_MONTH(Birthday__c) = ' + String.escapeSingleQuotes(monthOfBirthSearch);
            }
            if (String.isNotBlank(yearOfBirthSearch)) {
                SOQL += ' AND CALENDAR_YEAR(Birthday__c) = ' + String.escapeSingleQuotes(yearOfBirthSearch);
            }

            SOQL += ' ORDER BY StudentCode__c ASC';
            // 2026/07/21 Nguyen Ngoc Quy Delete Start
            // System.debug('SOQL: ' + SOQL);
            // if (String.isBlank(SOQL)) {
            //     throw newMessageException('SOQLクエリが空です。');
            // }
            // 2026/07/21 Nguyen Ngoc Quy Delete End
            List<Student__c> students = Database.query(SOQL);
            if (students.isEmpty()) {
                throw newMessageException('検索条件に一致する学生が見つかりませんでした。');
            }
            return students;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * deleteListStudents
    * 指定された学生IDのリストに基づいて複数の学生を削除するメソッド
    * @param:  List<Id> studentIds - 削除する学生のIDのリスト
    * @return: なし
    * @created: 2026/06/17 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static void deleteListStudents(List<Id> studentIds) {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            if (studentIds == null || studentIds.isEmpty()) {
                throw newMessageException('学生IDのリストが無効です。');
            }
            List<Student__c> studentsToDelete = [
                SELECT Id 
                FROM Student__c
                WHERE Id 
                IN :studentIds
            ];
            delete studentsToDelete;
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }
    
    // 2026/07/21 Nguyen Ngoc Quy Add Start
    /**
    * throwExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param: なし
    * @return: なし
    * @created: 2026/06/21 Nguyen Ngoc Quy
    * 
    */
    private static void throwExceptionForTesting() {
        if (throwException) {
            throw newMessageException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/21 Nguyen Ngoc Quy Add End
}