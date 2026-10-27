using System;
using System.Collections.Generic;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Summary_Exercises.Asserts
{
    public class DeleteRecord : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            try
            {
                ITracingService tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
                IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));

                IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                IOrganizationService service = serviceFactory.CreateOrganizationService(context.UserId);
                var context1 = new OrganizationServiceContext(service);

                if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is EntityReference)
                {
                    EntityReference entityReference = (EntityReference)context.InputParameters["Target"];
                    tracingService.Trace("EntityReference: " + entityReference.LogicalName + ", Id: " + entityReference.Id);

                    if (entityReference.LogicalName == ksvc_mst_class.EntityLogicalName)
                    {
                        var query1 = from s in context1.CreateQuery<ksvc_tra_student>()
                                     where s.ksvc_lup_class.Id == entityReference.Id
                                     && s.ksvc_opt_learningstatus == ksvc_LearningStatusOption.Enrolled
                                     select s;
                        List<ksvc_tra_student> studentsToDelete = query1.ToList();
                        tracingService.Trace("Number :" + studentsToDelete.Count());
                        foreach (ksvc_tra_student student in studentsToDelete)
                        {
                            service.Delete(ksvc_tra_student.EntityLogicalName, student.Id);
                        }

                        var query2 = from s in context1.CreateQuery<ksvc_tra_student>()
                                     where s.ksvc_lup_class.Id == entityReference.Id
                                     && s.ksvc_opt_learningstatus == ksvc_LearningStatusOption.Enrolled
                                     select s;
                        ksvc_tra_student stu = query2.FirstOrDefault();
                        if (stu != null)
                        {
                            throw new InvalidPluginExecutionException("Cannot delete the class because student not be deleted");
                        }
                    }
                }
            }
            catch (InvalidPluginExecutionException e)
            {
                // catch exception
                throw new InvalidPluginExecutionException("An error has occurred: " + e.Message);
            }
        }
    }
}
