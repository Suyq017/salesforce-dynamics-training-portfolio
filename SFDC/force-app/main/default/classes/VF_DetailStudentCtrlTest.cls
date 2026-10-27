/**
* クラス名   ：VF_DetailStudentCtrlTest
* クラス概要 ：VF_DetailStudentCtrlクラスのテストクラス
* @created  ：2026/07/15 Nguyen Ngoc Quy
* @modified ：
*/
@isTest
private class VF_DetailStudentCtrlTest {
    
    /**
    * testGetStudent_Success
    * getStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            PageReference pageRef = Page.VF_DetailStudent;
            pageRef.getParameters().put('id', studentTest.Id);
            Test.setCurrentPageReference(pageRef);

            Test.startTest();
                VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'The Student list should contain exactly one student record.');
            Assert.areEqual(studentTest.Id, controller.student[0].Id, 'The returned student ID should match the test student ID.');
            Assert.areEqual(studentTest.Name, controller.student[0].Name, 'The returned student Name should match the test student Name.');
            Assert.areEqual(studentTest.LastName__c, controller.student[0].LastName__c, 'The returned student LastName should match the test student LastName.');
            Assert.areEqual(studentTest.FirstName__c, controller.student[0].FirstName__c, 'The returned student FirstName should match the test student FirstName.');
            Assert.areEqual(studentTest.BirthDay__c, controller.student[0].BirthDay__c, 'The returned student BirthDay should match the test student BirthDay.');
            Assert.areEqual(studentTest.Gender__c, controller.student[0].Gender__c, 'The returned student Gender should match the test student Gender.');
            Assert.areEqual(studentTest.Class_look__c, controller.student[0].Class_look__c, 'The returned student Class_look should match the test student Class_look.');
            Assert.areEqual(studentTest.LearningStatus__c, controller.student[0].LearningStatus__c, 'The returned student LearningStatus should match the test student LearningStatus.');
            Assert.areEqual(studentTest.StudentCode__c, controller.student[0].StudentCode__c, 'The returned student StudentCode should match the test student StudentCode.');
        }
    }

    /**
    * testGetStudent_MissingId
    * getStudentメソッドの異常系テスト（idパラメータが欠落している場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_MissingId() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'The Student list should contain exactly one student record.');
            Assert.isNull(controller.student[0].Id, 'The returned student ID should be null.');
            Assert.isNull(controller.student[0].Name, 'The returned student Name should be null.');
            Assert.isNull(controller.student[0].LastName__c, 'The returned student LastName should be null.');
            Assert.isNull(controller.student[0].FirstName__c, 'The returned student FirstName should be null.');
            Assert.isNull(controller.student[0].BirthDay__c, 'The returned student BirthDay should be null.');
            Assert.isNull(controller.student[0].Gender__c, 'The returned student Gender should be null.');
            Assert.isNull(controller.student[0].Class_look__c, 'The returned student Class_look should be null.');
            Assert.isNull(controller.student[0].LearningStatus__c, 'The returned student LearningStatus should be null.');
            Assert.isNull(controller.student[0].StudentCode__c, 'The returned student StudentCode should be null.');
        }
    }

    /**
    * testGetStudent_MissingStudent
    * getStudentメソッドの異常系テスト（指定されたIDに対応する学生が存在しない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_MissingStudent() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            delete studentTest;
            PageReference pageRef = Page.VF_DetailStudent;
            pageRef.getParameters().put('id', studentTest.Id);
            Test.setCurrentPageReference(pageRef);

            Test.startTest();
                VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'The Student list should contain exactly one student record.');
            Assert.isNull(controller.student[0].Id, 'The returned student ID should be null.');
            Assert.isNull(controller.student[0].Name, 'The returned student Name should be null.');
            Assert.isNull(controller.student[0].LastName__c, 'The returned student LastName should be null.');
            Assert.isNull(controller.student[0].FirstName__c, 'The returned student FirstName should be null.');
            Assert.isNull(controller.student[0].BirthDay__c, 'The returned student BirthDay should be null.');
            Assert.isNull(controller.student[0].Gender__c, 'The returned student Gender should be null.');
            Assert.isNull(controller.student[0].Class_look__c, 'The returned student Class_look should be null.');
            Assert.isNull(controller.student[0].LearningStatus__c, 'The returned student LearningStatus should be null.');
            Assert.isNull(controller.student[0].StudentCode__c, 'The returned student StudentCode should be null.');
        }
    }

    /**
    * testGetStudent_Exception
    * getStudentメソッドの異常系テスト（例外が発生する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
            controller.throwException = true; 

            Test.startTest();
                controller.getStudent();
            Test.stopTest();

            List<ApexPages.Message> messages = ApexPages.getMessages();
            Assert.isTrue(!controller.student.isEmpty(), 'The Student list should contain exactly two records.');
            Assert.isNull(controller.student[1].Id, 'The returned student should be an empty record.');
            Assert.areEqual(2, messages.size(), 'Two error messages should be added.');
            Assert.areEqual(ApexPages.Severity.ERROR, messages[1].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(messages[1].getSummary().contains('テスト用の例外が発生しました。'),'The error message should contain the expected exception message.' );
        }
    }

    /**
    * testReturnToSearchPage_Success
    * returnToSearchPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testReturnToSearchPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.setCurrentPageReference(new PageReference(Page.VF_DetailStudent.getUrl()));
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();

            Test.startTest();
                PageReference resultPageRef = controller.returnToSearchPage();
            Test.stopTest();

            Assert.areEqual(Page.VF_SearchStudent.getUrl(), resultPageRef.getUrl(), 'The returned PageReference URL should match the expected search page URL.');
        }
    }

    /**
    * testReturnToSearchPage_Exception
    * returnToSearchPageメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testReturnToSearchPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
            controller.throwException = true; 

            Test.startTest();
                PageReference resultPageRef = controller.returnToSearchPage();
            Test.stopTest();

            Assert.isNull(resultPageRef, 'The returned PageReference should be null.');
            Assert.areEqual(2, ApexPages.getMessages().size(), 'Two error messages should be added.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[1].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[1].getSummary().contains('テスト用の例外が発生しました。'), 'The error message should contain the expected exception message.');
        }
    }

    /**
    * createTestUser
    * テスト用のユーザーを作成する
    * @param：なし
    * @return：User - 作成されたユーザー
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    private static User createTestUser() {
        Profile profile = [
            SELECT Id 
            FROM Profile 
            WHERE Name='Standard User' 
            LIMIT 1
        ];

        String uniqueName = UserInfo.getOrganizationId() + 
        Datetime.now().format('yyyyMMddHHmmssSSS') +
        Integer.valueOf(Math.rint(Math.random() * (2000000 - 1)));

        User userTest = new User(
            Alias = 'standt'
            , Email= uniqueName + '@keizu.co.jp'
            , EmailEncodingKey='UTF-8'
            , FirstName= uniqueName.substring(29, 34)
            , LastName= uniqueName.substring(30, 35)
            , LanguageLocaleKey='en_US'
            , LocaleSidKey='en_US'
            , ProfileId = profile.Id
            , TimeZoneSidKey='America/Los_Angeles'
            , UserName= uniqueName + '@ke1zu.co.jp'
        );
        insert userTest;
        return userTest;
    }

    /**
    * createAndInsertTestStudent
    * テスト用の学生レコードを作成する
    * @param：なし
    * @return：Student__c - 作成された学生レコード
    * @created：2026/07/15 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c createAndInsertTestStudent() {
        Class__c classRecord = new Class__c();
        insert classRecord;

        Student__c studentTest = new Student__c(Name = 'Test Student'
        , Lastname__c = 'Test'
        , FirstName__c = 'Student'
        , BirthDay__c = Date.newInstance(2000, 1, 1)
        , Gender__c = 'Male'
        , Class_look__c = classRecord.Id
        , LearningStatus__c = 'Enrolled');
        insert studentTest;

        Student__c returnStudent = [
            SELECT Id
            , Name
            , LastName__c
            , FirstName__c
            , Birthday__c
            , Gender__c
            , Class_look__c
            , LearningStatus__c
            , StudentCode__c FROM Student__c WHERE Id = :studentTest.Id LIMIT 1
        ];   
        return returnStudent;
    }
}