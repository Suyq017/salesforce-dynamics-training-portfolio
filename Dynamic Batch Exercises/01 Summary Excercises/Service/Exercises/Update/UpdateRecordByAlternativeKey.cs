using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises.Update
{
    internal class UpdateRecordByAlternativeKey
    {
        public static void UpdateRecordByAlternativeKeyFunc(IOrganizationService service) 
        {
            // This environment has an alternate key set for the accountnumber attribute.

            //Instantiate account entity with accountnumber value
            var account = new Entity("account", "accountnumber", "0015");
            account["name"] = "New Account";

            //Use Upsert the first time
            UpsertRequest request1 = new UpsertRequest()
            {
                Target = account
            };

            //The new entity is created
            var response1 = (UpsertResponse)service.Execute(request1);
            Console.WriteLine("Record Created: {0}", response1.RecordCreated); //true

            //Update the name of the existing account entity
            account["name"] = "Updated Account";

            //Use Upsert for the second time
            UpsertRequest request2 = new UpsertRequest()
            {
                Target = account
            };

            //The existing entity is updated.
            var response2 = (UpsertResponse)service.Execute(request2);
            Console.WriteLine("Record Created: {0}", response2.RecordCreated); //false
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
