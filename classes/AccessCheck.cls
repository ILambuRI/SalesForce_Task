public class AccessCheck {
    private Map<String, Schema.SObjectType> allObjectsMap;
    
    public AccessCheck() {
        this.allObjectsMap = Schema.getGlobalDescribe();
    }
    
    public Boolean checkAccessToObject(String objectName, String accessType) {
       
        if(accessType == 'isAccessible' &&
           !allObjectsMap.get(objectName).getDescribe().isAccessible()) {
           return false;
        }
       
        if(accessType == 'isCreateable' &&
           !allObjectsMap.get(objectName).getDescribe().isCreateable()) {
           return false;
        }
        
        if(accessType == 'isUpdateable' &&
           !allObjectsMap.get(objectName).getDescribe().isUpdateable()) {
           return false;
        }
        
        if(accessType == 'isDeletable' &&
           !allObjectsMap.get(objectName).getDescribe().isDeletable()) {
           return false;
        }
        
        return true;
    }
    
     public Boolean checkAccessToObjectFields(String objectName, String accessType, List<String> fieldsToCheck){
       
        SObjectType objectType = allObjectsMap.get(objectName);
        Map<String, SObjectField> objectFieldMap = objectType.getDescribe().fields.getMap();
 
        if(accessType == 'isAccessible'){
            for (String fieldToCheck : fieldsToCheck) {
                if (!objectFieldMap.get(fieldToCheck).getDescribe().isAccessible()) {
                    return false;
                }
            }
        }
       
        if(accessType == 'isCreateable'){
            for (String fieldToCheck : fieldsToCheck) {
                if (!objectFieldMap.get(fieldToCheck).getDescribe().isCreateable()) {
                    return false;
                }
            }
        }
         
        if(accessType == 'isUpdateable'){
            for (String fieldToCheck : fieldsToCheck) {
                if (!objectFieldMap.get(fieldToCheck).getDescribe().isUpdateable()) {
                    return false;
                }
            }
        }
       
        return true;
    }
}