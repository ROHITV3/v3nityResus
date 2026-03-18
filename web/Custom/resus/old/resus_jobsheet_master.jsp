<%--
    Document   : wars_work_order_plan
    Created on : 23 Mar, 2022, 1:24:58 PM
    Author     : Kevin
--%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.cust.biz.resus.data.*"%>
<%

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    int custId = listProperties.getUser().getInt("customer_id");
    
    int userId = listProperties.getUser().getId();

    String domainUrl = listProperties.getSystemProperties().getDomainURL();

    Connection con = null;

    String lib = "v3nity.cust.biz.resus.data";

    String type = "ResusJobsheet";

    ResusJobsheetDataHandler dataHandler = new ResusJobsheetDataHandler();

    Connection connection = null;

    //JSONArray staffList = null;
    //JSONArray warrantStatusList = null;
    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

        //staffList = dataHandler.getStaffList(listProperties.getUser().getInt("customer_id"));
        //warrantStatusList = dataHandler.getWarrantStatusList();
    } catch (Exception e) {

    } finally {
        listProperties.getDatabasePool().closeConnection(connection);
    }

//    CtmcsAreaDropDown ctmcsAreaDropDown = new CtmcsAreaDropDown(listProperties);
//    ctmcsAreaDropDown.setIdentifier("dropdown-area");
//    ctmcsAreaDropDown.loadData(listProperties);
//
//    CtmcsFormDropDown ctmcsFormDropDown = new CtmcsFormDropDown(listProperties);
//    ctmcsFormDropDown.setIdentifier("dropdown-form");
//    ctmcsFormDropDown.loadData(listProperties);
//    
//    CtmcsFreqTypeDropDown ctmcsFreqTypeDropDown = new CtmcsFreqTypeDropDown(listProperties);
//    ctmcsFreqTypeDropDown.setIdentifier("dropdown-freq-type");
//    ctmcsFreqTypeDropDown.loadData(listProperties);

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>work order plan</title>
        <link href="Custom/resus/resusCustom.css" rel="stylesheet">
        <style type="text/css">
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
            
            .float-left{
                float:left; 
            }
        </style> 
        <script>
            var requireOverallCount = true;

            $(document).ready(function ()
            {
                //Hide main toobar
                $('div.toolbar').hide();
            });

            function previewJobsheet() {

                var pdfName = $('#button-view').data('pdf');

                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }

                let creatorUserIdPreview = <%=listProperties.getUser().getId()%>;
                let company_name = $('textarea[name=company_name]').val();
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
//                let cost_centre_dropdown = $("#dropdownCostCentreId option:selected").text();
//                if ($("#dropdownCostCentreId option:selected").val()==='0'){
//                    cost_centre_dropdown = '';
//                }
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
                        id: id
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

            function closeAddJobsheet()
            {
                refreshDataTable();
                $('#ListCustom-form-dialog').data('dialog').close();
                clearJobsheetDataInDialog();
            }

            function endJobsheet(id, jobsheetNo)
            {
                console.log('id : ' + id);
                console.log('jobsheetNo : ' + jobsheetNo);
                $('textarea[name=closeRemarks]').val('');
                $('#closeQuotation-dialog-title').html('Close Jobsheet - ' + jobsheetNo);
                $('#button-void-quotation').show();
                $('#button-void-quotation').data('id', id);
                $('#closeQuotation-dialog').data('dialog').open();
            }

            function cancelEndJobsheet() {
                $('#closeQuotation-dialog').data('dialog').close();
            }

            function closeJobsheet()
            {
                var jobsheetId = $('#button-void-quotation').data('id');
                
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController?type=plan&action=closeJobsheet',
                    data:
                            {
                                jobsheetId: jobsheetId,
                                remarks: $('textarea[name=closeRemarks]').val(),
                            },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', 'Jobsheet Closed', 'success');
                            } else
                            {
                                dialog('Failed', 'Unable to close jobsheet', 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    async: true
                });
                $('#closeQuotation-dialog').data('dialog').close();
            }

            function clearJobsheetDataInDialog() {
                $('select[name=dropdownCustomer]').val(0);
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

            function refreshDataTable()
            {
                requireOverallCount = true;

                //refreshPageLength_ResusJobsheet();
                refreshPageLength_${namespace}();

            }

            function refreshPageLength()
            {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength))
                {
                    var table = $('#${namespace}-result-table').DataTable();

                    table.page.len(pageLength).draw();
                } else
                {
                    //refreshPageLength_ResusJobsheet();
                    refreshPageLength_${namespace}();
                }
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
                        $('textarea[name=company_name]').val(data.jobsheet_company_name);
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
//                        var dd = document.getElementById('dropdownCostCentreId');
//                        var cost_centre_found = false;
//                        for (var i = 0; i < dd.options.length; i++) {
//                            if (dd.options[i].text === data.jobsheet_cost_centre) {
//                            dd.selectedIndex = i;
//                            cost_centre_found = true;
//                            break;
//                            }
//                        }
//                        console.log("cost center found : " + cost_centre_found);
//                        if (!cost_centre_found){
//                            $('select[name=dropdownCostCentre]').val(0);
//                        }
                        
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
            
            function getJobsheetEmailOnlyForSignOFf(id)
            {
                console.log('getJobsheetData');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: id
                    },
                    success: function (data)
                    {
                        result = true;
                        $('textarea[name=signOffTextArea]').val(data.jobsheet_billing_email);
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
            
           function signOffJobsheet(id, jobsheetNo) {
                
                let link = '<%=domainUrl%>' + "jobsheetSignoff?id=" + id;
                
                var table = $('#${namespace}-result-table').DataTable();

                const dtrow = table.row('#' + id);

                var testColIndexStatus = table.column(':contains(Job Sheet Status Type)');
                var testColIndexRefNo = table.column(':contains(Ref Number)');

                var columnStatusData = table.cell(dtrow[0], testColIndexStatus[0]).data();
                console.log('columnStatusData : ' + columnStatusData);
                //var columnRefNoData = table.cell(dtrow[0], testColIndexRefNo[0]).data();
                
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#signoff-dialog-title').html('Signoff JS No:' + jobsheetNo);
                $('#signoff-dialog-content').html('');
                $('#signoff-dialog').animate({width: '550px', height: '200px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').hide();
                getJobsheetEmailOnlyForSignOFf(id);
                
                if (columnStatusData.includes('New') || columnStatusData.includes('Edited') || columnStatusData.includes('Revised') || columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }
                
                if (columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-recall').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }
                
                if (columnStatusData.includes('Approved')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                }
                
                $('#button-close').show();
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
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffLink() {
                $('#button-yes').data('action', 'signOffByLink');
                $('#signoff-dialog-content').html('Sign Off By Link?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('textarea[name=signOffTextArea]').val("");
                //$('#signoff-dialog').animate({width: '600px', height: '300px'});
                //$('textarea[name=signOffTextArea]').show();
            }
            function noSignOff() {
                $('#button-yes').data('action', 'noSignOff');
                $('#signoff-dialog-content').html('No Sign Off Needed?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffVoid() {
                $('#button-yes').data('action', 'signOffVoid');
                $('#signoff-dialog-content').html('Void Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffRecall() {
                $('#button-yes').data('action', 'signOffRecall');
                $('#signoff-dialog-content').html('Recall Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function selectYesSignoff() {

                var id = $('#button-yes').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: $('#button-yes').data('action'),
                        data: $('textarea[name=signOffTextArea]').val(),
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
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffByLink') {
                    let urlLink = $('#button-link').data('link');
                    $('#signoff-dialog-content').html('Please copy and send this link to customer : <br>');
                    $('#signoff-dialog').animate({width: '600px', height: '300px'});
                    $('textarea[name=signOffTextArea]').val(urlLink);
                    $('textarea[name=signOffTextArea]').show();
                } else if (action === 'noSignOff') {
                    $('#signoff-dialog-content').html('Jobsheet is close without sign off');
                    $('textarea[name=signOffTextArea]').hide();
                     $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffVoid') {
                    $('#signoff-dialog-content').html('Jobsheet Void');
                    $('textarea[name=signOffTextArea]').hide();
                     $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffRecall') {
                    $('#signoff-dialog-content').html('Jobsheet recalled');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                }
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#button-close').show();
            }

            function selectNoSignoff() {
                $('#signoff-dialog').data('dialog').close();
            }
            
            function copyUrl(){
                let urlLink = $('#button-link').data('link');
                navigator.clipboard.writeText(urlLink);
                alert("Copied the link " + urlLink);
            }

            function downloadJobsheet(id) {
                var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadJobsheet&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
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

                let uploaderUserId = <%=listProperties.getUser().getId()%>;

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
            
            function saveJobsheetForm()
            {
                //addJobSheetDataWithQuotation
                //editJobSheetDataWithQuotation
                console.log("Add|Edit for Ref ID" + quotationRefInit);
                var action = $('#button-save').data('action');
                var jobsheetId = $('#button-save').data('jobsheetId');
                var quotationId = $('#button-save').data('quotationId');
                console.log("action : " + action);
                console.log("jobsheetId : " + jobsheetId);
                console.log("quotationId : " + quotationId);


                var pdfName = $('#button-view').data('pdf');
                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }
                console.log("pdfName : " + pdfName);

                if ($('textarea[name=company_name]').val().trim().length === 0) {
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
                if (action === 'addJobSheetDataWithQuotation' || action === 'editJobSheetDataWithQuotation'){
                        if  ($('select[name=dropdownOrderType]').val() === '0') {
                        dialog('Error', 'Please select Job Order Type', 'alert');
                        return;
                    }
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

                let company_name = $('textarea[name=company_name]').val();
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
                let orderTypeId = $('select[name=dropdownOrderType]').val();
                let amount = $('input[name=amount]').val();
                let approved_by = $('input[name=approved_by]').val();
                let completed_by = $('input[name=completed_by]').val();
                let job_description = $('textarea[name=job_description]').val();
                let billing_address = $('textarea[name=billing_address]').val();
                let remarks = $('textarea[name=remarks]').val();
                let email = $('textarea[name=email]').val();
                let jobsheetCreatorId = <%=userId%>;

                //Create JobSheet
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: action,
                        jobsheet_type: jobsheetType,
                        jobsheet_quotation_id: quotationId,
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
                        order_type_id: orderTypeId,
                        job_description: job_description,
                        remarks: remarks,
                        amount: amount,
                        approved_by: approved_by,
                        completed_by: completed_by,
                        address: billing_address,
                        email: email,
                        id: jobsheetId,
                        operatorId:jobsheetCreatorId,
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
                            //After adding jobsheet, use the jobsheet id and update the resus_job table
                            console.log('Jobsheet Id with quotation:' + data.jobsheetId);
                            if (action === 'addJobSheetDataWithQuotation') {
                                updateJobWhenAdd(data.jobsheetId);
                                updateQuotationJobAssigned(data.jobsheetId, quotationId);
                            }
                            if (action === 'editJobSheetDataWithQuotation') {
                                updateJobWhenEdit(data.jobsheetId);
                                updateQuotationJobAssigned(data.jobsheetId, quotationId);
                            }
                            refreshDataTable();
                            closeAddJobsheet();
                            //If save from Add jobsheet (Must not have refreshJobsheetDataTable if not will have issues as the table is not initialized)
                            //If save from View jobsheet-Edit (Need to have refreshJobsheetDataTable)
                            if (action==='editJobSheetDataWithQuotation'){
                                refreshJobsheetDataTable();
                            }
                            
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
            
            //To edit Job Sheet tied to the quotation
            function editJobSheet(jobsheetId)
            {
                $('select[name=dropdownCostCentre]').val(0);
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
                        $('textarea[name=company_name]').val(data.jobsheet_company_name);
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
                        $('select[name=dropdownOrderType]').val(data.jobsheet_order_type_id);
//                        var dd = document.getElementById('dropdownCostCentreId');
//                        var cost_centre_found = false;
//                        for (var i = 0; i < dd.options.length; i++) {
//                            if (dd.options[i].text === data.jobsheet_cost_centre) {
//                            dd.selectedIndex = i;
//                            cost_centre_found = true;
//                            break;
//                            }
//                        }
//                        console.log("cost center found : " + cost_centre_found);
//                        if (!cost_centre_found){
//                            $('select[name=dropdownCostCentre]').val(0);
//                        }
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
                document.getElementsByClassName('form-dialog')[0].style.visibility = 'visible';
                $('#ListCustom-form-dialog').data('dialog').open();
            }
            
            //To edit Job Sheet tied to the quotation
            function uploadJobSheetAttachement(jobsheetId)
            {
                $('select[name=dropdownCostCentre]').val(0);
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
                        $('textarea[name=company_name]').val(data.jobsheet_company_name);
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
//                        var dd = document.getElementById('dropdownCostCentreId');
//                        var cost_centre_found = false;
//                        for (var i = 0; i < dd.options.length; i++) {
//                            if (dd.options[i].text === data.jobsheet_cost_centre) {
//                            dd.selectedIndex = i;
//                            cost_centre_found = true;
//                            break;
//                            }
//                        }
//                        console.log("cost center found : " + cost_centre_found);
//                        if (!cost_centre_found){
//                            $('select[name=dropdownCostCentre]').val(0);
//                        }
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
                $('#button-save').data('action', 'editUploadAttachment');
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
                document.getElementsByClassName('form-dialog')[0].style.visibility = 'hidden';
                $('#ListCustom-form-dialog').data('dialog').open();
            }
            
            function signOffJobsheet(id, jobsheetNo) {
                
                let link = '<%=domainUrl%>' + "jobsheetSignoff?id=" + id;
                
                var table = $('#${namespace}-result-table').DataTable();

                const dtrow = table.row('#' + id);

                var testColIndexStatus = table.column(':contains(Status)');
                var testColIndexRefNo = table.column(':contains(Ref Number)');

                var columnStatusData = table.cell(dtrow[0], testColIndexStatus[0]).data();
                //console.log('columnStatusData : ' + columnStatusData[1]);
                var columnRefNoData = table.cell(dtrow[0], testColIndexRefNo[0]).data();
                
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#signoff-dialog-title').html('Signoff JS No:' + jobsheetNo);
                $('#signoff-dialog-content').html('');
                $('#signoff-dialog').animate({width: '550px', height: '200px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').hide();
                getJobsheetEmailOnlyForSignOFf(id);
                
                if (columnStatusData.includes('New') || columnStatusData.includes('Edited') || columnStatusData.includes('Revised') || columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }
                
                if (columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-recall').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }
                
                if (columnStatusData.includes('Approved')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                }
                
                $('#button-close').show();
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
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffLink() {
                $('#button-yes').data('action', 'signOffByLink');
                $('#signoff-dialog-content').html('Sign Off By Link?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('textarea[name=signOffTextArea]').val("");
                //$('#signoff-dialog').animate({width: '600px', height: '300px'});
                //$('textarea[name=signOffTextArea]').show();
            }
            function noSignOff() {
                $('#button-yes').data('action', 'noSignOff');
                $('#signoff-dialog-content').html('No Sign Off Needed?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffVoid() {
                $('#button-yes').data('action', 'signOffVoid');
                $('#signoff-dialog-content').html('Void Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffRecall() {
                $('#button-yes').data('action', 'signOffRecall');
                $('#signoff-dialog-content').html('Recall Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function selectYesSignoff() {

                var id = $('#button-yes').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: $('#button-yes').data('action'),
                        data: $('textarea[name=signOffTextArea]').val(),
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
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffByLink') {
                    let urlLink = $('#button-link').data('link');
                    $('#signoff-dialog-content').html('Please copy and send this link to customer : <br>');
                    $('#signoff-dialog').animate({width: '600px', height: '300px'});
                    $('textarea[name=signOffTextArea]').val(urlLink);
                    $('textarea[name=signOffTextArea]').show();
                } else if (action === 'noSignOff') {
                    $('#signoff-dialog-content').html('Jobsheet is close without sign off');
                    $('textarea[name=signOffTextArea]').hide();
                     $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffVoid') {
                    $('#signoff-dialog-content').html('Jobsheet Void');
                    $('textarea[name=signOffTextArea]').hide();
                     $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffRecall') {
                    $('#signoff-dialog-content').html('Jobsheet recalled');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                }
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#button-close').show();
            }

            function selectNoSignoff() {
                $('#signoff-dialog').data('dialog').close();
            }

        </script>
    </head>
    <body>


        <div data-role="dialog" id=ListCustom-form-dialog class="small dialog bg-white" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Company Name</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="company_name" maxlength="300" placeholder="">
                                    </div>
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

                            <div class="row cells2">
                                <div class="cell">
                                    <label>Purchase Order No</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="purchase_order" maxlength="300" placeholder="">
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Cost Centre</label>
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
                        <button id=button-save type="button" class="button primary" onclick="saveJobsheetForm()">Save</button>
                        <button id="button-cancel" type="button" class="button" onclick="closeAddJobsheet()">Close</button>
                        <button id=button-preview type="button" class="button" onclick="previewJobsheet()">Preview</button>
                    </div>
                </div>
            </div>
        </div>

        <div data-role="dialog" id="signoff-dialog" class="padding20" data-close-button="true" data-width="600" data-height="200" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=signoff-dialog-title class="text-light"></h1>
            <p id="signoff-dialog-content"></p>
            <textarea name="signOffTextArea" data-role="textarea" cols="65" rows="7"></textarea>
            <div class="form-dialog-control">
                <div class="float-left">
                    <button id=button-void type="button" class="button alert" onclick="signOffVoid()">Void</button>
                    <button id=button-recall type="button" class="button warning" onclick="signOffRecall()">Recall</button>
                </div>
                <button id=button-yes type="button" class="button" onclick="selectYesSignoff()">Yes</button>
                <button id=button-no type="button" class="button" onclick="selectNoSignoff()">No</button>
                <button id=button-email type="button" class="button primary" onclick="signOffEmail()">Via Email</button>
                <button id=button-link type="button" class="button alert" onclick="signOffLink()">Via Link</button>
                <button id=button-nosignoff type="button" class="button" onclick="noSignOff()">No Sign Off</button>
                <button id=button-close type="button" class="button" onclick="closeSignoffForm()">Close</button>
            </div>
        </div>

    </body>
</html>
