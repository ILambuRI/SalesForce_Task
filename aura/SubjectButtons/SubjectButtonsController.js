({
    //console.log(JSON.parse(JSON.stringify(cmp.get("v.buttonStatus"))));
    
    /* Send event add/delete(RandomWords.cmp) & disable btn onclick before response */
    clickOnSubjectBtn : function(cmp, event) {
        let action = "";
        let btn = event.getSource();
        /* Disabling the button before response */
        btn.set("v.disabled", "true");
        /* Get btn label */
        let btnLabel = btn.get("v.label");
        /* Get obj from attribute 'buttonStatus' */
        let btnStatus = cmp.get("v.buttonStatus");
		
        /* Set action for event */
        if (!btnStatus.hasOwnProperty(btnLabel) || btnStatus[btnLabel] === 'unselected') {
            action = "ADD";
        }
        else {
            action = "DELETE";
        }
		
        /* Fire event with action and btn label to 'RandomWords.cmp' */
        cmp.getEvent("eventClickedSubject")
        .setParams({
            "subjectName" : btnLabel,
            "action" : action
        })
        .fire();
    },
    
    /* Handle on value change in attribute 'changedButtonName' (response from RandomWords.cmp) */
    handleButtonNameChange : function(cmp, event) {
        /* Exit if value is blank */
        if ("" === event.getParam("value")) 
            return;
        
        let btnLabel = event.getParam("value");
        
        /* Find button with label == 'btnLabel' in all buttons */
        let btnForChange = cmp.find('allButtons');
        btnForChange = btnForChange.find(function(element, index, array) {
            if (btnLabel === element.get("v.label")) {
                return true;
            }
            
            return false
        });
        
        /* Activate the button after response */
        btnForChange.set("v.disabled", "false");
        
        /* Set button color and status in attribute 'buttonStatus' */
        let btnStatus = cmp.get("v.buttonStatus");
        
        if (!btnStatus.hasOwnProperty(btnLabel) || btnStatus[btnLabel] === 'unselected') {
            btnForChange.set("v.variant", "success");
            btnStatus[btnLabel] = "selected";
        }
        else {
            btnForChange.set("v.variant", "brand");
            btnStatus[btnLabel] = "unselected";
        }
        
        cmp.set("v.buttonStatus", btnStatus);
        
        /* Clear value for handle the same value again */
        cmp.set("v.changedButtonName", "");
    },
})