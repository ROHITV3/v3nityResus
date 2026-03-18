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

    ResusJobsheetDataHandler dataHandler = new ResusJobsheetDataHandler();

    Connection connection = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);


    } catch (Exception e) {

    } finally {
        listProperties.getDatabasePool().closeConnection(connection);
    }


    ListData data = new ResusJobsheetWithouQuotation();
    data.onInstanceCreated(listProperties);

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>work order plan</title>
        <style type="text/css"> 
            .container_default {
                position: relative;
                width:1200px;
                height:150px;
                padding-top:20px;
                padding-right:15px;
            } 
            #close_case{
                float:left;
                padding-left:15px;
            }
        </style> 
        <script>

            $(document).ready(function ()
            {
            });
            
            $("#tool-button-add").click(function ()
            {
                showAdd();
            });
            
            function showAdd()
            {
                //clearForm();
                var dialog = $('#form-dialog').data('dialog');
                $('#form-dialog-title').html('Create ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                $('#button-save').data('action', 'addJobSheetDataWithoutQuotation');

                dialog.open();
            }

        </script>
    </head>
    <body>      
        <div class="toolbar">
         <button class="toolbar-button" id=tool-button-add name="add" value="" title="Add"><span class="mif-plus"></span></button>
         <button class="toolbar-button" id=tool-button-edit name="edit" value="" title="Edit"><span class="mif-pencil"></span></button>
         <button class="toolbar-button" id=tool-button-delete name="delete" value="" title="Delete"><span class="mif-bin"></span></button>
        </div>
        
        <div data-role="dialog" id=form-dialog class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
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
                                    <label>Postal Code</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="postal_code" maxlength="300" placeholder="">
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
                                <div class="cell">
                                    <label>Payment Term</label>
                                    <div class="input-control text full-size">
                                        <input type="text" name="payment_term" maxlength="300" placeholder="">
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
                                        <input type="text" name="amount" maxlength="300" placeholder="">
                                    </div>
                                    <label>Remarks</label>
                                    <div class="input-control text full-size">
                                        <textarea name="remarks" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Approved By</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="approved_by" maxlength="300" placeholder="">
                                    </div>
                                </div>
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
                <button id=button-save type="button" class="button primary" onclick="saveJobsheetForm()"><%=listProperties.getLanguage("save")%></button>
                <button id=button-cancel type="button" class="button" onclick="closeForm()"><%=listProperties.getLanguage("cancel")%></button>
                <button id=button-cancel type="button" class="button" onclick="previewJobsheet()">Preview</button>
            </div>
        </div>
    </body>
</html>
