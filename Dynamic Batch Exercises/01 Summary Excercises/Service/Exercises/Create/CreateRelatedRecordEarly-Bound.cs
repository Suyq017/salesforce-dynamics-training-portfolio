using System;
using System.Collections.Generic;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class CreateRelatedRecordEarly_Bound
    {
        public static void CreateRelatedRecordEarlyBound(IOrganizationService svc)
        {
            var account = new Account();
            // set attribute values
            // string primary name
            account.Name = "Sample Account";

            // Set the account primary contact
            account.account_primary_contact = new Contact()
            { FirstName = "John", LastName = "Smith" };

            // Set a list of Tasks to create
            account.Account_Tasks = new List<Task>() {
                new Task() { Subject = "Task 1" },
                new Task() { Subject = "Task 2" },
                new Task() { Subject = "Task 3" }
            };

            // Create the account
            Guid accountId = svc.Create(account);

            Account retrievedAccount = svc.Retrieve("account", accountId, new ColumnSet("primarycontactid")) as Account;

            Console.WriteLine("Account created with : " + retrievedAccount.Id.ToString());
            Console.WriteLine("Primary Contact created with ID: " + retrievedAccount.PrimaryContactId.Id.ToString());
        }
    }
}
