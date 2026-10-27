using System;
using System.Collections.Generic;
using CrmEarlyBound;

namespace Plugin_Exercise.Interfaces
{
    public interface ICommonRepository
    {
        decimal CalculateAverageScore(List<ksvc_tra_score> listScore);
        void UpdateNumberofClass(Guid classID, int updateValue);

        List<ksvc_mst_semester> GetSemesterList();
        List<ksvc_mst_subject> GetSubjectList();

        List<ksvc_tra_subjectscore> GetSubjectScoreList(Guid studentId);

        List<ksvc_tra_score> GetScoreList(Guid subjectScoreId);

        Guid GetSubjectScoreId(Guid scoreId);
    }
}
