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

    Locale locale = userProperties.getLocale();

    Connection con = null;

    String lib = "v3nity.cust.biz.resus.data";

    String type = "ResusJobsheetMaster";

    ListData data = new ResusJobsheetMaster();

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

            $("#dateTimePicker-date-of-commencement-id").AnyTime_picker({format: "%d/%m/%Y"});
            $("#dateTimePicker-date-of-completion-id").AnyTime_picker({format: "%d/%m/%Y"});
            
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

            function previewJobsheet() {

                var pdfName = $('#button-view').data('pdf');

                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }

                let creatorUserIdPreview = <%=userProperties.getUser().getId()%>;
                let company_name = $('input[name=company_name]').val();
                let postal_code = $('input[name=postal_code]').val();
                let customer_name = $('input[name=customer_name]').val();
                let designation = $('input[name=designation]').val();
                let tel_no = $('input[name=tel_no]').val();
                let fax_no = $('input[name=fax_no]').val();
                let date_of_commencement = $('input[name=dateTimePicker_date_of_commencement]').val();
                let date_of_completion = $('input[name=dateTimePicker_date_of_completion]').val();
                let purchase_order = $('input[name=purchase_order]').val();
                let payment_term = $('input[name=payment_term]').val();
                let cost_centre = $('input[name=cost_centre]').val();
                let amount = $('input[name=amount]').val();
                let approved_by = $('input[name=approved_by]').val();
                let completed_by = $('input[name=completed_by]').val();
                let job_description = $('textarea[name=job_description]').val();
                let billing_address = $('textarea[name=billing_address]').val();
                let remarks = $('textarea[name=remarks]').val();
                let email = $('textarea[name=email]').val();

                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'savePreviewJobsheet',
                        company_name: company_name,
                        postal_code: postal_code,
                        customer_name: customer_name,
                        designation: designation,
                        tel_no: tel_no,
                        fax_no: fax_no,
                        date_of_commencement: date_of_commencement,
                        date_of_completion: date_of_completion,
                        purchase_order: purchase_order,
                        payment_term: payment_term,
                        cost_centre: cost_centre,
                        job_description: job_description,
                        remarks: remarks,
                        amount: amount,
                        approved_by: approved_by,
                        completed_by: completed_by,
                        address: billing_address,
                        email: email,
                        creatorUserIdPreview: creatorUserIdPreview,
                        jobsheet_document: pdfName

                    },
                    beforeSend: function ()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            console.log("data.result true with id " + data.id);
                            var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadJobsheetPreview&id=" + data.id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
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
                        $('#button-save').prop("disabled", false);
                    },
                    async: false
                });

            }

            function saveJobsheetForm()
            {
                //addJobSheetDataWithQuotation
                //editJobSheetDataWithQuotation
                //console.log("Add|Edit for Ref ID" + quotationRefInit);
                var action = $('#button-save').data('action');
                var jobsheetId = $('#button-save').data('jobsheetId');
                //var quotationId = $('#button-save').data('quotationId');
                console.log("action : " + action);
                console.log("jobsheetId : " + jobsheetId);
                //console.log("quotationId : " + quotationId);


                var pdfName = $('#button-view').data('pdf');
                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }
                console.log("pdfName : " + pdfName);

                if ($('input[name=company_name]').val().trim().length === 0) {
                    dialog('Error', 'Please key in company name', 'alert');
                    return;
                }
                if ($('textarea[name=billing_address]').val().trim().length === 0) {
                    dialog('Error', 'Please key in billing address', 'alert');
                    return;
                }
                if ($('input[name=customer_name]').val().trim().length === 0) {
                    dialog('Error', 'Please key in customer name', 'alert');
                    return;
                }
                if ($('input[name=tel_no]').val().trim().length === 0) {
                    dialog('Error', 'Please key in telephone number', 'alert');
                    return;
                }
                if ($('textarea[name=email]').val().trim().length === 0) {
                    dialog('Error', 'Please key in email', 'alert');
                    return;
                }
                if ($('input[name=dateTimePicker_date_of_commencement]').val().trim().length === 0) {
                    dialog('Error', 'Please key in date of commencement', 'alert');
                    return;
                }
                if ($('input[name=dateTimePicker_date_of_completion]').val().trim().length === 0) {
                    dialog('Error', 'Please key in date of completion', 'alert');
                    return;
                }
                if  ($('select[name=dropdownOrderType]').val() === '0') {
                        dialog('Error', 'Please select Job Order Type', 'alert');
                        return;
                }
                if ($('textarea[name=job_description]').val().trim().length === 0) {
                    dialog('Error', 'Please key in the job description', 'alert');
                    return;
                }
                if ($('input[name=amount]').val().trim().length === 0) {
                    dialog('Error', 'Please key in the amount', 'alert');
                    return;
                }
                if ($('input[name=completed_by]').val().trim().length === 0) {
                    dialog('Error', 'Please key in completed by', 'alert');
                    return;
                }

                let jobsheetType = 'withQuotation';
