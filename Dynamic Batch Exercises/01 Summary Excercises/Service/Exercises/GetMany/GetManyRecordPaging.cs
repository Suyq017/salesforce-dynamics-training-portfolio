using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace Service.Exercises
{
    internal class GetManyRecordPaging
    {
        public static void GetManyRecordPagingFunc(IOrganizationService svc)
        {
            const int pageSize = 10;
            QueryExpression query = new QueryExpression("account")
            {
                ColumnSet = new ColumnSet("name"),
                PageInfo = new PagingInfo()
                {
                    Count = pageSize,
                    PageNumber = 1,
                    ReturnTotalRecordCount = true
                },
            };
            var results = svc.RetrieveMultiple(query);
            int totalRecords = results.TotalRecordCount;
            int pageNumber = (int)Math.Ceiling((double)totalRecords / pageSize);
            Console.WriteLine("Total Records: {0}", totalRecords);
            while (query.PageInfo.PageNumber <= pageNumber)
            {
                Console.WriteLine("Page {0} of {1}", query.PageInfo.PageNumber, pageNumber);
                query.PageInfo.PageNumber++;
                results = svc.RetrieveMultiple(query);
            }
        }
    }
}
