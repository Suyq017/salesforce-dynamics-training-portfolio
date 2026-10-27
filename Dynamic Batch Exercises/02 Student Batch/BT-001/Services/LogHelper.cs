using System;
using System.IO;
using BT_001.Common;
using BT_001.DTO;

namespace BT_001.Services
{
    internal class LogHelper
    {
        // Log
        // This method logs a message to the console and to a log file in the specified log folder path.
        public static void Log(string message)
        {
            try
            {
                String logFolderPath = System.Configuration.ConfigurationManager.AppSettings[Constant.LOG_FOLDER_CONFIG_KEY];
                if (String.IsNullOrEmpty(logFolderPath))
                {
                    throw new InvalidOperationException("Log folder path is not specified.");
                }
                if (!Directory.Exists(logFolderPath))
                {
                    Directory.CreateDirectory(logFolderPath);
                }

                String logFileName = DateTime.Now.ToString(Constant.LOG_FILE_DATE_FORMAT) + ".txt";
                String logFilePath = Path.Combine(logFolderPath, logFileName);

                File.AppendAllLines(logFilePath, new[] { $"[{DateTime.Now}] {message}" });
                Console.WriteLine($"[{DateTime.Now}] {message}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"LogHelper.Log: {Constant.EXCEPTION_MESSAGE} : {ex.Message}");
            }
        }

        // GetResultLine
        // This method formats a StudentDTO object into a CSV line for logging.
        public static String GetResultLine(StudentDTO student)
        {
            string line;
            line = string.Join(",", new string[] {
                $"\"{student.FullName}\"",
                $"\"{student.Class}\"",
                $"\"{student.Gender}\"",
                $"\"{student.Birthday}\"",
                $"\"{student.LearningStatus}\""
            });
            return line;
        }
    }
}
