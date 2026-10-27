using System;
using CrmEarlyBound;
using Microsoft.Crm.Sdk.Messages;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class CheckDuplicate
    {
        public static void checkDuplicateFunc(IOrganizationService service)
        {
            var account = new Account();
            account.Name = "Sample Account";

            var request = new RetrieveDuplicatesRequest()
            {
                BusinessEntity = account,
                MatchingEntityName = account.LogicalName,
                PagingInfo = new PagingInfo() { PageNumber = 1, Count = 50 }
            };

            var response = (RetrieveDuplicatesResponse)service.Execute(request);

            if (response.DuplicateCollection.Entities.Count >= 1)
            {
                Console.WriteLine("{0} Duplicate rows found.", response.DuplicateCollection.Entities.Count);
            }
        }
    }
}
