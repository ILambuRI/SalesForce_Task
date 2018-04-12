public class Settings {
    private Map<String, String> messagesMap = new Map<String, String>();
    private Map<String, String> picklistValueForObjectEmployeeMap = new Map<String, String>();
    
    public Settings() {
        this.initMessagesMap();
        this.initPicklistValueForObjectEmployee();
    }

    public String getMessage(String key) {
        return this.messagesMap.get(key);
    }

    public String getValuePicklistFromObjectEmployee(String key) {
        return this.picklistValueForObjectEmployeeMap.get(key);
    }

    private void initMessagesMap() {
        this.messagesMap.put('MsgForUser' , 'Sorry technical problems, contact your administrator please!');
        this.messagesMap.put('NoDataFound_Exc_Prefix' , 'NoDataFoundException caught: ');
        this.messagesMap.put('SObject_Exc_Prefix' , 'SObjectException caught: ');
        this.messagesMap.put('NullPointer_Exc_Prefix' , 'NullPointerException caught: ');
        this.messagesMap.put('Query_Exc_Prefix' , 'QueryException caught: ');
        this.messagesMap.put('Exc_Prefix' , 'Exception caught: ');
        this.messagesMap.put('DML_Exc_Prefix' , 'DML Exception caught: ');
        this.messagesMap.put('SAVE_SUCCESS' , ' Saving successful!');
        this.messagesMap.put('EDIT_SUCCESS' , ' Editing successful!');
        this.messagesMap.put('DELETE_SUCCESS' , ' Deleting successful!');
        this.messagesMap.put('NO_ACCESS_ACCOUNT' , ' You do not have access to Accounts!');
        this.messagesMap.put('NO_ACCESS_CONTACT' , ' You do not have access to Contacts!');
    }

    private void initPicklistValueForObjectEmployee() {
        this.picklistValueForObjectEmployeeMap.put('DEV' , 'DEV');
        this.picklistValueForObjectEmployeeMap.put('QA' , 'QA');
    }
}