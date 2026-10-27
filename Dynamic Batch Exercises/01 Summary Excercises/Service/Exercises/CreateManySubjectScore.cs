using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Query;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Rebar;

namespace Service.Exercises
{
    internal class CreateManySubjectScore
    {
        private static string studentcode = "SD00000013"; // Replace with actual student code"
        public static void CreateManySubjectScoreFunc(IOrganizationService service)
        {
            // Create an ExecuteMultipleRequest object.
            ExecuteMultipleRequest requestWithResults = new ExecuteMultipleRequest()
            {
                // Assign settings that define execution behavior: continue on error, return responses. 
                Settings = new ExecuteMultipleSettings()
                {
                    ContinueOnError = false,
                    ReturnResponses = true
                },
                // Create an empty organization request collection.
                Requests = new OrganizationRequestCollection()
            };

            // Create several (local, in memory) entities in a collection. 
            List<ksvc_tra_subjectscore> input = GetCollectionOfEntitiesToCreate(service);

            // Add a CreateRequest for each entity to the request collection.
            foreach (var entity in input)
            {
                CreateRequest createRequest = new CreateRequest { Target = entity};
                requestWithResults.Requests.Add(createRequest);
            }

            // Execute all the requests in the request collection using a single web method call.
            ExecuteMultipleResponse responseWithResults =
                (ExecuteMultipleResponse)service.Execute(requestWithResults);

            // Display the results returned in the responses.
            foreach (var responseItem in responseWithResults.Responses)
            {
                // A valid response.
                if (responseItem.Response != null)
                    Console.WriteLine($"Request at index {responseItem.RequestIndex} succeeded.");

                // An error has occurred.
                else if (responseItem.Fault != null)
                    Console.WriteLine($"Error occurred for request at index {responseItem.RequestIndex}: {responseItem.Fault.Message}");
            }
        }

        private static List<ksvc_tra_subjectscore> GetCollectionOfEntitiesToCreate(IOrganizationService service)
        {
            List<ksvc_mst_subject> subjects = new List<ksvc_mst_subject>();
            QueryExpression queryExpression1 = new QueryExpression("ksvc_mst_subject") 
            {
                    ColumnSet = new ColumnSet("ksvc_mst_subjectid"),
            };
            subjects = service.RetrieveMultiple(queryExpression1).Entities.Select(e => e.ToEntity<ksvc_mst_subject>()).ToList();

            List<ksvc_mst_semester> semesters = new List<ksvc_mst_semester>();
            QueryExpression queryExpression2 = new QueryExpression("ksvc_mst_semester")
            {
                ColumnSet = new ColumnSet("ksvc_mst_semesterid"),
            };
            semesters = service.RetrieveMultiple(queryExpression2).Entities.Select(e => e.ToEntity<ksvc_mst_semester>()).ToList();

            ksvc_tra_student student = new ksvc_tra_student();
            QueryExpression queryExpression3 = new QueryExpression("ksvc_tra_student")
            {
                ColumnSet = new ColumnSet("ksvc_tra_studentid"),
                Criteria = new FilterExpression()
                {
                    Conditions =
                    {
                        new ConditionExpression("ksvc_slt_studentcode", ConditionOperator.Equal, studentcode) // Replace with actual student ID
                    }
                }
            };
            student = service.RetrieveMultiple(queryExpression3).Entities.Select(e => e.ToEntity<ksvc_tra_student>()).FirstOrDefault();

            List<ksvc_tra_subjectscore> s = new List<ksvc_tra_subjectscore>();
            foreach (ksvc_mst_semester semester in semesters)
            {
                foreach(ksvc_mst_subject subject in subjects)
                {
                    ksvc_tra_subjectscore entity = new ksvc_tra_subjectscore();
                    entity["ksvc_lup_subject"] = new EntityReference("ksvc_mst_subject", subject.Id);
                    entity["ksvc_lup_semester"] = new EntityReference("ksvc_mst_semester", semester.Id);
                    entity["ksvc_lup_student"] = new EntityReference("ksvc_tra_student", student.Id);
                    decimal score = (decimal)(new Random().NextDouble()) *10;
                    entity["ksvc_dcn_averagescore"] = score;
                    if (score < 4)
                    {
                        entity.ksvc_opt_status = ksvc_Status.Notpassed;
                    } else entity.ksvc_opt_status = ksvc_Status.Passed;
                    s.Add(entity);
                }
            }
            return s;

        }
    }
}
