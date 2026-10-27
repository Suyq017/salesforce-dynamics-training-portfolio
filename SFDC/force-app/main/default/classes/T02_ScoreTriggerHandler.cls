/**
* クラス名  : T02_ScoreTriggerHandler
* クラス概要: Score__cオブジェクトのトリガー
* @created : 2026/07/01 Nguyen Ngoc Quy
* @modified: 2026/07/20 Nguyen Ngoc Quy
*/
public without sharing class T02_ScoreTriggerHandler {

    // 2026/07/20 Nguyen Ngoc Quy Add Start
    @TestVisible
    private static Boolean afterTriggerThrowException = false;
    // 2026/07/20 Nguyen Ngoc Quy Add End

    private static final String EXAM_TYPE_PROGRESS = 'Progress';
    private static final String EXAM_TYPE_PRACTICAL = 'Practical';
    private static final String EXAM_TYPE_MIDTERM = 'Midterm Exam';
    private static final String EXAM_TYPE_FINAL = 'FinalTerm Exam';

    private static final Map<String, Decimal> WEIGHT_MAP = new Map<String, Decimal>{
        EXAM_TYPE_PROGRESS => 0.1,
        EXAM_TYPE_PRACTICAL => 0.2,
        EXAM_TYPE_MIDTERM => 0.2,
        EXAM_TYPE_FINAL => 0.5
    };

    private static final Decimal PASSING_SCORE = 5.0;
    private static final String SUBJECT_STATUS_PASSED = 'Passed';
    private static final String SUBJECT_STATUS_FAILED = 'Not Passed';

    /**
    * afterInsertHandle
    * Score__cオブジェクトの挿入後の処理
    * @param: List<Score__c> newList
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    public static void afterInsertHandle(List<Score__c> newList) {
        try {
            // 2026/07/20 Nguyen Ngoc Quy Add start
            afterTriggerThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

            afterInsertOrUpdateHandle(newList);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * afterUpdateHandle
    * Score__cオブジェクトの挿入または更新後の処理
    * @param: List<Score__c> newList 
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    public static void afterUpdateHandle(List<Score__c> newList) {
        try {
            // 2026/07/20 Nguyen Ngoc Quy Add start
            afterTriggerThrowExceptionForTesting();
            // 2026/07/20 Nguyen Ngoc Quy Add end

            afterInsertOrUpdateHandle(newList);
        }
        catch (Exception e) {
           throw new CustomException(e.getMessage());
        }
    }

    /**
    * afterInsertOrUpdateHandle
    * Score__cオブジェクトの挿入または更新後の処理
    * @param: List<Score__c> newList - 新しいScore__cオブジェクトのリスト
    * @return: なし
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified: 2026/07/20 Nguyen Ngoc Quy
    */
    private static void afterInsertOrUpdateHandle(List<Score__c> newList) {
        // collect unique SubjectScore__c Ids from the new Score__c records
        Set<Id> setSubjectScoreIds = new Set<Id>();
        for(Score__c score : newList) {
            if (score.SubjectScore_look__c != null) {
                setSubjectScoreIds.add(score.SubjectScore_look__c);
            }
        }

        // retrieve all Score__c records related to the unique SubjectScore__c Ids
        List<Score__c> listScores = getScoresList(setSubjectScoreIds);
        // 2026/07/20 Nguyen Ngoc Quy Delete start
        // if (listScores == null || listScores.isEmpty()) {
        //     return;
        // }
        // 2026/07/20 Nguyen Ngoc Quy Delete end
        
        // put it into a map where the key is the SubjectScore__c Id and the value is a list of Score__c records
        Map<Id, List<Score__c>> mapScoresBySubjectScoreId = new Map<Id, List<Score__c>>();
        for (Score__c score : listScores) {
            if (!mapScoresBySubjectScoreId.containsKey(score.SubjectScore_look__c)) {
                mapScoresBySubjectScoreId.put(score.SubjectScore_look__c, new List<Score__c>());
            }
            mapScoresBySubjectScoreId.get(score.SubjectScore_look__c).add(score);
        }

        // create a set of exam types to check if all required exam types are present for each SubjectScore__c Id
        Set<String> setExamTypes = new Set<String>(WEIGHT_MAP.keySet());

        // calculate the average score for each SubjectScore__c Id
        List<SubjectScore__c> listSubjectScoresToUpdate = new List<SubjectScore__c>();
        for (Id subjectScoreId : setSubjectScoreIds) {
            // get the list of Score__c records for this SubjectScore__c Id
            List<Score__c> listScoresBySubjectScoreId = mapScoresBySubjectScoreId.get(subjectScoreId);

            // if there are not exactly 4 Score__c records, skip
            if (listScoresBySubjectScoreId == null || listScoresBySubjectScoreId.size() != 4) {
                continue;
            }

            // check if all exam types are present in the list of Score__c records
            set<String> setScoreExamTypes = new Set<String>();
            for (Score__c score : listScoresBySubjectScoreId) {
                if (String.isBlank(score.ExamType__c)) {
                    continue;
                }
                setScoreExamTypes.add(score.ExamType__c);
            }
            if (!setScoreExamTypes.containsAll(setExamTypes)) {
                continue;
            }

            // calculate the average score for this SubjectScore__c Id
            Decimal averageScore = 0;
            for (Score__c score : listScoresBySubjectScoreId) {
                Decimal weight = WEIGHT_MAP.get(score.ExamType__c);
                if (weight != null && score.Score__c != null) {
                    averageScore += score.Score__c * weight;
                }
            }
            // round the average score to 2 decimal places
            averageScore = averageScore.setScale(2, RoundingMode.HALF_UP);
            // create a new SubjectScore__c record to update the AverageScore__c and Status__c fields
            listSubjectScoresToUpdate.add(new SubjectScore__c(
                Id = subjectScoreId,
                AverageScore__c = averageScore,
                Status__c = averageScore >= PASSING_SCORE ? SUBJECT_STATUS_PASSED : SUBJECT_STATUS_FAILED
            ));
        }

        // update the SubjectScore__c records
        if (listSubjectScoresToUpdate != null && !listSubjectScoresToUpdate.isEmpty()) {
            update listSubjectScoresToUpdate;
        }
    }

    /**
    * getScoresList
    * Score__cレコードを取得する
    * @param: Set<Id> setSubjectScoreIds - SubjectScore__cレコードのIDのセット
    * @return: List<Score__c> - Score__cレコードのリスト
    * @created: 2026/07/01 Nguyen Ngoc Quy
    * @modified:
    */
    private static List<Score__c> getScoresList(Set<Id> setSubjectScoreIds) {
        List<Score__c> listScores = [
            SELECT Id
                , ExamType__c
                , Score__c
                , SubjectScore_look__c
            FROM Score__c
            WHERE SubjectScore_look__c IN :setSubjectScoreIds
        ];
        return listScores;
    }

    // 2026/07/20 Nguyen Ngoc Quy Add start
    /**
    * afterTriggerThrowExceptionForTesting
    * テスト用に例外をスローする
    * @param：なし
    * @return：なし
    * @created：2026/07/20 Nguyen Ngoc Quy
    * @modified：
    */
    private static void afterTriggerThrowExceptionForTesting() {
        if (afterTriggerThrowException && Test.isRunningTest()) {
            throw new CustomException('テスト用の例外が発生しました。');
        }
    }
    // 2026/07/20 Nguyen Ngoc Quy Add end

    /**
    * クラス名   : CustomException
    * クラス概要 : カスタム例外クラス
    * @created  : 2026/07/01 Nguyen Ngoc Quy
    * @modified : 
    */
    private class CustomException extends Exception {}
}