({
    /* @description: filters the full rollup data to find which rollups use a particular filter group
    * @param filterGroupLabel: label of the selected filter group
    * @param labels: labels for the rollups UI
    */
    filterRollupList: function(cmp, filterGroupLabel, labels){
        //filters row data based selected filter group
        var rollupList = cmp.get("v.rollupList");
        var filteredRollupList = rollupList.filter(function(rollup){
            return rollup.filterGroupName === filterGroupLabel;
        });

        //todo: should summary obj be dynamic?
        var rollupsBySummaryObj = [{label: labels.labelAccount, list: []}
                                , {label: labels.labelContact, list: []}
                                , {label: labels.labelGAU, list: []}];
        var itemList = [];

        //filter rollup list by type
        filteredRollupList.forEach(function (rollup){
            var item = {label: rollup.rollupName, name: rollup.id};
            if(rollup.summaryObject === labels.labelAccount){
                rollupsBySummaryObj[0].list.push(item);
            } else if (rollup.summaryObject === labels.labelContact){
                rollupsBySummaryObj[1].list.push(item);
            } else if (rollup.summaryObject === labels.labelGAU){
                rollupsBySummaryObj[2].list.push(item);
            }
        });

        //only add object to list if there are rollups with matching summary objects
        rollupsBySummaryObj.forEach(function(objList){
           if(objList.list.length > 1){
               var obj = {label: objList.label
                         , name: "title"
                         , expanded: false
                         , items: objList.list
               };
               itemList.push(obj);

           }
        });

        cmp.set("v.rollupItems", itemList);
    },
})