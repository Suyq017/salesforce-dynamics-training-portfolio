using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Identity.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class GetRecordRetrieveRequest
    {
        public static void getRecordRetrieve(IOrganizationService svc)
        {
            var account = new Account()
            {
                Name = "Sample Account for Retrieve",
            };
            Guid accountId = svc.Create(account);
            Console.WriteLine("account created with ID: " + accountId.ToString());

            RetrieveRequest request = new RetrieveRequest()
            {
                ColumnSet = new ColumnSet("name"),
                Target = new EntityReference("account", accountId)
            };
            var response = (RetrieveResponse)svc.Execute(request);
            Entity entity = response.Entity;
            Console.WriteLine("account name: {0}", entity["name"]);
        }
    }
}
