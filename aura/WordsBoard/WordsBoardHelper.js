({
	hideWord : function(cmp, word) {
        if ('eng' === word) {
            let word = cmp.find('engWord');
            let transcription = cmp.find('engWordTranscr');
            $A.util.addClass(word, 'slds-hide');
            $A.util.addClass(transcription, 'slds-hide');
        }
        else {
            let word = cmp.find('rusWord');
            $A.util.addClass(word, 'slds-hide');
        }
	},
    
    showWord : function(cmp, word) {
        if ('eng' === word) {
            let word = cmp.find('engWord');
            let transcription = cmp.find('engWordTranscr');
            $A.util.removeClass(word, 'slds-hide');
            $A.util.removeClass(transcription, 'slds-hide');
        }
        else if ('rus' === word) {
            let word = cmp.find('rusWord');
            $A.util.removeClass(word, 'slds-hide');
        }
        else {
            let engWord = cmp.find('engWord');
            let transcription = cmp.find('engWordTranscr');
            let rusWord = cmp.find('rusWord');
            $A.util.removeClass(engWord, 'slds-hide');
            $A.util.removeClass(transcription, 'slds-hide');
            $A.util.removeClass(rusWord, 'slds-hide');
        }
    },
    
    switchButtonAndInput : function(input, button, action) {
        if ('disable' === action) {
            input.set("v.disabled", true);
            button.set("v.disabled", true);
        }
        else {
            input.set("v.disabled", false);
            button.set("v.disabled", false);
        }
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
})