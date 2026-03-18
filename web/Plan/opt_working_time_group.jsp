<%@page import="v3nity.cust.biz.controller.OSTJobSchedule"%>
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

    String type = "OptWorkingTimeGroup";

    ListData data = new OptWorkingTimeGroup();

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
            .fromtime,.totime{
                height: 2.125rem;
                width: 23% !important;
                border: 1px #d9d9d9 solid;
                margin: 3px;
                padding: 8px;
                cursor: text;
                font: 400 13.3333px Arial;
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

            $(document).ready(function ()
            {
                listForm = new ListForm('specific-filter');

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
                                url: 'WorkingTimeGroupController?lib=<%=lib%>&type=<%=type%>&format=json&action=view',
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
            });

            function getForm(id)
            {
                if (id === '0')
                {
                    form.clear();
                } else
                {
                    $.ajax({
                        type: 'POST',
                        url: 'ListController?lib=v3nity.std.biz.data.plan&type=JobFormTemplate&action=data',
                        data: {
                            id: id
                        },
                        success: function (result)
                        {

                            $.each(result.data, function (i, field)
                            {

                                if (field.name === 'template_data')
                                {
                                    form.setHtml(field.value);
                                }
                            });

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
                }
            }

            $("#tool-button-add").click(function ()
            {
                properties = [];
                showAdd();
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
                            url: 'ListController?lib=<%=lib%>&type=<%=type%>&action=delete',
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
                $('div[type="add-button"').hide();
                $('.all-data').html('');

                listForm.reset();
            }

            function closeForm()
            {
                $('#form-dialog').data('dialog').close();

                clearForm();
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
                var timesArray;
                var dayName, fromToTimes, cVal, cValNext;
                var timesObject = {},timesMainObject = {};
                
                var checkedBoxes = $("input[type='checkbox']:checked");
                for (var i = 0; i < checkedBoxes.length; i++)
                {
                    timesArray = [],
                    dayName = checkedBoxes[i].name;

                    fromToTimes = $('#all-data-' + dayName + " input[type='time']");
                    var time2dArr, timeSortArr = [];
                    for (var j = 0; j < fromToTimes.length; j += 2)
                    {
                        cVal = fromToTimes[j].value;
                        cValNext = fromToTimes[j + 1].value;
                        if(parseInt(cVal)>parseInt(cValNext)){//check if start time greater than end time
                            dialog('Time error', 'Time slot ' + cVal +' should not greater than ' + cValNext, 'alert');
                            return false;
                        }
                        timesObject = {fromTime: cVal, toTime: cValNext};
                        timesArray.push(timesObject);

                        time2dArr = [cVal, cValNext];
                        timeSortArr.push(time2dArr);
                    }
                    timeSortArr.sort();
                    for (let k = 0; k < timeSortArr.length - 1; k++) { //to check time overlapping
                        const thisEndTime = timeSortArr[k][1];
                        const nextStartTime = timeSortArr[k + 1][0];
                        if (thisEndTime > nextStartTime) {
                            dialog('Time overlap', 'Time slot ' + nextStartTime + '-' + timeSortArr[k + 1][1] + ' overlaps ' + timeSortArr[k][0] + '-' + thisEndTime, 'alert');
                            return false;
                        }
                    }
                    timesMainObject[dayName] = timesArray;
                }

                action = $('#button-save').data('action');

                $.ajax({
                    type: 'POST',
                    url: 'WorkingTimeGroupController?lib=<%=lib%>&type=<%=type%>&action=' + action,
                    data: {
                        selectedId: selectedId,
                        customerId: $('select[name="customer_id"]').val(),
                        groupName: $('input[name="time_group"]').val(),
                        timeMap: JSON.stringify(timesMainObject)
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

            function showAdd()
            {
                selectedId = 0;
                $('#user_id').val(<%= userProperties.getId()%>);
                var dialog = $('#form-dialog').data('dialog');
                $('#form-dialog-title').html('<%=userProperties.getLanguage("add")%> ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                $('#button-save').data('action', 'add');
                clearForm();
                dialog.open();
            }

            function showEdit_OptWorkingTimeGroup(id)
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
                    url: 'WorkingTimeGroupController?lib=<%=lib%>&type=<%=type%>&action=data',
                    data: {
                        id: id
                    },
                    success: function (data)
                    {
                        var daytimedata = data.daytimedata;
                        var appendHtml = '';

                        $('select[name=customer_id]').val(data.customerid).trigger('change');
                        $('input[name=time_group]').val(data.groupname);
                        //  $('#input[name=time_group]' + prop[i].id).prop('checked', true);

                        for (var i = 0; i < daytimedata.length; i++)
                        {
                            $('input[name=' + daytimedata[i].day + ']').prop('checked', true);
                            appendHtml = '';
                            appendHtml += '<div class="from-to-div">';
                            appendHtml += 'From:<input type="time" class="fromtime" value=' + daytimedata[i].startTime + '> To:<input type="time" class="totime" value=' + daytimedata[i].endTime + '>';
                            appendHtml += '<button id="delete-slot" class="button">remove</button>';
                            appendHtml += '</div>';
                            $('#all-data-' + daytimedata[i].day).append(appendHtml);
                            $('#' + daytimedata[i].day).show();
                        }
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

            $('input[type="checkbox"]').click(function () {
                var name = $(this).prop("name");
                if ($(this).prop("checked") == true) {
                    $('#' + name).show();
                } else if ($(this).prop("checked") == false) {
                    $('#' + name).hide();
                    $('#all-data-' + name).html('');
                }
            });

            function  createNewSlot(obj) {
                var appendHtml = '';
                appendHtml += '<div class="from-to-div" id="preferredTime-' + obj + '">';
                appendHtml += 'From:<input type="time" class="fromtime"> To:<input type="time" class="totime">';
                appendHtml += '<button id="delete-slot" class="button">remove</button>';
                appendHtml += '</div>';
                // var text1 = $('<div/>').addClass('from-to-div').html('From:<input type="textbox" class="fromtime"> To:<input type="textbox" class="totime">').append($('<button/>').addClass('remove').text('Remove')).insertBefore(this);
                // var className = $(this).attr('class');
                $('#all-data-' + obj).append(appendHtml);
            }
            $(document).on('click', 'button#delete-slot', function (e) {
                e.preventDefault();
                $(this).closest('div.from-to-div').remove();
            });

        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("WorkingTimeGroup")%></h1>
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
                    %>
                <!--<button class="toolbar-button" id=tool-button-edit name="edit" value="" title="<%=userProperties.getLanguage("edit")%>"><span class="mif-pencil"></span></button>-->
                <%
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

        <div data-role="dialog" id=form-dialog class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
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
                            <div class="row cells1" style="margin-top: 40px;display: grid;">
                                <label><%=userProperties.getLanguage("workingTimes")%></label>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Monday">
                                        <span class="check"></span><span class="caption"> Mon</span>
                                    </label>
                                    <div id="all-data-Monday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Monday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
                                    <!--                                    <div id="mon" class="add-time-btn" style="margin-top: 5px;display: none; cursor: pointer;">
                                                                            <div class="add-box">
                                                                                <div class="add-icon"></div>
                                                                                <div class="single-add">Add New</div>
                                                                            </div>
                                                                        </div>-->
                                </div>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Tuesday">
                                        <span class="check"></span><span class="caption"> Tue</span>
                                    </label>
                                    <div id="all-data-Tuesday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Tuesday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
                                </div>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Wednesday">
                                        <span class="check"></span><span class="caption"> Wed</span>
                                    </label>
                                    <div id="all-data-Wednesday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Wednesday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
                                </div>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Thursday">
                                        <span class="check"></span><span class="caption"> Thu</span>
                                    </label>
                                    <div id="all-data-Thursday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Thursday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
                                </div>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Friday">
                                        <span class="check"></span><span class="caption"> Fri</span>
                                    </label>
                                    <div id="all-data-Friday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Friday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
                                </div>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Saturday">
                                        <span class="check"></span><span class="caption"> Sat</span>
                                    </label>
                                    <div id="all-data-Saturday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Saturday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
                                </div>
                                <div class="cell">
                                    <label class="input-control checkbox"><input type="checkbox" name="Sunday">
                                        <span class="check"></span><span class="caption"> Sun</span>
                                    </label>
                                    <div id="all-data-Sunday" class="all-data">
                                    </div>
                                    <div type="add-button" id="Sunday" class="button" onclick="createNewSlot(this.id)" style="display:none">Add Time Slot</div>
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
