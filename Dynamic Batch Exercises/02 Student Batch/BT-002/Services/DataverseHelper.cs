using System;
using System.Collections.Generic;
using System.Linq;
using BT_002.Common;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;
using Microsoft.Xrm.Sdk.Messages;

namespace BT_002.Services
{
    internal class DataverseHelper
    {
        // GetStudentsList
        // This method retrieves a list of student records from the Dataverse where the learning status is "Enrolled".
        public static List<ksvc_tra_student> GetStudentsList(IOrganizationService service)
        {
            try
            {
                using (var context = new OrganizationServiceContext(service))
                {
                    return (from s in context.CreateQuery<ksvc_tra_student>()
                            where s.ksvc_opt_learningstatus == ksvc_LearningStatusOption.Enrolled
                            select s).ToList();
                }
            }
            catch (Exception e)
            {
                LogHelper.Log($"getStudentsList: {Constant.EXCEPTION_MESSAGE} " + e.Message);
                return null;
            }
        }

        // CalculateGPAScore
        // This method calculates the GPA score for each student in the provided list based on their subject scores.
        public static void CalculateGPAScore(IOrganizationService service, List<ksvc_tra_student> studentsList)
        {
            try
            {
                foreach (var student in studentsList)
                {
                    Decimal averageScore = 0;
                    int count = 0;

                    OrganizationServiceContext context = new OrganizationServiceContext(service);
                    List<ksvc_tra_subjectscore> subjectScores = GetSubjectScoresByStudentId(context, student);
                    if (subjectScores == null || subjectScores.Count == 0)
                    {
                        continue;
                    }

                    Dictionary<Guid, ksvc_tra_subjectscore> subjectScoresDict = new Dictionary<Guid, ksvc_tra_subjectscore>();
                    foreach (var subjectScore in subjectScores)
                    {
                        if (!subjectScoresDict.ContainsKey(subjectScore.ksvc_lup_subject.Id))
                        {
                            subjectScoresDict.Add(subjectScore.ksvc_lup_subject.Id, subjectScore);
                            count++;
                            averageScore += subjectScore.ksvc_dcn_averagescore ?? 0;
                        }
                        else
                        {
                            if ((subjectScoresDict[subjectScore.ksvc_lup_subject.Id].ksvc_dcn_averagescore ?? 0) < (subjectScore.ksvc_dcn_averagescore ?? 0))
                            {
                                averageScore = averageScore
                                    - (subjectScoresDict[subjectScore.ksvc_lup_subject.Id].ksvc_dcn_averagescore ?? 0)
                                    + (subjectScore.ksvc_dcn_averagescore ?? 0);
                                subjectScoresDict[subjectScore.ksvc_lup_subject.Id] = subjectScore;
                            }
                        }
                    }

                    if (count > 0)
                    {
                        averageScore = averageScore / count;
                    }

                    var studentToUpdate = new ksvc_tra_student
                    {
                        Id = student.ksvc_tra_studentId ?? Guid.Empty,
                        ksvc_dcn_gpascore = averageScore
                    };
                    var updateRequest = new UpdateRequest { Target = studentToUpdate };
                    service.Execute(updateRequest);
                }

            }
            catch (Exception e)
            {
                LogHelper.Log($"CalculateGPAScore: {Constant.EXCEPTION_MESSAGE} " + e.Message);
            }
        }

        // GetSubjectScoresByStudentId
        // This method retrieves a list of subject score records for a specific student based on their student ID.
        private static List<ksvc_tra_subjectscore> GetSubjectScoresByStudentId(OrganizationServiceContext context, ksvc_tra_student student)
        {
            return (from sc in context.CreateQuery<ksvc_tra_subjectscore>()
                    where sc.ksvc_lup_student.Id == student.ksvc_tra_studentId
                    select sc).ToList();
        }
    }
}
