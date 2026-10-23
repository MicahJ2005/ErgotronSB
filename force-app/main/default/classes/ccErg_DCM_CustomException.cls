/**
 * @description       : 
 * @author            : Raziya Gurramkonda
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Raziya Gurramkonda
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   11-11-2020   Raziya Gurramkonda   Initial Version
**/
public without sharing class ccErg_DCM_CustomException extends Exception{

    private static String SOBJECT_NAME = 'DCM_Application_Log__c';
    private static Integer recursiveCount = 0;
    private static final Integer MAX_TRIES = 5;

    
    public static void log(Exception excp , String applicationName , String moduleName , String className , String methodName) {
        try
        {
            storeExceptionLog(excp , applicationName , moduleName , className , methodName,null);
        }
        catch (Exception e)
        {
            System.debug('########## Missing email address for Error Handling #########'+e);
          //  cleanUp(SOBJECT_NAME);
        }
    }

    public static void Log(Exception excp , String applicationName , String moduleName , String className , String methodName,String supportData)
    {
        storeExceptionLog(excp,applicationName,moduleName,className,methodName,supportData);
    }

    public static void storeExceptionLog(Exception excp , String applicationName , String moduleName , String className , String methodName,String supportData)
    {
            try {

                String queryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
                String dmlLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
                String dmlStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();
                String cpuUsage = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();

                List<String> lstSalesforceLimit = new List<String>();
                lstSalesforceLimit.add(queryLimit);
                lstSalesforceLimit.add(dmlLimit);
                lstSalesforceLimit.add(dmlStat);
                lstSalesforceLimit.add(cpuUsage);

                //Create exception record
                DCM_Application_Log__c exc = new DCM_Application_Log__c();
                exc.Salesforce_Limits__c = String.format( '{0}\n{1}\n{2}\n{3}', lstSalesforceLimit);
                exc.Error_Message__c = excp.getMessage();
                exc.Exception_Type__c = excp.getTypeName();
                exc.Line_Number__c = String.valueOf(excp.getLineNumber());
                exc.Stack_Trace__c = excp.getStackTraceString();
                exc.Application_Name__c = applicationName;
                exc.Module_Name__c = moduleName;
                exc.Class_Name__c  = className;
                exc.Method_Name__c = methodName;
                exc.Exception_Running_User__c = UserInfo.getUserId();
                exc.Error_Support_Data__c = supportData;
                ccrz.ccLog.log(LoggingLevel.INFO, 'Custom:Exception ', JSON.serialize(exc));
                Database.insert(exc);
              //  cleanUp(SOBJECT_NAME);
            }catch (Exception mailException) {
                System.debug('######## Error sending email message #######'+mailException);
                System.debug('######## Error sending email message #######'+mailException.getStackTraceString());
                System.debug('######## Error sending email message #######'+mailException.getMessage());
               // cleanUp(SOBJECT_NAME);
            }

        }
    }