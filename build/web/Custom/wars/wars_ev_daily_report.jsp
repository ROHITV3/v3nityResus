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

    JSONArray customerList = null;

    JSONArray warrantStatusList = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

        customerList = dataHandler.getAgencyByCustomerId(listProperties.getUser().getInt("customer_id"));

        warrantStatusList = dataHandler.getWarrantStatusList();

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
            });

            function downloadDailyReport()
            {

                if ($("#dateTimePicker-start-plan_status_date").val() && $("#dateTimePicker-end-plan_status_date").val())
                {
                    window.open("warsReport?type=plan&action=downloadDailyReport&startDate=" + $("#dateTimePicker-start-plan_status_date").val() + "&endDate=" + $("#dateTimePicker-end-plan_status_date").val() + "&customerId=" + $("#select-agency").val(), "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                } else
                {
                    alert("Please choose a date.");
                }
            }

        </script>
    </head>
    <body>
        <div class="container_work_order_plan_1">
            <div id ="schedule_enforcment" class="panel" style="width: 320px">
                <div class="heading">
                    <span class="title">Download Daily Report</span>
                </div>
                <div class="content">
                    <div class="input-control select">
                        <select id="select-agency">
                            <%  for (int i = 0; i < customerList.size(); i++) {
                                    JSONObject customer = (JSONObject) customerList.get(i);
                                    if (customer.get("customer").toString().equalsIgnoreCase("AETOS")) {
                                        out.println("<option value=\"1\">All Agencies</option>");
                                    } else {
                                        out.println("<option value=\"" + customer.get("id") + "\">" + customer.get("customer") + "</option>");
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <button class="button" type="button" title="Download Daily Report" onclick="if (confirm('Do you want to download daily report?'))
                                downloadDailyReport();"><span class="mif-checkmark"></span> Download</button>
                </div>

            </div>
        </div>        
    </body>
</html>
