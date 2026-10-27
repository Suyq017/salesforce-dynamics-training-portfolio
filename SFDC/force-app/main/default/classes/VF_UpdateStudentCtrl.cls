/**
* クラス名  ：UpdateStudentCtrl
* クラス概要：フォームから学生を更新する
* @created ：2026/06/08 Nguyen Ngoc Quy
* @modified：2026/07/20 Nguyen Ngoc Quy
*/
public with sharing class VF_UpdateStudentCtrl {
    public List<Student__c> student {get; set;}
    public PageReference pageRef { get; set; }
    public String id { get; set; }

    // 2026/07/20 Nguyen Ngoc Quy Add start
    @TestVisible 
    private Boolean throwException = false;
    // 2026/07/20 Nguyen Ngoc Quy Add end

    public VF_UpdateStudentCtrl() {
        student = new List<Student__c>();
        student = getStudent();     
    }

    /**
    * getStudent
    * URLパラメータから学生IDを取得し、学生の詳細情報を取得する
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/20 Nguyen Ngoc Quy
    */
    public List<Student__c> getStudent(){
        try{
            // 2026/07/20 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

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
    * @modified：2026/07/20 Nguyen Ngoc Quy
    */
    private List<Student__c> queryStudent() {
        // 2026/07/20 Nguyen Ngoc Quy Add start 
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
        // 2026/07/20 Nguyen Ngoc Quy Add end
    }

    /**
    * updateStudent
    * フォームから学生を更新する
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/20 Nguyen Ngoc Quy
    */
    public PageReference updateStudent() {
        try {
            // 2026/07/20 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

            string tempName = '';
            if (String.isNotBlank(student[0].LastName__c)) {
                tempName += student[0].LastName__c;
            }
            if (String.isNotBlank(student[0].FirstName__c)) {
                if (String.isNotBlank(tempName)) {
                    tempName += ' ';
                }
                tempName += student[0].FirstName__c;
            }
            if (String.isNotBlank(tempName)) {
                student[0].Name = tempName;
            }

            boolean isValid = is18OrOlder();
            if (!isValid) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '学生の年齢が無効です。有効な年齢は18歳以上です。'));
                return null;
            }

            update student[0];
            pageRef = returnToSearchPage();
            return pageRef;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラー: ' + e.getMessage()));
            return null;
        }
    }

    /**
    * is18OrOlder
    * 学生の年齢が18歳以上であることを確認する
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/06/08 Nguyen Ngoc Quy
    */
    private boolean is18OrOlder() {
        if (student[0].Birthday__c == null) {
            return false;
        }
        if (student[0].Birthday__c.year() > Date.today().year() - 18) {
            return false;
        }
        if (student[0].Birthday__c.year() == Date.today().year() - 18) {
            if (student[0].Birthday__c.month() > Date.today().month()) {
                return false;
            }
            if (student[0].Birthday__c.month() == Date.today().month() 
            && student[0].Birthday__c.day() > Date.today().day()) {
                return false;
            }
        }
        return true;
    }
	
    /**
    * returnToSearchPage
    * 学生の検索ページに戻る
    * @param：なし
    * @return：なし
    * @created：2026/06/08 Nguyen Ngoc Quy
    * @modified：2026/07/20 Nguyen Ngoc Quy
    */
    public PageReference returnToSearchPage() {
        try{
            // 2026/07/20 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

            pageRef = Page.VF_SearchStudent;
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラー: ' + e.getMessage()));
            return null;
        }
    }

    // 2026/07/20 Nguyen Ngoc Quy Add start
    /**
    * throwExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
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
    * @created ：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    class CustomException extends Exception {}
    // 2026/07/20 Nguyen Ngoc Quy Add end
    
}