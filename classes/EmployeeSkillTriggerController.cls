public class EmployeeSkillTriggerController {

    public EmployeeSkillTriggerController() {
        this.handling();
    }

    private void handling() {
        if(Trigger.isDelete && Trigger.isBefore) {
 
        }
        else if(Trigger.isundelete) {
           
        }
        else if(Trigger.isInsert && Trigger.isBefore) {

        }
        else if(Trigger.isUpdate && Trigger.isBefore) {

        }
        else if(Trigger.isDelete && Trigger.isAfter) {
            EmployeeSkillTriggerHelper.updateSumDevAndQaInProjects(Trigger.old, Trigger.isDelete);
        }
        else if(Trigger.isInsert && Trigger.isAfter) {
            EmployeeSkillTriggerHelper.updateSumDevAndQaInProjects(Trigger.new, Trigger.isDelete);
            EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter) {
            EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap);
        }
    }
}