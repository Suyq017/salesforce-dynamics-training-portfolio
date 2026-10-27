/**
* クラス名  ：LWC_UpdateStudentCtrl
* クラス概要：学生を更新するためのコントローラー
* @created ：2026/06/22 Nguyen Ngoc Quy
* @modified：2026/07/21 Nguyen Ngoc Quy
*/
public with sharing class LWC_UpdateStudentCtrl {
    // 2026/07/21 Nguyen Ngoc Quy Add Start
    @TestVisible
    private static Boolean throwException = false;
    // 2026/07/21 Nguyen Ngoc Quy Add End

    // 2026/07/14 Nguyen Ngoc Quy Delete Start
    // private static final Integer MIN_AGE = 18;
    // 2026/07/14 Nguyen Ngoc Quy Delete End
    
    /**
    * updateStudent
    * 学生の情報を更新する
    * @param: Student__c student - 更新する学生情報
    * @return: なし
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/09 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static void updateStudent(Student__c student) {
        try {
            if (student == null) {
                throw newMessageException('学生情報が提供されていません。');
            }
            // 2026/07/09 Nguyen Ngoc Quy Delete Start
            // if (String.isBlank(student.Lastname__c)) {
            //     throw newMessageException('姓は必須項目です。');
            // }
            // if (String.isBlank(student.Firstname__c)) {
            //     throw newMessageException('名は必須項目です。');
            // }
            // 2026/07/09 Nguyen Ngoc Quy Delete End

            student.Name = student.Lastname__c + student.Firstname__c;

            // 2026/07/09 Nguyen Ngoc Quy Delete Start
            // if (student.Birthday__c == null) {
            //     throw newMessageException('生年月日は必須項目です。');
            // } else if (getAge(student.Birthday__c) < MIN_AGE) {
            //     throw newMessageException('生年月日は' + MIN_AGE + '歳以上でなければなりません。');
            // }
            // if (String.isBlank(student.Gender__c)) {
            //     throw newMessageException('性別は必須項目です。');
            // }
            // if (String.isBlank(student.Class_look__c)) {
            //     throw newMessageException('クラスは必須項目です。');
            // }
            // if (String.isBlank(student.LearningStatus__c)) {
            //     throw newMessageException('学習状況は必須項目です。');
            // }
            // 2026/07/09 Nguyen Ngoc Quy Delete End
            update student;
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
    * getClassOptions
    * クラスの選択肢を取得する
    * @param: なし
    * @return: List<Class__c> - クラスの選択肢のリスト
    * @created: 2026/06/21 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    private static List<Class__c> getClassOptions() {
        // 2026/07/21 Nguyen Ngoc Quy Modify Start
        // try {
        //     return [
        //         SELECT Id
        //         , Name 
        //         FROM Class__c
        //         ORDER BY Name
        //         ];
        // } 
        // catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
        return [
            SELECT Id
            , Name 
            FROM Class__c
            ORDER BY Name
        ];
        // 2026/07/21 Nguyen Ngoc Quy Modify End
    }

    /**
    * getLearningStatusOptions
    * 学習状況の選択肢を取得する
    * @param: なし
    * @return: Map<String,String> - 学習状況の選択肢のマップ
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    private static Map<String,String> getLearningStatusOptions() {
        // 2026/07/21 Nguyen Ngoc Quy Modify Start
        // try {
        //     Map<String,String> options = new Map<String,String>();
        //     Schema.DescribeFieldResult fieldResult = Student__c.LearningStatus__c.getDescribe();
        //     List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        //     for (Schema.PicklistEntry v : picklistValues) {
        //         options.put(v.getValue(), v.getLabel());
        //     }
        //     return options;
        // } 
        // catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Student__c.LearningStatus__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : picklistValues) {
            options.put(v.getValue(), v.getLabel());
        }
        return options;
        // 2026/07/21 Nguyen Ngoc Quy Modify End
    }

    /**
    * getGenderOptions
    * 性別の選択肢を取得する
    * @param: なし
    * @return: Map<String,String> - 性別の選択肢のマップ
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    private static Map<String,String> getGenderOptions() {
        // 2026/07/21 Nguyen Ngoc Quy Modify Start
        // try {
        //     Map<String,String> options = new Map<String,String>();
        //     Schema.DescribeFieldResult fieldResult = Student__c.Gender__c.getDescribe();
        //     List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        //     for (Schema.PicklistEntry v : picklistValues) {
        //         options.put(v.getValue(), v.getLabel());
        //     }
        //     return options;
        // }
        // catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Student__c.Gender__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : picklistValues) {
            options.put(v.getValue(), v.getLabel());
        }
        return options;
        // 2026/07/21 Nguyen Ngoc Quy Modify End
    }

    // 2026/07/09 Nguyen Ngoc Quy Delete Start
    // /**
    // * メソッド名: getAge
    // * 概要: 生年月日から年齢を計算するヘルパーメソッド
    // * @param: Date birthday - 生年月日
    // * @return: Integer - 計算された年齢
    // * @created: 2026/06/22 Nguyen Ngoc Quy
    // */
    // private static Integer getAge(Date birthday) {
    //     if (birthday == null) {
    //         return null;
    //     }
    //     Date today = Date.today();
    //     Integer age = today.year() - birthday.year();
    //     if (today.month() < birthday.month() || (today.month() == birthday.month() && today.day() < birthday.day())) {
    //         age--;
    //     }
    //     return age;
    // }
    // 2026/07/09 Nguyen Ngoc Quy Delete End

    /**
    * getStudentDetail
    * 学生の詳細情報を取得する
    * @param：String studentId - 学生ID
    * @return：Student__c - 学生情報
    * @created：2026/06/22 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Student__c getStudentDetail(String studentId) {
        try {
            List<Student__c> studentList = new List<Student__c>();
            studentList = [
                SELECT Id
                , StudentCode__c
                , Lastname__c
                , Firstname__c
                , Gender__c
                , Class_look__c
                , Class_look__r.Name
                , Birthday__c
                , LearningStatus__c 
                FROM Student__c 
                WHERE Id = :studentId 
                LIMIT 1
                ];
            if (studentList.isEmpty()) {
                throw newMessageException('学生が見つかりませんでした。');
            }
            return studentList[0];
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * fetchOptions
    * クラス、学習状況、性別の選択肢を取得する
    * @param: なし
    * @return: Map<String, Object> - 選択肢データのマップ
    * @created: 2026/06/22 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<String, Object> fetchOptions(){
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End

            Map<String, Object> options = new Map<String, Object>();
            options.put('classOptions', getClassOptions());
            options.put('learningStatusOptions', getLearningStatusOptions());
            options.put('genderOptions', getGenderOptions());
            return options;
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    // 2026/07/21 Nguyen Ngoc Quy Add Start
    /**
    * throwExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified: 
    */
    private static void throwExceptionForTesting() {
        if (throwException) {
            throw newMessageException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/21 Nguyen Ngoc Quy Add End
}