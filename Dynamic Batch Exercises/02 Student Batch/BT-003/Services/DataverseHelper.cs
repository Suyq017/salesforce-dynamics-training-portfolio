using System;
using System.Collections.Generic;
using System.Linq;
using BT_003.Common;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Query;

namespace BT_003.Services
{
    internal class DataverseHelper
    {
        // getStudentsList
        // This method retrieves a list of student records from the Dataverse where the learning status is "Enrolled".
        public static List<ksvc_tra_student> GetStudentsList(IOrganizationService service)
        {
            try
            {
                using (var context = new OrganizationServiceContext(service))
                {
                    return (from s in context.CreateQuery<ksvc_tra_student>()
                            where s.ksvc_opt_learningstatus == ksvc_LearningStatusOption.Enrolled
                            select new ksvc_tra_student
                            {
                                Id = s.ksvc_tra_studentId ?? Guid.Empty,
                            }).ToList();
                }
            }
            catch (Exception e)
            {
                LogHelper.Log($"getStudentsList: {Constant.EXCEPTION_MESSAGE} " + e.Message);
                return null;
            }
        }

        // CalculateTotalCredit
        // This method calculates the total credit for each student in the provided list.
        public static void CalculateTotalCredit(IOrganizationService service, List<ksvc_tra_student> studentsList)
        {
            try
            {
                Dictionary<Guid, List<ksvc_tra_subjectscore>> subjectScoresDic = GetSubjectScoresByStudentIdList(service, studentsList);
                foreach (var student in studentsList)
                {
                    int totalCredit = 0;

                    if (!subjectScoresDic.ContainsKey(student.Id))
                    {
                        LogHelper.Log($"[{student.ksvc_tra_studentId}] has not subject score.");
                        continue;
                    }
                   
                    foreach (var subjectScore in subjectScoresDic[student.Id])
                    {
                        int credit = int.TryParse((subjectScore[Constant.SUBJECT_ALIAS_NAME + "." + ksvc_mst_subject.Fields.ksvc_int_coursecredit] as AliasedValue)?.Value.ToString() ?? "0", out var parsedCredit) ? parsedCredit : 0;
                        totalCredit += credit;
                    }

                    var studentToUpdate = new ksvc_tra_student
                    {
                        Id = student.Id,
                        ksvc_int_toltalcredit = totalCredit
                    };

                    var updateRequest = new UpdateRequest { Target = studentToUpdate };
                    service.Execute(updateRequest);
                }    
            }
            catch (Exception e)
            {
                LogHelper.Log($"CalculateTotalCredit: {Constant.EXCEPTION_MESSAGE} " + e.Message);
            }
        }

        // GetSubjectScoresByStudentIdList
        // This method retrieves subject scores for a list of students.
        private static Dictionary<Guid, List<ksvc_tra_subjectscore>> GetSubjectScoresByStudentIdList(IOrganizationService service, List<ksvc_tra_student> listStudents)
        {
            QueryExpression query = new QueryExpression(ksvc_tra_subjectscore.EntityLogicalName)
            {
                ColumnSet = new ColumnSet(ksvc_tra_subjectscore.Fields.ksvc_lup_student, ksvc_tra_subjectscore.Fields.ksvc_lup_subject),
                Criteria = new FilterExpression(LogicalOperator.And)
                {
                    Conditions =
                            {
                                new ConditionExpression(ksvc_tra_subjectscore.Fields.ksvc_lup_student, ConditionOperator.In, listStudents.Select(s => s.Id).ToArray()),
                                new ConditionExpression(ksvc_tra_subjectscore.Fields.ksvc_opt_status, ConditionOperator.Equal, (int)ksvc_Status.Passed)
                            }
                },
                LinkEntities =
                        {
                            new LinkEntity()
                            {
                                  LinkFromEntityName = ksvc_tra_subjectscore.EntitySchemaName,
                                  LinkToEntityName = ksvc_mst_subject.EntitySchemaName,
                                  LinkFromAttributeName = ksvc_tra_subjectscore.Fields.ksvc_lup_subject,
                                  LinkToAttributeName = ksvc_mst_subject.Fields.Id,
                                  JoinOperator = JoinOperator.Inner,
                                  EntityAlias = Constant.SUBJECT_ALIAS_NAME,
                                  Columns = new ColumnSet(ksvc_mst_subject.Fields.ksvc_int_coursecredit, ksvc_mst_subject.Fields.Id)
                            }
                        }
            };
            return service.RetrieveMultiple(query).Entities.Select(e => e.ToEntity<ksvc_tra_subjectscore>()).ToList()
                .GroupBy(s => s.ksvc_lup_student.Id)
                .ToDictionary(g1 => g1.Key
                            , g1 => (g1.GroupBy(g2 => g2.ksvc_lup_subject.Id).Select(g2 => g2.First()).ToList()));
        }
    }
}