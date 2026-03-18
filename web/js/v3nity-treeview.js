/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

function searchTree(searchId, treeId) {
    var searchText = $('#' + searchId).val();

    var tree = $('#' + treeId);

    // new selector for case-insensitive jquery.contains ...
    jQuery.expr[':'].matchAsset = function(a, i, m) {
        return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
    };

    if (searchText !== '') {
        // revert all colors to normal...
        tree.find('span.leaf').css({"background-color": "inherit", "color": "inherit"});

        // find matching assets...
        var result = tree.find('span.leaf:matchAsset("' + searchText + '")');

        // indicates the results found...
        //document.getElementById('matches-asset').innerHTML = result.length + ' found';

        for (i = 0; i < result.length; i++) {

            var item = result[i];

            var parents = $(result[i]).parents('li');

            // open up the treeview items...
            parents.removeClass('collapsed');

            $(result[i]).parents('li').children('ul').css({"display": "block"});
            // open up the treeview items...
            parents.children('ul').slideDown('fast');

            //asset.style.backgroundColor = '#FBFF98';

            item.style.color = '#FF0000';

            if (i === 0) {
                item.scrollIntoView();
            }
        }
    }
}

function getTreeId(treeId, identifier) {
    var tree = $('#' + treeId);

    var children_checked = tree.children('ul').find('input[type="checkbox"]:checked, input[type="radio"]:checked');

    var children = $(children_checked).parents('li:not(.node)');

    var idValue = '';

    var first = false;

    var list = {}; // use to eliminate duplicate ids...

    for (i = 0; i < children.length; i++) {

        var child = $(children[i]);

        var value = child.data(identifier);

        if (value !== undefined) {
            if (list[value] === undefined) {
                if (first) {
                    idValue += ',';
                }

                list[value] = 0;

                idValue += value;

                first = true;
            }
        }
    }

    return idValue;
}

function getTreeLabel(treeId, identifier) {
    var tree = $('#' + treeId);

    var children_checked = tree.children('ul').find('input[type="checkbox"]:checked, input[type="radio"]:checked');

    var children = $(children_checked).parents('li:not(.node)');

    var idValue = '';

    var first = false;

    var list = {}; // use to eliminate duplicate ids...

    for (i = 0; i < children.length; i++) {

        var child = $(children[i]).children().eq(1);

        var value = child.html();

        if (value !== undefined) {
            if (list[value] === undefined) {
                if (first) {
                    idValue += ',';
                }

                list[value] = 0;

                idValue += value;

                first = true;
            }
        }
    }
    return idValue;
}

function getDropDownValue(dropdownId) { // to pull filter value for dropdown, 1 value. 
    var dropdown = $('#' + dropdownId)
    
    var idValue = 0;
   
    idValue = dropdown.val();

    return idValue;
}

function getAllTreeId(treeId, identifier) { // unchecked
    var tree = $('#' + treeId);

    var children_checked = tree.children('ul').find('input[type="checkbox"], input[type="radio"]');

    var children = $(children_checked).parents('li:not(.node)');

    var idValue = '';

    var first = false;

    var list = {}; // use to eliminate duplicate ids...

    for (i = 0; i < children.length; i++) {

        var child = $(children[i]);

        var value = child.data(identifier);

        if (value !== undefined) {
            if (list[value] === undefined) {
                if (first) {
                    idValue += ',';
                }

                list[value] = 0;

                idValue += value;

                first = true;
            }
        }
    }
    
    return idValue;
}


function getGroupId(treeId, identifier) // getGroupId('tree-view-filter-asset', 'filter-asset'); use for TTC project to get Group Id. Should be able to scale for other treeview
{
    var tree = $('#' + treeId);

    var children_checked = tree.children('ul').find('input[type="checkbox"][name="' + identifier + '"]:checked');
    
    var children = $(children_checked).parents('li');
    
    var first = false;
    var idValue = '';
    
    for (i = 0; i < children.length; i++) 
    {
        var child = $(children[i]);
        
        if (child.attr('data-groupid') !== undefined)
        {
            if (first) {
                idValue += ',';
            }
            idValue += child.attr('data-groupid');
            
            first = true; 
        }
    }
    return idValue;
}
