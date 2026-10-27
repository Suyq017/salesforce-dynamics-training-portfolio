using System;
namespace Plugin_Exercise.Common
{
    internal class Constant
    {
        public readonly static int CURRENT_YEAR = DateTime.Now.Year;
        public readonly static int NEXT_YEAR = DateTime.Now.Year + 1;
        public const int FULL_SCORE = 4;
        public const int MAX_NUMBER_OF_STUDENT = 100;
        public const string SEMESTER_I = "Semester I";
        public const string SEMESTER_II = "Semester II";
        public const string PLUGIN_PREIMAGE = "PreImage";
        public const string CREATE_MESSAGE = "Create";
        public const string UPDATE_MESSAGE = "Update";
        public const string DELETE_MESSAGE = "Delete";
        public const string UKNOWN_ERROR_MESSAGE = "Có lỗi xảy ra: ";
        public const string PLUGIN_LOOP_ERROR_MESSAGE = "Plugin đang được gọi từ plugin khác, vui lòng kiểm tra logic.";
        public const string CLASS_NOT_FOUND_ERROR_MESSAGE = "Không tìm thấy thông tin lớp học của sinh viên.";
        public const string FULL_STUDENT_ERROR_MESSAGE = "Lớp đã chọn hiện tại đã đủ sỉ số lớp không thể thực hiện đăng ký thêm. Vui lòng chọn lớp khác!";

    }
}
