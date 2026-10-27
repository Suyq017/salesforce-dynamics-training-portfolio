using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using BT_001.Common;
using BT_001.DTO;
using CrmEarlyBound;
using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.Xrm.Sdk;

namespace BT_001.Services
{
    internal class FileHelper
    {
        // GetInputFilePath
        // This method retrieves the input file path from the application configuration
        public static string GetInputFilePath()
        {
            try
            {
                string inputFolderPath = GetInputFileFolderPath();

                string inputFileName = ConfigurationManager.AppSettings[Constant.INPUT_FILE_NAME_CONFIG_KEY];
                if (String.IsNullOrEmpty(inputFileName))
                {
                    throw new InvalidOperationException("Input file name is not specified.");
                }
                string filePath = Path.Combine(inputFolderPath, inputFileName);
                if (!File.Exists(filePath))
                {
                    throw new FileNotFoundException("Specified input file not found.");
                }
                LogHelper.Log($"GetInputFilePath: Input file path retrieved successfully: {filePath}");
                return filePath;
            }
            catch (Exception e)
            {
                LogHelper.Log($"GetInputFilePath: {Constant.EXCEPTION_MESSAGE} : {e.Message}");
                return "";
            }
        }

        // GetInputFileFolderPath
        // This method retrieves the input file folder path from the application configuration
        // creates the folder if it does not exist, and returns the path.
        // If the path is not specified in the configuration, it throws an InvalidOperationException.
        private static string GetInputFileFolderPath()
        {
            string path = ConfigurationManager.AppSettings[Constant.INPUT_FOLDER_CONFIG_KEY];
            if (String.IsNullOrEmpty(path))
            {
                throw new InvalidOperationException("Input folder path is not specified.");
            }
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            return path;
        }

        // ProcessInputFile
        // This method processes the input file, reads its content, validates the data, and prepares a list of student records.
        public static List<ksvc_tra_student> ProcessInputFile(string inputFilePath, IOrganizationService service)
        {
            try
            {
                List<StudentDTO> listStudentsDTO = ReadCsvFile(inputFilePath);

                List<string> listClassCode = listStudentsDTO.Select(s => s.Class).Distinct().ToList();
                Program.ClassDic = DataverseHelper.GetClassDictionaryByListCode(listClassCode, service);

                List<ksvc_tra_student> listStudents = new List<ksvc_tra_student>();
                for (int i = 0; i < listStudentsDTO.Count; i++)
                {
                    if (listStudentsDTO[i].FullName == null)
                    {
                        Program.ErrorLine.Add(LogHelper.GetResultLine(listStudentsDTO[i]));
                        LogHelper.Log($"processInputFile: Line {i + Constant.LINE_OFFSET} has an invalid full name: {listStudentsDTO[i].FullName}.");
                        continue;
                    }

                    if (listStudentsDTO[i].Class == null || !Program.ClassDic.ContainsKey(listStudentsDTO[i].Class))
                    {
                        Program.ErrorLine.Add(LogHelper.GetResultLine(listStudentsDTO[i]));
                        LogHelper.Log($"processInputFile: Line {i + Constant.LINE_OFFSET} has an invalid class code: {listStudentsDTO[i].Class}.");
                        continue;
                    }

                    var gender = Enum.TryParse<ksvc_GenderOption>(listStudentsDTO[i].Gender, out var genderEnum) ? genderEnum : (ksvc_GenderOption?)null;
                    if (gender == null)
                    {
                        Program.ErrorLine.Add(LogHelper.GetResultLine(listStudentsDTO[i]));
                        LogHelper.Log($"processInputFile: Line {i + Constant.LINE_OFFSET} has an invalid gender value: {listStudentsDTO[i].Gender}.");
                        continue;
                    }

                    var birthday = DateTime.TryParse(listStudentsDTO[i].Birthday, out var birthdayEnum) ? birthdayEnum : (DateTime?)null;
                    if (birthday == null)
                    {
                        Program.ErrorLine.Add(LogHelper.GetResultLine(listStudentsDTO[i]));
                        LogHelper.Log($"processInputFile: Line {i + Constant.LINE_OFFSET} has an invalid birthday value: {listStudentsDTO[i].Birthday}.");
                        continue;
                    }

                    var learningStatus = Enum.TryParse<ksvc_LearningStatusOption>(listStudentsDTO[i].LearningStatus, out var statusEnum) ? statusEnum : (ksvc_LearningStatusOption?)null;
                    if (learningStatus == null)
                    {
                        Program.ErrorLine.Add(LogHelper.GetResultLine(listStudentsDTO[i]));
                        LogHelper.Log($"processInputFile: Line {i + Constant.LINE_OFFSET} has an invalid learning status value: {listStudentsDTO[i].LearningStatus}.");
                        continue;
                    }

                    ksvc_tra_student student = new ksvc_tra_student();
                    student.ksvc_slt_studentname = listStudentsDTO[i].FullName;
                    student.ksvc_lup_class = Program.ClassDic[listStudentsDTO[i].Class].ToEntityReference();
                    student.ksvc_opt_gender = gender;
                    student.ksvc_dat_birthday = birthday;
                    student.ksvc_opt_learningstatus = learningStatus;
                    listStudents.Add(student);
                }
                return listStudents;
            }
            catch (Exception e)
            {
                LogHelper.Log($"processInputFile: {Constant.EXCEPTION_MESSAGE} : {e.Message}");
                return new List<ksvc_tra_student>();
            }
        }

