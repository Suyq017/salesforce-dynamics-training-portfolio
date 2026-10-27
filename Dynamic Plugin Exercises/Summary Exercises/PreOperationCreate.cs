using System;
using System.Collections;
using System.Collections.Generic;
using CrmEarlyBound;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Client;

namespace Summary_Exercises
{
    public class PreOperationCreate : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            try
            {
                ITracingService tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
                IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));

                var stage = context.Stage;
                if (stage == 10)
                {
                    throw new InvalidPluginExecutionException("Create Pre-validation Plugin");
                }
                if (stage == 40)
                {
                    throw new InvalidPluginExecutionException("Update Post-Operation Plugin");
                }
            }
            catch (InvalidPluginExecutionException e)
            {
                throw new InvalidPluginExecutionException("An error has occurred: " + e.Message);
            }
        }
    }
}