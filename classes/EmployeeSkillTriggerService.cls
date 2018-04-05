public class EmployeeSkillTriggerService {
	/* Get all employee ID */
	public static List<Id> createListAllEmployeeIdFormTriggerNew(EmployeeSkill__c[] triggerNew) {
		Id[] employeeIdList = new Id[]{};
		
        for (EmployeeSkill__c employeeSkill : triggerNew) {
            employeeIdList.add(employeeSkill.Employee__c);
        }

		return employeeIdList;
	}

    /* Fill map with ID of employee and his summ of 'Assigned Time' from EmployeeSkill */
	public static Map<Id, Integer> createMapEmployeeIdWithSummAssignedTime(AggregateResult[] employeeSummAssignedTimeList) {
        Map<Id, Integer> employeeSkillMap = new Map<Id, Integer>();

        for (AggregateResult summAssignedTime : employeeSummAssignedTimeList) {
            Id employeeId = (Id)summAssignedTime.get('Employee__c');
            Integer summ = Math.round((Decimal)summAssignedTime.get('summ'));
            employeeSkillMap.put(employeeId, summ);
        }

		return employeeSkillMap;
	}

    /* Fill map with ID of employee and obj EmployeeWrapper with params */
	public static Map<Id,EmployeeWrapper> createMapEmployeeIdWithEmployeeWrapper(Employee__c[] employeeList,
																				 Map<Id, Integer> employeeSkillMap,
																				 Map<Id, SObject> triggerNewMap) {
        Map<Id,EmployeeWrapper> employeeWrapperMap = new Map<Id,EmployeeWrapper>();

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

		return employeeWrapperMap;
	}

	/** Check, if Availability < Assigned Time for this employee
		* adds errors to all Employee Skill in Trigger.newMap
		* by ID from list in obj EmployeeWrapper
		*/
	public static void checkAvailabilityWithSummAssignedTime(Map<Id, EmployeeWrapper> employeeWrapperMap, Map<Id, SObject> triggerNewMap) {
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