/**
* クラス名  ：LWC_SearchStudentCtrl
* クラス概要：学生を検索するためのApexコントローラークラス
* @created ：2026/06/22 Nguyen Ngoc Quy
* @modified：2026/07/16 Nguyen Ngoc Quy
*/
public with sharing class LWC_SearchStudentCtrl {
    // 2026/06/22 Nguyen Ngoc Quy Add start
    @TestVisible
    private static Boolean throwException = false;
    // 2026/06/22 Nguyen Ngoc Quy Add end

    /**
    * fetchStudents
    * Student__cオブジェクトから学生のリストを取得するメソッド
    * @param: なし
    * @return: List<Student__c> - 学生のリスト
    * @created: 2026/06/22 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static List<Student__c> fetchStudentsList(Integer maxRecords) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            if (maxRecords == null || maxRecords <= 0) {
                maxRecords = 2000;
            }
            List<Student__c> students = new List<Student__c>();
            students = [
                SELECT Id
                    , StudentCode__c
                    , Lastname__c
                    , Firstname__c
                    , Birthday__c
                    , toLabel(Gender__c)
                    , Class_look__r.Name
                FROM Student__c 
                ORDER BY StudentCode__c
                ASC
                LIMIT :maxRecords
                ];
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
    * @created: 2026/06/22 Nguyen Ngoc Quy
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
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    private static Map<String, Decimal> getCustomSettings(){
        // 2026/07/16 Nguyen Ngoc Quy Modify start
        // try {
        //     Map<String, Decimal> settings = new Map<String, Decimal>();
        //     StudentManageSetting__c studentSetting = StudentManageSetting__c.getOrgDefaults();
        //     if (studentSetting != null && studentSetting.S_RecordPerPage__c != null && studentSetting.S_RecordPerPage__c > 0) {
        //         settings.put('RecordPerPage', studentSetting.S_RecordPerPage__c);
        //     } else {
        //         settings.put('RecordPerPage', 5);
        //     }
        //     if (studentSetting != null && studentSetting.S_MaxRecord__c != null && studentSetting.S_MaxRecord__c > 0) {
        //         settings.put('MaxRecord', studentSetting.S_MaxRecord__c);
        //     } else {
        //         settings.put('MaxRecord', 2000);
        //     }
        //     return settings;
        // }
        // catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
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
        // 2026/07/16 Nguyen Ngoc Quy Modify end
    }

    /**
    * getClassOptions
    * 学生のクラス選択肢を取得するメソッド
    * @param: なし
    * @return: クラスのIDと名前を含むMapオブジェクト
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    private static Map<String, String> getClassOptions() {
        // 2026/07/16 Nguyen Ngoc Quy Modify start
        // try {
        //     Map<String, String> options = new Map<String, String>();
        //     List<Class__c> classes = [
        //         SELECT Id
        //             , Name 
        //         FROM Class__c 
        //         ORDER BY Name
        //     ];
        //     for (Class__c cls : classes) {
        //         options.put(cls.Id, cls.Name);
        //     }
        //     return options;
        // }
        // catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
        Map<String, String> options = new Map<String, String>();
        List<Class__c> classes = [
            SELECT Id
                , Name 
            FROM Class__c 
            ORDER BY Name
        ];
        for (Class__c cls : classes) {
            options.put(cls.Id, cls.Name);
        }
        return options;
        // 2026/07/16 Nguyen Ngoc Quy Modify end
    }
    
    /**
    * getGenderOptions
    * 学生の性別選択肢を取得するメソッド
    * @param: なし
    * @return: 性別の値とラベルを含むMapオブジェクト
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    private static Map<String, String> getGenderOptions() {
        // 2026/07/16 Nguyen Ngoc Quy Modify start
        // try {
        //     Map<String, String> options = new Map<String, String>();
        //     Schema.DescribeFieldResult fieldResult = Student__c.Gender__c.getDescribe();
        //     List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        //     for (Schema.PicklistEntry entry : picklistEntries) {
        //         options.put(entry.getValue(), entry.getLabel());
        //     }
        //     return options;
        // }
        // catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Student__c.Gender__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            options.put(entry.getValue(), entry.getLabel());
        }
        return options;
        // 2026/07/16 Nguyen Ngoc Quy Modify end
    }

    /**
    * searchStudents
    * 指定された検索条件に基づいて学生を検索するメソッド
    * @param: searchKey - 検索条件を含むオブジェクト
    * @return: 学生のリスト
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static List<Student__c> searchStudents(String studentCodeSearch, String studentNameSearch, String classSearch, String genderSearch, Date birthdaySearch, String dayOfBirthSearch, String monthOfBirthSearch, String yearOfBirthSearch, Integer maxRecords) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            String SOQL = 'SELECT Id, StudentCode__c, Lastname__c, Firstname__c, Birthday__c, toLabel(Gender__c), Class_look__r.Name FROM Student__c';            
            
            if (String.isNotBlank(studentCodeSearch)) {
                studentCodeSearch = '%' + studentCodeSearch + '%';
            }
            if (String.isNotBlank(studentNameSearch)) {
                studentNameSearch = '%' + studentNameSearch + '%';
            }

            Integer dayOfBirth;
            if (String.isNotBlank(dayOfBirthSearch)) {
                dayOfBirth = Integer.valueOf(dayOfBirthSearch);
            }
            Integer monthOfBirth;
            if (String.isNotBlank(monthOfBirthSearch)) {
                monthOfBirth = Integer.valueOf(monthOfBirthSearch);
            }
            Integer yearOfBirth;
            if (String.isNotBlank(yearOfBirthSearch)) {
                yearOfBirth = Integer.valueOf(yearOfBirthSearch);
            }

            String whereClause = buildSOQLQuery(studentCodeSearch, studentNameSearch, classSearch, genderSearch, birthdaySearch, dayOfBirthSearch, monthOfBirthSearch, yearOfBirthSearch);
            if (String.isNotBlank(whereClause)) {
                SOQL += whereClause;
            }

            if (maxRecords == null || maxRecords <= 0) {
                maxRecords = 2000;
            }
            SOQL += ' ORDER BY StudentCode__c ASC LIMIT ' + maxRecords;
  
            return Database.query(SOQL);
        }
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * buildSOQLQuery
    * 検索条件に基づいてSOQLクエリを構築するメソッド
    * @param: searchKey - 検索条件を含むオブジェクト
    * @return: String - 構築されたSOQLクエリ
    * @created: 2026/06/26 Nguyen Ngoc Quy
    */
    private static String buildSOQLQuery(String studentCodeSearch, String studentNameSearch, String classSearch, String genderSearch, Date birthdaySearch, String dayOfBirthSearch, String monthOfBirthSearch, String yearOfBirthSearch) {
        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(studentCodeSearch)) {
            conditions.add('StudentCode__c LIKE :studentCodeSearch');
        }
        if (String.isNotBlank(studentNameSearch)) {
            conditions.add('Name LIKE :studentNameSearch');
        }
        if (String.isNotBlank(classSearch)) {
            conditions.add('Class_look__c = :classSearch');
        }
        if (String.isNotBlank(genderSearch)) {
            conditions.add('Gender__c = :genderSearch');
        }
        if (birthdaySearch != null) {
            conditions.add('Birthday__c = :birthdaySearch');
        }
        if (String.isNotBlank(dayOfBirthSearch)) {
            conditions.add('DAY_IN_MONTH(Birthday__c) = :dayOfBirth');
        }
        if (String.isNotBlank(monthOfBirthSearch)) {
            conditions.add('CALENDAR_MONTH(Birthday__c) = :monthOfBirth');
        }
        if (String.isNotBlank(yearOfBirthSearch)) {
            conditions.add('CALENDAR_YEAR(Birthday__c) = :yearOfBirth');
        }
        if (!conditions.isEmpty()) {
            return ' WHERE ' + String.join(conditions, ' AND ');
        }
        return '';
    }
    /**
    * deleteListStudents
    * 指定された学生IDのリストに基づいて複数の学生を削除するメソッド
    * @param:  List<Id> studentIds - 削除する学生のIDのリスト
    * @return: なし
    * @created: 2026/06/22 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static void deleteListStudents(List<Id> studentIds) {
        try {
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

    /**
    * getInitData
    * 初期データを取得する
    * @param: なし
    * @return: Map<String, Object> - 初期データを含むマップオブジェクト
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<String,Object> getInitData() {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            Map<String, Object> data = new Map<String, Object>();
            data.put('genderOptions', getGenderOptions());
            data.put('classOptions', getClassOptions());
            Map<String, Decimal> customSettingsData = getCustomSettings();
            data.put('CustomSettings', customSettingsData);
            if (customSettingsData != null && customSettingsData.containsKey('MaxRecord')) {
                data.put('studentsList', fetchStudentsList(Integer.valueOf(customSettingsData.get('MaxRecord'))));
            }
            
            return data;
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * getInitDataForSearchCondition
    * 検索条件の初期データを取得する
    * @param: なし
    * @return: Map<String, Object> - 検索条件の初期データを含むマップオブジェクト
    * @created: 2026/06/29 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<String, Object> getInitDataForSearchCondition() {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            Map<String, Object> data = new Map<String, Object>();
            data.put('genderOptions', getGenderOptions());
            data.put('classOptions', getClassOptions());
            return data;
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * getInitDataForSearchResult
    * 検索結果の初期データを取得する
    * @param: なし
    * @return: Map<String, Object> - 検索結果の初期データを含むマップオブジェクト
    * @created: 2026/06/29 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<String, Object> getInitDataForSearchResult() {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            Map<String, Object> data = new Map<String, Object>();
            Map<String, Decimal> customSettingsData = getCustomSettings();
            data.put('CustomSettings', customSettingsData);
            if (customSettingsData != null && customSettingsData.containsKey('MaxRecord')) {
                data.put('studentsList', fetchStudentsList(Integer.valueOf(customSettingsData.get('MaxRecord'))));
            }
            return data;
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    // 2026/07/16 Nguyen Ngoc Quy Add start
    /**
    * throwExceptionForTesting
    * テスト用に例外をスローする
    * @param：   なし
    * @return：  なし
    * @created： 2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    private static void throwExceptionForTesting() {
        if (throwException && Test.isRunningTest()) {
            throw newMessageException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/16 Nguyen Ngoc Quy Add end
}