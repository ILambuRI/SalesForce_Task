public class EmployeeSkillTriggerHelper {
    public static void checkEmployeeAvailability(EmployeeSkill__c[] triggerNew, Map<Id, SObject> triggerNewMap) {
        Id[] employeeIdList = new Id[]{};
        Employee__c[] employeeList = new Employee__c[]{};
        AggregateResult[] employeeSummAssignedTimeList = new AggregateResult[]{};
        Map<Id,EmployeeWrapper> employeeWrapperList = new Map<Id,EmployeeWrapper>();
        // EmployeeWrapper[] employeeWrapperList = new EmployeeWrapper[]{};
        Map<Id, Integer> employeeSkillMap = new Map<Id, Integer>();

        for (EmployeeSkill__c employeeSkill : triggerNew) {
            employeeIdList.add(employeeSkill.Employee__c);
        }
        
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


        for (AggregateResult summAssignedTime : employeeSummAssignedTimeList) {
            Id id = (Id)summAssignedTime.get('Employee__c');
            Integer summ = Math.round((Decimal)summAssignedTime.get('summ'));
            employeeSkillMap.put(id, summ);
        }

        for (Employee__c employee : employeeList) {
            EmployeeWrapper newEmployeeWrapper = new EmployeeWrapper();
            newEmployeeWrapper.id = employee.Id;
            newEmployeeWrapper.availability = Math.round((Decimal)employee.Availability__c);
            newEmployeeWrapper.summAssignedTime = employeeSkillMap.get(employee.Id);

            employeeWrapperList.put(employee.Id, newEmployeeWrapper);
        }

        for (SObject employeeSkill : triggerNewMap.values())  {
            if (employeeWrapperList.containsKey((Id)employeeSkill.get('Employee__c'))) {
                EmployeeWrapper employeeWrapper = employeeWrapperList.get((Id)employeeSkill.get('Employee__c'));
                employeeWrapper.employeeSkillIdList.add(employeeSkill.Id);
            }
        }
        
        for (EmployeeWrapper employeeWrapper : employeeWrapperList.values()) {
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