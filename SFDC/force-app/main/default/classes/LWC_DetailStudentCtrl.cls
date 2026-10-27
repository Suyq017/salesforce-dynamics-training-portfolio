/**
* クラス名  ：LWC_DetailStudentCtrl
* クラス概要：学生の詳細を表示するためのコントローラー
* @created ：2026/06/19 Nguyen Ngoc Quy
* @modified：2026/07/21 Nguyen Ngoc Quy
*/
public with sharing class LWC_DetailStudentCtrl {
    
    // 2026/07/21 Nguyen Ngoc Quy Add start
    @TestVisible
    private static Boolean thowException = false;
    // 2026/07/21 Nguyen Ngoc Quy Add end

    /**
    * getStudentDetail
    * 学生の詳細情報を取得する
    * @param：String studentId - 学生ID
    * @return：Student__c - 学生情報
    * @created：2026/06/19 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Student__c getStudentDetail(String studentId) {
        try {
            List<Student__c> studentList = new List<Student__c>();
            studentList = [
                SELECT Id
                , StudentCode__c
                , Lastname__c
                , Firstname__c
                , toLabel(Gender__c)
                , Class_look__c
                , Class_look__r.Name
                , Birthday__c
                , toLabel(LearningStatus__c)
                , GPAScore__c
                , TotalCredit__c
                FROM Student__c 
                WHERE Id = :studentId 
                LIMIT 1
                ];
            if (studentList.isEmpty()) {
                throw newMessageException('学生が見つかりませんでした。');
            }
            return studentList[0];
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
    * newMessageException
    * 例外メッセージを作成するヘルパーメソッド
    * @param: String message - 例外メッセージの内容
    * @return: AuraHandledException - 作成された例外オブジェクト
    * @created: 2026/06/19 Nguyen Ngoc Quy
    */
    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    /**
    * fetchSubjectScoreList
    * 学生の科目スコアリストを取得する
    * @param: String studentId - 学生ID
    * @return: List<SubjectScore__c> - 学生の科目スコアリスト
    * @created: 2026/06/25 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    private static List<SubjectScore__c> fetchSubjectScoreList(String studentId) {
        // 2026/07/21 Nguyen Ngoc Quy Modified Start
        // try {
        //     List<SubjectScore__c> subjectScores = [
        //         SELECT Id
        //         , Semester_look__c
        //         , Semester_look__r.Name
        //         , AverageScore__c
        //         , Status__c
        //         , Subject_look__r.SubjectCode__c
        //         , Subject_look__r.CourseCredit__c
        //         , Subject_look__r.Name
        //         FROM SubjectScore__c
        //         WHERE Student_look__c = :studentId
        //         // 2026/07/09 Nguyen Ngoc Quy Modified Start
        //         // ORDER BY Semester_look__r.StartDate__c
        //         ORDER BY Semester_look__r.StartDate__c, Subject_look__r.SubjectCode__c NULLS LAST
        //         // 2026/07/09 Nguyen Ngoc Quy Modified End
        //     ];
        //     return subjectScores;
        // } catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
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
            // 2026/07/09 Nguyen Ngoc Quy Modified Start
            // ORDER BY Semester_look__r.StartDate__c
            ORDER BY Semester_look__r.StartDate__c, Subject_look__r.SubjectCode__c NULLS LAST
            // 2026/07/09 Nguyen Ngoc Quy Modified End
        ];
        return subjectScores;
        // 2026/07/21 Nguyen Ngoc Quy Modified End
    }

    /**
    * fetchScoreList
    * 学生のスコアリストを取得する
    * @param: String studentId - 学生ID
    * @return: List<Score__c> - 学生のスコアリスト
    * @created: 2026/06/25 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    private static List<Score__c> fetchScoreList(String studentId) {
        // 2026/07/21 Nguyen Ngoc Quy Modified Start
        //     List<Score__c> scores = [
        //         SELECT Id
        //         , SubjectScore_look__c
        //         , Score__c
        //         , ExamType__c
        //         FROM Score__c
        //         WHERE SubjectScore_look__r.Student_look__c = :studentId
        //     ];
        //     return scores;
        // } catch (Exception e) {
        //     throw newMessageException(e.getMessage());
        // }
        List<Score__c> scores = [
            SELECT Id
            , SubjectScore_look__c
            , Score__c
            , ExamType__c
            FROM Score__c
            WHERE SubjectScore_look__r.Student_look__c = :studentId
        ];
        return scores;
        // 2026/07/21 Nguyen Ngoc Quy Modified End
    }

    /**
    * fetchSubjectScoresBySemester
    * 学生の学期ごとの科目スコアを取得する
    * @param: String studentId - 学生ID
    * @return: Map<String, Object> - 学期ごとの科目スコアのマップ
    * @created: 2026/06/25 Nguyen Ngoc Quy
    * @modified: 2026/07/21 Nguyen Ngoc Quy
    */
    @AuraEnabled
    public static Map<String, Object> fetchSubjectScoresBySemester(String studentId) {
        try {
            // 2026/07/21 Nguyen Ngoc Quy Add Start
            throwExceptionForTesting();
            // 2026/07/21 Nguyen Ngoc Quy Add End
            
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

                List<Map<String, Object>> scoreList = new List<Map<String, Object>>();
                if (scoresBySubjectScoreId.containsKey(subjectScore.Id)) {
                    for (Score__c score : scoresBySubjectScoreId.get(subjectScore.Id)) {
                        scoreList.add(new Map<String, Object>{
                            'Id' => score.Id,
                            'SubjectScore_look__c' => score.SubjectScore_look__c,
                            'Score__c' => score.Score__c,
                            'ExamType__c' => score.ExamType__c
                        });
                    }
                }

                Map<String, Object> subjectMap = new Map<String, Object>{
                    'Id' => subjectScore.Id,
                    'Semester_look__c' => subjectScore.Semester_look__c,
                    'Status__c' => subjectScore.Status__c,
                    'Subject_look__c' => subjectScore.Subject_look__c,
                    'Subject_look__r' => new Map<String, Object>{
                        'Id' => subjectScore.Subject_look__r.Id,
                        'Name' => subjectScore.Subject_look__r.Name,
                        'SubjectCode__c' => subjectScore.Subject_look__r.SubjectCode__c,
                        'CourseCredit__c' => subjectScore.Subject_look__r.CourseCredit__c
                    },
                    'Score__r' => scoreList,
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
            return semestersMap;
        } 
        catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    // 2026/07/21 Nguyen Ngoc Quy Add Start
    /**
    * throwExceptionForTesting
    * テスト用の例外をスローするヘルパーメソッド
    * @param: なし
    * @return: なし
    * @created: 2026/07/21 Nguyen Ngoc Quy
    * @modified:
    */
    private static void throwExceptionForTesting() {
        if (thowException) {
            throw newMessageException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/21 Nguyen Ngoc Quy Add End
}