using System;
using System.Collections.Generic;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Plugin_Exercise.Common;

namespace Plugin_Exercise
{
    public class Pl_E0002_01 : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            try
            {
                IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
                // Check if the plugin is being called recursively
                if (context.Depth > 1)
                {
                    throw new Exception(Constant.PLUGIN_LOOP_ERROR_MESSAGE);
                }

                IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                IOrganizationService service = serviceFactory.CreateOrganizationService(context.UserId);
                CommonRepository CommonRepository = new CommonRepository(service);

                if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity)
                {
                    Entity student = (Entity)context.InputParameters["Target"];

                    if (student.LogicalName == ksvc_tra_student.EntityLogicalName)
                    {
                        // Create SubjectScore
                        List<ksvc_mst_semester> listSemester = CommonRepository.GetSemesterList();
                        List<ksvc_mst_subject> listSubject = CommonRepository.GetSubjectList();
                        foreach (ksvc_mst_subject subject in listSubject)
                        {
                            foreach (ksvc_mst_semester semester in listSemester)
                            {
                                ksvc_tra_subjectscore ksvc_mst_subject = new ksvc_tra_subjectscore
                                {
                                    ksvc_lup_student = student.ToEntityReference(),
                                    ksvc_lup_semester = semester.ToEntityReference(),
                                    ksvc_lup_subject = subject.ToEntityReference(),
                                };
                                service.Create(ksvc_mst_subject);
                            }
                        }

                        // Create Score
                        List<ksvc_tra_subjectscore> listSubjectScore = CommonRepository.GetSubjectScoreList(student.Id);
                        foreach (ksvc_tra_subjectscore subjectScore in listSubjectScore)
                        {
                            foreach (ksvc_ExamType examType in Enum.GetValues(typeof(ksvc_ExamType)))
                            {
                                ksvc_tra_score score = new ksvc_tra_score
                                {
                                    ksvc_lup_subjectscore = subjectScore.ToEntityReference(),
                                    ksvc_opt_examtype = examType
                                };
                                service.Create(score);
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                throw new InvalidPluginExecutionException(Constant.UKNOWN_ERROR_MESSAGE + e.Message);
            }
        }
    }
}
