using System.Collections.Generic;
using BT_003.Services;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;

namespace BT_003
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
                LogHelper.Log("Retrieved student list is null.");
                return;
            }

            Services.DataverseHelper.CalculateTotalCredit(service, studentsList);

            LogHelper.Log("Program ended.");
        }
    }
}
