<%--
    Document   : wars_work_order_plan
    Created on : 23 Mar, 2022, 1:24:58 PM
    Author     : Kevin
--%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.cust.biz.resus.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>work order plan</title>
        <style type="text/css"> 
            .container_work_order_plan_1 {
                position: relative;
                width:1200px;
                height:120px;
                padding-top:20px;
                padding-right:15px;
            } 
            .container_work_order_plan_2 {
                position: relative;
                width:1200px;
                height:150px;
                padding-top:20px;
                padding-right:15px;
            }
            #schedule_enforcment {
                float:left; 
            }
            #change_warrant_status{
                float:left; 
                padding-left:15px;
            }
            #update_agency_ic{
                float:left;
            }
            #reopen_case{
                float:left;
                padding-left:15px;
            }
            #follow_up_case{
                float:left;
                padding-left:15px;
            }
            #close_case{
                float:left;
                padding-left:15px;
            }
        </style> 
        <script>
            
            $(document).ready(function ()
            {
//                $("#dateTimePicker-start-jobsheet_created_ts").AnyTime_picker({
//                    //format: "%d/%m/%Y"
//                            //earliest: (new Date()).getTime(),
//                            //latest: (new Date()).getTime() + 604800000      // 7 days...
//                });
//
//                $("#dateTimePicker-end-jobsheet_created_ts").AnyTime_picker({
//                    //format: "%d/%m/%Y"
//                            //earliest: (new Date()).getTime(),
//                            //latest: (new Date()).getTime() + 604800000      // 7 days...
//                });
                
                const collection = document.getElementsByClassName("toolbar");
                collection[0].style.display = "none";
            });

            function downloadJobSheetReport()
            {
                console.log("dateTimePicker-start-jobsheet_created_ts : " + $("#dateTimePicker-start-jobsheet_created_ts").val());
                console.log("dateTimePicker-end-jobsheet_created_ts : " + $("#dateTimePicker-end-jobsheet_created_ts").val());
                if ($("#dateTimePicker-start-jobsheet_created_ts").val() && $("#dateTimePicker-end-jobsheet_created_ts").val())
                {
                    window.open("ResusJobsheetReportController?type=plan&action=downloadJobSheetReport&startDate=" + $("#dateTimePicker-start-jobsheet_created_ts").val() + "&endDate=" + $("#dateTimePicker-end-jobsheet_created_ts").val() + "&customerId=" + $("#select-agency").val(), "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                } else
                {
                    alert("Please choose a date.");
                }
            }
            
            function addChangeRemoveQuotation(id)
            {
                //Get Job Sheet Details and check if it's with a quotation
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobSheetQuotationData',
                        id: id
                    },
                    success: function (data)
                    {
                        result = true;
                        $('input[name=jobSheetNo]').val(data.jobsheet_no);
                        $('input[name=quotationNo]').val(data.quotation_ref);
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
                //Assign to the textfield
                //Display Value
                $('#form-dialog').data('dialog').open();
            }
            
            function updateJoinJobsheet(){
                if ($('input[name=quotationNo]').val().trim() === ''){
                    dialog('Please Key In Quotation Ref No', '', 'alert');
                }
                else
                {
                    //Check if quotation is available
                    $.ajax({
                        type: 'POST',
                        url: 'ResusJobsheetController',
                        data: {
                            type: 'plan',
                            action: 'checkIfQuotationExist',
                            quotationRefId: $('input[name=quotationNo]').val(),
                            jobsheetNo: $('input[name=jobSheetNo]').val()
                        },
                        success: function (data)
                        {
                            if (data.result === true) {
                                let quotationId = data.quotation_id;
                                let jobsheetId = data.jobsheet_id;
                                $('#button-joinConfirm').data('quotationId', quotationId);
                                $('#button-joinConfirm').data('jobsheetId', jobsheetId);
                                $('#jobsheetJoin-dialog-content').html('Do you want to join Job Sheet : ' + $('input[name=jobSheetNo]').val() + ' to Quotation : ' + $('input[name=quotationNo]').val());
                                $('#jobsheetJoin-dialog').data('dialog').open();
                            } else {
                                dialog('Quotation Is Not Available', '', 'alert');
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error a', 'alert');
                        },
                        async: false
                    });
                }
            }
            
            function confirmJoinQuotation(){
                $('#jobsheetJoin-dialog').data('dialog').close();
                $('#form-dialog').data('dialog').close();
                
                let quotationId = $('#button-joinConfirm').data('quotationId');
                let jobsheetId = $('#button-joinConfirm').data('jobsheetId');
                
                $.ajax({
                        type: 'POST',
                        url: 'ResusJobsheetController',
                        data: {
                            type: 'plan',
                            action: 'joinJobSheetToQuotation',
                            quotationId: quotationId,
                            jobsheetId: jobsheetId
                        },
                        success: function (data)
                        {
                            if (data.result === true) {
                                $('#jobsheetJoin-dialog').data('dialog').close();
                                refreshDataTable_${namespace}();
                                dialog('Success', '', 'success');
                            } else {
                                dialog('Failed', '', 'alert');
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error a', 'alert');
                        },
                        async: false
                    });
            }
            
            function closeJoinJobsheet(){
                $('#form-dialog').data('dialog').close();;
            }
            
            function closeConfirmJoinQuotation(){
                $('#jobsheetJoin-dialog').data('dialog').close();
            }
            
            function updateRemoveJobsheet(){
                //Check If this Jobsheet is assigned to quotation
                $('#jobsheetRemove-dialog-content').html('Do you want to remove Job Sheet : ' + $('input[name=jobSheetNo]').val() + ' from Quotation : ' + $('input[name=quotationNo]').val());
                $('#jobsheetRemove-dialog').data('dialog').open();
            }
            
            function removeQuotationJobsheet(){
                    //Check if quotation is available
                    $.ajax({
                        type: 'POST',
                        url: 'ResusJobsheetController',
                        data: {
                            type: 'plan',
                            action: 'removeQuotationFromJobSheet',
                            jobsheetNo: $('input[name=jobSheetNo]').val()
                        },
                        success: function (data)
                        {
                            if (data.result === true) {
                                $('#form-dialog').data('dialog').close();
                                $('#jobsheetRemove-dialog').data('dialog').close();
                                refreshDataTable_${namespace}();
                                dialog('Success', '', 'success');
                            } else {
                                dialog('Failed', '', 'alert');
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error a', 'alert');
                        },
                        async: false
                    });
            }
            
            function closeConfirmRemoveQuotation(){
                $('#jobsheetRemove-dialog').data('dialog').close();
            }
            
            
            
            

        </script>
    </head>
    <body>
        <div class="container_work_order_plan_1">
            <div id ="schedule_enforcment" class="panel" style="width: 320px">
                <div class="heading">
                    <span class="title">Download Job Sheet Report</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Download Job Sheet Report" onclick="if (confirm('Do you want to download report?'))
                                downloadJobSheetReport();"><span class="mif-checkmark"></span> Download</button>
                </div>

            </div>
        </div>
        
        <div data-role="dialog" id=form-dialog class="small" data-close-button="false" data-width="500" data-height="200" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Job Sheet No. :</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="jobSheetNo" maxlength="300" placeholder="" disabled>
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Quotation Ref No. :</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="quotationNo" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                        </div> 
                    </form>
                </div>    
            </div>
            <div class="form-dialog-control">
                <div class="row">     
                    <div class="column" style="float:left;">
                        <button id=button-save type="button" class="button primary" onclick="updateJoinJobsheet()">Update</button>
                    </div>
                    <div class="column" style="float:right;">
                        <button id=button-save type="button" class="button primary" onclick="updateRemoveJobsheet()">Remove</button>
                        <button id="button-cancel" type="button" class="button" onclick="closeJoinJobsheet()">Close</button>
                    </div>
                </div>
            </div>
        </div>
        
        <div data-role="dialog" id="jobsheetJoin-dialog" class="padding20" data-close-button="false" data-width="500" data-height="200" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=jobsheetJoin-dialog-title class="text-light"></h1>
            <p id="jobsheetJoin-dialog-content"></p>
            <div class="form-dialog-control">
                <div class="column" style="float:left;">
                    <button id=button-joinConfirm type="button" class="button" onclick="confirmJoinQuotation()">Confirm</button>
                </div>
                <div class="column" style="float:right;">
                    <button id=button-joinClose type="button" class="button" onclick="closeConfirmJoinQuotation()">Close</button>
                </div>
            </div>
        </div>
        
        <div data-role="dialog" id="jobsheetRemove-dialog" class="padding20" data-close-button="false" data-width="500" data-height="200" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=jobsheetRemove-dialog-title class="text-light"></h1>
            <p id="jobsheetRemove-dialog-content"></p>
            <div class="form-dialog-control">
                <div class="column" style="float:left;">
                    <button id=button-removeConfirm type="button" class="button" onclick="removeQuotationJobsheet()">Confirm</button>
                </div>
                <div class="column" style="float:right;">
                    <button id=button-removeClose type="button" class="button" onclick="closeConfirmRemoveQuotation()">Close</button>
                </div>
            </div>
        </div>
    </body>
</html>
