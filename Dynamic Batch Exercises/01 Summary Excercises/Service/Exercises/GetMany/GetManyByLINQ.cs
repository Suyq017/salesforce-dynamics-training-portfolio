using System;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Service.Exercises
{
    internal class GetManyByLINQ
    {
        public static void GetManyByLINQFunc(IOrganizationService svc)
        {
            using (var context = new OrganizationServiceContext(svc))
            {
                var query1 = from a in context.CreateQuery<Account>()
                             where a.Name == "Contoso"
                             select a;
                foreach (var account in query1)
                {
                    Console.WriteLine(account.Name);
                }
            }
        }
    }
}
