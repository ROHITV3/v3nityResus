<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@page import="v3nity.cust.biz.wars.controller.*"%>
<%@page import="v3nity.cust.biz.wars.data.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
    
    String domainUrl = userProperties.getSystemProperties().getDomainURL();

    Locale locale = userProperties.getLocale();

    Connection con = null;

    String lib = "v3nity.cust.biz.wars.data";

    String type = "WarsJobSchedule";

    ListData data = new WarsJobSchedule();

    data.onInstanceCreated(userProperties);

    Data country = null;

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    ListMetaData metaData = null;

    List<MetaData> metaDataList = data.getMetaDataList();

    int metaListSize = metaDataList.size();

    String columnList = "";

    int operations = userProperties.getOperations(data.getResourceId());

    boolean add = userProperties.canAccess(operations, Operation.ADD);

    boolean update = userProperties.canAccess(operations, Operation.UPDATE);

    boolean delete = userProperties.canAccess(operations, Operation.DELETE);

    int formOperations = userProperties.getOperations(Resource.JOB_SCHEDULE_FORM_TEMPLATE);

    boolean addTemplate = userProperties.canAccess(formOperations, Operation.ADD);

    boolean editTemplate = userProperties.canAccess(formOperations, Operation.UPDATE);

    boolean deleteTemplate = userProperties.canAccess(formOperations, Operation.DELETE);

    boolean viewTemplate = userProperties.canAccess(formOperations, Operation.VIEW);

    int pageLength = data.getPageLength();

    DriverTreeView driverTreeView = new DriverTreeView(userProperties);

    JobFormTemplateDropDown formTemplateDropDown = new JobFormTemplateDropDown(userProperties);

    Connection connection = null;

    DriverDropDown driverDropDown = new DriverDropDown(userProperties);

    try
    {
        connection = userProperties.getConnection();

        dataHandler.setConnection(connection);

        driverDropDown.setIdentifier("dropdown-driver");

        driverDropDown.loadData(userProperties);

    }
    catch (Exception e)
    {

    }
    finally
    {
        userProperties.closeConnection(connection);
    }

    int customerId = userProperties.getInt("customer_id");

    try
    {
        for (int i = 0; i < metaListSize; i++)
        {
            metaData = (ListMetaData) metaDataList.get(i);

            // construct the column definition for the data table...
            if (metaData.getViewable())
            {
                if (columnList.length() > 0)
                {
                    columnList += ",";
                }

                columnList += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + "\", \"orderable\": " + metaData.getOrderable() + " }";
            }
        }

        // create the edit column...
        if (update && data.hasEditButton())
        {
            //columnList += ",{ \"data\": \"" + "editButton" + "\", \"title\": \"" + userProperties.getLanguage("edit") + "\", \"orderable\": false }";
        }

        driverTreeView.setIdentifier("filter-driver-schedule");

        driverTreeView.loadData(userProperties);

        formTemplateDropDown.setIdentifier("filter-form-template");

        formTemplateDropDown.loadData(userProperties);

        String countryCode = userProperties.getString("country").toUpperCase();

        CountryDataHandler countryDataHandler = new CountryDataHandler();

        con = userProperties.getConnection();

        countryDataHandler.setConnection(con);

        country = countryDataHandler.get(countryCode);

        //countryDataHandler.closeConnection();
    }
    catch (Exception e)
    {

    }
    finally
    {
        userProperties.closeConnection(con);
    }

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputRecurStartTime = dateTimeFormatter.format(today) + " 00:00:00";

    String inputStartTime = "00:00";

    String inputStartDate = dateTimeFormatter.format(today);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <link href="css/v3nity-timetable.css" rel="stylesheet">
        <style>
            #container {
                width: 100%;
                height: 100%;
                position: relative;
            }

            #map-view {
                position: absolute;
                top: 0;
                left: 0;
            }

            #infoi {
                top: 48px;
                right: 8px;
                z-index: 10;
            }

            .weekly-days , .monthly-checkbox , .specific-day , .specific-week , .monthly-date{
                margin: 15px;
                display: inline-block;
                vertical-align: middle;
                width: 84px;
            }

            #job-summary
            {
                float: left;
                height: 300px;
            }

            #summary-header
            {
                background: #fff;
                max-height: 100px;
                margin-top: 20px;
            }

            #summary-content
            {
                margin-top: 10px;
                height: 300px;
                overflow-y: scroll;
            }

            .singleDate
            {
                float: left;
                background: #437DC6;
                color: #fff;
                width: fit-content;
                padding: 10px;
                margin-right: 5px;
            }

            .dateSelected
            {
                background: #000;
                font-weight: bold;
            }

            .staffSelected
            {
                color: #000000;
                font-weight: bold;
            }

            #reschedule-dialog
            {
                max-height: 600px;
                margin-top: 150px;
            }

        </style>
        <script type="text/javascript" src="js/jszip.min.js"></script>
        <script type="text/javascript" src="js/v3nity-timetable.js"></script>
        <script type="text/javascript">

            var timetableDialogData;

            var csv = new csvDownload('JobScheduleListController?lib=<%=lib%>&type=<%=type%>&action=view', 'V3NITY');

            var totalRecords = -1;

            var requireOverallCount = true;

            var customFilterQuery = [];

            var addTemplate = (<%=(addTemplate) ? "true" : "false"%>);

            var editTemplate = (<%=(editTemplate) ? "true" : "false"%>);

            var deleteTemplate = (<%=(deleteTemplate) ? "true" : "false"%>);

            var viewTemplate = (<%=(viewTemplate) ? "true" : "false"%>);

            var listForm;

            var listFields = [];

            var scheduleData;
            var rescheduleId;
            var viewScheduleId;
            var selected = [];
            var selectedDriver = [];
            var date;
            var map, markerLocation, locationLayer, jobLayer, mapPadding;
            var location_road;
            var location_latitude;
            var location_longitude;
            var locationSearch;
            var reportTemplates;
            var driverIdData;
            var driverData;
            var scheduleDateData;
            var scheduleTimeData;
            var locationData;
            var longitudeData;
            var latitudeData;
            var templateData;
            var jobData;
            var reportDocuments;

            window.METRO_LOCALES = {
                'en': {
                    months: [
                        "<%=userProperties.getLanguage("january")%>", "<%=userProperties.getLanguage("february")%>", "<%=userProperties.getLanguage("march")%>", "<%=userProperties.getLanguage("april")%>", "<%=userProperties.getLanguage("may")%>", "<%=userProperties.getLanguage("june")%>", "<%=userProperties.getLanguage("july")%>", "<%=userProperties.getLanguage("august")%>", "<%=userProperties.getLanguage("september")%>", "<%=userProperties.getLanguage("october")%>", "<%=userProperties.getLanguage("november")%>", "<%=userProperties.getLanguage("december")%>",
                        "<%=userProperties.getLanguage("jan")%>", "<%=userProperties.getLanguage("feb")%>", "<%=userProperties.getLanguage("mar")%>", "<%=userProperties.getLanguage("apr")%>", "<%=userProperties.getLanguage("may")%>", "<%=userProperties.getLanguage("jun")%>", "<%=userProperties.getLanguage("jul")%>", "<%=userProperties.getLanguage("aug")%>", "<%=userProperties.getLanguage("sep")%>", "<%=userProperties.getLanguage("oct")%>", "<%=userProperties.getLanguage("nov")%>", "<%=userProperties.getLanguage("dec")%>"
                    ],
                    days: [
                        "<%=userProperties.getLanguage("sun")%>", "<%=userProperties.getLanguage("mon")%>", "<%=userProperties.getLanguage("tue")%>", "<%=userProperties.getLanguage("wed")%>", "<%=userProperties.getLanguage("thur")%>", "<%=userProperties.getLanguage("fri")%>", "<%=userProperties.getLanguage("sat")%>",
                        "<%=userProperties.getLanguage("su")%>", "<%=userProperties.getLanguage("mo")%>", "<%=userProperties.getLanguage("tu")%>", "<%=userProperties.getLanguage("we")%>", "<%=userProperties.getLanguage("th")%>", "<%=userProperties.getLanguage("fr")%>", "<%=userProperties.getLanguage("sa")%>"
                    ],
                    buttons: [
                        "<%=userProperties.getLanguage("today")%>", "<%=userProperties.getLanguage("clear")%>", "<%=userProperties.getLanguage("cancel")%>", "Help", "Prior", "Next", "Finish"
                    ]
                }
            };

            $(document).ready(function()
            {

                map = null;

                locationSearch = new AddressSearchBox('locationSearch', 1500, locationCallback, <%=(locale.getCountry().equals("SG"))%>);

                locationSearch.enable();

                // bind event for template selection...
                $('select[name=inputFormTemplateName]').on('change', function()
                {

                    $.ajax({
                        type: 'POST',
                        url: 'JobReportController',
                        data: {
                            type: 'system',
                            action: 'template',
                            templateId: $("#inputFormTemplateNameId").val()
                        },
                        beforeSend: function()
                        {

                        },
                        success: function(data)
                        {

                            reportTemplates = data.templates;

                            var html;

                            html += "<option value='0'>- <%=userProperties.getLanguage("jobReportTemplate")%> -</option>";

                            var selected = ' selected'; // use to default select first item...

                            for (var i = 0; i < reportTemplates.length; i++)
                            {

                                var template = reportTemplates[i];

                                html += "<option value='" + template.id + "' " + selected + ">" + template.name + "</option>";

                                selected = '';
                            }

                            document.getElementById('inputReportTemplateNameId').innerHTML = html;


                            reportDocuments = data.documents;

                            html = '';

                            html += "<option value='0'>- <%=userProperties.getLanguage("docFile")%> -</option>";

                            selected = ' selected'; // use to default select first item...

                            for (var i = 0; i < reportDocuments.length; i++)
                            {

                                var doc = reportDocuments[i];

                                html += "<option value='" + doc.document_file_name + "' " + selected + ">" + doc.name + "</option>";

                                selected = '';
                            }

                            document.getElementById('inputDocFileId').innerHTML = html;
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                        },
                        async: false
                    });

                    getForm(this.value);
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
                            url: 'JobScheduleListController?lib=<%=lib%>&type=<%=type%>&format=json&action=view',
                            type: 'POST',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords;
                                d.requireOverallCount = requireOverallCount;
                                d.customFilterQuery = JSON.stringify(customFilterQuery);
                            },
                            beforeSend: function()
                            {
                                $('.toolbar-button').prop("disabled", true);
                            },
                            error: function(xhr, error, thrown)
                            {
                                dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                            },
                            complete: function()
                            {
                                $('.toolbar-button').prop("disabled", false);
                            },
                            dataSrc: function(json)
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
                                    }
                                    else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
                                else
                                {
                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                    json.data = [];
                                }

                                return json.data;
                            }
                        },
                        drawCallback: function(settings)
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
                        createdRow: function(row, data, index)
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
                            processing: 'Retrieving...',
                            zeroRecords: 'No matching records found',
                            paginate: {
                                first: '<<',
                                last: '>>',
                                next: '>',
                                previous: '<'
                            }
                        }

                    });

                // every ajax call, turn off the draw event otherwise,
                // all rows will be selected from the table upon selecting buttons within the table.
                // there is something wrong with the datatable with server side processing.
                tbl.on('xhr', function()
                {

                    // this will turn off the event...
                    tbl.off('draw.dt.dtSelect');

                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });

                $(".schedule-time").AnyTime_picker({format: "%H:%i"});

                $("#recur-start-time").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#timetable-date").AnyTime_picker({format: "%d/%m/%Y"});
                var today = new Date();
                dd = today.getDate();
                if (dd < 10)
                {
                    dd = '0' + dd;
                }
                mm = today.getMonth() + 1;
                if (mm < 10)
                {
                    mm = '0' + mm;
                }
                tt = today.getHours();
                tt = ("0" + tt).slice(-2);
                ss = today.getMinutes();
                yyyy = today.getFullYear();
                var todayDate = dd + '/' + mm + '/' + yyyy;
                var todayFullDate = dd + '/' + mm + '/' + yyyy + ' ' + tt + ':' + ss;
                $("#timetable-date").val(todayDate);
                $(".starting-from").AnyTime_picker({format: "%d/%m/%Y"});
                $(".ending-on").AnyTime_picker({format: "%d/%m/%Y"});

                $("#reschedule-date").AnyTime_picker({
                    earliest: todayFullDate,
                    format: "%d/%m/%Y %H:%i"
                });
            });


            function locationCallback(road, lon, lat)
            {
                location_latitude = lat;

                location_longitude = lon;

                location_road = road;
            }

            function getForm(id)
            {
                if (id === '0')
                {
                    form.clear();
                }
                else
                {
                    $.ajax({
                        type: 'POST',
                        url: 'ListController?lib=v3nity.std.biz.data.plan&type=JobFormTemplate&action=data',
                        data: {
                            id: id
                        },
                        success: function(result)
                        {

                            $.each(result.data, function(i, field)
                            {

                                if (field.name === 'template_data')
                                {
                                    form.setHtml(field.value);
                                }
                            });

                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {

                        },
                        async: false
                    });
                }
            }

            $("#tool-button-add").click(function()
            {
                showAdd();
            });

            $("#tool-button-edit").click(function()
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
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            });

            $("#tool-button-delete").click(function()
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
                            beforeSend: function()
                            {
                                $('#button-save').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.result === true)
                                {
                                    dialog('Success', data.text, 'success');
                                    refreshPageLength();
                                    closeForm();
                                }
                                else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            },
                            error: function()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function()
                            {
                                $('#button-save').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'alert');
                }
            });

            $("#tool-button-copy").click(function()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Only one job can be replicated at a time', 'Please select 1 record to edit', 'alert');
                    }
                    else
                    {
                        var id = data.join();
                        copyJobSchedule(id);
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select 1 record to edit', 'alert');
                }
            });

            function dispose()
            {
                $(".schedule-time").AnyTime_noPicker();
                $("#recur-start-time").AnyTime_noPicker();
                $("#timetable-date").AnyTime_noPicker();
                $(".starting-from").AnyTime_noPicker();
                $(".ending-on").AnyTime_noPicker();
                $("#reschedule-date").AnyTime_noPicker();

                if (map !== null)
                {

                    map.disableDropMarker();

                    map.remove();
                }

//                if (typeof resourceMap !== "undefined" && resourceMap !== null)
//                {
//                    resourceMap.remove();
//                }

                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function(index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            }

            function toggleSelect()
            {
                if ($('#selectAll').hasClass('selected'))
                {
                    $('#result-table').DataTable().button(1).trigger();
                    $('#selectAll').removeClass('selected');
                }
                else
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
                }
                else
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

            function pdfDownloadByFilter()
            {
                var pdf = new pdfDownload('V3NITY');

                var filterQuery = listForm.filter();

                filterQuery.push({field: 'status_id', type: 'Integer', mandatory: 'true', operator: '=', value: <%=JobStatus.ENDED%>});

                pdf.startDownload(1, {customFilterQuery: JSON.stringify(filterQuery)});
            }

            function pdfDownloadBySelection()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var unsortedIds = data.join();
                    var idsInArray = unsortedIds.split(",");
                    idsInArray.sort(function(a, b)
                    {
                        return a - b
                    });
                    var ids = idsInArray.join();
                    var pdf = new pdfDownload('V3NITY');
                    var geotagCheckArray = checkSelectionGeotag(ids);
                    pdf.download(ids, geotagCheckArray);
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record', 'alert');
                }
            }

            function downloadPDF(id)
            {

                var geotagCheck = "E";

                if ($("#input-geotag-pdf-" + id + "").length > 0)
                {
                    if ($("#input-geotag-pdf-" + id + "").is(":checked"))
                    {
                        geotagCheck = "Y";
                    }
                    else
                    {
                        geotagCheck = "N";
                    }
                }

                var pdfdialog = window.open("WarsJobScheduleController?type=plan&action=pdf&id=" + id + "&geotagCheck=" + geotagCheck, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");

                pdfdialog.moveTo(0, 0);

                document.getElementById("downloadPdfButton" + id).style.color = 'white';
                document.getElementById("downloadPdfButton" + id).style.backgroundColor = 'green';
            }

            function downloadDOC(id)
            {
                var geotagCheck = "E";
                var docdialog = window.open("WarsJobScheduleController?type=plan&action=doc&id=" + id );
                document.getElementById("downloadPdfButton" + id).style.color = 'white';
                document.getElementById("downloadPdfButton" + id).style.backgroundColor = 'green';
            }

            function downloadIMG(id)
            {
                var img = new imgDownload('V3NITY_IMG');
                img.download(id);
            }

            function downloadCSVs()
            {
                csv.startDownload(1000, {customFilterQuery: JSON.stringify(listForm.filter())});
            }

            function checkSelectionGeotag(ids)
            {
                var tableId = ids.split(",");
                var geotagCheck = "E";
                var geotagCheckList = [];
                for (var x = 0; x < tableId.length; x++)
                {
                    if ($("#input-geotag-pdf-" + tableId[x] + "").length > 0)
                    {
                        if ($("#input-geotag-pdf-" + tableId[x] + "").is(":checked"))
                        {
                            geotagCheck = "Y";
                        }
                        else
                        {
                            geotagCheck = "N";
                        }
                    }
                    geotagCheckList.push(geotagCheck);
                }
                return geotagCheckList;
            }

            function checkTimePref()
            {
                var aStartTime = '';
                var aEndTime = '';

                for (var i = 0; i < startTimeArr.length; i++)
                {
                    aStartTime = startTimeArr[i];
                    aEndTime = endTimeArr[i];

                    if ((aStartTime != '' && aEndTime == '')
                        || (aStartTime == '' && aEndTime != ''))
                    {
                        return false;
                    }
                }

                return true;
            }

            function saveForm()
            {
                var timePrefValid = checkTimePref();

                if (!timePrefValid)
                {
                    dialog('Error', 'Preferred start and end time cannot be blank.', 'alert');
                    return;
                }

                if (listForm.save())
                {
                    var action = $('#button-save').data('action');
//                    console.log('data: ' + $('#form-dialog-data').serialize());
                    var id = $('#button-save').data('id');

                    if (id === undefined)
                    {
                        id = 0;
                    }

                    $.ajax({
                        type: 'POST',
                        url: 'ListController?lib=<%=lib%>&type=<%=type%>&action=' + action + '&id=' + id,
                        data: $('#form-dialog-data').serialize(),
                        beforeSend: function()
                        {
                            $('#button-save').prop("disabled", true);
                        },
                        success: function(data)
                        {

                            if (data.result === true)
                            {

                                dialog('Success', data.text, 'success');

                                refreshPageLength();

                                closeForm();
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            $('#button-save').prop("disabled", false);
                        },
                        async: false
                    });
                }
                else
                {
                    dialog('Error', listForm.saveError, 'alert');
                }
            }

            function showAdd()
            {
                $('#user_id').val(<%= userProperties.getId()%>);
                var dialog = $('#form-dialog').data('dialog');
                $('#form-dialog-title').html('<%=userProperties.getLanguage("add")%> ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                $('#button-save-optimize').data('action', 'optimize');
                $('#button-save').data('action', 'add');

                $('#inputFormTemplateNameId').prop("disabled", false);
                $('#inputReportTemplateNameId').prop("disabled", false);

                clearForm();

                dialog.open();
            }

            function showEdit_JobSchedule(id)
            {

                if (getData(id))
                {
                    var dialog = $('#form-dialog').data('dialog');
                    $('#form-dialog-title').html('<%=userProperties.getLanguage("edit")%> ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                    $('#button-save').data('action', 'edit');
                    $('#button-save').data('id', id);

                    $('#inputFormTemplateNameId').prop("disabled", true);
                    $('#inputReportTemplateNameId').prop("disabled", true);
                    $('#inputDocFileId').prop("disabled", true);

                    dialog.open();
                }
            }

            function copyJobSchedule(id)
            {

                $.ajax({
                    type: 'POST',
                    url: 'WarsJobScheduleController',
                    data: {
                        type: 'system',
                        action: 'copyscheduledata',
                        scheduleId: id
                    },
                    success: function(data)
                    {
                        dialog('Success', 'Successfully copied Job ID: ' + id, 'success');
                        refreshDataTable();
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }

            function clearForm()
            {
                document.getElementById('form-dialog-data').reset();

                $('#form-dialog-data').find('input[name=duration]').val(10);

                listForm.reset();

                $('#inputFormTemplateNameId option[value=0]').prop('selected', true);

                $('#inputReportTemplateNameId option[value=0]').prop('selected', true);

                $('#inputDocFileId option[value=0]').prop('selected', true);

                listFields.forEach(function(value, index)
                {
                    value.clear();
                });
            }

            function closeForm()
            {

                $('#form-dialog').data('dialog').close();

                clearForm();
            }

            function getData(id)
            {

                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'ListController?lib=<%=lib%>&type=<%=type%>&action=data',
                    data: {
                        id: id
                    },
                    success: function(data)
                    {
                        if (data.expired === undefined)
                        {
                            populateForm(data);

                            listForm.populate(data);

                            result = true;
                        }
//                        else
//                        {
//                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });

                return result;
            }

            function populateForm(result)
            {
                $.each(result.data, function(i, field)
                {
                    if (field.type === 'text')
                    {
                        $('input[name=' + field.name + ']').val(field.value);
                    }
                    else if (field.type === 'selection')
                    {
                        if (field.value === 0)
                        {
                            $('select[name=' + field.name + ']').val('');
                        }
                        else
                        {
                            $('select[name=' + field.name + ']').val(field.value).trigger('change');
                        }
                    }
                    else if (field.type === 'searchable')
                    {
                        $('input[name=' + field.name + ']').val(field.value);

                        $('#list-data-field-' + field.name).val(field.text);
                    }
                    else if (field.type === 'checkbox')
                    {
                        $('input[name=' + field.name + ']').prop('checked', field.value);
                    }
                    else if (field.type === 'html')
                    {

                    }
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

            $("#tool-button-delete-filter").click(function()
            {
                if (customFilterQuery.length > 0 && totalRecords > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'ListController?lib=<%=lib%>&type=<%=type%>&action=deleteByFilter',
                            data: {
                                filterQuery: JSON.stringify(customFilterQuery)
                            },
                            beforeSend: function()
                            {
                                $('#tool-button-delete-filter').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength();

                                        closeForm();
                                    }
                                    else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
//                                else
//                                {
//                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                                }
                            },
                            error: function()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function()
                            {
                                $('#tool-button-delete-filter').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'default');
                }
            });

            function getScheduleData(id)
            {

                $.ajax({
                    type: 'POST',
                    url: 'WarsJobScheduleController',
                    data: {
                        type: 'system',
                        action: 'getscheduledata',
                        scheduleId: id
                    },
                    success: function(data)
                    {

                        driverIdData = data.driverId;
                        driverData = data.driverName;
                        scheduleDateData = data.scheduleDate;
                        scheduleTimeData = data.scheduleTime;
                        locationData = data.location;
                        longitudeData = data.longitude;
                        latitudeData = data.latitude;
                        templateData = data.templateName;
                        jobData = data.jobId;
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }

            function cancelJobSchedule(id)
            {
                var c = confirm("Are you sure you want to cancel the job?");

                if (c === true)
                {

                    $.ajax({
                        type: 'POST',
                        url: 'WarsJobScheduleController',
                        data: {
                            type: 'system',
                            action: 'cancel',
                            scheduleId: id
                        },
                        beforeSend: function()
                        {

                        },
                        success: function(data)
                        {

                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');

                                refreshDataTable();
                            }
                            else
                            {

                                dialog('Failed', text, 'alert');

                                refreshDataTable();
                            }

                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {

                        },
                        async: true
                    });

                }

            }

            function endJobSchedule(id)
            {
                var c = confirm("Are you sure you want to end the job?");

                if (c === true)
                {

                    $.ajax({
                        type: 'POST',
                        url: 'WarsJobScheduleController',
                        data: {
                            type: 'system',
                            action: 'end',
                            scheduleId: id
                        },
                        beforeSend: function()
                        {

                        },
                        success: function(data)
                        {

                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');

                                refreshDataTable();
                            }
                            else
                            {

                                dialog('Failed', text, 'alert');

                                refreshDataTable();
                            }

                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {

                        },
                        async: true
                    });

                }

            }

            function showSchedule(id)
            {
                getScheduleData(id);

                var dialog = $('#schedule-dialog').data('dialog');

                viewScheduleId = id;

                locationSearch.clear();

                location_latitude = latitudeData;

                location_longitude = longitudeData;

                $(".starting-from").val(scheduleDateData);

                $(".schedule-time").val(scheduleTimeData);

                $("#locationText").val(locationData);

                var id = [driverIdData];

                var driverName = [driverData];

                dynamicDriverList(id, driverName);

                $("#select_id").val(driverIdData);

                $('#mutliDriverSelect').find('input[type=checkbox]:checked').removeAttr('checked');

                dialog.open();

            }

             function UnSchedule(id)
	  {
	      viewScheduleId = id;

	      var c = confirm("Are you sure you want to UnSchedule job?");
	      if (c === true)
	      {
		$.ajax({
		    type: 'POST',
		    url: 'WarsJobScheduleController',
		    data: {
		        type: 'system',
		        action: 'unschedulejob',
		        scheduleId: viewScheduleId
		    },
		    beforeSend: function ()
		    {
		        $('#button-save-2').prop('disabled', true);
		    },
		    success: function (data)
		    {

		        var result = data.result;

		        var text = data.text;

		        if (result === true)
		        {

			  dialog('Success', text, 'success');
			  refreshDataTable();
		        } else
		        {
			  dialog('Failed', text, 'alert');
			  refreshDataTable();
		        }


		    },
		    error: function ()
		    {
		        dialog('Error', 'System has encountered an error', 'alert');
		    },
		    complete: function ()
		    {
		        $('#button-save-2').prop('disabled', false);
		    },
		    async: true
		});
	      }
	  }

            $("#mutliDriverSelect").change(function()
            {

                var ids = getTreeId('tree-view-filter-driver-schedule', 'filter-driver-schedule-id').split(',');

                var driverName = getTreeId('tree-view-filter-driver-schedule', 'drivername').split(',');

                dynamicDriverList(ids, driverName);

            }).trigger("change");

            function dynamicDriverList(id, Name)
            {

                if (id)
                {

                    var broadCastId = 0;
                    var broadCast = "Broadcast";

                    var html = '<select id="driver_id">', driverId = id, driverName = Name, i;

                    if (id == "0")
                    {

                        html += "<option value=''></option>";
                        html += "<option value='" + broadCastId + "'>" + broadCast + "</option>";
                        html += '</select>';

                    }
                    else
                    {

                        for (i = 0; i < driverId.length; i++)
                        {

                            html += "<option value='" + driverId[i] + "'>" + driverName[i] + "</option>";

                        }

                        html += "<option value='" + broadCastId + "'>" + broadCast + "</option>";
                        html += '</select>';

                    }


                    document.getElementById('selectDriverDynamic').innerHTML = html;

                }
                else
                {

                    document.getElementById('selectDriverDynamic').innerHTML = "";

                }
            }

            function contains()
            {
                for (var i = 0; i < this.length; i++)
                {
                    if (this[i] === v)
                        return true;
                }
                return false;
            }
            ;

            function checkDistinct()
            {
                var arr = [];
                for (var i = 0; i < this.length; i++)
                {
                    if (!arr.contains(this[i]))
                    {
                        arr.push(this[i]);
                    }
                }
                return arr;
            }

            function showJob(driverId, jobIndex)
            {
                var index = scheduleData.index[driverId];

                var driver = scheduleData.drivers[index];

                if (map === null)
                {
                    initMap();
                }

                map.removeAllSimpleMarker();

                var job = driver.jobs[jobIndex];

                var popupHTML = '<div class="map-marker-popup text-light">' +
                    '<p>' + job.id + '</p>' +
                    '<p>' + driver.name + '</p>' +
                    '<p>' + job.location + '</p>' +
                    '<p>' + job.startDT.fullDate + '</p>' +
                    '<p><span class="job-status ' + job.status.toLowerCase() + '">' + job.status + '</span></p>' +
                    '<button class="button cycle-button" onclick="JobSchedule_showEdit(' + job.id + ')"><span class="mif-pencil"></span></button>&nbsp;' +
                    '<button class="button cycle-button" onclick="downloadPDF(' + job.id + ')"><span class="text-light text-small">PDF</span></button>' +
                    '</div>';

                map.addSimpleMarker(job.latitude, job.longitude, popupHTML);

                map.zoomTo(job.latitude, job.longitude, 18);
            }

            function showJobs(driverId)
            {
                var index = scheduleData.index[driverId];

                var driver = scheduleData.drivers[index];

                if (map === null)
                {
                    initMap();
                }

                map.removeAllSimpleMarker();

                var minLat, maxLat, minLng, maxLng;

                for (var i = 0; i < driver.jobs.length; i++)
                {
                    var job = driver.jobs[i];

                    var popupHTML = '<div class="map-marker-popup text-light">' +
                        '<p>' + job.id + '</p>' +
                        '<p>' + driver.name + '</p>' +
                        '<p>' + job.location + '</p>' +
                        '<p>' + job.startDT.fullDate + '</p>' +
                        '<p><span class="job-status ' + job.status.toLowerCase() + '">' + job.status + '</span></p>' +
                        '<button class="button cycle-button" onclick="JobSchedule_showEdit(' + job.id + ')"><span class="mif-pencil"></span></button>&nbsp;' +
                        '<button class="button cycle-button" onclick="downloadPDF(' + job.id + ')"><span class="text-light text-small">PDF</span></button>' +
                        '</div>';

                    if (minLat === undefined && maxLng === undefined && maxLat === undefined && minLng === undefined)
                    {
                        minLat = job.latitude;
                        maxLat = job.latitude;
                        minLng = job.longitude;
                        maxLng = job.longitude;
                    }
                    else
                    {
                        minLat = Math.min(minLat, job.latitude);
                        maxLat = Math.max(maxLat, job.latitude);
                        minLng = Math.min(minLng, job.longitude);
                        maxLng = Math.max(maxLng, job.longitude);
                    }

                    map.addSimpleMarker(job.latitude, job.longitude, popupHTML);
                }

                map.zoomBound(minLat, minLng, maxLat, maxLng);
            }

            function initTimetable(data)
            {
                var timetable = new Timetable();

                timetable.setScope(0, 0);

                timetable.on('timelineClick', function(e)
                {

                    if (tabId)
                    {
                        selectedTab = tabId;
                    }
                    scheduleTime = $('#schedule-time-' + selectedTab);
                    scheduleTime.val(e.time);

                    startingFrom = $('#starting-from-' + selectedTab);
                    startingFrom.val($("#timetable-date").val());

                    $('#driver_id  option[value=' + e.id + ']').prop("selected", true);
                });

                var drivers = [], htmls = [], html;

                for (var i = 0; i < data.drivers.length; i++)
                {
                    var driver = data.drivers[i];

                    drivers.push(driver.id);

                    if (driver.total > 0)
                    {
                        html = '<div class="timetable-side-label"><div><h4 class="text-light">' + driver.name + '</h4><h6><%=userProperties.getLanguage("completed")%>: ' + driver.completed + ' <%=userProperties.getLanguage("total")%>: ' + driver.total + '</h6></div><button class="button cycle-button" title="View Job" onclick="openMapDialog(); showJobs(' + driver.id + ')"><span class=\"mif-location\"></span></button></div>';
                    }
                    else
                    {
                        html = '<div class="timetable-side-label"><div><h4 class="text-light">' + driver.name + '</h4><h6><%=userProperties.getLanguage("completed")%>: ' + driver.completed + ' <%=userProperties.getLanguage("total")%>: ' + driver.total + '</h6></div></div>';
                    }

                    htmls.push(html);
                }

                timetable.addLocations(drivers, htmls);

                for (var i = 0; i < data.drivers.length; i++)
                {
                    var driver = data.drivers[i];

                    for (var j = 0; j < driver.jobs.length; j++)
                    {
                        var job = driver.jobs[j];

                        var driverId = driver.id;
                        console.log('job.startDT.time: ' + job.startDT.time);
                        console.log('job.status: ' + job.status);
                        console.log('driverId: ' + driverId);
                        console.log('job.startDT.year etc etc: ' + job.startDT.year + ' - '
                            + job.startDT.month + ' - '
                            + job.startDT.day + ' - '
                            + job.startDT.hour + ' - '
                            + job.startDT.minute);
                        console.log('job.endDT.year etc etc: ' + job.endDT.year + ' - '
                            + job.endDT.month + ' - '
                            + job.endDT.day + ' - '
                            + job.endDT.hour + ' - '
                            + job.endDT.minute);
                        console.log('job-status: job-status ' + job.status.toLowerCase());

                        timetable.addEvent(
                            job.startDT.time + ' ' + job.status,
                            driverId,
                            new Date(job.startDT.year, job.startDT.month, job.startDT.day, job.startDT.hour, job.startDT.minute),
                            new Date(job.endDT.year, job.endDT.month, job.endDT.day, job.endDT.hour, job.endDT.minute),
                            '#',
                            'job-status ' + job.status.toLowerCase(),
                            (function(driverId, jobIndex)
                            {

                                return function()
                                {

                                    openMapDialog();

                                    showJob(driverId, jobIndex);
                                };
                            })(driverId, j));
                    }
                }

                var renderer = new Timetable.Renderer(timetable);

                //renderer.draw('.timetable');
                renderer.draw('#timetable');

                $('#timetable').show();
            }

            function viewSchedule()
            {

                var timetableDate = $('#timetable-date').val();

                document.getElementById('timeTableTitle').innerHTML = timetableDate;

                $('#timeTableTitle').show();

                var ids = getTreeId('tree-view-filter-driver-schedule', 'filter-driver-schedule-id');

                if (ids.toString() === "")
                {

                    dialog('Error', 'Please select Staff to view.', 'alert');

                }
                else if (timetableDate === "" || timetableDate === 'undefined' || timetableDate === null)
                {

                    dialog('Error', 'Please select a date.', 'alert');

                }
                else
                {

                    $.ajax({
                        type: 'POST',
                        url: 'WarsJobScheduleController',
                        data: {
                            type: 'system',
                            action: 'get',
                            date: timetableDate,
                            driver: ids.toString()
                        },
                        async: true,
                        success: function(data)
                        {

                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    scheduleData = data;

                                    initTimetable(data);
                                }
                                else
                                {
                                    dialog('Failed', 'System not responding', 'alert');
                                }
                            }
//                            else
//                            {
//                                $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                            }
                        }
                    });

                }
            }

            document.getElementById("defaultOpen").click();

            function recurringSchedule(evt, frequency)
            {
                // Declare all variables
                var i, tabcontent, tablinks;
                // Get all elements with class="tabcontent" and hide them
                tabcontent = document.getElementsByClassName("tabcontent");
                for (i = 0; i < tabcontent.length; i++)
                {
                    tabcontent[i].style.display = "none";
                }

                // Get all elements with class="tablinks" and remove the class "active"
                tablinks = document.getElementsByClassName("tablinks");
                for (i = 0; i < tablinks.length; i++)
                {
                    tablinks[i].className = tablinks[i].className.replace(" active", "");
                }

                // Show the current tab, and add an "active" class to the button that opened the tab
                document.getElementById(frequency).style.display = "block";
                clearScheduleInfo();
                evt.currentTarget.className += " active";

                tabId = frequency;
            }

            function clearScheduleInfo()
            {
                $('.starting-from').val("");
                $('.ending-on').val("");
                $('.recurring').val("");
                $('.schedule-time').val("");
                $(':checkbox[name=weekly]').prop('checked', false);
                $(':checkbox[name=monthly]').prop('checked', false);
                $(':checkbox[name=monthly-date]').prop('checked', false);
                $(':checkbox[name=specific-week]').prop('checked', false);
                $(':checkbox[name=specific-day]').prop('checked', false);
                weeklyDaysArr = new Array();
                monthlyCheckboxArr = new Array();
                monthlyDateArr = new Array();
                specificWkArr = new Array();
                specificDayArr = new Array();
                $('#radio-days').prop('checked', false);
                $('#radio-specific').prop('checked', false);
            }

            function checkForRadio()
            {
                $('#days').css("display", "none");
                $('#specific').css("display", "none");

                if ($('#radio-days').is(':checked'))
                {
                    $(':checkbox[name=specific-week]').prop('checked', false);
                    $(':checkbox[name=specific-day]').prop('checked', false);
                    specificWkArr = new Array();
                    specificDayArr = new Array();
                    $('#days').css("display", "block");

                }
                else
                {
                    $(':checkbox[name=monthly-date]').prop('checked', false);
                    monthlyDateArr = new Array();
                    $('#specific').css("display", "block");
                }
            }

            var weeklyDaysArr = new Array();
            // selected days ( MTWTF )checkbox from weekly tab
            $(':checkbox[name=weekly]').on('change', function()
            {
                var selectedDays = $(this).val();
                if ($(this).is(':checked'))
                {
                    if (weeklyDaysArr.indexOf(selectedDays) == -1)
                    { // -1 means it does not exist in array
                        weeklyDaysArr.push(selectedDays);
                    }
                }
                else
                {
                    if (weeklyDaysArr.indexOf(selectedDays) != -1)
                    {
                        index = weeklyDaysArr.indexOf(selectedDays);
                        weeklyDaysArr.splice(index, 1);
                    }
                }
            });

            var monthlyCheckboxArr = new Array();
            // selected months checkbox from monthly tab
            $(':checkbox[name=monthly]').on('change', function()
            {
                var selectedMth = $(this).val();
                if ($(this).is(':checked'))
                {
                    if (monthlyCheckboxArr.indexOf(selectedMth) == -1)
                    { // -1 means it does not exist in array
                        monthlyCheckboxArr.push(selectedMth);
                    }
                }
                else
                {
                    if (monthlyCheckboxArr.indexOf(selectedMth) != -1)
                    {
                        index = monthlyCheckboxArr.indexOf(selectedMth);
                        monthlyCheckboxArr.splice(index, 1);
                    }
                }
            });

            var monthlyDateArr = new Array();
            // selected date checkbox from monthly tab
            $(':checkbox[name=monthly-date]').on('change', function()
            {
                var selectedDate = $(this).val();
                if ($(this).is(':checked'))
                {
                    if (monthlyDateArr.indexOf(selectedDate) == -1)
                    { // -1 means it does not exist in array
                        monthlyDateArr.push(selectedDate);
                    }
                }
                else
                {
                    if (monthlyDateArr.indexOf(selectedDate) != -1)
                    {
                        index = monthlyDateArr.indexOf(selectedDate);
                        monthlyDateArr.splice(index, 1);
                    }
                }
            });

            var specificWkArr = new Array();
            // selected week checkbox from monthly tab
            $(':checkbox[name=specific-week]').on('change', function()
            {
                var selectedWk = $(this).val();
                if ($(this).is(':checked'))
                {
                    if (specificWkArr.indexOf(selectedWk) == -1)
                    { // -1 means it does not exist in array
                        specificWkArr.push(selectedWk);
                    }
                }
                else
                {
                    if (specificWkArr.indexOf(selectedWk) != -1)
                    {
                        index = specificWkArr.indexOf(selectedWk);
                        specificWkArr.splice(index, 1);
                    }
                }
            });

            var specificDayArr = new Array();
            // selected date checkbox from monthly tab
            $(':checkbox[name=specific-day]').on('change', function()
            {
                var selectedDay = $(this).val();
                if ($(this).is(':checked'))
                {
                    if (specificDayArr.indexOf(selectedDay) == -1)
                    { // -1 means it does not exist in array
                        specificDayArr.push(selectedDay);
                    }
                }
                else
                {
                    if (specificDayArr.indexOf(selectedDay) != -1)
                    {
                        index = specificDayArr.indexOf(selectedDay);
                        specificDayArr.splice(index, 1);
                    }
                }
            });

            function scheduleJob()
            {

                if (map !== null)
                {
                    map.disableDropMarker();
                }

                if (tabId)
                {
                    selectedTab = tabId;
                }

                var dialogSchedule = $('#schedule-dialog').data('dialog');
                var driverSelectedId = $('#driver_id').val();

                var startingDateCheck = false;
                var endingDateCheck = false;
                var validStartDTCheck = false;
                var validDateCheck = false;
                var scheduleTimeCheck = false;
                var recurringCheck = false;
                var recurringLengthCheck = false;
                var weeklyDaysCheck = false;
                var monthlyCheckboxCheck = false;
                var specificCheck = false;
                var monthlyDateCheck = false;
                var radioCheck = false;


                if (selectedTab == "one-time")
                {
                    startingDateCheck = true;
                    scheduleTimeCheck = true;
                    validStartDTCheck = true;

                }
                else if (selectedTab == "daily")
                {
                    validDateCheck = true;
                    startingDateCheck = true;
                    endingDateCheck = true;
                    scheduleTimeCheck = true;
                    recurringCheck = true;
                    recurringLengthCheck = true;
                    validDateCheck = true;
                }
                else if (selectedTab == "weekly")
                {
                    startingDateCheck = true;
                    endingDateCheck = true;
                    scheduleTimeCheck = true;
                    recurringCheck = true;
                    recurringLengthCheck = true;
                    weeklyDaysCheck = true;
                    validDateCheck = true;
                }
                else // monthly
                {
                    startingDateCheck = true;
                    endingDateCheck = true;
                    scheduleTimeCheck = true;
                    monthlyCheckboxCheck = true;

                    if ($('#radio-days').is(':checked'))
                    {
                        monthlyDateCheck = true;
                    }
                    else if ($('#radio-specific').is(':checked'))
                    {
                        specificCheck = true;
                    }
                    else
                    {
                        radioCheck = true;
                    }
                    validDateCheck = true;

                }

                var timetableDate = $('#timetable-date').val();

                var startingFrom = '#starting-from-' + selectedTab;
                var startingDate = $(startingFrom).val();

                var endingOn = '#ending-on-' + selectedTab;
                var endingDate = $(endingOn).val();

                var endingOn = '#ending-on-' + selectedTab;
                var endDate = $(endingOn).val();

                var assignTime = '#schedule-time-' + selectedTab;
                var scheduleTime = $(assignTime).val();

                var recurringNo = '#recurring-' + selectedTab;
                var recurring = $(recurringNo).val();

                if (startingDateCheck)
                {
                    if (startingDate == "" || startingDate == "undefined")
                    {
                        dialog('Error', 'Please Select Starting Date Before Scheduling', 'alert');
                        return;
                    }
                }

                if (endingDateCheck)
                {
                    if (endingDate == "" || endingDate == "undefined")
                    {
                        dialog('Error', 'Please Select Ending Date Before Scheduling', 'alert');
                        return;
                    }
                }

                if (validStartDTCheck)
                {

                    var startYr = startingDate.substring(6);
                    var startMth = startingDate.substring(3, 5);
                    var startDay = startingDate.substring(0, 2);
                    startMth = startMth - 1;
                    var scheduleH = scheduleTime.substring(0, 2);
                    var scheduleM = scheduleTime.substring(3, 5);
                    var startDate = new Date(startYr, startMth, startDay, scheduleH, scheduleM, 0, 0);

                    var todayDate = new Date();

                    if (startDate < todayDate)
                    {
                        dialog('Error', 'Start Date Cannot Occur Before Current Time', 'alert');
                        return;
                    }
                }

                if (validDateCheck)
                {

                    var startYr = startingDate.substring(6);
                    var startMth = startingDate.substring(3, 5);
                    var startDay = startingDate.substring(0, 2);
                    startMth = startMth - 1;
                    var scheduleH = scheduleTime.substring(0, 2);
                    var scheduleM = scheduleTime.substring(3, 5);
                    var startDate = new Date(startYr, startMth, startDay, scheduleH, scheduleM, 0, 0);
                    var todayDate = new Date();

                    if (startDate < todayDate)
                    {
                        dialog('Error', 'Start Date Cannot Occur Before Current Time', 'alert');
                        return;
                    }

                    var endYr = endingDate.substring(6);
                    var endMth = endingDate.substring(3, 5);
                    var endDay = endingDate.substring(0, 2);
                    endMth = endMth - 1;
                    var endDate = new Date(endYr, endMth, endDay, 11, 59, 59, 0);

                    if (startDate > endDate)
                    {
                        dialog('Error', 'Start Date Cannot Occur After End Date ', 'alert');
                        return;
                    }

                    var validYr = startYr + 1;
                    var validDate = new Date(validYr, startMth, startDay, scheduleH, scheduleM, 0, 0);
                    if (endDate > validDate)
                    {
                        dialog('Error', 'Date Range should be within a year', 'alert');
                        return;
                    }

                }

                if (scheduleTimeCheck)
                {
                    if (scheduleTime == "" || scheduleTime == "undefined")
                    {
                        dialog('Error', 'Please Select Schedule Time Before Scheduling', 'alert');
                        return;
                    }
                }

                if (recurringCheck)
                {
                    if (recurring == "" || recurring == "undefined")
                    {
                        dialog('Error', 'Please Type Recurring Frequency Before Scheduling', 'alert');
                        return;
                    }
                }

                if (recurringLengthCheck)
                {
                    if (isNaN(recurring) || recurring.toString().length > 3 || recurring == "0" || recurring % 1 != 0)
                    {
                        dialog('Error', 'Please enter a valid whole number. Numbers are limited to 3 digits.', 'alert');
                        return;
                    }
                }
                if (weeklyDaysCheck)
                {
                    if (weeklyDaysArr.length == 0)
                    {
                        dialog('Error', 'Please Select Day(s) To Recur On Before Scheduling', 'alert');
                        return;
                    }
                }
                if (monthlyCheckboxCheck)
                {
                    if (monthlyCheckboxArr.length == 0)
                    {
                        dialog('Error', 'Please Select Month(s) To Recur On Before Scheduling', 'alert');
                        return;
                    }
                }
                if (specificCheck)
                {
                    if (specificWkArr.length == 0 || specificDayArr.length == 0)
                    {
                        dialog('Error', 'Please Select Which Week(s) and Day(s) To Recur On Before Scheduling', 'alert');
                        return;
                    }
                }
                if (monthlyDateCheck)
                {
                    if (monthlyDateArr.length == 0)
                    {
                        dialog('Error', 'Please Select Which Date To Recur On Before Scheduling', 'alert');
                        return;
                    }
                }
                if (radioCheck)
                {
                    dialog('Error', 'Please Select Date / Weeks and Days To Recur On Before Scheduling', 'alert');
                    return;
                }

                if (driverSelectedId === null || driverSelectedId == '')
                {

                    dialog('Error', 'Please Select a Staff Before Scheduling', 'alert');

                }
                else if (timetableDate === "//")
                {

                    dialog('Error', 'Please Select a Date Before Scheduling', 'alert');

                }
                else
                {

                    if (location_latitude == "" || location_latitude == 'undefined' || location_latitude == null)
                    {

                        location_latitude = "";

                    }

                    if (location_longitude == "" || location_longitude == 'undefined' || location_longitude == null)
                    {

                        location_longitude = "";

                    }

                    weeklyDaysArr = weeklyDaysArr.toString();
                    monthlyCheckboxArr = monthlyCheckboxArr.toString();
                    monthlyDateArr = monthlyDateArr.toString();
                    specificWkArr = specificWkArr.toString();
                    specificDayArr = specificDayArr.toString();
                    $.ajax({
                        type: 'POST',
                        url: 'WarsJobScheduleController',
                        data: {
                            type: 'system',
                            action: 'set',
                            driverId: driverSelectedId,
                            scheduleId: viewScheduleId,
                            location_road: $("#locationText").val(),
                            latitude: location_latitude,
                            longitude: location_longitude,
                            selectedTab: selectedTab,
                            startingDate: startingDate,
                            endingDate: endingDate,
                            scheduleTime: scheduleTime,
                            recurring: recurring,
                            weeklyDaysArr: weeklyDaysArr,
                            monthlyCheckboxArr: monthlyCheckboxArr,
                            monthlyDateArr: monthlyDateArr,
                            specificWkArr: specificWkArr,
                            specificDayArr: specificDayArr,
                            optimizeJob: $("#input-optimize-job").attr('checked')
                        },
                        beforeSend: function()
                        {
                            $('#button-save-2').prop('disabled', true);
                        },
                        success: function(data)
                        {

                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');

                                dialogSchedule.close();

                                $('#timetable').hide();

                                refreshDataTable();
                                clearScheduleInfo();
                            }
                            else
                            {

                                dialog('Failed', text, 'alert');

                                dialogSchedule.close();

                                $('#timetable').hide();

                                refreshDataTable();
                                clearScheduleInfo();
                            }


                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            $('#button-save-2').prop('disabled', false);
                        },
                        async: true
                    });

                }

            }

            function reschedule(id)
            {
                var dialog = $('#reschedule-dialog').data('dialog');

                dialog.open();

                rescheduleId = id;

                getScheduleData(id);

                var driverId = [driverIdData];

                var template = [templateData];

                $('#report-title').html('['+ id +']  '+ template);

                $("#driverList").val(driverId);
            }

            function rescheduleJob()
            {
                var driver = $("#driverList").val();
                var date = $("#reschedule-date").val();

                 $.ajax({
                        type: 'POST',
                        url: 'WarsJobScheduleController',
                        data: {
                            type: 'system',
                            action: 'rescheduleJob',
                            driverId: driver,
                            scheduleId: rescheduleId,
                            scheduleTime: date
                        },
                        beforeSend: function()
                        {
                            $('#button-save-2').prop('disabled', true);
                        },
                        success: function(data)
                        {
                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');

                                closeRescheduleDialog();

                                refreshDataTable();

                            }
                            else
                            {

                                dialog('Failed', text, 'alert');

                                closeRescheduleDialog();

                                refreshDataTable();
                            }
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            $('#button-save-2').prop('disabled', false);
                        },
                        async: true
                    });
            }

            function closeRescheduleDialog()
            {
                var dialog = $('#reschedule-dialog').data('dialog');

                dialog.close();
            }

            function closeDialog()
            {

                var dialog = $('#schedule-dialog').data('dialog');

                dialog.close();

                $('#timetable').hide();

                $('#timeTableTitle').hide();
            }

            function openMapDialog()
            {

                var dialog = $('#location-dialog').data('dialog');

                dialog.open();

                var charm = $("#charmSearch");

                charm.show();
            }

            function dropMarker(enabled)
            {
                if (map === null)
                {
                    initMap();
                }

                if (enabled)
                {
                    map.enableDropMarker(dropMarkerCoordinate, markerLocation);
                }
                else
                {
                    map.disableDropMarker();
                }
            }

            function dropMarkerCoordinate(lat, lon, road)
            {

                var dialog = $('#location-dialog').data('dialog');

                location_latitude = lat;

                location_longitude = lon;

                location_road = road;

                $('#locationText').val(location_road);

                dialog.close();
            }

            function initMap()
            {
                map = new v3nityMap('map-view');

                map.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
            }

            function showOptimizationOptions()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var c = confirm("Add job(s) to Auto-schedule?");

                    if (c === true)
                    {
                        var ids = data.join();

                        $.ajax({
                            type: 'POST',
                            url: 'WarsJobScheduleController',
                            data: {
                                type: 'system',
                                action: 'setoptimize',
                                scheduleId: ids
                            },
                            success: function(data)
                            {

                                var result = data.result;
                                var text = data.text;

                                if (result === true)
                                {
                                    dialog('Success', text, 'success');
                                    refreshDataTable();
                                    clearScheduleInfo();
                                }
                                else
                                {
                                    dialog('Failed', text, 'alert');
                                    refreshDataTable();
                                    clearScheduleInfo();
                                }
                            },
                            error: function()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to optimize', 'alert');
                }
            }
            
            
            function copyLink(theLink)
            {
                navigator.clipboard.writeText();

                dialog('Success', 'Link Copied', 'success');
                
                window.open('<%=domainUrl%>' + theLink, '_blank').focus();
            }

        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage(data.getDisplayName())%></h1>
        </div>
        <div class="toolbar">
            <%
                if (add || update || delete)
                {
            %>
            <div class="toolbar-section">
                <%
                    if (add && data.hasAddButton())
                    {
                %>
                <button class="toolbar-button" id=tool-button-add name="add" value="" title="<%=userProperties.getLanguage("add")%>"><span class="mif-plus"></span></button>
                    <%
                        }

                        if (update && data.hasEditButton())
                        {
                    %>
                <!--<button class="toolbar-button" id=tool-button-edit name="edit" value="" title="<%=userProperties.getLanguage("edit")%>"><span class="mif-pencil"></span></button>-->
                <%
                    }

                    if (delete && data.hasDeleteButton())
                    {
                %>
                <button class="toolbar-button" id=tool-button-delete name="delete" value="" title="<%=userProperties.getLanguage("delete")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>

                <%
                    if (data.hasDeleteByFilterButton())
                    {
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
                <button class="toolbar-button" type="button" title="<%=userProperties.getLanguage("copy")%>" id=tool-button-copy><span class="mif-files-empty"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" title="<%=userProperties.getLanguage("SelectOrUnselect")%>" onclick="toggleSelect()" id=selectAll><span class="mif-table"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" title="<%=userProperties.getLanguage("downloadCSV")%>" onclick="downloadCSVs()"><span class="text-light text-small">CSV</span></button>
                <div class="split-button">
                    <button class="toolbar-button dropdown-toggle" title="<%=userProperties.getLanguage("downloadPDF")%>" style="width: 56px !important"><span class="text-light text-small">PDF</span></button>
                    <ul class="split-content d-menu" data-role="dropdown">
                        <li><a onclick="pdfDownloadBySelection()">Single File From Selection</a></li>
                        <li><a onclick="pdfDownloadByFilter()">Multiple Files From Filter</a></li>
                    </ul>
                </div>
            </div>
            <%
                if (userProperties.canAccessView(userProperties.getOperations(Resource.JOB_AUTOSCHEDULING)))
                {
            %>
            <div class="toolbar-section">

                <button class="toolbar-button" title="Set to Auto-schedule" onclick="showOptimizationOptions()" type="button" style="width: fit-content; padding: 0 5px 0 5px;"><span class="mif-target"></span></button>

            </div>
            <%
                }
            %>

            <%
                if (data.hasCustomFilterButton())
                {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" onclick="customFilter()"><span class="mif-search"></span></button>
            </div>
            <%
                }
            %>
        </div>
        <div>
            <%  try
                {
                    ListFilter listFilter = new ListFilter(5);
            %>
        </div>
        <br>
        <h3 class="text-light"><%=userProperties.getLanguage("searchBy")%></h3>
        <div id="specific-filter" class="grid filter-menu">

            <%                if (data.hasCustomFilterButton())
                {
                    listFilter.outputHtml(data, userProperties, out);
                }
            %>

            <div class="row cells2">
                <div class="cell">
                    <div class="list-show-result-control">
                        <!--<span class="caption"><%=userProperties.getLanguage("show")%></span>-->
                        <div class="input-control text" style="margin: 0">
                            <input id=page-length type="text" value="<%=pageLength%>" maxlength="3">
                            <div class="button-group">
                                <button class="button" id=refresh name="refresh" value="" title="<%=userProperties.getLanguage("refresh")%>" onclick="refreshPageLength()"><span class="mif-loop2"></span></button>
                                <button class="button" id=resetForm name="resetForm" value="" title="<%=userProperties.getLanguage("reset")%>" onclick="resetPageLength()"><span class="mif-undo"></span></button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="cell">
                    <%
                        if (data.hasSearchBox())
                        {
                    %>
                    <div class="list-search-control place-right">
                        <div class="input-control text full-size" style="margin: 0">
                            <input id=search-data type="text" placeholder="<%=userProperties.getLanguage("searchKeyword")%>"/>
                            <button id=searchDataButton class="button" onclick="searchData('search-data')"><span class="mif-search"></span></button>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id=result-table>
            <thead>

            </thead>
            <tbody>

            </tbody>
        </table>

        <div data-role="dialog" id="searching-dialog" class="medium" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light" id="searching-dialog-text"></h1>
                <p id="time-elapsed">Time Elapsed: 0s</p>
                <div class="form-dialog-content" style="margin-top: 150px;">
                    <div class="grid">
                        <div class="row cells1">
                            <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="to-optimize-table">
                                <thead></thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-cancel-searching type="button" class="button" onclick="cancelOptimization()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <div data-role="dialog" id="optimization-result-timetable-dialog" class="large" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <div style="float: left;">
                    <h1 class="text-light">Optimization Result - Resource View</h1>
                </div>
                <div style="float: left; margin-left: 10px;" onclick="switchToJobView()" title="Switch View">
                    <a href="#"><h1 style="padding: 14px"><img src="img/switch.png" style="width: 70%; height: 70%"></h1></a>
                </div>

                <div class="form-dialog-content" style="margin-top: 80px">
                    <div class="grid">
                        <div class="row cells1" id="dates-container"></div>

                        <div class="row cells5">
                            <div class="cell colspan3">
                                <div id="opt-timetable" class="timetable" style="max-height: 600px; overflow-y: scroll"></div>
                            </div>

                            <div class="cell colspan2">
                                <div id="resource-map" style="height: 230px"> </div>

                                <div id="summary-header">
                                    <div class="row cells5">
                                        <div class="cell colspan2">
                                            <h4 id="summary_resource_name" style="margin-top: 5px"></h4>
                                        </div>
                                        <div class="cell"></div>
                                        <div class="cell" style="background: #4b43c6; color: #fff">
                                            <p style="margin: 5px;">distance</p>
                                            <h4 id="summary_total_distance" style="margin: 5px"></h4>
                                        </div>
                                        <div class="cell" style="background: #3cabb2; color: #fff">
                                            <p style="margin: 5px">time</p>
                                            <h4 id="summary_total_time" style="margin: 5px"></h4>
                                        </div>
                                    </div>
                                </div>
                                <div id="summary-content"></div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button type="button" class="button primary" onclick="scheduleOptResult()"><%=userProperties.getLanguage("schedule")%></button>
                <button type="button" class="button" onclick="closeTimetableDialog()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <div data-role="dialog" id="optimization-option-dialog" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Optimization Options</h1>
                <div class="form-dialog-content" style="margin-top: 110px;">
                    <div class="grid">
                        <div class="row cells3">
                            <div class="cell">
                                <div class="input-control checkbox">
                                    <label class="text-bold">
                                        <input type="checkbox" id="optimize_distance" value="optimize_distance"/>
                                        <span class="check"></span>&nbsp; Optimize Distance
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="row cells1">
                            <div class="cell">
                                <p class="text-italic text-light">add description here</p>
                            </div>
                        </div>
                        <br/><br/>

                        <div class="row cells3">
                            <div class="cell">
                                <div class="input-control checkbox">
                                    <label class="text-bold">
                                        <input type="checkbox" id="optimize_availability"/>
                                        <span class="check"></span>&nbsp; Optimize Availability
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="row cells1">
                            <div class="cell">
                                <p class="text-italic text-light">add description here</p>
                            </div>
                        </div>
                        <br/><br/>

                        <div class="row cells1">
                            <div class="cell">
                                <label class="text-bold">Stringent Level</label>
                                <div style="margin-top: 10px;">
                                    <input type="range" id="stringent_level" min="0" max="10" value="5" oninput="changeStringent(this.value)" />
                                    <span id="stringent_label">Moderately Stringent</span>
                                </div>
                            </div>
                        </div>
                        <div class="row cells1">
                            <div class="cell">
                                <p class="text-italic text-light">add description here</p>
                            </div>
                        </div>
                        <br/>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-run-optimization type="button" class="button primary" onclick="runOptimization()"><%=userProperties.getLanguage("runOptimization")%></button>
                <button id=button-cancel-options type="button" class="button" onclick="closeOptimizationOptions()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <div data-role="dialog" id="optimization-result-dialog" class="medium" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <div style="float: left;">
                    <h1 class="text-light">Optimization Result - Job View</h1>
                </div>
                <div style="float: left; margin-left: 10px;" onclick="switchToResourceView()" title="Switch View">
                    <a href="#"><h1 style="padding: 14px"><img src="img/switch.png" style="width: 70%; height: 70%"></h1></a>
                </div>

                <div class="form-dialog-content">
                    <div class="grid">
                        <div class="row cells1">
                            <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="optimization-result-table">
                                <thead></thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-save-optimization type="button" class="button primary" onclick="scheduleOptResult()"><%=userProperties.getLanguage("schedule")%></button>
                <button id=button-cancel-optimization type="button" class="button" onclick="closeOptResult()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <div data-role="dialog" id="schedule-dialog" class="large" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light"><%=userProperties.getLanguage("assignJobSchedule")%></h1>
                <div class="form-dialog-content">
                    <div class="grid">
                        <div class="row cells4">
                            <div class="cell">
                                <h4 class="text-light align-left"><%=userProperties.getLanguage("selectDriver")%></h4>
                                <div id = "mutliDriverSelect" class="treeview-control" style="height:300px;">
                                    <%
                                        driverTreeView.outputHTML(out, userProperties);
                                    %>
                                </div>
                            </div>
                            <div class="cell colspan3">
                                <h3 class="text-light"><%=userProperties.getLanguage("timeTable")%>&nbsp;<span id="timeTableTitle" class="v3-fg-blue"></span></h3>

                                <div class="row cells3">
                                    <div class="cell">
                                        <div class="input-control text full-size" data-role="input">
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="timetable-date" type="text" placeholder="<%=userProperties.getLanguage("selectDate")%>" value="" autocomplete="on">
                                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                    <div class="cell">
                                        <button id="viewSchedule" type="button" class="button" onclick="viewSchedule()"><span class="mif-calendar"></span>&nbsp&nbsp<%=userProperties.getLanguage("viewSchedule")%></button>
                                    </div>
                                </div>
                                <div class="row">
                                    <div id = "timetable" class="timetable"></div>
                                </div>
                                <div class="row cells3">
                                    <div class="cell">
                                        <h4 class="text-light align-left"><%=userProperties.getLanguage("assignDriver")%><span style="color: red; font-weight: bold"> *</span></h4>
                                        <div class="input-control select full-size" id="selectDriverDynamic">

                                        </div>
                                    </div>
                                    <div class="cell">
                                        <h4 class="text-light align-left"><%=userProperties.getLanguage("assignLocation")%></h4>
                                        <div id="locationSearch" class="input-control text full-size" data-role="input">
                                            <input id="locationText" type="text" size="50" placeholder="<%=userProperties.getLanguage("search")%>">
                                            <button class="button" id="location" value="" onclick="openMapDialog();
                                                    dropMarker(true);"><span class="mif-location"></span></button>
                                        </div>
                                    </div>
                                </div>

                                <div class="row cells4">
                                    <h3 class="text-light"><%=userProperties.getLanguage("recurringOptions")%>&nbsp;<span id="timeTableTitle" class="v3-fg-blue"></span></h3>
                                    <div class="tab">
                                        <div class="cell"><button style="width:25%" class="tablinks" onclick="recurringSchedule(event, 'one-time')" id="defaultOpen"><%=userProperties.getLanguage("oneTime")%></button></div>
                                        <div class="cell"><button style="width:25%" class="tablinks" onclick="recurringSchedule(event, 'daily')"><%=userProperties.getLanguage("daily")%></button></div>
                                        <div class="cell"><button style="width:25%" class="tablinks" onclick="recurringSchedule(event, 'weekly')"><%=userProperties.getLanguage("weekly")%></button></div>
                                        <div class="cell"><button style="width:25%" class="tablinks" onclick="recurringSchedule(event, 'monthly')"><%=userProperties.getLanguage("monthly")%></button></div>
                                    </div>
                                </div>

                                <div id="one-time" class="tabcontent">
                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("jobScheduleDT")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="starting-from" id="starting-from-one-time" type="text" placeholder="<%=userProperties.getLanguage("jobScheduleDT")%>" value="<%=inputStartDate%>" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("assignTime")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input id="schedule-time-one-time" class="schedule-time" type="text" placeholder="<%=userProperties.getLanguage("startTime")%>" value="<%=inputStartTime%>" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                                <div id="daily" class="tabcontent">
                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("startingFrom")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="starting-from" id="starting-from-daily" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>

                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("endingOn")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="ending-on" id="ending-on-daily" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("assignTime")%><span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input id="schedule-time-daily" class="schedule-time" type="text" placeholder="<%=userProperties.getLanguage("startTime")%>" value="<%=inputStartTime%>" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <h4 class="text-light align-left"><%=userProperties.getLanguage("recurEvery")%><input type="text" id="recurring-daily" class="recurring"> <%=userProperties.getLanguage("days")%> <span style="color: red; font-weight: bold"> *</span></h4>
                                    </div>

                                </div>

                                <div id="weekly" class="tabcontent" >
                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("startingFrom")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="starting-from" id="starting-from-weekly" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>

                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("endingOn")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="ending-on" id="ending-on-weekly" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("assignTime")%><span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input id="schedule-time-weekly" class="schedule-time" type="text" placeholder="<%=userProperties.getLanguage("startTime")%>" value="<%=inputStartTime%>" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <h4 class="text-light align-left"><%=userProperties.getLanguage("recurEvery")%><input type="text" id="recurring-weekly" class="recurring"> <%=userProperties.getLanguage("weeks")%><span style="color: red; font-weight: bold"> *</span></h4>
                                    </div>

                                    <div class="row">
                                        <h4 class="text-light align-left"><%=userProperties.getLanguage("recurOn")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="mon"/><span class="check"></span>&nbsp; <%=userProperties.getLanguage("mon1")%></label></div>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="tue"/><span class="check"></span>&nbsp; <%=userProperties.getLanguage("tue1")%></label></div>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="wed"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("wed1")%></label></div>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="thu"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("thu1")%></label></div>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="fri"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("fri1")%></label></div>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="sat"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("sat1")%></label></div>
                                        <div class="input-control checkbox"><label class="weekly-days"><input type="checkbox" name="weekly" value="sun"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("sun1")%></label></div>
                                    </div>
                                </div>

                                <div id="monthly" class="tabcontent">
                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("startingFrom")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="starting-from" id="starting-from-monthly" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>

                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("endingOn")%>:<span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input class="ending-on" id="ending-on-monthly" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row cells2">
                                        <div class="cell">
                                            <h4 class="text-light align-left"><%=userProperties.getLanguage("assignTime")%><span style="color: red; font-weight: bold"> *</span></h4>
                                            <div class="input-control text full-size" data-role="input">
                                                <span class="mif-calendar prepend-icon"></span>
                                                <input id="schedule-time-monthly" class="schedule-time" type="text" placeholder="<%=userProperties.getLanguage("startTime")%>" value="<%=inputStartTime%>" autocomplete="on">
                                                <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                            </div>
                                        </div>
                                    </div>

                                    <h4 class="text-light align-left"><%=userProperties.getLanguage("recurOn")%>:<span style="color: red; font-weight: bold"> *</span></h4>

                                    <div class="row">
                                        <h5 class="text-light align-left" style="border-bottom:1px solid #ccc; padding:10px;"><%=userProperties.getLanguage("selectMonth")%>:</h5>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="jan"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("jan")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="feb"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("feb")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="mar"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("mar")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="apr"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("apr")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="may"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("may")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="jun"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("jun")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="jul"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("jul")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="aug"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("aug")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="sep"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("sep")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="oct"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("oct")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="nov"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("nov")%></label></div>
                                        <div class="input-control checkbox"><label class="monthly-checkbox"><input type="checkbox" name="monthly" value="dec"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("dec")%></label></div>
                                    </div>


                                    <div class="row cells4" style="padding:10px;margin-top: 50px;">

                                        <div class="cell">
                                            <div class="input-control radio small-check"><label><input type="radio" name="choose" onclick="checkForRadio()" id="radio-days" /><span class="check"></span> &nbsp; <%=userProperties.getLanguage("days")%></label></div>
                                        </div>

                                        <div class="cell">
                                            <div class="input-control radio small-check"><label><input type="radio" name="choose"  onclick="checkForRadio()" id="radio-specific"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("specific")%></label></div>
                                        </div>
                                        <div class="cell"></div>
                                        <div class="cell"></div>
                                    </div>

                                    <div class="row" style="padding:10px; display:none;" id="specific">
                                        <h5 class="text-light align-left" style="border-bottom:1px solid #ccc; padding:10px;"><%=userProperties.getLanguage("selectWeek")%>:<span style="color: red; font-weight: bold"> *</span></h5>
                                        <div class="input-control checkbox"><label class="specific-week"><input type="checkbox" name="specific-week" value="1"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("first")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-week"><input type="checkbox" name="specific-week" value="2"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("second")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-week"><input type="checkbox" name="specific-week" value="3"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("third")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-week"><input type="checkbox" name="specific-week" value="4"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("fourth")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-week"><input type="checkbox" name="specific-week" value="last"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("last")%></label></div>

                                        <h5 class="text-light align-left" style="border-bottom:1px solid #ccc; padding:10px;"><%=userProperties.getLanguage("selectDay")%>:<span style="color: red; font-weight: bold"> *</span></h5>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="mon"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("mon1")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="tue"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("tue1")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="wed"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("wed1")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="thu"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("thu1")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="fri"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("fri1")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="sat"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("sat1")%></label></div>
                                        <div class="input-control checkbox"><label class="specific-day"><input type="checkbox" name="specific-day" value="sun"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("sun1")%></label></div>
                                    </div>

                                    <div class="row" style="padding:10px; display:none;" id="days">
                                        <h5 class="text-light align-left" style="border-bottom:1px solid #ccc; padding:10px;"><%=userProperties.getLanguage("selectDate")%>:<span style="color: red; font-weight: bold"> *</span></h5>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="1"/><span class="check"></span> &nbsp; 1</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="2"/><span class="check"></span> &nbsp; 2</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="3"/><span class="check"></span> &nbsp; 3</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="4"/><span class="check"></span> &nbsp; 4</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="5"/><span class="check"></span> &nbsp; 5</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="6"/><span class="check"></span> &nbsp; 6</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="7"/><span class="check"></span> &nbsp; 7</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="8"/><span class="check"></span> &nbsp; 8</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="9"/><span class="check"></span> &nbsp; 9</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="10"/><span class="check"></span> &nbsp; 10</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="11"/><span class="check"></span> &nbsp; 11</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="12"/><span class="check"></span> &nbsp; 12</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="13"/><span class="check"></span> &nbsp; 13</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="14"/><span class="check"></span> &nbsp; 14</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="15"/><span class="check"></span> &nbsp; 15</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="16"/><span class="check"></span> &nbsp; 16</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="17"/><span class="check"></span> &nbsp; 17</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="18"/><span class="check"></span> &nbsp; 18</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="19"/><span class="check"></span> &nbsp; 19</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="20"/><span class="check"></span> &nbsp; 20</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="21"/><span class="check"></span> &nbsp; 21</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="22"/><span class="check"></span> &nbsp; 22</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="23"/><span class="check"></span> &nbsp; 23</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="24"/><span class="check"></span> &nbsp; 24</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="25"/><span class="check"></span> &nbsp; 25</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="26"/><span class="check"></span> &nbsp; 26</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="27"/><span class="check"></span> &nbsp; 27</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="28"/><span class="check"></span> &nbsp; 28</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="29"/><span class="check"></span> &nbsp; 29</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="30"/><span class="check"></span> &nbsp; 30</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="31"/><span class="check"></span> &nbsp; 31</label></div>
                                        <div class="input-control checkbox"><label class="monthly-date"><input type="checkbox" name="monthly-date" value="last"/><span class="check"></span> &nbsp; <%=userProperties.getLanguage("last")%></label></div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-dialog-control">
                    <button id=button-save-2 type="button" class="button primary" onclick="scheduleJob()"><%=userProperties.getLanguage("schedule")%></button>
                    <button id=button-cancel-2 type="button" class="button" onclick="closeDialog();
                            dropMarker(false);"><%=userProperties.getLanguage("cancel")%></button>
                </div>
            </div>
        </div>
        <%
            if (userProperties.canAccessView(userProperties.getOperations(Resource.RESCHEDULE_JOB)))
            {
        %>
        <div data-role="dialog" id="reschedule-dialog" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light"><%=userProperties.getLanguage("rescheduleJob")%></h1>
                <div class="form-dialog-content">
                    <h3 id=report-title class="text-light"></h3>
                    <div class="grid">
                        <div class="row cells2">
                            <div class="cell">
                                <h4 class="text-light align-left"><%=userProperties.getLanguage("scheduledTo")%></h4>
                                <div class="input-control select full-size">
                                    <select name="driverList" id="driverList">
                                           <% driverDropDown.outputHTML(out, userProperties);%>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row cells2">
                            <div class="cell">
                            <h4 class="text-light align-left"><%=userProperties.getLanguage("jobScheduleDT")%></h4>
                                <div class="input-control text full-size" data-role="input">
                                    <span class="mif-calendar prepend-icon"></span>
                                    <input id="reschedule-date" type="text" placeholder="<%=userProperties.getLanguage("date")%>">
                                    <button class="button helper-button clear"><span class="mif-cross"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-dialog-control">
                    <button id=button-reschedule type="button" class="button primary" onclick="rescheduleJob()"><%=userProperties.getLanguage("reschedule")%></button>
                    <button id=button-closeReschedule type="button" class="button" onclick="closeRescheduleDialog()"><%=userProperties.getLanguage("cancel")%></button>
                </div>
            </div>
        </div>
        <%
            }
        %>
        <div data-role="dialog" id="location-dialog" class="large" data-close-button="true" data-background="bg-white">
            <div id ="container">
                <div id="map-view" class="map-dialog full-size"></div>
                <ul id="infoi" class="t-menu compact place-right">
                    <li><a href="#" onclick="map.zoomIn()" title="<%=userProperties.getLanguage("zoomIn")%>"><span class="icon mif-plus"></span></a></li>
                    <li><a href="#" onclick="map.zoomOut()" title="<%=userProperties.getLanguage("zoomOut")%>"><span class="icon mif-minus"></span></a></li>
                    <li><a href="#" onclick="map.zoomToDefault()" title="<%=userProperties.getLanguage("zoomDefault")%>"><span class="icon mif-target"></span></a></li>
                </ul>
            </div>
        </div>
        <div data-role="dialog" id=form-dialog class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <%
                                try
                                {
                                    dataHandler.setConnection(userProperties.getConnection());

                                    ListForm listForm = new ListForm();

                                    listForm.outputHtml(userProperties, data, dataHandler, out);
                                }
                                catch (Exception e)
                                {

                                }
                                finally
                                {
                                    dataHandler.closeConnection();
                                }
                            %>
                            <div class="row cells2">
                                <div class="cell">
                                    <label><%=userProperties.getLanguage("jobFormTemplate")%></label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control select full-size">
                                        <select name="inputFormTemplateName" id="inputFormTemplateNameId">
                                            <option value="0">- <%=userProperties.getLanguage("jobFormTemplate")%> -</option>
                                            <%
                                                formTemplateDropDown.outputHTML(out, userProperties);
                                            %>
                                        </select>
                                    </div>
                                </div>
                                <div class="cell">
                                    <label><%=userProperties.getLanguage("jobReportTemplate")%></label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control select full-size">
                                        <select name="inputReportTemplateName" id="inputReportTemplateNameId">
                                            <option value="0">- <%=userProperties.getLanguage("jobReportTemplate")%> -</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row cells2">
                                <div class="cell">
                                    <label><%=userProperties.getLanguage("docFile")%></label>
<!--                                    <span style="color: red; font-weight: bold"> *</span>-->
                                    <div class="input-control select full-size">
                                        <span class="v3-custom-filter v3-custom-prepend-icon"></span><%--UFV5--%>
                                        <select name="inputDocFile" id="inputDocFileId">
                                            <option value="0">- <%=userProperties.getLanguage("docFile")%> -</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div>
                            <%
                                data.outputHtml(userProperties, out);

                                String jspPath = data.outputJsp();

                                if (!jspPath.equals(""))
                                {
                                    request.setAttribute("properties", userProperties);

                                    pageContext.include(jspPath);
                                }
                            %>
                        </div>

                        <div class="grid">
                            <%
                                    pageContext.include("job_schedule_optimization_parameters.jsp");
                                }
                                catch (Exception e)
                                {

                                }
                                finally
                                {

                                }
                            %>
                        </div>
                        </div> <!--somehow need to add this one in prod -->
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
