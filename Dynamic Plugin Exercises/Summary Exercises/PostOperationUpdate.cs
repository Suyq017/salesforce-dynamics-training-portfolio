using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;
using System.Linq;
namespace Carl.PluginPostOperationSample
{
    public class PostOperationUpdate : IPlugin
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

                if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity)
                {
                    // Obtain the target entity from the input parameters.
                    Entity entity = (Entity)context.InputParameters["Target"];

                    if (entity.LogicalName == ksvc_tra_student.EntityLogicalName)
                    {
                        var query1 = from s in context1.CreateQuery<ksvc_mst_subject>()
                                      select s;
                        var query2 = from s in context1.CreateQuery<ksvc_mst_semester>()
                                     select s;

                        ksvc_tra_subjectscore subjectscore = new ksvc_tra_subjectscore();
                        subjectscore.ksvc_lup_student = new EntityReference(ksvc_tra_student.EntityLogicalName, entity.Id);
                        subjectscore.ksvc_lup_semester = new EntityReference(ksvc_mst_semester.EntityLogicalName, query2.FirstOrDefault().Id);
                        subjectscore.ksvc_lup_subject = new EntityReference(ksvc_mst_subject.EntityLogicalName, query1.FirstOrDefault().Id);
                        service.Create(subjectscore);
                    }
                }
            }
            catch (InvalidPluginExecutionException e)
            {
                throw new InvalidPluginExecutionException("An error has occurred: " + e.Message);
            }
        }
    }
}