<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@page import="v3nity.cust.biz.resus.data.*"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    String domainUrl = userProperties.getSystemProperties().getDomainURL();

    int userId = userProperties.getUser().getId();

    Locale locale = userProperties.getLocale();

    Connection con = null;

    String lib = "v3nity.cust.biz.resus.data";

     String type = "ResusQuotationTrack2";

    ListData data = new ResusQuotationTrack2();

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

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputRecurStartTime = dateTimeFormatter.format(today) + " 00:00:00";

    String inputStartTime = "00:00";

    String inputStartDate = dateTimeFormatter.format(today);

    ResusCustomerDropDown resusCustomerDropDown = new ResusCustomerDropDown(userProperties);
    resusCustomerDropDown.setIdentifier("dropdown-resus-customer");
    resusCustomerDropDown.loadData(userProperties);

    ResusQuotationDescDropDown resusQuotationDescDropDown = new ResusQuotationDescDropDown(userProperties);
    resusQuotationDescDropDown.setIdentifier("dropdown-quotation-desc");
    resusQuotationDescDropDown.loadData(userProperties);

    ResusQuotationContactPsnDropDown resusQuotationContactPsnDropDown = new ResusQuotationContactPsnDropDown(userProperties);
    resusQuotationContactPsnDropDown.setIdentifier("dropdown-quotation-contactPsn");
    resusQuotationContactPsnDropDown.loadData(userProperties);

    ResusQuotationTypeDropDown resusQuotationTypeDropDown = new ResusQuotationTypeDropDown(userProperties);
    resusQuotationTypeDropDown.setIdentifier("dropdown-quotation-type");
    resusQuotationTypeDropDown.loadData(userProperties);

    ResusAuthoriserDropDown resusAuthoriserDropDown = new ResusAuthoriserDropDown(userProperties);
    resusAuthoriserDropDown.setIdentifier("dropdown-resus-authoriser");
    resusAuthoriserDropDown.loadData(userProperties);

    Connection connection = null;

    try {
        connection = userProperties.getConnection();
        dataHandler.setConnection(connection);
    } catch (Exception e) {

    } finally {
        userProperties.closeConnection(connection);
    }

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

        }
    } catch (Exception e) {

    }