        // WriteOutputFile
        // Write sucess and error log
        public static void WriteOutputFile()
        {
            try
            {
                string outputFolderPath = ConfigurationManager.AppSettings[Constant.OUTPUT_FOLDER_CONFIG_KEY];
                string successFileName = Constant.SUCCESS_LOG_FILENAME;
                string errorFileName = Constant.ERROR_LOG_FILENAME;
                if (!Directory.Exists(outputFolderPath))
                {
                    Directory.CreateDirectory(outputFolderPath);
                }

                string dateTime = DateTime.Now.ToString(Constant.LOG_CSV_DATE_FORMAT);
                string successOutputFilePath = Path.Combine(outputFolderPath, successFileName + dateTime + ".csv");

                string header = Constant.CSV_HEADER;

                using (StreamWriter writer = new StreamWriter(successOutputFilePath))
                {
                    writer.WriteLine(header);
                    foreach (string line in Program.SuccessLine)
                    {
                        writer.WriteLine(line);
                    }
                }
                LogHelper.Log($"WriteOutputFile: Output file written successfully to {successOutputFilePath}");

                string errorOutputFilePath = Path.Combine(outputFolderPath, errorFileName + dateTime + ".csv");
                using (StreamWriter writer = new StreamWriter(errorOutputFilePath))
                {
                    writer.WriteLine(header);
                    foreach (string line in Program.ErrorLine)
                    {
                        writer.WriteLine(line);
                    }
                }
                LogHelper.Log($"WriteOutputFile: Output file written successfully to {errorOutputFilePath}");
            }
            catch (Exception e)
            {
                LogHelper.Log($"WriteOutputFile: {Constant.EXCEPTION_MESSAGE} : {e.Message}");
            }
        }

        // DeleteDataFile
        // Delete csv data file
        public static void DeleteDataFile(string path)
        {
            try
            {
                File.Delete(path);
                LogHelper.Log("Delete data file sucessfully");
            }
            catch (Exception ex)
            {
                LogHelper.Log($"DeleteDataFile: {Constant.EXCEPTION_MESSAGE} : {ex.Message}");
            }
        }

        // ReadCsvFile
        // This method reads a CSV file and returns a list of StudentDTO objects.
        private static List<StudentDTO> ReadCsvFile(string filePath)
        {
            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                Delimiter = Constant.CSV_DELIMITER,
                MissingFieldFound = null,
                BadDataFound = null
            };
            using (var reader = new StreamReader(filePath))
            using (var csv = new CsvReader(reader, config))
            {
                return csv.GetRecords<StudentDTO>().ToList();
            }
        }
    }
}
