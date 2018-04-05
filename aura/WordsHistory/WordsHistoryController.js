({
    /* Get and set word('v.wordForHistory') onchange to 'v.listOfWords' */
    addWordToList : function(cmp, event, helper) {
        let wordsStat = cmp.get("v.wordsStat");
        let arrWords = cmp.get("v.listOfWords");
        let word = event.getParam("value");
        
        arrWords.unshift(word);
        cmp.set("v.listOfWords", arrWords);

        /* Add stats to array */
        wordsStat.overall = arrWords.length;

        if ('skipped' === word.checkStatus) {
            wordsStat.skipped++;
        }
        else if ('success' === word.checkStatus) {
            wordsStat.success++;
        }
        else if ('error' === word.checkStatus) {
            wordsStat.error++;
        }
        
        cmp.set('v.wordsStat', wordsStat);

        //console.log( JSON.parse(JSON.stringify(cmp.get('v.wordsStat'))) );
        
    }
})