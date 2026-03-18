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

    JSONArray staffList = null;

    JSONArray warrantStatusList = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

        staffList = dataHandler.getStaffList(listProperties.getUser().getInt("customer_id"));

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
                width:1500px;
                height:150px;
                padding-top:20px;
                padding-right:15px;
            } 
            #update_start_time {
                float:left; 
            }
            #update_end_time{
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
                $("#dateTimePicker-opReportingTime-time").AnyTime_picker({
                    format: "%H:%i"
                });
            });

            function updateAdhocStart()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();


                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'warsOp?type=plan&action=updateReportingTime',
                        data:
                                {
                                    'workOrderPlanId': id,
                                    'reportingTime': document.getElementById("dateTimePicker-opReportingTime-time").value
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Expiry date has been updated', 'success');
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
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            }

            function updateEstimateTime()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (!(document.getElementById("estimate_time").value.match("^[0-9]*\\.?[0-9]*$")))
                {
                    dialog('Incorrect Input', 'Please input numeric input', 'alert');
                    return;
                }
                
                var y = parseInt(document.getElementById("estimate_time").value);
                if (!(y >= 3))
                {
                    dialog('Incorrect Input', 'Estimate Hours must at least be 3 hours or more', 'alert');
                    return;
                }

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'warsOp?type=plan&action=updateEstimatedTime',
                        data:
                                {
                                    'workOrderPlanId': id,
                                    'estimateTime': document.getElementById("estimate_time").value
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Expiry date has been updated', 'success');
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
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            }

        </script>
    </head>
    <body>
        <div class="container_work_order_plan_1">

            <div id ="update_start_time" class="panel" style="width: 300px">
                <div class="heading">
                    <span class="title">Update Adhoc Start Time</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input" style="min-width:96px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-opReportingTime-time" type="text" placeholder="Adhoc Start Time" value="">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <button class="button" type="button" title="Update" onclick="if (confirm('Do you want to update reporting time?'))
                                updateAdhocStart();"><span class="mif-checkmark"></span> Update</button>
                </div>
            </div>
            <div id ="update_end_time" class="panel" style="width: 300px">
                <div class="heading">
                    <span class="title">Update Estimate Time</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input">
                        <input id="estimate_time" type="text" size="50" style="width:260px;"> 
                    </div>
                    <button class="button" type="button" title="Update" onclick="if (confirm('Do you want to update hours of custody?'))
                                updateEstimateTime();"><span class="mif-checkmark"></span> Update</button>
                </div>
            </div>
        </div> 
    </body>
</html>
