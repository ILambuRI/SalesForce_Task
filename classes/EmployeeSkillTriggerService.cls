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
    
    /******************************************************************************************************************/

    /* Fill map with Project's ID and obj ProjectWrapper by list EmployeeSkill */
	public static Map<Id, ProjectWrapper> createMapProjectIdAndProjectWrapper(EmployeeSkill__c[] empSkillsOfEmployeeList) {
        Map<Id, ProjectWrapper> projectWrapperMap = new Map<Id, ProjectWrapper>();
        for (EmployeeSkill__c empSkill : empSkillsOfEmployeeList) {
            projectWrapperMap.put(empSkill.Project__c, new ProjectWrapper(empSkill.Project__c));
        }
        
        return projectWrapperMap;
    }

    /* Get all EmployeeSkills by Project's ID */
	public static List<EmployeeSkill__c> getAllEmployeeSkillsByProjectsId(Set<Id> projectIdList) {
        EmployeeSkill__c[] allEmpSkillsByProjectId = new EmployeeSkill__c[]{};

        try {
            for (EmployeeSkill__c[] employeeSkillListBatch : [
                    SELECT Employee__c, Project__c
                    FROM EmployeeSkill__c
                    WHERE Project__c IN :projectIdList
                ]) {
                
                allEmpSkillsByProjectId.addAll(employeeSkillListBatch);
                
            }
        } catch (QueryException e) {
            System.debug('Error in QueryException: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Error in Exception: ' + e.getMessage());
        }

        return allEmpSkillsByProjectId;
    }
    
	public static Map<Id, Employee__c> createMapWithIdAndEmployeesFromListEmployeeSkill(EmployeeSkill__c[] allEmpSkillsByProjectId) {
        Set<Id> allEmployeesIdFromProjectsSet = new Set<Id>();
        Map<Id, Employee__c> allEmployeesByIdMap = new Map<Id, Employee__c>();

        /* Add ID to set with all employees */
        for (EmployeeSkill__c empSkill : allEmpSkillsByProjectId) {
            allEmployeesIdFromProjectsSet.add(empSkill.Employee__c);
        }

        /** Get map with ID and Employee from set of all Employees by ID
         *  where 'isActive' true and 'IT Department' is 'DEV' or 'QA'
         */
        try {
            for (Employee__c[] employeeListBatch : [
                    SELECT IT_Department__c
                    FROM Employee__c
                    WHERE Id IN :allEmployeesIdFromProjectsSet
                    AND isActive__c = true
                    AND (IT_Department__c = 'DEV' OR IT_Department__c = 'QA')
                ]) {

                allEmployeesByIdMap.putAll(employeeListBatch);
            }

        } catch (QueryException e) {
            System.debug('Error in QueryException: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Error in Exception: ' + e.getMessage());
        }
        
        return allEmployeesByIdMap;
    }

    /* Add ID to set of obj ProjectWrapper with his employees */
	public static Map<Id, ProjectWrapper> addEmployeeIdToObjInMapWithProjectWrapper(Map<Id, ProjectWrapper> projectWrapperMap, EmployeeSkill__c[] allEmpSkillsByProjectId) {
        for (EmployeeSkill__c empSkill : allEmpSkillsByProjectId) {
            projectWrapperMap.get(empSkill.Project__c).projectEmployeesSet.add(empSkill.Employee__c);
        }

        return projectWrapperMap;
    }

    /* Count all active Employees with 'QA' and 'DEV' 'IT Department' for each Project */
	public static List<Project__c> createListOfProjectsForUpdate(Map<Id, Employee__c> allEmployeesByIdMap, Map<Id, ProjectWrapper> projectWrapperMap) {
        /* List with Projects for update */
        Project__c[] projectToUpdateList = new Project__c[]{};

        for (ProjectWrapper projectWrapper : projectWrapperMap.values()) {
            for (Id employeeId : projectWrapper.projectEmployeesSet) {
                /* If an employee exists */
                if ( !allEmployeesByIdMap.containsKey(employeeId) ) {
                    continue;
                }

                Employee__c employee = allEmployeesByIdMap.get(employeeId);
                /* Add +1 to count in obj ProjectWrapper */
                if (employee.IT_Department__c == 'QA') {
                    projectWrapper.qa += 1;
                }
                else if (employee.IT_Department__c == 'DEV') {
                    projectWrapper.dev += 1;
                }
            }

            /* Create new Project based on ProjectWrapper for update */
            Project__c projectToUpdate = new Project__c(
                Id = projectWrapper.id,
                QA__c = projectWrapper.qa,
                Developers__c = projectWrapper.dev
            );

            /* Add project for update with new value */
            projectToUpdateList.add(projectToUpdate);
        }

        return projectToUpdateList;
    }

    public static void salesforceCreateMiracle(Project__c[] projectToUpdateList) {
        /* Save state of objects */
        Savepoint sp = Database.setSavepoint();

        try {
            update projectToUpdateList;
        }
        catch(DMLException e) {
            /* Return to saved state */
            Database.rollback(sp);
            System.debug('Error in DMLException: ' + e.getMessage());
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error in Exception: ' + e.getMessage());
        }
    }

    public class ProjectWrapper
    {
        public Id id {get; set;}
        public Set<Id> projectEmployeesSet {get; set;} {projectEmployeesSet = new Set<Id>();}
        public Integer dev {get; set;} {dev = 0;}
        public Integer qa {get; set;} {qa = 0;}

        public ProjectWrapper(Id id) {
            this.id = id;
        }
    }

    public class EmployeeWrapper {
        public Id id {get; set;}
        public Integer availability {get; set;}
        public Integer summAssignedTime {get; set;}
        public Id[] employeeSkillIdList {get; set;} { employeeSkillIdList = new Id[]{}; }
    }
}