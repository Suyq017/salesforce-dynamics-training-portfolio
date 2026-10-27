using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Xrm.Sdk;

namespace Service.Exercises
{
    internal class GetManyByFETCHXML
    {
        public static void GetManyByFETCHXMLFunc(IOrganizationService svc)
        {
            string fetchXml = @"
                <fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'>
                  <entity name='account'>
                    <attribute name='name' />
                    <filter type='and'>
                      <condition attribute='name' operator='eq' value='Contoso' />
                    </filter>
                  </entity>
                </fetch>";
            var result = svc.RetrieveMultiple(new Microsoft.Xrm.Sdk.Query.FetchExpression(fetchXml));
            foreach (var entity in result.Entities)
            {
                Console.WriteLine(entity.GetAttributeValue<string>("name"));
            }
        }
    }
}
