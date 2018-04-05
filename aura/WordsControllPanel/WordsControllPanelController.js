({
    //console.log(JSON.parse(JSON.stringify(cmp.get("v.buttonStatus"))));

    /* Fire event to 'RandomWords.cmp' to resume selected words by lesson(s) (Subject__c) */
    clickOnRefreshBtn : function(cmp) {
        cmp.getEvent("eventClickedRefresh").fire();
    },

    clickSelectLesson : function(cmp, event) {
        /* Get all buttons */
        let btnRefresh = cmp.find('refresh');
        let btnSelect = cmp.find('select');
        let btnFinish = cmp.find('finish');

        /* Get the name of the clicked button */
        let btnName = event.getSource().get('v.name');
        let action = 'select' === btnName ? 'show' : 'hide';

        /* Setting classes depending on the action */
        if ('show' === action) {
            $A.util.addClass(btnRefresh, 'slds-hide');
            $A.util.addClass(btnSelect, 'slds-hide');
            $A.util.removeClass(btnFinish, 'slds-hide');
        }
        else {
            $A.util.addClass(btnFinish, 'slds-hide');
            $A.util.removeClass(btnRefresh, 'slds-hide');
            $A.util.removeClass(btnSelect, 'slds-hide');
        }
        
        /* Fire event to 'RandomWords.cmp' */
        cmp.getEvent('eventClickShowOrHideLesson')
        .setParams({
            'action' : action
        })
        .fire();
    },
})