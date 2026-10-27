using System;
using System.Collections.Generic;
using System.Linq;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;
using Plugin_Exercise.Interfaces;

namespace Plugin_Exercise.Common
{
    public class CommonRepository : ICommonRepository
    {
        private readonly IOrganizationService _service;

        public CommonRepository(IOrganizationService service)
        {
            _service = service;
        }

        // CalculateAverageScore
        // Calculate the average score from a list of scores
        public decimal CalculateAverageScore(List<CrmEarlyBound.ksvc_tra_score> listScore)
        {
            if (listScore == null || listScore.Count == 0)
            {
                return 0;
            }
            decimal totalScore = listScore.Sum(s => s.ksvc_dcn_scorenumber ?? 0);
            decimal averageScore = totalScore / listScore.Count;
            return averageScore;
        }

        // UpdateNumberofClass
        // Update the number of students in a class by a specified value
        public void UpdateNumberofClass(Guid classID, int updateValue)
        {
            var queryClass = from c in new OrganizationServiceContext(_service).CreateQuery<ksvc_mst_class>()
                        where c.Id == classID
                        select new ksvc_mst_class
                        {
                            ksvc_int_numberofstudent = c.ksvc_int_numberofstudent
                        };

            int numberOfStudent = queryClass.FirstOrDefault()?.ksvc_int_numberofstudent ?? 0;
            if (numberOfStudent > Constant.MAX_NUMBER_OF_STUDENT)
            {
                throw new Exception(Constant.FULL_STUDENT_ERROR_MESSAGE);
            }

            var classToUpdate = new ksvc_mst_class
            {
                Id = classID,
                ksvc_int_numberofstudent = numberOfStudent + updateValue
            };
            _service.Update(classToUpdate);
        }

        // GetSemesterList
        // Get a list of semesters based on the current and next year
        public List<ksvc_mst_semester> GetSemesterList()
        {
            DateTime startCurrentYear = new DateTime(Constant.CURRENT_YEAR, 1, 1);
            DateTime endCurrentYear = new DateTime(Constant.CURRENT_YEAR, 12, 31);

            DateTime startNextYear = new DateTime(Constant.NEXT_YEAR, 1, 1);
            DateTime endNextYear = new DateTime(Constant.NEXT_YEAR, 12, 31);

            var querySemester = from s in new OrganizationServiceContext(_service).CreateQuery<ksvc_mst_semester>()
                            where (s.ksvc_opt_semetername == Constant.SEMESTER_I
                               && s.ksvc_dat_startdate >= startCurrentYear && s.ksvc_dat_startdate <= endCurrentYear)
                            || (s.ksvc_opt_semetername == Constant.SEMESTER_II
                               && s.ksvc_dat_enddate >= startNextYear && s.ksvc_dat_enddate <= endNextYear)
                            select new ksvc_mst_semester
                            {
                                Id = s.Id,
                            };
            return querySemester.ToList();
        }

        // GetSubjectList
        // Get a list of subjects from the database
        public List<ksvc_mst_subject> GetSubjectList()
        {
            var querySubject = from s in new OrganizationServiceContext(_service).CreateQuery<ksvc_mst_subject>()
                         select new ksvc_mst_subject
                         {
                             Id = s.Id,
                         };
            return querySubject.ToList();
        }

        // GetSubjectScoreList
        // Get a list of subject scores for a specific student
        public List<ksvc_tra_subjectscore> GetSubjectScoreList(Guid studentId)
        {
            var querySubjectScore = from sc in new OrganizationServiceContext(_service).CreateQuery<ksvc_tra_subjectscore>()
                         where sc.ksvc_lup_student.Id == studentId
                         select new ksvc_tra_subjectscore
                         {
                             Id = sc.Id,
                         };
            return querySubjectScore.ToList();
        }

        // GetScoreList
        // Get a list of scores for a specific subject score
        public List<ksvc_tra_score> GetScoreList(Guid subjectScoreId)
        {
            var queryScore = from s in new OrganizationServiceContext(_service).CreateQuery<ksvc_tra_score>()
                         where s.ksvc_lup_subjectscore.Id == subjectScoreId
                         select new ksvc_tra_score
                         {
                             Id = s.Id,
                         };
            return queryScore.ToList();
        }

        // GetSubjectScoreId
        // Get the subject score ID associated with a specific score ID
        public Guid GetSubjectScoreId(Guid scoreId)
        {
            var querySubjectScoreId = from s in new OrganizationServiceContext(_service).CreateQuery<ksvc_tra_score>()
                         where s.Id == scoreId
                         select new ksvc_tra_score
                         {
                             ksvc_lup_subjectscore = s.ksvc_lup_subjectscore
                         };
            return querySubjectScoreId.FirstOrDefault().ksvc_lup_subjectscore.Id;
        }
    }
}