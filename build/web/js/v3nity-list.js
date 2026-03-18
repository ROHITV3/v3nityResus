/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

var ListForm = function(filter_id) 
{
    var _this = {
        saveError: 'error saving data',
        save: function()
        {
            return true;
        },
        reset: function()
        {

        },
        populate: function(result)
        {
            return result;
        },
        filter: function()
        {
            var filters = $('#' + filter_id).find('.filter');

            var filterList = [];

            filters.each(function(key, value)
            {
                var filter = $(value);

                var name = filter.attr('name');

                var field = filter.attr('data-field');

                var mandatory = filter.attr('data-mandatory');
                
                if (field === 'text')
                {
                    var text = filter.find('input').val();

                    if (text.length > 0)
                    {
                        var type = filter.attr('data-type');

                        switch (type)
                        {
                            case 'String':
                                filterList.push({field: name, type: type, mandatory: mandatory, operator: 'LIKE', value: text + '%'});
                                break;

                            case 'HTML':
                                filterList.push({field: name, type: type, mandatory: mandatory, operator: 'LIKE', value: '%' + text + '%'});
                                break;

                            default:
                                filterList.push({field: name, type: type, mandatory: mandatory, operator: '=', value: text});
                                break;
                        }
                    }
                }
                else if (field === 'textarea')
                {
                    var text = filter.find('textarea').val();

                    if (text.length > 0)
                    {
                        filterList.push({field: name, type: type, mandatory: mandatory, operator: 'LIKE', value: text + '%'});
                    }
                }
                else if (field === 'checkbox')
                {
                    var checked = filter.find('input')[0].checked;

                    if (checked)
                    {
                        filterList.push({field: name, type: 'Boolean', mandatory: mandatory, operator: '=', value: true});
                    }
                }
                else if (field === 'treeview')
                {
                    var checkboxes = filter.find('input:checked');

                    var checkedValues = [];

                    for (var i = 0; i < checkboxes.length; i++)
                    {
                        var checkbox = $(checkboxes[i]).parent().parent();  // goes up to the li tag...

                        var checkedValue = checkbox.attr('data-value');

                        if (checkedValue !== undefined)
                        {
                            checkedValues.push(checkedValue);
                        }
                    }

                    if (checkedValues.length > 0)
                    {
                        filterList.push({field: name, type: 'Integer', operator: 'IN', value: checkedValues});
                    }
                }
                else if (field === 'custom-treeview')
                {
                    if (filter.attr('data-default-filterer') === 'true')
                    {
                        var identifier = filter.attr('data-identifier');    // indicates the tree view identifier...

                        var metafield = filter.attr('data-metafield');      // indicates the column name that needs to be filtered...

                        var ids = getTreeId('tree-view-' + identifier, identifier + '-id');

                        filterList.push({field: metafield, type: 'Integer', mandatory: mandatory, operator: 'IN', value: ids.split(',')});
                    }
                }
                else if (field === 'date-range')
                {
                    var dateInputs = filter.find('input');

                    var startDate = dateInputs[0].value;

                    var endDate = dateInputs[1].value;
                    
                    var datelimit = filter.attr('data-date-limit');

                    filterList.push({field: name, type: 'DateRange', mandatory: mandatory, value1: startDate, value2: endDate, datelimit: datelimit});
                }
                else if (field === 'date-single')
                {
                    var dateInputs = filter.find('input');

                    var startDate = dateInputs[0].value + ' 00:00:00';

                    var endDate = dateInputs[0].value + ' 23:59:59';

                    filterList.push({field: name, type: 'DateRange', mandatory: mandatory, value1: startDate, value2: endDate, datelimit: datelimit});
                }
                else if (field === 'selection')
                {
                    var id = filter.find('option:selected').val();

                    if (id !== '')
                    {
                        filterList.push({field: name, type: 'Integer', mandatory: mandatory, operator: '=', value: parseInt(id)});
                    }
                }
                else if (field === 'selection-text')
                {
                    var id = filter.find('option:selected').val();

                    if (id !== '')
                    {
                        filterList.push({field: name, type: 'String', mandatory: mandatory, operator: '=', value: id});
                    }
                }

            });

            _this.onfilter(filterList);

            return filterList;
        },
        onfilter: function(filterList)
        {
            return filterList;
        },
        getColumns: function()
        {
            return '';
        }
    };

    return _this;
};


/*
 * provide search function for the list field...
 *
 * created by kevin
 */
