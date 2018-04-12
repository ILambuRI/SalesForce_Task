public class EmployeeSkillTriggerController {

    public EmployeeSkillTriggerController() {
        this.handling();
    }

    private void handling() {
        if (Trigger.isUndelete) {
            EmployeeSkillTriggerHelper.updateSumDevAndQaInProjects(Trigger.new);
        }
        else if (Trigger.isDelete) {
            if (Trigger.isAfter) {
                EmployeeSkillTriggerHelper.updateSumDevAndQaInProjects(Trigger.old);
            }
            else if (Trigger.isBefore) {
            }
        }
        else if (Trigger.isUpdate) {
            if (Trigger.isAfter) {
                EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap);
            }
            else if (Trigger.isBefore) {
            }
        }
        else if (Trigger.isInsert) {
            if (Trigger.isAfter) {
                EmployeeSkillTriggerHelper.updateSumDevAndQaInProjects(Trigger.new);
                EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap);
            }
            else if (Trigger.isBefore) {
            }
        }
    }
}