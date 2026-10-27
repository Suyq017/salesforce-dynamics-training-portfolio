using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises.DeleteRecord
{
    internal class DeleteRecord
    {
        public static void DeleteRecordFunc(IOrganizationService service)
        {
            // Create a new record
            Guid recordId = createRecord(service);
            Console.WriteLine("Created record with ID: " + recordId);
            // Retrieve the record to verify it was created
            Account createdRecord = getRecord(recordId, service);
            Console.WriteLine("Retrieved record: Name = " + createdRecord.Name + ", Telephone = " + createdRecord.Telephone1);
            // Delete the record
            service.Delete("account", recordId);
            Console.WriteLine("Deleted record with ID: " + recordId);
            // Try to retrieve the deleted record to verify it was deleted
            try
            {
                Account deletedRecord = getRecord(recordId, service);
                Console.WriteLine("Retrieved deleted record: Name = " + deletedRecord.Name + ", Telephone = " + deletedRecord.Telephone1);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error retrieving deleted record: " + ex.Message);
            }
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
