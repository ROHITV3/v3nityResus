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

            function downloadMonthlyReport()
            {
                if (document.getElementById("work-order-number").value === '')
                {
                    dialog('No Work Order Number', 'Please type in the Work Order Number', 'alert');

                    return;
                }

                $.ajax({
                    type: 'POST',
                    url: 'WarsMonthlyReportController?type=plan&action=checkIfReportExist',
                    data:
                            {
                                'workOrderSn': document.getElementById("work-order-number").value
                            },
                    success: function (data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                window.open("WarsMonthlyReportController?type=plan&action=downloadMonthlyReport&workOrderSn=" + document.getElementById("work-order-number").value, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
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
        <div class="container_work_order_plan_1">
            <div id ="schedule_enforcment" class="panel" style="width: 320px">
                <div class="heading">
                    <span class="title">Download Monthly Report</span>
                </div>
                <div class="content">
                    <div class="input-control select">
                        <div class="input-control text" data-role="input">
                            <input id="work-order-number" type="text" size="50" style="width:300px;"> 
                        </div>
                    </div>
                    <button class="button" type="button" title="Download Monthly Report" onclick="if (confirm('Do you want to download monthly report?'))
                                downloadMonthlyReport();"><span class="mif-checkmark"></span> Download</button>
                </div>

            </div>
        </div>        
    </body>
</html>
