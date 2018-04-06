public class EmployeeTriggerHelper {
    public static void updateSumDevAndQaInProjects(Employee__c[] triggerNewOrOld, Boolean isDelete) {
        /* Creat set with Employee's ID which change */
        Set<Id> employeesIdSet = new Map<Id, Employee__c>(triggerNewOrOld).keySet();

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

    // public static void updateSumDevAndQaInProjects(Employee__c[] triggerNew, Map<Id, SObject> triggerNewMap, Boolean isInsert) {
    //     /* Get all EmployeeSkills by Employee's ID */
    //     EmployeeSkill__c[] empSkillsOfEmployeeList = [
    //         SELECT Project__c
    //         FROM EmployeeSkill__c
    //         WHERE Employee__c IN :triggerNew
    //     ];

    //     /* Exit if the employee does not have EmployeeSkills */
    //     if (empSkillsOfEmployeeList.size() == 0) {
    //         return;
    //     }

    //     /* Fill map with Project's ID and obj ProjectWrapper by list EmployeeSkills of Employees */
    //     Map<Id, EmployeeTriggerService.ProjectWrapper> projectWrapperMap = new Map<Id, EmployeeTriggerService.ProjectWrapper>();
    //     for (EmployeeSkill__c empSkill : empSkillsOfEmployeeList) {
    //         projectWrapperMap.put(empSkill.Project__c, new EmployeeTriggerService.ProjectWrapper(empSkill.Project__c));
    //     }

    //     /* Get all EmployeeSkills by Project's ID from map */
    //     EmployeeSkill__c[] allEmpSkillsByProjectId = [
    //         SELECT Employee__c, Project__c
    //         FROM EmployeeSkill__c
    //         WHERE Project__c IN :projectWrapperMap.keySet()
    //     ];

    //     /* Set with ID of all employees */
    //     Set<Id> allEmployeesIdFromProjectsSet = new Set<Id>();
    //     for (EmployeeSkill__c empSkill : allEmpSkillsByProjectId) {
    //         /* Add ID to set of obj ProjectWrapper with his employees */
    //         projectWrapperMap.get(empSkill.Project__c).projectEmployeesSet.add(empSkill.Employee__c);
    //         /* Add ID to set with all employees */
    //         allEmployeesIdFromProjectsSet.add(empSkill.Employee__c);
    //     }

    //     /* Get map with ID and Employees from set of all Employees by ID */
    //     Map<Id, Employee__c> allEmployeesByIdMap = new Map<Id, Employee__c>([
    //         SELECT isActive__c, IT_Department__c
    //         FROM Employee__c
    //         WHERE Id IN :allEmployeesIdFromProjectsSet
    //     ]);

    //     /* List with Projects for update */
    //     Project__c[] projectToUpdateList = new Project__c[]{};
    //     /* Count all active Employees with 'QA' and 'DEV' 'IT Department' for each Project */
    //     for (EmployeeTriggerService.ProjectWrapper projectWrapper : projectWrapperMap.values()) {
    //         for (Id employeeId : projectWrapper.projectEmployeesSet) {
    //             Employee__c employee = allEmployeesByIdMap.get(employeeId);

    //             if (employee.isActive__c == true &&
    //                 employee.IT_Department__c == 'QA') {

    //                 projectWrapper.qa += 1;
    //             }

    //             if (employee.isActive__c == true &&
    //                 employee.IT_Department__c == 'DEV') {

    //                 projectWrapper.dev += 1;
    //             }
    //         }

    //         Project__c projectToUpdate = new Project__c(
    //             Id = projectWrapper.id,
    //             QA__c = projectWrapper.qa,
    //             Developers__c = projectWrapper.dev
    //         );

    //         /* Add project for update with new value */
    //         projectToUpdateList.add(projectToUpdate);
    //     }

    //     update projectToUpdateList;
    // }

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