<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    Locale locale = userProperties.getLocale();

    Connection con = null;

    String lib = "v3nity.std.biz.data.plan";

    String type = "OptResource";

    ListData data = new OptResource();

    data.onInstanceCreated(userProperties);

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    ListMetaData metaData = null;

    List<MetaData> metaDataList = data.getMetaDataList();

    int metaListSize = metaDataList.size();

    String columnList = "";

    int operations = userProperties.getOperations(data.getResourceId());

    boolean add = userProperties.canAccess(operations, Operation.ADD);

    boolean update = userProperties.canAccess(operations, Operation.UPDATE);

    boolean delete = userProperties.canAccess(operations, Operation.DELETE);

    int pageLength = data.getPageLength();

    int customerId = userProperties.getInt("customer_id");

    try {
        for (int i = 0; i < metaListSize; i++) {
            metaData = (ListMetaData) metaDataList.get(i);

            // construct the column definition for the data table...
            if (metaData.getViewable()) {
                if (columnList.length() > 0) {
                    columnList += ",";
                }

                columnList += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + "\", \"orderable\": " + metaData.getOrderable() + " }";
            }
        }

        // create the edit column...
        if (update && data.hasEditButton()) {
            columnList += ",{ \"data\": \"" + "editButton" + "\", \"title\": \"" + userProperties.getLanguage("edit") + "\", \"orderable\": false }";
        }

        //countryDataHandler.closeConnection();
    } catch (Exception e) {

    } finally {
        userProperties.closeConnection(con);
    }


%>

