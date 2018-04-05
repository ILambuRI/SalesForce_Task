public class EmployeeTriggerHelper {
    public static void checkDuplicate(Employee__c[] triggerNew, Map<Id, SObject> triggerNewMap, Boolean isInsert) {
        List<String> firstNameList = new List<String>();
        List<String> lastNameList = new List<String>();
        Date[] birthdayList = new List<Date>();

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