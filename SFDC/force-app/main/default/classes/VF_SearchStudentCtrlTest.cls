/**
* クラス名   ：VF_SearchStudentCtrlTest
* クラス概要 ：VF_SearchStudentCtrlクラスのテストクラス
* @created  ：2026/07/20 Nguyen Ngoc Quy
* @modified ：
*/
@isTest
private class VF_SearchStudentCtrlTest {
    /**
    * testSearchStudent_Success
    * searchStudentメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudent_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';

            Test.startTest();
                controller.searchStudents();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
        }
    }

    /**
    * testSearchStudent_Exception
    * searchStudentメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testSearchStudent_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                controller.searchStudents();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testGoToPage_Success
    * goToPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();
            controller.currentPage = 2;

            Test.startTest();
                controller.goToPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
        }
    }

    /**
    * testGoToPage_Exception
    * goToPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.throwException = true;
            controller.currentPage = 2;

            Test.startTest();
                controller.goToPage();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');        }
    }

    /**
    * testGoToPage_Success_PageNumberCenter
    * goToPageメソッドの正常系テスト（ページ番号が中央の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToPage_Success_PageNumberCenter() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(40);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();
            controller.currentPage = 5;

            Test.startTest();
                controller.goToPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
        }
    }

    /**
    * testGoToPage_Success_PageNumberRight
    * goToPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToPage_Success_PageNumberRight() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(30);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();
            controller.currentPage = 5;

            Test.startTest();
                controller.goToPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
        }
    }

    /**
    * testGoToFirstPage_Success
    * goToFirstPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToFirstPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();
            controller.currentPage = 3;
            controller.goToPage();

            Test.startTest();
                controller.goToFirstPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
            Assert.areEqual(1, controller.currentPage, 'The current page should be 1 after going to the first page.');
        }
    }

    /**
    * testGoToFirstPage_Exception
    * goToFirstPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToFirstPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.currentPage = 3;
            controller.goToPage();
            controller.throwException = true;

            Test.startTest();
                controller.goToFirstPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testGoToLastPage_Success
    * goToLastPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToLastPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();

            Test.startTest();
                controller.goToLastPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
            Assert.areEqual(4, controller.currentPage, 'The current page should be 4 after going to the last page.');
        }
    }

    /**
    * testGoToLastPage_Exception
    * goToLastPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToLastPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                controller.goToLastPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testGoToNextPage_Success
    * goToNextPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToNextPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();

            Test.startTest();
                controller.goToNextPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
            Assert.areEqual(2, controller.currentPage, 'The current page should be 2 after going to the next page.');
        }
    }

    /**
    * testGoToNextPage_Exception
    * goToNextPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToNextPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                controller.goToNextPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testGetSelectedCount_Success
    * getSelectedCountメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetSelectedCount_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();
            controller.studentsPaginated[0].isSelected = true;
            controller.studentsPaginated[1].isSelected = true;

            Test.startTest();
                Integer selectedCount = controller.getSelectedCount();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
            Assert.areEqual(2, selectedCount, 'The selected count should be 2.');
        }
    }

    /**
    * testGoToPreviousPage_Success
    * goToPreviousPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToPreviousPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();
            controller.currentPage = 2;
            controller.goToPage();

            Test.startTest();
                controller.goToPreviousPage();
            Test.stopTest();

            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
            Assert.areEqual(1, controller.currentPage, 'The current page should be 2 after going to the previous page.');
        }
    }

    /**
    * testGoToPreviousPage_Exception
    * goToPreviousPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGoToPreviousPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.currentPage = 2;
            controller.goToPage();
            controller.throwException = true;

            Test.startTest();
                controller.goToPreviousPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testGetSelectedCount_Exception
    * getSelectedCountメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testGetSelectedCount_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                controller.getSelectedCount();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testClearSearch_Success
    * clearSearchメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testClearSearch_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            StudentManageSetting__c setting = new StudentManageSetting__c(
                S_MaxRecord__c = 20,
                S_RecordPerPage__c = 5
            );
            insert setting;
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();

            Test.startTest();
                controller.clearSearch();
            Test.stopTest();

            Assert.isTrue(controller.searchKey.isEmpty(), 'The searchKey should be empty after clearing the search.');
            Assert.areEqual(5, controller.studentsPaginated.size(), 'The number of students returned should match the expected count.');
        }
    }

    /**
    * testClearSearch_Exception
    * clearSearchメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testClearSearch_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            Class__c classRecord = getClassRecord();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentCode = 'SV';
            controller.searchKey.studentName = 'LastName';
            controller.searchKey.studentClass = classRecord.Id;
            controller.searchKey.studentGender = 'Male';
            controller.searchKey.studentBirthday = Date.newInstance(2000, 1, 1);
            controller.searchKey.dayOfBirth = '1';
            controller.searchKey.monthOfBirth = '1';
            controller.searchKey.yearOfBirth = '2000';
            controller.searchStudents();
            controller.throwException = true;

            Test.startTest();
                controller.clearSearch();
            Test.stopTest();
            
            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testOpenCreateStudentPage_Success
    * openCreateStudentPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenCreateStudentPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

            Test.startTest();
                PageReference result = controller.openCreateStudentPage();
            Test.stopTest();

            Assert.isNotNull(result, 'The PageReference returned should not be null.');
            Assert.areEqual(Page.VF_CreateStudent.getUrl(), result.getUrl(), 'The URL of the PageReference should match the expected URL.');
        }
    }

    /**
    * testOpenCreateStudentPage_Exception
    * openCreateStudentPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenCreateStudentPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.throwException = true;

            Test.startTest();
                PageReference result = controller.openCreateStudentPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testOpenEditStudentPage_Success
    * openEditStudentPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenEditStudentPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentId = testStudent.Id;

            Test.startTest();
                PageReference result = controller.openEditStudentPage();
            Test.stopTest();

            Assert.isNotNull(result, 'The PageReference returned should not be null.');
            Assert.isTrue(result.getUrl().contains(Page.VF_UpdateStudent.getUrl()), 'The URL of the PageReference should match the expected URL.');
        }
    }

    /**
    * testOpenEditStudentPage_Exception
    * openEditStudentPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenEditStudentPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentId = testStudent.Id;
            controller.throwException = true;
            
            Test.startTest();
                PageReference result = controller.openEditStudentPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testOpenEditStudentPage_MissingStudentId
    * openEditStudentPageメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenEditStudentPage_MissingStudentId() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

            Test.startTest();
                PageReference result = controller.openEditStudentPage();
            Test.stopTest();

            Assert.isNull(result, 'The PageReference returned should be null.');
            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'There should be an error message when studentId is null.');
            Assert.isTrue(messages[0].getSummary().contains('学生が選択されていません。'), 'The error message should indicate that no student is selected.');
        }
    }

    /**
    * testOpenStudentDetailPage_Success
    * openStudentDetailPageメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenStudentDetailPage_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentId = testStudent.Id;

            Test.startTest();
                PageReference result = controller.openStudentDetailPage();
            Test.stopTest();

            Assert.isNotNull(result, 'The PageReference returned should not be null.');
            Assert.isTrue(result.getUrl().contains(Page.VF_DetailStudent.getUrl()), 'The URL of the PageReference should match the expected URL.');
        }
    }

    /**
    * testOpenStudentDetailPage_Exception
    * openStudentDetailPageメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenStudentDetailPage_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentId = testStudent.Id;
            controller.throwException = true;

            Test.startTest();
                PageReference result = controller.openStudentDetailPage();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testOpenStudentDetailPage_MissingStudentId
    * openStudentDetailPageメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenStudentDetailPage_MissingStudentId() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

            Test.startTest();
                PageReference result = controller.openStudentDetailPage();
            Test.stopTest();

            Assert.isNull(result, 'The PageReference returned should be null.');
            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'There should be an error message when studentId is null.');
            Assert.isTrue(messages[0].getSummary().contains('学生が選択されていません。'), 'The error message should indicate that no student is selected.');
        }
    }

    /**
    * testOpenDeleteConfirm_Success
    * openDeleteConfirmメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenDeleteConfirm_Success(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentId = testStudent.Id;
            
            Test.startTest();
                controller.openDeleteConfirm();
            Test.stopTest();

            Assert.isTrue(controller.showDeleteConfirm, 'The showDeleteConfirm should be true after calling openDeleteConfirm.');
        }
    }

    /**
    * testOpenDeleteConfirm_Exception
    * openDeleteConfirmメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenDeleteConfirm_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = createTestStudents(1)[0];
            insert testStudent;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentId = testStudent.Id;
            controller.throwException = true;

            Test.startTest();
                controller.openDeleteConfirm();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testOpenDeleteMultipleConfirm_Success
    * openDeleteMultipleConfirmメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenDeleteMultipleConfirm_Success(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();
            controller.studentsPaginated[0].isSelected = true;
            controller.studentsPaginated[1].isSelected = true;
            
            Test.startTest();
                controller.openDeleteMultipleConfirm();
            Test.stopTest();

            Assert.isTrue(controller.showDeleteConfirm, 'The showDeleteConfirm should be true after calling openDeleteConfirm.');
        }
    }

    /**
    * testOpenDeleteMultipleConfirm_Exception
    * openDeleteMultipleConfirmメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenDeleteMultipleConfirm_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();
            controller.studentsPaginated[0].isSelected = true;
            controller.studentsPaginated[1].isSelected = true;
            controller.throwException = true;
            
            Test.startTest();
                controller.openDeleteMultipleConfirm();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testOpenDeleteMultipleConfirm_NoStudentSelected
    * openDeleteMultipleConfirmメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testOpenDeleteMultipleConfirm_NoStudentSelected(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();
            
            Test.startTest();
                controller.openDeleteMultipleConfirm();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'There should be an error message when no students are selected for deletion.');
            Assert.isTrue(messages[0].getSummary().contains('学生が選択されていません。'), 'The error message should indicate that no students are selected for deletion.');
        }
    }

    /**
    * testCloseDeleteConfirm_Success
    * closeDeleteConfirmメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testCloseDeleteConfirm_Success(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.showDeleteConfirm = true;
            
            Test.startTest();
                controller.closeDeleteConfirm();
            Test.stopTest();

            Assert.isFalse(controller.showDeleteConfirm, 'The showDeleteConfirm should be false after calling closeDeleteConfirm.');
        }
    }

    /**
    * testCloseDeleteConfirm_Exception
    * closeDeleteConfirmメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testCloseDeleteConfirm_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.showDeleteConfirm = true;
            controller.throwException = true;
            
            Test.startTest();
                controller.closeDeleteConfirm();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testToggleSelectAll_SuccessWithSearchKey
    * toggleSelectAllメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testToggleSelectAll_SuccessWithSearchKey() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentName = 'LastName';
            controller.searchStudents();

            Test.startTest();
                controller.toggleSelectAll();
            Test.stopTest();

            Assert.isTrue(!controller.students.isEmpty(), 'The students list should not be empty after toggling select all with search key.');
        }
    }

    /**
    * testToggleSelectAll_Exception
    * toggleSelectAllメソッドの異常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testToggleSelectAll_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentName = 'LastName';
            controller.searchStudents();
            controller.throwException = true;

            Test.startTest();
                controller.toggleSelectAll();
            Test.stopTest();
            
            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testToggleSelectAll_SuccessWithoutSearchKey
    * toggleSelectAllメソッドの正常系テスト（検索キーなし）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testToggleSelectAll_SuccessWithoutSearchKey() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();

            Test.startTest();
                controller.toggleSelectAll();
            Test.stopTest();

            Assert.isTrue(!controller.students.isEmpty(), 'The students list should not be empty after toggling select all with search key.');
        }
    }

    /**
    * testToggleSelectAll_SuccessWithSearchKey_ToogleOff
    * toggleSelectAllメソッドの正常系テスト（検索キーあり、トグルオフ）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testToggleSelectAll_SuccessWithSearchKey_ToogleOff() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchKey.studentName = 'LastName';
            controller.searchStudents();
            controller.selectAll = true;

            Test.startTest();
                controller.toggleSelectAll();
            Test.stopTest();

            Assert.isTrue(!controller.students.isEmpty(), 'The students list should not be empty after toggling select all with search key.');
        }
    }

    /**
    * testToggleSelectAll_SuccessWithoutSearchKey_ToogleOff
    * toggleSelectAllメソッドの正常系テスト（検索キーなし）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testToggleSelectAll_SuccessWithoutSearchKey_ToogleOff() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(20);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.searchStudents();
            controller.selectAll = true;

            Test.startTest();
                controller.toggleSelectAll();
            Test.stopTest();

            Assert.isTrue(!controller.students.isEmpty(), 'The students list should not be empty after toggling select all with search key.');
        }
    }

    /**
    * testDeleteStudent_multiDeleteFalse_GoLastPage
    * deleteStudentメソッドの正常系テスト（multiDeleteがfalseの場合、最後のページに移動する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudent_multiDeleteFalse_GoLastPage(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(21);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.goToLastPage();
            controller.studentId = testStudents[0].Id;
            controller.multiDelete = false;

            Test.startTest();
                controller.deleteStudent();
            Test.stopTest();

            List<Student__c> deletedStudent = [SELECT Id FROM Student__c WHERE Id = :testStudents[0].Id LIMIT 1];
            Assert.isTrue(deletedStudent.isEmpty(), 'The student should be deleted from the database.');
        }
    }

    /**
    * testDeleteStudent_multiDeleteFalse
    * deleteStudentメソッドの正常系テスト（multiDeleteがfalseの場合、最後のページに移動する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudent_multiDeleteFalse(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(22);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.goToLastPage();
            controller.studentId = testStudents[0].Id;
            controller.multiDelete = false;

            Test.startTest();
                controller.deleteStudent();
            Test.stopTest();

            List<Student__c> deletedStudent = [SELECT Id FROM Student__c WHERE Id = :testStudents[0].Id LIMIT 1];
            Assert.isTrue(deletedStudent.isEmpty(), 'The student should be deleted from the database.');
        }
    }

    /**
    * testDeleteStudent_multiDeleteFalse_Exception
    * deleteStudentメソッドの異常系テスト（multiDeleteがfalseの場合、最後のページに移動する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudent_multiDeleteFalse_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(22);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.goToLastPage();
            controller.studentId = testStudents[0].Id;
            controller.multiDelete = false;
            controller.throwException = true;

            Test.startTest();
                controller.deleteStudent();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testDeleteStudent_multiDeleteFalse_BlankId
    * deleteStudentメソッドの正常系テスト（multiDeleteがfalseの場合、最後のページに移動する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudent_multiDeleteFalse_BlankId(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(22);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.goToLastPage();
            controller.studentId = '';
            controller.multiDelete = false;

            Test.startTest();
                controller.deleteStudent();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'There should be an error message when studentId is blank.');
            Assert.isTrue(messages[0].getSummary().contains('学生が選択されていません。'), 'The error message should indicate that no student is selected.');
        }
    }

    /**
    * testDeleteStudent_multiDeleteTrue
    * deleteStudentメソッドの正常系テスト（multiDeleteがtrueの場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudent_multiDeleteTrue(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(21);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentsPaginated[0].isSelected = true;
            controller.multiDelete = true;

            Test.startTest();
                controller.deleteStudent();
            Test.stopTest();

            List<Student__c> deletedStudents = [SELECT Id FROM Student__c WHERE Id = :testStudents[0].Id];
            Assert.isTrue(deletedStudents.isEmpty(), 'The selected students should be deleted from the database.');
        }
    }

    /**
    * testDeleteStudents_EmptySelectedStudent
    * deleteStudentsメソッドの異常系テスト（選択された学生がない場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudents_EmptySelectedStudent(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(21);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

            Test.startTest();
                controller.deleteStudents();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'There should be an error message when no students are selected for deletion.');
            Assert.isTrue(messages[0].getSummary().contains('学生が選択されていません。'), 'The error message should indicate that no students are selected for deletion.');
        }
    }

    /**
    * testDeleteStudents_Success
    * deleteStudentsメソッドの正常系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudents_Success(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(21);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentsPaginated[0].isSelected = true;
            controller.studentsPaginated[1].isSelected = true;

            Test.startTest();
                controller.deleteStudents();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            List<Student__c> listStudent = [SELECT Id FROM Student__c WHERE Id IN :testStudents];
            Assert.isTrue(listStudent.size() == 19, 'The selected students should be deleted from the database.');
        }
    }

    /**
    * testDeleteStudents_Exception
    * deleteStudentsメソッドの例外系テスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudents_Exception(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(21);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.studentsPaginated[0].isSelected = true;
            controller.studentsPaginated[1].isSelected = true;
            controller.throwException = true;

            Test.startTest();
                controller.deleteStudents();
            Test.stopTest();

            ApexPages.Message [] messages = ApexPages.getMessages();
            Assert.isTrue(!messages.isEmpty(), 'An error message should be present when an exception occurs.');
            Assert.isTrue(messages[0].getSummary().contains('エラーが発生しました'), 'The error message should indicate that an error occurred.');
        }
    }

    /**
    * testDeleteStudents_Success_GoToLastPage
    * deleteStudentsメソッドの正常系テスト（削除後に最後のページに移動する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDeleteStudents_Success_GoToLastPage(){
        User testUser = createTestUser();
        System.runAs(testUser) {
            List<Student__c> testStudents = createTestStudents(21);
            insert testStudents;
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
            controller.goToLastPage();
            controller.studentsPaginated[0].isSelected = true;

            Test.startTest();
                controller.deleteStudents();
            Test.stopTest();

            ApexPages.Message[] messages = ApexPages.getMessages();
            List<Student__c> listStudent = [SELECT Id FROM Student__c WHERE Id IN :testStudents];
            Assert.isTrue(listStudent.size() == 20, 'The selected students should be deleted from the database.');
            Assert.isTrue(controller.currentPage == 4, 'The current page should be 4 after deleting a student on the last page.');
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
    * CreateTestStudents
    * テスト用の学生レコードを作成する
    * @param：count - 作成する学生レコードの数
    * @return：List<Student__c> - 作成された学生レコードのリスト
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static List<Student__c> createTestStudents(Integer count) {
        Class__c studentClass = new Class__c();
        insert studentClass;
        
        List<Student__c> students = new List<Student__c>();
        for (Integer i = 0; i < count; i++) {
            Student__c student = new Student__c(
                LastName__c = 'LastName' + i,
                FirstName__c = 'FirstName' + i,
                Name = 'LastName' + i + 'FirstName' + i,
                BirthDay__c = Date.newInstance(2000, 1, 1),
                Gender__c = 'Male',
                Class_look__c = studentClass.Id,
                LearningStatus__c = 'Enrolled'
            );
            students.add(student);
        }
        return students;
    }

    /**
    * getClassRecord
    * テスト用のクラスレコードを取得する
    * @param: なし
    * @return： Class__c - 取得されたクラスレコード
    * @created： 2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static Class__c getClassRecord() {
        return [
            SELECT Id, Name 
            FROM Class__c 
            LIMIT 1
        ];
    }
}