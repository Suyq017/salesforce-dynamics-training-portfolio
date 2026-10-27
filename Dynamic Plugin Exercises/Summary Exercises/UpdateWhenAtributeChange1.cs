using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Summary_Exercises
{
    public class UpdateWhenAtributeChange1 : IPlugin
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
                    Entity entity = (Entity)context.InputParameters["Target"];

                    if (entity.LogicalName == ksvc_tra_student.EntityLogicalName)
                    {
                            if (context.Depth > 1)
                            {
                                return; // Prevent infinite loop
                            }
                            tracingService.Trace("Plugin 1 called for student name change.");
                            var entityToUpdate = new ksvc_tra_student
                            {
                                Id = entity.Id,
                                ksvc_slt_studentname = "Updated 1"
                            };
                            service.Update(entityToUpdate);
                      
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
