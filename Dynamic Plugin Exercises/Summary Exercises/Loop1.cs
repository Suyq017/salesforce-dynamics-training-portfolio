using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Summary_Exercises
{
    public class Loop1 : IPlugin
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

                    if (student.Contains(ksvc_tra_student.Fields.ksvc_slt_studentname))
                    {
                        decimal gpaScore = Decimal.TryParse(student.GetAttributeValue<string>(ksvc_tra_student.Fields.ksvc_slt_studentname), out decimal result) ? result : 0;
                        gpaScore += 0.5m; // Increase GPA score by 0.5
                        var studentToUpdate = new ksvc_tra_student
                        {
                            Id = student.Id,
                            ksvc_slt_studentname = gpaScore.ToString()
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
