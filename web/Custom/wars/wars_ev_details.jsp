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
                $("#dateTimePicker-expiry-date").AnyTime_picker({
                    format: "%d/%m/%Y"
                            //earliest: (new Date()).getTime(),
                            //latest: (new Date()).getTime() + 604800000      // 7 days...
                });
            });

            function filterOffenderId(offenderId)
            {
                $('div[name="offender_id_number"] :input').val(offenderId);

                customFilter_${namespace}();
            }

            function filterWarrantNo(warrantNo)
            {
                $('div[name="warrant_number"] :input').val(warrantNo);

                customFilter_${namespace}();
            }

            function updateOffenderAddress()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (document.getElementById("offender-updated-address").value === '')
                {
                    dialog('No Address', 'Please type in the address', 'alert');

                    return;
                }

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=updateOffenderAddress',
                        data:
                                {
                                    'workOrderPlanId': id,
                                    'offenderAddress': document.getElementById("offender-updated-address").value,
                                    'offenderAddressTypeId': document.getElementById("select-address-type-id").value,

                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Address has been updated', 'success');
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

            function updateExpiryDate()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (document.getElementById("dateTimePicker-expiry-date").value === '')
                {
                    dialog('No Expiry Date', 'Please select the expiry date', 'alert');

                    return;
                }

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=updateExpiryDate',
                        data:
                                {
                                    'workOrderPlanId': id,
                                    'expiryDate': document.getElementById("dateTimePicker-expiry-date").value
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

            function updateChargable()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=updateChargable',
                        data:
                                {
                                    'workOrderEvId': id,
                                    'chargable': document.getElementById("select-chargable").value
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Work order chargable has been updated', 'success');
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

            function updateeAgencyIc()
            {
                var table = $('#${namespace}-result-table').DataTable();
                var data = table.rows('.selected').ids();

                var columnData = table.rows('.selected').data()[0];
                var agencyName = [columnData[6]];

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=updateAgencyICFromWorkOrderDetailsEv',
                        data:
                                {
                                    'workOrderEvId': id,
                                    'agencyName': agencyName
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Agency IC has been updated', 'success');
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
            <div id="update_address" class="panel" style="width: 700px">
                <div class="heading">
                    <span class="title">Change Address</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input">
                        <input id="offender-updated-address" type="text" size="50" style="width:350px;"> 
                    </div>
                    <div class="input-control select">
                        <select id="select-address-type-id">
                            <option value="1">Residence</option>
                            <option value="2">Workplace</option>
                        </select>
                    </div>
                    <button class="button" type="button" title="Update Address" onclick="if (confirm('Do you want to update address?'))
                                updateOffenderAddress();"><span class="mif-checkmark"></span> Update</button>
                </div>
            </div>

            <div id ="update_expiry_date" class="panel" style="width: 400px">
                <div class="heading">
                    <span class="title">Update Expiry Date</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input" style="min-width:96px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-expiry-date" type="text" placeholder="Expiry Date" value="">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <button class="button" type="button" title="Update Expiry Date" onclick="if (confirm('Do you want to update expiry date?'))
                                updateExpiryDate();"><span class="mif-checkmark"></span> Update</button>
                </div>
            </div>
        </div> 
        <div id ="schedule_enforcment" class="panel" style="width: 300px">
            <div class="heading">
                <span class="title">Update Chargable</span>
            </div>
            <div class="content">
                <div class="input-control select">
                    <select id="select-chargable">
                        <option value="1">Yes</option>
                        <option value="0">No</option>
                    </select>
                </div>
                <button class="button" type="button" title="Update Chargable" onclick="if (confirm('Do you want to update chargable?'))
                            updateChargable();"><span class="mif-checkmark"></span> Update</button>
            </div>
        </div>
    </body>
</html>
