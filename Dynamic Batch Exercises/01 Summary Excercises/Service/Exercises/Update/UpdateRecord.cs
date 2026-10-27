using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises.Update
{
    internal class UpdateRecord
    {
        public static void UpdateRecordFunc(IOrganizationService service)
        {
            Guid accountId = createRecord(service);
            Account a = getRecord(accountId, service);
            Console.WriteLine($"Before Updated Name: {a["name"]}");
            Console.WriteLine($"Before Updated Telephone: {a["telephone1"]}");

            // Create a new entity object with the logical name of the table you want to update
            Account accountToUpdate = new Account();
            // Set the ID of the record you want to update
            accountToUpdate.Id = new Guid(accountId.ToString());
            // Set the attributes you want to update
            accountToUpdate.Name = "Updated Account Name";
            accountToUpdate.Telephone1 = "123-456-7890";
            // Call the Update method to update the record
            service.Update(accountToUpdate);
            Console.WriteLine("Record updated successfully.");

            a = getRecord(accountId, service);
            Console.WriteLine($"After Updated Name: {a["name"]}");
            Console.WriteLine($"After Updated Telephone: {a["telephone1"]}");
        }

        private static Account getRecord(Guid recordId, IOrganizationService service)
        {
            // Retrieve the updated record to verify the changes
            Account updatedEntity = service.Retrieve("account", recordId, new ColumnSet("name", "telephone1")).ToEntity<Account>();
            return updatedEntity;
        }

        private static Guid createRecord(IOrganizationService service)
        {
            Account a = new Account()
            {
                Name = "Test Account",
                Telephone1 = "987-654-3210"
            };
            return service.Create(a);
        }
    }
}
