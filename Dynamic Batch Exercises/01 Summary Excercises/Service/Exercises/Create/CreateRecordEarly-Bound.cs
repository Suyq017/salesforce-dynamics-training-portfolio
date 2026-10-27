using System;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;

namespace Service.Exercises
{
    internal class CreateRecordEarly_Bound
    {
        public static void CreateRecordEarlyBound(IOrganizationService svc)
        {
            var account = new Account();
            // set attribute values
            // string primary name
            account.Name = "Contoso";
            // Boolean (Two option)
            account.CreditOnHold = false;
            // DateTime
            account.LastOnHoldTime = new DateTime(2017, 1, 1);
            // Double
            account.Address1_Latitude = 47.642311;
            account.Address1_Longitude = -122.136841;
            // Int
            account.NumberOfEmployees = 500;
            // Money
            account.Revenue = new Money(new decimal(5000000.00));
            // Picklist (Option set)
            account.AccountCategoryCode = Account_AccountCategoryCode.KhachhangUutien;

            //Create the account
            Guid accountid = svc.Create(account);

            Console.WriteLine("Account created with ID: " + accountid.ToString());
        }
    }
}