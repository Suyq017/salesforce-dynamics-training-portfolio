/**
* クラス名   ：CMP_DetailStudentCtrl
* クラス概要 ：学生の詳細情報を取得するコントローラークラス
* @created  ：2026/06/11 Nguyen Ngoc Quy
* @modified ：2026/06/15 Nguyen Ngoc Quy
*/
public with sharing class CMP_DetailStudentCtrl {
    /**
    * getStudent
    * 学生の詳細情報を取得するメソッド
    * @param: id 学生のID
    * @return: 学生の詳細情報を含むStudent__cオブジェクト
    * @created: 2026/06/11 Nguyen Ngoc Quy
    * @modified: 2026/06/16 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Student__c getStudent(string id){
        try {
            if (String.isBlank(id)) {
                throw newMessageException('学生IDが提供されていません。');
            }
            List<Student__c> student = [
                SELECT StudentCode__c
                    , FirstName__c
                    , LastName__c
                    , Birthday__c
                    , Gender__c
                    , Class_look__c
                    , Class_look__r.Name
                    , LearningStatus__c
                FROM Student__c
                WHERE Id = :id
                LIMIT 1
            ];
            if (student.isEmpty()){
                throw newMessageException('学生が見つかりませんでした。');
            }

            return student[0];
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