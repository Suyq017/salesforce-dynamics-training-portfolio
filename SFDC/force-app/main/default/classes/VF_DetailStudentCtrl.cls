/**
* クラス名  ：VF_DetailStudentCtrl
* クラス概要：学生詳細情報を表示する
* @created ：2026/06/03 Nguyen Ngoc Quy
* @modified：2026/07/15 Nguyen Ngoc Quy
*/
public with sharing class VF_DetailStudentCtrl {
    public List<Student__c> student { get; set; }
    public string id { get; set; }

    // 2026/07/15 Nguyen Ngoc Quy Delete start
    // public pageReference pageRef { get; set; }
    // 2026/07/15 Nguyen Ngoc Quy Delete end

    // 2026/07/15 Nguyen Ngoc Quy Add start
    @TestVisible 
    private Boolean throwException = false;
    // 2026/07/15 Nguyen Ngoc Quy Add end

    public VF_DetailStudentCtrl() {
        student = new List<Student__c>();
        student = getStudent();
    }

    /**
    * getStudent
    * 学生の詳細情報を取得する
    * @param：なし
    * @return：なし
    * @created：2026/06/03 Nguyen Ngoc Quy
    * @modified：2026/07/15 Nguyen Ngoc Quy
    */
    public List<Student__c> getStudent() {
        try{
            // 2026/07/15 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/15 Nguyen Ngoc Quy Add end
            id = ApexPages.currentPage().getParameters().get('id');
            if (string.isBlank(id)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '学生IDが指定されていません。'));
                student.add(new Student__c());
                return student;
            }
            student = queryStudent();
            if (student.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '学生が見つかりませんでした。'));
                student.add(new Student__c());
            }
            return student;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラー: ' + e.getMessage()));
            student.add(new Student__c());
            return student;
        }
    }
    
    /**
    * queryStudent
    * 学生の詳細情報をクエリする
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/15 Nguyen Ngoc Quy
    */
    private List<Student__c> queryStudent() {
        // 2026/07/15 Nguyen Ngoc Quy Modify start
        // try{
        //     List<Student__c> student = new List<Student__c>();
        //     student = [SELECT Id
        //     , Name
        //     , LastName__c
        //     , FirstName__c
        //     , Birthday__c
        //     , Gender__c
        //     , Class_look__r.Name
        //     , LearningStatus__c
        //     , StudentCode__c FROM Student__c WHERE Id = :id LIMIT 1];
        //     return student;
        // }
        // catch(Exception e){
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'クエリエラー: ' + e.getMessage()));
        //     return new List<Student__c>();
        // }
        List<Student__c> student = new List<Student__c>();
        student = [
            SELECT Id
            , Name
            , LastName__c
            , FirstName__c
            , Birthday__c
            , Gender__c
            , Class_look__r.Name
            , LearningStatus__c
            , StudentCode__c 
            FROM Student__c 
            WHERE Id = :id 
            LIMIT 1
        ];
        return student;
        // 2026/07/15 Nguyen Ngoc Quy Modify end
    }

    /**
    * returnToSearchPage
    * 検索ページに戻る
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/15 Nguyen Ngoc Quy
    */
    public PageReference returnToSearchPage() {
        try{
            // 2026/07/15 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/15 Nguyen Ngoc Quy Add end
            PageReference pageRef = Page.VF_SearchStudent;
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
            return null;
        }
    }

    // 2026/07/15 Nguyen Ngoc Quy Add start
    /**
    * throwExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    private void throwExceptionForTesting() {
        if (throwException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }

    /**
    * クラス名  ：CustomException
    * クラス概要：テスト用のカスタム例外クラス
    * @created ：2026/07/15 Nguyen Ngoc Quy
    * @modified： 
    */
    class CustomException extends Exception {}
    // 2026/07/15 Nguyen Ngoc Quy Add end

}