@isTest
private class TestTriggerEmployeeSkill {

    @testSetup static void setup() {
        Employee__c employee1 = new Employee__c(
            First_Name__c = 'TestFirst',
            Last_Name__c = 'TestLast',
            Birthday__c = System.today() - 10,
            IT_Department__c = 'QA',
            Level__c = 'Junior',
            Start_Date__c = System.today()
        );
 
        insert employee1;

        Project__c project1 = new Project__c(
            Name = 'Test1',
            Start_Date__c = System.today() - 10,
            Priority__c = 'Hot',
            Team_Lead__c = employee1.Id,
            Project_Owner__c = employee1.Id
        );

        insert project1;

        EmployeeSkill__c employeeSkill1 = new EmployeeSkill__c(
            Name = 'Test1',
            Assigned_Time__c = 1,
            Employee__c = employee1.Id,
            Project__c = project1.Id
        );
 
        insert employeeSkill1;

        EmployeeSkill__c employeeSkill2 = new EmployeeSkill__c(
            Name = 'Test2',
            Assigned_Time__c = 1,
            Employee__c = employee1.Id,
            Project__c = project1.Id
        );
 
        insert employeeSkill2;
    }

    @isTest static void TestInsert() {

        Employee__c[] employeeList = [
            SELECT Id
            FROM Employee__c
            WHERE First_Name__c = 'TestFirst'
        ];
        
        Employee__c employee1 = employeeList[0];

        Project__c[] projectList = [
            SELECT Id
            FROM Project__c
            WHERE Name = 'Test1'
        ];

        Project__c project1 = projectList[0];

        EmployeeSkill__c employeeSkill2 = new EmployeeSkill__c(
            Name = 'Test2',
            Assigned_Time__c = 6,
            Employee__c = employee1.Id,
            Project__c = project1.Id
        );


        EmployeeSkill__c employeeSkill3 = new EmployeeSkill__c(
            Name = 'Test3',
            Assigned_Time__c = 7,
            Employee__c = employee1.Id,
            Project__c = project1.Id
        );
 
        Test.startTest();
        Database.SaveResult result = Database.insert(employeeSkill2, false);
        Database.SaveResult resultWithError = Database.insert(employeeSkill3, false);
        Test.stopTest();
 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
 
        System.assert(!resultWithError.isSuccess());
        System.assert(resultWithError.getErrors().size() > 0);
    }
    
    @isTest static void TestUpdate() {
        EmployeeSkill__c[] queryResult1 = [
            SELECT Assigned_Time__c
            FROM EmployeeSkill__c
            WHERE Name = 'Test1'
        ];

        EmployeeSkill__c[] queryResult2 = [
            SELECT Assigned_Time__c
            FROM EmployeeSkill__c
            WHERE Name = 'Test2'
        ];

        EmployeeSkill__c employeeSkillSuccess = queryResult1[0];
        employeeSkillSuccess.Assigned_Time__c = 7;

        EmployeeSkill__c employeeSkillError = queryResult2[0];
        employeeSkillError.Assigned_Time__c = 8;



        Test.startTest();
        Database.SaveResult result = Database.update(employeeSkillSuccess, false);
        Database.SaveResult resultWithError = Database.update(employeeSkillError, false);
        Test.stopTest();
 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
 
        System.assert(!resultWithError.isSuccess());
        System.assert(resultWithError.getErrors().size() > 0);
    }
    
}