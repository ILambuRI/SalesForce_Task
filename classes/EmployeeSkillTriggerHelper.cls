public class EmployeeSkillTriggerHelper {
    public static void checkEmployeeAvailability(EmployeeSkill__c[] triggerNew, Map<Id, SObject> triggerNewMap) {
        Id[] employeeIdList = new Id[]{};
        Employee__c[] employeeList = new Employee__c[]{};
        AggregateResult[] employeeSummAssignedTimeList = new AggregateResult[]{};
        Map<Id,EmployeeWrapper> employeeWrapperMap = new Map<Id,EmployeeWrapper>();
        Map<Id, Integer> employeeSkillMap = new Map<Id, Integer>();

        /* Get all employee ID */
        for (EmployeeSkill__c employeeSkill : triggerNew) {
            employeeIdList.add(employeeSkill.Employee__c);
        }
        
        /* Filling out lists from the database */
        try {
            employeeList = [
                SELECT Id, Availability__c
                FROM Employee__c
                WHERE Id IN :employeeIdList
            ];

            employeeSummAssignedTimeList = [
                SELECT Employee__c, SUM(Assigned_Time__c) summ
                FROM EmployeeSkill__c
                WHERE Employee__c IN :employeeIdList
                GROUP BY Employee__c
            ];
        } catch (QueryException e) {
            System.debug('Error in QueryException: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Error in Exception: ' + e.getMessage());
        }

        /* Fill map with ID of employee and his summ of 'Assigned Time' from EmployeeSkill */
        for (AggregateResult summAssignedTime : employeeSummAssignedTimeList) {
            Id employeeId = (Id)summAssignedTime.get('Employee__c');
            Integer summ = Math.round((Decimal)summAssignedTime.get('summ'));
            employeeSkillMap.put(employeeId, summ);
        }

        /* Fill map with ID of employee and obj EmployeeWrapper with params */
        for (Employee__c employee : employeeList) {
            EmployeeWrapper newEmployeeWrapper = new EmployeeWrapper();
            newEmployeeWrapper.id = employee.Id;
            newEmployeeWrapper.availability = Math.round((Decimal)employee.Availability__c);
            newEmployeeWrapper.summAssignedTime = employeeSkillMap.get(employee.Id);

            employeeWrapperMap.put(employee.Id, newEmployeeWrapper);
        }

        /* Add ID of EmployeeSkill to list in obj EmployeeWrapper from map */
        for (SObject employeeSkill : triggerNewMap.values())  {
            if (employeeWrapperMap.containsKey((Id)employeeSkill.get('Employee__c'))) {
                EmployeeWrapper employeeWrapper = employeeWrapperMap.get((Id)employeeSkill.get('Employee__c'));
                employeeWrapper.employeeSkillIdList.add(employeeSkill.Id);
            }
        }
        
        /** Check, if Availability < Assigned Time for this employee
          * adds errors to all Employee Skill in Trigger.newMap
          * by ID from list in obj EmployeeWrapper
          */
        for (EmployeeWrapper employeeWrapper : employeeWrapperMap.values()) {
            if (employeeWrapper.availability < employeeWrapper.summAssignedTime) {
                for (Id employeeSkillId : employeeWrapper.employeeSkillIdList) {
                    triggerNewMap.get(employeeSkillId).addError('Availability is less than overall Assigned Time!');
                }
            }
        }
    }

    public class EmployeeWrapper {
        public Id id {get; set;}
        public Integer availability {get; set;}
        public Integer summAssignedTime {get; set;}
        public Id[] employeeSkillIdList {get; set;} { employeeSkillIdList = new Id[]{}; }
    }
}