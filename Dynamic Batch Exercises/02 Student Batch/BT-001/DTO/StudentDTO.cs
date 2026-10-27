using CsvHelper.Configuration.Attributes;

namespace BT_001.DTO
{
    public class StudentDTO
    {
        [Name("Full Name")]
        public string FullName { get; set; }
        public string Class { get; set; }
        public string Gender { get; set; }
        public string Birthday { get; set; }
        [Name("Learning Status")]
        public string LearningStatus { get; set; }

    }
}
