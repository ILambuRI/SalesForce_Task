trigger TriggerEmployeeSkill on EmployeeSkill__c (before insert,
                                        before update,
                                        before delete,
                                        after insert,
                                        after update,
                                        after delete,
                                        after undelete) {

	new EmployeeSkillTriggerController();
}