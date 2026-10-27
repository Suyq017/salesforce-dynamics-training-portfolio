using System;
using System.Collections.Generic;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class GetManyRecord
    {
        public static void GetManyRecordFunc(IOrganizationService svc)
        {
            QueryExpression query = new QueryExpression("account")
            {
                ColumnSet = new ColumnSet("name"),
                Criteria = new FilterExpression(LogicalOperator.And)
                {
                    Conditions =
                    {
                        new ConditionExpression("name", ConditionOperator.Like, "Contoso%"),
                        new ConditionExpression("numberofemployees", ConditionOperator.Equal, 500)
                    }
                }
            };
            List<Account> results = svc.RetrieveMultiple(query).Entities.Select(e => e.ToEntity<Account>()).ToList();
            foreach (Account account in results)
            {
                Console.WriteLine(account.Name);
            }
        }
    }
}