//                if ($('input[name="partialCheckBox"]').prop("checked") === false) {
//                    jobsheetType = 'withQuotation';
//                } else {
//                    jobsheetType = 'partial';
//                }

                let company_name = $('input[name=company_name]').val();
                let postal_code = $('input[name=postal_code]').val();
                let customer_name = $('input[name=customer_name]').val();
                let designation = $('input[name=designation]').val();
                let tel_no = $('input[name=tel_no]').val();
                let fax_no = $('input[name=fax_no]').val();
                let date_of_commencement = $('input[name=dateTimePicker_date_of_commencement]').val();
                let date_of_completion = $('input[name=dateTimePicker_date_of_completion]').val();
                let purchase_order = $('input[name=purchase_order]').val();
                let payment_term = $('input[name=payment_term]').val();
                let cost_centre = $('input[name=cost_centre]').val();
                let amount = $('input[name=amount]').val();
                let approved_by = $('input[name=approved_by]').val();
                let completed_by = $('input[name=completed_by]').val();
                let job_description = $('textarea[name=job_description]').val();
                let billing_address = $('textarea[name=billing_address]').val();
                let remarks = $('textarea[name=remarks]').val();
                let email = $('textarea[name=email]').val();
                let jobsheetCreatorId = <%=userProperties.getUser().getId()%>;

                console.log("jobsheetCreatorId : " + jobsheetCreatorId);

                //Create JobSheet
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: action,
                        jobsheet_type: jobsheetType,
                        company_name: company_name,
                        postal_code: postal_code,
                        customer_name: customer_name,
                        designation: designation,
                        tel_no: tel_no,
                        fax_no: fax_no,
                        date_of_commencement: date_of_commencement,
                        date_of_completion: date_of_completion,
                        purchase_order: purchase_order,
                        payment_term: payment_term,
                        cost_centre: cost_centre,
                        job_description: job_description,
                        remarks: remarks,
                        amount: amount,
                        approved_by: approved_by,
                        completed_by: completed_by,
                        address: billing_address,
                        email: email,
                        id: jobsheetId,
                        operatorId: jobsheetCreatorId,
                        jobsheetDoc: pdfName
                    },
                    beforeSend: function ()
                    {
                        //$('#button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            dialog('Success', data.text, 'success');
                            closeAddJobsheet();
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
                        //$('#button-save').prop("disabled", false);  
                    },
                    async: false
                });
            }

            function closeAddJobsheet()
            {
                refreshDataTable();
                $('#form-dialog-master').data('dialog').close();
                clearJobsheetDataInDialog();
            }

            function clearJobsheetDataInDialog() {
                $('input[name=company_name]').val('');
                $('input[name=postal_code]').val('');
                $('input[name=customer_name]').val('');
                $('input[name=designation]').val('');
                $('input[name=tel_no]').val('');
                $('input[name=fax_no]').val('');
                $('input[name=dateTimePicker_date_of_commencement]').val('');
                $('input[name=dateTimePicker_date_of_completion]').val('');
                $('input[name=purchase_order]').val('');
                $('input[name=payment_term]').val('');
                $('input[name=cost_centre]').val('');
                $('input[name=amount]').val('');
                $('input[name=approved_by]').val('');
                $('input[name=completed_by]').val('');
                $('textarea[name=job_description]').val('');
                $('textarea[name=billing_address]').val('');
                $('textarea[name=remarks]').val('');
                $('textarea[name=email]').val('');
                $('#button-view').data('pdf', '');
            }

            function clearForm()
            {

                document.getElementById('form-dialog-data').reset();

                listForm.reset();

                listFields.forEach(function (value, index)
                {
                    value.clear();
                });

                refreshDataTable();
            }

            function closeForm()
            {

                $('#form-dialog-master').data('dialog').close();

                clearForm();
            }

            function getJobsheetData(id)
            {
                console.log('getJobsheetData');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: jobsheetId
                    },
                    success: function (data)
                    {
                        result = true;
                        $('input[name=company_name]').val(data.jobsheet_company_name);
                        $('input[name=postal_code]').val(data.jobsheet_billing_postal_code);
                        $('input[name=customer_name]').val(data.jobsheet_billing_contact_person);
                        $('input[name=designation]').val(data.jobsheet_billing_designation);
                        $('input[name=tel_no]').val(data.jobsheet_billing_tel_no);
                        $('input[name=fax_no]').val(data.jobsheet_billing_fax_no);
                        $('input[name=dateTimePicker_date_of_commencement]').val(data.jobsheet_date_start);
                        $('input[name=dateTimePicker_date_of_completion]').val(data.jobsheet_date_end);
                        $('input[name=purchase_order]').val(data.jobsheet_po);
                        $('input[name=payment_term]').val(data.jobsheet_payment_terms);
                        $('input[name=cost_centre]').val(data.jobsheet_cost_centre);
                        $('input[name=amount]').val(data.jobsheet_amount);
                        //amount = data.jobsheet_amount;
                        $('input[name=approved_by]').val(data.jobsheet_approved_by);
                        $('input[name=completed_by]').val(data.jobsheet_completed_by);
                        $('textarea[name=job_description]').val(data.jobsheet_job_description);
                        $('textarea[name=billing_address]').val(data.jobsheet_billing_address);
                        $('textarea[name=remarks]').val(data.jobsheet_remarks);
                        $('textarea[name=email]').val(data.jobsheet_billing_email);
                        //quotationId = data.jobsheet_quotation_id;
                        console.log('data.jobsheet_document ' + data.jobsheet_document);
                        $('#button-view').data('pdf', data.jobsheet_document);

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

            //To edit Job Sheet tied to the quotation
            function editJobSheet(jobsheetId)
            {
                //get jobsheet data
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: jobsheetId
                    },
                    success: function (data)
                    {
                        result = true;
                        $('input[name=company_name]').val(data.jobsheet_company_name);
                        $('input[name=postal_code]').val(data.jobsheet_billing_postal_code);
                        $('input[name=customer_name]').val(data.jobsheet_billing_contact_person);
                        $('input[name=designation]').val(data.jobsheet_billing_designation);
                        $('input[name=tel_no]').val(data.jobsheet_billing_tel_no);
                        $('input[name=fax_no]').val(data.jobsheet_billing_fax_no);
                        $('input[name=dateTimePicker_date_of_commencement]').val(data.jobsheet_date_start);
                        $('input[name=dateTimePicker_date_of_completion]').val(data.jobsheet_date_end);
                        $('input[name=purchase_order]').val(data.jobsheet_po);
                        $('input[name=payment_term]').val(data.jobsheet_payment_terms);
                        $('input[name=cost_centre]').val(data.jobsheet_cost_centre);
                        $('input[name=amount]').val(data.jobsheet_amount);
                        $('input[name=approved_by]').val(data.jobsheet_approved_by);
                        $('input[name=completed_by]').val(data.jobsheet_completed_by);
                        $('textarea[name=job_description]').val(data.jobsheet_job_description);
                        $('textarea[name=billing_address]').val(data.jobsheet_billing_address);
                        $('textarea[name=remarks]').val(data.jobsheet_remarks);
                        $('textarea[name=email]').val(data.jobsheet_billing_email);
                        console.log('data.jobsheet_document ' + data.jobsheet_document);
                        $('#button-view').data('pdf', data.jobsheet_document);

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
                $('#button-save').data('action', 'editJobSheetDataWithoutQuotation');
                $('#button-save').data('jobsheetId', jobsheetId);

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

                console.log('editJobSheet');
                console.log('jobsheetId:' + jobsheetId);
                //console.log('refNo : ' + quotationRef)

                $('#form-dialog-master').data('dialog').open();
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

            function downloadJobsheet(id) {
                var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadJobsheet&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
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
                        return confirm("Are you sure you want to send this quotation for authorization?");
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
                //show dialog box
            }

            function signOffJobsheet(id, jobsheetNo) {
                let link = '<%=domainUrl%>' + "jobsheetSignoff?id=" + id;
                $('#button-yes').data('id', id);
                $('#button-email').data('id', id);
                $('#button-email').data('link', link);
                $('#button-link').data('id', id);
                $('#button-link').data('link', link);
                $('#button-nosigning').data('id', id);
                $('#signoff-dialog-title').html('Signoff JS No:' + jobsheetNo);
                $('#signoff-dialog-content').html('');
                $('#button-email').show();
                $('#button-link').show();
                $('#button-nosignoff').show();
                $('#button-close').show();
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#signoff-dialog').data('dialog').open();
            }

            function closeSignoffForm() {
                $('#signoff-dialog').data('dialog').close();
            }

            function signOffEmail() {
                $('#button-yes').data('action', 'signOffByEmail');
                $('#signoff-dialog-content').html('Sign Off By Email?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
            }
            function signOffLink() {
                $('#button-yes').data('action', 'signOffByLink');
                $('#signoff-dialog-content').html('Sign Off By Link?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
            }
            function noSignOff() {
                $('#button-yes').data('action', 'noSignOff');
                $('#signoff-dialog-content').html('No Sign Off Needed?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
            }
            function selectYesSignoff() {

                var id = $('#button-yes').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: $('#button-yes').data('action'),
                        id: id
                    },
                    success: function (data)
                    {
                        if (data.result === true) {
                            //refreshDataTable_${namespace}();
                            refreshDataTable();
                            jobsheetShowResultViaPromptBeforeClose();
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

            function jobsheetShowResultViaPromptBeforeClose() {
                console.log('jobsheetShowResultViaPromptBeforeClose');
                let action = $('#button-yes').data('action');
                if (action === 'signOffByEmail') {
                    $('#signoff-dialog-content').html('Email is sent to customer');
                } else if (action === 'signOffByLink') {
                    let urlLink = $('#button-link').data('link');
                    $('#signoff-dialog-content').html('Please copy and send this link to customer : <br>' + urlLink);
                } else if (action === 'noSignOff') {
                    $('#signoff-dialog-content').html('Jobsheet is close without sign off');
                }
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#button-close').show();
            }

            function selectNoSignoff() {
                $('#signoff-dialog').data('dialog').close();
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
                    url: 'ResusJobsheetController?type=plan&action=uploadJobsheetAttachment',
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
                var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadAttachment&filename=" + pdfName, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            });

        </script>
    </head>
    <body>
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

        <div data-role="dialog" id="signoff-dialog" class="padding20" data-close-button="true" data-width="500" data-height="200" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=signoff-dialog-title class="text-light"></h1>
            <p id="signoff-dialog-content"></p>
            <div class="form-dialog-control">
                <button id=button-yes type="button" class="button" onclick="selectYesSignoff()">Yes</button>
                <button id=button-no type="button" class="button" onclick="selectNoSignoff()">No</button>
                <button id=button-email type="button" class="button primary" onclick="signOffEmail()">Via Email</button>
                <button id=button-link type="button" class="button alert" onclick="signOffLink()">Via Link</button>
                <button id=button-nosignoff type="button" class="button" onclick="noSignOff()">No Sign Off</button>
                <button id=button-close type="button" class="button" onclick="closeSignoffForm()">Close</button>
            </div>
        </div>

        <div data-role="dialog" id=form-dialog-master class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
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
                        </div>
                        <div class="grid">
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Company Name</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="company_name" maxlength="300" placeholder="">
                                    </div>
                                    <!--                                    <label>Postal Code</label>
                                                                        <span style="color: red; font-weight: bold"> *</span>
                                                                        <div class="input-control text full-size">
                                                                            <input type="text" name="postal_code" maxlength="300" placeholder="">
                                                                        </div>-->
                                </div>
                                <div class="cell">
                                    <label>Billing Address</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control textarea full-size">
                                        <textarea name="billing_address" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Customer Name</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="customer_name" maxlength="300" placeholder="">
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Designation</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="designation" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Tel No:</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="tel_no" maxlength="300" placeholder="">
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Fax No:</label>
                                    <div class="input-control text full-size">
                                        <input type="text" name="fax_no" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Email</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control textarea full-size">
                                        <textarea name="email" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                                <div class="cell">
                                    <div>
                                        <label>Date of Commencement</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text" data-role="input" >
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="dateTimePicker-date-of-commencement-id" name="dateTimePicker_date_of_commencement" class="start" type="text" placeholder="" value="" readonly="" style="padding-right: 36px;">
                                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                    <div>
                                        <label>Date of Completion</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text" data-role="input" >
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="dateTimePicker-date-of-completion-id" name="dateTimePicker_date_of_completion" class="end" type="text" placeholder="" value="" readonly="" style="padding-right: 36px;">
                                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells1">
                                <div class="cell">
                                    <label>Purchase Order No</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="purchase_order" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <!--                                <div class="cell">
                                                                    <label>Payment Term</label>
                                                                    <div class="input-control text full-size">
                                                                        <input type="text" name="payment_term" maxlength="300" placeholder="">
                                                                    </div>
                                                                </div>-->
                                <div class="cell">
                                    <label>Cost Centre</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="cost_centre" maxlength="300" placeholder="">
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Order Type</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="cost_centre" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Job Description</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control textarea full-size">
                                        <textarea name="job_description" maxlength="5000" rows="8" placeholder=""></textarea>
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Amount</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="number" name="amount" maxlength="10" placeholder="">
                                    </div>
                                    <label>Remarks</label>
                                    <div class="input-control text full-size">
                                        <textarea name="remarks" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <!--                                <div class="cell">
                                                                    <label>Approved By</label>
                                                                    <span style="color: red; font-weight: bold"> *</span>
                                                                    <div class="input-control text full-size">
                                                                        <input type="text" name="approved_by" maxlength="300" placeholder="">
                                                                    </div>
                                                                </div>-->
                                <div class="cell">
                                    <label>Completed By</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="completed_by" maxlength="300" placeholder="">
                                    </div>
                                </div>
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
                    <div class="column" style="float:left; width:60%;">
                        <input id="file" class="file" accept="application/pdf" name="fileToUpload" type="file" style="display: none;"/>
                        <button id="button-add-attachment" class="button" style="float:left; margin-right:10px">Upload Attachment</button>
                        <button id=button-view type="button" class="button primary" style="float:left; margin-right:10px; display:none;">View Attachment</button>
                        <button id=button-clear type="button" class="mif-cross cycle-button" style="float:left; display:none;"></button>
                    </div>
                    <div class="column" style="float:left; width:40%;">
                        <button id=button-save type="button" class="button primary" onclick="saveJobsheetForm()"><%=userProperties.getLanguage("save")%></button>
                        <button id="button-cancel" type="button" class="button" onclick="closeForm()"><%=userProperties.getLanguage("close")%></button>
                        <button id=button-preview type="button" class="button" onclick="previewJobsheet()">Preview</button>
                    </div>
                </div>
            </div>
        </div>

    </body>
</html>
