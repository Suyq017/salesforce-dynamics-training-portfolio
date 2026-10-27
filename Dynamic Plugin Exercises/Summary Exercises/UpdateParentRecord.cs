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
    public class UpdateParentRecord : IPlugin
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
                        var query1 = from s in context1.CreateQuery<ksvc_mst_class>()
                                     where s.Id == ((EntityReference)entity[ksvc_tra_student.Fields.ksvc_lup_class]).Id
                                     select s;
                        ksvc_mst_class classEntity = query1.FirstOrDefault();
                        var numberOfStudents = classEntity.GetAttributeValue<int>(ksvc_mst_class.Fields.ksvc_int_numberofstudent);
                        numberOfStudents++;

                        var classToUpdate = new ksvc_mst_class
                        {
                            Id = classEntity.Id,
                            ksvc_int_numberofstudent = numberOfStudents
                        };
                        service.Update(classToUpdate);
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