var ListDataSearchBox = function(parent, div, speed, className, packageName, displayColumn, callback)
{
    var _this = {
        callback: callback,
        className: className,
        packageName: packageName,
        displayColumn: displayColumn,
        timer: null,
        searchText: null,
        list: null,
        enable: function()
        {
            var parent = $('#' + div);

            parent.addClass('search-box');

            var input = parent.children('input')[0];

            input = $(input);

            input.keyup(_this.inputCallback);

            _this.list = $('<ul/>', {
                class: 'search-result-box'
            });

            _this.list.insertAfter(input);
        },
        clear: function()
        {
            _this.list.empty();
        },
        inputCallback: function()
        {
            if (_this.timer !== null)
            {
                clearTimeout(_this.timer);

                _this.timer = null;
            }

            _this.searchText = this.value;

            if (_this.searchText.length > 3)
            {
                _this.timer = setTimeout(_this.timerCallback, speed);
            }
        },
        timerCallback: function()
        {
            _this.list.empty();

            $.ajax({
                type: 'GET',
                url: 'ListController?action=searchable',
                data: {
                    lib: _this.packageName,
                    type: _this.className,
                    displayColumn: _this.displayColumn,
                    search: _this.searchText
                },
                success: function(data)
                {
                    if (data.result)
                    {
                        for (i = 0; i < data.records.length; i++)
                        {
                            var record = data.records[i];

                            var item = $('<li/>');

                            // must use mousedown instead of click otherwise the list will lost focus...
                            var content = $('<a/>', {
                                'data-id': record.id
                            }).on('mousedown', function()
                            {
                                var elem = $(this);

                                var parent = elem.parents('div');

                                var input = parent.children('input')[0];

                                input.value = elem.attr('data-value');

                                _this.callback(input.value, elem.attr('data-id'));
                            });

                            /*
                             * the display text of each item in the dropdown list...
                             */
                            content.html(record.text);

                            /*
                             * the actual display text of the search field...
                             */
                            content.attr('data-value', record.value);

                            item.append(content);

                            _this.list.prepend(item);
                        }
                    }
                },
                complete: function()
                {

                },
                error: function()
                {

                },
                async: true
            });

        }
    };

    /*
     * added to the main parent dom for purpose such as clearform...
     */
    if (parent.listFields !== undefined)
    {
        parent.listFields.push(_this);
    }

    return _this;
};

