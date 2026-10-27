using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Identity.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class GetRecordRetrieve
    {
        public static void getRecordRetrieve(IOrganizationService svc)
        {
            var account = new Account()
            {
                Name = "Sample Account for Retrieve",
            };
            Guid accountId = svc.Create(account);
            Console.WriteLine("account created with ID: " + accountId.ToString());

            Account retrievedAccount = svc.Retrieve("account", accountId, new ColumnSet("name")) as Account;
            Console.WriteLine("account name: {0}", retrievedAccount.Name);
            Console.WriteLine("account id: {0}", retrievedAccount.Id.ToString());
        }
    }
}
