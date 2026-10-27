using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Plugin_Exercise.Common;

namespace Plugin_Exercise
{
    public class Pl_E0002_02 : IPlugin
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

                // Create, Update
                if (context.InputParameters.Contains("Target") 
                    && context.InputParameters["Target"] is Entity)
                {
                    Entity student = (Entity)context.InputParameters["Target"];
                    if (student.LogicalName == ksvc_tra_student.EntityLogicalName)
                    {
                        if (!student.Contains(ksvc_tra_student.Fields.ksvc_lup_class))
                        {
                            throw new Exception(Constant.CLASS_NOT_FOUND_ERROR_MESSAGE);
                        }
                        Guid classId = student.GetAttributeValue<EntityReference>(ksvc_tra_student.Fields.ksvc_lup_class).Id;

                        // Create
                        if (context.MessageName == Constant.CREATE_MESSAGE)
                        {
                            CommonRepository.UpdateNumberofClass(classId, 1);
                        }
                        // Update
                        if (context.MessageName == Constant.UPDATE_MESSAGE)
                        {
                            Entity studentPreImage = (Entity)context.PreEntityImages[Constant.PLUGIN_PREIMAGE];
                            if (student == studentPreImage)
                            {
                                return;
                            }
                            Guid classIdOfPreImage = studentPreImage.GetAttributeValue<EntityReference>(ksvc_tra_student.Fields.ksvc_lup_class).Id;
                            CommonRepository.UpdateNumberofClass(classId, 1);
                            CommonRepository.UpdateNumberofClass(classIdOfPreImage, -1);
                        }
                    }
                }
                
                // Delete
                if (context.InputParameters.Contains("Target") 
                    && context.InputParameters["Target"] is EntityReference 
                    && context.MessageName == Constant.DELETE_MESSAGE)
                {
                    EntityReference student = (EntityReference)context.InputParameters["Target"];
                    Entity studentPreImage = (Entity)context.PreEntityImages[Constant.PLUGIN_PREIMAGE];
                    if (student.LogicalName == ksvc_tra_student.EntityLogicalName)
                    {
                        if (!studentPreImage.Contains(ksvc_tra_student.Fields.ksvc_lup_class))
                        {
                            throw new Exception(Constant.CLASS_NOT_FOUND_ERROR_MESSAGE);
                        }
                        Guid classId = studentPreImage.GetAttributeValue<EntityReference>(ksvc_tra_student.Fields.ksvc_lup_class).Id;
                        CommonRepository.UpdateNumberofClass(classId, -1);
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
