({
    //console.log(JSON.parse(JSON.stringify(selectedWords)))
    
    /* Get all parts of the Day and save to 'v.partsOfTheDay' */
    doInit : function(cmp, event, helper) {
        // let callback = function(response) {
        //     if ( "SUCCESS" === response.getState() ) {
		// 		cmp.set("v.partsOfTheDay", response.getReturnValue());
                
        //         helper.getNamesOfTheParts(cmp, response.getReturnValue());
                
		// 		//console.log(cmp.get("v.partsOfTheDay"));
        //     }
        //     else {
        //         console.log( "Failed with state: " +
        //                     response.getState() +
        //                     " in ReservationController|doInit()" );
        //     }
        // };
        
        // helper.sendRequest(cmp, "getPartsOfTheDay", false, callback);
        helper.getAllPartsOfTheDay(cmp);
    },
    
    handleClickOnPartBtn : function(cmp, event, helper) {
       	let partName = event.getSource().get('v.value');
        helper.formationPartArrByName(cmp, partName);
    }
})