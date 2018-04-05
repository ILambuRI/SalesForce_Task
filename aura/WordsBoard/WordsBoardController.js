({
    /* Show any hidden word and disable input with button */
	clickShowHiddenWord : function(cmp, event, helper) {
        let word = cmp.get('v.word');

        /* If word is empty - show Toast */
        if ( !word  || (Object.keys(word).length === 0) ) {
            helper.showToast('', 'Sorry!', 'There\'s nothing to show');
            return;
        }

        let input = cmp.find('wordInput');
        let button = cmp.find('checkButton');

        helper.showWord(cmp);
        
        /* Clear input if 'word.enteredWord' is blank */
        if (!word.enteredWord) {
            input.set('v.value', '');
        }

        helper.switchButtonAndInput(input, button, 'disable');
	},
    
    /* Fire event onclick to 'RandomWords.cmp'
     * Hide word 'rus' or 'eng', activate input and show 'check' button
     */
	clickGetRandomWord : function(cmp, event, helper) {
        cmp.getEvent('eventGetNextRandomWord').fire();
        
        let input = cmp.find('wordInput');
        /* Clear input value */
        input.set('v.value', '');
        
        let button = cmp.find('checkButton');
        /* Active input and show button */
        helper.switchButtonAndInput(input, button, 'show');

        let word = cmp.get('v.word');
        /* If the word is not empty */
        if ( word && Object.keys(word).length ) {
            /* Get unique clicked elment name 'eng' or 'rus' */
            let clickedBtnName = event.getSource().get("v.name");

            if ('eng' === clickedBtnName) {
                helper.hideWord(cmp, 'rus');
                helper.showWord(cmp, 'eng');
            }
            else {
                helper.hideWord(cmp, 'eng');
                helper.showWord(cmp, 'rus');
            }
        }
	},
    
    /* Set new state from word entered, show hidden word and disable input and button */
    clickCheckWord : function(cmp, event, helper) {
        let word = cmp.get("v.word");
        if ( Object.keys(word).length === 0 ) return;
        
        let button = event.getSource();
        let input = cmp.find('wordInput');
        
        /* Set the entered value from input to 'v.word' */
        word.enteredWord = input.get("v.value").trim();
        if (!word.enteredWord) return;
        
		/* Show hidden word */
        helper.showWord(cmp);
        
        /* Disable input and button */
        helper.switchButtonAndInput(input, button, 'disable');

        /* Set check status to 'v.word' */
        if (word.enteredWord === word.English__c.trim()) {
            helper.showToast('success', 'Excellent!', 'Correct input ...');
            word.checkStatus = 'success';
            input.set("v.value", word.enteredWord + ' - success');
        }
        else {
            helper.showToast('error', 'Mistake!', 'Invalid input ...');
            word.checkStatus = 'error';
            input.set("v.value", word.enteredWord + ' - error');
        }
        
        cmp.set("v.word", word);
    },
    
    /* Add default props to word(obj) onchange in 'v.word' */
    addPropsToWord : function(cmp, event) {
        let word = event.getParam("value");
        
        if (Object.keys(word).length === 0 ||
            word.hasOwnProperty('checkStatus') ||
            word.hasOwnProperty('engWordLength') ||
            word.hasOwnProperty('enteredWord') ) {
            
            return;
        }
        
        word['engWordLength'] = word.English__c.length;
        word['checkStatus'] = 'skipped';
        word['enteredWord'] = '';
        
        cmp.set("v.word", word);
    }
})