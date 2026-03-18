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

    //For Status Dashboard

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
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
            
            $(document).ready(function()
            {
                setInterval(function()
                {
                    if (selectedIds != '')
                    {
                        getdata(selectedIds);
                    }
                }, refreshRate);
                
            });

            function dispose()
            {
                
            }
            
            var FMS_ITEMS = ['Ignition Status', 'Fuel Level (%)', 'Service Brake Circuit 1 Air Pressure', 'Engine Coolant Temperature (C)',
                                'Engine Hours', 'Main Power Voltage', 'Battery Voltage', 'Mileage (KM)'];
            
            
            
            function getdata(ids)
            {
                $.ajax({
                    type: 'POST',
                    url: 'DashboardFmsController',
                    data: 
                    {
                        action: 'getdata',
                        type: 'fmsdashboard',
                        assetids: ids
                    },
                    beforeSend: function(){},
                    success: function(data)
                    {
                        var allHtml = '';
                        
                        allAssetIds = [];
                        allFuelLevels = [];
                        
                        if (data.result)
                        {
                            if (data.alldata.length > 0)
                            {
                                document.getElementById('last-updated').innerHTML = '<i>Last Updated on ' + data.timestamp + '</i>';
                                document.getElementById('headers').style.visibility = '';
                            }
                            else
                            {
                                document.getElementById('headers').style.visibility = 'hidden';
                            }
                            
                            for (var i = 0 ; i < data.alldata.length ; i++)
                            {
                                var aData = data.alldata[i];
                                
                                allAssetIds[i] = aData.asset_id;
                                allFuelLevels[i] = aData.fuel_level;
                                
                                if (aData.ignition === 'ON') allHtml += '<div class="singleVehicle">';
                                else allHtml += '<div class="singleVehicle alternate">';
                                
                                    allHtml += '<div class="singleContent vehicleLabel">' + aData.label + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.ignition + '</div>';
                                    allHtml += '<div class="singleContent" id="fuel-level-' + aData.asset_id + '"></div>';
                                    
                                    allHtml += '<div class="singleContent">' + aData.service_brake_circuit_1_air_pressure + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.engine_coolant_temperature + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.rpm + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.engine_hours + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.main_power_voltage + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.temperature + '</div>';
                                    allHtml += '<div class="singleContent">' + aData.mileage + '</div>';
                                allHtml += '</div>';   
                            }
                            
                            document.getElementById('vehicleContainer').innerHTML = allHtml;
                            
                            setTimeout(function()
                            {
                                reloadFuelLevel(allAssetIds, allFuelLevels);
                            }, 100);
                        }
                        else
                        {
                            document.getElementById('vehicleContainer').innerHTML = allHtml;
                            dialog('Error', 'Unable to load FMS data', 'alert');
                        }
                        
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                    },
                    async: true
                });
            }
            
            function onTreeviewCheckboxClicked(treeview, parent, children, checked)
            {
                if (treeview === 'tree-view-filter-asset')
                {
                    var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

                    selectedIds = ids;
                    getdata(ids);
                }
                else
                {
                    return;
                }
            }
            
            
            function reloadFuelLevel(assetIdArr, fuelLevelValueArr)
            {
                var g;
                
                var myColors = [
                    "#DD0000",
                    "#DDDD00",
                    "#00DD00"
                  ]
                
                for (var i = 0 ; i < assetIdArr.length ; i++)
                {
                    g = new JustGage({
                        id: 'fuel-level-' + assetIdArr[i],
                        value: fuelLevelValueArr[i],
                        min: 0,
                        max: 100,
                        levelColors: myColors,
                        hideMinMax: true,
                        valueFontColor: '#3B6DAB'
                    });
                }
            }
            
            
            
            
        </script>
        
        <style>
                    
            #last-updated
            {
                font-size: 16px;
            }
            
            
            /*
                Below are all new ones
            */
            
            #headers
            {
                float: left;
                height: 50px;
                width: 900px;
                margin-top: 10px;
                /*background: #990000;*/
            }
            
            .singleHeader
            {
                float: left;
                height: 50px;
                width: 85px;
                /*background: #009900;*/
                border-width: 0.5px;
                border-color: #ccc;
                border-style: solid;
                margin: 5px;
                margin-right: 0px;
                
                
            }
            
            .headerText
            {
                margin-top: 5px;
                height: 40px;
                line-height: 40px;
                
                text-align: center;
                font-weight: bold;
                font-size: 17px;
                padding-left: 3px;
                padding-right: 3px;
            }
            
            
            
            .small
            {
                font-size: 14px;
            }
            
            .two-liner
            {
                line-height: 20px;
            }
            
            .no-border
            {
                border-style: none;
            }
            
            
            
            #vehicleContainer
            {
                float: left;
                height: 500px;
                width: 905px;
                /*background: #009900;*/
                margin-top: 10px;
            }
            
            .singleVehicle
            {
                margin-top: 3px;
                float: left;
                height: 50px;
                width: 905px;
                background: #F0F8FF;
                
                border-radius: 5px;
            }
            
            .alternate
            {
                background: #f7f7f7;
            }
            
            .singleContent
            {
                float: left;
                height: 40px;
                line-height: 40px;
                width: 85px;
                border-width: 0.5px;
                border-color: #ccc;
                /*border-style: solid;*/
                margin: 5px;
                margin-right: 0px;
                
                text-align: center;
                font-weight: bold;
                font-size: 14px;
                padding-left: 3px;
                padding-right: 3px;
                color: #3B6DAB;
            }
            
            .vehicleLabel{
                color: #000;
            }
            
            .greenBox{
                background: #F0FFF0;
                border-radius: 10px;
            }
            
        </style>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("fmsDashboard")%></h1>
        </div>
        <br>
        <div class="grid" style="max-width: 100%">
            <div class="row cells4">
                <div id="treeview-panel" class="cell dashboard-chart">
                    <h3 class="text-light align-left"><%=userProperties.getLanguage("asset")%></h3>
                    <div  class="treeview-control" style="height: 100%">
                        <%
                            assetTreeView.outputHTML(out, userProperties);
                        %>
                    </div>
                </div>
                <div class="cell colspan3" id="vehicles-container">
                    <div class="row cells1" style="margin-bottom: 5px;">
                        <div class="cell" id="last-updated">
                            <i>Last Updated on -</i>
                        </div>
                    </div>
                    
                    <div id="headers" style="visibility: hidden">
                        <div class="singleHeader no-border"></div>
                        <div class="singleHeader"><div class="headerText">Ignition</div></div>
                        <div class="singleHeader"><div class="headerText small">Fuel Level</div></div>
                        <div class="singleHeader"><div class="headerText small two-liner">SBC 1 Air Pressure</div></div>
                        <div class="singleHeader"><div class="headerText small two-liner">Coolant Temp (°C)</div></div>
                        <div class="singleHeader"><div class="headerText">RPM</div></div>
                        <div class="singleHeader"><div class="headerText small two-liner">Engine Hours</div></div>
                        <div class="singleHeader"><div class="headerText small two-liner">Main Voltage</div></div>
                        <div class="singleHeader"><div class="headerText small two-liner">Cabin &nbsp;Temp (°C)</div></div>
                        <div class="singleHeader"><div class="headerText">Mileage</div></div>
                    </div>

                    <div id="vehicleContainer">
<!--                        <div class="singleVehicle alternate">
                            <div class="singleContent vehicleLabel">YM2839X</div>
                            <div class="singleContent">ON</div>
                            <div class="singleContent aChart" id="fuel-level-3473"></div>
                            <div class="singleContent">289</div>
                            <div class="singleContent">37</div>
                            <div class="singleContent">2100</div>
                            <div class="singleContent">8</div>
                            <div class="singleContent">24</div>
                            <div class="singleContent">12</div>
                            <div class="singleContent">24314</div>
                        </div>-->
                    </div>
                    
                </div>
            </div>
        </div>
    </body>
</html>
