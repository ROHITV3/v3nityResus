<%@page import="java.text.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    DataTreeView assetTreeView = new AssetTreeView(userProperties);

    //
    // get data from cache...
    //
    if (!userProperties.getDataCache().isDataTreeViewCached(assetTreeView))
    {
        assetTreeView.loadData(userProperties);

        userProperties.getDataCache().cacheDataTreeView(assetTreeView);
    }
    else
    {
        assetTreeView = userProperties.getDataCache().getDataTreeViewCache(assetTreeView);
    }

    assetTreeView.setIdentifier("filter-asset");
    
    Data aUser = userProperties.getUser();
    int userId = aUser.getId();
    int customerId = aUser.getInt("customer_id");

    //For Status Dashboard

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <link href="css/vehicle-health.css" rel="stylesheet">
        <title></title>
        <script type="text/javascript">

            var language = {
                lastUpdated: '<%=userProperties.getLanguage("ddLastUpdated")%>',
                unscheduled: '<%=userProperties.getLanguage("unscheduled")%>',
                scheduled: '<%=userProperties.getLanguage("scheduled")%>',
                dispatched: '<%=userProperties.getLanguage("dispatched")%>',
                accepted: '<%=userProperties.getLanguage("accepted")%>',
                started: '<%=userProperties.getLanguage("started")%>',
                ended: '<%=userProperties.getLanguage("ended")%>',
                rejected: '<%=userProperties.getLanguage("rejected")%>',
                cancelled: '<%=userProperties.getLanguage("cancelled")%>',
                received: '<%=userProperties.getLanguage("received")%>',
                uploading: '<%=userProperties.getLanguage("uploading")%>',
                optimize: '<%=userProperties.getLanguage("optimize")%>',
                pending: '<%=userProperties.getLanguage("pending")%>',
                formTemplate: '<%=userProperties.getLanguage("formTemplate")%>',
                mins: '<%=userProperties.getLanguage("mins")%>',
                onTime: '<%=userProperties.getLanguage("onTime")%>',
                productivity: '<%=userProperties.getLanguage("productivity")%>',
                jobs: '<%=userProperties.getLanguage("jobs")%>',
                staffs: '<%=userProperties.getLanguage("ddStaffs")%>',
            };

            var selectedIds = '';
            var refreshRate = 60000;
            var allAssetIds = [];
            var allFuelLevels = [];
            
            var COOLANT_TEMP_MONITOR = 3;
            var COOLANT_TEMP_ATTENTION = 4;
            var COOLANT_TEMP_BREAKDOWN = 5;
            var MAIN_VOLTAGE_MONITOR = 6;
            var MAIN_VOLTAGE_ATTENTION = 7;
            var MAIN_VOLTAGE_BREAKDOWN = 8;
            var FUEL_LEVEL_MONITOR = 15;
            var FUEL_LEVEL_ATTENTION = 16;
            var FUEL_LEVEL_BREAKDOWN = 17;
            var OVERCHARGING = 43;
            
            var conditionIssues = [];
            var detailFromDate;
            
            $(document).ready(function()
            {
                getParameters();
                
                var today = new Date();
                var dd = today.getDate();
                if (dd < 10)
                {
                    dd = '0' + dd;
                }
                var mm = today.getMonth() + 1;
                if (mm < 10)
                {
                    mm = '0' + mm;
                }
                var yyyy = today.getFullYear();
                var todayDate = dd + '/' + mm + '/' + yyyy;
                
                $("#dashboard-date").AnyTime_picker({format: "%d/%m/%Y"});
                $("#dashboard-date").val(todayDate);
                
                refreshDashboard();
            });

            function dispose()
            {
                
                $("#dashboard-date").AnyTime_noPicker();
            }
            
            function getParameters()
            {
                $.ajax({
                    type: 'GET',
                    url: 'VehicleHealthController',
                    data: {
                        type: 'system',
                        action: 'getparameters',
                        customerId: '<%=customerId%>'
                    },
                    success: function(data)
                    {
                        if (data.success)
                        {
                            var data = data.data;
                            
                            for (var i = 0 ; i < data.length ; i++)
                            {
                                var param = data[i].parameter_id;
                                
                                var value = data[i].value;
                                
                                if (param == COOLANT_TEMP_MONITOR) $('#monitor-coolant').val(value);
                                else if (param == COOLANT_TEMP_ATTENTION) $('#attn-coolant').val(value);
                                else if (param == COOLANT_TEMP_BREAKDOWN) $('#fault-coolant').val(value);
                                
                                else if (param == MAIN_VOLTAGE_MONITOR) $('#monitor-voltage').val(value);
                                else if (param == MAIN_VOLTAGE_ATTENTION) $('#attn-voltage').val(value);
                                else if (param == MAIN_VOLTAGE_BREAKDOWN) $('#fault-voltage').val(value);
                                
                                else if (param == OVERCHARGING) $('#overcharging').val(value);
                                
                                else if (param == FUEL_LEVEL_MONITOR) $('#monitor-fuel').val(value);
                                else if (param == FUEL_LEVEL_ATTENTION) $('#attn-fuel').val(value);
                                else if (param == FUEL_LEVEL_BREAKDOWN) $('#fault-fuel').val(value);
                            }
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }
            
            function showPopup(param)
            {
                setTimeout(function()
                {
                    if (param == COOLANT_TEMP_BREAKDOWN || param == COOLANT_TEMP_ATTENTION || param == COOLANT_TEMP_MONITOR)
                    {
                        document.getElementById('detail-column-label').innerHTML = 'Coolant Temp (°C)';
                    }
                    if (param == COOLANT_TEMP_BREAKDOWN) $('#detail-dialog-text').html('Coolant Temp: Fault');
                    else if (param == COOLANT_TEMP_ATTENTION) $('#detail-dialog-text').html('Coolant Temp: Attention');
                    else if (param == COOLANT_TEMP_MONITOR) $('#detail-dialog-text').html('Coolant Temp: Monitor');
                    
                    
                    if (param == MAIN_VOLTAGE_BREAKDOWN || param == MAIN_VOLTAGE_ATTENTION || param == MAIN_VOLTAGE_MONITOR)
                    {
                        document.getElementById('detail-column-label').innerHTML = 'Main Power Voltage (V)';
                    }
                    
                    if (param == MAIN_VOLTAGE_BREAKDOWN) $('#detail-dialog-text').html('Main Power Voltage: Fault');
                    else if (param == MAIN_VOLTAGE_ATTENTION) $('#detail-dialog-text').html('Main Power Voltage: Attention');
                    else if (param == MAIN_VOLTAGE_MONITOR) $('#detail-dialog-text').html('Main Power Voltage: Monitor');
                    
                    if (param == OVERCHARGING)
                    {
                        document.getElementById('detail-column-label').innerHTML = 'Overcharging (V)';
                    }
                    
                    if (param == OVERCHARGING) $('#detail-dialog-text').html('Overcharging: Fault');
                    
                    
                    if (param == FUEL_LEVEL_BREAKDOWN || param == FUEL_LEVEL_ATTENTION || param == FUEL_LEVEL_MONITOR)
                    {
                        document.getElementById('detail-column-label').innerHTML = 'Fuel Level (%)';
                    }
                    
                    if (param == FUEL_LEVEL_BREAKDOWN) $('#detail-dialog-text').html('Fuel Level: Fault');
                    else if (param == FUEL_LEVEL_ATTENTION) $('#detail-dialog-text').html('Fuel Level: Attention');
                    else if (param == FUEL_LEVEL_MONITOR) $('#detail-dialog-text').html('Fuel Level: Monitor');
                    
                    
                    document.getElementById('detail-from-date').innerHTML = detailFromDate;
                    
                    
                    var detailHtml = '';
                    var count = 0;
//                    alert(conditionIssues.length)
                    
                    for (var i = 0 ; i < conditionIssues.length ; i++)
                    {
                        if (conditionIssues[i].param != param)
                        {
                            continue;
                        }
                        
                        var id = conditionIssues[i].id;
                        var assetId = conditionIssues[i].assetId;
                        var label = conditionIssues[i].label;
                        var value = conditionIssues[i].value;
                        var timestamp = conditionIssues[i].timestamp;
                        var coord = conditionIssues[i].coord;
                        var remarks = conditionIssues[i].remarks;
                        var location = conditionIssues[i].location;

                            
                        if (count%2 == 0)
                        {
                            detailHtml += '<div class="row cells5 subpart-odd-popup">';
                        }
                        else
                        {
                            detailHtml += '<div class="row cells5 subpart-even-popup">';
                        }
                            detailHtml += '<div class="cell">' + label + '</div>';

                            if (remarks != 'null' && remarks != '')
                            {
                                detailHtml += '<div class="cell">[' + remarks + '] ' + value + '</div>';
                            }
                            else
                            {
                                detailHtml += '<div class="cell">' + value + '</div>';
                            }


                            detailHtml += '<div class="cell">' + timestamp + '</div>';
                            /*detailHtml += '<div class="cell">'
                                                + '<img src="img/vehicle-health/btn_chart.png" height="22" width="22" style="cursor: pointer" onclick="showHistory(\'' + id + '\',\'' + label + '\')">'
                                                + '</div>';*/

                            detailHtml += '<div class="cell">' + location + '</div>';

                        detailHtml += '</div>';
                            
                        count++;
                    }

                    document.getElementById("system-issues-details").innerHTML = detailHtml;

                    $('#detail-dialog').data('dialog').open();
                }, 50);
            }
            
            function updateAllParam()
            {
//                alert($('#fuel_alert_from').val())
//                alert($('#overcharging').val())
                $.ajax({
                    type: 'GET',
                    url: 'VehicleHealthController',
                    data: {
                        type: 'system',
                        action: 'updateallparameters',
                        customerId: '<%=customerId%>',
                        
                        coolantMon: $('#monitor-coolant').val(),
                        coolantWarn: $('#attn-coolant').val(),
                        coolantFault: $('#fault-coolant').val(),
                        
                        voltageMon: $('#monitor-voltage').val(),
                        voltageWarn: $('#attn-voltage').val(),
                        voltageFault: $('#fault-voltage').val(),
                        
                        overcharging: $('#overcharging').val(),
                        
                        fuelMon: $('#monitor-fuel').val(),
                        fuelWarn: $('#attn-fuel').val(),
                        fuelFault: $('#fault-fuel').val()
                    },
                    success: function(data)
                    {
                        if (data.success)
                        {
                            dialog('Success', 'Settings updated', 'success');
                        }
                        else
                        {
                            dialog('Error', 'Unable to update, please try again', 'alert');
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }
            
            function refreshDashboard()
            {
                $.ajax({
                    type: 'GET',
                    url: 'VehicleHealthController',
                    data: {
                        type: 'system',
                        action: 'getvehiclehealth',
                        date: $("#dashboard-date").val(),
                        customerId: '<%=customerId%>'
                    },
                    success: function(data)
                    {
                        if (data.success)
                        {
                            conditionIssues = [];
                            var breakdowns = [];
                            var faults = [];
                           
//                            detailFromDate = "Since " + data.from;
                            detailFromDate = "";
                            var result = data.data;
                            
                            var coolantTempMonitor = 0;
                            var coolantTempAttention = 0;
                            var coolantTempBreakdown = 0;
                            
                            var mainVoltageMonitor = 0;
                            var mainVoltageAttention = 0;
                            var mainVoltageBreakdown = 0;
                            
                            var overcharging = 0;
                            
                            var fuelLevelMonitor = 0;
                            var fuelLevelAttention = 0;
                            var fuelLevelBreakdown = 0;
                            
                            
                            for (var i = 0 ; i < result.length ; i++)
                            {
                                var id = result[i].id;
                                var assetId = result[i].asset_id;
                                var issue = result[i].issue_type_id;
                                var param = result[i].parameter_id;
                                var label = result[i].label;
                                var timestamp = result[i].trigger_timestamp;
                                var notif = result[i].notification_time;
                                var location = result[i].location;
                                var coord = result[i].latitude + ',' + result[i].longitude;
                                var value = result[i].value_when_triggered;
                                var remarks = result[i].remarks;
                                var attended = result[i].attended;
                                
                                if (param == COOLANT_TEMP_MONITOR) coolantTempMonitor++;
                                else if (param == COOLANT_TEMP_ATTENTION) coolantTempAttention++;
                                else if (param == COOLANT_TEMP_BREAKDOWN) coolantTempBreakdown++;
                                
                                else if (param == MAIN_VOLTAGE_MONITOR) mainVoltageMonitor++;
                                else if (param == MAIN_VOLTAGE_ATTENTION) mainVoltageAttention++;
                                else if (param == MAIN_VOLTAGE_BREAKDOWN) mainVoltageBreakdown++;
                                
                                else if (param == OVERCHARGING) overcharging++;
                                
                                else if (param == FUEL_LEVEL_MONITOR) fuelLevelMonitor++;
                                else if (param == FUEL_LEVEL_ATTENTION) fuelLevelAttention++;
                                else if (param == FUEL_LEVEL_BREAKDOWN) fuelLevelBreakdown++;
                                
                                
                                var aCondition = {
                                        id: id,
                                        assetId: assetId,
                                        label: label,
                                        param: param,
                                        value: value,
                                        timestamp: timestamp,
                                        location: location,
                                        coord: coord,
                                        remarks: remarks
                                    }
                                    
                                conditionIssues.push(aCondition);
                            }
                                
                            
                            /*
                             * Coolant Temp
                             */
                            
                            var coolantTempHtml = '';
                            coolantTempHtml += '<div class="status-box" onclick="showPopup(' + COOLANT_TEMP_BREAKDOWN + ')">';
                                if (coolantTempBreakdown > 0)
                                {
                                    coolantTempHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                else
                                {
                                    coolantTempHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                coolantTempHtml += '<div class="status-box-text">Fault</div>';
                                coolantTempHtml += '<div class="status-box-count">' + coolantTempBreakdown + '</div>';
                            coolantTempHtml += '</div>';
                            
                            coolantTempHtml += '<div class="status-box" onclick="showPopup(' + COOLANT_TEMP_ATTENTION + ')">';
                                coolantTempHtml += '<div class="status-box-icon attn"></div>';
                                coolantTempHtml += '<div class="status-box-text">Attention</div>';
                                coolantTempHtml += '<div class="status-box-count">' + coolantTempAttention + '</div>';
                            coolantTempHtml += '</div>';
                            
                            coolantTempHtml += '<div class="status-box" onclick="showPopup(' + COOLANT_TEMP_MONITOR + ')">';
                                coolantTempHtml += '<div class="status-box-icon monitor"></div>';
                                coolantTempHtml += '<div class="status-box-text">Monitor</div>';
                                coolantTempHtml += '<div class="status-box-count">' + coolantTempMonitor + '</div>';
                            coolantTempHtml += '</div>';
                            
                            document.getElementById("coolant-temp-status").innerHTML = coolantTempHtml;
                            
                            
                            
                            /*
                             * Main Power Voltage
                             */
                            var mainVoltageHtml = '';
                            mainVoltageHtml += '<div class="status-box" onclick="showPopup(' + MAIN_VOLTAGE_BREAKDOWN + ')">';
                                if (mainVoltageBreakdown > 0)
                                {
                                    mainVoltageHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                else
                                {
                                    mainVoltageHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                mainVoltageHtml += '<div class="status-box-text">Fault</div>';
                                mainVoltageHtml += '<div class="status-box-count">' + mainVoltageBreakdown + '</div>';
                            mainVoltageHtml += '</div>';
                            
                            mainVoltageHtml += '<div class="status-box" onclick="showPopup(' + MAIN_VOLTAGE_ATTENTION + ')">';
                                mainVoltageHtml += '<div class="status-box-icon attn"></div>';
                                mainVoltageHtml += '<div class="status-box-text">Attention</div>';
                                mainVoltageHtml += '<div class="status-box-count">' + mainVoltageAttention + '</div>';
                            mainVoltageHtml += '</div>';
                            
                            mainVoltageHtml += '<div class="status-box" onclick="showPopup(' + MAIN_VOLTAGE_MONITOR + ')">';
                                mainVoltageHtml += '<div class="status-box-icon monitor"></div>';
                                mainVoltageHtml += '<div class="status-box-text">Monitor</div>';
                                mainVoltageHtml += '<div class="status-box-count">' + mainVoltageMonitor + '</div>';
                            mainVoltageHtml += '</div>';
                            
                            document.getElementById("main-voltage-status").innerHTML = mainVoltageHtml;
                            
                            
                            /*
                             * OVERCHARGING
                             */
                            
                            var overchargingHtml = '';
                            overchargingHtml += '<div class="status-box" onclick="showPopup(' + OVERCHARGING + ')">';
                                if (overcharging > 0)
                                {
                                    overchargingHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                else
                                {
                                    overchargingHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                overchargingHtml += '<div class="status-box-text">Fault</div>';
                                overchargingHtml += '<div class="status-box-count">' + overcharging + '</div>';
                            overchargingHtml += '</div>';
                            
                            document.getElementById("overcharging-status").innerHTML = overchargingHtml;
                            
                            
                            /*
                             * Fuel Level
                             */
                            
                            var fuelLevelHtml = '';
                            fuelLevelHtml += '<div class="status-box" onclick="showPopup(' + FUEL_LEVEL_BREAKDOWN + ')">';
                                if (fuelLevelBreakdown > 0)
                                {
                                    fuelLevelHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                else
                                {
                                    fuelLevelHtml += '<div class="status-box-icon breakdown"></div>';
                                }
                                fuelLevelHtml += '<div class="status-box-text">Fault</div>';
                                fuelLevelHtml += '<div class="status-box-count">' + fuelLevelBreakdown + '</div>';
                            fuelLevelHtml += '</div>';
                            
                            fuelLevelHtml += '<div class="status-box" onclick="showPopup(' + FUEL_LEVEL_ATTENTION + ')">';
                                fuelLevelHtml += '<div class="status-box-icon attn"></div>';
                                fuelLevelHtml += '<div class="status-box-text">Attention</div>';
                                fuelLevelHtml += '<div class="status-box-count">' + fuelLevelAttention + '</div>';
                            fuelLevelHtml += '</div>';
                            
                            fuelLevelHtml += '<div class="status-box" onclick="showPopup(' + FUEL_LEVEL_MONITOR + ')">';
                                fuelLevelHtml += '<div class="status-box-icon monitor"></div>';
                                fuelLevelHtml += '<div class="status-box-text">Monitor</div>';
                                fuelLevelHtml += '<div class="status-box-count">' + fuelLevelMonitor + '</div>';
                            fuelLevelHtml += '</div>';
                            
                            document.getElementById("fuel-level-status").innerHTML = fuelLevelHtml;
                            
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }
            
            
            
            
        </script>
        
        
        <style>
           .single-health{
                float: left;
                margin-right: 60px;
                margin-top: 0px;
            }
            
            .subheader{
                margin-left: 10px;
                font-size: 16px;
                font-weight: bold;
            }
            
            .subexplanation{
                margin-left: 10px;
                font-size: 10px;
                font-weight: normal;
            }
            
            .param-box{
                margin-top: 10px;
                width: 290px;
                height: 130px;
                /*background: #990066;*/
                
                border-radius: 3px;
                border-width: 1px;
                border-style: solid;
            }
            
                .param-single{
                    height: 30px;
                    width: 300px;
                    float: left;

                    margin-top: 8px;
                    /*background: #990066;*/
                }
            
                    .param-text{
                        float: left;
                        height: 30px;
                        width: 150px;
                        
                        line-height: 30px;
                        
                        margin-left: 15px;
                        /*background: #009966;*/
                    }
                    
                    .param-sign{
                        float: left;
                        height: 30px;
                        line-height: 30px;
                        
                        margin-left: 10px;
                        /*background: #669900;*/
                        font-size: 16px;
                    }
                    
                    .param-input{
                        float: left;
                        height: 30px;
                        width: 60px;
                        line-height: 30px;
                        
                        margin-left: 30px;
                        /*background: #669900;*/
                        
                        border-radius: 10px;
                        border-width: 1px;
                        border-style: solid;
                    }
                    
                    input{
                        outline: none;
                        border: none;
                    }
                    
                    .param-input-box{
                        height: 20px;
                        width: 40px;
                        margin-left: 10px;
                        margin-top: 4px;
                        background: none;
                    }         
            
        </style>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("vehicleHealth")%></h1>
        </div>
        <br>
        <div class="grid" style="max-width: 100%">
            <div class="row cells1">
                <div class="cell">
                    <div id="setting-update" onclick="updateAllParam()">
                        UPDATE SETTINGS
                    </div>
                </div>
            </div>
            <br/>
            
            <div class="row cells1">
                <div class="single-health">
                    <div class="subheader">Coolant Temperature (°C)</div>
                    <div class="subexplanation">Notify when value goes ABOVE triggering points</div>
                    <div class="param-box">
                        <div class="param-single">
                            <div class="param-text">To Monitor</div><div class="param-sign">></div>
                            <div class="param-input"> <input class="param-input-box" type="text" maxlength="4" id="monitor-coolant" 
                                                             onkeyup="paramChanged('monitor-coolant',3)"/></div>
                        </div>

                        <div class="param-single">
                            <div class="param-text">Need Attention</div><div class="param-sign">></div>
                            <div class="param-input"><input class="param-input-box" type="text" maxlength="4" id="attn-coolant"
                                                            onkeyup="paramChanged('attn-coolant',4)"/></div>
                        </div>

                        <div class="param-single">
                            <div class="param-text">Fault</div><div class="param-sign">></div>
                            <div class="param-input"><input class="param-input-box" type="text" id="fault-coolant"
                                                            onkeyup="paramChanged('fault-coolant',5)"/></div>
                        </div>
                    </div>
                </div>

                <div class="single-health">
                    <div class="subheader">Main Voltage (V)</div>
                    <div class="subexplanation">Notify when value goes BELOW triggering points</div>
                    <div class="param-box">
                        <div class="param-single">
                            <div class="param-text">To Monitor</div><div class="param-sign"><</div>
                            <div class="param-input"> <input class="param-input-box" type="text" maxlength="4" id="monitor-voltage" 
                                                             onkeyup="paramChanged('monitor-voltage',6)"/></div>
                        </div>

                        <div class="param-single">
                            <div class="param-text">Need Attention</div><div class="param-sign"><</div>
                            <div class="param-input"><input class="param-input-box" type="text" maxlength="4" id="attn-voltage"
                                                            onkeyup="paramChanged('attn-voltage',7)"/></div>
                        </div>

                        <div class="param-single">
                            <div class="param-text">Fault</div><div class="param-sign"><</div>
                            <div class="param-input"><input class="param-input-box" type="text" id="fault-voltage"
                                                            onkeyup="paramChanged('fault-voltage',8)"/></div>
                        </div>
                    </div>
                </div>

                <div class="single-health">
                    <div class="subheader">Overcharging (V)</div>
                    <div class="subexplanation">Notify when value goes ABOVE triggering points</div>
                    <div class="param-box">
                        <div class="param-single">
                            <div class="param-text">Fault</div><div class="param-sign">></div>
                            <div class="param-input"><input class="param-input-box" type="text" id="overcharging"
                                                            onkeyup="paramChanged('overcharging',43)"/></div>
                        </div>
                    </div>
                </div>

                <div class="single-health">
                    <div class="subheader">Fuel Level (%)</div>
                    <div class="subexplanation">Notify when value goes BELOW triggering points</div>
                    <div class="param-box">
                        <div class="param-single">
                            <div class="param-text">To Monitor</div><div class="param-sign"><</div>
                            <div class="param-input"> <input class="param-input-box" type="text" maxlength="4" id="monitor-fuel" 
                                                             onkeyup="paramChanged('monitor-fuel',15)"/></div>
                        </div>

                        <div class="param-single">
                            <div class="param-text">Need Attention</div><div class="param-sign"><</div>
                            <div class="param-input"><input class="param-input-box" type="text" maxlength="4" id="attn-fuel"
                                                            onkeyup="paramChanged('attn-fuel',16)"/></div>
                        </div>

                        <div class="param-single">
                            <div class="param-text">Fault</div><div class="param-sign"><</div>
                            <div class="param-input"><input class="param-input-box" type="text" id="fault-fuel"
                                                            onkeyup="paramChanged('fault-fuel',17)"/></div>
                        </div>
                    </div>
                </div>
            </div>
            
            
            <div class="row cells1" style="margin-top: 20px; margin-bottom: -7px;">
                <div class="cell">
                    <div class="subpart-header" style="float: left; margin-top: 25px;">Systems Exceeding Operating Limits</div>
                </div>
            </div>
        
            <div class="row cells5" style="margin-bottom: -20px;">
                <div class="cell">
                    <div class="input-control text full-size" data-role="input">
                            <span class="mif-calendar prepend-icon"></span>
                            <input class="starting-from" id="dashboard-date" type="text" placeholder="Date" value="" autocomplete="on" readonly="" style="padding-right: 36px;">
                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                    </div>
                </div>
            </div>
            
            <div class="row cells1">
                <div style="float: left; clear: both; margin-bottom: 30px;">
                    <div class="health-box">
                        <div class="health-left">
                            <div class="health-icon icon-temp"></div>
                            <div class="health-title">COOLANT TEMP</div>
                        </div>

                        <div class="health-right">
                            <div class="health-marker"></div>

                            <div class="health-status" id="coolant-temp-status">
                                <div class="status-box" onclick="showPopup()">
                                    <div class="status-box-icon breakdown"></div>
                                    <div class="status-box-text">Fault</div>
                                    <div class="status-box-count">122</div>
                                </div>

                                <div class="status-box">
                                    <div class="status-box-icon attn"></div>
                                    <div class="status-box-text">Attention</div>
                                    <div class="status-box-count">0</div>
                                </div>

                                <div class="status-box">
                                    <div class="status-box-icon monitor"></div>
                                    <div class="status-box-text">Monitor</div>
                                    <div class="status-box-count">2</div>
                                </div>
                            </div>
                        </div>
                    </div>


                    <div class="health-box">
                        <div class="health-left">
                            <div class="health-icon icon-voltage"></div>
                            <div class="health-title">MAIN POWER</div>
                        </div>

                        <div class="health-right">
                            <div class="health-marker"></div>

                            <div class="health-status" id="main-voltage-status">
                                <div class="status-box inactive">
                                    <div class="status-box-icon breakdown"></div>
                                    <div class="status-box-text">Fault</div>
                                    <div class="status-box-count">1</div>
                                </div>

                                <div class="status-box">
                                    <div class="status-box-icon attn"></div>
                                    <div class="status-box-text">Attention</div>
                                    <div class="status-box-count">1</div>
                                </div>

                                <div class="status-box">
                                    <div class="status-box-icon monitor"></div>
                                    <div class="status-box-text">Monitor</div>
                                    <div class="status-box-count">3</div>
                                </div>
                            </div>


                        </div>
                    </div>


                    <div class="health-box">
                        <div class="health-left">
                            <div class="health-icon icon-voltage"></div>
                            <div class="health-title">OVER- CHARGING</div>
                        </div>

                        <div class="health-right">
                            <div class="health-marker"></div>

                            <div class="health-status" id="overcharging-status">
                                <div class="status-box inactive">
                                    <div class="status-box-icon breakdown"></div>
                                    <div class="status-box-text">Fault</div>
                                    <div class="status-box-count">1</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="health-box">
                        <div class="health-left">
                            <div class="health-icon icon-fuel"></div>
                            <div class="health-title">FUEL LEVEL</div>
                        </div>

                        <div class="health-right">
                            <div class="health-marker"></div>

                            <div class="health-status" id="fuel-level-status">
                                <div class="status-box inactive">
                                    <div class="status-box-icon breakdown"></div>
                                    <div class="status-box-text">Fault</div>
                                    <div class="status-box-count">0</div>
                                </div>

                                <div class="status-box">
                                    <div class="status-box-icon attn"></div>
                                    <div class="status-box-text">Attention</div>
                                    <div class="status-box-count">1</div>
                                </div>

                                <div class="status-box">
                                    <div class="status-box-icon monitor"></div>
                                    <div class="status-box-text">Monitor</div>
                                    <div class="status-box-count">0</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        
        
        <div data-role="dialog" id="detail-dialog" class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light" id="detail-dialog-text">Tyre Pressure: Fault</h1>
                <p id="detail-from-date">22-Feb-2020</p>
                <div class="form-dialog-content" style="margin-top: 100px;">
                    <div class="grid" style="margin-top: 30px; max-width: 100%; margin-left: 10px; min-width: 700px !important">
                        <div class="subpart-container" style="">
                            <div class="row cells5 subpart-table-header">
                                <div class="cell">Bus</div>
                                <div class="cell" id="detail-column-label">Tyre Pressure (psi)</div>
                                <div class="cell">Timestamp</div>
                                <!--<div class="cell">History</div>-->
                                <div class="cell">Location</div>
                            </div>
                            <div id="system-issues-details" style="height: 200px;">
                                <div class="row cells5 subpart-odd-popup">  
                                    <div class="cell">SG1195C</div>
                                    <div class="cell">95 [pos #2]</div>
                                    <div class="cell">22/02/2020 11:10</div>
                                    <div class="cell">
                                        <img src="img/vehicle-health/btn_chart.png" height="22" width="22">
                                    </div>
                                    <div class="cell">
                                        <a href="https://www.google.com/maps/search/?api=1&query=1.372360, 103.946802" target="_blank"><img src="img/vehicle-health/btn_location.png" height="22" width="22"></a>
                                    </div>
                                </div>
                                <div class="row cells5 subpart-even-popup">  
                                    <div class="cell">SBS6521A</div>
                                    <div class="cell">99 [pos #5]</div>
                                    <div class="cell">22/02/2020 14:45</div>
                                    <div class="cell">
                                        <img src="img/vehicle-health/btn_chart.png" height="22" width="22">
                                    </div>
                                    <div class="cell">
                                        <a href="https://www.google.com/maps/search/?api=1&query=1.372360, 103.946802" target="_blank"><img src="img/vehicle-health/btn_location.png" height="22" width="22"></a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        
        
        
        
    </body>
</html>
