public with sharing class ReservationController {
    
    @AuraEnabled
    public static Map< String, Map<Integer, List<Map<String, String>>> > getPartsOfTheDay() {
        Map<String, Reservation_Settings__c> partsOfDay = Reservation_Settings__c.getAll();

        List<String> partsName = new List<String>();
        partsName.addAll( partsOfDay.keySet() );

        Map< String, Map<Integer, List<Map<String, String>>> > formattedData = new Map< String, Map<Integer, List<Map<String, String>>> >();

        for (String partName : partsName) {
            Reservation_Settings__c currentPart = partsOfDay.get(partName);

            
            Map<Integer, List<Map<String, String>> > listOfHours = new Map<Integer, List<Map<String, String>> >();
            

            for (Integer i = Math.round(currentPart.Start__c); i < Math.round(currentPart.End__c); i++) {
                List< Map<String, String> > listOfMinutes = new List< Map<String, String> >();

                
                Integer cnt = 0;

                for (Integer j = 1; j < 60; j++) {
                    cnt++;

                    if ( cnt == Math.round(currentPart.Separation__c) ) {
                        Map<String, String> minute = new Map<String, String>();
                        String minuteNumber = String.valueOf(j);

                        if (j < 10) {
                            minuteNumber = '0' + minuteNumber;
                        }
                        
						minute.put(minuteNumber, 'Description here ...');
                        listOfMinutes.add(minute);
                        cnt = 0;
                    }
                    else if (j == 1) {
                        Map<String, String> minute = new Map<String, String>();
                        minute.put('00', 'Description here ...');
                        listOfMinutes.add(minute);
                    }
                }

                listOfHours.put(i, listOfMinutes);
            }

            formattedData.put(partName, listOfHours);
        }

        return formattedData;
        //System.debug(formattedData);
    }
}