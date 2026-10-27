/**
* クラス名   ：VF_DetailStudentPDFRenderCtrlTest
* クラス概要 ：VF_DetailStudentPDFRenderCtrlクラスのテストクラス
* @created  ：2026/07/20 Nguyen Ngoc Quy
* @modified ：
*/
@isTest
private class VF_DetailStudentPDFRenderCtrlTest {

    /**
    * testDetailStudentPDFRenderCtrl_Success
    * VF_DetailStudentPDFRenderCtrlクラスのコンストラクタのテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDetailStudentPDFRenderCtrl_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = initCreateTestData();
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
                VF_DetailStudentPDFRenderCtrl controller = new VF_DetailStudentPDFRenderCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'Student list must not be empty');
            Assert.isTrue(testStudent.Id == controller.student[0].Id, 'Student Id must be equal');
            Assert.isTrue(!controller.semestersMap.isEmpty(), 'Semesters map must not be empty');
        }
    }

    /**
    * testDetailStudentPDFRenderCtrl_EmptyStudent
    * VF_DetailStudentPDFRenderCtrlクラスのコンストラクタのテスト（Studentが空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDetailStudentPDFRenderCtrl_EmptyStudent() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = initCreateTestData();
            delete testStudent;
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
                VF_DetailStudentPDFRenderCtrl controller = new VF_DetailStudentPDFRenderCtrl();
            Test.stopTest();

            Assert.isTrue(controller.student.isEmpty(), 'Student list must be empty');
            Assert.isNull(controller.semestersMap, 'Semesters map must be null');
        }
    }

    /**
    * testDetailStudentPDFRenderCtrl_Exception
    * VF_DetailStudentPDFRenderCtrlクラスのコンストラクタのテスト（例外が発生する場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDetailStudentPDFRenderCtrl_Exception() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = initCreateTestData();
            delete testStudent;
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPage(pageRef);
            VF_DetailStudentPDFRenderCtrl.thowException = true;
            VF_DetailStudentPDFRenderCtrl controller;

            Test.startTest();
                try {
                    controller = new VF_DetailStudentPDFRenderCtrl();
                } catch (Exception e) {
                    Assert.isTrue(e.getMessage().contains('テスト用の例外をスローしました。'), 'Exception message must contain the expected text');
                }
            Test.stopTest();

            Assert.isNull(controller.student, 'Student list must be null');
            Assert.isNull(controller.semestersMap, 'Semesters map must be null');
        }
    }

    /**
    * testFormatText_Success
    * VF_DetailStudentPDFRenderCtrlクラスのformatTextメソッドのテスト
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testFormatText_Success() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Class__c classRecord = new Class__c();
            insert classRecord;

            Student__c testStudent = new Student__c(Name = 'Test Student'
            , Lastname__c = 'Test FormatTextWithLenghtNameData'
            , FirstName__c = 'Student'
            , BirthDay__c = Date.newInstance(2000, 1, 1)
            , Gender__c = 'Male'
            , LearningStatus__c = 'Enrolled'
            , Class_look__c = classRecord.Id);
            insert testStudent;

            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
                VF_DetailStudentPDFRenderCtrl controller = new VF_DetailStudentPDFRenderCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'Student list must not be empty');
            Assert.isTrue(testStudent.Id == controller.student[0].Id, 'Student Id must be equal');
            Assert.isNull(controller.semestersMap, 'Semesters map must be null');
        }
    }

    /**
    * testDetailStudentPDFRenderCtrl_NullSemesterId
    * VF_DetailStudentPDFRenderCtrlクラスのコンストラクタのテスト（SemesterIdがnullの場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDetailStudentPDFRenderCtrl_NullSemesterId() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = initCreateTestData();
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPage(pageRef);
            SubjectScore__c subjectScore = [
                SELECT Id
                , Semester_look__c 
                FROM SubjectScore__c 
                WHERE Student_look__c = :testStudent.Id 
                LIMIT 1
            ];
            subjectScore.Semester_look__c = null;
            update subjectScore;

            Test.startTest();
                VF_DetailStudentPDFRenderCtrl controller = new VF_DetailStudentPDFRenderCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'Student list must not be empty');
            Assert.isTrue(testStudent.Id == controller.student[0].Id, 'Student Id must be equal');
            Assert.isTrue(!controller.semestersMap.isEmpty(), 'Semesters map must not be empty');
        }
    }

    /**
    * testDetailStudentPDFRenderCtrl_EmptySemesterMap
    * VF_DetailStudentPDFRenderCtrlクラスのコンストラクタのテスト（SemesterMapが空の場合）
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    @isTest
    private static void testDetailStudentPDFRenderCtrl_EmptySemesterMap() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Student__c testStudent = initCreateTestData();
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('id', testStudent.Id);
            Test.setCurrentPage(pageRef);

            List<SubjectScore__c> subjectScore = [
                SELECT Id
                , Semester_look__c 
                FROM SubjectScore__c 
                WHERE Student_look__c = :testStudent.Id
            ];
            delete subjectScore;
            
            Test.startTest();
                VF_DetailStudentPDFRenderCtrl controller = new VF_DetailStudentPDFRenderCtrl();
            Test.stopTest();

            Assert.isTrue(!controller.student.isEmpty(), 'Student list must not be empty');
            Assert.isTrue(testStudent.Id == controller.student[0].Id, 'Student Id must be equal');
            Assert.isNull(controller.semestersMap, 'Semesters map must be null');
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
    * initCreateTestData
    * テスト用の学生レコードを作成する
    * @param：なし
    * @return：Student__c - 作成された学生レコード
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static Student__c initCreateTestData() {
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

        List<Semester__c> semesters = new List<Semester__c>();
        for (Integer i = 1; i <= 2; i++) {
            Semester__c semester = new Semester__c(Name = 'Semester ' + i);
            semesters.add(semester);
        }
        insert semesters;

        List<Subject__c> subjects = new List<Subject__c>();
        for (Integer i = 1; i <= 5; i++) {
            Subject__c subject = new Subject__c(Name = 'Subject ' + i
            , CourseCredit__c = 3);
            subjects.add(subject);
        }
        insert subjects;

        List<SubjectScore__c> subjectScores = new List<SubjectScore__c>();
        for (Semester__c semester : semesters) {
            for (Subject__c subject : subjects) {
                SubjectScore__c subjectScore = new SubjectScore__c(Student_look__c = returnStudent.Id
                , Semester_look__c = semester.Id
                , Subject_look__c = subject.Id);
                subjectScores.add(subjectScore);
            }
        }
        insert subjectScores;

        List<Score__c> scores = new List<Score__c>();
        for (SubjectScore__c subjectScore : subjectScores) {
            List<Score__c> scoreList = createScore(subjectScore);
            scores.addAll(scoreList);
        }
        insert scores;

        return returnStudent;
    }

    /**
    * createScore
    * テスト用のスコアレコードを作成する
    * @param：SubjectScore__c subjectScore - 作成するスコアの関連する科目スコアレコード
    * @return：List<Score__c> - 作成されたスコアレコードのリスト
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static List<Score__c> createScore (SubjectScore__c subjectScore) {
        List<Score__c> scores = new List<Score__c>();
        Set<String> scoreType = new Set<String>{'Progress', 'Practical', 'Midterm Exam', 'FinalTerm Exam'};
        for (String type : scoreType) {
            Score__c score = new Score__c(SubjectScore_look__c = subjectScore.Id
            , ExamType__c = type
            , Score__c = Math.random() * 10);
            scores.add(score);
        }
        return scores;
    }
}