public class EmployeeTriggerHelper {
    public static void updateSumDevAndQaInProjects(Map<Id,SObject> triggerNewMap, Map<Id,SObject> triggerOldMap, Boolean isDelete, Boolean isUpdate, Boolean isUndelete) {
        Set<Id> employeesIdSet = new Set<Id>();

        if (isUpdate) {
            employeesIdSet = EmployeeTriggerService.createSetIdWithFilteredEmployeeOnUpdate(triggerNewMap, triggerOldMap);
        }
        else if (isDelete) {
            employeesIdSet = EmployeeTriggerService.createSetIdWithFilteredEmployeeOnDeleteOrUndelete(triggerOldMap);
        }
        else if (isUndelete) {
            employeesIdSet = EmployeeTriggerService.createSetIdWithFilteredEmployeeOnDeleteOrUndelete(triggerNewMap);
        }

        /* Exit if the employee set with ID is empty after filtering */
        if (employeesIdSet.size() == 0) {
            return;
        }
        
        System.debug('Recalculate');
        // /* Creat set with Employee's ID which change */
        // Set<Id> employeesIdSet = new Map<Id, Employee__c>(triggerNew).keySet();

        /* Get all EmployeeSkills by Employee's ID */
        EmployeeSkill__c[] empSkillsOfEmployeeList = EmployeeTriggerService.getListAllEmployeeSkillByEmployeeId(employeesIdSet);

        /* Exit if the employee does not have EmployeeSkills */
        if (empSkillsOfEmployeeList.size() == 0) {
            return;
        }

        /* Fill map with Project's ID and obj ProjectWrapper by list EmployeeSkills from Employees */
        Map<Id, EmployeeTriggerService.ProjectWrapper> projectWrapperMap = EmployeeTriggerService.createMapProjectIdAndProjectWrapper(empSkillsOfEmployeeList);
        
        /* Get all EmployeeSkills by Project's ID from map */
        EmployeeSkill__c[] allEmpSkillsByProjectId = EmployeeTriggerService.getAllEmployeeSkillsByProjectsId(projectWrapperMap.keySet());
        
        /* Set with ID of all employees */
        Map<Id, Employee__c> allEmployeesByIdMap = EmployeeTriggerService.createMapWithIdAndEmployeesFromListEmployeeSkill(allEmpSkillsByProjectId, employeesIdSet, isDelete);
        
        /* Add ID to set of obj ProjectWrapper with his employees */
        projectWrapperMap = EmployeeTriggerService.addEmployeeIdToObjInMapWithProjectWrapper(projectWrapperMap, allEmpSkillsByProjectId);
        
        /* Count all active Employees with 'QA' and 'DEV' 'IT Department' for each Project */
        Project__c[] projectToUpdateList = EmployeeTriggerService.createListOfProjectsForUpdate(allEmployeesByIdMap, projectWrapperMap);
        
        /* Update Projects by ID with new data */
        EmployeeTriggerService.salesforceCreateMiracle(projectToUpdateList);
    }

    public static void checkDuplicate(Employee__c[] triggerNew, Map<Id, SObject> triggerNewMap, Boolean isInsert) {
        String[] firstNameList = new String[]{};
        String[] lastNameList = new String[]{};
        Date[] birthdayList = new Date[]{};

        for (Employee__c employee : triggerNew) {
            firstNameList.add(employee.First_Name__c);
            lastNameList.add(employee.Last_Name__c);
            birthdayList.add(employee.Birthday__c);
        }

        Employee__c[] resultList = [
            SELECT Id, First_Name__c, Last_Name__c, Birthday__c
            FROM Employee__c
            WHERE First_Name__c IN :firstNameList
            AND Last_Name__c IN :lastNameList
            AND Birthday__c IN :birthdayList
        ];

        if (resultList.size() == 0) {
            return;
        }

        // if (isInsert) {
            for (Employee__c duplicateEmployee : resultList) {
                for (Employee__c newEmployee : triggerNew) {
                    if (duplicateEmployee.First_Name__c == newEmployee.First_Name__c &&
                        duplicateEmployee.Last_Name__c == newEmployee.Last_Name__c &&
                        duplicateEmployee.Birthday__c == newEmployee.Birthday__c &&
                        duplicateEmployee.Id != newEmployee.Id) {
                            newEmployee.addError('You can not add duplicate entries!');
                    }
                }
            }
        // } else {
        //     for (Employee__c duplicateEmployee : resultList) {
        //             if ( !(triggerNewMap.get(duplicateEmployee.Id) instanceof Employee__c) ) {
        //                 triggerNewMap.get(duplicateEmployee.Id).addError('You can not add duplicate entries!');
        //             } 
        //     }
        // }
    }
}