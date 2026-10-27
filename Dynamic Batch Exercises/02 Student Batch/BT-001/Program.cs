using System;
using System.Collections.Generic;
using BT_001.Services;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;

namespace BT_001
{
    internal class Program
    {
        public static Dictionary<string, ksvc_mst_class> ClassDic = new Dictionary<string, ksvc_mst_class>();
        public static List<string> ErrorLine = new List<string>();
        public static List<string> SuccessLine = new List<string>();
        static void Main()
        {

            LogHelper.Log("Program started.");
            string path = FileHelper.GetInputFilePath();
            if (String.IsNullOrEmpty(path))
            {
                return;
            }

            IOrganizationService service = LoginHelper.Login();
            if (service == null)
            {
                return;
            }

            List<ksvc_tra_student> lstStudent = FileHelper.ProcessInputFile(path, service);
            if (lstStudent.Count > 0)
            {
                DataverseHelper.CreateListStudent(lstStudent, service);
            }
            FileHelper.WriteOutputFile();
            FileHelper.DeleteDataFile(path);
            LogHelper.Log("Program ended.");
        }
    }
}
