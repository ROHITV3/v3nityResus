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

            function assign()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (document.getElementById("dateTimePicker-enforcement-date").value === '')
                {
                    dialog('No Enforcement Date', 'Please select the enforcement date', 'alert');

                    return;
                }

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=assignEnforcement',
                        data:
                                {
                                    'workOrderPlanId': id,
                                    'staffId': document.getElementById("select-staff").value,
                                    'enforcementDate': document.getElementById("dateTimePicker-enforcement-date").value
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Enforcement has been scheduled', 'success');
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

            function updateWarrantStatus()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (document.getElementById("dateTimePicker-warrant-date").value === '')
                {
                    dialog('No Warrant Date', 'Please select the warrant date', 'alert');

                    return;
                }

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=updateWarrantStatus',
                        data:
                                {
                                    'workOrderPlanId': id,
                                    'warrantStatusId': document.getElementById("select-warrant-status").value,
                                    'warrantDate': document.getElementById("dateTimePicker-warrant-date").value
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Warrant Status has been updated', 'success');
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

            function updateAgencyIc()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=updateAgencyIC',
                        data:
                                {
                                    'workOrderPlanId': id
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

            function reopenCase()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=reopenCase',
                        data:
                                {
                                    'workOrderPlanId': id
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Case has be reopen', 'success');
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

            function followUpCase()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=followUpCase',
                        data:
                                {
                                    'workOrderPlanId': id
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Case is followed up', 'success');
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

            function closeCase()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=closeCase',
                        data:
                                {
                                    'workOrderPlanId': id
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Case is closed', 'success');
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

            function downloadEWarrant(id)
            {

                var pdfdialog = window.open("wars?type=plan&action=downloadEWarrant&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");

                pdfdialog.moveTo(0, 0);
            }
            
            function deleteCase()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=deleteCase',
                        data:
                                {
                                    'workOrderPlanId': id
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Do you want to delete the enforcement visit', 'success');
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
            
            function redoCase()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var id = data.join();

                    $.ajax({
                        type: 'POST',
                        url: 'wars?type=plan&action=redoCase',
                        data:
                                {
                                    'workOrderPlanId': id
                                },
                        success: function (data)
                        {
                            refreshDataTable_${namespace}();
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', 'Do you want to redo the enforcement visit', 'success');
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
            <div id ="schedule_enforcment" class="panel" style="width: 560px">
                <div class="heading">
                    <span class="title">Schedule Enforcement</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input" style="min-width:96px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-enforcement-date" type="text" placeholder="Enforcement Date" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control select">
                        <select id="select-staff">
                            <%  for (int i = 0; i < staffList.size(); i++) {
                                    JSONObject staff = (JSONObject) staffList.get(i);

                                    out.println("<option value=\"" + staff.get("id") + "\">" + staff.get("driver") + "</option>");
                                }
                            %>
                        </select>
                    </div>
                    <button class="button" type="button" title="Assign enforcement" onclick="if (confirm('Do you want to assign enforcement?'))
                                assign();"><span class="mif-checkmark"></span> Assign</button>
                </div>
            </div>

            <div id="change_warrant_status" class="panel" style="width: 560px">
                <div class="heading">
                    <span class="title">Change Warrant Status</span>
                </div>
                <div class="content">
                    <div class="input-control text" data-role="input" style="min-width:96px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-warrant-date" type="text" placeholder="Warrant Date" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control select">
                        <select id="select-warrant-status">
                            <%  
                                out.println("<option value=\"3\">Withheld</option>");
                                out.println("<option value=\"4\">Cancel</option>");
                                out.println("<option value=\"5\">Abort</option>");
                            %>
                        </select>
                    </div>
                    <button class="button" type="button" title="Update Warrant Status" onclick="if (confirm('Do you want to update Warrant Status?'))
                                updateWarrantStatus();"><span class="mif-checkmark"></span> Update</button>
                </div>
            </div>
        </div>        
        <div class="container_work_order_plan_2">
            <div id="update_agency_ic" class="panel" style="width: 200px">
                <div class="heading">
                    <span class="title">Update Agency IC</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Update Agency IC" onclick="if (confirm('Do you want to update Agency IC?'))
                            updateAgencyIc();"><span class="mif-checkmark"></span> Update</button>
                </div>
            </div>
            <div id ="reopen_case" class="panel" style="width: 200px">
                <div class="heading">
                    <span class="title">Reopen Case</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Reopen Case" onclick="if (confirm('Do you want to reopen this case?'))
                            reopenCase();"><span class="mif-checkmark"></span> Reopen</button>
                </div>
            </div>
            <div id ="follow_up_case" class="panel" style="width: 200px">
                <div class="heading">
                    <span class="title">Follow Up Case</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Follow Up Case" onclick="if (confirm('Do you want to follow up this case?'))
                            followUpCase();"><span class="mif-checkmark"></span> Follow up</button>
                </div>
            </div>
            <div id ="close_case" class="panel" style="width: 200px">
                <div class="heading">
                    <span class="title">Close Case</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Close Case" onclick="if (confirm('Do you want to close up this case?'))
                            closeCase();"><span class="mif-checkmark"></span> Close</button>
                </div>
            </div>
            <div id ="redo_case" class="panel" style="width: 200px">
                <div class="heading">
                    <span class="title">Redo Case</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Redo Case" onclick="if (confirm('Do you want to redo this case?'))
                            redoUpCase();"><span class="mif-checkmark"></span> Follow up</button>
                </div>
            </div>
            <div id ="delete_case" class="panel" style="width: 200px">
                <div class="heading">
                    <span class="title">Delete Case</span>
                </div>
                <div class="content">
                    <button class="button" type="button" title="Close Case" onclick="if (confirm('Do you want to delete this case?'))
                            deleteCase();"><span class="mif-checkmark"></span> Delete</button>
                </div>
            </div>
        </div>


    </body>
</html>
