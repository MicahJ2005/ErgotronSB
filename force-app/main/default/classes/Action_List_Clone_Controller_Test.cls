/*
    Test class for the Action_List_Clone_Controller.cls.

    MOD DATE        Who                     Description
    09/05/2014      Chris Noe               Initial Release    
*/

@isTest
private class Action_List_Clone_Controller_Test {
	
	@isTest static void testCloneWithTasks() {
		//Create assigned to user for test
		User oAssignedToUser = Test_Environment_Utility.createInsertUser();

		//Create account for test
		Account oAccount = Test_Environment_Utility.createInsertAccountUS();

		//Create contact for test
		Contact oContact = Test_Environment_Utility.createInsertContact(oAccount);

		//Create Action_List__c for test
		Action_List__c oActionList = Test_Environment_Utility.createInsertActionList(oAccount, oAssignedToUser);

		//Create Action_List__c Task for test
		Task oTask = new Task();
		oTask.Subject='Test Subject';
		oTask.OwnerId=oActionList.Assigned_To__c;
		oTask.Description='Test Descrption';
		oTask.Priority='Normal';
		oTask.WhoId=oContact.Id;
		oTask.WhatId=oActionList.Id;
		insert oTask;

		Test.startTest();
            PageReference oPageRef = Page.ActionListClone;
            Test.setCurrentPage(oPageRef);

            //Invoke the standard and extension controllers for the Action_List__c created above
            ApexPages.StandardController oStdController = new ApexPages.StandardController(oActionList);
            ApexPages.currentPage().getParameters().put('id',oActionList.id);
            Action_List_Clone_Controller oExtController = new Action_List_Clone_Controller(oStdController);
            
            oPageRef = oExtController.saveWithActivities();

            //Retrieve the Action_List__c record created via the saveWithActivities method call
            Action_List__c oNewActionList = [select Assigned_To__c, Account__c, Action__c, Next_Steps__c, Due_Date__c from Action_List__c where Id!=:oActionList.Id limit 1];

            //Assert statements for Action_List__c
            system.assertEquals(oActionList.Assigned_To__c,oNewActionList.Assigned_To__c);
            system.assertEquals(oActionList.Account__c,oNewActionList.Account__c);
            system.assertEquals(oActionList.Action__c,oNewActionList.Action__c);
            system.assertEquals(oActionList.Next_Steps__c,oNewActionList.Next_Steps__c);

            //Retrieve Task record created via the saveWithActivities method call
            Task oActionListTask = [select ActivityDate, Subject, Description, Priority, WhoId, WhatId, OwnerId from Task where WhatId=:oNewActionList.Id];
			
            //Assert statements for Action_List__c cloned tasks
			system.assertEquals(oNewActionList.Due_Date__c, oActionListTask.ActivityDate);
			system.assertEquals(oTask.Subject, oActionListTask.Subject);
            system.assertEquals(oTask.Description, oActionListTask.Description);
            system.assertEquals(oTask.Priority, oActionListTask.Priority);
            system.assertEquals(oTask.WhoId, oActionListTask.WhoId);
            system.assertEquals(oNewActionList.Id, oActionListTask.WhatId);	
            system.assertEquals(oNewActionList.Assigned_To__c,oActionListTask.OwnerId);
		Test.stopTest();
	}	
}