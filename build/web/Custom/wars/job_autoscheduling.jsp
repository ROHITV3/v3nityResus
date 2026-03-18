<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%  
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    Locale locale = userProperties.getLocale();

    String lib = "v3nity.std.biz.data.plan";
    
    String type = "JobAutoscheduling";

    ListData data = new JobAutoscheduling();

    data.onInstanceCreated(userProperties);

    Data country = null;

    Connection con = null;

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    ListMetaData metaData = null;

    List<MetaData> metaDataList = data.getMetaDataList();

    int metaListSize = metaDataList.size();

    String columnList = "";

    ListForm listForm = new ListForm();

    ListFilter listFilter = new ListFilter(5);

    int operations = userProperties.getOperations(data.getResourceId());
    
    boolean update = userProperties.canAccess(operations, Operation.UPDATE);

    int pageLength = data.getPageLength();

    int customerId = userProperties.getInt("customer_id");

    Data dataToOptimize = new JobScheduleToOptimize();
    List<MetaData> metaDataListToOptimize = dataToOptimize.getMetaDataList();
    int metaListSizeToOptimize = metaDataListToOptimize.size();
    int pageLengthToOptimize = 20;
    String columnListToOptimize = "";
    
    Data dataOptimizationResult = new JobScheduleOptimizationResult();
    List<MetaData> metaDataListOptimizationResult = dataOptimizationResult.getMetaDataList();
    int metaListSizeOptimizationResult = metaDataListOptimizationResult.size();
    int pageLengthOptimizationResult = 20;
    String columnListOptimizationResult = "";

    int COL_JOB_ID = 0;
    int COL_STAFF_NAME = 0;
    int COL_START_TIME = 0;
    int COL_END_TIME = 0;

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
            columnList += ",{ \"data\": \"" + "editButton" + "\", \"title\": \"" + userProperties.getLanguage("edit") + "\", \"orderable\": false }";
        }

        for (int i = 0; i < metaListSizeToOptimize; i++)
        {
            metaData = (ListMetaData) metaDataListToOptimize.get(i);
            // construct the column definition for the data table...
            if (metaData.getViewable())
            {
                if (columnListToOptimize.length() > 0)
                {
                    columnListToOptimize += ",";
                }

                columnListToOptimize += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + "\", \"orderable\": " + metaData.getOrderable() + " }";
            }
        }

        for (int i = 0; i < metaListSizeOptimizationResult; i++)
        {
            metaData = (ListMetaData) metaDataListOptimizationResult.get(i);
            // construct the column definition for the data table...
            if (metaData.getViewable())
            {
                if (columnListOptimizationResult.length() > 0)
                {
                    columnListOptimizationResult += ",";
                }

                columnListOptimizationResult += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + "\", \"orderable\": " + metaData.getOrderable() + " }";

                if (metaData.getFieldName().equals("job_id"))
                {
                    COL_JOB_ID = i;
                }
                else if (metaData.getFieldName().equals("driver"))
                {
                    COL_STAFF_NAME = i;
                }
                else if (metaData.getFieldName().equals("start_time"))
                {
                    COL_START_TIME = i;
                }
                else if (metaData.getFieldName().equals("end_time"))
                {
                    COL_END_TIME = i;
                }

            }
        }

        con = userProperties.getConnection();

        String countryCode = userProperties.getString("country").toUpperCase();

        CountryDataHandler countryDataHandler = new CountryDataHandler();

        countryDataHandler.setConnection(con);

        country = countryDataHandler.get(countryCode);
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
        <link href="css/v3nity-timetable.css?v=${code}" rel="stylesheet">
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
            #button-run-optimization
            {
                background-color: #d46e15; 
                color:#fff; 
                font-weight: bold;
            }
            #dialog-header
            {
                width: 100%; 
                background: #3b6dab; 
                color: #fff; 
                float: left;
            }
            .form-dialog-content.optimize
            {
                margin-top: 75px; 
                margin-left: 0; 
                margin-right: 0;
            }
            #dates-container
            {
               background: #437dc6; 
            }
            #job-summary
            {
                float: left;
                height: 300px;
            }
            #summary
            {
                padding-left: 15px; 
                max-height: 550px;
                overflow-y: scroll;
                border: 1px solid #eeeeee;
            }
            #summary::-webkit-scrollbar 
            {
                width: 0px; 
                background: transparent;
            }
            #summary-content
            {
                margin:5px;
            }
            .panel
            {
               padding-top: 10px; 
            }
            .panel .heading
            {
                background: #437dc6; 
                text-align: center; 
                height: 35px
            }
            .singleDate
            {
                float: left;
                background: #437DC6;
                color: #fff;
                width: fit-content;
                padding: 10px;
            }
            .unassigned
            {
                background: #bc1a1d;
            }

            .dateSelected
            {
                background: #000;
                font-weight: bold;
            }
            
            .staffSelected
            {
                color: #ffffff;
                font-weight: bold;
            }
            .timetable
            {
                max-height: 800px; 
                overflow-y: scroll; 
                border: 1px solid #eeeeee; 
                margin-left: 15px;
            }
            .timetable::-webkit-scrollbar 
            {
                width: 0px; 
                background: transparent;
            }
            .timetable aside li:hover
            {
                background-color: #437DC6;
                position: static;
                font-weight: bold;
            }            
            .timetable aside li.staffSelected
            {
                background-color: #437DC6;
                font-weight: bold;
            }
            .timetable aside a
            {
                color: #383838;
            }
            #collapsible-table
            {
                width:100%; 
                background: #3598db; 
                color: #fff; 
                border-top: solid 2px #fff;
            }
            th
            {
                color: #52677a;
                font-weight: bold;
                text-align: left;
            }
            .job-status
            {
                border-radius: 5px;
            }
            .job-status.selected 
            {
                background-color: #ffa128 !important;
                color: #fff !important;
            }
            .job-status:hover 
            {
                background-color: #ffa128 !important;
            }
            #resource-map
            {
                height: 540px;
            }
            #schedule-alert
            {
                width: auto;
                height: auto;
                padding: 0 50px 25px 50px;
            }
            .slider {
                -webkit-appearance: none;
                width: 100%;
                height: 15px;
                border-radius: 5px;   
                background: #d3d3d3;
                outline: none;
                opacity: 0.7;
                -webkit-transition: .2s;
                transition: opacity .2s;
            }

            .slider::-webkit-slider-thumb {
                -webkit-appearance: none;
                appearance: none;
                width: 25px;
                height: 25px;
                border-radius: 50%; 
                background: #d46e15;
                cursor: pointer;
            }

            .slider::-moz-range-thumb {
                width: 25px;
                height: 25px;
                border-radius: 50%;
                background: #d46e15;
                cursor: pointer;
                
            }
            .container {
              position: relative;
              padding-left: 35px;
              margin-bottom: 12px;
              cursor: pointer;
              -webkit-user-select: none;
              -moz-user-select: none;
              -ms-user-select: none;
              user-select: none;
            }

            .container input {
              position: absolute;
              opacity: 0;
            }

            .checkmark {
              position: absolute;
              top: 0;
              left: 0;
              height: 25px;
              width: 25px;
              background-color: #eee;
              border-radius: 50%;
            }

            .container:hover input ~ .checkmark {
              background-color: #ccc;
            }

            .container input:checked ~ .checkmark {
              background-color: #d46e15;
            }

            .checkmark:after {
              content: "";
              position: absolute;
              display: none;
            }

            .container input:checked ~ .checkmark:after {
              display: block;
            }
            .dialog.small 
            {
                height: 50% !important;
                top: 35% !important;
            }

        </style>
        <script type="text/javascript" src="js/jszip.min.js"></script>
        <script type="text/javascript" src="js/v3nity-timetable.js"></script>
        <script type="text/javascript">
            
            var timetableDialogData;
            
            var csv = new csvDownload('ListController?lib=<%=lib%>&type=<%=type%>&action=view', 'V3NITY');

            var totalRecords = -1;

            var requireOverallCount = true;

            var customFilterQuery = [];

            var listForm;

            var scheduleData;

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

            var attrIdArr = [];


            var toOptTotalRecords = -1;
            var toOptRequireOverallCount = true;
            var toOptCustomFilterQuery = [{"field": "status_id", "type": "Integer", "operator": "IN", "value": ["<%=JobStatus.OPTIMIZE%>"]},
                                {"field": "customer_id", "type": "Integer", "operator": "IN", "value": ["<%=customerId%>"]}];

            var optResultTotalRecords = -1;
            var optResultRequireOverallCount = true;
            var optimizationJobIdArr = [];

            var isOptimizing = false;
            var stringentLevel = 5;
            var optimizationLevel = 2;
            var optimizationEngine = 1;
            var optimizeDistance = false;
            var optimizeSkillset = false;
            var resourceMap;
            var engineArr;

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

            $(document).ready(function() {

                map = null;

                locationSearch = new AddressSearchBox('locationSearch', 1500, locationCallback, <%=(locale.getCountry().equals("SG"))%>);

                locationSearch.enable();

                // bind event for template selection...
                $('select[name=inputFormTemplateName]').on('change', function() {

                    $.ajax({
                        type: 'POST',
                        url: 'JobReportController',
                        data: {
                            type: 'system',
                            action: 'template',
                            templateId: $("#inputFormTemplateNameId").val()
                        },
                        beforeSend: function() {

                        },
                        success: function(data) {

                            reportTemplates = data.templates;

                            var html;

                            html += "<option value='0'>- <%=userProperties.getLanguage("jobReportTemplate")%> -</option>";

                            var selected = ' selected'; // use to default select first item...

                            for (var i = 0; i < reportTemplates.length; i++) {

                                var template = reportTemplates[i];

                                html += "<option value='" + template.id + "' " + selected + ">" + template.name + "</option>";

                                selected = '';
                            }

                            document.getElementById('inputReportTemplateNameId').innerHTML = html;
                        },
                        error: function() {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function() {
                        },
                        async: false
                    });

                    getForm(this.value);
                });

                var tbl = $('#result-table').DataTable(
                        {
                            dom: 'tip',
                            pageLength: <%=pageLength%>,
                            autoWidth: false,
                            deferRender: true,
                            orderClasses: false,
                            order: [[0, 'desc']], // default sort by job id...
                            columns: [<%=columnList%>],
                            serverSide: true,
                            responsive: true,
                            ajax: {
                                url: 'ListController?lib=<%=lib%>&type=<%=type%>&format=json&action=view',
                                type: 'POST',
                                data: function(d) {
                                    d.totalRecords = totalRecords;
                                    d.requireOverallCount = requireOverallCount;
                                    d.customFilterQuery = JSON.stringify(customFilterQuery);
                                
                                },
                                error: function(xhr, error, thrown) {
                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                },
                                dataSrc: function(json) {
                                    var data = json;
                                    if (data.expired === undefined) {
                                        if (data.result === true) {
                                                if (data.data.length === 0) {
                                                    //dialog('No Record', 'No record found', 'alert');
                                                }
                                        }
                                        else {
                                            dialog('Search Failed', data.text, 'alert');
                                            json.data = [];
                                        }
                                    }
                                    else {
                                        $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                        json.data = [];
                                    }

                                    return json.data;
                                }
                            },
                            drawCallback: function(settings) {
                                if (settings.json.errorText !== undefined) {
                                    dialog('Error', settings.json.errorText, 'alert');
                                    return;
                                }
                                // do this so that the total records will not be retrieved from the database again...
                                // greatly increase performance towards retrieving data from datatable...
                                if (tbl !== undefined) {
                                    if (tbl.page.info().recordsTotal === 0 && totalRecords !== -1) {

                                    }
                                    totalRecords = tbl.page.info().recordsTotal;
                                    requireOverallCount = false;
                                }
                            },
                            createdRow: function(row, data, index) {

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
                                info: 'Showing _START_ to _END_ of _TOTAL_ entries ',
                                infoEmpty: 'Showing 0 to 0 of 0 entries',
                                emptyTable: 'No data available',
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
                tbl.on('xhr', function() {

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
                if (dd < 10) {
                    dd = '0' + dd;
                }
                mm = today.getMonth() + 1;
                if (mm < 10) {
                    mm = '0' + mm;
                }
                yyyy = today.getFullYear();
                var todayDate = dd + '/' + mm + '/' + yyyy;
                $("#timetable-date").val(todayDate);
                $(".starting-from").AnyTime_picker({format: "%d/%m/%Y"});
                $(".ending-on").AnyTime_picker({format: "%d/%m/%Y"});



                var tblToOptimize = $('#to-optimize-table').DataTable(
                        {
                            dom: 'rtip',
                            pageLength: <%=pageLengthToOptimize%>,
                            deferRender: true,
                            orderClasses: false,
                            columns: [<%=columnListToOptimize%>],
                            serverSide: true,
                            responsive: true,
                            ajax: {
                                url: 'ListController?lib=<%=lib%>&type=JobScheduleToOptimize&format=json&action=view',
                                type: 'POST',
                                data: function(d) {
                                    d.totalRecords = toOptTotalRecords;
                                    d.requireOverallCount = toOptRequireOverallCount;
                                    d.customFilterQuery = JSON.stringify(toOptCustomFilterQuery);
                                },
                                error: function(xhr, error, thrown) {
                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                },
                                dataSrc: function(json) {

                                    var data = json;
                                    if (data.expired === undefined) {
                                        if (data.result === true) {
                                            if (data.data.length === 0) {
                                                //dialog('No Record', 'No record found', 'alert');
                                            }
                                        }
                                        else {
                                            dialog('Failed', data.text, 'alert');
                                        }
                                    }
                                    else {
                                        $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                        json.data = [];
                                    }

                                    return json.data;
                                }
                            },
                            drawCallback: function(settings) {
                                if (settings.json.errorText !== undefined) {
                                    dialog('Error', settings.json.errorText, 'alert');
                                    return;
                                }

                                if (tblToOptimize !== undefined) {
                                    if (tblToOptimize.page.info().recordsTotal === 0 && toOptTotalRecords !== -1) {
                                        // dialog('No Record', 'No record found', 'alert');
                                    }
                                    toOptTotalRecords = tblToOptimize.page.info().recordsTotal;
                                    toOptRequireOverallCount = false;
                                }
                            },
                            createdRow: function(row, data, index) {

                            },
                            buttons: [
                                'selectNone',
                                'csv'
                            ],
                            info: false,
                            language: {
                                info: 'Showing _START_ to _END_ of _TOTAL_ entries ',
                                infoEmpty: 'Showing 0 to 0 of 0 entries',
                                emptyTable: 'No data available',
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

                tblToOptimize.on('xhr', function() {
                    tblToOptimize.off('draw.dt.dtSelect');
                });


                setTimeout(function() {
                    var tblOptimizationResult = $('#optimization-result-table').DataTable(
                            {
                                dom: 'rtip',
                                pageLength: <%=pageLengthOptimizationResult%>,
                                deferRender: true,
                                orderClasses: false,
                                columns: [<%=columnListOptimizationResult%>],
                                serverSide: true,
                                responsive: true,
                                ajax:
                                        {
                                            url: 'JobScheduleController?lib=<%=lib%>&type=JobScheduleOptimizationResult&format=json&action=optimize',
                                            type: 'POST',
                                            data: function(d) {
                                                d.totalRecords = optResultTotalRecords;
                                                d.requireOverallCount = optResultRequireOverallCount;
                                                d.jobIdArr = optimizationJobIdArr;
                                                d.optimize = isOptimizing;
                                                d.stringentLevel = stringentLevel;
                                                d.optimizationLevel = optimizationLevel;
                                                d.optimizeDistance = optimizeDistance;
                                                d.optimizeSkillset = optimizeSkillset;
                                                d.optimizationEngine = optimizationEngine;
                                            },
                                            error: function(xhr, error, thrown) {
                                                $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                            },
                                            dataSrc: function(json) {
                                                var data = json;
                                                if (data.expired === undefined) {
                                                    if (data.result === true) {
                                                        if (data.data.length === 0) {
                                                            //dialog('No Record', 'No record found', 'alert');
                                                        }
                                                    }
                                                    else {
                                                        //dialog('Failed', data.text, 'alert');
                                                    }
                                                }
                                                else {
                                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                                    json.data = [];
                                                }
                                                
                                                timetableDialogData = json.timetable_data;

                                                return json.data;
                                            }
                                        },
                                drawCallback: function(settings) {
                                    
                                    if (isOptimizing == true) 
                                    {
                                        document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: 0s';
                                        if (searchingIntervalVar != null) {
                                            clearInterval(searchingIntervalVar);
                                        }
                                        $('#searching-dialog').data('dialog').close();

                                        showTimetableDialog();

                                        isOptimizing = false;
                                    }

                                    if (settings.json.errorText !== undefined) {
                                        dialog('Error', settings.json.errorText, 'alert');
                                        return;
                                    }

                                    if (tblOptimizationResult !== undefined) {
                                        if (tblOptimizationResult.page.info().recordsTotal === 0 && optResultTotalRecords !== -1) {
                                            // dialog('No Record', 'No record found', 'alert');
                                        }
                                        optResultTotalRecords = tblOptimizationResult.page.info().recordsTotal;
                                        optResultRequireOverallCount = false;
                                    }
                                },
                                createdRow: function(row, data, index) {

                                },
                                buttons: [
                                    'selectNone',
                                    'csv'
                                ],
                                info: false,
                                language: {
                                    info: 'Showing _START_ to _END_ of _TOTAL_ entries ',
                                    infoEmpty: 'Showing 0 to 0 of 0 entries',
                                    emptyTable: 'No data available',
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

                    tblOptimizationResult.on('xhr', function() {
                        tblOptimizationResult.off('draw.dt.dtSelect');
                    });
                }, 100);


                resourceMap = null;
                
            });

            function locationCallback(road, lon, lat) {
                location_latitude = lat;

                location_longitude = lon;

                location_road = road;
            }

            function getForm(id) {
                if (id === '0') {
                    form.clear();
                }
                else {
                    $.ajax({
                        type: 'POST',
                        url: 'ListController?lib=<%=lib%>&type=JobFormTemplate&action=data',
                        data: {
                            id: id
                        },
                        success: function(result) {

                            $.each(result.data, function(i, field) {

                                if (field.name === 'template_data') {
                                    form.setHtml(field.value);
                                }
                            });

                        },
                        error: function() {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function() {

                        },
                        async: false
                    });
                }
            }


            function dispose() {
                $(".schedule-time").AnyTime_noPicker();
                $("#recur-start-time").AnyTime_noPicker();
                $("#timetable-date").AnyTime_noPicker();
                $(".starting-from").AnyTime_noPicker();
                $(".ending-on").AnyTime_noPicker();

                if (map !== null) {

                    map.disableDropMarker();

                    map.remove();
                }
                
                if (resourceMap !== null) {
                    resourceMap.remove();
                }

                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function(index, elem) {
                    $(elem).AnyTime_noPicker();
                });
            }

            function toggleSelect() {
                if ($('#selectAll').hasClass('selected')) {
                    $('#result-table').DataTable().button(1).trigger();
                    $('#selectAll').removeClass('selected');
                }
                else {
                    $('#result-table').DataTable().button(0).trigger();
                    $('#selectAll').addClass('selected');
                }
            }

            function searchData() {
                var searchText = $('#search-data').val();

                requireOverallCount = true;

                $('#result-table').DataTable().search(searchText).draw();
            }

            function refreshDataTable() {
                requireOverallCount = true;

                refreshPageLength();

            }

            function refreshPageLength() {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength)) {
                    var table = $('#result-table').DataTable();

                    table.page.len(pageLength).draw();
                }
                else {
                    resetPageLength();
                }
            }

            function resetPageLength() {
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

    
            function clearForm() {

                document.getElementById('form-dialog-data').reset();

                $('#form-dialog-data').find('input[name=duration]').val(10);

                listForm.reset();

                $('#inputFormTemplateNameId option[value=0]').prop('selected', true);

                $('#inputReportTemplateNameId option[value=0]').prop('selected', true);
            }

            function closeForm() {

                $('#form-dialog').data('dialog').close();

                clearForm();
            }

            function getData(id) {

                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'ListController?lib=<%=lib%>&type=<%=type%>&action=data',
                    data: {
                        id: id
                    },
                    success: function(data) {

                        if (data.expired === undefined) {
                            populateForm(data);

                            listForm.populate(data);

                            result = true;
                        }
                        else {
                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                        }
                    },
                    error: function() {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function() {

                    },
                    async: false
                });

                return result;
            }

            function populateForm(result) {

                $.each(result.data, function(i, field) {

                    if (field.type === 'text') {
                        $('input[name=' + field.name + ']').val(field.value);
                    }
                    else if (field.type === 'selection') {
                        if (field.value === 0) {
                            $('select[name=' + field.name + ']').val('');
                        }
                        else {
                            $('select[name=' + field.name + ']').val(field.value);
                        }
                    }
                    else if (field.type === 'checkbox') {
                        $('input[name=' + field.name + ']').prop('checked', field.value);
                    }
                    else if (field.type === 'html') {

                    }
                });
            }

            function getScheduleData(id) {

                $.ajax({
                    type: 'POST',
                    url: 'JobScheduleController',
                    data: {
                        type: 'system',
                        action: 'getscheduledata',
                        scheduleId: id
                    },
                    success: function(data) {

                        driverIdData = data.driverId;
                        driverData = data.driverName;
                        scheduleDateData = data.scheduleDate;
                        scheduleTimeData = data.scheduleTime;
                        locationData = data.location;
                        longitudeData = data.longitude;
                        latitudeData = data.latitude;
                    },
                    error: function() {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function() {

                    },
                    async: false
                });
            }
            function cancelOptimize(id){
                var c = confirm("Are you sure you want to remove this job from auto-schedule?");

                if (c === true) {
                $.ajax({
                        type: 'POST',
                        url: 'JobScheduleController',
                        data: {
                            type: 'system',
                            action: 'cancelOptimize',
                            scheduleId: id
                        },
                        beforeSend: function() {

                        },
                        success: function(data) {

                            var result = data.result;

                            var text = data.text;

                            if (result === true) {

                                dialog('Success', text, 'success');

                                refreshDataTable();
                            }
                            else {

                                dialog('Failed', text, 'alert');

                                refreshDataTable();
                            }

                        },
                        error: function() {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function() {

                        },
                        async: true
                    });
                }
            }


     
            function showSchedule(id) {
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

            $("#mutliDriverSelect").change(function() {

                var ids = getTreeId('tree-view-filter-driver-schedule', 'filter-driver-schedule-id').split(',');

                var driverName = getTreeId('tree-view-filter-driver-schedule', 'drivername').split(',');

                dynamicDriverList(ids, driverName);

            }).trigger("change");


            function contains() {
                for (var i = 0; i < this.length; i++) {
                    if (this[i] === v)
                        return true;
                }
                return false;
            }
            ;

            function checkDistinct() {
                var arr = [];
                for (var i = 0; i < this.length; i++) {
                    if (!arr.contains(this[i])) {
                        arr.push(this[i]);
                    }
                }
                return arr;
            }

         

            //document.getElementById("defaultOpen").click();

            function closeDialog() {

                var dialog = $('#schedule-dialog').data('dialog');

                dialog.close();

                $('#timetable').hide();

                $('#timeTableTitle').hide();
            }

            function openMapDialog() {

                var dialog = $('#location-dialog').data('dialog');

                dialog.open();

                var charm = $("#charmSearch");

                charm.show();
            }

            function dropMarker(enabled) {
                if (map === null) {
                    initMap();
                }

                if (enabled) {
                    map.enableDropMarker(dropMarkerCoordinate, markerLocation);
                }
                else {
                    map.disableDropMarker();
                }
            }

            function dropMarkerCoordinate(lat, lon, road) {

                var dialog = $('#location-dialog').data('dialog');

                location_latitude = lat;

                location_longitude = lon;

                location_road = road;

                $('#locationText').val(location_road);

                dialog.close();
            }

            function initMap() {
                map = new v3nityMap('map-view');

                map.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
            }
            
            
            function initResourceMap()
            {   
                resourceMap = new v3nityMap('resource-map');
                
                resourceMap.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
            }

            var optResultDialog;

            function showOptimizationResult() {
                refreshOptimizationResultTable();
            }

            function scheduleOptResult() {
                var table = $('#optimization-result-table').DataTable();
                var rowData;

                var updateSuccess = true;
                var failedJobIds = '';
                var onlyWarehouseJob = true;

                for (var i = 0; i < table.rows().data().length; i++) {
                    rowData = table.row(i).data();

                    $.ajax({
                        type: 'POST',
                        url: 'JobScheduleController?lib=<%=lib%>&type=JobScheduleOptimizationResult&format=json&action=scheduleoptimizedjobs',
                        data: {
                            job_id: rowData[<%=COL_JOB_ID%>],
                            staff_name: rowData[<%=COL_STAFF_NAME%>],
                            start_time: rowData[<%=COL_START_TIME%>]
                        },
                        beforeSend: function() {
                            $('#button-save').prop("disabled", true);
                        },
                        success: function(data) {
                            
                            if (data.success) {
                                customFilter();
                            }
                            else {
                                updateSuccess = false;
                        
                                if (failedJobIds.length > 0) {
                                    failedJobIds += ', ';
                                }
                                if (rowData[<%=COL_JOB_ID%>] !== '0')
                                {
                                    onlyWarehouseJob = false;
                                    
                                    failedJobIds += rowData[<%=COL_JOB_ID%>];
                                }
                            }
                        },
                        error: function() {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function() {
                            $('#button-save').prop("disabled", false);
                        },
                        async: false
                    });
                }

                closeOptResult();
                closeTimetableDialog();

                if (updateSuccess) 
                {
                    dialog('Success', 'All jobs have been scheduled', 'success');
                }
                else if (!updateSuccess && onlyWarehouseJob)
                {
                    dialog('Success', 'All jobs have been scheduled. \nPlease note return trips to warehouse will not be scheduled.', 'success');
                }
                else 
                {
                    //create a permanent alert dialog
                    $('#schedule-alert').data('dialog').open();
                    
                    html  = 'Unable to schedule job(s) ' + failedJobIds + '.</br></br>';
                    html += 'The rest of the jobs are scheduled.';
                    document.getElementById('schedule-alert-info').innerHTML = html;
                }
            }

            function closeOptResult() {
                $('#optimization-result-dialog').data('dialog').close();
            }

            function refreshOptimizationResultTable() {
                optResultRequireOverallCount = true;

                refreshPageLengthOptimizationResultTable();
            }

            function refreshPageLengthOptimizationResultTable() {
                var pageLength = "<%=pageLengthOptimizationResult%>";
                if (isInteger(pageLength)) {
                    var table = $('#optimization-result-table').DataTable();
                    table.page.len(pageLength).draw();
                }
            }


            var searchingDialog;
            var searchingIntervalVar;
            var minutes;
            var seconds;
            var counter;
            var SELECTED_DATE;
            var SELECTED_RESOURCE_ID;
            
            function showOptimizationOptions()
            {
               $('#optimization-option-dialog').data('dialog').open();
               
               $('#optimization_engine0').prop('checked', true);
               
               selectOptimizationEngine();
            }

            function changeIterations(val)
            {
                var value = parseInt(val);
                
                var description='';
                
                if (value < 2)
                {
                    description = 'Less Balanced';
                }
                else if (value > 3)
                {
                    description = 'More Balanced';
                }
                else
                {
                    description = 'Balanced';
                }
                    
                document.getElementById('optimization_label').innerHTML = description;
            }
            
            function closeOptimizationOptions()
            {
                document.getElementById("optimization_level").value = 2;
                document.getElementById('optimization_label').innerHTML = 'Balanced';
                
                $('#optimization-option-dialog').data('dialog').close();
            }
            
            function runOptimization() 
            {
                optimizationLevel = $("#optimization_level").val();
                
                if (engineArr.length > 1)
                {
                    for (var i = 0; i < engineArr.length; i ++)
                    {
                        if($("#optimization_engine" + i).is(':checked'))
                        {
                            optimizationEngine = $("#optimization_engine" + i).val();
                        }
                
                    }
                }
                else if (engineArr.length === 1)
                {
                    optimizationEngine = engineValue;
                }
                else
                {
                    optimizationEngine = 1;
                }
                
                 if($("#optimize_distance").is(':checked'))
                {
                    optimizeDistance = true;
                }
                if($("#optimize_skillset").is(':checked'))
                {
                    optimizeDistance = false;
                    optimizeSkillset = true;
                }
                
                closeOptimizationOptions();
                
                $.ajax({
                    type: 'POST',
                    url: 'JobScheduleController?lib=<%=lib%>&type=JobSchedule&format=json&action=checkcanoptimize',
                    data: '',
                    beforeSend: function() {
                        $('#button-run-optimization').prop("disabled", true);
                    },
                    success: function(data) {

                        if (data.result) {
                            isOptimizing = true;

                            toOptCustomFilterQuery = [{"field": "status_id", "type": "Integer", "operator": "IN", "value": ["<%=JobStatus.OPTIMIZE%>"]},
                                {"field": "customer_id", "type": "Integer", "operator": "IN", "value": ["<%=customerId%>"]}];

                            refreshOptimizeTable();

                            showOptimizingDialog();
                            
                            showOptimizationResult();
                        }
                        else {
                            dialog('Error', 'There are no jobs to optimize', 'alert');
                        }
                    },
                    error: function() {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function() {
                        $('#button-run-optimization').prop("disabled", false);
                    },
                    async: true
                });
            }


            function cancelOptimization() {
                isOptimizing = false;
                document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: 0s';
                clearInterval(searchingIntervalVar);
                $('#searching-dialog').data('dialog').close();
            }

            function refreshOptimizeTable() {
                toOptRequireOverallCount = true;

                refreshPageLengthOptimizeTable();
            }

            function refreshPageLengthOptimizeTable() {
                var pageLength = "<%=pageLengthToOptimize%>";
                if (isInteger(pageLength)) {
                    var table = $('#to-optimize-table').DataTable();
                    table.page.len(pageLength).draw();
                }
            }

            function showOptimizingDialog() {
                document.getElementById('searching-dialog-text').innerHTML = 'Optimizing...';
                searchingDialog = $('#searching-dialog').data('dialog');
                searchingDialog.open();
                minutes = 0;
                seconds = 0;
                counter = 0;

                searchingIntervalVar = setInterval(function() {
                    var searchingText = document.getElementById('searching-dialog-text').innerHTML;
                    if (searchingText == 'Optimizing.......') {
                        searchingText = 'Optimizing..';
                    }
                    document.getElementById('searching-dialog-text').innerHTML = searchingText + '.';
                    counter++;
                    if (counter == 2) {
                        counter = 0;
                        seconds = seconds + 1;

                        if (seconds == 60) {
                            minutes = minutes + 1;
                            seconds = 0;
                        }

                        if (minutes == 0) {
                            document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: ' + seconds + 's';
                        }
                        else {
                            document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: ' + minutes + 'm ' + seconds + 's';
                        }
                    }
                }, 500);
            }
    
            function showTimetableDialog()
            {
                $('#optimization-result-timetable-dialog').data('dialog').open();
                
                initResourceMap();
                
                populateOptDates();
            }
            
            function closeTimetableDialog()
            {
                $('#optimization-result-timetable-dialog').data('dialog').close();
                
                timetableDialogData = null;
                
                if (resourceMap !== null) {
                    resourceMap.remove();
                }
            }
  
            function changeSelectedDate(date)
            {
                $(".singleDate").each(function() {
                    $(this).removeClass('dateSelected');
                });
                
                $('#date_'+date).addClass('dateSelected');
                
                SELECTED_DATE = date;
                
                populateOptTimetable(date, null, null);
                document.getElementById('summary').style.display = "block";
            }
            
            
            function changeSelectedResource(driverId, populate)
            {
                $(".timetable-side-label").each(function() {
                    $(this).removeClass('staffSelected');
                    $(this).parent().parent().parent().removeClass('staffSelected');
                });
                
                
                $('#driver_label_'+driverId).addClass('staffSelected');
                $('#driver_label_'+driverId).parent().parent().parent().addClass('staffSelected');
               
                $('#summary_resource_name').html($('#driver_label_'+driverId).find('h4').html());

                SELECTED_RESOURCE_ID = driverId;
                
                var date= SELECTED_DATE;
                
                if (populate)
                {
                    populateJobDetails();
                }
            }
            
            
            
            function reloadResourceMap(jobsData)
            {
                if (resourceMap === null)
                {
                    resourceMap = new v3nityMap('resource-map');
                }
                
                resourceMap.removeAllSimpleMarker();
                
                var minLat, maxLat, minLng, maxLng;
                
                for (var i = 0; i < jobsData.length; i++) 
                {
                    var job = jobsData[i];
                    
                    if (parseFloat(job.lat, 10) <= 0.0 && parseFloat(job.lon, 10) <= 0.0)
                    {
                        continue;
                    }
                    
                    if (minLat === undefined && maxLng === undefined && maxLat === undefined && minLng === undefined) 
                    {
                        minLat = job.lat;
                        maxLat = job.lat;
                        minLng = job.lon;
                        maxLng = job.lon;
                    }
                    else 
                    {
                        minLat = Math.min(minLat, job.lat);
                        maxLat = Math.max(maxLat, job.lat);
                        minLng = Math.min(minLng, job.lon);
                        maxLng = Math.max(maxLng, job.lon);
                    }
                    
                    var popupHTML = '<div class="map-marker-popup text-light">' +
                            '<p>' + job.start + ' - ' + job.end + '</p>' +
                            '<p>' + job.location + '</p>' +
                            '</div>';

                    resourceMap.addNumberedMarker(job.lat, job.lon, popupHTML, 'green', (i+1), job.location);
                }
                    
                resourceMap.zoomBound(minLat, minLng, maxLat, maxLng);
            }
            
         
            function zoomResourceMap(driverId, jobIndex)
            {
                var driverData;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if(timetableDialogData[i].date == SELECTED_DATE)
                    {
                        driverData = timetableDialogData[i].drivers;
                        break;
                    }
                }
                
                if (driverData.length > 0)
                {
                    for (var i = 0; i < driverData.length; i++) 
                    {
                        var jobs = driverData[i].jobs;
                        var aDriverId = driverData[i].driver_id;
                        
                        if (aDriverId != driverId) continue;
                        
                        if (aDriverId != SELECTED_RESOURCE_ID)
                        {
                            changeSelectedResource(aDriverId, true)
                        }
                        
                        var lat = jobs[jobIndex].lat;
                        var lon = jobs[jobIndex].lon;
                        
                        resourceMap.zoomBound(lat, lon, lat, lon);
                        
                        break;
                    }
                }
            }
            
            function changeSummaryContent(driverId, jobIndex)
            {
                 var driverData;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if(timetableDialogData[i].date == SELECTED_DATE)
                    {
                        driverData = timetableDialogData[i].drivers;
                        break;
                    }
                }
                
                var html = '';
                
                if (driverData.length > 0)
                {
                    for (var i = 0; i < driverData.length; i++) 
                    {
                        var jobs = driverData[i].jobs;
                        var aDriverId = driverData[i].driver_id;
                        
                        if (aDriverId != driverId) continue;
                        
                        if (aDriverId != SELECTED_RESOURCE_ID)
                        {
                            changeSelectedResource(aDriverId, true);
                        }
                        
                    html += '<div class="row cells1">';
                    html += '<div class="cell">';
                    html += '<table class="dataTable striped border bordered hovered no-footer dtr-inline">';
                    html += '<tr><th>Job Id</th><td>' + jobs[jobIndex].jobId + '</td></tr>';
                    html += '<tr><th>Scheduled Time</th><td>' + jobs[jobIndex].start + ' - ' + jobs[jobIndex].end + '</td></tr>';
                    if(jobs[jobIndex].description !== null)
                    {
                        html += '<tr><th>Description</th><td>' + jobs[jobIndex].description + '</td></tr>';
                    }
                    if(jobs[jobIndex].reference !== "")
                    {
                        html += '<tr><th>Reference</th><td>' + jobs[jobIndex].reference + '</td></tr>';
                    }
                    if (jobs[jobIndex].location !== null)
                    {
                        html += '<tr><th>Location</th><td>' + jobs[jobIndex].location + '</td></tr>';
                    }
                    if (jobs[jobIndex].capacity !== null)
                    {
                        html += '<tr><th>Capacity</th><td>' + jobs[jobIndex].capacity + '</td></tr>';
                    }
                    html += '<tr><th>Duration (Mins)</th><td>' + jobs[jobIndex].duration + '</td></tr>';
                    html += '</table></div>';
                    html += '</div>';
                
                    document.getElementById('summary_total_distance').innerHTML = jobs[jobIndex].distance;
                    document.getElementById('summary_total_time').innerHTML = jobs[jobIndex].time;    
                }
                document.getElementById('summary-content').innerHTML = html;   
                
            }
        }
            
            
            function populateJobDetails()
            {
                var jobsData;
                var totalDistance;
                var totalTime;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if (timetableDialogData[i].date == SELECTED_DATE)
                    {
                        for (var j = 0 ; j < timetableDialogData[i].drivers.length ; j++)
                        {
                            if (timetableDialogData[i].drivers[j].driver_id == SELECTED_RESOURCE_ID)
                            {
                                totalDistance = timetableDialogData[i].drivers[j].total_distance;
                                totalTime = timetableDialogData[i].drivers[j].total_time;
                                jobsData = timetableDialogData[i].drivers[j].jobs;
                                break;
                            }
                        }
                        break;
                    }
                }
                
                var html = '';
                
                for (var i = 0 ; i < jobsData.length ; i++)
                {
                    var job = jobsData[i];
                    
                    if (i > 0)
                    {
                        html += '<div class="row cells1" style="background: #ddd;"';
                            if (parseFloat(job.distance, 10) >= 0.0)
                            {
                                html += '<div class="cell"><center> ' + job.distance + ', ' + job.time + '</center></div>';
                            }
                            else
                            {
                                html += '<div class="cell">&nbsp &nbsp';
                            }
                        html += '</div>';
                    }
                    
                    html += '<div class="row cells1">';
                        html += '<div class="cell">';
                            html += '<h5>' + '[' + (i+1) + '] ' + job.start + ' - ' + job.end + '</h5>';
                            if (job.location == null)
                            {
                                html += '<p><i>---location not specified--</i></p>';
                            }
                            else
                            {
                                html += '<p>' + job.location + '</p></br>';
                            }
                        html += '</div>';
                    html += '</div>';
                }
                
                document.getElementById('summary_total_distance').innerHTML = totalDistance;
                document.getElementById('summary_total_time').innerHTML = totalTime;
                document.getElementById('summary-content').innerHTML = html;

                reloadResourceMap(jobsData);
            }
            
            
            function populateOptDates()
            {
                var html = "";
                var unassignedData = null;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    html += '<a href="#">';
                    
                    html += '<div class="singleDate" id="date_' + timetableDialogData[i].date 
                            + '" onclick="changeSelectedDate(\'' + timetableDialogData[i].date + '\')">' + timetableDialogData[i].date_formatted + '</div>';
                        
                    html += '</a>';
                    
                    if (typeof timetableDialogData[i].unassigned !== 'undefined')
                    { 
                        unassignedData = timetableDialogData[i].unassigned;

                        html += '<a href="#">';

                        html += '<div class="singleDate unassigned" id="date_' + timetableDialogData[i].date + '_unassigned"'
                                + 'onclick="showUnassignedJobs(\''+ timetableDialogData[i].date + '\')">' + timetableDialogData[i].date_formatted + ' Unassigned Jobs</div>';

                        html += '</a>';
                    }
                }
                
                document.getElementById('dates-container').innerHTML = html;
                
                changeSelectedDate(timetableDialogData[0].date);
            }
            
            
            
            function populateOptTimetable(selectedDate, driverIndex, jobIndex)
            {
                var driverData;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if(timetableDialogData[i].date === selectedDate)
                    {
                        driverData = timetableDialogData[i].drivers;
                        break;
                    }
                }
                
                if (driverData.length > 0)
                {
                    var timetable = new Timetable();

                    timetable.setScope(7, 23);

                    var drivers = [], htmls = [], html;

                    for (var i = 0; i < driverData.length; i++) 
                    {
                        drivers.push(driverData[i].driver_id);

                        html = '<a href="#"><div class="timetable-side-label"'
                                    + 'id="driver_label_' + driverData[i].driver_id + '" '
                                    + 'onclick="clickSideBar(\'' + driverData[i].driver_id + '\');"><div>'
                                    + '<h4 class="text-bold">' + driverData[i].resource_name + '</h4>'
                                    + '<h6>Jobs: ' + driverData[i].jobs.length + '</h6>'
                                    + '</div></div></a>';
                        htmls.push(html);
                    }
                    
                    timetable.addLocations(drivers, htmls);
                    
                    for (var i = 0; i < driverData.length; i++) 
                    {
                        var jobs = driverData[i].jobs;
                        var driverId = driverData[i].driver_id;
                        
                        for (var j = 0 ; j < jobs.length ; j++)
                        {
                            var job = jobs[j];
                            
                            var startTime = job.start.split(':');
                            var endTime = job.end.split(':');

                            if(driverId===driverIndex && j===jobIndex)
                            {
                                timetable.addEvent
                                   (
                                       job.location,
                                       driverId,
                                       new Date(1970, 0, 1, startTime[0], startTime[1]),
                                       new Date(1970, 0, 1, endTime[0], endTime[1]),
                                       '#',
                                       'job-status selected',
                                       (function(driverId, jobIndex) {
                                           return function() {

                                           };
                                       })(driverId, j)
                                   );
                            }
                            else
                            {
                                timetable.addEvent
                                (
                                    job.location,
                                    driverId,
                                    new Date(1970, 0, 1, startTime[0], startTime[1]),
                                    new Date(1970, 0, 1, endTime[0], endTime[1]),
                                    '#',
                                    'job-status ' + job.status,
                                    (function(driverId, jobIndex) {
                                        return function() {
                                            zoomResourceMap(driverId, jobIndex);
                                            changeSummaryContent(driverId, jobIndex);
                                            populateOptTimetable(selectedDate, driverId, jobIndex);
                                            changeSelectedResource(driverId, false);
                                        };
                                    })(driverId, j)
                                );
                            }
                        }
                    }
                    
                    var renderer = new Timetable.Renderer(timetable);

                    renderer.draw('#opt-timetable');

                    $('#opt-timetable').show();
                    
                    if (driverIndex === null & jobIndex === null)
                    {
                        changeSelectedResource(driverData[0].driver_id, true);
                    }
                }
            }
           
           function clickSideBar(driverId)
           {
               populateOptTimetable(SELECTED_DATE, null, null);
               changeSelectedResource(driverId, true);
           }
            
   
           function showUnassignedJobs(date)
           {
               $(".singleDate").each(function() {
                    $(this).removeClass('dateSelected');
                });
                
                $("#date_"+date+"_unassigned").addClass('dateSelected');
               
               var unassignedData = null;
               
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if (timetableDialogData[i].date === date)
                    {
                        unassignedData = timetableDialogData[i].unassigned;
                    }
                }
        
                var html = '';
                html += '<div class="help-tag" style="margin: 10px"><p>Note: Unassigned jobs will not be scheduled.</p></div>';
                html += '<div class="unassigned-table" style="margin: 20px">';
                html += '<h2 class="text-light">' + unassignedData.length + ' Unassigned Job(s)</h2>' ;
                html += '<table class="dataTable striped border bordered hovered no-footer dtr-inline">';
                    html += '<thead>';
                        html += '<tr>';
                            html += '<th class="sortable-column">Index</th>';
                            html += '<th class="sortable-column">Job Id</th>';
                            html += '<th class="sortable-column">Description</th>';
                            html += '<th class="sortable-column">Location</th>';
                            html += '<th class="sortable-column">Time Preferences</th>';
                            html += '<th class="sortable-column">Capacity</th>';
                            html += '<th class="sortable-column">Duration(Mins)</th>';
                        html += '</tr>';
                    html += '</thead><tbody>';
                
                var ind = 1;
                for (var i = 0 ; i < unassignedData.length ; i++)
                {
                    var job = unassignedData[i];
                    
                        html += '<tr>';
                            html += '<td>' + ind + "</td>";
                            html += '<td>' + job.jobId + "</td>";
                            html += '<td>' + job.description + "</td>";
                            html += '<td>' + job.location + "</td>";
                            html += '<td>' + job.timePrefStart + " - " + job.timePrefEnd + "</td>";
                            html += '<td>' + job.capacity + "</td>";
                            html += '<td>' + job.duration + "</td>";
                        html += '</tr>';
                        ind ++;

                }
                html += '</tbody></table></div>';
                
                reloadResourceMap(unassignedData);
                document.getElementById('opt-timetable').innerHTML = html;
                document.getElementById('summary').style.display = "none";
        }

        var engineValue;

        function selectOptimizationEngine()
        {
            $.ajax({
                   type: 'POST',
                   url: 'JobScheduleController',
                   data: {
                       type: 'system',
                       action: 'getOptimizationEngine'
                   },
                   success: function(data) {
   
                        engineArr = data.engine;
                        
                   },

                   error: function() {
                       //dialog('Error', 'System has encountered an error', 'alert');
                   },
                   complete: function() {

                   },
                   async: false
               });
               
            var html = '';
            
            if (engineArr.length > 1)
            {
                html +='<div class="row cells1" style="margin-top:50px;">';
                html +='<label class="text-bold">Optimization Engine</label>';
                html +='<div class="help-tag"><p>Select the optimization engine to use.</p></div>';
                html +='<div class="input-control radio big-check" style="margin-top:30px;">';
                
                for(var i = 0; i < engineArr.length; i++)
                {
                    var engineId = engineArr[i].id;
                    var engineName = engineArr[i].name;

                    html += '<label class="container" style="margin-right: 20px">';
                    html += '<input type="radio" name="optimization_engine" id="optimization_engine' + i + '" value="' + engineId + '"/>';
                    html += '<span class="checkmark"></span>&nbsp;' + engineName;
                    html += '</label>';
                }    
                html += '</div></div>';
            }
            else if (engineArr.length === 1)
            {
                engineValue = engineArr[0].id;
            }
            
            document.getElementById('optimization_table_check').innerHTML = html;
            
        }
   
        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("jobAutoscheduling")%></h1>
        </div>
         <div class="help-tag">
            <h4>Instructions:</h4>
            <p>To add jobs for auto-scheduling, select jobs in <b>Plan - Job Schedule</b> page. </p>
            <p>Click the  <span class="mif-target"></span> button to set for auto-schedule. </p>
            <p>Jobs set to auto-schedule listed below: </p>
        </div>
        <div class="toolbar">
         
<!--            <div class="toolbar-section">
                <button class="toolbar-button" title="<%=userProperties.getLanguage("SelectOrUnselect")%>" onclick="toggleSelect()" id=selectAll><span class="mif-table"></span></button>
            </div>-->

            <div class="toolbar-section">
                <button type="button" class="button"  style="background-color: #d46e15; color:#fff; font-weight: bold;" onclick="showOptimizationOptions()" title= "Autoschedule Jobs" > Auto-schedule Jobs </button>
            </div>
           
            <%
                if (data instanceof IDeviceSynchronizable)
                {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" title="<%=userProperties.getLanguage("deviceSync")%>" onclick="deviceSync()" id=button-deviceSync><span class="mif-embed"></span></button>
            </div>
            <%
                }
            %>
        </div>
        <div>
            <%  try
                {
                    con = userProperties.getConnection();

                    dataHandler.setConnection(con);

                    data.outputFilteringHtml(userProperties, out);

            %>
        </div>
        <br>
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

        <div data-role='dialog' id="optimization-option-dialog" class="small" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Optimization Options</h1>
                <div class="form-dialog-content" style="margin-top: 110px;">

                    <div class="row cells1">
                        <div class="cell">
                            <label class="text-bold">Workload balancing</label>
                            <div class="slidecontainer" style= "margin-top: 50px;">
                                <input type="range" id="optimization_level" min="1" max="4" value="2" class="slider" oninput="changeIterations(this.value)">
                                <span id="optimization_label">Balanced</span>
                            </div>
                        </div>
                    </div>
                   
                    <div id="optimization_table_check"></div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-run-optimization button type="button" class="button" onclick="runOptimization()"><%=userProperties.getLanguage("runOptimization")%></button>
                <button id=button-cancel-options type="button" class="button" onclick="closeOptimizationOptions()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>
                
        <div data-role="dialog" id="searching-dialog" class="tiny" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light" id="searching-dialog-text"></h1>
                <p id="time-elapsed">Time Elapsed: 0s</p>
                <img src="img/loader.gif" alt="Loader" style="width:128px; height:128px; margin: 80px">
<!--            <div class="form-dialog-control">
                <button id=button-cancel-searching type="button" class="button" style="margin-top: 14px" onclick="cancelOptimization()"><%=userProperties.getLanguage("cancel")%></button>
            </div>-->
        </div>
        </div>
            
        <div data-role="dialog" id="optimization-result-timetable-dialog" class="large" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog" style="padding:0">
                <div id="dialog-header">
                    <h1 class="text-light" style="margin-left:16px; padding-bottom: 0">Optimization Result</h1>
                </div>
   
                <div class="form-dialog-content optimize">
                    <div class="grid condensed" style="margin-top: 0">
                    
                     <div class="row cells" id="dates-container"></div>
                     
                        <div class="row cells12" style="margin-top: 10px">
                            <div class="cell colspan10">
                                <div id="opt-timetable" class="timetable"></div>
                            </div>

                            <div class="cell colspan2" id="summary">

                                <div class="panel collapsible collapsed" data-role="panel">
                                    <div class="heading">
                                        <span class="title" id="summary_resource_name"></span>
                                    </div>

                                    <div class="content" style="padding: 0">
                                        <table id="collapsible-table">
                                            <tr>
                                                <th style="color: #fff; padding: 5px; width: 50%;">DISTANCE</th>
                                                <th style="color: #fff; padding: 5px; width: 50%; border-left: solid 2px #fff;">TRAVEL TIME</th>
                                            </tr>
                                            <tr>
                                                <td ><h4 id="summary_total_distance" style="text-align:center; margin-bottom: 0"></h4></td>
                                                <td style="border-left: solid 2px #fff;"><h4 id="summary_total_time" style="text-align:center; margin-bottom: 0"></h4></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            
                            <div id="summary-content"></div>
                        </div>
                    </div>

                        <div class="row cells5" style="padding-top: 15px"> 
                            <div id="resource-map"> </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button type="button" class="button primary" onclick="scheduleOptResult()"><%=userProperties.getLanguage("schedule")%></button>
                <button type="button" class="button" onclick="closeTimetableDialog()"><%=userProperties.getLanguage("cancel")%></button>
            </div>
        </div>
            
    
                      
       <div data-role="dialog" id="optimization-result-dialog" class="medium" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
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
        </div>
            
        
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
                
        <div data-role="dialog" id="schedule-alert" class="dialog alert" data-close-button="true" data-type="alert">
            <h1>Error</h1>
            <div id ="schedule-alert-info"></div>
        </div>
                
        <div data-role="dialog" id=form-dialog class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <%
                                listForm.outputHtml(userProperties, data, dataHandler, out);
                            %>
                          
                        </div>

                        <div>
                            <%
                                data.outputHtml(userProperties, out);

                                String jspPath = data.outputJsp();

                                if (!jspPath.equals(""))
                                {
                                    request.setAttribute("user", userProperties);

                                    pageContext.include(jspPath);
                                }
                            %>
                        </div>

                        <div class="grid">
                            <%
 
                                }
                                catch (Exception e)
                                {

                                }
                                finally
                                {
                                    userProperties.closeConnection(con);
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
