@isTest
private class TestTriggerEmployee {
    @isTest static void TestInsert() {
        Employee__c employee1 = new Employee__c(
            First_Name__c = 'TestFirst',
            Last_Name__c = 'TestLast',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'QA',
            Level__c = 'Junior',
            Start_Date__c = System.today()
        );
 
        insert employee1;
 
        Employee__c employee2 = new Employee__c(
            First_Name__c = 'TestFirst',
            Last_Name__c = 'TestLast',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'QA',
            Level__c = 'Junior',
            Start_Date__c = System.today()
        );
 
        Employee__c employee3 = new Employee__c(
            First_Name__c = 'TestFirst2',
            Last_Name__c = 'TestLast2',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'QA',
            Level__c = 'Junior',
            Start_Date__c = System.today()
        );
 
        Test.startTest();
        Database.SaveResult resultWithError = Database.insert(employee2, false);
        Database.SaveResult result = Database.insert(employee3, false);
        Test.stopTest();
 
        System.assert(!resultWithError.isSuccess());
        System.assert(resultWithError.getErrors().size() > 0);
 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
    
    @isTest static void TestUpdate() {
        Employee__c employee1 = new Employee__c(
            First_Name__c = 'TestFirst',
            Last_Name__c = 'TestLast',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'QA',
            Level__c = 'Junior',
            Start_Date__c = System.today()
        );
 
        insert employee1;
 
        Employee__c employee2 = new Employee__c(
            Id = employee1.Id,
            First_Name__c = 'TestFirst',
            Last_Name__c = 'TestLast',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'DEV',
            Level__c = 'Trainee',
            Start_Date__c = System.today()
        );
 
        Employee__c employee3 = new Employee__c(
            First_Name__c = 'TestFirst2',
            Last_Name__c = 'TestLast2',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'QA',
            Level__c = 'Junior',
            Start_Date__c = System.today()
        );

        insert employee3;
        employee3.First_Name__c = 'TestFirst';
        employee3.Last_Name__c = 'TestLast';
        employee3.Birthday__c = System.today() - 10;
 
        Test.startTest();
        Database.SaveResult result = Database.update(employee2, false);
        Database.SaveResult resultWithError = Database.update(employee3, false);
        Test.stopTest();
 
        System.assert(!resultWithError.isSuccess());
        System.assert(resultWithError.getErrors().size() > 0);
 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
    
}