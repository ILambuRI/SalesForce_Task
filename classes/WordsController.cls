public with sharing class WordsController {
    @AuraEnabled
    /* Return all objs 'Words__c' where Subject__c == subject */
    public static List<Words__c> getWordsBySubject(String subject) {
        return [
            SELECT English__c, Russian__c, Transcription__c, Subject__c
            FROM Words__c
            WHERE Subject__c = :subject
        ];
    }
    

    @AuraEnabled
    /* Return Subject__c DISTINCT */
    public static String[] getAllSubjectDistinct() {
        Set<Words__c> allWords = new Set<Words__c>([SELECT Subject__c FROM Words__c]);

        Set<String> uniqueSubjects = new Set<String>();
        
        for (Words__c value : allWords) {
            uniqueSubjects.add(value.Subject__c);
        }
        
        return new List<String>(uniqueSubjects);
    }
    
}