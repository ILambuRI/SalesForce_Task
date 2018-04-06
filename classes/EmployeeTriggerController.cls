public class EmployeeTriggerController {

    public EmployeeTriggerController() {
        this.handling();
    }

    private void handling() {
        if (Trigger.isInsert && Trigger.isAfter) {

        }
        else if (Trigger.isundelete) {
           
        }
        else if (Trigger.isDelete && Trigger.isAfter) {

        }
        else if (Trigger.isUpdate && Trigger.isAfter) {
            EmployeeTriggerHelper.updateSumDevAndQaInProjects(Trigger.new, Trigger.isDelete);
        }
        else if (Trigger.isDelete && Trigger.isBefore) {
            EmployeeTriggerHelper.updateSumDevAndQaInProjects(Trigger.old, Trigger.isDelete);
        }
        else if (Trigger.isInsert && Trigger.isBefore) {
            EmployeeTriggerHelper.checkDuplicate(Trigger.new, Trigger.newMap, Trigger.isInsert);
        }
        else if(Trigger.isUpdate && Trigger.isBefore) {
            EmployeeTriggerHelper.checkDuplicate(Trigger.new, Trigger.newMap, Trigger.isInsert);
        }
    }
}