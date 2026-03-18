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

    ResusQuotationDataHandler dataHandler = new ResusQuotationDataHandler();

    Connection connection = null;

    JSONArray staffList = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

        //staffList = dataHandler.getStaffList(listProperties.getUser().getInt("customer_id"));
    } catch (Exception e) {

    } finally {
        listProperties.getDatabasePool().closeConnection(connection);
    }

    int userId = listProperties.getUser().getId();

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
                height:150px;
                padding-top:20px;
                padding-right:15px;
            } 
            #update_address {
                float:left; 
            }
            #update_expiry_date{
                float:left; 
                padding-left:15px;
            }
            #update_agency_ic{
                float:left;
            }
            #update_chargable{
                float:left;
                padding-left:15px;
            }
        </style>

        <script>
            $(document).ready(function ()
            {

            });

            function promptSendQuotation(id, quotationRef) {
                showSendQuotationDialog(id, quotationRef);
            }

            function showSendQuotationDialog(id, quotationRef) {
                $('#button-authorize').data('id', id);
                $('#send-email-dialog-title').html('Do you want to send ' + quotationRef + ' to customer?');
                $('#send-email-dialog').data('dialog').open();
            }

            function selectYesEmail() {
                let id = $('#button-authorize').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'sendForApproval',
                        id: id
                    },
                    success: function (data)
                    {
                        //refreshDataTable();
                        refreshDataTable_${namespace}();
                        if (data.result === true) {
                            dialog('Success', 'Quotation is sent for approval', 'success');
                            $('#send-email-dialog').data('dialog').close();
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

            function selectNoEmail() {
                $('#send-email-dialog').data('dialog').close();
            }

            function sendQuotation() {
                //before sending, check if there the quotation status. Only allow the quotation that is authorized to be able to send out.
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();
                    console.log('id to sent quotation :' + id);
                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: 'sendForApproval',
                            id: id
                        },
                        success: function (data)
                        {
                            //refreshDataTable();
                            refreshDataTable_${namespace}();
                            if (data.result === true) {
                                dialog('Success', 'Quotation is sent for approval', 'success');
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
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            }

            function cancelQuotation() {
            }

            function downloadQuotationBeforeAuthorize(id) {
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadQuotationForBD&quotationId=" + id + "&bdId=" + <%=listProperties.getUser().getId()%>, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function downloadQuotationAfterAuthorize(id) {
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadQuotation&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function authorizeQuotation(id, quotationRef) {
                showAdd(id, quotationRef);
            }

            function showAdd(id, quotationRef) {
                //check if authoriser have signature input
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
                    //clearForm();
                    $('#button-authorize').data('id', id);
                    $('#button-reject').data('id', id);
                    $('#button-preview').data('id', id);
                    $('#authorize-dialog-title').html('Authorize ' + quotationRef);
                    $('#button-authorize').show();
                    $('#button-reject').show();
                    $('#button-preview').show();
                    $('#button-close').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                    $('#remarksId').hide();
                    let dialog = $('#authorize-dialog').data('dialog');
                    dialog.open();
                }else{
                    dialog('Error', 'Please go to "Manage Quotation -> Signature" to add signature', 'alert');
                }
            }

            function authorize() {
                $('#authorize-dialog-content').html('Confirm authorize quotation and send to customer by email?');
                $('#button-yes').show();
                //$('#button-yes').data('action', 'updateQuotationAuthorized');
                $('#button-yes').data('action', 'sendForApproval');
                $('#button-no').show();
                $('#button-authorize').hide();
                $('#button-reject').hide();
                $('#button-close').hide();
            }

            function reject() {
                $('#authorize-dialog-content').html('Confirm reject quotation?');
                $('#button-yes').show();
                $('#button-yes').data('action', 'rejectFromBd');
                $('#button-no').show();
                $('#button-authorize').hide();
                $('#button-reject').hide();
                $('#button-close').hide();
                $('#remarksId').show();
            }

            function previewForm() {
                let id = $('#button-preview').data('id');
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadQuotationForBD&quotationId=" + id + "&bdId=" + <%=listProperties.getUser().getId()%>, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function closeForm() {
                $('#authorize-dialog').data('dialog').close();
            }

            function selectNo() {
                $('#authorize-dialog').data('dialog').close();
            }

            function selectYes() {
                var id = $('#button-authorize').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: $('#button-yes').data('action'),
                        remarks: $('textarea[name=remarks]').val(),
                        id: id
                    },
                    success: function (data)
                    {
                        if (data.result === true) {
                            refreshDataTable_${namespace}();
                            $('#authorize-dialog').data('dialog').close();
                            if ($('#button-yes').data('action')==='sendForApproval'){
                                dialog('Success', 'Quotation is approved', 'success');
                            }
                            if ($('#button-yes').data('action')==='rejectFromBd'){
                                dialog('Success', 'Quotation is approved', 'success');
                            }
                            
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

//            function showDialog(id) {
//                var dialog = $(id).data('dialog');
//                dialog.open();
//            }
        </script>
    </head>
    <body>

        <div data-role="dialog" id="authorize-dialog" class="padding20" data-close-button="true" data-width="500" data-height="300" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=authorize-dialog-title class="text-light"></h1>
            <p id="authorize-dialog-content"></p>
            <div class="form-dialog-content">
                <div class="grid">
                    <div class="row cells1">
                        <div class="cell">
                            <div id="remarksId" class="input-control textarea full-size">
                                <textarea name="remarks" maxlength="255" rows="3" placeholder="Enter remarks if required"></textarea>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-yes type="button" class="button" onclick="selectYes()">Yes</button>
                <button id=button-no type="button" class="button" onclick="selectNo()">No</button>
                <button id=button-authorize type="button" class="button primary" onclick="authorize()">Authorize</button>
                <button id=button-reject type="button" class="button alert" onclick="reject()">Reject</button>
                <button id=button-preview type="button" class="button" onclick="previewForm()">Preview</button>
                <button id=button-close type="button" class="button" onclick="closeForm()">Close</button>
            </div>
        </div>

        <div data-role="dialog" id="send-email-dialog" class="padding20" data-close-button="true" data-width="500" data-height="200" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=send-email-dialog-title class="text-light"></h1>
            <p id="send-email-dialog-content"></p>
            <div class="form-dialog-control">
                <button id=button-yes-email type="button" class="button" onclick="selectYesEmail()">Yes</button>
                <button id=button-no-email type="button" class="button" onclick="selectNoEmail()">No</button>
            </div>
        </div>

        <div id="TestDialog" data-role="dialog" class="Dialog" data-close-button="true" data-width="300" data-height="300"></div>

    </body>
</html>
