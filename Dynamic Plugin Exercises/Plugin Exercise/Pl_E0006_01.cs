using System;
using System.Collections.Generic;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Plugin_Exercise.Common;

namespace Plugin_Exercise
{
    public class Pl_E0006_01 : IPlugin
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
                    Entity score = (Entity)context.InputParameters["Target"];
                    if (score.LogicalName == ksvc_tra_score.EntityLogicalName)
                    {
                        // Check update message and compare the score with the pre-image to avoid unnecessary updates
                        if (context.MessageName == Constant.UPDATE_MESSAGE)
                        {
                            Entity scorePreImage = (Entity)context.PreEntityImages[Constant.PLUGIN_PREIMAGE];
                            if (score == scorePreImage)
                            {
                                return;
                            }
                        }

                        Guid subjectScoreID = CommonRepository.GetSubjectScoreId(score.Id);
                        List<ksvc_tra_score> listScore = CommonRepository.GetScoreList(subjectScoreID);
                        // Check if the number of scores is not equal to the full score, if not return without updating
                        if (listScore.Count != Constant.FULL_SCORE)
                        {
                            return;
                        }

                        decimal averageScore = CommonRepository.CalculateAverageScore(listScore);
                        var subjectScore = new ksvc_tra_subjectscore()
                        {
                            Id = subjectScoreID,
                            ksvc_dcn_averagescore = averageScore
                        };
                        service.Update(subjectScore);
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
