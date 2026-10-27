using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Summary_Exercises
{
    public class ImagePlugin : IPlugin
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
                    Entity studentPreImage = (Entity)context.PreEntityImages["PreImage"];
                    Entity studentPostImage = (Entity)context.PostEntityImages["PostImage"];

                    if (student.Contains(ksvc_tra_student.Fields.ksvc_slt_studentname))
                    {
                        string preName = studentPreImage.Contains(ksvc_tra_student.Fields.ksvc_slt_studentname) ? studentPreImage[ksvc_tra_student.Fields.ksvc_slt_studentname].ToString() : string.Empty;
                        string postName = studentPostImage.Contains(ksvc_tra_student.Fields.ksvc_slt_studentname) ? studentPostImage[ksvc_tra_student.Fields.ksvc_slt_studentname].ToString() : string.Empty;
                        tracingService.Trace($"Pre-Image Name: {preName}");
                        tracingService.Trace($"Post-Image Name: {postName}");
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
