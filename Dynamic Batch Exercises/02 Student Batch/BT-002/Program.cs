using System.Collections.Generic;
using BT_002.Services;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;

namespace BT_002
{
    internal class Program
    {
        static void Main()
        {
            LogHelper.Log("Program started.");

            IOrganizationService service = LoginHelper.Login();
            if (service == null)
            {
                return;
            }

            List<ksvc_tra_student> studentsList = Services.DataverseHelper.GetStudentsList(service);
            if (studentsList == null || studentsList.Count == 0) 
            { 
                LogHelper.Log("listStudent is null.");
                return; 
            }
            Services.DataverseHelper.CalculateGPAScore(service, studentsList);

            LogHelper.Log("Program ended.");
        }
    }
}
