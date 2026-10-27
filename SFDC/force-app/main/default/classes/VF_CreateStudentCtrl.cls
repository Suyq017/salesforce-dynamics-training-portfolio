/**
* クラス名  ：VF_CreateStudentCtrl
* クラス概要：学生を作成する
* @created ：2026/06/03 Nguyen Ngoc Quy
* @modified：2026/06/11 Nguyen Ngoc Quy
*/
public with sharing class VF_CreateStudentCtrl {
    public Student__c student {get; set;}
    public PageReference pageRef { get; set; }

    // 2026/07/16 Nguyen Ngoc Quy Add start
    @TestVisible 
    private Boolean throwException = false;
    // 2026/07/16 Nguyen Ngoc Quy Add end

    public VF_CreateStudentCtrl() {
        student = new Student__c();
    }

    /**
    * saveStudent
    * フォームから学生を作成する
    * @param：なし
    * @return：なし
    * @created：2026/06/03 Nguyen Ngoc Quy
    * @modified：2026/07/16 Nguyen Ngoc Quy
    */
    public PageReference saveStudent() {
        try {
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            string tempName = '';
            if (String.isNotBlank(student.LastName__c)) {
                tempName += student.LastName__c;
            }
            if (String.isNotBlank(student.FirstName__c)) {
                if (String.isNotBlank(tempName)) {
                    tempName += ' ';
                }
                tempName += student.FirstName__c;
            }
            if (String.isNotBlank(tempName)) {
                student.Name = tempName;
            }
            if (!isValid()) {
                return null;
            }

            insert student;
            return pageRef  = returnToSearchPage();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラー: ' + e.getMessage()));
            return null;
        }
    }

    /**
    * isValid
    * 学生の入力値が有効であることを確認する
    * @param：なし
    * @return：なし
    * @created：2026/06/10 Nguyen Ngoc Quy
    * @modified：2026/06/10 Nguyen Ngoc Quy
    */
    private boolean isValid() {
        boolean isValid = true;
        if (student.LastName__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '姓を入力してください。'));
            isValid = false;
        }
        if (student.FirstName__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '名を入力してください。'));
            isValid = false;
        }
        if (student.Birthday__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '生年月日を入力してください。'));
            isValid = false;
        } else if (!is18OrOlder()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '学生は18歳以上でなければなりません。'));
            isValid = false;
        }
        if (student.Class_look__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'クラスを選択してください。'));
            isValid = false;
        }
        if (student.LearningStatus__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '学習状態を選択してください。'));
            isValid = false;
        }
        if (student.Gender__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '性別を選択してください。'));
            isValid = false;
        }
        return isValid;
    }

    /**
    * is18OrOlder
    * 学生の年齢が18歳以上であることを確認する
    * @param：なし
    * @return：なし
    * @created：2026/06/05 Nguyen Ngoc Quy
    * @modified：2026/07/16 Nguyen Ngoc Quy
    */
    private boolean is18OrOlder() {
        // 2026/07/16 Nguyen Ngoc Quy Delete start
        // if (student.birthday__c == null) {
        //     return false;
        // }
        // 2026/07/16 Nguyen Ngoc Quy Delete end
        if (student.birthday__c.year() > Date.today().year() - 18) {
            return false;
        }
        if (student.birthday__c.year() == Date.today().year() - 18) {
            if (student.birthday__c.month() > Date.today().month()) {
                return false;
            }
            if (student.birthday__c.month() == Date.today().month() 
            && student.birthday__c.day() > Date.today().day()) {
                return false;
            }
        }
        return true;
    }

    /**
     * returnToSearchPage
     * 学生検索ページに戻る
     * @param：なし
     * @return：なし
     * @created：2026/06/05 Nguyen Ngoc Quy
     * @modified：2026/07/16 Nguyen Ngoc Quy
     */
    public PageReference returnToSearchPage() {
        try{
            // 2026/07/16 Nguyen Ngoc Quy Add start
            throwExceptionForTesting();
            // 2026/07/16 Nguyen Ngoc Quy Add end

            PageReference pageRef = Page.VF_SearchStudent;
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
            return null;
        }
    }

    // 2026/07/16 Nguyen Ngoc Quy Add start
    /**
    * throwExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
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
    * @created ：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    class CustomException extends Exception {}
    // 2026/07/16 Nguyen Ngoc Quy Add end
}