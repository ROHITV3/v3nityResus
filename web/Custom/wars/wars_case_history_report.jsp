<%--
    Document   : wars_work_order_plan
    Created on : 23 Mar, 2022, 1:24:58 PM
    Author     : Kevin
--%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.cust.biz.wars.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    WarsDataHandler dataHandler = new WarsDataHandler();

    Connection connection = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

    } catch (Exception e) {

    } finally {
        listProperties.getDatabasePool().closeConnection(connection);
    }


%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Case History</title>
        <style type="text/css"> 
            .container_case_history {
                position: relative;
                width:1200px;
                height:120px;
                padding-top:20px;
                padding-right:15px;
            } 
            #schedule_enforcment {
                float:left; 
            }
        </style> 
        <script>
            
//            $(document).ready(function ()
//            {
//                $("#dateTimePicker-from-date").AnyTime_picker({
//                    format: "%d/%m/%Y"
//                });
//
//                $("#dateTimePicker-to-date").AnyTime_picker({
//                    format: "%d/%m/%Y"
//                });
//            });


            function downloadCaseReport()
            {
                if (document.getElementById("offender-id-number").value === '')
                {
                    dialog('No Offender Id Number', 'Please type in the Offender Id Number', 'alert');

                    return;
                }
                if (document.getElementById("dateTimePicker-from-date").value === '')
                {
                    dialog('No Warrant Date', 'Please select the from date', 'alert');

                    return;
                }
                if (document.getElementById("dateTimePicker-to-date").value === '')
                {
                    dialog('No Warrant Date', 'Please select the to date', 'alert');

                    return;
                }

                $.ajax({
                    type: 'POST',
                    url: 'WarsCaseHistoryReportController?type=plan&action=checkIfReportExist',
                    data:
                            {
                                'offenderNoId': document.getElementById("offender-id-number").value,
                                'fromDate': document.getElementById("dateTimePicker-from-date").value,
                                'toDate': document.getElementById("dateTimePicker-to-date").value
                            },
                    success: function (data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                window.open("WarsCaseHistoryReportController?type=plan&action=downloadCaseReport&offenderNoId=" + document.getElementById("offender-id-number").value + "&fromDate=" + document.getElementById("dateTimePicker-from-date").value + "&toDate=" + document.getElementById("dateTimePicker-to-date").value, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
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
            }

        </script>
    </head>
    <body>
        <div class="container_case_history">
            <div id ="schedule_enforcment" class="panel" style="width: 320px">
                <div class="heading">
                    <span class="title">Download Case History Report</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input" style="min-width:96px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-from-date" type="date" placeholder="From" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control text" data-role="input" style="min-width:96px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-to-date" type="date" placeholder="To" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control select">
                        <div class="input-control text" data-role="input">
                            <input id="offender-id-number" type="text" size="50" style="width:300px;"> 
                        </div>
                    </div>
                    <button class="button" type="button" title="Download Monthly Report" onclick="if (confirm('Do you want to download case history report?'))
                                downloadCaseReport();"><span class="mif-checkmark"></span> Download</button>
                </div>

            </div>
        </div>        
    </body>
</html>
