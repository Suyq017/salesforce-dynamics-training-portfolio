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
    public class Loop2 : IPlugin
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
                    Entity student = (Entity)context.InputParameters["Target"];

                    if (student.Contains(ksvc_tra_student.Fields.ksvc_dcn_gpascore))
                    {
                        string name = student.Contains(ksvc_tra_student.Fields.ksvc_slt_studentname) ? student[ksvc_tra_student.Fields.ksvc_slt_studentname].ToString() : string.Empty;
                        name += " Loop 2";
                        var studentToUpdate = new ksvc_tra_student
                        {
                            Id = student.Id,
                            ksvc_slt_studentname = name
                        };
                        service.Update(studentToUpdate);
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