<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <link href="css/v3nity-timetable.css" rel="stylesheet">
        <style>
            .cap-box {
                float: left;
                height: 30px;
                padding: 3px;
                border-radius: 5px;
                background: #87CEFA;
                margin-right: 5px;
                margin-top: 3px;
            }
            .single-cap {
                float: left;
                height: 20px;
                line-height: 20px;
                font-size: 14px;
                margin-left: 3px;
            }
            .cap-icon {
                float: left;
                width: 20px;
                height: 20px;
                margin-left: 5px;
                background: url(img/bin.png) no-repeat;
                background-position: center;
                background-size: 80%;
                cursor: pointer;
            }
            .cap-icon:hover{
                background: url("img/bin_hover_2.png") no-repeat;
                background-position: center; 
                background-size: 80%;
            }
            .add-box{
                float: left;
                clear: both;
                height: 30px;
                padding: 5px;
                color: #000;

                border-radius: 5px;
                border-width: 1px;
                border-style: solid;
                border-color: #aaa;

                background: #ddd;
                margin-top: 10px;

                -webkit-transition:background 0.3s;
                -moz-transition:background 0.3s;
                -o-transition:background 0.3s;
                transition:background 0.3s;

            }
            .add-box:hover{
                color: #fff;
                background: #007700;
                cursor: pointer;
            }
            .add-icon{
                float: left;
                width: 20px;
                height: 20px;

                background: url("img/add.png") no-repeat;
                background-position: center; 
                background-size: 80%;

                cursor: pointer;
            }

            .add-box:hover{
                color: #fff;
                background: #007700;
                cursor: pointer;
            }
            .single-add{
                float: left;
                height: 20px;
                line-height: 20px;
                font-size: 14px;
                font-weight: bold;
                margin-left: 3px;
                margin-right: 5px;
            } 
            .confirm-icon{
                float: left;
                width: 30px;
                height: 30px;
                margin-top: 5px;
                background: url("img/ic_confirm.png") no-repeat;
                background-position: center; 
                background-size: 80%;
                cursor: pointer;
            }
            .confirm-icon:hover{
                background: url("img/ic_confirm_hover.png") no-repeat;
                background-position: center; 
                background-size: 80%;
            }
            .cancel-icon{
                float: left;
                width: 30px;
                height: 30px;
                margin-top: 5px;
                background: url("img/ic_cancel.png") no-repeat;
                background-position: center; 
                background-size: 80%;
                cursor: pointer;
            }
            .cancel-icon:hover
            {
                background: url("img/ic_cancel_hover.png") no-repeat;
                background-position: center; 
                background-size: 80%;
            }
        </style>
        <script type="text/javascript" src="js/v3nity-timetable.js"></script>
        <script type="text/javascript">
            var selectedId, action;

            var timetableDialogData;

            var csv = new csvDownload('OSTListController?lib=<%=lib%>&type=<%=type%>&action=view', 'V3NITY');

            var totalRecords = -1;

            var requireOverallCount = true;

            var customFilterQuery = [];

            var listForm;

            var properties = [];
            var blockDate = [];

            $(document).ready(function ()
            {
                listForm = new ListForm('specific-filter');

                $("#from-date").AnyTime_picker({
                    format: "%d/%m/%Y"
                });
                $("#to-date").AnyTime_picker({
                    format: "%d/%m/%Y"
                });

                var tbl = $('#result-table').DataTable(
                        {
                            dom: 'rtip',
                            pageLength: <%=pageLength%>,
                            autoWidth: false,
                            deferRender: true,
                            orderClasses: false,
                            order: [[0, 'desc']], // default sort by job id...
                            columns: [<%=columnList%>],
                            processing: true,
                            serverSide: true,
                            responsive: true,
                            ajax: {
                                url: 'WamResourceController?lib=<%=lib%>&type=<%=type%>&format=json&action=view',
                                type: 'POST',
                                data: function (d) {
                                    d.totalRecords = totalRecords;
                                    d.requireOverallCount = requireOverallCount;
                                    d.customFilterQuery = JSON.stringify(customFilterQuery);
                                },
                                beforeSend: function ()
                                {
                                    $('.toolbar-button').prop("disabled", true);
                                },
                                error: function (xhr, error, thrown)
                                {
                                    dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                                },
                                complete: function ()
                                {
                                    $('.toolbar-button').prop("disabled", false);
                                },
                                dataSrc: function (json)
                                {
                                    var data = json;
                                    if (data.expired === undefined)
                                    {
                                        if (data.result === true)
                                        {
                                            if (data.data !== undefined && data.data.length === 0 && totalRecords !== -1)
                                            {
                                                dialog('No Record', 'No record found', 'alert');
                                            }
                                        } else
                                        {
                                            dialog('Failed', data.text, 'alert');
                                        }
                                    } else
                                    {
                                        $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                        json.data = [];
                                    }

                                    return json.data;
                                }
                            },
                            drawCallback: function (settings)
                            {
                                if (settings.json.errorText !== undefined)
                                {
                                    dialog('Error', settings.json.errorText, 'alert');
                                    return;
                                }
                                // do this so that the total records will not be retrieved from the database again...
                                // greatly increase performance towards retrieving data from datatable...
                                if (tbl !== undefined)
                                {
                                    if (tbl.page.info().recordsTotal === 0 && totalRecords !== -1)
                                    {

                                    }
                                    totalRecords = tbl.page.info().recordsTotal;
                                    requireOverallCount = false;
                                }
                            },
                            createdRow: function (row, data, index)
                            {

                            },
                            select: {
            <%=(data.hasSelection()) ? "style: 'multi'" : ""%>
                            },
                            buttons: [
                                'selectAll',
                                'selectNone',
                                'csv'
                            ],
                            language: {
                                info: '<%=userProperties.getLanguage("showing")%>' + ' _START_ ' + '<%=userProperties.getLanguage("to")%>'.toLowerCase() + ' _END_ ' + '<%=userProperties.getLanguage("of")%>'.toLowerCase() + ' _TOTAL_ ' + '<%=userProperties.getLanguage("entries")%>'.toLowerCase(),
                                infoEmpty: '<%=userProperties.getLanguage("showing")%>' + ' 0 ' + '<%=userProperties.getLanguage("to")%>'.toLowerCase() + ' 0 ' + '<%=userProperties.getLanguage("of")%>'.toLowerCase() + ' 0 ' + '<%=userProperties.getLanguage("entries")%>'.toLowerCase(),
                                emptyTable: '<%=userProperties.getLanguage("noDataAvailable")%>',
                                loadingRecords: 'Loading...',
                                processing: 'Retrieving...<span class="mif-spinner2 mif-ani-spin"></span>',
                                zeroRecords: 'No matching records found',
                                paginate: {
                                    first: '<<',
                                    last: '>>',
                                    next: '>',
                                    previous: '<'
                                }
                            }

                        });

                tbl.on('xhr', function ()
                {
                    tbl.off('draw.dt.dtSelect');
                });
                getProperty();
            });

            function getProperty()
            {
                $.ajax({
                    type: 'POST',
                    url: 'PropertyGroupController?lib=<%=lib%>&type=<%=type%>&action=getproperty&customerId=<%=customerId%>',
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            var propertyData = data.data;
                            var html = '';

                            html += "<option value = \"\" disabled selected>- Select Property -</option>";

                            for (var i = 0; i < propertyData.length; i++)
                            {
                                var aProp = propertyData[i];

                                html += "<option value='" + aProp.id + "'" + ">" + aProp.property + "</option>";

                            }
                            $('select[name=property').replaceWith("<select id=\"property\" name=\"property\" style=\"font-size: 18px;\">" + html + "</select>");
                        } 
                        else
                        {
                            dialog('Failed', 'Unable to retrieve Property list', 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#button-save').prop("disabled", false);
                    },
                    async: true
                });
            }

            $("#tool-button-add").click(function ()
            {
                properties = [];
                showAddForm();
            });

            $("#tool-button-edit").click(function ()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Warning', 'Please aware that you have selected more than one records', 'warning');
                    }

                    var id = data.join();

                    JobSchedule_showEdit(id);
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            });

            $("#tool-button-delete").click(function ()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        var ids = data.join();

                        $.ajax({
                            type: 'POST',
                            url: 'WamResourceController?lib=<%=lib%>&type=<%=type%>&action=delete',
                            data: {
                                id: ids
                            },
                            beforeSend: function ()
                            {
                                $('#button-save').prop("disabled", true);
                            },
                            success: function (data)
                            {

                                if (data.result === true)
                                {
                                    dialog('Success', data.text, 'success');
                                    refreshPageLength();
                                    closeForm();
                                } else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            },
                            error: function ()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function ()
                            {
                                $('#button-save').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                } else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'alert');
                }
            });

            $("#tool-button-copy").click(function ()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Only one job can be replicated at a time', 'Please select 1 record to edit', 'alert');
                    } else
                    {
                        var id = data.join();
                        copyJobSchedule(id);
                    }
                } else
                {
                    dialog('No Record Selected', 'Please select 1 record to edit', 'alert');
                }
            });



            function toggleSelect()
            {
                if ($('#selectAll').hasClass('selected'))
                {
                    $('#result-table').DataTable().button(1).trigger();
                    $('#selectAll').removeClass('selected');
                } else
                {
                    $('#result-table').DataTable().button(0).trigger();
                    $('#selectAll').addClass('selected');
                }
            }

            function searchData()
            {
                var searchText = $('#search-data').val();

                requireOverallCount = true;

                $('#result-table').DataTable().search(searchText).draw();
            }

            function refreshDataTable()
            {
                requireOverallCount = true;

                refreshPageLength();

            }

            function refreshPageLength()
            {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength))
                {
                    var table = $('#result-table').DataTable();

                    table.page.len(pageLength).draw();
                } else
                {
                    resetPageLength();
                }
            }

            function resetPageLength()
            {
                var table = $('#result-table').DataTable();
                // reset default value in page length control...
                $('#page-length').val(<%=pageLength%>);
                // reset search box...
                $('#search-data').val('');
                // reset table search...
                table.search('');
                // reset default page length...
                table.page.len(<%=pageLength%>).draw();
            }
            function populateForm(result)
            {
                $.each(result.data, function (i, field)
                {
                    if (field.type === 'text')
                    {
                        $('input[name=' + field.name + ']').val(field.value);
                    } else if (field.type === 'selection')
                    {
                        if (field.value === 0)
                        {
                            $('select[name=' + field.name + ']').val('');
                        } else
                        {
                            $('select[name=' + field.name + ']').val(field.value).trigger('change');
                        }
                    } else if (field.type === 'checkbox')
                    {
                        $('input[name=' + field.name + ']').prop('checked', field.value);
                    } else if (field.type === 'html')
                    {

                    }
                });
            }

            function clearForm()
            {
                document.getElementById('form-dialog-data').reset();
                $('#all-prop').html('');
                $('#all-block-date').html('');
                hideAddProperty();
                hideAddBlockDate();
                listForm.reset();
            }

            function closeForm()
            {
                $('#form-dialog').data('dialog').close();

                clearForm();
            }

            function dispose()
            {
                $("#from-date").AnyTime_noPicker();
                $("#to-date").AnyTime_noPicker();
                $('[id^="dateTimePicker"]').each(function (index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            }

            function customFilter()
            {
                if (listForm.filter() !== undefined)
                {
                    customFilterQuery = listForm.filter();

                    refreshDataTable();
                }
            }

            function saveForm()
            {
                var action = $('#button-save').data('action');

                if ($('select[name=driver_id]').val() === '' || $('select[name=time_group_id]').val() === '' || $('input[name=resource]').val() === '')
                {
                    dialog('Failed', 'Mandatory fields cannot be blank', 'alert');
                    return;
                }
                
                $.ajax({
                    type: 'POST',
                    url: 'WamResourceController?lib=<%=lib%>&type=<%=type%>&action=' + action,
                    data: {
                        selectedId: selectedId,
                        customerId: $('select[name="customer_id"]').val(),
                        driverId: $('select[name="driver_id"]').val(),
                        resource: $('input[name=resource]').val(),
                        timeGroupId: $('select[name=time_group_id]').val(), //propertiesIds
                        depotId: $('select[name=depot_id]').val(), //propertiesIds
                        capacity: $('#capacity').val(),
                        properties: properties.toString(),
                        blockDate: blockDate.toString()
                    },
                    beforeSend: function ()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            dialog('Success', '', 'success');

                            refreshPageLength();

                            closeForm();
                        } else
                        {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#button-save').prop("disabled", false);
                    },
                    async: true
                });
            }

            function showAddForm()
            {
                selectedId = 0;
                var dialog = $('#form-dialog').data('dialog');
                $('#form-dialog-title').html('<%=userProperties.getLanguage("add")%> ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                $('#button-save').data('action', 'add');
                clearForm();
                dialog.open();
            }

            function showEdit_OptResource(id)
            {
                clearForm();
                selectedId = id;
                if (getData(id))
                {
                    var dialog = $('#form-dialog').data('dialog');
                    $('#form-dialog-title').html('<%=userProperties.getLanguage("edit")%> ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                    $('#button-save').data('action', 'edit');
                    $('#button-save').data('id', id);

                    dialog.open();
                }
            }

            function getData(id)
            {
                action = $('#button-save').data('action');
                var result = false;
                $.ajax({
                    type: 'POST',
                    url: 'WamResourceController?lib=<%=lib%>&type=<%=type%>&action=data',
                    data: {
                        id: id
                    },
                    success: function (data)
                    {
                        selectedId = id;

                        $('#label').val(data.label);
                        $('select[name="customer_id"]').val(data.customerid);
                        $('select[name="driver_id"]').val(data.driverid);
                        $('input[name=resource]').val(data.resource);
                        $('select[name=time_group_id]').val(data.timeGroupid);
                        $('select[name=depot_id]').val(data.depotid);
                        $('#capacity').val(data.capacity);
                        properties = [];
                        capacityVal = [];
                        blockDate = [];

                        var prop = data.properties;
                        var bd = data.block_dates;

                        var html = '';
                        
                        if (prop) {
                            for (var i = 0; i < prop.length; i++)
                            {
                                html += '<div class="cap-box" id="prop-' + prop[i].propertyid + '">';
                                html += '<div class="single-cap">' + prop[i].property + '</div>';
                                html += '<div class="cap-icon" onclick="removeProperty(' + prop[i].propertyid + ')">' + '</div>';
                                html += '</div>';

                                properties.push(prop[i].propertyid);
                            }
                            document.getElementById('all-prop').innerHTML = html;
                        }

                        html = '';
                        if (bd) {
                            for (var i = 0; i < bd.length; i++)
                            {
                                html += '<div class="cap-box" id="bd-' + bd[i].id + '">';
                                html += '<div class="single-cap">' + bd[i].from + ' to ' + bd[i].to + '</div>';
                                html += '<div class="cap-icon" onclick="removeBlockDate(\'' + bd[i].id + '\')">' + '</div>';
                                html += '</div>';

                                blockDate.push(bd[i].id);
                            }
                        }
                        document.getElementById('all-block-date').innerHTML = html;
                        result = true;
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {

                    },
                    async: false
                });

                return result;
            }

            function showAddProperty()
            {
                $('#add-property').show();
                $('#add-prop-btn').hide();
            }

            function hideAddProperty()
            {
                $('#add-property').hide();
                $('#add-prop-btn').show();
            }

            function hideAddBlockDate()
            {
                $('#add-block-date').hide();
                $('#add-block-btn').show();
            }

            function showAddBlockDate()
            {
                $('#add-block-btn').hide();
                $('#add-block-date').show();
            }

            function addProperty()
            {
                var selectedVal = $('#property').val();

                if (!selectedVal)
                {
                    return;
                }

                for (var i = 0; i < properties.length; i++)
                {
                    if (parseInt(properties[i], 10) === parseInt(selectedVal, 10))
                    {
                        alert('Property has been added');
                        return;
                    }
                }

                properties.push(selectedVal);

                var selectedText = $('#property option:selected').text();

                var html = '<div class="cap-box" id="prop-' + selectedVal + '">';
                html += '<div class="single-cap">' + selectedText + '</div>';
                html += '<div class="cap-icon" onclick="removeProperty(' + selectedVal + ')">' + '</div>';
                html += '</div>';

                $('#all-prop').append(html);

                hideAddProperty();
            }

            function addBlockDate()
            {
                var fromDate = $('#from-date').val();
                var toDate = $('#to-date').val();

                if (fromDate == '' || toDate == '')
                {
                    alert('Please specify both dates.')
                    return;
                }

                var fromDateConv = convertToFormat(fromDate);
                var toDateConv = convertToFormat(toDate);

                var bd = fromDateConv + '-' + toDateConv;

                blockDate.push(bd);

                var html = '<div class="cap-box" id="bd-' + bd + '">';
                html += '<div class="single-cap">' + fromDate + ' to ' + toDate + '</div>';
                html += '<div class="cap-icon" onclick="removeBlockDate(\'' + bd + '\')">' + '</div>';
                html += '</div>';

                $('#all-block-date').append(html);

                hideAddBlockDate();
            }
            function convertToFormat(date)
            {
                var fields = date.split('/');
                var dd = fields[0];
                var mm = fields[1];
                var yyyy = fields[2];

                return yyyy + mm + dd;
            }
            function removeBlockDate(val)
            {
                for (var i = 0; i < blockDate.length; i++)
                {
                    if (blockDate[i] === val)
                    {
                        blockDate.splice(i, 1);
                        break;
                    }
                }

                $("#bd-" + val).remove();
            }

            $(document).on('click', 'div.cap-icon', function (e) {
                e.preventDefault();
                var propertyName = $(this).closest('div.cap-box').find('.single-cap').text();
                for (var i = 0; i < properties.length; i++)
                {
                    if (properties[i] === propertyName)
                    {
                        properties.splice(i, 1);
                        break;
                    }
                }
                $(this).closest('div.cap-box').remove();
            });
        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("resource")%></h1>
        </div>
        <div class="toolbar">
            <%
                if (add || update || delete) {
            %>
            <div class="toolbar-section">
                <%
                    if (add && data.hasAddButton()) {
                %>
                <button class="toolbar-button" id=tool-button-add name="add" value="" title="<%=userProperties.getLanguage("add")%>"><span class="mif-plus"></span></button>
                    <%
                        }

                        if (update && data.hasEditButton()) {
                    %>    <%
                        }

                        if (delete && data.hasDeleteButton()) {
                    %>
                <button class="toolbar-button" id=tool-button-delete name="delete" value="" title="<%=userProperties.getLanguage("delete")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>

                <%
                    if (data.hasDeleteByFilterButton()) {
                %>

                <button class="toolbar-button" id=tool-button-delete-filter name="delete" value="" title="<%=userProperties.getLanguage("deleteByFilter")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>
            </div>
            <%
                }
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" title="<%=userProperties.getLanguage("downloadCSV")%>" onclick="downloadCSVs()"><span class="text-light text-small">CSV</span></button>
                <div class="split-button">
<!--                    <button class="toolbar-button dropdown-toggle" title="<%=userProperties.getLanguage("downloadPDF")%>" style="width: 56px !important"><span class="text-light text-small">PDF</span></button>
                    <ul class="split-content d-menu" data-role="dropdown">
                        <li><a onclick="pdfDownloadBySelection()">Single File From Selection</a></li>
                        <li><a onclick="pdfDownloadByFilter()">Multiple Files From Filter</a></li>
                    </ul>-->
                </div>
            </div>
            <%
                if (userProperties.canAccessView(userProperties.getOperations(Resource.JOB_AUTOSCHEDULING))) {
            %>
            <div class="toolbar-section">

                <button class="toolbar-button" title="Set to Auto-schedule" onclick="showOptimizationOptions()" type="button" style="width: fit-content; padding: 0 5px 0 5px;"><span class="mif-target"></span></button>

            </div>
            <%
                }
            %>

            <%
                if (data.hasCustomFilterButton()) {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" onclick="customFilter()"><span class="mif-search"></span></button>
            </div>
            <%
                }
            %>
        </div>
        <div>
            <%  try {
                    ListFilter listFilter = new ListFilter(5);
            %>
        </div>
        <br>
        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id=result-table>
            <thead>

            </thead>
            <tbody>

            </tbody>
        </table>

        <div data-role="dialog" id=form-dialog class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <%
                                try {
                                    dataHandler.setConnection(userProperties.getConnection());

                                    ListForm listForm = new ListForm();

                                    listForm.outputHtml(userProperties, data, dataHandler, out);
                                } catch (Exception e) {

                                } finally {
                                    dataHandler.closeConnection();
                                }
                            %>

                            <!-- CAPACITY -->
                            <div class="row cells1">
                                <div class="cell">
                                    <label>Capacity</label>
                                    <div class="input-control text full-size">
                                        <input type="text" id="capacity" name="capacity" maxlength="50" placeholder="Capacity" value="" style="font-size: 14px;width: 49%;">
                                    </div>
                                </div>
                            </div>

                            <!-- PROPERTY -->
                            <div class="row cells1">
                                <div class="cell">
                                    <label>Property</label>
                                    <div id="all-prop" style="margin-top: 5px;">
                                    </div>

                                    <div id="add-prop-btn" style="margin-top: 5px;" onclick="showAddProperty()">
                                        <div class="add-box">
                                            <div class="add-icon"></div>
                                            <div class="single-add">Add New</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row cells1" id="add-property">
                                <div class="cell">
                                    <div style="float: left; height: 40px;">
                                        <div class="input-control select" style="float: left; min-width: 0px; ">
                                            <select id ="property" name="property" style="font-size: 18px;">

                                            </select>
                                        </div>

                                        <div style="float: left; margin-left: 10px;">
                                            <div class="confirm-icon" title="Confirm" onclick="addProperty()"></div>
                                            <div class="cancel-icon"  title="Cancel" onclick="hideAddProperty()"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- block date -->
                            <div class="row cells1" style="margin-top: 20px;">
                                <div class="cell">
                                    <label>Blocked Dates</label>
                                    <div id="all-block-date" style="margin-top: 5px;">
                                    </div>

                                    <div id="add-block-btn" style="margin-top: 5px;" onclick="showAddBlockDate()">
                                        <div class="add-box">
                                            <div class="add-icon"></div>
                                            <div class="single-add">Add New</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row cells1" id="add-block-date">
                                <div class="cell">
                                    <div style="float: left; height: 40px;">
                                        <div class="input-control text" style="float: left; min-width: 0px; width: 150px;">
                                            <input id="from-date" style="width: 150px; font-size: 14px;" size="20" maxlength="20" placeholder="From" value="">
                                        </div>

                                        <div style="float: left; margin-left: 10px; margin-right: 10px; line-height: 40px;"> - </div>

                                        <div class="input-control text" style="float: left; min-width: 0px; width: 150px;">
                                            <input id="to-date" style="width: 150px; font-size: 14px;" size="20" maxlength="20" placeholder="To" value="">
                                        </div>

                                        <div style="float: left; margin-left: 10px;">
                                            <div class="confirm-icon" title="Confirm" onclick="addBlockDate()"></div>
                                            <div class="cancel-icon" title="Cancel" onclick="hideAddBlockDate()"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div>
                            <%
                                    data.outputHtml(userProperties, out);

                                    String jspPath = data.outputJsp();

                                    if (!jspPath.equals("")) {
                                        request.setAttribute("properties", userProperties);

                                        pageContext.include(jspPath);
                                    }
                                    //  pageContext.include("job_schedule_optimization_parameters.jsp");
                                } catch (Exception e) {

                                } finally {

                                }
                            %>
                        </div>


                    </form>
                    <div id=sub-type></div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-save type="button" class="button primary" onclick="saveForm()"><%=userProperties.getLanguage("save")%></button>
                <button id=button-cancel type="button" class="button" onclick="closeForm()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>

    </body>
</html>
