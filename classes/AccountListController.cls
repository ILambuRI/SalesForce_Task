public with sharing class AccountListController {
    /* For help in class */
    private Settings settings {get; set;}
    private Map<ID, AccountWrapper> accountsMapForSearch = new Map<ID, AccountWrapper>();

    /* For Visualforce page */
    public FormInputWrapper formInputs {get; set;} {formInputs = new FormInputWrapper();}
    /* Function params */
    public Id selectedId {get; set;}
    /* For rendered */
    public Boolean isSelectedAccount {get; set;} {isSelectedAccount = false;}
    public Boolean isShowModal {get; set;} {isShowModal = false;}
    public Boolean isNewModal {get; set;} {isNewModal = false;}
    /* Access to object */
    public AccessToObjectInfoWrapper accessToAccount {get; private set;}
    public AccessToObjectInfoWrapper accessToContact {get; private set;}

    /* Selected Account */
    public AccountWrapper selectedAccount {get; set;}
    /* List for repeat */
    public AccountWrapper[] accountsList {
        public get {
            /* TODO Access check */
            if (accountsList == null) {
                accountsList = this.setAccountsList();
            }

            return accountsList;
        }

        private set;
    }
    
    public AccountListController() {
        this.settings = new Settings();
        this.accessToAccount = new AccessToObjectInfoWrapper('Account');

        if (this.accessToAccount.isAccessible == false) {
            this.displayMessageOnPage('WARNING', this.settings.getMessage('NO_ACCESS_ACCOUNT'));
        }

        this.accessToContact = new AccessToObjectInfoWrapper('Contact');
        
        if (this.accessToContact.isAccessible == false) {
            this.displayMessageOnPage('WARNING', this.settings.getMessage('NO_ACCESS_CONTACT'));
        }

        System.debug(accessToAccount);
        System.debug(accessToContact);
    }
    
    /**
     * Get all Accounts, wrap and set to property accountsList
     */
    private AccountWrapper[] setAccountsList() {
        List<Account> result = new List<Account>();

        try {
            result = [
                SELECT Id, Name, (SELECT Id, FirstName, LastName, Email FROM Contacts)
                FROM Account
                LIMIT 10
            ];
        } catch (NoDataFoundException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('NoDataFound_Exc_Prefix'));
        } catch (SObjectException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('SObject_Exc_Prefix'));
        } catch (NullPointerException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('NullPointer_Exc_Prefix'));
        } catch (QueryException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('Query_Exc_Prefix'));
        } catch (Exception e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('Exc_Prefix'));
        }

        return this.wrapAccountsList(result);
    }

    public void switchModal() {
        this.isShowModal = !this.isShowModal;
    }

    public void switchAndClearModal() {
        this.formInputs = new FormInputWrapper();
        this.switchModal();
    }

    public void cancelModal() {
        this.switchAndClearModal();
    }

    public void newModal() {
        this.isNewModal = true;
        this.switchAndClearModal();
    }

    public void saveModal() {
        if (this.isNewModal) {
            this.saveNewContactForAccount();
        } else {
            this.editContactForAccount();
        }

        this.switchAndClearModal();
    }

    public void editModal() {
        this.isNewModal = false;

        for (ContactWrapper contact : this.selectedAccount.contactsList) {
            if (contact.id == this.selectedId) {
                this.formInputs.firstName = contact.firstName;
                this.formInputs.lastName = contact.lastName;
                this.formInputs.email = contact.email;

                break;
            }
        }
        
        this.switchModal();
    }

    private void saveNewContactForAccount() {
        Contact newContact = new Contact(
            FirstName = this.formInputs.firstName,
            LastName = this.formInputs.lastName,
            Email = this.formInputs.email,
            AccountId = this.selectedAccount.id
        );

        try {
            Database.SaveResult savedContact = Database.insert(newContact, false);

            if (savedContact.isSuccess()) {
                this.selectedAccount.contactsList.add(
                    new ContactWrapper(
                        savedContact.getId(),
                        this.formInputs.firstName,
                        this.formInputs.lastName,
                        this.formInputs.email
                    )
                );

                this.displayMessageOnPage('CONFIRM', this.settings.getMessage('SAVE_SUCCESS'));
            } else {
                Database.Error error = savedContact.getErrors()[0];
                this.displayMessageOnPage('ERROR', ' ' + error.getMessage());
            }
        } catch (DmlException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('DML_Exc_Prefix'));
        }
    }

    private void editContactForAccount() {
        Contact newContact = new Contact(
            Id = this.selectedId,
            FirstName = this.formInputs.firstName,
            LastName = this.formInputs.lastName,
            Email = this.formInputs.email
        );

        try {
            UPDATE newContact;

            Integer sizeContactsList = this.selectedAccount.contactsList.size();
            for (Integer i=(sizeContactsList - 1); i>=0; i--) {
                if (this.selectedAccount.contactsList[i].id == this.selectedId) {
                    this.selectedAccount.contactsList[i].firstName = this.formInputs.firstName;
                    this.selectedAccount.contactsList[i].lastName = this.formInputs.lastName;
                    this.selectedAccount.contactsList[i].email = this.formInputs.email;
                }
            }

            this.displayMessageOnPage('CONFIRM', this.settings.getMessage('EDIT_SUCCESS'));
        } catch (DmlException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('DML_Exc_Prefix'));
        }
    }

    public void setSelectedAccountById() {
        this.selectedAccount = this.accountsMapForSearch.get(this.selectedId);
        this.isSelectedAccount = true;
        // String id = Apexpages.currentPage().getParameters().get('id');     
        // System.debug(this.selectedId);
    }

    public void deleteContactsFromSelectedAccount() {
        Contact[] contactForDeleteList = new List<Contact>();
        Id[] contactsIdForDeleteList = new List<Id>();
        Integer sizeContactsList = this.selectedAccount.contactsList.size();
        
        if (sizeContactsList == 0) {
            return;
        }

        for (Integer i=(sizeContactsList - 1); i>=0; i--) {
            if (this.selectedAccount.contactsList[i].forDelete == true) {
                contactsIdForDeleteList.add(this.selectedAccount.contactsList[i].id);
                this.selectedAccount.contactsList.remove(i);
            }
        }

        contactForDeleteList = [
            SELECT Id 
            FROM Contact
            WHERE Id IN :contactsIdForDeleteList
        ];
        
        if (contactForDeleteList.isEmpty()) {
            return;
        }

        try {
            DELETE contactForDeleteList;

            this.displayMessageOnPage('CONFIRM', this.settings.getMessage('DELETE_SUCCESS'));
        } catch (DmlException e) {
            this.displayMessageFromCatch(e, this.settings.getMessage('MsgForUser'), this.settings.getMessage('DML_Exc_Prefix'));
        }
    }

    private void displayMessageOnPage(String type, String msg) {
        if (type == 'CONFIRM') {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.CONFIRM, msg)
            );
        } else if (type == 'ERROR') {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, msg)
            );
        } else if (type == 'FATAL') {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.FATAL, msg)
            );
        } else if (type == 'INFO') {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.INFO, msg)
            );
        } else if (type == 'WARNING') {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.WARNING, msg)
            );
        }
    }

    private void displayMessageFromCatch(Exception obj, String displayMsg, String consolePrefixMsg) {
            this.displayMessageOnPage('FATAL', displayMsg);
            System.debug(consolePrefixMsg + ' ' + obj.getMessage());
    }

    private void requiredFieldsForObjects() {
        //get required fields for usergiven sObjects
        List<String> sObjList = new List<String>{'Account', 'Contact'};
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(sObjList);
        Map<String, List<String>> objToRequiredFieldsMap = new Map<String, List<String>>();

        for(Schema.DescribeSObjectResult dsr : descResult) {
            List<String> requiredFields = new List<String>();
            //get required fields
            Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();

            for(String str : fieldMap.keySet()){
                Schema.DescribeFieldResult f = fieldMap.get(str).getDescribe();

                if(!f.isNillable()){
                    requiredFields.add(f.getName());
                }
            }

            objToRequiredFieldsMap.put(dsr.getName(), requiredFields);
        }

        // System.debug(objToRequiredFieldsMap);
    }

    private AccountWrapper[] wrapAccountsList(Account[] paramList) {
        AccountWrapper[] accountsList = new List<AccountWrapper>();

        if (!paramList.isEmpty()) {
            for (Account account : paramList) {
                AccountWrapper newAccount = new AccountWrapper(
                    account.Id,
                    account.Name,
                    this.wrapContactsList(account.Contacts)
                );

                accountsList.add(newAccount);
                this.accountsMapForSearch.put(account.Id, newAccount);
            }
        }

        return accountsList;
    }

    private ContactWrapper[] wrapContactsList(Contact[] paramList) {
        ContactWrapper[] contactsList = new List<ContactWrapper>();

        if (!paramList.isEmpty()) {
            for (Contact contact : paramList) {
                ContactWrapper newContact = new ContactWrapper(
                    contact.Id,
                    contact.FirstName,
                    contact.LastName,
                    contact.Email
                );

                contactsList.add(newContact);
            }
        }

        return contactsList;
    }

    public class AccountWrapper {
        public Id id {get; set;}
        public String name {get; set;}
        // Schema.SObjectField name {get; set;}
        public ContactWrapper[] contactsList {get; set;}

        public AccountWrapper(Id id, String name, ContactWrapper[] contactsList) {
            this.id = id;
            this.name = name;
            this.contactsList = contactsList;
        }
    }

    public class ContactWrapper {
        public Id id {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        public Boolean forDelete {get; set;} {forDelete = false;}
        // Schema.SObjectField firstName {get; set;}
        // Schema.SObjectField lastName {get; set;}

        public ContactWrapper(Id id, String firstName, String lastName, String email) {
            this.id = id; 
            this.firstName = firstName;
            this.lastName = lastName;        
            this.email = email;        
        }
    }

    public class FormInputWrapper {
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}

        public FormInputWrapper() {
            this.firstName = '';
            this.lastName = '';        
            this.email = '';        
        }

        public FormInputWrapper(String firstName, String lastName, String email) {
            this.firstName = firstName;
            this.lastName = lastName;        
            this.email = email;        
        }
    }

    public class AccessToObjectInfoWrapper {
        public Boolean isAccessible {get; set;}
        public Boolean isCreateable {get; set;}
        public Boolean isUpdateable {get; set;}
        public Boolean isDeletable {get; set;}

        public AccessToObjectInfoWrapper(String objName) {
            AccessCheck access = new AccessCheck();
            this.isAccessible = access.checkAccessToObject(objName, 'isAccessible');
            this.isCreateable = access.checkAccessToObject(objName, 'isCreateable');
            this.isUpdateable = access.checkAccessToObject(objName, 'isUpdateable');
            this.isDeletable = access.checkAccessToObject(objName, 'isDeletable');

        }
    }
}