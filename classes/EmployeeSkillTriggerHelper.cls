public class EmployeeSkillTriggerHelper {
    public static void checkEmployeeAvailability(EmployeeSkill__c[] triggerNew, Map<Id, SObject> triggerNewMap) {
        Id[] employeeIdList = new Id[]{};
        Employee__c[] employeeList = new Employee__c[]{};
        AggregateResult[] employeeSummAssignedTimeList = new AggregateResult[]{};
        Map<Id, EmployeeSkillTriggerService.EmployeeWrapper> employeeWrapperMap = new Map<Id, EmployeeSkillTriggerService.EmployeeWrapper>();
        Map<Id, Integer> employeeSkillMap = new Map<Id, Integer>();
        
        /* Get all employee ID */
        employeeIdList = EmployeeSkillTriggerService.createListAllEmployeeIdFormTriggerNew(triggerNew);
        
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
        employeeSkillMap = EmployeeSkillTriggerService.createMapEmployeeIdWithSummAssignedTime(employeeSummAssignedTimeList);

        /* Fill map with ID of employee and obj EmployeeWrapper with params */
        employeeWrapperMap = EmployeeSkillTriggerService.createMapEmployeeIdWithEmployeeWrapper(employeeList, employeeSkillMap, triggerNewMap);

        
        /** Check, if Availability < Assigned Time for this employee
          * adds errors to all Employee Skill in Trigger.newMap
          * by ID from list in obj EmployeeWrapper
          */
        EmployeeSkillTriggerService.checkAvailabilityWithSummAssignedTime(employeeWrapperMap, triggerNewMap);
    }

    /****************************************************************************************************************/

    public static void updateSumDevAndQaInProjects(EmployeeSkill__c[] triggerNewOrOld) {
        /* Fill map with Project's ID and obj ProjectWrapper by list EmployeeSkills from trigger list */
        Map<Id, EmployeeSkillTriggerService.ProjectWrapper> projectWrapperMap = EmployeeSkillTriggerService.createMapProjectIdAndProjectWrapper(triggerNewOrOld);
        
        /* Get all EmployeeSkills by Project's ID from map */
        EmployeeSkill__c[] allEmpSkillsByProjectId = EmployeeSkillTriggerService.getAllEmployeeSkillsByProjectsId(projectWrapperMap.keySet());
        
        /* Set with ID of all employees */
        Map<Id, Employee__c> allEmployeesByIdMap = EmployeeSkillTriggerService.createMapWithIdAndEmployeesFromListEmployeeSkill(allEmpSkillsByProjectId);
        
        /* Add ID to set of obj ProjectWrapper with his employees */
        projectWrapperMap = EmployeeSkillTriggerService.addEmployeeIdToObjInMapWithProjectWrapper(projectWrapperMap, allEmpSkillsByProjectId);
        
        /* Count all active Employees with 'QA' and 'DEV' 'IT Department' for each Project */
        Project__c[] projectToUpdateList = EmployeeSkillTriggerService.createListOfProjectsForUpdate(allEmployeesByIdMap, projectWrapperMap);
        
        /* Update Projects by ID with new data */
        EmployeeSkillTriggerService.salesforceCreateMiracle(projectToUpdateList);
    }
}