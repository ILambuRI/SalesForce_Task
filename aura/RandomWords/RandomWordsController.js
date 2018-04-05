({
    //console.log(JSON.parse(JSON.stringify(selectedWords)))
    
    /* Get all Subject__c DISTINCT for buttons label (SubjectButtons.cmp)*/
    doInit : function(cmp, event, helper) {
        let callback = function(response) {
            if ( "SUCCESS" === response.getState() ) {
                cmp.set("v.uniqueSubjects", response.getReturnValue());
            }
            else {
                console.log( "Failed with state: " +
                            response.getState() +
                            " in RandomWordsController|doInit()" );
            }
        };
        
        helper.sendRequest(cmp, "getAllSubjectDistinct", false, callback);
    },
    
    /* Handling an Event from a Component SubjectButtons.cmp */
    handleClickedSubject : function(cmp, event, helper) {
        let subjectName = event.getParam('subjectName');
        let action = event.getParam('action');
        
        /* Adding all items with a Subject__c == 'subjectName' to 'v.selectedWords' 
         * and 'v.storeSelectedWords' arrays from Database
         */
        if ("ADD" === action) {
            let params = {"subject" : subjectName};
            let callback = function(response) {
                if ( "SUCCESS" === response.getState() ) {
                    let result = response.getReturnValue();
                    
                    /* Add to store.
                     * This must be in front of the 'v.selectedWords' and 'v.buttonNameForChange'
                     * for the correct processing in the 'WordsProgress.cmp'.
                     */
                    var store = cmp.get("v.storeSelectedWords");
                    store[subjectName] = result;
                    cmp.set("v.storeSelectedWords", store);

                    /* Set changed Subject name(btn name) for 'SubjectButtons.cmp'.
                     * This must be in front of the 'v.selectedWords'
                     * for the correct processing in the 'WordsProgress.cmp'.
                     */
                    cmp.set("v.buttonNameForChange", subjectName);
                    
                    /* Add to all 'v.selectedWords' */
                    let selectedWords = cmp.get("v.selectedWords").concat(result);
                    cmp.set("v.selectedWords", selectedWords);
                }
                else {
                    console.log( "Failed with state: " +
                                response.getState() +
                                " in RandomWordsController|addToSelectedWords()" );
                }
            };
            
            helper.sendRequest(cmp, "getWordsBySubject", params, callback);
        }
        
        /* Deleting all items with a Subject__c == 'subjectName' from 'selectedWords' array */
        if ("DELETE" === action) {
            /* Set changed Subject name(btn name) for 'SubjectButtons.cmp'
             * This must be in front of the 'v.selectedWords' for the correct processing in the 'WordsProgress.cmp'
             */
            cmp.set("v.buttonNameForChange", subjectName);
            
            let selectedWords = cmp.get('v.selectedWords');
            helper.delPropsWithValFromObjInArr(selectedWords, 'Subject__c', subjectName);
            cmp.set('v.selectedWords', selectedWords);

            if (!selectedWords.length) {
                cmp.set('v.randomWord', {});
            }
        }
    },
    
    /* Handle event from 'WordsBoard.cmp' */
    getRandomWord : function(cmp, event, helper) {
        let randomWord = cmp.get("v.randomWord");
        /* Array with all selected words */
        let selectedWords = cmp.get("v.selectedWords");
        //console.log(JSON.parse(JSON.stringify(cmp.get('v.buttonStatus'))))


        /* Send info msg and return */
        if ( (!randomWord || Object.keys(randomWord).length === 0) && selectedWords.length == 0 ) {
            let buttonStatus = cmp.get('v.buttonStatus');

            /* If 'v.selectedWords' is empty and lesson(s) selected */
            if (buttonStatus && Object.keys(buttonStatus) !== 0) {
                let isSelected = Object.keys(buttonStatus).some(function(value) {
                    return 'selected' === buttonStatus[value];
                });
    
                if (isSelected) {
                    helper.showToast('', 'Wait!', 'Choose new lesson(s) or refresh selected!');
                    // alert('Wait! Select lesson(s) first!');
                    return;
                }
            }

            /* If 'v.selectedWords' is empty and no lesson(s) have been selected */
            helper.showToast('', 'Wait!', 'Select lesson(s) first!');
            // alert('Wait! Select lesson(s) first!');
			return;
        }

        /* Set new value in 'v.oldRandomWord' for 'c.WordsHistory' */
        if ( randomWord && Object.keys(randomWord).length !== 0 ) {
            cmp.set("v.oldRandomWord", randomWord);
        }
        
        /* Get and delete random element from 'v.selectedWords' */
        let newRandomWord = {};

        if (selectedWords.length !== 0) {
            newRandomWord = selectedWords.splice( (selectedWords.length * Math.random() << 0), 1 )[0];
            cmp.set("v.selectedWords", selectedWords);
        }

        /* Set new word(Obj) to 'v.randomWord' for 'WordsBoard.cmp' */
        cmp.set("v.randomWord", newRandomWord);

        /* Send info msg if it was the last word from 'v.selectedWords' */
        if (Object.keys(newRandomWord).length !== 0 && selectedWords.length === 0) {
            helper.showToast('success', 'Congratulation!', 'This is your last word!');
            // alert('Congratulation! This is your last word!');
        }
    },
    
    /* Resume all words in 'v.selectedWords' from 'v.storeSelectedWords' by selected Subject */
    handleClickedRefresh : function(cmp, event, helper) {
        /* Get list of selected Subject(s) */
        // let arrSelectedSubject = event.getParam("selectedLesson");
        let buttonStatus = cmp.get("v.buttonStatus");
        let arrSelectedLesson = [];
        
        for (let key in buttonStatus) {
            if ("selected" === buttonStatus[key]) {
                arrSelectedLesson.push(key);
            }
        }

        let store = cmp.get("v.storeSelectedWords");
        
        let selectedWords = [];
        selectedWords = helper.fillSelectedWordsFromStore(selectedWords, arrSelectedLesson, store);
        cmp.set("v.selectedWords", selectedWords);
    },

    handleClickToTheTop : function() {
        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    },

    handleClickShowOrHideLesson : function(cmp, event) {
        let action = event.getParam('action');
        let wordsBoard = cmp.find('wordsBoard');
        let subjectButtons = cmp.find('subjectButtons');
        
        if ('show' === action) {
            $A.util.addClass(wordsBoard, 'slds-hide');
            $A.util.removeClass(subjectButtons, 'slds-hide');
        }
        else {
            $A.util.addClass(subjectButtons, 'slds-hide');
            $A.util.removeClass(wordsBoard, 'slds-hide');
        }

        //alert(action);
    }
})