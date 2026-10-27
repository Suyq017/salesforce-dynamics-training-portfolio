namespace BT_001.Common
{
    internal class Constant
    {
        public const string EXCEPTION_MESSAGE = "Unknown error occurred.";

        public const string DATE_FORMAT = "yyyy/MM/dd";
        public const string LOG_CSV_DATE_FORMAT = "yyyyMMdd_HHmmss";
        public const string LOG_FILE_DATE_FORMAT = "yyyy-MM-dd";
        public const string CSV_DELIMITER = ",";

        public const string SUCCESS_LOG_FILENAME = "success_insertion_";
        public const string ERROR_LOG_FILENAME = "error_insertion_";

        public const string INPUT_FILE_NAME_CONFIG_KEY = "InputFileName";
        public const string INPUT_FOLDER_CONFIG_KEY = "InputFolderPath";
        public const string OUTPUT_FOLDER_CONFIG_KEY = "OutputFolderPath";
        public const string LOG_FOLDER_CONFIG_KEY = "LogFolderPath";

        public const string CSV_HEADER = "\"Full Name\",\"Class\",\"Gender\",\"Birthday\",\"Learning Status\"";

        public const int BATCH_SIZE = 1000;
        public const int LINE_OFFSET = 2;
    }
}
