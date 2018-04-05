public class EmployeeSkillTriggerHelper {
    public static void checkEmployeeAvailability(EmployeeSkill__c[] triggerNew, Map<Id, SObject> triggerNewMap) {
        Id[] employeeIdList = new Id[]{};
        Employee__c[] employeeList = new Employee__c[]{};
        AggregateResult[] employeeSummAssignedTimeList = new AggregateResult[]{};
        EmployeeWrapper[] employeeWrapperList = new EmployeeWrapper[]{};

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

        for (Employee__c employee : employeeList) {
            EmployeeWrapper newEmployeeWrapper = new EmployeeWrapper();
            newEmployeeWrapper.id = employee.Id;
            newEmployeeWrapper.availability = Math.round((Decimal)employee.Availability__c);

            for (AggregateResult summAssignedTime : employeeSummAssignedTimeList) {
                if (summAssignedTime.get('Employee__c') == employee.Id) {
                    newEmployeeWrapper.summAssignedTime = Math.round((Decimal)summAssignedTime.get('summ'));
                }
            }

            employeeWrapperList.add(newEmployeeWrapper);
        }
        
        for (EmployeeWrapper employeeWrapper : employeeWrapperList) {
            if (employeeWrapper.availability < employeeWrapper.summAssignedTime) {
                for (SObject employeeSkill : triggerNewMap.values())  {
                    if (employeeSkill.get('Employee__c') == employeeWrapper.id) {
                        employeeSkill.addError('Availability is less than overall Assigned Time!');
                    }
                }
            }
        }
    }

    public class EmployeeWrapper {
        Id id {get; set;}
        public Integer availability {get; set;}
        public Integer summAssignedTime {get; set;}
    }
}