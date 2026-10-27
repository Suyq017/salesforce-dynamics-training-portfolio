/**
* クラス名   : T01_StudentTriggerHandler
* クラス概要 : Student__cオブジェクトのトリガー
* @created  : 2026/07/01 Nguyen Ngoc Quy
* @modified : 2026/07/16 Nguyen Ngoc Quy
*/
public without sharing class T01_StudentTriggerHandler {

    // 2026/07/16 Nguyen Ngoc Quy Add Start
    @TestVisible
    private static Boolean beforeTriggerThrowException = false;
    @TestVisible
    private static Boolean afterTriggerThrowException = false;
    // 2026/07/16 Nguyen Ngoc Quy Add End

    private static final Integer MIN_AGE = 18;
    private static final String ENROLLED_STATUS = 'Enrolled';
    private static final String LASTNAME_FIELD = 'Lastname__c';
    private static final String FIRSTNAME_FIELD = 'Firstname__c';
    private static final String CLASS_LOOK_FIELD = 'Class_look__c';
    private static final String BIRTHDAY_FIELD = 'Birthday__c';
    private static final String GENDER_FIELD = 'Gender__c';
    
    /**
    * beforeInsertHandle
    * Student__cオブジェクトの挿入前の処理
    * @param: List<Student__c> newList
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    public static void beforeInsertHandle(List<Student__c> newList) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add Start
            beforeTriggerThrowExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add End

            beforeInsertOrUpdateHandle(newList);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * beforeUpdateHandle
    * Student__cオブジェクトの更新前の処理
    * @param: List<Student__c> newList
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/01 Nguyen Ngoc Quy
    */
    public static void beforeUpdateHandle(List<Student__c> newList) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add Start
            beforeTriggerThrowExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add End

            beforeInsertOrUpdateHandle(newList);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * beforeDeleteHandle
    * Student__cオブジェクトの削除前の処理
    * @param: Map<Id, Student__c> oldMap
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    public static void beforeDeleteHandle(Map<Id, Student__c> oldMap) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add Start
            beforeTriggerThrowExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add End

            List<SubjectScore__c> listSubjectScores = getSubjectScoreList(oldMap.keySet());
            if (!listSubjectScores.isEmpty()) {
                delete listSubjectScores;
            }
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * afterInsertHandle
    * Student__cオブジェクトの挿入後の処理
    * @param: List<Student__c> newList
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    public static void afterInsertHandle(List<Student__c> newList) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add Start
            afterTriggerThrowExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add End

            Set<Id> setClassIds = getSetClassIdsFromStudentList(newList, new List<Student__c>());
            recountAndUpdateClassNumberOfStudent(setClassIds);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * afterUpdateHandle
    * Student__cオブジェクトの更新後の処理
    * @param: List<Student__c> newList, List<Student__c> oldList
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    public static void afterUpdateHandle(List<Student__c> newList, List<Student__c> oldList) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add Start
            afterTriggerThrowExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add End

            Set<Id> setClassIds = getSetClassIdsFromStudentList(newList, oldList);
            recountAndUpdateClassNumberOfStudent(setClassIds);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * afterDeleteHandle
    * Student__cオブジェクトの削除後の処理
    * @param: List<Student__c> oldList
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    public static void afterDeleteHandle(List<Student__c> oldList) {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add Start
            afterTriggerThrowExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add End

            Set<Id> setClassIds = getSetClassIdsFromStudentList(new List<Student__c>(), oldList);
            recountAndUpdateClassNumberOfStudent(setClassIds);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * recountAndUpdateClassNumberOfStudent
    * Class__cレコードのIDのセットを取得し、学生数をカウントして更新する
    * @param: Set<Id> setClassIds - Class__cレコードのIDのセット
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/16 Nguyen Ngoc Quy
    */
    private static void recountAndUpdateClassNumberOfStudent(Set<Id> setClassIds) {
        // 2026/07/16 Nguyen Ngoc Quy Delete Start
        // // if the set of Class__c Ids is null or empty, return
        // if (setClassIds == null || setClassIds.isEmpty()) {
        //     return;
        // }

        // // get the map of Class__c Ids to the number of students in each class
        // 2026/07/16 Nguyen Ngoc Quy Delete End

        Map<Id, Integer> mapClassCount = getClassCountMap(setClassIds);
        // 2026/07/16 Nguyen Ngoc Quy Delete Start
        // if (mapClassCount == null) {
        //     return;
        // }
        // 2026/07/16 Nguyen Ngoc Quy Delete End

        // create a list of Class__c records to update the NumberOfStudent__c field
        List<Class__c> listClassRecords = new List<Class__c>();
        for (Id classId : setClassIds) {
            Class__c classRecord = new Class__c(Id = classId);
            classRecord.NumberOfStudent__c = mapClassCount.get(classRecord.Id);
            if (classRecord.NumberOfStudent__c == null) {
                classRecord.NumberOfStudent__c = 0;
            }
            listClassRecords.add(classRecord);
        }
        if (!listClassRecords.isEmpty()) {
            update listClassRecords;
        }
    }

    /**
    * getSetClassIdsFromStudentList
    * Student__cオブジェクトのリストからClass__cレコードのIDのセットを取得する
    * @param: List<Student__c> list1, List<Student__c> list2 - Student__cオブジェクトのリスト
    * @return: Set<Id> - Class__cレコードのIDのセット
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    private static Set<Id> getSetClassIdsFromStudentList(List<Student__c> list1, List<Student__c> list2) {
        Set<Id> setClassIds = new Set<Id>();
        if (list1 != null && !list1.isEmpty()) {
            for (Student__c student : list1) {
                setClassIds.add(student.Class_look__c);
            }
        }
        if (list2 != null && !list2.isEmpty()) {
            for (Student__c student : list2) {
                setClassIds.add(student.Class_look__c);
            }
        }
        return setClassIds;
    }

    /**
    * beforeInsertOrUpdateHandle
    * Student__cオブジェクトの挿入または更新前の処理
    * @param: List<Student__c> newList 
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    private static void beforeInsertOrUpdateHandle(List<Student__c> newList) {
        for (Student__c student : newList) {
            if (student.Birthday__c != null){
                if (!isAgeValid(student.Birthday__c)) {
                    student.addError('学生の年齢が無効です。有効な年齢は18歳以上です。');
                }
            }
            
            List<String> listErrorMessage = new List<String>();
            if (String.isBlank(student.Lastname__c)) {
                listErrorMessage.add(LASTNAME_FIELD);
            }
            if (String.isBlank(student.Firstname__c)) {
                listErrorMessage.add(FIRSTNAME_FIELD);
            }
            if (String.isBlank(student.Class_look__c)) {
                listErrorMessage.add(CLASS_LOOK_FIELD);
            }
            if (student.Birthday__c == null) {
                listErrorMessage.add(BIRTHDAY_FIELD);
            }
            if (String.isBlank(student.Gender__c)) {
                listErrorMessage.add(GENDER_FIELD);
            }
            if (listErrorMessage != null && !listErrorMessage.isEmpty()) {
                student.addError('値を入力してください:' + String.join(listErrorMessage, ', '));
            }
        }
    }

    /**
    * getClassCountMap
    * Class__cレコードのIDのセットから、学生数をカウントしてマップを作成する
    * @param: Set<Id> setClassIds - Class__cレコードのIDのセット
    * @return: Map<Id, Integer> - Class__cレコードのIDと学生数のマップ
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    private static Map<Id, Integer> getClassCountMap(Set<Id> setClassIds) {
        List<AggregateResult> listResults = [
            SELECT Class_look__c
                , COUNT(Id) numberOfEnrolledStudents
            FROM Student__c
            WHERE Class_look__c IN :setClassIds AND LearningStatus__c = :ENROLLED_STATUS
            GROUP BY Class_look__c
        ];

        Map<Id, Integer> mapClassCount = new Map<Id, Integer>();
        for (AggregateResult result : listResults) {
            Id classId = (Id) result.get('Class_look__c');
            Integer numberOfEnrolledStudents = (Integer) result.get('numberOfEnrolledStudents');
            mapClassCount.put(classId, numberOfEnrolledStudents);
        }
        return mapClassCount;
    }

    /**
    * isAgeValid
    * 年齢がMIN_AGE歳以上であることを確認する
    * @param: Date birthday - 誕生日
    * @return: Boolean - MIN_AGE歳以上であればtrue、そうでなければfalse
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    private static Boolean isAgeValid(Date birthday) {
        if (birthday.addYears(MIN_AGE) > Date.today()) {
            return false;
        }
        return true;
    }

    /**
    * getSubjectScoreList
    * Student__cレコードのIDのセットから、関連するSubjectScore__cレコードを取得する
    * @param: Set<Id> setStudentIds - Student__cレコードのIDのセット
    * @return: List<SubjectScore__c> - SubjectScore__cレコードのリスト
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    private static List<SubjectScore__c> getSubjectScoreList(Set<Id> setStudentIds) {
        List<SubjectScore__c> listSubjectScores = [
            SELECT Id
            FROM SubjectScore__c
            WHERE Student_look__c IN :setStudentIds
        ];
        return listSubjectScores;
    }

    // 2026/07/16 Nguyen Ngoc Quy Add start
    /**
    * beforeTriggerThrowExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    private static void beforeTriggerThrowExceptionForTesting() {
        if (beforeTriggerThrowException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * afterTriggerThrowExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created： 2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    private static void afterTriggerThrowExceptionForTesting() {
        if (afterTriggerThrowException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/16 Nguyen Ngoc Quy Add end

    /**
    * クラス名   : CustomException
    * クラス概要 : カスタム例外クラス
    * @created  : 2026/07/01 Nguyen Ngoc Quy
    * @modified : 
    */
    private class CustomException extends Exception {}
}