/**
* クラス名   ：VF_CreateStudentCtrlTest
* クラス概要 ：VF_CreateStudentCtrlクラスのテストクラス
* @created  ：2026/07/16 Nguyen Ngoc Quy
* @modified ：
*/
@isTest
private class VF_CreateStudentCtrlTest {
    private static final Integer UNDERAGE_LIMIT = 18;

    /**
    * testSaveStudent_Success
    * saveStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            controller.student = testStudent;

            Test.startTest();
                controller.saveStudent();
            Test.stopTest();

            Student__c insertedStudent = getStudentById(testStudent.Id);
            Assert.isNotNull(insertedStudent, 'The student record should be inserted successfully.');
            Assert.areEqual(insertedStudent.Id, testStudent.Id, 'The returned student ID should match the test student ID.');
            Assert.areEqual(insertedStudent.Name, testStudent.Name, 'The returned student Name should match the test student Name.');
            Assert.areEqual(insertedStudent.LastName__c, testStudent.LastName__c, 'The returned student LastName should match the test student LastName.');
            Assert.areEqual(insertedStudent.FirstName__c, testStudent.FirstName__c, 'The returned student FirstName should match the test student FirstName.');
            Assert.areEqual(insertedStudent.BirthDay__c, testStudent.BirthDay__c, 'The returned student BirthDay should match the test student BirthDay.');
            Assert.areEqual(insertedStudent.Gender__c, testStudent.Gender__c, 'The returned student Gender should match the test student Gender.');
            Assert.areEqual(insertedStudent.Class_look__c, testStudent.Class_look__c, 'The returned student Class_look should match the test student Class_look.');
            Assert.areEqual(insertedStudent.LearningStatus__c, testStudent.LearningStatus__c, 'The returned student LearningStatus should match the test student LearningStatus.');
            Assert.areEqual(Page.VF_SearchStudent.getUrl(), controller.pageRef.getUrl(), 'The returned PageReference URL should match the expected search page URL.');
        }
    }

    /**
    * testSaveStudent_Exception
    * saveStudentメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            // Set the flag to throw an exception
            controller.throwException = true; 

            Test.startTest();
                controller.saveStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[0].getSummary().contains('テスト用の例外が発生しました。'), 'The error message should contain the expected exception message.');
        }
    }

    /**
    * testSaveStudent_InvalidInput
    * saveStudentメソッドの入力値検証テスト（姓が空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_InvalidInput() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();

            Test.startTest();
                controller.saveStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[0].getSummary().contains('姓を入力してください。'), 'The error message should indicate that the last name is required.');
        }
    }

    /**
    * testSaveStudent_Underage
    * saveStudentメソッドの入力値検証テスト（18歳未満の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_Underage() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            controller.student = testStudent;
            // Set the birthday to make the student underage
            controller.student.BirthDay__c = Date.today(); 

            Test.startTest();
                controller.saveStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[0].getSummary().contains('学生は18歳以上でなければなりません。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testSaveStudent_UnderagWithSameYear
    * saveStudentメソッドの入力値検証テスト（18歳未満で同じ年の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_UnderagWithSameYear() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            controller.student = testStudent;
            controller.student.BirthDay__c = Date.today().addYears(-UNDERAGE_LIMIT).addMonths(1);

            Test.startTest();
                controller.saveStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[0].getSummary().contains('学生は18歳以上でなければなりません。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testSaveStudent_UnderageWithSameYearAndMonth
    * saveStudentメソッドの入力値検証テスト（18歳未満で同じ年・月の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSaveStudent_UnderageWithSameYearAndMonth() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            controller.student = testStudent;
            // Set the birthday to make the student underage
            controller.student.BirthDay__c = Date.today().addYears(-UNDERAGE_LIMIT).addDays(1);

            Test.startTest();
                controller.saveStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[0].getSummary().contains('学生は18歳以上でなければなりません。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testReturnToSearchPage_Success
    * returnToSearchPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testReturnToSearchPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.setCurrentPageReference(new PageReference(Page.VF_CreateStudent.getUrl()));
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();

            Test.startTest();
                PageReference resultPageRef = controller.returnToSearchPage();
            Test.stopTest();

            Assert.areEqual(Page.VF_SearchStudent.getUrl(), resultPageRef.getUrl(), 'The returned PageReference URL should match the expected search page URL.');
        }
    }

    /**
    * testReturnToSearchPage_Exception
    * returnToSearchPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testReturnToSearchPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            // Set the flag to throw an exception
            controller.throwException = true; 

            Test.startTest();
                PageReference resultPageRef = controller.returnToSearchPage();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity(), 'The message severity should be ERROR.');
            Assert.isTrue(ApexPages.getMessages()[0].getSummary().contains('テスト用の例外が発生しました。'), 'The error message should contain the expected exception message.');
        }
    }

    /**
    * createTestUser
    * テスト用のユーザーを作成する
    * @param：なし
    * @return：User - 作成されたユーザー
    * @created：2026/07/16 Nguyen Ngoc Quy
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
    * createTestStudent
    * テスト用の学生レコードを作成する
    * @param：なし
    * @return：Student__c - 作成された学生レコード
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c createTestStudent() {
        Class__c classRecord = new Class__c();
        insert classRecord;

        Student__c studentTest = new Student__c(
            Lastname__c = 'Test'
            , FirstName__c = 'Student'
            , BirthDay__c = Date.newInstance(2000, 1, 1)
            , Gender__c = 'Male'
            , Class_look__c = classRecord.Id
            , LearningStatus__c = 'Enrolled'
        );
        return studentTest;
    }

    /**
    * getStudentById
    * 指定されたIDの学生レコードを取得する
    * @param：なし
    * @return：Student__c - 取得された学生レコード
    * @created：2026/07/16 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c getStudentById(Id studentId) {
        return [
            SELECT Id
            , Name
            , LastName__c
            , FirstName__c
            , Birthday__c
            , Gender__c
            , Class_look__r.Name
            , LearningStatus__c
            , StudentCode__c FROM Student__c 
            WHERE Id = :studentId
            LIMIT 1
        ];
    }
}