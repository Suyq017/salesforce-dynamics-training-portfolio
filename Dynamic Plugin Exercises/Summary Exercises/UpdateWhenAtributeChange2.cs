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
    public class UpdateWhenAtributeChange2 : IPlugin
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
                        if (entity.Contains(ksvc_tra_student.Fields.ksvc_slt_studentname))
                        {
                            if (context.Depth > 2)
                            {
                                return;
                            }
                            tracingService.Trace("Plugin 2 called for student name change.");
                            string studentName = entity.GetAttributeValue<string>(ksvc_tra_student.Fields.ksvc_slt_studentname);
                            string updatedName = studentName + " Updated 2";
                            entity[ksvc_tra_student.Fields.ksvc_slt_studentname] = updatedName;
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
