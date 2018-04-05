//console.log(JSON.parse(JSON.stringify(progress)))
({
    onchangeRecalculationOverall: function (cmp, event) {
        let progress = cmp.get('v.progress');
        progress.overall = 0;
        
        let storeSelectedWords = cmp.get('v.storeSelectedWords');
        let buttonStatus = cmp.get('v.buttonStatus');
        
        for (let key in buttonStatus) {
            if ('selected' === buttonStatus[key]) {
                progress.overall = progress.overall + storeSelectedWords[key].length;
            }
        }
        
        progress.percent = (progress.left / progress.overall) * 100 << 0;

        cmp.set('v.progress', progress);
    },
    
    onchangeRecalculationLeft : function(cmp, event) {
        let progress = cmp.get('v.progress');
        progress.left = 0;
        
        let selectedWords = cmp.get('v.selectedWords');
        progress.left = selectedWords.length;
        
        progress.percent = (progress.left / progress.overall) * 100 << 0;

        cmp.set('v.progress', progress);
    }
})