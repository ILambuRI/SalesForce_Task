public class EmployeeTriggerController {

    public EmployeeTriggerController() {
        this.handling();
    }

    private void handling() {
       
        if(Trigger.isInsert && Trigger.isAfter)
        {

        }
        else if(Trigger.isUpdate && Trigger.isAfter)
        {
 
        }
        else if(Trigger.isDelete && Trigger.isBefore)
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
            EmployeeTriggerHelper.checkDuplicate(Trigger.new, Trigger.newMap, Trigger.isInsert);
        }
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
            EmployeeTriggerHelper.checkDuplicate(Trigger.new, Trigger.newMap, Trigger.isInsert);
        }
    }
}