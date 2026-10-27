using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;

namespace Service.Exercises
{
    internal class CreateManyRecord
    {
        public static void createManyRecordFunc(IOrganizationService service)
        {
            // Create an ExecuteMultipleRequest object.
            ExecuteMultipleRequest requestWithResults = new ExecuteMultipleRequest()
            {
                // Assign settings that define execution behavior: continue on error, return responses. 
                Settings = new ExecuteMultipleSettings()
                {
                    ContinueOnError = false,
                    ReturnResponses = true
                },
                // Create an empty organization request collection.
                Requests = new OrganizationRequestCollection()
            };

            // Create several (local, in memory) entities in a collection. 
            EntityCollection input = GetCollectionOfEntitiesToCreate();

            // Add a CreateRequest for each entity to the request collection.
            foreach (var entity in input.Entities)
            {
                CreateRequest createRequest = new CreateRequest { Target = entity };
                requestWithResults.Requests.Add(createRequest);
            }

            // Execute all the requests in the request collection using a single web method call.
            ExecuteMultipleResponse responseWithResults =
                (ExecuteMultipleResponse)service.Execute(requestWithResults);

            // Display the results returned in the responses.
            foreach (var responseItem in responseWithResults.Responses)
            {
                // A valid response.
                if (responseItem.Response != null)
                    DisplayResponse(requestWithResults.Requests[responseItem.RequestIndex], responseItem.Response);

                // An error has occurred.
                else if (responseItem.Fault != null)
                    DisplayFault(requestWithResults.Requests[responseItem.RequestIndex],
                        responseItem.RequestIndex, responseItem.Fault);
            }
        }

        private static EntityCollection GetCollectionOfEntitiesToCreate()
        {
            EntityCollection input = new EntityCollection();
            // Create several (local, in memory) entities in a collection. 
            for (int i = 0; i < 5; i++)
            {
                Entity entity = new Entity("account");
                entity["name"] = "Test Record " + i;
                input.Entities.Add(entity);
            }
            return input;
        }

        private static void DisplayResponse(OrganizationRequest request, OrganizationResponse response)
        {
            Console.WriteLine("Request Name: {0}", request.Parameters.ToString());
            Console.WriteLine("Response Name: {0}", response.Results.ToString());
            Console.WriteLine();
        }

        private static void DisplayFault(OrganizationRequest request, int requestIndex, OrganizationServiceFault fault)
        {
            Console.WriteLine("Request Name: {0}", request.RequestName);
            Console.WriteLine("Fault: {0}", fault.Message);
            Console.WriteLine();
        }
    }
}
