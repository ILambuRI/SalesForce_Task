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
    
    showToast : function(type, title, msg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            /*
            messageTemplate: '!!! Mode is sticky ,duration is 5sec and Message is overrriden because messageTemplateData is {0}{1}',
            messageTemplateData: ['Salesforce', {
                url: 'http://www.webkul.com/',
                label: 'Click Here',
            }],
            */
            duration:'1000',
            key: 'announcement',
            type: type,
            mode: 'dismissible'
        });
        
        toastEvent.fire();
    },
    
    /* Delete all props with value in array */
    delPropsWithValFromObjInArr : function(arr, propsName, propsVal) {
        for (let i=(arr.length-1); i>=0; i--) {
            if (arr[i].hasOwnProperty(propsName) &&
                arr[i][propsName] === propsVal) {
                
                arr.splice(i, 1);
            }
        }
    },
    
    /* Resume selectedWords(arr) from obj(store) by props name(arrSelectedSubject) */
    fillSelectedWordsFromStore : function(selectedWords, arrSelectedSubject, store) {
        for (let i=0; i < arrSelectedSubject.length; i++) {
            if ( store.hasOwnProperty(arrSelectedSubject[i]) ) {
                selectedWords = selectedWords.concat( store[arrSelectedSubject[i]] );
            }
        }
        
        return selectedWords;
    },

    showOrHideButton : function(cmp, tumbler) {
        let btn = cmp.find('btnToTheTop');

        $A.util.toggleClass(btn, 'slds-hide');

        // if (true === tumbler) {
        //     $A.util.removeClass(btn, 'slds-hide');
        // }
        // else {
        //     $A.util.addClass(btn, 'slds-hide');
        // }
    },

    toggleStickyProgress : function(cmp, tumbler) {
        console.log('SHOW or HIDE');
        
        let progress = cmp.find('progress');
        $A.util.toggleClass(progress, 'slds-hide');
    }
})