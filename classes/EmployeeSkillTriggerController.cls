public class EmployeeSkillTriggerController {

    public EmployeeSkillTriggerController() {
        this.handling();
    }

    private void handling() {
       
        if(Trigger.isDelete && Trigger.isBefore)
        {
 
        }
        else if(Trigger.isDelete && Trigger.isAfter)
        {
 
        }
        else if(Trigger.isundelete)
        {
           
        }
        else if(Trigger.isInsert && Trigger.isBefore)
        {
            // EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap, Trigger.isInsert);
        }
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
            // EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap, Trigger.isInsert);
        }
        else if(Trigger.isInsert && Trigger.isAfter)
        {
            EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter)
        {
            EmployeeSkillTriggerHelper.checkEmployeeAvailability(Trigger.new, Trigger.newMap);
        }
    }
}