public class EmployeeTriggerController {

    public EmployeeTriggerController() {
        this.handling();
    }

    private void handling() {
        if (Trigger.isUndelete) {
            EmployeeTriggerHelper.updateSumDevAndQaInProjects(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate, Trigger.isUndelete);
        }
        else if (Trigger.isDelete) {
            if (Trigger.isAfter) {

            }
            else if (Trigger.isBefore) {
                EmployeeTriggerHelper.updateSumDevAndQaInProjects(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate, Trigger.isUndelete);
            }
        }
        else if (Trigger.isUpdate) {
            if (Trigger.isAfter) {
                EmployeeTriggerHelper.updateSumDevAndQaInProjects(Trigger.newMap, Trigger.oldMap, Trigger.isDelete, Trigger.isUpdate, Trigger.isUndelete);
            }
            else if (Trigger.isBefore) {
                EmployeeTriggerHelper.checkDuplicate(Trigger.new, Trigger.newMap, Trigger.isInsert);
            }
        }
        else if (Trigger.isInsert) {
            if (Trigger.isAfter) {

            }
            else if (Trigger.isBefore) {
                EmployeeTriggerHelper.checkDuplicate(Trigger.new, Trigger.newMap, Trigger.isInsert);
            }
        }
    }
}