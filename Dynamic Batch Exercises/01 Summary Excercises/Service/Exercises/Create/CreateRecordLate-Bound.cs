using System;
using Microsoft.Xrm.Sdk;

namespace Service.Exercises
{
    internal class CreateRecordLate_Bound
    {
        public static void CreateRecordLateBound(IOrganizationService svc)
        {
            //Use Entity class with entity logical name
            var account = new Entity("account");

            // set attribute values
            // string primary name
            account["name"] = "Contoso";
            // Boolean (Two option)
            account["creditonhold"] = false;
            // DateTime
            account["lastonholdtime"] = new DateTime(2017, 1, 1);
            // Double
            account["address1_latitude"] = 47.642311;
            account["address1_longitude"] = -122.136841;
            // Int
            account["numberofemployees"] = 500;
            // Money
            account["revenue"] = new Money(new decimal(5000000.00));
            // Picklist (Option set)
            account["accountcategorycode"] = new OptionSetValue(1); //Preferred customer

            //Create the account
            Guid accountid = svc.Create(account);
            Console.WriteLine("Account created with ID: " + accountid.ToString());
        }
    }
}