({
    afterRender: function (cmp, helper) {
        this.superAfterRender();

        let tumbler = false;
        
        //let progress = cmp.find('progress');

        window.onscroll = function () {
            // let scrollTop = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
            // console.log('1 ' + document.documentElement.scrollTop);
            // console.log('2 ' + window['scrollY']);

            if (!tumbler && pageYOffset > 142) {
                // console.log('show')
                tumbler = true;
                helper.toggleStickyProgress(cmp, tumbler);
                helper.showOrHideButton(cmp, tumbler);
            }
            else if (tumbler && pageYOffset < 142) {
                // console.log('hide')
                tumbler = false;
                helper.toggleStickyProgress(cmp, tumbler);
                helper.showOrHideButton(cmp, tumbler);
            }
        };

    },

    // unrender: function (component, helper) {

    //     this.superUnrender();

    //     var scrollCheckIntervalId = component.get('v.scrollCheckIntervalId');

    //     if (!$A.util.isUndefinedOrNull(scrollCheckIntervalId)) {
    //         window.clearInterval(scrollCheckIntervalId);
    //     }

    // }
})