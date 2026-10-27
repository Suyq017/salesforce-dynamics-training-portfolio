using System;
using System.Collections.Generic;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Xrm.Sdk.Query;
namespace Service.Exercises
{
    internal class GetRecordByRelationshipQueryCollection
    {
        public static void getRecordByRelationshipQueryCollection(IOrganizationService svc)
        {
            var contact = new Contact()
            {
                FirstName = "Sample",
                LastName = "Contact for QueryCollection",
            };
            Guid contactId = svc.Create(contact);
            Console.WriteLine("contact created with ID: " + contactId.ToString());

            var account = new Account()
            {
                Name = "Sample Account for QueryCollection",
            };
            account.Account_Tasks = new List<Task>() {
                new Task() { Subject = "Task 1" },
                new Task() { Subject = "Task 2" },
                new Task() { Subject = "Task 3" }
            };
            account["primarycontactid"] = new EntityReference("contact", contactId);

            Guid accountId = svc.Create(account);
            Console.WriteLine("account created with ID: " + accountId.ToString());
            var relationshipQueryCollection = new RelationshipQueryCollection();

            var relatedTasks = new QueryExpression("task");
            relatedTasks.ColumnSet = new ColumnSet("subject", "description");
            var taskRelationship = new Relationship("Account_Tasks");
            relationshipQueryCollection.Add(taskRelationship, relatedTasks);


            var relatedContacts = new QueryExpression("contact");
            relatedContacts.ColumnSet = new ColumnSet("fullname", "emailaddress1");
            var contactRelationship = new Relationship("account_primary_contact");
            relationshipQueryCollection.Add(contactRelationship, relatedContacts);

            var request = new RetrieveRequest()
            {
                ColumnSet = new ColumnSet(true),
                RelatedEntitiesQuery = relationshipQueryCollection,
                Target = new EntityReference("account", accountId)
            };

            RetrieveResponse response = (RetrieveResponse)svc.Execute(request);

            Entity retrievedAccount = response.Entity;

            Console.WriteLine("Account Name: {0}", retrievedAccount["name"]);

            var tasks = retrievedAccount.RelatedEntities[new Relationship("Account_Tasks")];

            Console.WriteLine("Tasks:");
            tasks.Entities.ToList().ForEach(x => {
                Console.WriteLine(" Task Subject: {0}", x["subject"]);
            });

            Entity primaryContact = retrievedAccount
              .RelatedEntities[new Relationship("account_primary_contact")]
              .Entities.FirstOrDefault();

            Console.WriteLine("Primary Contact Fullname: {0}", primaryContact["fullname"]);
        }
    }
}
