using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Service.Exercises
{
    internal class test
    {
        public static void testFunc(IOrganizationService service)
        {
            var context = new OrganizationServiceContext(service);

            //var query1 = from c in context.CreateQuery<ksvc_mst_class>()
            //             where c.ksvc_slt_classcode == "CL0009"
            //             select c;
            //ksvc_mst_class classEntity = query1.FirstOrDefault();
            //Console.WriteLine($"Class Code: {classEntity.ksvc_slt_classcode}");

            var query2 = from s in context.CreateQuery<ksvc_tra_student>()
                         where s.ksvc_lup_class.Id == new Guid("b288454c-bc96-f111-b8dc-002248b2d5e2")
                         && s.ksvc_opt_learningstatus == ksvc_LearningStatusOption.Enrolled
                         select s;
            foreach (ksvc_tra_student student in query2)
            {
                Console.WriteLine($"Student Name: {student.ksvc_slt_studentname}");
            }
        } 
    }
}
