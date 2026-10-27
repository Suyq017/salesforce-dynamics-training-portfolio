using System;
using System.Collections.Generic;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class GetManyByAttribute
    {
        public static void GetManyByAttributeFunc(IOrganizationService svc)
        {
            QueryByAttribute query = new QueryByAttribute("account")
            {
                ColumnSet = new ColumnSet("name"),
                Attributes = { "name" },
                Values = { "Contoso" }
            };
            List<Account> lst = svc.RetrieveMultiple(query).Entities.Select(e => e.ToEntity<Account>()).ToList();
            foreach (Account account in lst)
            {
                Console.WriteLine(account.Name);
            }
        }
    }
}
