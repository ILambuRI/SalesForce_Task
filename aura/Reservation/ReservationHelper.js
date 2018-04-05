({
    /* Silly request on the Server */
    sendRequest : function(cmp, apexMethodName, methodParams, callbackFunction) {
        let request = cmp.get('c.' + apexMethodName);
        
        if (methodParams) {
            request.setParams(methodParams);
        }
        
        if (callbackFunction) {
            request.setCallback(this, callbackFunction);
        }
        
        $A.enqueueAction(request);
    },
    
    formationPartArrByName : function(cmp, name) {
        let parts = cmp.get('v.partsOfTheDay');
        let currentPart = cmp.get('v.currentPart');
        currentPart = [];
        
        for (let hourKey in parts[name]) {
            let newMinutes = [];
            
            parts[name][hourKey].forEach(function(element) {
                for (let minuteKey in element) {
                    newMinutes.push({
                        minute: minuteKey,
                        description: element[minuteKey]
                    });                    
                }
            });

            
            currentPart.push({
                hour: hourKey,
                minutes: newMinutes
            });
        }
        
        cmp.set('v.currentPart', currentPart);
        //console.log(cmp.get('v.currentPart'));
    },
    
    getNamesOfTheParts : function(cmp, obj) {
        let partsNames = cmp.get('v.partsNames');
		partsNames = Object.keys(obj);
        cmp.set('v.partsNames', partsNames);

        //console.log(cmp.get('v.partsNames'));
    },

    getAllPartsOfTheDay : function(cmp) {
        let callback = function(response) {
            if ( "SUCCESS" === response.getState() ) {
				cmp.set("v.partsOfTheDay", response.getReturnValue());
                
                this.getNamesOfTheParts(cmp, response.getReturnValue());
                
				//console.log(cmp.get("v.partsOfTheDay"));
            }
            else {
                console.log( "Failed with state: " +
                            response.getState() +
                            " in ReservationController|doInit()" );
            }
        };
        
        this.sendRequest(cmp, "getPartsOfTheDay", false, callback);
    }
})