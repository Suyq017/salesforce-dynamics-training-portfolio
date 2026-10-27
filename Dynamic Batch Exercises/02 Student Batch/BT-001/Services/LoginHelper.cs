using System;
using System.Configuration;
using System.ServiceModel;
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;

namespace BT_001.Services
{
    internal class LoginHelper
    {
        // Login
        // This method establishes a connection to the Dataverse service using the connection string retrieved from the application configuration.
        public static IOrganizationService Login()
        {
            String connectionString = GetConnectionString();
            try
            {
                IOrganizationService service = new ServiceClient(connectionString);
                LogHelper.Log("Connection established successfully.");
                return service;
            }
            catch (FaultException<Microsoft.Xrm.Sdk.OrganizationServiceFault> ex)
            {
                LogHelper.Log("The application terminated with an error.");
                LogHelper.Log($"Code: {ex.Detail.ErrorCode}");
                LogHelper.Log($"Message: {ex.Detail.Message}");
                LogHelper.Log($"Inner Fault: {(null == ex.Detail.InnerFault ? "No Inner Fault" : "Has Inner Fault")}");
                return null;
            }
            catch (System.TimeoutException ex)
            {
                LogHelper.Log("The application terminated with an error.");
                LogHelper.Log($"Message: {ex.Message}");
                LogHelper.Log($"Stack Trace: {ex.StackTrace}");
                LogHelper.Log($"Inner Fault: {(null == ex.InnerException?.Message ? "No Inner Fault" : ex.InnerException.Message)}");
                return null;
            }
            catch (System.Exception ex)
            {
                LogHelper.Log("The application terminated with an error.");
                LogHelper.Log($"Message: {ex.Message}");

                // Display the details of the inner exception.
                if (ex.InnerException != null)
                {
                    LogHelper.Log($"Inner Exception: {ex.InnerException.Message}");

                    FaultException<Microsoft.Xrm.Sdk.OrganizationServiceFault> fe = ex.InnerException
                        as FaultException<Microsoft.Xrm.Sdk.OrganizationServiceFault>;
                    if (fe != null)
                    {
                        LogHelper.Log($"Code: {fe.Detail.ErrorCode}");
                        LogHelper.Log($"Message: {fe.Detail.Message}");
                        LogHelper.Log($"Trace: {fe.Detail.TraceText}");
                        LogHelper.Log($"Inner Fault: {(null == fe.Detail.InnerFault ? "No Inner Fault" : "Has Inner Fault")}");
                    }
                }
                return null;
            }
        }

        // GetConnectionString
        // This method retrieves the connection string for the Dataverse service from the application configuration.
        private static string GetConnectionString()
        {
            return ConfigurationManager.AppSettings["ConnectionString"];
        }
    }
}
