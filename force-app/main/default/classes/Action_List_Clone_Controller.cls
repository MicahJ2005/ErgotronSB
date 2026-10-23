/*
    Controller class for the ActionListClone.page.

    MOD DATE        Who                     Description
    09/05/2014      Chris Noe               Initial Release    
*/

public with sharing class Action_List_Clone_Controller {

	private final Action_List__c oActionList;
    public Action_List__c oActionListClone {get;set;}

    // The extension constructor initializes the private member variable oActionList by using the getRecord method from the standard controller.
    public Action_List_Clone_Controller(ApexPages.StandardController oStdController) {
        this.oActionList = (Action_List__c)oStdController.getRecord();

        //Set fields on cloned Action List record
        oActionListClone = new Action_List__c();
        oActionListClone.Name = 'CLONED FROM ' + this.oActionList.Name;
        oActionListClone.Assigned_To__c = this.oActionList.Assigned_To__c;
        oActionListClone.Account__c = this.oActionList.Account__c;
        oActionListClone.Status__c = 'New';
        oActionListClone.Action__c = this.oActionList.Action__c;
        oActionListClone.Next_Steps__c = this.oActionList.Next_Steps__c;
    }

    public PageReference saveWithActivities() {
        //Method variables
        List<Task> listClonedActionListTasks = new List<Task>();

        //Insert new Action List record
        insert oActionListClone;

        //Query for tasks assigned to the Action List being cloned and create tasks for newly cloned action list
        for (Task oTask : [select Subject, Description, Priority, WhoId from Task where WhatId=:oActionList.Id]) {
            Task oNewTask = new Task();
            oNewTask.ActivityDate=oActionListClone.Due_Date__c;
            oNewTask.Subject=oTask.Subject;
            oNewTask.Description=oTask.Description;
            oNewTask.Priority=oTask.Priority;
            oNewTask.WhoId=oTask.WhoId;
            oNewTask.WhatId=oActionListClone.Id;
            oNewTask.OwnerId=oActionListClone.Assigned_To__c;
            
            listClonedActionListTasks.add(oNewTask); 
        }

        //Insert cloned Action List tasks
        if(!listClonedActionListTasks.isEmpty()){
            insert listClonedActionListTasks;
        }

        return new PageReference('/' + oActionListClone.Id);
    }
}