using System;
using System.IO;
using BT_002.Common;

namespace BT_002.Services
{
    internal class LogHelper
    {
        // Log
        // This method logs a message to the console and to a log file in the specified log folder path.
        public static void Log(string message)
        {
            try
            {
                String logFolderPath = System.Configuration.ConfigurationManager.AppSettings["LogFolderPath"];
                if (String.IsNullOrEmpty(logFolderPath))
                {
                    throw new InvalidOperationException("Log folder path is not specified.");
                }
                if (!Directory.Exists(logFolderPath))
                {
                    Directory.CreateDirectory(logFolderPath);
                }

                String logFileName = DateTime.Now.ToString(Constant.DATE_FORMAT) + ".txt";
                String logFilePath = Path.Combine(logFolderPath, logFileName);

                File.AppendAllLines(logFilePath, new[] { $"[{DateTime.Now}] {message}" });
                Console.WriteLine($"[{DateTime.Now}] {message}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"LogHelper.Log: {Constant.EXCEPTION_MESSAGE} {ex.Message}");
            }
        }
    }
}
