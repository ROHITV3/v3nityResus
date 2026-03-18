<%--
    Document   : tsp_site_order
    Created on : 13 Mar, 2020, 12:12:30 PM
    Author     : Kevin
--%>

<%@page import="org.json.simple.*"%>
<%@page import="v3nity.std.util.Utility"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.cust.biz.tps.data.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    TpsSiteOrder data = (TpsSiteOrder) request.getAttribute("data");

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>customized page on top of standard list page</title>
        <style>

            #list-sub-title {
                margin-left: 16px;
            }

            .tps-asset-pool-dialog {
                top: 92px;
                right: 16px;
                width: 540px;
                position: fixed;
                z-index: 20;
                box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
            }

            .tps-asset-pool-dialog-content {
                background-color: #f8f9f9 !important;
            }

            .tps-asset-pool-container {
                width: 100%;
                min-height: 128px;
                max-height: 224px;
                overflow-y: scroll;
                padding: 8px;
            }

            .tps-asset-pool-preloader-overlay {
                background-color: rgba(0, 0, 0, 0.6);
                width: 100%;
                height: 100%;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                position: absolute;
                overflow: hidden;
                z-index: 999999;
            }

            .tps-asset {
                color: #fff;
                display: inline-block;
                border-radius: 6px;
                border: #fff 2px solid;
                font-weight: bold;
                font-size: 14px;
                margin: 2px;
                padding: 4px 4px;
                white-space: nowrap;
                cursor: grab;
                z-index: 1;
                transition: 0.2s;
            }

            .tps-asset:active {
                cursor: grabbing;
                transform: scale(1.3);
                z-index: 2;
            }

            .tps-asset:hover {
                border: #4F4F4F 2px solid;
            }

            /* this will display an icon at the side of the div but ktc doesn't want it...
            .tps-asset.all-shift {
                background-image: url('Custom/tps/2-user.png');
                background-repeat: no-repeat;
                background-position: right 4px top 2px;
                background-size: 16px 16px;
                padding-right: 28px;
            }*/

            .tps-asset.all-shift {
                background-color: #82ca15 !important;
            }

            .tps-asset.disabled {
                cursor: not-allowed;
                transform: none;
                border: none;
            }

            .tps-asset-source-filter {
                margin-right: 16px;
            }

            .tps-filterer-count {
                font-weight: bold;
            }

            .tps-dashboard-container {
                display: inline-block;
                margin-right: 32px;
                vertical-align: top;
            }

            .tps-dashboard-container hr {
                background-color: #cdcdcd;
                border: 0 none;
                color: #cdcdcd;
                height: 1px;
            }

            .tps-dashboard {
                background-color: #000;
                color: #fff;
                display: inline-block;
                text-align: center;
                min-width: 100px;
                margin: 8px 4px;
                padding: 8px;
                box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
                vertical-align: top;
            }

            .tps-dashboard:last-child {
                margin-right: 0;
            }

            .tps-dashboard-footer {
                background-color: #000;
                margin: -8px;
                margin-top: 8px;
                padding: 2px;
            }

            .tps-dashboard-field {
                display: inline-block;
                padding: 4px;
                font-size: 14px;
            }

            .tps-dashboard-data {
                font-size: 28px;
                font-weight: bolder;
                text-align: center;
            }

            .tps-dashboard-asset-summary {
                border-collapse:collapse;
                border-spacing:0;
                font-size: 12px;
                margin-top: 8px;
            }

            .tps-dashboard-asset-summary th{
                text-align: left;
                text-transform: uppercase;

            }

            .tps-dashboard-asset-summary th:first-child{
                display: inline-block;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                width: 128px;
            }

            .tps-dashboard-asset-summary td{
                text-align: left;
            }

            .tps-dashboard-asset-summary td:first-child{
                display: inline-block;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                width: 120px;
            }

            .site-order-container {
                width: 100%;
                min-width: 380px;
                min-height: 32px;
                max-width: 500px;
            }

            .site-order-container.disabled {
                pointer-events: none;
                opacity: 0.6;
            }

            .site-order-pending-dashboard {
                padding: 0;
                margin: 0;
                width: auto;
            }

            .site-order-pending-dashboard span:first-child {
                display: inline-block;
                color: #000;
                text-align: center;
                width: 24px;
                font-size: 12px;
                vertical-align: bottom;
                margin-right: -4px;
            }

            .site-order-pending-dashboard span {
                display: inline-block;
                color: #000;
                font-size: 12px;
                font-weight: bold;
                text-align: center;
                width: 32px;
                height: 28px;
                line-height: 28px;
                vertical-align: bottom;
            }

            .site-order-pending-dashboard span.done {
                color: #000;
            }

            .site-order-pending-dashboard span.overflow {
                color: #fff;
                background-color: #a551d6;
            }

            .site-order-pending-dashboard span.pending {
                color: #000;
                background-color: #ffff00;
            }

            .dataTable {
                font-size: 14px !important;
            }

        </style>
        <script>

            $(document).ready(function()
            {
            <%  if (!data.hasAssignmentPool())
                {
            %>
                togglePool();   // hide the dialog...
            <%
            }
            else
            {
            %>
                refreshDashboardAssetSummary();   // hide the dialog...
            <%
                }
            %>

                $('select[name="shift_id"]').change(shiftChanged);

            });

            function shiftChanged()
            {
                $('select[name="start_time"]').children().show();

                $('select[name="end_time"]').children().show();

                if (this.value === '1') // day...
                {
                    $('select[name="start_time"]').children().slice(49).hide();

                    $('select[name="end_time"]').children().slice(49).hide();
                }
                else if (this.value === '2') // night...
                {
                    $('select[name="start_time"]').children().slice(0, 49).hide();

                    $('select[name="end_time"]').children().slice(0, 49).hide();
                }
            }

            function allowDrop(e)
            {
                e.preventDefault();
            }

            function drag(e)
            {
                e.dataTransfer.setData("asset", e.target.id);
            }

            function drop(e)
            {
                e.preventDefault();

                var tagId = e.dataTransfer.getData("asset");

                var tag = document.getElementById(tagId);

                var target = e.target;

                var assetId = tag.getAttribute('data-asset');

                var shiftId = tag.getAttribute('data-shift');

                var sourceId = tag.getAttribute('data-src');

                var destinationId = target.getAttribute('data-dst');

                /*
                 * if no destination id, check for its parent, the parent may be the drop off destination container...
                 */
                if (destinationId === null)
                {
                    destinationId = target.parentElement.getAttribute('data-dst');

                    if (destinationId !== null)
                    {
                        // it is indeed the parent...
                        target = target.parentElement;
                    }
                }

                /*
                 * this is to prevent either dropping on the same div or dropping into the asset div itself...
                 */
                if (sourceId === destinationId || destinationId === null)
                {
                    return;
                }

                $.ajax({
                    url: "tps?type=update&action=assign",
                    type: "POST",
                    data: {
                        src: sourceId,
                        dst: destinationId,
                        asset: assetId,
                        shift: shiftId,
                        date: selectedDate()
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            if (sourceId > 0)   // 0 value represents drop from pool...
                            {
                                updateSiteOrderDashboard(sourceId, -1);
                            }

                            updateSiteOrderDashboard(destinationId, 1);

                            target.appendChild(tag);

                            tag.setAttribute('data-src', destinationId);

                            tag.id = 'tag-' + destinationId + '-' + assetId;
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);

                        refreshPool();

                        refreshDashboardAssignment();
                    }
                });
            }

            function updateSiteOrderDashboard(id, difference)
            {
                var element = $('#site-order-pending-' + id);

                var val = parseInt(element.text()) + difference;

                var pending = parseInt($('#site-order-total-' + id).text()) - val;

                element.text(val);

                element.removeClass();

                if (pending === 0)
                {
                    element.addClass('done');
                }
                else if (pending < 0)
                {
                    element.addClass('overflow');
                }
                else
                {
                    element.addClass('pending');
                }
            }

            function _confirm(id)
            {
                $.ajax({
                    url: "tps?type=update&action=confirm",
                    type: "POST",
                    data: {
                        id: id
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'site order is pending for acknowledgement', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function acknowledge(id)
            {
                $.ajax({
                    url: "tps?type=update&action=acknowledge",
                    type: "POST",
                    data: {
                        id: id
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'site order acknowledged', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function commit(id)
            {
                $.ajax({
                    url: "tps?type=update&action=commit",
                    type: "POST",
                    data: {
                        id: id
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'site order committed', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function approve(id)
            {
                $.ajax({
                    url: "tps?type=update&action=approve",
                    type: "POST",
                    data: {
                        id: id
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'site order approved', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function reject(id)
            {
                $.ajax({
                    url: "tps?type=update&action=reject",
                    type: "POST",
                    data: {
                        id: id
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'site order rejected', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function cancel(id)
            {
                var c = confirm("Are you sure you want to cancel?");

                if (c === true)
                {
                    $.ajax({
                        url: "tps?type=update&action=cancel",
                        type: "POST",
                        data: {
                            id: id
                        },
                        success: function(response)
                        {
                            if (response.result)
                            {
                                refreshDataTable_${namespace}();

                                dialog('Information', 'site order cancelled', 'success');
                            }
                            else
                            {
                                dialog('Error', response.text, 'alert');
                            }
                        },
                        beforeSend: function()
                        {
                            preloader(true);
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            preloader(false);
                        }
                    });
                }
            }

            function revert(id, fromStatus, toStatus)
            {
                $.ajax({
                    url: "tps?type=update&action=revert",
                    type: "POST",
                    data: {
                        id: id,
                        fromStatus: fromStatus,
                        toStatus: toStatus
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'site order status reverted', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function editRecord(id)
            {
                showEdit_${namespace}(id);
            }

            function deleteRecord(id)
            {
                delete_${namespace}(id);
            }

            function selectedDate()
            {
                var d = $('#dateTimePicker-start-start_date').val();

                if (d === '')
                {
                    return '';
                }

                /* conversion...
                 * dd/mm/yyyy -> yyyymmdd
                 */
                return d.substr(6, 4) + d.substr(3, 2) + d.substr(0, 2);
            }

            function selectedShift()
            {
                /*
                 * fuck!!! got no choice have to use stupid way to get the selected option...
                 */
                var id = $('div[name="shift_id"').find('select :selected').val();

                if (id === '')
                {
                    id = 0;
                }

                return id;
            }

            function refreshDashboardAssetSummary()
            {
                $.ajax({
                    url: "tps?type=dashboard&action=asset",
                    type: "POST",
                    data: {},
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var data = response.data;

                            var table = document.getElementById('tps-dashboard-asset-status-summary');

                            for (var i = 0; i < data.asset_status_summary.length; i++)
                            {
                                var row = document.createElement("tr");

                                row.innerHTML = '<td>' + data.asset_status_summary[i].status + '</td><td>' + data.asset_status_summary[i].total + '</td>';

                                table.appendChild(row);
                            }

                            table = document.getElementById('tps-dashboard-asset-unassign-summary');

                            var row = document.createElement("tr");

                            row.innerHTML = '<td>WITHOUT DRIVER</td><td>' + data.total_unassigned_asset + '</td>';

                            table.appendChild(row);
                        }
                    }
                });
            }

            function refreshDashboardAssignment()
            {
                $.ajax({
                    url: "tps?type=dashboard&action=assignment",
                    type: "POST",
                    data: {
                        planner: <%=listProperties.getUser().getId()%>,
                        shift: selectedShift(),
                        date: selectedDate()
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var data = response.data;

                            $('#tps-dashboard-requested').html(data.requested);

                            $('#tps-dashboard-fulfilled').html(data.fulfilled);

                            $('#tps-dashboard-unfulfilled').html(data.requested - data.fulfilled);

                            $('#tps-dashboard-assigned').html(data.assigned);

                            $('#tps-dashboard-overflowed').html(data.overflowed);

                            var fulfilled = response.fulfilled;

                            $('#tps-dashboard-fulfilled-ktc').html(fulfilled.ktc);

                            $('#tps-dashboard-fulfilled-others').html(fulfilled.others);
                        }
                    }
                });
            }

            function refreshDashboardStatus()
            {
                $.ajax({
                    url: "tps?type=dashboard&action=status",
                    type: "POST",
                    data: {
                        resourceId: <%=data.getResourceId()%>,
                        identifier: <%=listProperties.getUser().getId()%>,
                        shift: selectedShift(),
                        date: selectedDate()
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var data = response.data;

                            for (var i = 0; i < data.length; i++)
                            {
                                $('#tps-dashboard-status-' + data[i].id).html(data[i].count);
                            }
                        }
                    }
                });
            }

            function refreshPool()
            {
                $.ajax({
                    url: "tps?type=pool&action=asset",
                    type: "POST",
                    data: {
                        date: selectedDate(),
                        shift: selectedShift()
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var assets = response.data;

                            $('#asset-pool').html('');

                            $('#tps-asset-pool-dialog-count').html(' (' + assets.length + ')');

                            for (var i = 0; i < assets.length; i++)
                            {
                                var asset = assets[i];

                                var element = $('<div>',
                                    {
                                        id: asset.tag_id,
                                        class: 'tps-asset',
                                        draggable: asset.assignable,
                                        ondragstart: 'drag(event)',
                                        onselectstart: 'return false',
                                        'data-src': 0,
                                        'data-asset': asset.id,
                                        'data-shift': asset.shift_id,
                                        'data-source-id': asset.source_id
                                    }
                                ).css('background-color', asset.color);

                                element.text(asset.label + (asset.spare === '' ? '' : ' / ' + asset.spare));

                                if (asset.assignable)
                                {
                                    element.attr('title', asset.shift + ', ' + asset.status + ', ' + asset.company);
                                }
                                else
                                {
                                    element.attr('title', asset.status + ', ' + asset.company);

                                    element.addClass('disabled');
                                }

                                if (asset.all_shift === true)
                                {
                                    element.addClass('all-shift');
                                }

                                if (!document.getElementById('checkbox-asset-source-' + asset.source_id).checked)
                                {
                                    element.hide();
                                }

                                $('#asset-pool').append(element);
                            }

                            refreshFiltererCount();
                        }
                    },
                    beforeSend: function()
                    {
                        preloaderPool(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'Pool dialog has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloaderPool(false);
                    }
                });
            }

            function refreshFiltererCount()
            {
                $('#asset-source-filterer input[type=checkbox]').each(function()
                {
                    var sourceId = $(this).attr('data-id');

                    var count = $('#asset-pool').children("div[data-source-id='" + sourceId + "']").length;

                    $('#tps-filterer-count-' + sourceId).html('(' + count + ')');
                });
            }

            function refreshSubTitle()
            {
                var d = $('#dateTimePicker-start-start_date').val();

                var date = new Date(d.substr(6, 4) + '-' + d.substr(3, 2) + '-' + d.substr(0, 2));

                if (isToday(date))
                {
                    $('#list-sub-title').html(d + ' (Today)');
                }
                else
                {
                    $('#list-sub-title').html(d);
                }
            }

            function togglePool()
            {
                $('#tps-asset-pool-dialog').toggle();
            }

            function preloaderPool(on)
            {
                var preloader = document.getElementById("tps-asset-pool-preloader");

                if (on)
                {
                    preloader.style.display = "block";
                }
                else
                {
                    preloader.style.display = "none";
                }
            }

            function openCopy()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    $('#dialog-copy-schedule').data('dialog').open();
                }
                else
                {
                    dialog('No Record Selected', 'Please select at least a record to copy', 'alert');
                }
            }

            function closeCopy()
            {
                $('#dialog-copy-schedule').data('dialog').close();
            }

            function executeCopy()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if ($('#dateTimePicker-copy').val() === '')
                    {
                        dialog('No Date Selected', 'Please select a date to copy', 'alert');

                        return;
                    }

                    var date = $('#dateTimePicker-copy').val();

                    var ids = data.join();

                    $.ajax({
                        url: "tps?type=update&action=copy",
                        type: "POST",
                        data: {
                            ids: ids,
                            date: date
                        },
                        success: function(response)
                        {
                            closeCopy();

                            if (response.result)
                            {
                                refreshDataTable_${namespace}();

                                dialog('Schedule Copied', 'Site order has been copied successfully.', 'success');
                            }
                            else
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            }
                        },
                        beforeSend: function()
                        {
                            preloader(true);
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            preloader(false);
                        }
                    });
                }
            }

            function openOverlay()
            {
                $('#dialog-overlay-schedule').data('dialog').open();
            }

            function closeOverlay()
            {
                $('#dialog-overlay-schedule').data('dialog').close();
            }

            function executeOverlay()
            {
                var startDate = $('#dateTimePicker-start-start_date').val();

                if (startDate === '')
                {
                    return '';
                }

                if ($('#dateTimePicker-overlay').val() === '')
                {
                    dialog('No Date Selected', 'Please select a date to overlay', 'alert');

                    return;
                }

                var overlayDate = $('#dateTimePicker-overlay').val();

                $.ajax({
                    url: "tps?type=update&action=overlay",
                    type: "POST",
                    data: {
                        targetDate: startDate,
                        overlayDate: overlayDate
                    },
                    success: function(response)
                    {
                        closeOverlay();

                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Schedule Overlayed', 'Overlay completed.', 'success');
                        }
                        else
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

            function replicate(id)
            {
                $.ajax({
                    url: "tps?type=update&action=replicate",
                    type: "POST",
                    data: {
                        order_id: id
                    },
                    success: function(response)
                    {
                        closeCopy();

                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Schedule Copied', 'Site order has been copied successfully.', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }


            function selectionUpdate(fromStatus, toStatus)
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length === 0)
                {
                    dialog('No Record Selected', 'Please select at least a record to update', 'alert');

                    return;
                }

                var c = confirm("Are you sure you want to update the selected records?");

                if (c === true)
                {
                    $.ajax({
                        url: "tps?type=update&action=selection",
                        type: "POST",
                        data: {
                            id: data.join(),
                            date: selectedDate(),
                            fromStatus: fromStatus,
                            toStatus: toStatus
                        },
                        success: function(response)
                        {
                            if (response.result)
                            {
                                refreshDataTable_${namespace}();

                                dialog('Information', 'site orders are updated', 'success');
                            }
                            else
                            {
                                dialog('Error', response.text, 'alert');
                            }
                        },
                        beforeSend: function()
                        {
                            preloader(true);
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            preloader(false);
                        }
                    });
                }
            }

            function selectionUpdateAll(fromStatus, toStatus)
            {
                var c = confirm('Are you sure you want to update all the records?');

                if (c === true)
                {
                    $.ajax({
                        url: "tps?type=update&action=selection",
                        type: "POST",
                        data: {
                            date: selectedDate(),
                            fromStatus: fromStatus,
                            toStatus: toStatus
                        },
                        success: function(response)
                        {
                            if (response.result)
                            {
                                refreshDataTable_${namespace}();

                                dialog('Information', 'site orders are updated', 'success');
                            }
                            else
                            {
                                dialog('Error', response.text, 'alert');
                            }
                        },
                        beforeSend: function()
                        {
                            preloader(true);
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            preloader(false);
                        }
                    });
                }
            }

            function ondatasuccess()
            {
            <%  if (data.hasAssignmentPool())
                {
            %>
                refreshPool();
            <%
                }
            %>
            <%  if (data.hasAssignmentDashboard())
                {
            %>
                refreshDashboardAssignment();
            <%
                }
            %>
            <%  if (data.hasStatusDashboard())
                {
            %>
                refreshDashboardStatus();
            <%
                }
            %>
                refreshSubTitle();
            }

            function isToday(date)
            {
                var today = new Date();

                return date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear();
            }

            function filterAsset()
            {
                var text = $('#input-filter-asset').val().toUpperCase();

                $('#asset-pool').children().each((index, element) => {

                    if ($(element).html().toUpperCase().includes(text) === true || $(element).attr('title').toUpperCase().includes(text))
                    {
                        $(element).show();
                    }
                    else
                    {
                        $(element).hide();
                    }
                });
            }

            function filterAssetSource()
            {
                $('#asset-source-filterer input[type=checkbox]').each(function()
                {
                    var sourceId = $(this).attr('data-id');

                    if (this.checked)
                    {
                        $('#asset-pool').children("div[data-source-id='" + sourceId + "']").show();
                    }
                    else
                    {
                        $('#asset-pool').children("div[data-source-id='" + sourceId + "']").hide();
                    }
                });
            }

        </script>
    </head>
    <body>
        <%  if (data.hasStatusDashboard())
            {
        %>
        <div class="tps-dashboard-container">
            <h4 class="text-light">Status Dashboard</h4>
            <hr>
            <%
                int[] ids = data.getViewableStatus();

                for (int i = 0; i < ids.length; i++)
                {
                    int status = ids[i];

                    String color = TpsSiteOrderStatus.getHtmlColor(ids[i]);

                    String text = TpsSiteOrderStatus.getDisplayText(ids[i]);

            %>
            <div class="tps-dashboard" style="background-color: <%=color%>;" data-role="hint" data-hint="Shows the total <%=text%> site orders filtered by the specified date." data-hint-background="bg-red" data-hint-color="fg-white" data-hint-mode="2">
                <%
                    out.write("<div class=\"tps-dashboard-data\" id=\"tps-dashboard-status-" + status + "\">0</div>");
                %>
                <div class="tps-dashboard-field"><%=text%></div>
            </div>
            <%
                }
            %>
        </div>
        <%
            }
        %>

        <%  if (data.hasAssignmentDashboard())
            {
        %>
        <div class="tps-dashboard-container">
            <h4 class="text-light">Assignment Dashboard</h4>
            <hr>
            <div class="tps-dashboard" style="background-color: #295289;" data-role="hint" data-hint="Shows the total number of vehicles requested." data-hint-background="bg-red" data-hint-color="fg-white" data-hint-mode="2">
                <div class="tps-dashboard-data" id="tps-dashboard-requested">0</div>
                <div class="tps-dashboard-field">Requested</div>
            </div>
            <div class="tps-dashboard" style="background-color: #4da6d8;" data-role="hint" data-hint="Shows the total vehicles assigned to meet the requested site orders." data-hint-background="bg-red" data-hint-color="fg-white" data-hint-mode="2">
                <div class="tps-dashboard-data" id="tps-dashboard-fulfilled">0</div>
                <div class="tps-dashboard-field">Fulfilled</div>
            </div>
            <div class="tps-dashboard" style="background-color: #ffff00; color: #000000" data-role="hint" data-hint="Shows the total number of vehicles pending to assign." data-hint-background="bg-red" data-hint-color="fg-white" data-hint-mode="2">
                <div class="tps-dashboard-data" id="tps-dashboard-unfulfilled">0</div>
                <div class="tps-dashboard-field">Unfulfilled</div>
            </div>
            <div class="tps-dashboard" style="background-color: #a551d6;" data-role="hint" data-hint="Shows the excess total number of vehicles assigned" data-hint-background="bg-red" data-hint-color="fg-white" data-hint-mode="2">
                <div class="tps-dashboard-data" id="tps-dashboard-overflowed">0</div>
                <div class="tps-dashboard-field">Excessed</div>
            </div>
            <div class="tps-dashboard" style="background-color: #8ca504;" data-role="hint" data-hint="Shows the total number of vehicles deployed (fulfilled + excessed)" data-hint-background="bg-red" data-hint-color="fg-white" data-hint-mode="2">
                <div class="tps-dashboard-data" id="tps-dashboard-assigned">0</div>
                <div class="tps-dashboard-field">Deployed</div>
                <div class="tps-dashboard-footer" style="background-color: #6b7b12;">
                    <div class="tps-dashboard-field">KTC <span id="tps-dashboard-fulfilled-ktc">0</span></div>
                    <div class="tps-dashboard-field">OTHERS <span id="tps-dashboard-fulfilled-others">0</span></div>
                </div>
            </div>
        </div>
        <div class="tps-dashboard-container">
            <h4 class="text-light">Asset Summary</h4>
            <hr>
            <table class='tps-dashboard-asset-summary'>
                <thead>
                    <tr>
                        <th>KTC</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody id="tps-dashboard-asset-status-summary">

                </tbody>
            </table>
            <table class='tps-dashboard-asset-summary'>
                <thead>
                    <tr>
                        <th>KTC</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody id="tps-dashboard-asset-unassign-summary">

                </tbody>
            </table>
        </div>
        <%
            }
        %>
        <div id='tps-asset-pool-dialog' class="panel tps-asset-pool-dialog" data-role="draggableItem" data-drag-element=".heading">
            <div class="heading" style="background-color: #b31011;">
                <span class="icon mif-truck" style="background-color: #000; line-height: 21px"></span>
                <span class="title">Assignment</span><span id="tps-asset-pool-dialog-count"></span>
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="togglePool();" style="top: -6px;"><span class="mif-cross"></span></button>
            </div>
            <div class="content tps-asset-pool-dialog-content">
                <div class="input-control text" data-role="input" style="width: 100%">
                    <input id="input-filter-asset" type="text" placeholder="Enter vehicle or company to filter" onkeyup="filterAsset()" autocomplete="off">
                    <div class="button-group">
                        <button class="button" type="button" onclick="filterAsset()" title="Apply filter"><span class="mif-filter"></span></button>
                    </div>
                </div>
                <div id="asset-source-filterer">
                    <%
                        TpsDataHandler dataHandler = new TpsDataHandler();

                        dataHandler.setConnection(listProperties.getDatabasePool().getConnection());

                        try
                        {
                            JSONArray assetSourceList = dataHandler.getAssetSourceList(listProperties.getUser().getInt("customer_id"));

                            for (int i = 0; i < assetSourceList.size(); i++)
                            {
                                JSONObject assetSource = (JSONObject) assetSourceList.get(i);

                                int id = (int) assetSource.get("id");

                                String source = (String) assetSource.get("source");
                    %>
                    <label class="tps-asset-source-filter input-control checkbox small-check">
                        <input id="checkbox-asset-source-<%=id%>" type="checkbox" data-id="<%=id%>" onchange="filterAssetSource(<%=id%>)" checked>
                        <span class="check"></span>
                        <span class="caption"><%=source%></span>
                        <span id="tps-filterer-count-<%=id%>" class="tps-filterer-count"></span>
                    </label>
                    <%      }
                        }
                        catch (Exception e)
                        {

                        }
                        finally
                        {
                            dataHandler.closeConnection();
                        }
                    %>
                </div>
                <!--<p class="note" style="margin: 8px 0">Drag and drop vehicle into assignment column.</p>-->
                <div id='asset-pool' data-dst='0' class="tps-asset-pool-container" ondrop='drop(event)' ondragover='allowDrop(event)'></div>
            </div>
            <div id="tps-asset-pool-preloader" class="tps-asset-pool-preloader-overlay" style="display: none">
                <div class="page-preloader"></div>
            </div>
        </div>
        <div data-role="dialog" id=dialog-copy-schedule class="" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div style="padding: 16px;">
                <h1 class="text-light">Copy Schedule</h1>
                <p class="note">Selection only applies to single page records.</p>
                <div style="margin: 16px 0;">
                    <label style="margin-right: 8px;">Choose start date to copy to:</label>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-copy" type="text" placeholder="Choose a start date" value="" readonly>
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        <script>
                            var minDate = new Date();

                            minDate.setHours(0, 0, 0, 0);

                            var maxDate = new Date(minDate.getTime() + (6 * 86400000));

                            $('#dateTimePicker-copy').AnyTime_picker({format: '%d/%m/%Y', earliest: minDate, latest: maxDate});

                        </script>
                    </div>
                </div>
                <div style="text-align: right;">
                    <button id=button-copy-schedule type="button" class="button primary" onclick="executeCopy()">Copy</button>
                    <button id=button-copy-schedule-cancel type="button" class="button" onclick="closeCopy()">Cancel</button>
                </div>
            </div>
        </div>
        <div data-role="dialog" id=dialog-overlay-schedule class="" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div style="padding: 16px;">
                <h1 class="text-light">Overlay Schedule</h1>
                <p class="note">Overlaying will copy non overlapped site orders to allow viewing and assignment.</p>
                <div style="margin: 16px 0;">
                    <label style="margin-right: 8px;">Choose date to overlay:</label>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-overlay" type="text" placeholder="Choose date" value="" readonly>
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        <script>

                            $('#dateTimePicker-overlay').AnyTime_picker({format: '%d/%m/%Y'});

                        </script>
                    </div>
                </div>
                <div style="text-align: right;">
                    <button id=button-overlay-schedule type="button" class="button primary" onclick="executeOverlay()">Overlay</button>
                    <button id=button-overlay-schedule-cancel type="button" class="button" onclick="closeOverlay()">Cancel</button>
                </div>
            </div>
        </div>
    </body>
</html>