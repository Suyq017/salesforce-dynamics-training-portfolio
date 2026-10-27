using System;
using System.Collections.Generic;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises.Update
{
    internal class UpdateRelated
    {
        public static void UpdateRelatedFunc(IOrganizationService service)
        {
            Guid accountId = createRecord(service);
            Account a = getRecord(accountId, service);
            Console.WriteLine($"Before Updated Name: {a["name"]}");

            Contact c = getContact(a.PrimaryContactId.Id, service);
            Console.WriteLine("Before Updated Primary Contact Email: " + c.EMailAddress1);

            // Create a new entity object with the logical name of the table you want to update
            Account accountToUpdate = new Account();
            // Set the ID of the record you want to update
            accountToUpdate.Id = new Guid(accountId.ToString());
            // Set the attributes you want to update
            accountToUpdate.Name = "Updated Account Name";
            // Call the Update method to update the record

            //Update the email address for the primary contact of the account
            accountToUpdate.account_primary_contact = new Contact
            { Id = a.PrimaryContactId.Id, EMailAddress1 = "someone_a@example.com" };

            service.Update(accountToUpdate);

            Console.WriteLine("Record updated successfully.");
            a = getRecord(accountId, service);
            Console.WriteLine($"After Updated Name: {a["name"]}");
            c = getContact(a.PrimaryContactId.Id, service);
            Console.WriteLine("After Updated Primary Contact Email: " + c.EMailAddress1);
        }

        private static Account getRecord(Guid recordId, IOrganizationService service)
        {
            // Retrieve the updated record to verify the changes
            Account updatedEntity = service.Retrieve("account", recordId, new ColumnSet("name", "telephone1", "primarycontactid")).ToEntity<Account>();
            return updatedEntity;
        }

        private static Contact getContact(Guid recordId, IOrganizationService service)
        {
            Contact contact = service.Retrieve("contact", recordId, new ColumnSet("emailaddress1")).ToEntity<Contact>();
            return contact;
        }

        private static Guid createRecord(IOrganizationService service)
        {
            var contact = new Contact()
            {
                FirstName = "Sample",
                LastName = "Contact for QueryCollection",
                EMailAddress1 = "testemail@gmail.com"
            };
            Guid contactId = service.Create(contact);
            Console.WriteLine("contact created with ID: " + contactId.ToString());

            var account = new Account()
            {
                Name = "Sample Account for QueryCollection",
            };
            account["primarycontactid"] = new EntityReference("contact", contactId);
            return service.Create(account);
        }
    }
}
