/**
* クラス名   ：VF_DetailStudentPDFRenderCtrl
* クラス概要 ：学生詳細情報をPDF形式で表示する
* @created  ：2026/07/17 Nguyen Ngoc Quy
* @modified ：
*/
public with sharing class VF_DetailStudentPDFRenderCtrl {
    
    private Id studentId {get; set;}
    public List<Student__c> student {get; set;}
    public Student__c studentRecord {get; set;}
    public Map<String, Object> semestersMap {get; set;}

    public String studentLastName {get; set;}
    public String studentFirstName {get; set;}

    @TestVisible
    private static Boolean thowException = false;

    public VF_DetailStudentPDFRenderCtrl() {
        try {
            if (thowException) {
                throw new CustomException('テスト用の例外をスローしました。');
            }

            studentRecord = new Student__c();
            getStudent();
            if (student != null && !student.isEmpty()) {
                studentRecord = student[0];
                studentLastName = formatText(student[0].LastName__c, 20);
                studentFirstName = formatText(student[0].FirstName__c, 20);
                semestersMap = fetchSubjectScoresBySemester(studentId);
                semestersMap = caculateScoresAndCredit(semestersMap);
            } else {
                studentLastName = '';
                studentFirstName = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '学生の詳細情報が見つかりません。'));
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'エラーが発生しました: ' + e.getMessage()));
        }
        
    }

    /**
    * getStudent
    * 学生の詳細情報を取得する
    * @param：なし
    * @return：List<Student__c> - 学生の詳細情報リスト
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    private List<Student__c> getStudent() {
        studentId = ApexPages.currentPage().getParameters().get('id');
        student = queryStudent();
        return student;
    }

    /**
    * queryStudent
    * 学生の詳細情報をクエリする
    * @param：なし
    * @return：List<Student__c> - 学生の詳細情報リスト
    * @created：2026/07/17 Nguyen Ngoc Quy
    * @modified：
    */
    private List<Student__c> queryStudent() {
        List<Student__c> student = [
            SELECT Id
            , Name
            , LastName__c
            , FirstName__c
            , Birthday__c
            , toLabel(Gender__c)
            , Class_look__r.Name
            , toLabel(LearningStatus__c)
            , GPAScore__c
            , TotalCredit__c
            , StudentCode__c 
            FROM Student__c 
            WHERE Id = :studentId 
            LIMIT 1
        ];
        return student;
    }

    /**
    * fetchSubjectScoreList
    * 学生の科目スコアリストを取得する
    * @param: String studentId - 学生ID
    * @return: List<SubjectScore__c> - 学生の科目スコアリスト
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    private List<SubjectScore__c> fetchSubjectScoreList(String studentId) {
        List<SubjectScore__c> subjectScores = [
            SELECT Id
            , Semester_look__c
            , Semester_look__r.Name
            , AverageScore__c
            , Status__c
            , Subject_look__r.SubjectCode__c
            , Subject_look__r.CourseCredit__c
            , Subject_look__r.Name
            FROM SubjectScore__c
            WHERE Student_look__c = :studentId
            ORDER BY Semester_look__r.StartDate__c, Subject_look__r.SubjectCode__c NULLS LAST
        ];
        return subjectScores;
    }

    /**
    * fetchScoreList
    * 学生のスコアリストを取得する
    * @param: String studentId - 学生ID
    * @return: List<Score__c> - 学生のスコアリスト
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    private List<Score__c> fetchScoreList(String studentId) {
        List<Score__c> scores = [
            SELECT Id
            , SubjectScore_look__c
            , Score__c
            , ExamType__c
            FROM Score__c
            WHERE SubjectScore_look__r.Student_look__c = :studentId
        ];
        return scores;
    }

    /**
    * fetchSubjectScoresBySemester
    * 学生の学期ごとの科目スコアを取得する
    * @param: String studentId - 学生ID
    * @return: Map<String, Object> - 学期ごとの科目スコアのマップ
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    private Map<String, Object> fetchSubjectScoresBySemester(String studentId) {
        List<SubjectScore__c> subjectScores = fetchSubjectScoreList(studentId);
        List<Score__c> scores = fetchScoreList(studentId);

        Map<String, Object> semestersMap = new Map<String, Object>();

        Map<Id, List<Score__c>> scoresBySubjectScoreId = new Map<Id, List<Score__c>>();
        for (Score__c score : scores) {
            if (!scoresBySubjectScoreId.containsKey(score.SubjectScore_look__c)) {
                scoresBySubjectScoreId.put(score.SubjectScore_look__c, new List<Score__c>());
            }
            scoresBySubjectScoreId.get(score.SubjectScore_look__c).add(score);
        }

        for (SubjectScore__c subjectScore : subjectScores) {

            if (subjectScore.Semester_look__c == null) {
                continue;
            }

            Map<String, Object> scoreMap = new Map<String, Object>();
            if (scoresBySubjectScoreId.containsKey(subjectScore.Id)) {
                for (Score__c score : scoresBySubjectScoreId.get(subjectScore.Id)) {
                    scoreMap.put(score.ExamType__c, score.Score__c);
                }
            }

            Map<String, Object> subjectMap = new Map<String, Object>{
                'Id' => subjectScore.Id,
                'Semester_look__c' => subjectScore.Semester_look__c,
                'Status__c' => subjectScore.Status__c,
                'Subject_look__c' => subjectScore.Subject_look__c,
                'Subject_look__r' => new Map<String, Object>{
                    'Id' => subjectScore.Subject_look__r.Id,
                    'Name' => formatText(subjectScore.Subject_look__r.Name, 20),
                    'SubjectCode__c' => subjectScore.Subject_look__r.SubjectCode__c,
                    'CourseCredit__c' => subjectScore.Subject_look__r.CourseCredit__c
                },
                'Score__r' => scoreMap,
                'AverageScore__c' => subjectScore.AverageScore__c
            };
            
            if (!semestersMap.containsKey(subjectScore.Semester_look__c)) {
                semestersMap.put(
                    subjectScore.Semester_look__c,
                    new Map<String, Object>{
                        'Id' => subjectScore.Semester_look__c,
                        'Name' => subjectScore.Semester_look__r.Name,
                        'AverageScore__c' => subjectScore.AverageScore__c,
                        'SubjectScores__r' => new List<Map<String, Object>>{
                            subjectMap
                        }
                    }
                );
            } else {
                Map<String, Object> semesterMap = (Map<String, Object>) semestersMap.get(subjectScore.Semester_look__c);
                List<Map<String, Object>> subjectList = (List<Map<String, Object>>) semesterMap.get('SubjectScores__r');
                subjectList.add(subjectMap);
            }
        }
        if (semestersMap.isEmpty()) {
            return null;
        }
        return semestersMap;
    }
    
    /**
    * caculateScoresAndCredit
    * 学生の学期ごとの科目スコアを取得する
    * @param: Map<String, Object> semestersMap - 学期ごとの科目スコアのマップ
    * @return: Map<String, Object> - 学期ごとの科目スコアのマップ（平均点と合計単位数を含む）
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    private Map<String, Object> caculateScoresAndCredit(Map<String, Object> semestersMap) {
        if (semestersMap == null || semestersMap.isEmpty()) {
            return null;
        }
        for (String semesterId : semestersMap.keySet()) {
            Map<String, Object> semesterMap = (Map<String, Object>) semestersMap.get(semesterId);
            List<Map<String, Object>> subjectScoresList = (List<Map<String, Object>>) semesterMap.get('SubjectScores__r');

            Decimal totalScore = 0;
            Decimal totalCredit = 0;

            for (Map<String, Object> subjectScore : subjectScoresList) {
                Decimal averageScore = (Decimal) subjectScore.get('AverageScore__c');
                Decimal courseCredit = (Decimal) ((Map<String, Object>) subjectScore.get('Subject_look__r')).get('CourseCredit__c');

                if (averageScore != null && courseCredit != null) {
                    totalScore += averageScore * courseCredit;
                    totalCredit += courseCredit;
                }
            }

            Decimal averageSemesterScore = (totalCredit > 0) ? (totalScore / totalCredit) : 0;
            Decimal roundScore = averageSemesterScore.setScale(2, RoundingMode.HALF_UP);

            semesterMap.put('totalSemesterCredit', totalCredit);
            semesterMap.put('averageScore', roundScore);
        }
        return semestersMap;
    }

    /**
    * formatText
    * テキストを指定された長さで改行する
    * @param: String text - フォーマットするテキスト
    * @param: Integer Lenght - 改行する長さ
    * @return: String - フォーマットされたテキスト
    * @created: 2026/07/17 Nguyen Ngoc Quy
    * @modified:
    */
    private String formatText (String text, Integer Lenght){
        List<String> content = new List<String>();
        if (text.length() > Lenght) {
            // Split the text into phrases based on whitespace
            content = text.split('\\s+');

            // If any phrase lenght is greater than the specified length, split it into multiple lines
            for (String str : content) {
                if (str.length() <= Lenght) {
                    continue;
                }
                Integer startIndex = 0;
                String line = '';
                while (startIndex < str.length()) {
                    Integer endIndex = Math.min(startIndex + Lenght, str.length());
                    if (endIndex == str.length()) {
                        line += str.substring(startIndex, endIndex);
                    } else {
                        line += str.substring(startIndex, endIndex) + '<br/>';
                    }
                    startIndex += Lenght;
                }
                text = text.replace(str, line);
            }
            
        }
        return text;
    }

    /**
    * クラス名   ：CustomException
    * クラス概要 ：カスタム例外クラス
    * @created  ：2026/07/17 Nguyen Ngoc Quy
    * @modified ：
    */
    class CustomException extends Exception {}
}