var AlertListForm = function(filter_id)
{
    var _this = {
        save: function()
        {
            var groupTreeView = document.getElementById('groupAssetId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-asset', 'asset-id');
            }

            groupTreeView = document.getElementById('groupEventId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-event', 'event-id');
            }

            groupTreeView = document.getElementById('groupUserId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-user', 'user-id');
            }

            groupTreeView = document.getElementById('groupCriteriaId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-criteria', 'criteria-id');
            }

            return true;
        },
        onfilter: function(filterList)
        {
            var ids = getTreeId('tree-view-filter-user', 'filter-user-id');

            if (ids !== '')
            {
                filterList.push({field: 'user_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});

            ids = getTreeId('tree-view-filter-criteria', 'filter-criteria-id');

            if (ids !== '')
            {
                filterList.push({field: 'alert_criteria_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-event', 'filter-event-id');

            if (ids !== '')
            {
                var events = ids.split(',');

                var eventList = {};

                var total = 0;

                for (i = 0; i < events.length; i++)
                {
                    if (events[i].indexOf('_') > -1)
                    {
                        var event = events[i].split('_');

                        if (eventList[event[0]] === undefined)
                        {
                            eventList[event[0]] = [];
                            total++;
                        }

                        eventList[event[0]].push(event[1]);
                    }
                    else
                    {
                        if (eventList[events[i]] === undefined)
                        {
                            eventList[events[i]] = [];
                            total++;
                        }
                    }
                }

                var operator = 'AND';
                var count = 0;

                for (var eventId in eventList)
                {

                    if (eventList[eventId].length > 0)
                    {
                        if (count === 0)
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 0});
                        }

                        if (count === total - 1)
                        {
                            filterList.push({field: 'reference_id', type: 'Integer', operator: 'IN', value: eventList[eventId], endQuery: true, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'reference_id', type: 'Integer', operator: 'IN', value: eventList[eventId], endQuery: true, queryDepth: 0});
                        }

                    }
                    else
                    {

                        if (count === 0)
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 0});
                        }

                        if (count === total - 1)
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), endQuery: true, logicalOperator: operator, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), endQuery: true, logicalOperator: operator, queryDepth: 0});
                        }
                    }

                    operator = 'OR';

                    count++;
                }
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var GeoFenceAssignmentListForm = function(filter_id)
{
    var _this = {
        save: function()
        {
            var groupAsset = document.getElementById('groupAssetId');

            if (groupAsset !== null)
            {
                groupAsset.value = getTreeId('tree-view-asset', 'asset-id');
            }

            var groupGeoFence = document.getElementById('groupGeoFenceId');

            if (groupGeoFence !== null)
            {
                groupGeoFence.value = getTreeId('tree-view-geofence', 'geofence-id');
            }

            var groupCriteria = document.getElementById('groupCriteriaId');

            if (groupCriteria !== null)
            {
                groupCriteria.value = getTreeId('tree-view-criteria', 'criteria-id');
            }

            return true;
        },
        onfilter: function(filterList)
        {
            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-geofence', 'filter-geofence-id');

            if (ids !== '')
            {
                filterList.push({field: 'geo_fence_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-criteria', 'filter-criteria-id');

            if (ids !== '')
            {
                filterList.push({field: 'geo_fence_criteria_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var RouteAssignmentListForm = function(filter_id)
{

    var _this = {
        save: function()
        {
            var groupAsset = document.getElementById('groupAssetId');

            if (groupAsset !== null)
            {
                groupAsset.value = getTreeId('tree-view-asset', 'asset-id');
            }

            var groupRoute = document.getElementById('groupRouteId');

            if (groupRoute !== null)
            {
                groupRoute.value = getTreeId('tree-view-route', 'route-id');
            }

            var groupCriteria = document.getElementById('groupCriteriaId');

            if (groupCriteria !== null)
            {
                groupCriteria.value = getTreeId('tree-view-criteria', 'criteria-id');
            }

            return true;
        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-route', 'filter-route-id');

            if (ids !== '')
            {
                filterList.push({field: 'route_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-criteria', 'filter-criteria-id');

            if (ids !== '')
            {
                filterList.push({field: 'route_criteria_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var GroupListForm = function(filter_id)
{

    var _this = {
        getOptions: function(optionsDataById, idValueById)
        {
            var optionsData = document.getElementById(optionsDataById);

            var idValue = document.getElementById(idValueById);

            if (optionsData !== null)
            {
                var tempOptions = optionsData.options;

                idValue.value = '';

                for (var i = 0; i < tempOptions.length; i++)
                {
                    if (i > 0)
                    {
                        idValue.value += ',';
                    }

                    idValue.value += tempOptions[i].value;
                }
            }
        },
        compareOptionText: function(a, b)
        {
            /*
             * return >0 if a>b
             *         0 if a=b
             *        <0 if a<b
             */
            // textual comparison
            return a.text !== b.text ? a.text < b.text ? -1 : 1 : 0;
            // numerical comparison
            //  return a.text - b.text;
        },
        sortOptions: function(list)
        {
            var items = list.options.length;

            // create array and make copies of options in list
            var tmpArray = new Array(items);

            for (i = 0; i < items; i++)
            {
                tmpArray[i] = new Option(list.options[i].text, list.options[i].value);
            }

            // sort options using given function
            tmpArray.sort(_this.compareOptionText);

            // make copies of sorted options back to list
            for (i = 0; i < items; i++)
            {
                list.options[i] = new Option(tmpArray[i].text, tmpArray[i].value);
            }
        },
        toggleSelectedOptions: function(fromListById, toListById, all)
        {
            var fromList = document.getElementById(fromListById);

            var toList = document.getElementById(toListById);

            if (fromList === null || toList === null)
            {
                return;
            }

            var fromOptions = fromList.options;

            var toOptions = toList.options;

            for (var i = 0; i < fromOptions.length; i++)
            {
                if (fromOptions[i].selected || all)
                {
                    toOptions[toOptions.length] = new Option(fromOptions[i].text, fromOptions[i].value);
                    fromList.remove(i);
                    i--;
                }
            }

            _this.sortOptions(toList);
        },
        toggleOptions: function(fromListById, toListById, ids)
        {
            var toOptionsDom = document.getElementById(toListById);

            var fromOptions = $('#' + fromListById);

            if (toOptionsDom === undefined || fromOptions === undefined)
            {
                return;
            }

            toOptionsDom = toOptionsDom.options;

            $.each(ids, function(i, item)
            {
                var option = fromOptions.find("option[value='" + item + "']");

                if (option.length > 0)
                {
                    toOptionsDom[toOptionsDom.length] = new Option(option.text(), option.val());

                    option.remove();
                }
            });
        },
        selectAll: function(selectBox, selectAll)
        {
            for (var i = 0; i < selectBox.options.length; i++)
            {
                selectBox.options[i].selected = selectAll;
            }
        },
        save: function()
        {
            _this.getOptions('groupAsset', 'groupAssetId');

            _this.getOptions('groupDriver', 'groupDriverId');

            _this.getOptions('groupUser', 'groupUserId');

            return true;
        },
        reset: function()
        {
            _this.toggleSelectedOptions('groupAsset', 'asset', true);

            _this.toggleSelectedOptions('groupDriver', 'driver', true);

            _this.toggleSelectedOptions('groupUser', 'user', true);
        },
        populate: function(result)
        {

            _this.toggleOptions('asset', 'groupAsset', result.assets);

            _this.toggleOptions('driver', 'groupDriver', result.drivers);

            _this.toggleOptions('user', 'groupUser', result.users);
        }

    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var DateReminderSenderGroupListForm = function(filter_id)
{

    var _this = {
        getOptions: function(optionsDataById, idValueById)
        {
            var optionsData = document.getElementById(optionsDataById);

            var idValue = document.getElementById(idValueById);

            if (optionsData !== null)
            {
                var tempOptions = optionsData.options;

                idValue.value = '';

                for (var i = 0; i < tempOptions.length; i++)
                {
                    if (i > 0)
                    {
                        idValue.value += ',';
                    }

                    idValue.value += tempOptions[i].value;
                }
            }
        },
        compareOptionText: function(a, b)
        {
            /*
             * return >0 if a>b
             *         0 if a=b
             *        <0 if a<b
             */
            // textual comparison
            return a.text !== b.text ? a.text < b.text ? -1 : 1 : 0;
            // numerical comparison
            //  return a.text - b.text;
        },
        sortOptions: function(list)
        {
            var items = list.options.length;

            // create array and make copies of options in list
            var tmpArray = new Array(items);

            for (i = 0; i < items; i++)
            {
                tmpArray[i] = new Option(list.options[i].text, list.options[i].value);
            }

            // sort options using given function
            tmpArray.sort(_this.compareOptionText);

            // make copies of sorted options back to list
            for (i = 0; i < items; i++)
            {
                list.options[i] = new Option(tmpArray[i].text, tmpArray[i].value);
            }
        },
        toggleSelectedOptions: function(fromListById, toListById, all)
        {
            var fromList = document.getElementById(fromListById);

            var toList = document.getElementById(toListById);

            if (fromList === null || toList === null)
            {
                return;
            }

            var fromOptions = fromList.options;

            var toOptions = toList.options;

            for (var i = 0; i < fromOptions.length; i++)
            {
                if (fromOptions[i].selected || all)
                {
                    toOptions[toOptions.length] = new Option(fromOptions[i].text, fromOptions[i].value);
                    fromList.remove(i);
                    i--;
                }
            }

            _this.sortOptions(toList);
        },
        toggleOptions: function(fromListById, toListById, ids)
        {
            var toOptionsDom = document.getElementById(toListById);

            var fromOptions = $('#' + fromListById);

            if (toOptionsDom === undefined || fromOptions === undefined)
            {
                return;
            }

            toOptionsDom = toOptionsDom.options;

            $.each(ids, function(i, item)
            {
                var option = fromOptions.find("option[value='" + item + "']");

                if (option.length > 0)
                {
                    toOptionsDom[toOptionsDom.length] = new Option(option.text(), option.val());

                    option.remove();
                }
            });
        },
        selectAll: function(selectBox, selectAll)
        {
            for (var i = 0; i < selectBox.options.length; i++)
            {
                selectBox.options[i].selected = selectAll;
            }
        },
        save: function()
        {
            _this.getOptions('groupUser', 'groupUserId');

            return true;
        },
        reset: function()
        {
            _this.toggleSelectedOptions('groupUser', 'user', true);
        },
        populate: function(result)
        {
            _this.toggleOptions('user', 'groupUser', result.users);
        }

    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var HistoryListForm = function(filter_id)
{
    var _this = {
        onfilter: function(filterList)
        {
            ids = getTreeId('tree-view-filter-event', 'filter-event-id');

            if (ids !== '')
            {
                var events = ids.split(',');

                var eventList = {};

                var total = 0;

                for (i = 0; i < events.length; i++)
                {
                    if (events[i].indexOf('_') > -1)
                    {
                        var event = events[i].split('_');

                        if (eventList[event[0]] === undefined)
                        {
                            eventList[event[0]] = [];
                            total++;
                        }

                        eventList[event[0]].push(event[1]);
                    }
                    else
                    {
                        if (eventList[events[i]] === undefined)
                        {
                            eventList[events[i]] = [];
                            total++;
                        }
                    }
                }

                var operator = 'AND';
                var count = 0;

                for (var eventId in eventList)
                {
                    if (eventList[eventId].length > 0)
                    {
                        if (count === 0)
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 0});
                        }

                        if (count === total - 1)
                        {
                            filterList.push({field: 'reference_id', type: 'Integer', operator: 'IN', value: eventList[eventId], endQuery: true, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'reference_id', type: 'Integer', operator: 'IN', value: eventList[eventId], endQuery: true, queryDepth: 0});
                        }
                    }
                    else
                    {
                        if (count === 0)
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), startQuery: true, logicalOperator: operator, queryDepth: 0});
                        }

                        if (count === total - 1)
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), endQuery: true, logicalOperator: operator, queryDepth: 1});
                        }
                        else
                        {
                            filterList.push({field: 'event_id', type: 'Integer', operator: '=', value: Number(eventId), endQuery: true, logicalOperator: operator, queryDepth: 0});
                        }
                    }

                    operator = 'OR';

                    count++;
                }
            }

            ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            //if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            // add parameter for location type selection...
            filterList.push({field: 'road', type: 'Location', value: _this.getLocationType()});

            return filterList;
        },
        getColumns: function()
        {

            var ids = getTreeId('tree-view-filter-asset', 'asset-type-id');

            return ids;
        },
        getLocationType: function()
        {

            var types = document.getElementsByName('location-type');

            var type;

            for (var i = 0; i < types.length; i++)
            {
                if (types[i].checked)
                {
                    type = types[i].value;
                    break;
                }
            }

            return type;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var LocationListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        },
        getColumns: function()
        {

            var ids = getTreeId('tree-view-filter-asset', 'asset-type-id');

            return ids;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var LocationFmsListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        },
        getColumns: function()
        {

            var ids = getTreeId('tree-view-filter-asset', 'asset-type-id');

            return ids;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var PanUnitedLastLocationListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        },
        getColumns: function()
        {

            var ids = getTreeId('tree-view-filter-asset', 'asset-type-id');

            return ids;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var SettingListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var RoleListForm = function(filter_id)
{

    var _this = {
        save: function()
        {
            var accessId = document.getElementById('accessId');

            var inputs = document.getElementsByClassName('input-access');

            accessId.value = '';

            for (var i = 0; i < inputs.length; i++)
            {
                if (inputs[i].checked)
                {
                    if (accessId.value.length > 0)
                    {
                        accessId.value += ',';
                    }

                    accessId.value += inputs[i].id;
                }
            }

            return true;
        },
        reset: function()
        {

        },
        populate: function(result)
        {
            for (var i = 0; i < result.access.length; i++)
            {
                var inputId = result.access[i].resource_id + '-' + result.access[i].operation_id;

                var input = document.getElementById(inputId);

                input.checked = true;
            }
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var JobFormTemplateListForm = function(filter_id, form)
{

    var _this = {
        save: function()
        {

            document.getElementById('formTemplateData').value = form.getHtml();

            return true;
        },
        reset: function()
        {

            form.clear();
        },
        populate: function(result)
        {

            // array index 3 must be the html value...
            var html = result.data[3].value;

            form.setHtml(html);

        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var JobScheduleListForm = function(filter_id, form)
{
    var _this = {
        save: function()
        {
            if (form.count() === 0)
            {
                _this.saveError = 'You must select a form template';

                return false;
            }
            else
            {
                form.mobilize();

                document.getElementById('formTemplatePreview').value = form.getPreview();

                document.getElementById('formTemplateDetails').value = form.getHtml();

                var selectTemplateName = document.getElementById('inputFormTemplateNameId');

                if (selectTemplateName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('formTemplateName').value = selectTemplateName.options[ selectTemplateName.selectedIndex ].text;
                }

                var selectReportTemplateName = document.getElementById('inputReportTemplateNameId');

                if (selectReportTemplateName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('reportTemplateName').value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].text;
                    document.getElementById('reportTemplateData').value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].value;
                }
                
                var selectDocFileName = document.getElementById('inputDocFileId');

                if (selectDocFileName)
                {
                    if (selectDocFileName.selectedIndex === 0)
                    {

                    }
                    else
                    {
                        document.getElementById('docFileName').value = selectDocFileName.options[selectDocFileName.selectedIndex].value;
                    }
                }
                

                return true;
            }
        },
        reset: function()
        {

            form.clear();
        },
        populate: function(result)
        {

            // array index 0 must be the html value. very stupid way of doing it.. must think of a smarter way in the future..
            var html = result.data[0].value;

            form.setHtml(html);

        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var JobImportTemplateListForm = function(filter_id)
{

    var _this = {
        save: function()
        {

            var fieldArray = [];

            // fields validation shall take place...
            var proceed = true;

            $('.import-field').each(function()
            {

                // basically 2 inputs... checkbox input and column index input...
                var inputs = $(this).find('input');

                var inputColumnIndex = inputs[0];

                var inputCheckbox = inputs[1];

                var label = $(inputCheckbox).parent('label');

                var labelArr = label.html().replace(/>/gi, ">!");

                var labelArr = labelArr.split("!");

                var columnId = inputCheckbox.value;

                var columnName = label;

                if (labelArr.length > 3)
                {
                    var columnName = labelArr[1] + labelArr[2] + labelArr[3] + labelArr[4];
                }
                else
                {
                    var columnName = labelArr[1];
                }

                var columnIndex = inputColumnIndex.value;   // by right this should be cast to integer but we will handle it in the java class...

                if (!_this.isNumber(columnIndex))
                {
                    _this.saveError = 'The column sequence "' + columnName + '" must be a number';

                    proceed = false;

                    return false;
                }

                var columnActive = inputCheckbox.checked;

                fieldArray.push({'column_id': columnId, 'column_name': columnName, 'column_index': columnIndex, 'column_active': columnActive});
            });

            if (proceed)
            {
                var reportName = document.getElementById('reportName');

                var templateName = document.getElementById('templateName');

                var selectFormTemplateId = document.getElementById('inputFormTemplateNameId');

                var selectReportTemplateName = document.getElementById('inputReportTemplateNameId');

                reportName.value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].text;

                templateName.value = selectFormTemplateId.options[ selectFormTemplateId.selectedIndex ].text;

                var importFields = {'data': fieldArray};

                document.getElementById('jobImportField').value = JSON.stringify(importFields);
            }

            return proceed;
        },
        reset: function()
        {

            clearFields();
        },
        populate: function(result)
        {

            var total = result.import_fields.length;

            for (var i = 0; i < total; i++)
            {
                var field = result.import_fields[i];

                if (field.column_id.startsWith('sys'))
                {
                    addField('import-system-fields', field.column_id, field.column_name, field.column_index, field.column_active);
                }
                else
                {
                    addField('import-user-fields', field.column_id, field.column_name, field.column_index, field.column_active);
                }
            }
        },
        isNumber: function(value)
        {
            if ((parseFloat(value) === parseInt(value)) && !isNaN(value))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var JobReportTemplateListForm = function(filter_id)
{

    var _this = {
        save: function()
        {

            var reportTempData = document.getElementById('reportTemplateData');

            var tableView = $('#tableView');

            // remove selected cell...
            tableView.find('.selected').removeClass('selected');

            var reportHtml = tableView.html();

            reportTempData.value = reportHtml;

            return true;
        },
        reset: function()
        {

        },
        populate: function(result)
        {

            // select the option of the report template...
            $('select[name=template_id]').val(result.data[2].value);

            // gets the template fields populated...
            getTemplate();

            var tableView = document.getElementById('tableView');

            var html = result.data[5].value;

            tableView.innerHTML = html;

            bindSelected();

        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var JobResourceProfileListForm = function(filter_id)
{

    var _this = {
        save: function()
        {

            var profileAttribute = document.getElementById('ProfileAttribute');

            var selectProfileAttributeId = document.getElementById('inputProfileAttributeId');

            profileAttribute.value = selectProfileAttributeId.options[ selectProfileAttributeId.selectedIndex ].value;

            return true;
        },
        reset: function()
        {

            clearFields();
        },
        populate: function(result)
        {

        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};
var BargeBunkerGrade = function(filter_id)
{

    var _this = {
        save: function()
        {

            var bunkerGrade = document.getElementById('ProfileAttribute');

            var selectProfileAttributeId = document.getElementById('inputProfileAttributeId');

            profileAttribute.value = selectProfileAttributeId.options[ selectProfileAttributeId.selectedIndex ].value;

            return true;
        },
        reset: function()
        {

            clearFields();
        },
        populate: function(result)
        {

        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};
var DTCHistoryListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            //if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var ProfileListForm = function(filter_id, form)
{
    var _this = {
        save: function()
        {
            var selectFormTemplate = document.getElementById('inputFormTemplateNameId');

            if (selectFormTemplate.selectedIndex === 0)
            {
                document.getElementById('formTemplateName').value = document.getElementById('profile-title').innerHTML;
            }
            else
            {
                document.getElementById('formTemplateName').value = selectFormTemplate.options[ selectFormTemplate.selectedIndex ].text;
            }

            document.getElementById('formTemplateData').value = form.getHtml();

            return true;
        },
        reset: function()
        {
            form.clear();
        },
        populate: function(result)
        {
            var indexTitle = result.indexes['profile_title'];

            var indexData = result.indexes['profile_data'];

            document.getElementById('profile-title').innerHTML = result.data[indexTitle].value;

            var html = result.data[indexData].value;

            form.setHtml(html);
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var AutoReportGeneratorListForm = function(filter_id)
{

    var _this = {
        save: function()
        {
            var groupTreeView = document.getElementById('groupAssetId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-asset', 'asset-id');
            }

            groupTreeView = document.getElementById('groupUserId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-user', 'user-id');
            }

            groupTreeView = document.getElementById('groupEventId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-event', 'event-id');
            }

            return true;
        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-user', 'filter-user-id');

            filterList.push({field: 'user_id', type: 'Integer', operator: 'IN', value: ids.split(',')});

            ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-event', 'filter-event-id');

            if (ids !== '')
            {
                var events = ids.split(',');

                var referenceId = [];

                var eventId = [];

                for (i = 0; i < events.length; i++)
                {
                    if (events[i].indexOf('_') > -1)
                    {
                        var event = events[i].split('_');

                        eventId.push(event[0]);

                        referenceId.push(event[1]);
                    }
                    else
                    {
                        eventId.push(events[i]);
                    }
                }

                var startQuery = (eventId.length > 0 && referenceId.length > 0);

                if (eventId.length > 0)
                {
                    eventId = removeArrayDuplicates(eventId);
                    filterList.push({field: 'event_id', type: 'Integer', operator: 'IN', value: eventId, startQuery: startQuery});
                }

                if (referenceId.length > 0)
                {
                    referenceId = removeArrayDuplicates(referenceId);
                    filterList.push({field: 'reference_id', type: 'Integer', operator: 'IN', value: referenceId, logicalOperator: 'OR', endQuery: startQuery});

                }
            }
            ids = getDropDownValue('report_type');

            if (ids !== '' && ids > 0)
            {
                filterList.push({field: 'report_type_id', type: 'Integer', operator: '=', value: parseInt(ids)});
            }

            ids = getDropDownValue('period_type');

            if (ids !== '' && ids > 0)
            {
                filterList.push({field: 'period_type_id', type: 'Integer', operator: '=', value: parseInt(ids)});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var TTCMovementReportListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            //if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var TTCWorkDoneReportListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            //if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var TTCDailyReportListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            //if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }
            ids = getGroupId('tree-view-filter-asset', 'filter-asset');

            filterList.push({field: 'group_id', type: 'Integer', operator: 'IN', value: ids.split(',')});

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};



var CubeReportListForm = function(filter_id)
{

    var _this = {
        save: function()
        {

        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }


            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);
    return _this;
};


var UserAccessListForm = function(filter_id)
{

    var _this = {
        save: function()
        {
            var groupTreeView = document.getElementById('groupUserId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-user', 'user-id');
            }

            var groupTreeView = document.getElementById('groupOperationId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-operation', 'operation-id');
            }

            return true;
        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-user', 'filter-user-id');

            if (ids !== '')
            {
                filterList.push({field: 'user_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};



var ClusterLocationTableListForm = function(filter_id)
{

    var _this = {
        save: function()
        {
            var groupTreeView = document.getElementById('groupClusterLocationId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-clusterLocation', 'clusterlocation-id');
            }

            return true;
        },
        onfilter: function(filterList)
        {



            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};


var UserLogListForm = function(filter_id)
{

    var _this = {
        save: function()
        {

        },
        onfilter: function(filterList)
        {
            var ids = getTreeId('tree-view-filter-customer', 'filter-customer-id');

            if (ids !== '')
            {
                filterList.push({field: 'customer_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }


            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var VehicleMaintenanceListForm = function(filter_id)
{

    var _this = {
        save: function()
        {
            var groupTreeView = document.getElementById('groupUserId');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeId('tree-view-user', 'user-id');
            }

            groupTreeView = document.getElementById('groupUserValue');

            if (groupTreeView !== null)
            {
                groupTreeView.value = getTreeLabel('tree-view-user', 'user-id');
            }


            return true;
        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-user', 'filter-user-id');

            if (ids !== '')
            {
                filterList.push({field: 'user_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};
var DeviceLocationListForm = function(filter_id)
{

    var _this = {
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        },
        getColumns: function()
        {

            var ids = getTreeId('tree-view-filter-asset', 'asset-type-id');

            return ids;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};


var TFSRatingFeedbackListForm = function(filter_id)
{
    var _this = {
        onfilter: function(filterList)
        {

            ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        },
        getColumns: function()
        {

            var ids = getTreeId('tree-view-filter-asset', 'asset-type-id');

            return ids;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};


var JobTemplateAllowAdHocListForm = function(filter_id)
{

    var _this = {
        getOptions: function(optionsDataById, idValueById)
        {
            var optionsData = document.getElementById(optionsDataById);

            var idValue = document.getElementById(idValueById);

            if (optionsData !== null)
            {
                var tempOptions = optionsData.options;

                idValue.value = '';

                for (var i = 0; i < tempOptions.length; i++)
                {
                    if (i > 0)
                    {
                        idValue.value += ',';
                    }

                    idValue.value += tempOptions[i].value;
                }
            }
        },
        compareOptionText: function(a, b)
        {
            /*
             * return >0 if a>b
             *         0 if a=b
             *        <0 if a<b
             */
            // textual comparison
            return a.text !== b.text ? a.text < b.text ? -1 : 1 : 0;
            // numerical comparison
            //  return a.text - b.text;
        },
        sortOptions: function(list)
        {
            var items = list.options.length;

            // create array and make copies of options in list
            var tmpArray = new Array(items);

            for (i = 0; i < items; i++)
            {
                tmpArray[i] = new Option(list.options[i].text, list.options[i].value);
            }

            // sort options using given function
            tmpArray.sort(_this.compareOptionText);

            // make copies of sorted options back to list
            for (i = 0; i < items; i++)
            {
                list.options[i] = new Option(tmpArray[i].text, tmpArray[i].value);
            }
        },
        toggleSelectedOptions: function(fromListById, toListById, all)
        {
            var fromList = document.getElementById(fromListById);

            var toList = document.getElementById(toListById);

            if (fromList === null || toList === null)
            {
                return;
            }

            var fromOptions = fromList.options;

            var toOptions = toList.options;

            for (var i = 0; i < fromOptions.length; i++)
            {
                if (fromOptions[i].selected || all)
                {
                    toOptions[toOptions.length] = new Option(fromOptions[i].text, fromOptions[i].value);
                    fromList.remove(i);
                    i--;
                }
            }

            _this.sortOptions(toList);
        },
        toggleOptions: function(fromListById, toListById, ids)
        {
            var toOptionsDom = document.getElementById(toListById);

            var fromOptions = $('#' + fromListById);

            if (toOptionsDom === undefined || fromOptions === undefined)
            {
                return;
            }

            toOptionsDom = toOptionsDom.options;

            $.each(ids, function(i, item)
            {
                var option = fromOptions.find("option[value='" + item + "']");

                if (option.length > 0)
                {
                    toOptionsDom[toOptionsDom.length] = new Option(option.text(), option.val());

                    option.remove();
                }
            });
        },
        selectAll: function(selectBox, selectAll)
        {
            for (var i = 0; i < selectBox.options.length; i++)
            {
                selectBox.options[i].selected = selectAll;
            }
        },
        save: function()
        {
            _this.getOptions('allowDriver', 'allowDriverId');

            return true;
        },
        reset: function()
        {
            _this.toggleSelectedOptions('allowDriver', 'driver', true);
        },
        populate: function(result)
        {
            _this.toggleOptions('driver', 'allowDriver', result.drivers);
        }

    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var RamkyFeedbackListForm = function(filter_id, form)
{
    var _this = {
        save: function()
        {
            if (form.count() === 0)
            {
                _this.saveError = 'You must select a form template';

                return false;
            }
            else
            {
                form.mobilize();

                document.getElementById('formTemplatePreview').value = form.getPreview();

                document.getElementById('formTemplateDetails').value = form.getHtml();

                var selectTemplateName = document.getElementById('inputFormTemplateNameId');

                if (selectTemplateName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('formTemplateName').value = selectTemplateName.options[ selectTemplateName.selectedIndex ].text;
                }

                var selectReportTemplateName = document.getElementById('inputReportTemplateNameId');

                if (selectReportTemplateName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('reportTemplateName').value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].text;
                    document.getElementById('reportTemplateData').value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].value;
                }
                
                var selectRoadName = document.getElementById('inputRoadNameId');

                if (selectRoadName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('roadId').value = selectRoadName.options[ selectRoadName.selectedIndex ].value;
                    document.getElementById('locationId').value = selectRoadName.options[ selectRoadName.selectedIndex ].text;
                }
                
                var selectDocFileName = document.getElementById('inputDocFileId');

                if (selectDocFileName)
                {
                    if (selectDocFileName.selectedIndex === 0)
                    {

                    }
                    else
                    {
                        document.getElementById('docFileName').value = selectDocFileName.options[selectDocFileName.selectedIndex].value;
                    }
                }
                

                return true;
            }
        },
        reset: function()
        {

            form.clear();
        },
        populate: function(result)
        {

            // array index 0 must be the html value. very stupid way of doing it.. must think of a smarter way in the future..
            var html = result.data[0].value;

            form.setHtml(html);

        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var RamkyVehicleChecklistListForm = function(filter_id, form)
{
    var _this = {
        save: function()
        {
            if (form.count() === 0)
            {
                _this.saveError = 'You must select a form template';

                return false;
            }
            else
            {
                form.mobilize();

                document.getElementById('formTemplatePreview').value = form.getPreview();

                document.getElementById('formTemplateDetails').value = form.getHtml();

                var selectTemplateName = document.getElementById('inputFormTemplateNameId');

                if (selectTemplateName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('formTemplateName').value = selectTemplateName.options[ selectTemplateName.selectedIndex ].text;
                }

                var selectReportTemplateName = document.getElementById('inputReportTemplateNameId');

                if (selectReportTemplateName.selectedIndex === 0)
                {

                }
                else
                {
                    document.getElementById('reportTemplateName').value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].text;
                    document.getElementById('reportTemplateData').value = selectReportTemplateName.options[ selectReportTemplateName.selectedIndex ].value;
                }
                
                var selectDocFileName = document.getElementById('inputDocFileId');

                if (selectDocFileName)
                {
                    if (selectDocFileName.selectedIndex === 0)
                    {

                    }
                    else
                    {
                        document.getElementById('docFileName').value = selectDocFileName.options[selectDocFileName.selectedIndex].value;
                    }
                }
                

                return true;
            }
        },
        reset: function()
        {

            form.clear();
        },
        populate: function(result)
        {

            // array index 0 must be the html value. very stupid way of doing it.. must think of a smarter way in the future..
            var html = result.data[0].value;

            form.setHtml(html);

        },
        onfilter: function(filterList)
        {

            var ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');

            if (ids !== '')
            {
                filterList.push({field: 'driver_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }
            
            ids = getTreeId('tree-view-filter-asset', 'filter-asset-value');

            if (ids !== '')
            {
                filterList.push({field: 'asset', type: 'String', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};



var HistoryDbTrackerListForm = function(filter_id)
{
    var _this = {
        onfilter: function(filterList)
        {
            ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');
            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};

var CementListForm = function(filter_id)
{
    var _this = {
        onfilter: function(filterList)
        {
            ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');
            if (ids !== '')
            {
                filterList.push({field: 'asset_id', type: 'Integer', operator: 'IN', value: ids.split(',')});
            }

            return filterList;
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};
