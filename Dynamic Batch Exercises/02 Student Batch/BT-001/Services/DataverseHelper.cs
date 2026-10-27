using System;
using System.Collections.Generic;
using System.Linq;
using BT_001.Common;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Query;

namespace BT_001.Services
{
    internal class DataverseHelper
    {
        // GetClassDictionaryByListCode
        // return a dictionary of ksvc_mst_class entities where the key is the class code and the value is the corresponding ksvc_mst_class entity.
        public static Dictionary<string, ksvc_mst_class> GetClassDictionaryByListCode(List<string> listClassCode, IOrganizationService service)
        {
            try
            {
                QueryExpression query = new QueryExpression(ksvc_mst_class.EntityLogicalName)
                {
                    ColumnSet = new ColumnSet(ksvc_mst_class.Fields.ksvc_slt_classcode),
                    Criteria =
                    {
                        Conditions = {
                            new ConditionExpression(ksvc_mst_class.Fields.ksvc_slt_classcode, ConditionOperator.In, listClassCode)
                        }
                    }
                };
                List<ksvc_mst_class> results = service.RetrieveMultiple(query).Entities.Select(e => e.ToEntity<ksvc_mst_class>()).ToList();
                Dictionary<string, ksvc_mst_class> classDic = new Dictionary<string, ksvc_mst_class>();
                foreach (ksvc_mst_class cls in results)
                {
                    classDic.Add(cls.ksvc_slt_classcode, cls);
                }
                return classDic;
            }
            catch (System.Exception ex)
            {
                LogHelper.Log($"GetClassDictionaryByListCode: {Constant.EXCEPTION_MESSAGE} : {ex.Message}");
                return new Dictionary<string, ksvc_mst_class>();
            }

        }

        // CreateListStudent
        // This method creates a list of student records in Dataverse.
        public static void CreateListStudent(List<ksvc_tra_student> studentsList, IOrganizationService service)
        {
            try
            {
                List<List<ksvc_tra_student>> studentsListBatch = SplitList(studentsList, Constant.BATCH_SIZE);

                foreach (List<ksvc_tra_student> students in studentsListBatch)
                {

                    ExecuteMultipleRequest requestWithResults = new ExecuteMultipleRequest()
                    {
                        Settings = new ExecuteMultipleSettings()
                        {
                            ContinueOnError = true,
                            ReturnResponses = true
                        },
                        Requests = new OrganizationRequestCollection()
                    };

                    foreach (ksvc_tra_student student in students)
                    {
                        CreateRequest createRequest = new CreateRequest { Target = student };
                        requestWithResults.Requests.Add(createRequest);
                    }

                    ExecuteMultipleResponse responseWithResults =
                        (ExecuteMultipleResponse)service.Execute(requestWithResults);

                    Dictionary <Guid, string> classCodeDic = Program.ClassDic.ToDictionary(kvp => kvp.Value.Id, kvp => kvp.Value.ksvc_slt_classcode);
                    foreach (var response in responseWithResults.Responses)
                    {
                        var student = students[response.RequestIndex];
                        if (response.Fault != null)
                        {
                            LogHelper.Log($"createListStudent: Error creating student record. {response.Fault.Message}");
                            Program.ErrorLine.Add($"\"{student.ksvc_slt_studentname}\",\"{student.ksvc_lup_class.Name}\",\"{student.ksvc_opt_gender}\",\"{student.ksvc_dat_birthday?.ToString(Constant.DATE_FORMAT)}\",\"{student.ksvc_opt_learningstatus}\"");
                            continue;
                        }
                        Program.SuccessLine.Add($"\"{student.ksvc_slt_studentname}\",\"{classCodeDic[student.ksvc_lup_class.Id]}\",\"{student.ksvc_opt_gender}\",\"{student.ksvc_dat_birthday?.ToString(Constant.DATE_FORMAT)}\",\"{student.ksvc_opt_learningstatus}\"");
                    }
                }
            }
            catch (System.Exception ex)
            {
                LogHelper.Log($"createListStudent: {Constant.EXCEPTION_MESSAGE} : {ex.Message}");
            }
        }

        // SplitList
        // This method splits a list of ksvc_tra_student entities into smaller batches of a specified size.
        private static List<List<ksvc_tra_student>> SplitList(List<ksvc_tra_student> source, int chunkSize)
        {
            return source
                .Select((x, i) => new { Index = i, Value = x })
                .GroupBy(x => x.Index / chunkSize)
                .Select(x => x.Select(v => v.Value).ToList())
                .ToList();
        }
    }
}
