trigger Trigger_IPPreventativeMaintenance on Integration_Project__c (after insert) {
	ContractLinesToTechDeployLines.AssignContractLines(Trigger.New);
}