%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <%            data.outputScriptHtml(out);
        %>
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

            .cap-box{
                float: left;
                height: 30px;
                padding: 3px;

                border-radius: 5px;
                background: #87CEFA;
                margin-right: 5px;
                margin-top: 3px;
            }

            .single-cap{
                float: left;
                height: 20px;
                line-height: 20px;
                font-size: 14px;
                margin-left: 3px;
            } 

            .cap-icon{
                float: left;
                width: 20px;
                height: 20px;
                margin-left: 5px;

                background: url("img/bin.png") no-repeat;
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

            .single-add{
                float: left;
                height: 20px;
                line-height: 20px;
                font-size: 14px;
                font-weight: bold;

                margin-left: 3px;
                margin-right: 5px;
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

            select:invalid { color: gray; }

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

            label{
                font-size: 16px;
                font-weight: bold;
            }

            .waste-type{
                margin-right: 10px;
            }

            .waste-type .caption{
                font-size: 12px;
            }

            .column {
                float: left;
                width: 50%;
                padding: 10px;
            }

            * {
                box-sizing: border-box;
                font-family: "Arial";
            }
            .wrapper-dropdown {
                position: relative;
                width: 200px;
                background: #FFF;
                color: #2e2e2e;
                outline: none;
                cursor: pointer;
            }
            .wrapper-dropdown > span {
                width: 100%;
                display: block;
                border: 1px solid #ababab;
                padding: 5px;
            }
            .wrapper-dropdown > span > span {
                padding: 0 12px;
                margin-right: 5px;
            }
            .wrapper-dropdown > span:after {
                content: "";
                width: 0;
                height: 0;
                position: absolute;
                right: 16px;
                top: calc(50% + 4px);
                margin-top: -6px;
                border-width: 6px 6px 0 6px;
                border-style: solid;
                border-color: #2e2e2e transparent;
            }

            .wrapper-dropdown .dropdown {
                position: absolute;
                z-index: 10;
                top: 100%;
                left: 0;
                right: 0;
                background: #fff;
                font-weight: normal;
                list-style-type: none;
                padding-left: 0;
                margin: 0;
                border: 1px solid #ababab;
                border-top: 0;
            }

            .wrapper-dropdown .dropdown li {
                display: block;
                text-decoration: none;
                color: #2e2e2e;
                padding: 5px;
                cursor: pointer;
            }

            .wrapper-dropdown .dropdown li > span {
                padding: 0 12px;
                margin-right: 5px;
            }

            .wrapper-dropdown .dropdown li:hover {
                background: #eee;
                cursor: pointer;
            }

            .container_quotation_update_status {
                position: relative;
                width:1200px;
                height:120px;
                padding-top:20px;
                padding-right:15px;
            } 

            .container_list_number_filter {
                position: relative;
                padding-top:20px;
                padding-right:15px;
            } 

            .float-left{
                float:left; 
            }

            .float-right{
                float:right; 
            }

            #close_quotation{
                float:left;
            }

            #reject_quotation{
                float:left;
                padding-left:15px;
            }
            #follow_up_quotation{
                float:left;
                padding-left:15px;
            }


        </style>
        <script type="text/javascript" src="js/jszip.min.js"></script>
        <script type="text/javascript" src="js/v3nity-timetable.js"></script>
        <script type="text/javascript">
            console.log('User : ' + <%=userProperties.getUser().getId()%>);
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
            var operators = [];
            var date;
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
            var customerDetails;
            var dataSpreadsheet;
            var quotationDescTable;
            var quotationDescFormatPdfTable;
            var spreadsheetHeaderDataString = JSON.stringify([""]);
            var spreadsheetColWidthDataString = JSON.stringify(["100"]);
            var spreadsheetDataString = JSON.stringify([[""]]);
            var spreadsheetDataFormatPdfString = JSON.stringify([[""]]);
            var tncTable;
            var tncSpreadsheetDataString = JSON.stringify([[""]]);
            var grandTotalAmount = 0;
            var postalCode;
            var quotationRevision = 0;
            var quotationStatusTypeId = 0;
            var onQuotationDataRetrieveBgString;
            var onQuotationDataRetrieveBg = [];

            $("#dateTimePicker-date-start-id").AnyTime_picker({format: "%d/%m/%Y"});
            $("#dateTimePicker-date-end-id").AnyTime_picker({format: "%d/%m/%Y"});

            $(document).ready(function ()
            {
                $("#dateTimePicker-enforcement-date").AnyTime_picker({
                    format: "%d/%m/%Y"
                            //earliest: (new Date()).getTime(),
                            //latest: (new Date()).getTime() + 604800000      // 7 days...
                });

                $("#dateTimePicker-warrant-date").AnyTime_picker({
                    format: "%d/%m/%Y"
                            //earliest: (new Date()).getTime(),
                            //latest: (new Date()).getTime() + 604800000      // 7 days...
                });

                listForm = new ListForm('specific-filter');
                // bind event for template selection...
                $('select[name=dropdownCustomer]').on('change', function ()
                {
                    console.log("Onchange customer : " + $('select[name=dropdownCustomer]').val());
                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: 'getCustomerDetails',
                            resusCustomerId: $('select[name=dropdownCustomer]').val()
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            $('input[name=customerName]').val(data.name);
                            $('input[name=attention_to]').val(data.attentionTo);
                            $('input[name=designation]').val(data.designation);
                            $('textarea[name=address]').val(data.address);
                            $('textarea[name=email]').val(data.email);
                            postalCode = data.postalCode;
                            console.log('postalCode : ' + postalCode);

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
                });

                $('select[name=selectDescriptionTemplate]').on('change', function ()
                {
                    console.log("Onchange customer : " + $('select[name=selectDescriptionTemplate]').val());
                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: 'getQuotationDescription',
                            quotationDescId: $('select[name=selectDescriptionTemplate]').val()
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            document.getElementById('GT').innerHTML = 'Grand Total : $0.00';
                            console.log('header' + data.header);
                            console.log('width' + data.width);
                            console.log('data' + data.data);
                            console.log('footer' + data.footer);

                            //deconstruct header to generate column data
                            let noOfColumn = data.header.split(",");
                            //console.log('noOfColumn' + noOfColumn.length);
                            let jsonColumnBuilder = [];
                            let columnObj = new Object();
                            for (let i = 0; i < noOfColumn.length; i++) {
                                //console.log('Data' + noOfColumn[i]);
                                columnObj.type = 'text';
                                if (noOfColumn[i].includes('$')) {
                                    columnObj.mask = '$ #,##.00';
                                }
                                jsonColumnBuilder[i] = columnObj;
                                columnObj = {};
                            }
                            //console.log('Final columnBuilder : ' + JSON.stringify(jsonBuilder));

                            if (quotationDescTable !== undefined) {
                                quotationDescTable.destroy();
                            }
                            quotationDescTable = jspreadsheet(document.getElementById('spreadsheet'), {
                                colHeaders: JSON.parse(data.header),
                                colWidths: JSON.parse(data.width),
                                columns: jsonColumnBuilder,
                                data: JSON.parse(data.data),
                                type: 'text',
                                wordWrap: true,
                                columnSorting: false,
                                allowInsertRow: true,
                                allowManualInsertRow: false,
                                allowInsertColumn: true,
                                allowManualInsertColumn: false,
                                copyCompatibility: false,
                                onchange: calculateGradTotal,
                                onselection: selectionActive
                            });
                            //quotationDescTable.refresh();
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
                });

                $('select[name=quotationType]').on('change', function ()
                {
                    console.log("Onchange quotation type : " + $('select[name=quotationType]').val());
                });

                // bind event for area selection...
                $('select[name=selectAuthoriser]').on('focus', function ()
                {
                    console.log('selectAuthoriser');
                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: 'getBDByAmount',
                            amount: grandTotalAmount
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {

                            let bdData = data.bduser;

                            var html;

                            html += "<option value='0'>- Select BD -</option>";

                            //var selected = ' selected'; // use to default select first item...

                            for (var i = 0; i < bdData.length; i++)
                            {

                                var bdName = bdData[i];

                                html += "<option value='" + bdName.id + "'" + ">" + bdName.name + "</option>";

                                //selected = '';
                            }

                            document.getElementById('selectAuthoriserId').innerHTML = html;
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
                            // ADD THESE LINES FOR MULTIPLE SORTING:
                            orderMulti: true,  // Enable multiple column sorting
                            orderFixed: [],    // No fixed columns
                            ajax: {
                                url: 'ResusQuotationListController?lib=<%=lib%>&type=<%=type%>&format=json&action=view',
                                type: 'POST',
                                data: function (d)
                                {
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
                tbl.on('xhr', function ()
                {

                    // this will turn off the event...
                    tbl.off('draw.dt.dtSelect');

                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });

                setTimeout(function ()
                {
                    getUserList();
                }, 200);

                //Not in use?
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

            function quotation_description_load()
            {
                console.log('quotation_description_load');

                //deconstruct header to generate column data
                let noOfColumnForMask = spreadsheetHeaderDataString.split(",");
                //console.log('noOfColumn' + noOfColumn.length);
                let jsonColumnBuilder = [];
                let columnObj = new Object();
                for (let i = 0; i < noOfColumnForMask.length; i++) {
                    //console.log('Data' + noOfColumn[i]);
                    if (noOfColumnForMask[i].includes('(From)')) {
                        columnObj.type = 'calendar';
                    } else if (noOfColumnForMask[i].includes('(To)')) {
                        columnObj.type = 'calendar';
                    } else if (noOfColumnForMask[i].includes('$')) {
                        columnObj.type = 'text';
                        columnObj.mask = '$ #,##.00';
                    } else {
                        columnObj.type = 'text';
                    }
                    jsonColumnBuilder[i] = columnObj;
                    columnObj = {};
                }
                console.log('Final columnBuilder');
                console.log(JSON.stringify(jsonColumnBuilder));

                quotationDescTable = jspreadsheet(document.getElementById('spreadsheet'), {
                    colHeaders: JSON.parse(spreadsheetHeaderDataString),
                    colWidths: JSON.parse(spreadsheetColWidthDataString),
                    columns: jsonColumnBuilder,
                    data: JSON.parse(spreadsheetDataString),
                    type: 'text',
                    wordWrap: true,
                    columnSorting: false,
                    allowInsertRow: true,
                    allowManualInsertRow: false,
                    allowInsertColumn: true,
                    allowManualInsertColumn: false,
                    copyCompatibility: false,
                    onchange: calculateGradTotal,
                    onselection: selectionActive
                });




                let header = quotationDescTable.getHeaders();

                //Note: APparently .getHEaders for jspreadsheet does not convert to Array properly when JSON.stringify. Thus I need to extract the data rebuild the array
                let noOfColumn = header.split(",");
                let headerArr = [];
                let totalAmountPosition = -1;
                for (let i = 0; i < noOfColumn.length; i++) {
                    headerArr.push(quotationDescTable.getHeader(i));
                    if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('Amount'.toLowerCase())) {
                        console.log('This column contains amount to calculate:' + i);
                        totalAmountPosition = i;
                    }
                    if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('($$)'.toLowerCase())) {
                        console.log('This column contains amount to calculate:' + i);
                        totalAmountPosition = i;
                    }
                }
                if (totalAmountPosition === -1)
                {

                } else {
                    grandTotalAmount = SUMCOL(quotationDescTable, totalAmountPosition);
                    console.log('Grandtotal when form is load : $' + grandTotalAmount.toFixed(2));
                    document.getElementById('GT').innerHTML = 'Grand Total : $' + grandTotalAmount.toFixed(2);
                }

                console.log('Grandtotal when form is load : $' + grandTotalAmount.toFixed(2));

                let rows = $("#spreadsheet tr");
                console.log('onQuotationDataRetrieveBg  : ' + onQuotationDataRetrieveBg)
                if (onQuotationDataRetrieveBg !== '') {
                    console.log('onQuotationDataRetrieveBg length : ' + onQuotationDataRetrieveBg.length)
                    for (let i = 0; i < onQuotationDataRetrieveBg.length; i++) {
                        console.log('colour : ' + onQuotationDataRetrieveBg[i]);
                        rows[i + 1].style.backgroundColor = onQuotationDataRetrieveBg[i];
                    }
                }
                onQuotationDataRetrieveBg = [];
            }

            function quotation_tnc_first_load() {
                tncTable = jspreadsheet(document.getElementById('my-spreadsheet'), {
                    data: [
                        ["-Payment Terms: 7 days from the date of invoice"]
                    ],
                    columns: [
                        {title: 'T&C', width: 800}
                    ],
                    wordWrap: true,
                    columnSorting: false,
                    allowInsertRow: true,
                    allowManualInsertRow: false,
                    allowInsertColumn: true,
                    allowManualInsertColumn: false,
                    style: {
                        A1: 'height: 100px; text-align:left',
                    }
                });
            }

            function quotation_tnc_load() {
                tncTable = jspreadsheet(document.getElementById('my-spreadsheet'), {
                    data: JSON.parse(tncSpreadsheetDataString),
                    columns: [
                        {title: 'T&C', width: 800}
                    ],
                    wordWrap: true,
                    columnSorting: false,
                    allowInsertRow: true,
                    allowManualInsertRow: false,
                    allowInsertColumn: true,
                    allowManualInsertColumn: false,
                    style: {
                        A1: 'height: 100px; text-align:left',
                    }
                });
            }

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
                document.getElementById('all-prop').innerHTML = '';
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

                    showEdit_Quotation(id);

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

            function dispose()
            {
                $(".schedule-time").AnyTime_noPicker();
                $("#recur-start-time").AnyTime_noPicker();
                $("#timetable-date").AnyTime_noPicker();
                $(".starting-from").AnyTime_noPicker();
                $(".ending-on").AnyTime_noPicker();
                $("#reschedule-date").AnyTime_noPicker();

//                if (typeof resourceMap !== "undefined" && resourceMap !== null)
//                {
//                    resourceMap.remove();
//                }

                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function (index, elem)
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

            function previewQuotation() {

                var pdfName = $('#button-view').data('pdf');
                var signoffPdfName = $('#button-signoff-view').data('pdf');

                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }

                let creatorUserIdPreview = <%=userProperties.getUser().getId()%>;
                let customerIdPreview = $('select[name=dropdownCustomer]').val();
                let attentionToPreview = $('input[name=attention_to]').val();
                let addressPreview = $('textarea[name=address]').val();
                let contactPsnIdPreview = $('select[name=selectContactPerson]').val();
                let quotationHeaderPreview = $('input[name=quotationHeader]').val();

                let headerPreview = quotationDescTable.getHeaders();
                let widthPreview = quotationDescTable.getWidth();
                let dataPreview = quotationDescTable.getData();
                console.log("width when save : " + widthPreview);
                for (let i = 0; i < widthPreview.length; i++) {
                    widthPreview[i] = Math.round(widthPreview[i]);
                }
                console.log("width after rounding when save : " + widthPreview);

                let noOfColumnPreview = headerPreview.split(",");
                let headerArrPreview = [];
                //let widthArr = [];
                for (let i = 0; i < noOfColumnPreview.length; i++) {
                    headerArrPreview.push(quotationDescTable.getHeader(i));
                    //widthArr.push(quotationDescTable.getWidth(i));
                }

                //calculateTotalAmountRow

                let spreadsheetHeaderDataStringPreview = JSON.stringify(headerArrPreview);
                let spreadsheetColWidthDataStringPreview = JSON.stringify(widthPreview);
                let spreadsheetDataStringPreview = JSON.stringify(dataPreview);

                let tncDataPreview = tncTable.getData();
                let tncSpreadsheetDataStringPreview = JSON.stringify(tncDataPreview);

                quotationDescFormatPdfTable = jspreadsheet(document.getElementById('spreadsheet-preview'), {
                    data: JSON.parse(spreadsheetDataStringPreview),
                    type: 'text',
                    allowInsertColumn: true,
                    allowManualInsertColumn: false,
                    copyCompatibility: true
                });

                let dataFormatPdf = quotationDescFormatPdfTable.getData();
                let spreadsheetDataFormatPdfPreviewString = JSON.stringify(dataFormatPdf);

                console.log("spreadsheetDataFormatPdfPreviewString when preview : " + spreadsheetDataFormatPdfPreviewString);

                let rows = $("#spreadsheet tr");
                //check individual rows 
                console.log('Total number of rows : ' + rows.length);
                let rowStyle = [];
                for (let i = 0; i < rows.length; i++) {
                    if (i !== 0) {
                        console.log('row : ' + i + 'colour : ' + rows[i].style.backgroundColor);
                        if (rows[i].style.backgroundColor === '') {
                            rowStyle.push('white');
                        } else {
                            rowStyle.push(rows[i].style.backgroundColor);
                        }
                    }
                }
                console.log('rowStyle : ' + rowStyle);

                let customerName = $('input[name=customerName]').val();
                let quotationValidityDuration = $('input[name=validity]').val();
                let quotationValidityType = $('select[name=billingType]').val();
                let quotationBillingType = $('select[name=durationType]').val();

                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'savePreviewQuotation',
                        creatorUserId: creatorUserIdPreview,
                        resusCustomerId: customerIdPreview,
                        address: addressPreview,
                        quotationHeader: quotationHeaderPreview,
                        attentionTo: attentionToPreview,
                        contactPsnId: contactPsnIdPreview,
                        descHeader: spreadsheetHeaderDataStringPreview,
                        descWidth: spreadsheetColWidthDataStringPreview,
                        descData: spreadsheetDataStringPreview,
                        descDataPdf: spreadsheetDataFormatPdfPreviewString,
                        grandTotal: grandTotalAmount.toFixed(2),
                        tncData: tncSpreadsheetDataStringPreview,
                        annexData: pdfName,
                        descBg: JSON.stringify(rowStyle),
                        customerName: customerName,
                        quotationValidityDuration: quotationValidityDuration,
                        quotationValidityType: quotationValidityType,
                        quotationBillingType: quotationBillingType,
                        signOffPdf: signoffPdfName
                    },
                    beforeSend: function ()
                    {
                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            if (quotationDescFormatPdfTable !== undefined) {
                                quotationDescFormatPdfTable.destroy();
                            }

                            console.log("data.result true with id " + data.id);
                            var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadPreviewQuotation&id=" + data.id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                            pdfdialog.moveTo(0, 0);
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
                    },
                    async: false
                });

            }

            function saveQuotationForm()
            {

                //check individual rows 
                //console.log('Total number of rows : ' + rows3.length);
                console.log('saveQuotationForm');
                //addQuotationData
                //editQuotationData
                if (listForm.save())
                {
                    let rows3 = $("#spreadsheet tr");
                    var action = $('#button-save').data('action');
                    var id = $('#button-save').data('id');
                    var pdfName = $('#button-view').data('pdf');
                    var signoffPdfName = $('#button-signoff-view').data('pdf');

                    if (pdfName === undefined || pdfName === null) {
                        pdfName = '';
                    }

                    if (signoffPdfName === undefined || signoffPdfName === null) {
                        signoffPdfName = '';
                    }

                    if (id === undefined)
                    {
                        id = 0;
                    }

                    let customerId = $('select[name=dropdownCustomer]').val();
                    let attentionTo = $('input[name=attention_to]').val();
                    let designation = $('input[name=designation]').val();
                    let address = $('textarea[name=address]').val();
                    let email = $('textarea[name=email]').val();
                    let contactPsnId = $('select[name=selectContactPerson]').val();
                    let quotationHeader = $('input[name=quotationHeader]').val();
                    let quotationType = $('select[name=quotationType]').val();
                    let creatorUserId = <%=userProperties.getUser().getId()%>;
                    //let descriptionTemplate = $('select[name=selectDescriptionTemplate]').val();
                    let authoriserId = $('select[name=selectAuthoriser]').val();
                    //console.log("authoriserId save : " + authoriserId);
                    let customerName = $('input[name=customerName]').val();
                    let periodStart = $('input[name=dateTimePicker_date_start]').val();
                    let periodEnd = $('input[name=dateTimePicker_date_end]').val();
                    let quotationValidityDuration = $('input[name=validity]').val();
                    let quotationValidityType = $('select[name=billingType]').val();
                    let quotationBillingType = $('select[name=durationType]').val();

                    let header = quotationDescTable.getHeaders();
                    let width = quotationDescTable.getWidth();
                    let data = quotationDescTable.getData();
                    //console.log("header when save : " + header);
                    //console.log("width when save : " + width);
                    //console.log("data when save : " + data);
                    console.log("width when save : " + width);
                    for (let i = 0; i < width.length; i++) {
                        width[i] = Math.round(width[i]);
                    }
                    console.log("width after rounding when save : " + width);

                    //Note: APparently .getHEaders for jspreadsheet does not convert to Array properly when JSON.stringify. Thus I need to extract the data rebuild the array
                    let noOfColumn = header.split(",");
                    let headerArr = [];
                    let totalAmountPosition = -1;
                    for (let i = 0; i < noOfColumn.length; i++) {
                        headerArr.push(quotationDescTable.getHeader(i));
                        if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('Amount'.toLowerCase())) {
                            console.log('This column contains amount to calculate:' + i);
                            totalAmountPosition = i;
                        }
                        if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('($$)'.toLowerCase())) {
                            console.log('This column contains amount to calculate:' + i);
                            totalAmountPosition = i;
                        }
                    }
                    if (totalAmountPosition === -1)
                    {
                        grandTotalAmount = 0;
                    } else {
                        grandTotalAmount = SUMCOL(quotationDescTable, totalAmountPosition);
                    }
                    console.log('Saving Grand Total : $' + grandTotalAmount.toFixed(2));

                    //Check mandatory before submit
                    let mandatoryCheck = true;
                    if (mandatoryCheck) {
                        //Check Customer
                        if (customerId === '0') {
                            dialog('Failed', 'Please select company', 'alert');
                            return;
                        }
                        //Check Attention To
                        if (attentionTo === '') {
                            dialog('Failed', 'Please key in attention to', 'alert');
                            return;
                        }
                        //Check Address
                        if (address === '') {
                            dialog('Failed', 'Please key in address', 'alert');
                            return;
                        }
                        //Check Email
                        if (email === '') {
                            dialog('Failed', 'Please key in email', 'alert');
                            return;
                        }
                        //Cheack Header
                        if (quotationHeader === '') {
                            dialog('Failed', 'Please key in quotation header', 'alert');
                            return;
                        }
                        //Check Re Contact
                        if (contactPsnId === '0') {
                            dialog('Failed', 'Please select RE Contact', 'alert');
                            return;
                        }
                        //Check Quotation Type
                        if (quotationType === '0') {
                            dialog('Failed', 'Please select quotation type', 'alert');
                            return;
                        }
                        //Check Operation In Charge - There needs to be operation in charge set to the quotation
                        if (operators.length === 0)
                        {
                            dialog('Failed', 'Please select the Opertaion In Charge', 'alert');
                            return;
                        }
                        //Check Amount - Make sure it's not $0.00
                        if (grandTotalAmount <= 0)
                        {
                            dialog('Failed', 'Amount needs to have value', 'alert');
                            return;
                        }
                        //Check Quotation Authoriser
                        if (authoriserId === '0') {
                            dialog('Failed', 'Please select authoriser', 'alert');
                            return;
                        }
                        //Check Billing Type
//                        if (quotationBillingType === '0') {
//                            dialog('Failed', 'Please select Billing Type', 'alert');
//                            return;
//                        }
                        //Check Duration
                        if (quotationValidityDuration === '0') {
                            dialog('Failed', 'Please input duration (numeric)', 'alert');
                            return;
                        }
                        //Check Duration Type
                        if (quotationValidityType === '0') {
                            dialog('Failed', 'Please select duration type', 'alert');
                            return;
                        }
                    }

                    spreadsheetHeaderDataString = JSON.stringify(headerArr);
                    spreadsheetColWidthDataString = JSON.stringify(width);
                    spreadsheetDataString = JSON.stringify(data);
                    //console.log('initial data');
                    //console.log(JSON.stringify(data));

                    let tncData = tncTable.getData();
                    tncSpreadsheetDataString = JSON.stringify(tncData);

                    quotationDescFormatPdfTable = jspreadsheet(document.getElementById('spreadsheet'), {
                        data: JSON.parse(spreadsheetDataString),
                        type: 'text',
                        allowInsertColumn: true,
                        allowManualInsertColumn: false,
                        copyCompatibility: true
                    });

                    let dataFormatPdf = quotationDescFormatPdfTable.getData();

                    //let grandTotalAmount = 0;
                    for (let i = 0; i < data.length; i++) {
                        //console.log('Data No: ' + i + ' - ' + data[i]);
                        let dataRow = data[i];
                        //console.log('dataRow length : ' + dataRow.length);
                        for (let j = 0; j < dataRow.length; j++) {
                            //console.log('Data No: ' + j + ' - ' + dataRow[j]);
                            let dataRowString = dataRow[j].toString();
                            if (dataRowString.charAt(0) === '=') {
                                //console.log(data[i][j]);
                                data[i][j] = dataFormatPdf[i][j];
                            }
                        }
                    }
                    //console.log('updated data');
                    //console.log(JSON.stringify(data));
                    spreadsheetDataFormatPdfString = JSON.stringify(data);

                    //console.log(customerId);
                    //console.log(attentionTo);
                    //console.log(address);
                    //console.log(email);
                    //console.log(spreadsheetHeaderDataString);
                    //console.log(spreadsheetColWidthDataString);
                    //console.log(spreadsheetDataString);
                    //console.log(spreadsheetDataFormatPdfString);
                    //console.log(tncSpreadsheetDataString);
                    //console.log(operators.toString());

                    //let rows2 = $("#spreadsheet tr");
                    //check individual rows 
                    console.log('Total number of rows : ' + rows3.length);
                    let rowStyle2 = [];
                    for (let i = 0; i < rows3.length; i++) {
                        if (i !== 0) {
                            console.log('row : ' + i + 'colour : ' + rows3[i].style.backgroundColor);
                            if (rows3[i].style.backgroundColor === '') {
                                rowStyle2.push('white');
                            } else {
                                rowStyle2.push(rows3[i].style.backgroundColor);
                            }
                        }
                    }
                    console.log('rowStyle2 : ' + rowStyle2);

                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: action,
                            resusCustomerId: customerId,
                            attentionTo: attentionTo,
                            designation: designation,
                            address: address,
                            email: email,
                            contactPsnId: contactPsnId,
                            quotationHeader: quotationHeader,
                            quotationType: quotationType,
                            descHeader: spreadsheetHeaderDataString,
                            descWidth: spreadsheetColWidthDataString,
                            descData: spreadsheetDataString,
                            descDataPdf: spreadsheetDataFormatPdfString,
                            grandTotal: grandTotalAmount.toFixed(2),
                            tncData: tncSpreadsheetDataString,
                            creatorUserId: creatorUserId,
                            operators: operators.toString(),
                            quotationAttachment: pdfName,
                            postalCode: postalCode,
                            rev: quotationRevision,
                            quotationStatusTypeId: quotationStatusTypeId,
                            authoriserId: authoriserId,
                            descBg: JSON.stringify(rowStyle2),
                            customerName: customerName,
                            periodStart: periodStart,
                            periodEnd: periodEnd,
                            quotationValidityDuration: quotationValidityDuration,
                            quotationValidityType: quotationValidityType,
                            quotationBillingType: quotationBillingType,
                            signOffPdf: signoffPdfName,
                            id: id
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
                        async: false
                    });
                } else
                {
                    dialog('Error', listForm.saveError, 'alert');
                }
            }

            function updateOperationInCharge()
            {
                console.log('updateOperationInCharge');
                if (listForm.save())
                {
                    var action = $('#button-save').data('action');
                    var id = $('#button-save').data('id');

                    if (id === undefined)
                    {
                        id = 0;
                    }

                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: action,
                            operators: operators.toString(),
                            id: id
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
                        async: false
                    });
                } else
                {
                    dialog('Error', listForm.saveError, 'alert');
                }
            }

            function showAdd()
            {
                resetDialogFieldsAfterHideFromFieldExceptOperator();
                clearForm();
                $('#user_id').val(<%= userProperties.getId()%>);
                var dialog = $('#form-dialog').data('dialog');
                $('#form-dialog-title').html('Create ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                $('#button-save-optimize').data('action', 'optimize');
                $('#button-save').data('action', 'addQuotationData');

                $('#inputFormTemplateNameId').prop("disabled", false);
                $('#inputReportTemplateNameId').prop("disabled", false);

                showResourceDialog();
                quotation_tnc_first_load();
                quotation_description_load();

                dialog.open();
            }

            function showEdit_Quotation(id)
            {
                resetDialogFieldsAfterHideFromFieldExceptOperator();
                if (getQuotationData(id))
                {
                    var pdfName = $('#button-view').data('pdf');
                    if (pdfName === undefined || pdfName === null) {
                        pdfName = '';
                    }

                    if (pdfName === '') {
                        $('#button-view').hide();
                        $('#button-clear').hide();
                    } else {
                        $('#button-view').show();
                        $('#button-clear').show();
                    }

                    console.log('Load form dialog');
                    $('#form-dialog-title').html('Edit ' + '<%=userProperties.getLanguage(data.getDisplayName())%>');
                    $('#button-save').data('action', 'editQuotationData');
                    $('#button-save').data('id', id);
                    showResourceDialog();
                    quotation_description_load();
                    quotation_tnc_load();
                    var dialog = $('#form-dialog').data('dialog');
                    //var dialog = $('#operator-dialog').data('dialog');
                    dialog.open();
                }
            }

            function showEdit_Operator(id)
            {
                if (getQuotationOperator(id))
                {
                    showResourceDialog();
                    hideFormFieldExceptOperator();
                    $('#button-save').data('action', 'editQuotationOperationInCharge');
                    $('#button-save').data('id', id);
                    $('#form-dialog-title').html('Edit Operation In-Charge');
                    var dialog = $('#form-dialog').data('dialog');
                    //var dialog = $('#operator-dialog').data('dialog');
                    dialog.open();
                }
            }
            
            function downloadCSVs()
            {
                csv.startDownload(1000, {customFilterQuery: JSON.stringify(listForm.filter())});
            }

            function copyJobSchedule(id)
            {

                $.ajax({
                    type: 'POST',
                    url: 'JobScheduleController',
                    data: {
                        type: 'system',
                        action: 'copyscheduledata',
                        scheduleId: id
                    },
                    success: function (data)
                    {
                        dialog('Success', 'Successfully copied Job ID: ' + id, 'success');
                        refreshDataTable();
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

            function clearForm()
            {
                postalCode = '';
                operators = [];
                grandTotalAmount = 0;
                quotationRevision = 0;
                quotationStatusTypeId = 0;
                document.getElementById('GT').innerHTML = 'Grand Total : $' + grandTotalAmount.toFixed(2);
                if (quotationDescTable !== undefined) {
                    quotationDescTable.destroy();
                }
                if (quotationDescFormatPdfTable !== undefined) {
                    quotationDescFormatPdfTable.destroy();
                }
                if (tncTable !== undefined) {
                    tncTable.destroy();
                }

                spreadsheetHeaderDataString = JSON.stringify([""]);
                spreadsheetColWidthDataString = JSON.stringify(["100"]);
                spreadsheetDataString = JSON.stringify([[""]]);
                spreadsheetDataFormatPdfString = JSON.stringify([[""]]);
                tncSpreadsheetDataString = JSON.stringify([[""]]);

                document.getElementById('form-dialog-data').reset();

                $('#form-dialog-data').find('input[name=duration]').val(10);

                listForm.reset();

                $('#inputFormTemplateNameId option[value=0]').prop('selected', true);

                $('#inputReportTemplateNameId option[value=0]').prop('selected', true);

                $('#inputDocFileId option[value=0]').prop('selected', true);

                listFields.forEach(function (value, index)
                {
                    value.clear();
                });

                hideAddOperatorIc();

                $('#button-view').data('pdf', '');
                $('#button-signoff-view').data('pdf', '');
            }

            function closeForm()
            {

                $('#form-dialog').data('dialog').close();
                clearForm();
            }

            function getData(id)
            {
                console.log('getData');
                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'ListController?lib=<%=lib%>&type=<%=type%>&action=data',
                    data: {
                        id: id
                    },
                    success: function (data)
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

            function getQuotationData(id)
            {
                console.log('getQuotationData');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'getQuotationData',
                        id: id
                    },
                    success: function (data)
                    {
                        result = true;
                        $('select[name=dropdownCustomer]').val(data.customerId);
                        $('input[name=attention_to]').val(data.attentionTo);
                        $('input[name=designation]').val(data.designation);
                        $('textarea[name=address]').val(data.address);
                        $('textarea[name=email]').val(data.email);
                        $('input[name=quotationHeader]').val(data.quotationHeader);
                        $('select[name=selectContactPerson]').val(data.contactPsnId);
                        $('select[name=quotationType]').val(data.quotationTypeId);
                        spreadsheetHeaderDataString = data.descHeader;
                        spreadsheetColWidthDataString = data.descWidth;
                        spreadsheetDataString = data.descData;
                        tncSpreadsheetDataString = data.tncData;
                        $('#button-view').data('pdf', data.quotationAttachment);
                        quotationRevision = data.quotationRefRev;
                        console.log('quotationRevision : ' + quotationRevision);
                        quotationStatusTypeId = data.quotationStatusTypeId;
                        console.log('quotationStatusTypeId : ' + quotationStatusTypeId);
                        grandTotalAmount = data.quotationGrandTotal;

                        $('textarea[name=followUpEmail]').val(data.email);

                        operators = [];
                        let operatorIc = data.operators;
                        var html = '';

                        for (var i = 0; i < operatorIc.length; i++)
                        {
                            console.log(operatorIc[i].name);
                            html += '<div class="cap-box" id="prop-' + operatorIc[i].id + '">';
                            html += '<div class="single-cap">' + operatorIc[i].name + '</div>';
                            html += '<div class="cap-icon" onclick="removeOperationIc(' + operatorIc[i].id + ')">' + '</div>';
                            html += '</div>';

                            operators.push(operatorIc[i].id);
                        }

                        document.getElementById('all-prop').innerHTML = html;

                        console.log('Set Authoriser Id : ' + data.authoriserId);

                        onQuotationDataRetrieveBg = JSON.parse(data.descBg);
                        reloadBD();
                        $('select[name=selectAuthoriser]').val(data.authoriserId);

                        $('input[name=customerName]').val(data.customerName);
                        $('input[name=dateTimePicker_date_start]').val(data.periodStart);
                        $('input[name=dateTimePicker_date_end]').val(data.periodEnd);
                        console.log('quotationValidityDuration : ' + data.quotationValidityDuration);
                        $('input[name=validity]').val(data.quotationValidityDuration);
                        console.log('quotationValidityDuration : ' + data.quotationValidityType);
                        $('select[name=durationType]').val(data.quotationValidityType);
                        console.log('quotationValidityDuration : ' + data.quotationBillingType);
                        $('select[name=billingType]').val(data.quotationBillingType);
                        $('#button-signoff-view').data('pdf', data.quotationSignoffAttachment);

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

            function reloadBD()
            {
                console.log('reloadBD with grandTotalAmout : ' + grandTotalAmount);
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'getBDByAmount',
                        amount: grandTotalAmount
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {

                        let bdData = data.bduser;

                        var html;

                        html += "<option value='0'>- Select BD -</option>";

                        //var selected = ' selected'; // use to default select first item...

                        for (var i = 0; i < bdData.length; i++)
                        {

                            var bdName = bdData[i];

                            html += "<option value='" + bdName.id + "'" + ">" + bdName.name + "</option>";

                            //selected = '';
                        }

                        document.getElementById('selectAuthoriserId').innerHTML = html;
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

            function getQuotationOperator(id)
            {
                console.log('getQuotationOperator');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'getQuotationData',
                        id: id
                    },
                    success: function (data)
                    {
                        result = true;

                        operators = [];
                        let operatorIc = data.operators;
                        var html = '';

                        for (var i = 0; i < operatorIc.length; i++)
                        {
                            console.log('getQuotationOperator:' + operatorIc[i].name);
                            html += '<div class="cap-box" id="prop-' + operatorIc[i].id + '">';
                            html += '<div class="single-cap">' + operatorIc[i].name + '</div>';
                            html += '<div class="cap-icon" onclick="removeOperationIc(' + operatorIc[i].id + ')">' + '</div>';
                            html += '</div>';

                            operators.push(operatorIc[i].id);
                        }

                        document.getElementById('all-prop').innerHTML = html;
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
                    } else if (field.type === 'searchable')
                    {
                        $('input[name=' + field.name + ']').val(field.value);

                        $('#list-data-field-' + field.name).val(field.text);
                    } else if (field.type === 'checkbox')
                    {
                        $('input[name=' + field.name + ']').prop('checked', field.value);
                    } else if (field.type === 'html')
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

            $("#tool-button-delete-filter").click(function ()
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
                            beforeSend: function ()
                            {
                                $('#tool-button-delete-filter').prop("disabled", true);
                            },
                            success: function (data)
                            {

                                if (data.expired === undefined)
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
                                }
//                                else
//                                {
//                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                                }
                            },
                            error: function ()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function ()
                            {
                                $('#tool-button-delete-filter').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                } else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'default');
                }
            });

            //function showAddProperty()
            function showAddOperatorIc()
            {
                document.getElementById("add-operationIc").style.display = "block";
                document.getElementById("add-prop-btn").style.display = "none";
            }

            //function hideAddProperty()
            function hideAddOperatorIc()
            {
                document.getElementById("add-operationIc").style.display = "none";
                document.getElementById("add-prop-btn").style.display = "block";
            }

            function showResourceDialog()
            {
                document.getElementById("add-operationIc").style.display = "none";
                hideAddOperatorIc();
            }

            //function addProperty()
            function addOperatorIc()
            {
                var selectedVal = $('#operationIc').val();

                if (!selectedVal)
                {
                    return;
                }

                for (var i = 0; i < operators.length; i++)
                {
                    if (parseInt(operators[i], 10) === parseInt(selectedVal, 10))
                    {
                        alert('Operation IC has been added');
                        return;
                    }
                }

                operators.push(selectedVal);

                var selectedText = $('#operationIc option:selected').text();

                var html = '<div class="cap-box" id="prop-' + selectedVal + '">';
                html += '<div class="single-cap">' + selectedText + '</div>';
                html += '<div class="cap-icon" onclick="removeOperationIc(' + selectedVal + ')">' + '</div>';
                html += '</div>';

                $('#all-prop').append(html);

                hideAddOperatorIc();
            }

            function removeOperationIc(val)
            {
                for (var i = 0; i < operators.length; i++)
                {
                    if (parseInt(operators[i], 10) === parseInt(val, 10))
                    {
                        operators.splice(i, 1);
                        break;
                    }
                }

                $("#prop-" + val).remove();
            }

            function hideFormFieldExceptOperator() {
                document.getElementById("header1").style.display = "none";
                document.getElementById("header1_2").style.display = "none";
                document.getElementById("header2").style.display = "none";
                document.getElementById("header3").style.display = "none";
                document.getElementById("header4").style.display = "none";
                document.getElementById("header5").style.display = "none";
                document.getElementById("header5_2").style.display = "none";
                document.getElementById("header6").style.display = "none";
                document.getElementById("header7").style.display = "none";
                document.getElementById("header8").style.display = "none";
                document.getElementById("header9").style.display = "none";
                document.getElementById("header10").style.display = "none";
                document.getElementById("spreadsheet").style.display = "none";
                document.getElementById("calculateGrandTotalDiv").style.display = "none";
                document.getElementById("addRowSpreadsheet").style.display = "none";
                document.getElementById("termsCondition").style.display = "none";
                document.getElementById("button-add-attachment").style.display = "none";
                document.getElementById("button-preview").style.display = "none";
                document.getElementById("button-save-operation-in-charge").style.display = "";
                document.getElementById("button-save").style.display = "none";
                document.getElementById("form-dialog").className = "small dialog bg-white";
            }

            function resetDialogFieldsAfterHideFromFieldExceptOperator() {
                document.getElementById("header1").style.display = "";
                document.getElementById("header2").style.display = "";
                document.getElementById("header3").style.display = "";
                document.getElementById("header4").style.display = "";
                document.getElementById("header5").style.display = "";
                document.getElementById("header6").style.display = "";
                document.getElementById("header7").style.display = "";
                document.getElementById("header8").style.display = "";
                document.getElementById("header9").style.display = "";
                document.getElementById("header10").style.display = "";
                document.getElementById("spreadsheet").style.display = "";
                document.getElementById("calculateGrandTotalDiv").style.display = "";
                document.getElementById("addRowSpreadsheet").style.display = "";
                document.getElementById("termsCondition").style.display = "";
                document.getElementById("button-add-attachment").style.display = "";
                document.getElementById("button-preview").style.display = "";
                document.getElementById("button-save-operation-in-charge").style.display = "none";
                document.getElementById("button-save").style.display = "";
                document.getElementById("form-dialog").className = "medium dialog bg-white";
            }

            function getUserList() {
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'getUserList'
                    },
                    success: function (data)
                    {

                        if (data.result === true)
                        {
                            var userData = data.data;
                            var html = '';

                            html += "<option value = \"\" disabled selected>- Select Operation IC -</option>";

                            for (var i = 0; i < userData.length; i++)
                            {
                                var aOperationIc = userData[i];

                                html += "<option value='" + aOperationIc.id + "'" + ">" + aOperationIc.name + "</option>";
                            }
                            $('select[name=operationIc').replaceWith("<select id=\"operationIc\" name=\"operationIc\" style=\"font-size: 18px;\">" + html + "</select>");

                        } else
                        {
                            dialog('Failed', 'Unable to retrieve Property list', 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error a', 'alert');
                    },
                    complete: function ()
                    {
                        $('#button-save').prop("disabled", false);
                    },
                    async: false
                });
            }

            function downloadQuotation(id) {
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadQuotation&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function sendForAuthorize(id) {
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'sendForAuthorize',
                        id: id
                    },
                    beforeSend: function () {
                        return confirm("Are you sure you want to send this quotation for authorisation?");
                    },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.result === true) {
                            dialog('Success', 'Quotation is sent for authorization', 'success');
                        } else {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error a', 'alert');
                    },
                    async: false
                });
            }

            function copyLink(theLink)
            {
                navigator.clipboard.writeText();

                dialog('Success', 'Link Copied', 'success');

                window.open('<%=domainUrl%>' + theLink, '_blank').focus();
            }

            var SUMCOLOld = function (instance, columnId) {
                let total = 0;
                for (let j = 0; j < instance.options.data.length; j++) {
                    console.log("SUMCOL :" + instance.records[j][columnId].innerHTML);
                    if (Number(instance.records[j][columnId].innerHTML)) {
                        total += Number(instance.records[j][columnId].innerHTML);
                    } else {
                        console.log("SUMCOL contain string. Remove them");
                        parseNum = str => +str.replace(/[^.\d]/g, '');
                        let str = instance.records[j][columnId].innerHTML;
                        total += parseNum(str);
                    }
                }
                return total;
            }
            
                    const SUMCOL = (instance, columnId) => {
            // Validate inputs
            if (!instance || !instance.options?.data || !instance.records || !columnId) {
                console.error('Invalid input: instance or columnId missing');
                return 0;
            }

            // Define parseNum outside the loop to avoid redefinition
            const parseNum = str => {
                if (typeof str !== 'string') return 0;
                const cleaned = str.replace(/[^0-9.-]/g, '');
                const num = Number(cleaned);
                return isNaN(num) ? 0 : num;
            };

            let total = 0;
            const rowCount = Math.min(instance.options.data.length, instance.records.length);

            for (let j = 0; j < rowCount; j++) {
                const cell = instance.records[j]?.[columnId];
                if (!cell || !('innerHTML' in cell)) {
                    console.warn(`Skipping invalid cell at row ${j}, column ${columnId}`);
                    continue;
                }

                const value = parseNum(cell.innerHTML);
                total += value;

                // Optional debug logging
                // console.log(`Row ${j}, Column ${columnId}: ${cell.innerHTML} -> ${value}`);
            }

            return total;
        };

            function calculateTotalAmount() {
                var total = 0;
                for (var j = 0; j < quotationDescTable.options.data.length; j++) {
                    if (Number(quotationDescTable.records[j][1].innerHTML)) {
                        total += Number(quotationDescTable.records[j][1].innerHTML);
                    }
                }
                console.log('total amount :' + total);
            }

            function getCalculatedColumn() {
                let spreadsheetData = quotationDescTable.descData;
                Console.log(spreadsheetData.length);
            }

            function calculateTotalAmountRow() {
                let spreadsheetData = quotationDescTable.descData;
                Console.log(spreadsheetData.length);
            }

            function letterValue(str) {
                var anum = {
                    A: 0, B: 1, C: 2, D: 3, E: 4, F: 5, G: 6, H: 7, I: 8, J: 9, K: 10,
                    L: 11, M: 12, N: 13, O: 14, P: 15, Q: 16, R: 17, S: 18, T: 19,
                    U: 20, V: 21, W: 22, X: 23, Y: 24, Z: 25
                }
                if (str.length == 1)
                    return anum[str] || ' ';
                return str.split('').map(letterValue);
            }

            function addRowsWithData() {

                let data = quotationDescTable.getData();

                let lastRowNo = 0;
                for (let i = 0; i < data.length; i++) {
                    lastRowNo++;
                }
                //get LastRowData 
                let lastRowData = data[(lastRowNo - 1)];
                //console.log('Last Row length: ' + lastRowData.length);
                for (let j = 0; j < lastRowData.length; j++) {
                    //console.log('Data No: ' + j + ' - ' + lastRowData[j]);

                    let lastRowDataRowString = lastRowData[j].toString();
                    if (lastRowDataRowString.charAt(0) === '=') {
                        //console.log('Last Row Data: ' + lastRowDataRowString);
                        //console.log('Last Row Data Remove No: ' + lastRowDataRowString.replace(/(\d+)+/g, (lastRowNo + 1)));
                        lastRowData[j] = lastRowDataRowString.replace(/(\d+)+/g, (lastRowNo + 1));
                    } else {
                        lastRowData[j] = '';
                    }
                }

                //console.log('After Clearning');
                //console.log(lastRowData);
                quotationDescTable.insertRow(lastRowData);

                //quotationDescTable.headers[0].style.backgroundColor = 'red';
                //document.getElementById('spreadsheet').jexcel.headers[0].style.backgroundColor = 'red';
                //quotationDescTable.columns[0].type = 'text'; // Change first column to text.
            }

            function deleteRowsUpdateData() {
                quotationDescTable.deleteRow();
                let header = quotationDescTable.getHeaders();

                //Note: APparently .getHEaders for jspreadsheet does not convert to Array properly when JSON.stringify. Thus I need to extract the data rebuild the array
                let noOfColumn = header.split(",");
                let headerArr = [];
                let totalAmountPosition = -1;
                for (let i = 0; i < noOfColumn.length; i++) {
                    headerArr.push(quotationDescTable.getHeader(i));
                    if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('Amount'.toLowerCase())) {
                        console.log('This column contains amount to calculate:' + i);
                        totalAmountPosition = i;
                    }
                    if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('($$)'.toLowerCase())) {
                        console.log('This column contains amount to calculate:' + i);
                        totalAmountPosition = i;
                    }
                }
                if (totalAmountPosition === -1)
                {

                } else {
                    grandTotalAmount = SUMCOL(quotationDescTable, totalAmountPosition);
                    console.log('Grandtotal when row is deleted : $' + grandTotalAmount.toFixed(2));
                    document.getElementById('GT').innerHTML = 'Grand Total : $' + grandTotalAmount.toFixed(2);
                }
            }

            var calculateGradTotal = function () {
                let header = quotationDescTable.getHeaders();
                console.log('header when calculateGradTotal runs :' + header);
                //Note: APparently .getHEaders for jspreadsheet does not convert to Array properly when JSON.stringify. Thus I need to extract the data rebuild the array
                let noOfColumn = header.split(",");
                let headerArr = [];
                let totalAmountPosition = -1;
                let isAmountIsTrue = false;
                for (let i = 0; i < noOfColumn.length; i++) {
                    headerArr.push(quotationDescTable.getHeader(i));
                    if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('Amount'.toLowerCase())) {
                        console.log('This column contains amount to calculate:' + i);
                        totalAmountPosition = i;
                        isAmountIsTrue = true;
                    } else if (quotationDescTable.getHeader(i).toString().toLowerCase().includes('($$)'.toLowerCase())) {
                        console.log('This column contains amount to calculate:' + i);
                        totalAmountPosition = i;
                        isAmountIsTrue = true;
                    }
                }

                if (isAmountIsTrue) {
                    grandTotalAmount = SUMCOL(quotationDescTable, totalAmountPosition);
                }
                console.log('Grand Total: ' + grandTotalAmount.toFixed(2));
                document.getElementById('GT').innerHTML = 'Grand Total : $' + grandTotalAmount.toLocaleString();
            }

            function ROUND(x) {
                return Number.parseFloat(x).toFixed(2);
            }

            function clearUpload() {
                const file = document.querySelector('.file');
                file.value = '';
            }

            $('#button-clear').on('click', function () {
                $('#button-view').data('pdf', '');
                $('#button-view').hide();
                $('#button-clear').hide();
            });

            $('#button-add-attachment').on('click', function () {
                $('#file').click();
                return false;
            });

            let fileUpload = document.getElementById("file");
            fileUpload.onchange = function () {
                let now = new Date();
                let year = now.getFullYear();
                let month = now.getMonth() + 1;
                let day = now.getDate();
                let hour = now.getHours();
                let minute = now.getMinutes();
                let second = now.getSeconds();
                if (month.toString().length == 1) {
                    month = '0' + month;
                }
                if (day.toString().length == 1) {
                    day = '0' + day;
                }
                if (hour.toString().length == 1) {
                    hour = '0' + hour;
                }
                if (minute.toString().length == 1) {
                    minute = '0' + minute;
                }
                if (second.toString().length == 1) {
                    second = '0' + second;
                }

                let uploaderUserId = <%=userProperties.getUser().getId()%>;

                let filename = uploaderUserId + '_' + year + '_' + month + '_' + day + '_' + hour + '_' + minute + '_' + second;

                let filenameWithType = filename + '.pdf';

                let fd = new FormData();
                let file = $('#file')[0].files[0];
                fd.append('file', file, filenameWithType);

                $.ajax({
                    url: 'ResusQuotationController?type=plan&action=uploadQuotationAttachment',
                    type: 'post',
                    data: fd,
                    contentType: false,
                    processData: false,
                    success: function (data) {
                        if (data.result === true) {
                            dialog('Success', 'Attachment Uploaded', 'success');
                            $('#button-view').data('pdf', filenameWithType);
                            //show button
                            $('#button-view').show();
                            $('#button-clear').show();
                        } else {
                            dialog('Failed', 'Failed Uploading Attachement', 'alert');
                        }
                    },
                });
            };

            $('#button-view').on('click', function () {
                var pdfName = $('#button-view').data('pdf');
                console.log('View Attachment : ' + pdfName);
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadAttachment&filename=" + pdfName, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            });

            $('#button-signoff-view').on('click', function () {
                var pdfName = $('#button-signoff-view').data('pdf');
                console.log('View Attachment : ' + pdfName);
                //var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadAttachment&filename=" + pdfName, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadPreviewSignOffQuotation", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            });

            var selectedRows = [];
            var selectionActive = function () {
                console.log('selectionActive');
                selectedRows = quotationDescTable.getSelectedRows(true);
                console.log('Number of selected Rows : ' + selectedRows.length);
                console.log('Selected Row : ' + selectedRows);
            }

            function changeColour() {
                console.log('changeColour');
                let selectedColour = $('select[id=setRowColour]').val();
                //let selectedColour = "#4BACC6";
                console.log('selected coulour : ' + selectedColour);
                let rows = $("#spreadsheet tr");

                if (selectedRows.length > 0) {
                    for (let i = 0; i < selectedRows.length; i++)
                    {
                        let currentRow = parseInt(selectedRows[i]) + 1;
                        console.log('Selected Row : ' + currentRow);
                        rows[currentRow].style.backgroundColor = selectedColour;
                        console.log('rows[currentRow].style.backgroundColor : ' + rows[currentRow].style.backgroundColor);
                    }
                } else {
                    console.log('No row is selected');
                }
                selectedRows = [];
            }

            function loadTableStyle() {

            }

            function closeQuotation()
            {
                $('#button-void-quotation').hide();
                $('#button-terminate-quotation').hide();
                $('#button-reject-quotation').hide();

                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                console.log('selected row : ' + data[0]);

                var dataIndex = table.rows('.selected').indexes();

                console.log('selected row : ' + dataIndex[0]);

                var testColIndexStatus = table.column(':contains(Status)');
                var testColIndexRefNo = table.column(':contains(Ref Number)');

                //console.log('testcoldata : ' + testColIndexStatus[0]);

                var columnStatusData = table.cell(dataIndex[0], testColIndexStatus[0]).data();
                var columnRefNoData = table.cell(dataIndex[0], testColIndexRefNo[0]).data();
                //console.log('column data : ' + columnStatusData);

                if (data.length > 0)
                {
                    if (data.length === 1) {
                    } else {
                        dialog('More than 1 item selected', 'You can only close 1 quotation at a time', 'alert');
                    }
                } else
                {
                    dialog('No Quotation Selected', 'Please select a quotation', 'alert');
                }
                if (columnStatusData.includes('Pending For Authorisation') || columnStatusData.includes('Pending–Client Acceptance') || columnStatusData.includes('Pending BD Authorisation')) {
                    console.log('Reject Quotation By Creator - Add remarks');
                    $('#closeQuotation-dialog-title').html('Reject - ' + columnRefNoData);
                    //If Pending Authorisation - Send email to BD
                    //If Pending Client - Send email to Client and BD
                    $('#button-reject-quotation').show();
                    $('#closeQuotation-dialog').data('dialog').open();
                } else if (!columnStatusData.includes('Void')) {
                    console.log('Void Quotation');
                    $('#closeQuotation-dialog-title').html('Void - ' + columnRefNoData);
                    $('#button-void-quotation').show();
                    $('#closeQuotation-dialog').data('dialog').open();
                }
            }

            function rejectQuotation()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    $('#closeQuotation-dialog').data('dialog').close();
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController?type=plan&action=rejectQuotation',
                        data:
                                {
                                    quotationId: id,
                                    remarks: $('textarea[name=closeRemarks]').val(),
                                },
                        success: function (data)
                        {
                            refreshDataTable();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Quotation rejected', 'success');
                                } else
                                {
                                    dialog('Failed', 'Unable to reject quotation', 'alert');
                                }
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        async: true
                    });
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            }

            function voidQuotation()
            {
                var table = $('#result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    $('#closeQuotation-dialog').data('dialog').close();
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController?type=plan&action=voidQuotation',
                        data:
                                {
                                    quotationId: id,
                                    remarks: $('textarea[name=closeRemarks]').val(),
                                },
                        success: function (data)
                        {
                            refreshDataTable();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Quotation rejected', 'success');
                                } else
                                {
                                    dialog('Failed', 'Unable to reject quotation', 'alert');
                                }
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        async: true
                    });
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            }

            function followUpQuotation()
            {
                var table = $('#result-table').DataTable();
                var data = table.rows('.selected').ids();

                if (data.length = 1)
                {
                    var ids = data.join();
                    let link = '<%=domainUrl%>' + "customersignoff?id=" + ids;
                    //console.log("Follow Up Quotation By Link : " + link);
                    //$('#button-email').data('id', id);
                    $('#button-followup-copy').data('link', link);
                    $('#button-followup-email').data('id', ids);
                    $('#followUp-dialog').animate({width: '550px', height: '150px'});
                    $('textarea[name=followUpEmail]').hide();
                    $('#button-followup-email').show();
                    $('#button-followup-link').show();
                    $('#button-followup-send').hide();
                    $('#button-followup-copy').hide();
                    $('#button-followup-cancel').show();
                    $('#followUp-dialog').data('dialog').open();
                } else if (data.length > 1)
                {
                    dialog('More than 1 record selected', 'Please select only 1 record record to follow up', 'alert');
                } else
                {
                    dialog('No Record Selected', 'Please select a record to follow up', 'alert');
                }
            }

            //followUp-dialog
            function followUpQuotationNew(id)
            {
                let proceedAuthorize = false;
                $.ajax({
                    type: 'POST',
                    url: 'QuotationCreatorSignatureTemplateController',
                    data: {
                        action: 'getSignature',
                        userId: '<%=userId%>'
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            //console.log("Signature Data : " + data.signature.length);
                            if (data.signature.length > 2000) {
                                proceedAuthorize = true;
                            }
                        }
                    },
                    error: function ()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });

                if (proceedAuthorize) {
                    $('#followUpQuotation-dialog-title').html('');

                    $('#followUpQuotation-dialog-content').html('');
                    $('textarea[name=followUpEmail]').val("");
                    let link = '<%=domainUrl%>' + "customersignoff?id=" + id;
                    $('#button-followup-copy').data('link', link);
                    $('#button-followup-email').data('id', id);
                    $('#button-followup-cancel').data('id', id);
                    $('#button-followup-copy').data('link', link);
                    $('#followUp-dialog').animate({width: '550px', height: '150px'});

                    $('textarea[name=followUpEmail]').hide();
                    $('#button-followup-authorise').hide();
                    $('#button-followup-reauthorise').hide();
                    $('#button-followup-recall-bd').hide();
                    $('#button-followup-recall-cust').hide();
                    $('#button-followup-recall-submit').hide();
                    $('#button-followup-signoff').hide();
                    $('#button-followup-signoff-submit').hide();
                    $('#button-followup-email').hide();
                    $('#button-followup-send').hide();
                    $('#button-followup-link').hide();
                    $('#button-followup-copy').hide();
                    $('#button-followup-void').hide();
                    $('#button-followup-void-submit').hide();
                    $('#button-followup-cancel').hide();
                    $('#button-signoff-add-attachment').hide();
                    $('#button-signoff-view').hide();
                    $('#button-signoff-clear').hide();

                    var table = $('#result-table').DataTable();

                    const dtrow = table.row('#' + id);

                    var testColIndexStatus = table.column(':contains(Status)');
                    var testColIndexRefNo = table.column(':contains(Ref Number)');

                    var columnStatusData = table.cell(dtrow[0], testColIndexStatus[0]).data();
                    //console.log('columnStatusData : ' + columnStatusData[1]);
                    var columnRefNoData = table.cell(dtrow[0], testColIndexRefNo[0]).data();

                    $('#followUpQuotation-dialog-title').html('Follow-Up - ' + columnRefNoData);

                    $('#followUp-dialog').data('id', id);
                    $('#followUp-dialog').data('link', link);
                    $('#followUp-dialog').data('refNo', columnRefNoData);

                    if (columnStatusData.includes('New') || columnStatusData.includes('Edited') || columnStatusData.includes('Revised')) {
                        $('#button-followup-void').show();
                        $('#button-followup-authorise').show();
                        $('#followUp-dialog').data('dialog').open();
                    }
                    if (columnStatusData.includes('Recall From Customer') || columnStatusData.includes('Recall From BD')) {
                        $('#button-followup-void').show();
                        F
                        $('#followUp-dialog').data('dialog').open();
                    }
                    if (columnStatusData.includes('Pending For Authorisation')|| columnStatusData.includes('Pending BD Authorisation')) {
                        $('#button-followup-void').show();
                        $('#button-followup-recall-bd').show();
                        $('#button-followup-reauthorise').show();
                        $('#followUp-dialog').data('dialog').open();
                    }
                    if (columnStatusData.includes('Pending–Client Acceptance')) {
                        $('#button-followup-void').show();
                        $('#button-followup-recall-cust').show();
                        $('#button-followup-signoff').show();
                        $('#button-followup-email').show();
                        $('#button-followup-copy').show();
                        $('#followUp-dialog').data('dialog').open();
                    }
                    columnStatusData.includes('')
                }else{
                    dialog('Error', 'Please go to "Manage Quotation -> Signature" to add signature', 'alert');
                }


            }

            function cancel()
            {
                let id = $('#button-followup-cancel').data('id');
                $('#followUpQuotation-dialog-title').html('');
                $('#followUpQuotation-dialog-content').html('');
                $('textarea[name=followUpEmail]').val("");
//                let link = '<%=domainUrl%>' + "customersignoff?id=" + id;
//                $('#button-followup-copy').data('link', link);
//                $('#button-followup-email').data('id', id);
//                $('#button-followup-cancel').data('id', id);
                $('#followUp-dialog').animate({width: '550px', height: '150px'});

                $('textarea[name=followUpEmail]').hide();
                $('#button-followup-authorise').hide();
                $('#button-followup-reauthorise').hide();
                $('#button-followup-recall-bd').hide();
                $('#button-followup-recall-cust').hide();
                $('#button-followup-recall-submit').hide();
                $('#button-followup-signoff').hide();
                $('#button-followup-signoff-submit').hide();
                $('#button-followup-email').hide();
                $('#button-followup-send').hide();
                $('#button-followup-link').hide();
                $('#button-followup-copy').hide();
                $('#button-followup-void').hide();
                $('#button-followup-void-submit').hide();
                $('#button-followup-cancel').hide();
                $('#button-signoff-add-attachment').hide();
                $('#button-signoff-view').hide();
                $('#button-signoff-clear').hide();

                var table = $('#result-table').DataTable();

                const dtrow = table.row('#' + id);

                var testColIndexStatus = table.column(':contains(Status)');
                var testColIndexRefNo = table.column(':contains(Ref Number)');

                var columnStatusData = table.cell(dtrow[0], testColIndexStatus[0]).data();
                //console.log('columnStatusData : ' + columnStatusData[1]);
                var columnRefNoData = table.cell(dtrow[0], testColIndexRefNo[0]).data();

                $('#followUpQuotation-dialog-title').html('Follow-Up - ' + columnRefNoData);

                if (columnStatusData.includes('New') || columnStatusData.includes('Edited') || columnStatusData.includes('Revised')) {
                    $('#button-followup-void').show();
                    $('#button-followup-authorise').show();
                    $('#followUp-dialog').data('dialog').open();
                }
                if (columnStatusData.includes('Pending For Authorisation')|| columnStatusData.includes('Pending BD Authorisation')) {
                    $('#button-followup-void').show();
                    $('#button-followup-recall-bd').show();
                    $('#button-followup-reauthorise').show();
                    $('#followUp-dialog').data('dialog').open();
                }
                if (columnStatusData.includes('Pending–Client Acceptance')) {
                    $('#button-followup-void').show();
                    $('#button-followup-recall-cust').show();
                    $('#button-followup-signoff').show();
                    $('#button-followup-signoff-submit').hide();
                    $('#button-followup-email').show();
                    $('#button-followup-copy').show();
                    $('#followUp-dialog').data('dialog').open();
                }
                columnStatusData.includes('')
            }

            function followAuthorise() {
                let id = $('#followUp-dialog').data('id');

                let result = confirm("Are you sure you want to send this quotation for authorisation?");
                if (result === true)
                {
                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: 'sendForAuthorize',
                            id: id
                        },
                        beforeSend: function () {
                            //$('#button-followup-authorise').attr("disabled", false);
                            //$('#button-followup-reauthorise').attr("disabled", false);
                            $('#button-followup-authorise').hide();
                            $('#button-followup-authorise').hide();
                        },
                        success: function (data)
                        {
                            refreshDataTable();
                            if (data.result === true) {
                                dialog('Success', 'Quotation is sent for authorization', 'success');
                            } else {
                                dialog('Failed', data.text, 'alert');
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error a', 'alert');
                        },
                        async: false
                    });
                    $('#followUp-dialog').data('dialog').close();
                }
            }

            function followUpEmail() {
                if (getQuotationData($('#button-followup-email').data('id'))) {
                }

                $('textarea[name=followUpEmail]').show();
                $('#button-followup-send').show();
                $('#button-followup-email').hide();
                $('#button-followup-link').hide();
                $('#button-followup-copy').hide();
                $('#button-followup-signoff').hide();
                $('#button-followup-signoff-submit').hide();
                $('#button-followup-recall-bd').hide();
                $('#button-followup-recall-cust').hide();
                $('#button-followup-recall-submit').hide();
                $('#button-followup-void').hide();
                $('#button-followup-void-submit').hide();
                $('#button-followup-cancel').show();
                $('#followUp-dialog').animate({width: '550px', height: '300px'});
            }

            function followUpLink() {
                let link = $('#button-followup-link').data('link');
                console.log("Dollow Up Link : " + link);
                $('#button-followup-copy').show();
                $('#button-followup-cancel').hide();
                $('#button-followup-email').hide();
                $('#button-followup-link').hide();
                $('#button-followup-send').hide();
            }

            function copyLink() {
                $('#followUp-dialog').data('dialog').close();
                let link = $('#button-followup-copy').data('link');
                console.log("Follow Up Link : " + link);
                // Copy the text inside the text field
                navigator.clipboard.writeText(link);
                // Alert the copied text
                alert("Copied the link " + link);
            }

            function sendFOllowUpEmail() {
                let strs = $('textarea[name=followUpEmail]').val();
                console.log("Before regex : " + strs);
                let strreg = strs.split(/,\s*|\s+/);
                console.log("After regex : " + strreg);
                //sendForFollowup
                let id = $('#button-followup-email').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController?type=plan&action=sendForFollowup',
                    data:
                            {
                                'quotationId': id,
                                'emailList': strs
                            },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
                            } else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    async: true
                });
                $('#followUp-dialog').data('dialog').close();
            }

            function followUpRecallBd() {
                let columnRef = $('#followUp-dialog').data('refNo');
                $('#followUpQuotation-dialog-title').html('Recall - ' + columnRef);
                $('#followUpQuotation-dialog-content').html('Please enter reason to recall the quotation');

                $('#button-followup-reauthorise').hide();
                $('#button-followup-void').hide();
                $('#button-followup-signoff').hide();
                $('#button-followup-signoff-submit').hide();
                $('#button-followup-email').hide();
                $('#button-followup-copy').hide();
                $('#button-followup-recall-bd').hide();
                $('#button-followup-recall-cust').hide();
                $('#button-followup-recall-submit').show();
                $('#button-followup-recall-submit').data('recallFrom', 'bd');


                $('#button-followup-cancel').show();
                $('textarea[name=followUpEmail]').show();
                $('#followUp-dialog').animate({width: '550px', height: '300px'});
            }

            function followUpRecallCust() {
                let columnRef = $('#followUp-dialog').data('refNo');
                $('#followUpQuotation-dialog-title').html('Recall - ' + columnRef);
                $('#followUpQuotation-dialog-content').html('Please enter reason to recall the quotation')

                $('#button-followup-void').hide();
                $('#button-followup-signoff').hide();
                $('#button-followup-signoff-submit').hide();
                $('#button-followup-email').hide();
                $('#button-followup-copy').hide();
                $('#button-followup-recall-bd').hide();
                $('#button-followup-recall-cust').hide();
                $('#button-followup-recall-submit').show();
                $('#button-followup-recall-submit').data('recallFrom', 'cust');

                $('textarea[name=followUpEmail]').show();
                $('#button-followup-cancel').show();
                $('#followUp-dialog').animate({width: '550px', height: '300px'});
            }

            function followUpRecallSubmit()
            {
                let id = $('#followUp-dialog').data('id');
                let recallFromStr = $('#button-followup-recall-submit').data('recallFrom');

                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController?type=plan&action=recallQuotation',
                    data:
                            {
                                quotationId: id,
                                remarks: $('textarea[name=followUpEmail]').val(),
                                recallFrom: recallFromStr
                            },
                    beforeSend: function () {
                        return confirm("Are you sure you want to recall this quotation?");
                    },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', 'Quotation Recalled', 'success');
                            } else
                            {
                                dialog('Failed', 'Unable to recall quotation', 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    async: true
                });
                $('#followUp-dialog').data('dialog').close();
            }

            function followUpVoid() {
                let columnRef = $('#followUp-dialog').data('refNo');
                $('#followUpQuotation-dialog-title').html('Void - ' + columnRef);
                $('#followUpQuotation-dialog-content').html('Please enter reason to void the quotation')

                $('#button-followup-authorise').hide();
                $('#button-followup-reauthorise').hide();
                $('#button-followup-recall-bd').hide();
                $('#button-followup-recall-cust').hide();
                $('#button-followup-recall-submit').hide();
                $('#button-followup-void').hide();
                $('#button-followup-signoff').hide();
                $('#button-followup-signoff-submit').hide();
                $('#button-followup-email').hide();
                $('#button-followup-copy').hide();

                $('textarea[name=followUpEmail]').show();
                $('#button-followup-cancel').show();
                $('#button-followup-void-submit').show();
                $('#followUp-dialog').animate({width: '550px', height: '300px'});
            }

            function followUpSignoff() {
                let columnRef = $('#followUp-dialog').data('refNo');
                $('#followUpQuotation-dialog-title').html('Sign Off - ' + columnRef);
                $('#followUpQuotation-dialog-content').html('Please enter reason to sign off the quotation')

                $('#button-followup-void').hide();
                $('#button-followup-signoff').hide();
                $('#button-followup-signoff-submit').hide();
                $('#button-followup-email').hide();
                $('#button-followup-copy').hide();
                $('#button-followup-recall-bd').hide();
                $('#button-followup-recall-cust').hide();
                $('#button-followup-recall-submit').hide();

                $('textarea[name=followUpEmail]').show();
                $('#button-followup-signoff-submit').show();
                $('#button-followup-cancel').show();

                $('#button-signoff-add-attachment').show();
                $('#button-signoff-view').hide();
                $('#button-signoff-clear').hide();

                $('#followUp-dialog').animate({width: '550px', height: '300px'});
            }

            $('#button-signoff-add-attachment').on('click', function () {
                $('#fileSignOff').click();
                return false;
            });

            //Upload Sign Off File
            let fileSignOffUpload = document.getElementById("fileSignOff");
            fileSignOffUpload.onchange = function () {
                let id = $('#followUp-dialog').data('id');
                let now = new Date();
                let year = now.getFullYear();
                let month = now.getMonth() + 1;
                let day = now.getDate();
                let hour = now.getHours();
                let minute = now.getMinutes();
                let second = now.getSeconds();
                if (month.toString().length == 1) {
                    month = '0' + month;
                }
                if (day.toString().length == 1) {
                    day = '0' + day;
                }
                if (hour.toString().length == 1) {
                    hour = '0' + hour;
                }
                if (minute.toString().length == 1) {
                    minute = '0' + minute;
                }
                if (second.toString().length == 1) {
                    second = '0' + second;
                }

                let uploaderUserId = <%=userProperties.getUser().getId()%>;

                let filename = 'signoff_' + uploaderUserId + '_' + year + '_' + month + '_' + day + '_' + hour + '_' + minute + '_' + second;

                let filenameWithType = filename + '.pdf';

                let fd = new FormData();
                let file = $('#fileSignOff')[0].files[0];
                fd.append('fileSignOff', file, filenameWithType);

                //copy current quotation data to preview data

                $.ajax({
                    url: 'ResusQuotationController?type=plan&action=uploadQuotationSignOffAttachment',
                    type: 'post',
                    data: fd,
                    contentType: false,
                    processData: false,
                    success: function (data) {
                        if (data.result === true) {
                            dialog('Success', 'Attachment Uploaded', 'success');
                            $('#button-signoff-view').data('pdf', filenameWithType);
                            //show button
                            $('#button-signoff-view').show();
                            $('#button-signoff-clear').show();
                            $.ajax({
                                type: 'POST',
                                url: 'ResusQuotationController?type=plan&action=updateQuotationSignOffAttachment',
                                data:
                                        {
                                            quotationId: id,
                                            fileName: filenameWithType
                                        },
                                success: function (data)
                                {
                                    dialog('Success', 'Attachment Uploaded', 'success');
                                },
                                error: function ()
                                {
                                    dialog('Error', 'System has encountered an error', 'alert');
                                },
                                async: true
                            });
                        } else {
                            dialog('Failed', 'Failed Uploading Attachement', 'alert');
                        }
                    },
                });
            };

            $('#button-signoff-clear').on('click', function () {
                $('#button-signoff-view').data('pdf', '');
                $('#button-signoff-view').hide();
                $('#button-signoff-clear').hide();
                //Call ajax to remove
            });

            function followUpSignoffSubmit() {
                let id = $('#followUp-dialog').data('id');

                //Check mandatory before submit
                let mandatoryCheck = true;
                if (mandatoryCheck) {
                    //check for remarks
                    if ($('textarea[name=followUpEmail]').val() === '') {
                        dialog('Failed', 'Please key in remarks to sign off the quotation', 'alert');
                        return;
                    }
                    //check for proof
                    if ($('#button-signoff-view').data('pdf') === '' || $('#button-signoff-view').data('pdf') === undefined) {
                        dialog('Failed', 'Please upload proof to signoff (In PDF format)', 'alert');
                        return;
                    }
                }

                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController?type=plan&action=signoffQuotation',
                    data:
                            {
                                quotationId: id,
                                remarks: $('textarea[name=followUpEmail]').val(),
                                fileName: $('#button-signoff-view').data('pdf')
                            },
                    beforeSend: function () {
                        return confirm("Are you sure you want to sign off this quotation?");
                    },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', 'Quotation Signed Off', 'success');
                            } else
                            {
                                dialog('Failed', 'Unable to sign off quotation', 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    async: true
                });
                $('#followUp-dialog').data('dialog').close();
            }

            function followUpVoidSubmit()
            {
                let id = $('#followUp-dialog').data('id');

                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController?type=plan&action=voidQuotation',
                    data:
                            {
                                quotationId: id,
                                remarks: $('textarea[name=followUpEmail]').val(),
                            },
                    beforeSend: function () {
                        return confirm("Are you sure you want to void this quotation?");
                    },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', 'Quotation voided', 'success');
                            } else
                            {
                                dialog('Failed', 'Unable to void quotation', 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    async: true
                });
                $('#followUp-dialog').data('dialog').close();
            }

            function downloadTemplate() {
                console.log('downloadTemplate : ' + $('select[name=selectDescriptionTemplate]').val());

                if ($('select[name=selectDescriptionTemplate]').val() === '0')
                {
                    alert('Please Select Dropdown Description');

                } else
                {
                    window.open("ResusQuotationController?type=plan&action=getQuotationTemplate&quotationDescId=" + $('select[name=selectDescriptionTemplate]').val(), "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                }

//                if ($('select[name=selectDescriptionTemplate]').val()==='0'){
//                    alert('Please Select Dropdown Description');
//                }else{
//                    $.ajax({
//                        type: 'POST',
//                        url: 'ResusQuotationController',
//                        data: {
//                            type: 'plan',
//                            action: 'getQuotationTemplate',
//                            quotationDescId: $('select[name=selectDescriptionTemplate]').val()
//                        },
//                        beforeSend: function ()
//                        {
//
//                        },
//                        success: function (data)
//                        {
//                            console.log('header' + data.header);
//                            //quotationDescTable.refresh();
//                        },
//                        error: function ()
//                        {
//                            dialog('Error', 'System has encountered an error', 'alert');
//                        },
//                        complete: function ()
//                        {
//                        },
//                        async: false
//                    });
//                }
            }

            $('#button-import-excel').on('click', function () {
                $('#importExcel').click();
                return false;
            });

            let importExcel = document.getElementById("importExcel");
            importExcel.onchange = function () {
                let fd = new FormData();
                let file = $('#importExcel')[0].files[0];
                fd.append('file', file);

                $.ajax({
                    url: 'ResusQuotationController?type=plan&action=importExcel',
                    type: 'post',
                    data: fd,
                    contentType: false,
                    processData: false,
                    success: function (data) {
                        if (data != 0) {
                            //document.getElementById('GT').innerHTML = 'Grand Total : $0.00';

                            console.log(data.descHeader);

                            let header = quotationDescTable.getHeaders();
                            //console.log('header when calculateGradTotal runs :' + header);
                            //Note: APparently .getHEaders for jspreadsheet does not convert to Array properly when JSON.stringify. Thus I need to extract the data rebuild the array
                            let noOfColumnFromData = header.split(",");

                            //deconstruct header to generate column data
                            //let noOfColumn2 = data.descHeader.split(",");
                            let noOfColumnFromExcel = JSON.parse(data.descHeader);

                            let columnCheck = true;

                            if (noOfColumnFromData.length === noOfColumnFromExcel.length) {
                                //console.log('data and excel have the same number of column');
                                //Check if the column is the same
                                for (let i = 0; i < noOfColumnFromData.length; i++) {
                                    //console.log('noOfColumnFromData : ' + i + ' : ' + noOfColumnFromData[i]);
                                    //console.log('noOfColumnFromExcel : ' + i + ' : ' + noOfColumnFromExcel[i]);

                                    if (noOfColumnFromData[i] === noOfColumnFromExcel[i]) {

                                    } else {
                                        columnCheck = false;
                                    }

                                }
                            } else {
                                columnCheck = false;
                                console.log('data and excel does not have the same cumber of column');
                            }

                            if (columnCheck) {
//                                console.log('proccess data');

                                //document.getElementById('GT').innerHTML = 'Grand Total : $0.00';
//                                console.log('descHeader');
//                                console.log(data.descHeader);
//                                console.log('descWidth');
//                                console.log(data.descWidth);
//                                console.log('descData');
//                                console.log(data.descData);
//                                console.log('descBg');
//                                console.log(data.descBg);

                                //deconstruct header to generate column data
                                let noOfColumn = data.descHeader.split(",");
                                //console.log('noOfColumn' + noOfColumn.length);
                                let jsonColumnBuilder = [];
                                let columnObj = new Object();
                                for (let i = 0; i < noOfColumn.length; i++) {
                                    //console.log('Data' + noOfColumn[i]);
                                    columnObj.type = 'text';
                                    if (noOfColumn[i].includes('$')) {
                                        columnObj.mask = '$ #,##.00';
                                    }
                                    jsonColumnBuilder[i] = columnObj;
                                    columnObj = {};
                                }
                                //console.log('Final columnBuilder : ' + JSON.stringify(jsonBuilder));

                                if (quotationDescTable !== undefined) {
                                    quotationDescTable.destroy();
                                }
                                quotationDescTable = jspreadsheet(document.getElementById('spreadsheet'), {
                                    colHeaders: JSON.parse(data.descHeader),
                                    colWidths: JSON.parse(data.descWidth),
                                    columns: jsonColumnBuilder,
                                    data: JSON.parse(data.descData),
                                    type: 'text',
                                    wordWrap: true,
                                    columnSorting: false,
                                    allowInsertRow: true,
                                    allowManualInsertRow: false,
                                    allowInsertColumn: true,
                                    allowManualInsertColumn: false,
                                    copyCompatibility: false,
                                    onchange: calculateGradTotal,
                                    onselection: selectionActive
                                });

                                onQuotationDataRetrieveBg = JSON.parse(data.descBg);

                                let rows = $("#spreadsheet tr");
                                console.log('onQuotationDataRetrieveBg  : ' + onQuotationDataRetrieveBg)
                                if (onQuotationDataRetrieveBg !== '') {
                                    console.log('onQuotationDataRetrieveBg length : ' + onQuotationDataRetrieveBg.length)
                                    for (let i = 0; i < onQuotationDataRetrieveBg.length; i++) {
                                        console.log('colour : ' + onQuotationDataRetrieveBg[i]);
                                        rows[i + 1].style.backgroundColor = onQuotationDataRetrieveBg[i];
                                    }
                                }
                                onQuotationDataRetrieveBg = [];

                                calculateGradTotal();

                                alert('file uploaded');

                            } else {
                                //console.log('please use the correct format');
                                alert('please use the correct format');
                            }
                        } else {
                            alert('file not uploaded');
                        }
                    },
                });
                importExcel.value = null;
            };
        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage(data.getDisplayName())%></h1>
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
                <button class="toolbar-button" id=tool-button-edit name="edit" value="" title="<%=userProperties.getLanguage("edit")%>"><span class="mif-pencil"></span></button>
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
        <h3 class="text-light"><%=userProperties.getLanguage("searchBy")%></h3>
        <div id="specific-filter" class="grid filter-menu">

            <%                if (data.hasCustomFilterButton()) {
                    listFilter.outputHtml(data, userProperties, out);
                }
            %>

            <!--            <div class="container_quotation_update_status">
                            <div id="close_quotation" class="panel" style="width: 200px">
                                <div class="heading">
                                    <span class="title">Close Quotation</span>
                                </div>
                                <div class="content">
                                    <button class="button" type="button" title="Close Quotation" onclick="closeQuotation();"><span class="mif-checkmark"></span> Close</button>
                                </div>
                            </div>
                            <div id="follow_up_quotation" class="panel" style="width: 200px">
                                <div class="heading">
                                    <span class="title">Follow-Up Quotation</span>
                                </div>
                                <div class="content">
                                    <button class="button" type="button" title="Follow-Up Quotation" onclick="followUpQuotation();"><span class="mif-checkmark"></span> Follow-Up</button>
                                </div>
                            </div>
                        </div> -->

            <div class="container_list_number_filter">
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
                        if (data.hasSearchBox()) {
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

        <div data-role="dialog" id="job-customer-send-mail-dialog" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="mail-container">
                <h4 id="job-customer-name"></h4>
                <div class="input-control text full-size" style="margin: 15px 0px 20px 0px;">
                    <input type="hidden" id="job-customer-list-id">
                    <input id="job-customer-mail-id" type="text" maxlength="1000" placeholder="Enter Customer's email Address (If there are multiple addresses, use ',' to separate addresses)">
                </div>
                <button id="button-send-mail" type="button" class="button primary" onclick="sendEmail()">Send Mail</button>
            </div>
            <div id="jobs-container">
            </div>
        </div>

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

                                    //listForm.outputHtml(userProperties, data, dataHandler, out);
                                } catch (Exception e) {

                                } finally {
                                    dataHandler.closeConnection();
                                }
                            %>
                            <div class="grid">
                                <div class="row cells1" id="header1">
                                    <div class="cell">
                                        <label>Customer</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="dropdownCustomer" id="dropdownCustomerId">
                                                <option value="0">- Customer -</option>
                                                <%
                                                    resusCustomerDropDown.outputHTML(out, userProperties);
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells1" id="header1_2">
                                    <div class="cell">
                                        <label>Customer Name</label>
                                        <div class="input-control text full-size">
                                            <input type="text" name="customerName" maxlength="300" placeholder="Designation" value="" onkeydown="return (event.keyCode != 13);">
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells2" id="header2">
                                    <div class="cell">
                                        <label>Designation</label>
                                        <div class="input-control text full-size">
                                            <input type="text" name="designation" maxlength="300" placeholder="Designation" value="" onkeydown="return (event.keyCode != 13);">
                                        </div>
                                    </div>
                                    <div class="cell">
                                        <label>Attention To</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text full-size">
                                            <input type="text" name="attention_to" maxlength="300" placeholder="Attention To" value="" onkeydown="return (event.keyCode != 13);">
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells2" id="header3">
                                    <div class="cell">
                                        <label>Address</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control textarea full-size">
                                            <textarea name="address" maxlength="255" rows="3" placeholder="Address"></textarea>
                                        </div>
                                    </div>
                                    <div class="cell">
                                        <label>Email (Commas can be used to separate multiple recipients)</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control textarea full-size">
                                            <textarea name="email" maxlength="255" rows="3" placeholder="Email"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells1" id="header4">
                                    <div class="cell">
                                        <label>Header</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text full-size">
                                            <input type="text" name="quotationHeader" maxlength="300" placeholder="Header" onkeydown="return (event.keyCode != 13);">
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells2" id="header5">
                                    <div class="cell">
                                        <label>RE Contact Person</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="selectContactPerson" id="selectContactPersonId">
                                                <option value="0">- Select RE Contact Person -</option>
                                                <%
                                                    resusQuotationContactPsnDropDown.outputHTML(out, userProperties);
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="cell">
                                        <label>Quotation Type</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="quotationType" id="quotationTypeId">
                                                <option value="0">- Select Quotation Type -</option>
                                                <%
                                                    resusQuotationTypeDropDown.outputHTML(out, userProperties);
                                                %>
                                            </select>
                                        </div>
                                    </div>        
                                </div>
                                <div class="row cells2" id="header5_2">
                                    <div class="cell">
                                        <label>Quotation Period Start</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text" data-role="input" >
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="dateTimePicker-date-start-id" name="dateTimePicker_date_start" class="start" type="text" placeholder="" value="" readonly="" style="padding-right: 36px;">
                                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                    <div class="cell">
                                        <label>Quotation Period End</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text" data-role="input" >
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="dateTimePicker-date-end-id" name="dateTimePicker_date_end" class="end" type="text" placeholder="" value="" readonly="" style="padding-right: 36px;">
                                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                </div>
                                <!-- operationIc -->
                                <div class="row cells1">
                                    <div class="cell">
                                        <label>Operation In-Charge</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div id="all-prop" style="margin-top: 5px;">
                                        </div>

                                        <div id="add-prop-btn" style="margin-top: 5px;" onclick="showAddOperatorIc()">
                                            <div class="add-box">
                                                <div class="add-icon"></div>
                                                <div class="single-add">Add New</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row cells1" id="add-operationIc">
                                    <div class="cell">
                                        <div style="float: left; height: 40px;">
                                            <div class="input-control select" style="float: left; min-width: 0px; ">
                                                <select id ="operationIc" name="operationIc" style="font-size: 18px;">
                                                </select>
                                            </div>

                                            <div style="float: left; margin-left: 10px;">
                                                <div class="confirm-icon" title="Confirm" onclick="addOperatorIc()"></div>
                                                <div class="cancel-icon"  title="Cancel" onclick="hideAddOperatorIc()"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row cells2" id="header6">
                                    <div class="cell">
                                        <label>Description</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="selectDescriptionTemplate" id="selectDescriptionTemplateId">
                                                <option value="0">- Select Description Template -</option>
                                                <%
                                                    resusQuotationDescDropDown.outputHTML(out, userProperties);
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="row cells1" id="header10">
                                    <button id="button-download-excel" type="button" class="button" onclick="downloadTemplate()" style="float:left; margin-right:10px">Download Template</button>

                                    <input id="importExcel" accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" name="importExcel" type="file" class="file" style="display: none;"/>
                                    <button id="button-import-excel" class="button" style="float:left; margin-right:10px">Import Excel</button>
                                    <!--                                    <form method="post" action="" enctype="multipart/form-data" id="myform">
                                                                        <div>
                                                                            <input id="fileExcel" type="file" class="file" accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" >
                                                                            <button id="importExcel">Import Excel</button>
                                                                        </div>
                                                                        </form>-->
                                </div>            


                                <div id="header9">
                                    <select id="setRowColour">
                                        <option value="white" selected>Clear</option>          
                                        <option value="cyan">Cyan</option>
                                        <option value="lime">Green</option>
                                        <option value="orange">Orange</option>
                                        <option value="lightsalmon">Red</option>  
                                        <option value="yellow">Yellow</option>
                                    </select>
                                    <button id=button-cancel type="button" class="button" onclick="changeColour()">Change Colour</button>
                                    </br>
                                    </br>
                                </div>
                                <div id="spreadsheet"></div>
                                <div id="addRowSpreadsheet">
                                    </br>
                                    <button id=button-cancel type="button" class="button" onclick="addRowsWithData()">Add Row</button>
                                    <button id=button-cancel type="button" class="button" onclick="deleteRowsUpdateData()">Delete Row</button>
                                </div>
                                <div id="calculateGrandTotalDiv">
                                    </br>
                                    <div class="row cells1">
                                        <div class="cell">
                                            <label id = "GT">Grand Total</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells2" id="header7">
                                    <div class="cell">
                                        </br>
                                        <label>Select Authoriser</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="selectAuthoriser" id="selectAuthoriserId">
                                                <option value="0">- Select Authoriser -</option>
                                                <%--
                                                    resusAuthoriserDropDown.outputHTML(out, userProperties);
                                                --%>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="cell">
                                        </br>
                                        <label>Billing Type</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="billingType" id="billingTypeId">
                                                <option value="0">- Select Billing Type-</option>
                                                <option value="1">Daily</option>
                                                <option value="2">Weekly</option>
                                                <option value="3">Monthly</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="row cells2" id="header8">
                                    <div class="cell">
                                        <label>Validity</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text full-size">
                                            <input type="number" name="validity" maxlength="300" placeholder="Validity" value="" onkeydown="return (event.keyCode != 13);">
                                        </div>
                                    </div>
                                    <div class="cell">
                                        <label>Duration Type</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control select full-size">
                                            <select name="durationType" id="durationTypeId">
                                                <option value="0">- Select Duration Type-</option>
                                                <option value="1">Day</option>
                                                <option value="2">Week</option>
                                                <option value="3">Month</option>
                                                <option value="4">Year</option>
                                            </select>
                                        </div>
                                    </div>        
                                </div>
                                <!--                                <div id="header8">
                                                                    </br>
                                                                </div>-->

                                <div class="row cells2" id="termsCondition">
                                    <label>Terms and Conditions</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    </br>
                                    <div id="my-spreadsheet"></div>
                                </div>
                                <div id="spreadsheet-preview"></div>
                            </div>                      
                        </div>

                        <div>
                            <%
                                    //data.outputHtml(userProperties, out);
                                    String jspPath = data.outputJsp();

                                    if (!jspPath.equals("")) {
                                        request.setAttribute("properties", userProperties);

                                        pageContext.include(jspPath);
                                    }
                                } catch (Exception e) {

                                } finally {

                                }
                            %>
                        </div>

                    </form>

                </div>    
            </div>
            <div class="form-dialog-control">
                <div class="row">     
                    <div class="column">
                        <input id="file" class="file" accept="application/pdf" name="fileToUpload" type="file" style="display: none;"/>
                        <button id="button-add-attachment" class="button" style="float:left; margin-right:10px">Upload Attachment</button>
                        <button id=button-view type="button" class="button primary" style="float:left; margin-right:10px; display:none;">View Attachment</button>
                        <button id=button-clear type="button" class="mif-cross cycle-button" style="float:left; display:none;"></button>
                    </div>
                    <div class="column">
                        <button id=button-save type="button" class="button primary" onclick="saveQuotationForm()"><%=userProperties.getLanguage("save")%></button>
                        <button id=button-save-operation-in-charge type="button" class="button primary" onclick="updateOperationInCharge()">Update</button>
                        <button id=button-cancel type="button" class="button" onclick="closeForm()"><%=userProperties.getLanguage("cancel")%></button>
                        <button id=button-preview type="button" class="button" onclick="previewQuotation()">Preview</button>
                    </div>
                </div>
            </div>
        </div>

        <div data-role="dialog" id=operator-dialog class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <div class="grid">
                                <!-- operationIc -->
                                <div class="row cells1">
                                    <div class="cell">
                                        <label>Operation In-Charge</label>
                                        <div id="all-prop" style="margin-top: 5px;">
                                        </div>

                                        <div id="add-prop-btn" style="margin-top: 5px;" onclick="showAddOperatorIc()">
                                            <div class="add-box">
                                                <div class="add-icon"></div>
                                                <div class="single-add">Add New</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row cells1" id="add-operationIc">
                                    <div class="cell">
                                        <div style="float: left; height: 40px;">
                                            <div class="input-control select" style="float: left; min-width: 0px; ">
                                                <select id ="operationIc" name="operationIc" style="font-size: 18px;">
                                                </select>
                                            </div>

                                            <div style="float: left; margin-left: 10px;">
                                                <div class="confirm-icon" title="Confirm" onclick="addOperatorIc()"></div>
                                                <div class="cancel-icon"  title="Cancel" onclick="hideAddOperatorIc()"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>                      
                        </div>
                    </form>

                </div>    
            </div>
            <div class="form-dialog-control">
                <div class="row">     
                    <div class="column">
                    </div>
                    <div class="column">
                        <button id=button-save type="button" class="button primary" onclick="saveQuotationForm()"><%=userProperties.getLanguage("save")%></button>
                        <button id=button-cancel type="button" class="button" onclick="closeForm()"><%=userProperties.getLanguage("cancel")%></button>
                    </div>
                </div>
            </div>
        </div>

        <div data-role="dialog" id="closeQuotation-dialog" class="padding20" data-close-button="true" data-width="550" data-height="300" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=closeQuotation-dialog-title class="text-light">Close Quotation</h1>
            <p id="closeQuotation-dialog-content">Please enter some remarks</p>
            <p></p>
            <textarea name="closeRemarks" data-role="textarea" cols="70" rows="8"></textarea>
            <div class="form-dialog-control">
                <button id=button-void-quotation type="button" class="button alert" onclick="voidQuotation()">Void Quotation</button>
                <button id=button-terminate-quotation type="button" class="button alert" onclick="voidQuotation()">Terminate Quotation</button>
                <button id=button-reject-quotation type="button" class="button alert" onclick="rejectQuotation()">Reject Quotation</button>
                <button id=button-close-quotation type="button" class="button" onclick="closeSignoffForm()">Cancel</button>
            </div>
        </div>  

        <div data-role="dialog" id="followUp-dialog" class="padding20" data-close-button="true" data-width="550" data-height="150" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=followUpQuotation-dialog-title class="text-light">Follow-Up RCS/23/MAR/0006</h1>
            <p id=followUpQuotation-dialog-content></p>
            <p></p>
            <textarea name="followUpEmail" data-role="textarea" cols="70" rows="9"></textarea>
            <div class="form-dialog-control">
                <div class="float-left">
                    <input id="fileSignOff" class="file" accept="application/pdf" name="fileSignoffToUpload" type="file" style="display: none;"/>
                    <button id="button-signoff-add-attachment" class="button" style="float:left; margin-right:10px">Upload Attachment</button>
                    <button id="button-signoff-view" type="button" class="button primary" style="float:left; margin-right:10px; display:none;">View Attachment</button>
                    <button id="button-signoff-clear" type="button" class="mif-cross cycle-button" style="float:left; display:none;"></button>
                </div>
                <div class="float-left">
                    <button id=button-followup-void type="button" class="button alert" onclick="followUpVoid()">Void</button>
                    <button id=button-followup-void-submit type="button" class="button alert" onclick="followUpVoidSubmit()">Void</button>
                    <button id=button-followup-recall-bd type="button" class="button warning" onclick="followUpRecallBd()">Recall</button>
                    <button id=button-followup-recall-cust type="button" class="button warning" onclick="followUpRecallCust()">Recall</button>
                    <button id=button-followup-recall-submit type="button" class="button warning" onclick="followUpRecallSubmit()">Recall</button>
                </div>

                <div class="float-right">
                    <button id=button-followup-reauthorise type="button" class="button primary" onclick="followAuthorise()">Re-Send for Authorization</button>
                    <button id=button-followup-authorise type="button" class="button primary" onclick="followAuthorise()">Send for Authorization</button>
                    <button id=button-followup-signoff type="button" class="button" onclick="followUpSignoff()">SignOff</button>
                    <button id=button-followup-signoff-submit type="button" class="button" onclick="followUpSignoffSubmit()">SignOff</button>
                    <button id=button-followup-email type="button" class="button" onclick="followUpEmail()">Email</button>
                    <button id=button-followup-send type="button" class="button" onclick="sendFOllowUpEmail()">Send Email</button>
                    <!--<button id=button-followup-link type="button" class="button" onclick="followUpLink()">Link</button>-->
                    <button id=button-followup-copy type="button" class="button" onclick="copyLink()">Copy Link</button>
                    <button id=button-followup-cancel type="button" class="button" onclick="cancel()">Cancel</button>
                </div>
            </div>
        </div>  
    </body>
</html>
