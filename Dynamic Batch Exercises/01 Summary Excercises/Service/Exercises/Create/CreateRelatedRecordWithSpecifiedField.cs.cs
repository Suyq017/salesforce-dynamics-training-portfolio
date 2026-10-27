using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;

namespace Service.Exercises
{
    internal class CreateRelatedRecordWithSpecifiedField
    {
        public static void createRelatedRecordWithSpecifiedField(IOrganizationService svc)
        {
            var Contact = new Contact()
            {
                FirstName = "John",
                LastName = "Doe",
            };
            Guid contactId = svc.Create(Contact);
            Console.WriteLine("contact created with ID: " + contactId.ToString());

            //Use Entity class with entity logical name
            var account = new Entity("account");

            account["primarycontactid"] = new EntityReference("contact", contactId);

            //Create the account
            Guid accountid = svc.Create(account);
            Console.WriteLine("account created with ID: " + accountid.ToString());
        }
    }
}
