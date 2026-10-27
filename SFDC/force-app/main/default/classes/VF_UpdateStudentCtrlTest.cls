/**
* クラス名   ：VF_UpdateStudentCtrlTest
* クラス概要 ：VF_UpdateStudentCtrlクラスのテストクラス
* @created  ：2026/07/20 Nguyen Ngoc Quy
* @modified ：
*/
@isTest
private class VF_UpdateStudentCtrlTest {
    /**
    * testGetStudent_Success
    * getStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c studentTest = createAndInsertTestStudent();
            PageReference pageRef = Page.VF_UpdateStudent;
            pageRef.getParameters().put('id', studentTest.Id);
            Test.setCurrentPageReference(pageRef);

            Test.startTest();
                VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
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
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_MissingId() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.startTest();
                VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
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
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_MissingStudent() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            PageReference pageRef = Page.VF_UpdateStudent;
            // Unknown ID that does not exist in the database
            pageRef.getParameters().put('id', 'a');
            Test.setCurrentPageReference(pageRef);

            Test.startTest();
                VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
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
    * getStudentメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetStudent_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            PageReference pageRef = Page.VF_UpdateStudent;
            pageRef.getParameters().put('id', 'a');
            Test.setCurrentPageReference(pageRef);
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                try {
                    controller.getStudent();
                } 
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should match the expected message.');
                }
            Test.stopTest();
        }
    }

    /**
    * testupdateStudent_Success
    * updateStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testupdateStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createAndInsertTestStudent();
            PageReference pageRef = Page.VF_UpdateStudent;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPageReference(pageRef);
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.student[0].BirthDay__c = Date.newInstance(2002, 1, 1);
            controller.student[0].Firstname__c = 'UpdatedFirstName';
            controller.student[0].Lastname__c = 'UpdatedLastName';

            Test.startTest();
                controller.updateStudent();
            Test.stopTest();

            Student__c student = getStudentById(testStudent.Id);
            Assert.areEqual(student.Id, testStudent.Id, 'The returned student ID should match the test student ID.');
            Assert.areNotEqual(student.Name, testStudent.Name, 'The returned student Name should match the test student Name.');
            Assert.areNotEqual(student.Lastname__c, testStudent.Lastname__c, 'The returned student LastName should match the test student LastName.');
            Assert.areNotEqual(student.Firstname__c, testStudent.Firstname__c, 'The returned student FirstName should match the test student FirstName.');
            Assert.areNotEqual(student.BirthDay__c, testStudent.BirthDay__c, 'The returned student BirthDay should match the test student BirthDay.');
            Assert.areEqual(student.Gender__c, testStudent.Gender__c, 'The returned student Gender should match the test student Gender.');
            Assert.areEqual(student.Class_look__c, testStudent.Class_look__c, 'The returned student Class_look should match the test student Class_look.');
            Assert.areEqual(student.LearningStatus__c, testStudent.LearningStatus__c, 'The returned student LearningStatus should match the test student LearningStatus.');
        }
    }

    /**
    * testUpdateStudent_Underage
    * updateStudentメソッドの入力値検証テスト（18歳未満の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_Underage() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createAndInsertTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_UpdateStudent.getUrl()));
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.student.add(testStudent);
            controller.student[0].BirthDay__c = Date.today(); 

            Test.startTest();
                controller.updateStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.WARNING, ApexPages.getMessages()[1].getSeverity(), 'The message severity should be WARNING.');
            Assert.isTrue(ApexPages.getMessages()[1].getSummary().contains('学生の年齢が無効です。有効な年齢は18歳以上です。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testUpdateStudent_UnderageWithSameYear
    * updateStudentメソッドの入力値検証テスト（18歳未満で同じ年の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_UnderageWithSameYear() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createAndInsertTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_UpdateStudent.getUrl()));
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.student.add(testStudent);
            controller.student[0].BirthDay__c = Date.today().addYears(-18).addMonths(1);

            Test.startTest();
                controller.updateStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.WARNING, ApexPages.getMessages()[1].getSeverity(), 'The message severity should be WARNING.');
            Assert.isTrue(ApexPages.getMessages()[1].getSummary().contains('学生の年齢が無効です。有効な年齢は18歳以上です。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testUpdateStudent_UnderageWithSameYearAndMonth
    * updateStudentメソッドの入力値検証テスト（18歳未満で同じ年・月の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_UnderageWithSameYearAndMonth() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createAndInsertTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_UpdateStudent.getUrl()));
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.student.add(testStudent);
            controller.student[0].BirthDay__c = Date.today().addYears(-18).addDays(1); 

            Test.startTest();
                controller.updateStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.WARNING, ApexPages.getMessages()[1].getSeverity(), 'The message severity should be WARNING.');
            Assert.isTrue(ApexPages.getMessages()[1].getSummary().contains('学生の年齢が無効です。有効な年齢は18歳以上です。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testUpdateStudent_NullBirthday
    * updateStudentメソッドの入力値検証テスト（生年月日がnullの場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_NullBirthday() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createAndInsertTestStudent();
            Test.setCurrentPageReference(new PageReference(Page.VF_UpdateStudent.getUrl()));
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.student.add(testStudent);
            controller.student[0].BirthDay__c = null;

            Test.startTest();
                controller.updateStudent();
            Test.stopTest();

            Assert.isTrue(!ApexPages.getMessages().isEmpty(), 'An error message should be added to the page messages.');
            Assert.areEqual(ApexPages.Severity.WARNING, ApexPages.getMessages()[1].getSeverity(), 'The message severity should be WARNING.');
            Assert.isTrue(ApexPages.getMessages()[1].getSummary().contains('学生の年齢が無効です。有効な年齢は18歳以上です。'), 'The error message should indicate that the student must be at least 18 years old.');
        }
    }

    /**
    * testUpdateStudent_Exception
    * updateStudentメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testUpdateStudent_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            PageReference pageRef = Page.VF_UpdateStudent;
            pageRef.getParameters().put('id', 'a');
            Test.setCurrentPageReference(pageRef);
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                try {
                    controller.updateStudent();
                } 
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should match the expected message.');
                }
            Test.stopTest();
        }
    }

    /**
    * testReturnToSearchPage_Success
    * returnToSearchPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testReturnToSearchPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Test.setCurrentPageReference(new PageReference(Page.VF_UpdateStudent.getUrl()));
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();

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
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testReturnToSearchPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            PageReference pageRef = Page.VF_UpdateStudent;
            pageRef.getParameters().put('id', 'a');
            Test.setCurrentPageReference(pageRef);
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                try {
                    controller.returnToSearchPage();
                } 
                catch (Exception e) {
                    Assert.areEqual('テスト用の例外が発生しました。', e.getMessage(), 'The exception message should match the expected message.');
                }
            Test.stopTest();
        }
    }

    /**
    * createTestUser
    * テスト用のユーザーを作成する
    * @param：なし
    * @return：User - 作成されたユーザー
    * @created：2026/07/20 Nguyen Ngoc Quy
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
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c createAndInsertTestStudent() {
        Class__c classRecord = new Class__c();
        insert classRecord;

        Student__c studentTest = new Student__c(
            Name = 'Test Student'
            , Lastname__c = 'Test'
            , FirstName__c = 'Student'
            , BirthDay__c = Date.newInstance(2000, 1, 1)
            , Gender__c = 'Male'
            , Class_look__c = classRecord.Id
            , LearningStatus__c = 'Enrolled'
        );
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
            , StudentCode__c FROM Student__c 
            WHERE Id = :studentTest.Id 
            LIMIT 1
        ];   
        return returnStudent;
    }

    /**
    * getStudentById
    * 指定されたIDの学生レコードを取得する
    * @param：なし
    * @return：Student__c - 取得された学生レコード
    * @created：2026/07/20 Nguyen Ngoc Quy
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