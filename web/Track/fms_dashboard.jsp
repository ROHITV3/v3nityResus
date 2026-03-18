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
                                allHtml += '<div class="row cells1" style="margin-bottom: 5px;">';
                                    allHtml += '<div class="cell" id="last-updated">';
                                        allHtml += '<i>Last Updated on ' + data.timestamp + '</i>';
                                    allHtml += '</div>';
                                allHtml += '</div>';
                            }
                            
                            for (var i = 0 ; i < data.alldata.length ; i++)
                            {
                                var aData = data.alldata[i];
                                
                                allAssetIds[i] = aData.asset_id;
                                allFuelLevels[i] = aData.fuel_level;
                                
                                allHtml += '<div class="single-vehicle-box">';
                                    allHtml += '<div class="row cells1" style="margin-bottom: 5px;">';
                                        allHtml += '<div class="cell vehicle-label">' + aData.label + '</div>';
                                    allHtml += '</div>';
                                    
                                    allHtml += '<div class="row cells5">';
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Ignition Status</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.ignition + '</div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-chart-title">Fuel Level (%)</div>';
                                            allHtml += '<div class="fms-chart-value" id="fuel-level-' + aData.asset_id + '"></div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Service Brake Circuit 1 Air Pressure</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.service_brake_circuit_1_air_pressure + '</div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Engine Coolant Temperature (°C)</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.engine_coolant_temperature + '</div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Engine RPM</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.rpm + '</div>';
                                        allHtml += '</div>';
                                    allHtml += '</div>';
                                    
                                    
                                    allHtml += '<div class="row cells4">';
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Engine Hours</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.engine_hours + '</div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Main Power Voltage</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.main_power_voltage + '</div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Cabin Temperature (°C)</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.temperature + '</div>';
                                        allHtml += '</div>';
                                        
                                        allHtml += '<div class="cell fms-info-box">';
                                            allHtml += '<div class="fms-item-title">Mileage (KM)</div>';
                                            allHtml += '<div class="fms-item-value">' + aData.mileage + '</div>';
                                        allHtml += '</div>';
                                    allHtml += '</div>';
                                allHtml += '</div>';   
                            }
                            
                            document.getElementById('vehicles-container').innerHTML = allHtml;
                            
                            setTimeout(function()
                            {
                                reloadFuelLevel(allAssetIds, allFuelLevels);
                            }, 100);
                        }
                        else
                        {
                            document.getElementById('vehicles-container').innerHTML = allHtml;
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
                        levelColors: myColors
                    });
                }
            }
            
            
            
            
        </script>
        
        <style>
            .single-vehicle-box
            {
                width: auto;
                height: auto;
                /*background: #00aa00;*/
                padding: 10px;
                margin-top: 20px;
                
                max-width: 1200px;
                border-width: 2px;
                border-style: solid;
            }
            
                .vehicle-label
                {
                    font-weight: bold;
                    font-size: 20px;
                }

                .fms-info-box
                {
                    width: 170px;
                    height: 120px;
                    /*background: #990000;*/
                    min-width: 170px;
                    max-width: 280px;
                    border-width: 2px;
                    border-style: solid;
                }

                    .fms-item-title
                    {
                        font-weight: normal;
                        font-size: 16px;
                        text-align: center;
                        margin: 5px;
                        margin-top: 10px;
                        /*background: #0000aa;*/
                        height: 40px;
                        line-height: 20px;
                    }

                    .fms-item-value
                    {
                        font-weight: bold;
                        font-size: 24px;
                        text-align: center;
                        margin: 5px;
                        margin-top: 15px;
                        vertical-align: bottom;
                        /*background: #aa0000;*/
                        height: 50px;
                        line-height: 50px;
                    }
                    
                    .fms-chart-title
                    {
                        font-weight: normal;
                        font-size: 16px;
                        text-align: center;
                        margin: 5px;
                        margin-top: 10px;
                        /*background: #0000aa;*/
                        height: 20px;
                        line-height: 20px;
                    }
                    
                    .fms-chart-value
                    {
                        font-weight: bold;
                        font-size: 24px;
                        text-align: center;
                        margin: auto;
                        margin-top: -25px;
                        vertical-align: bottom;
                        /*background: #aa0000;*/
                        height: 105px;
                        line-height: 105px;
                    }
                    
            #last-updated
            {
                font-size: 16px;
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
<!--                    <div class="row cells1" style="margin-bottom: 5px;">
                        <div class="cell" id="last-updated">
                            Last Updated on 22-06-2019 10:00:00
                        </div>
                    </div>
                    <div class="single-vehicle-box">
                        <div class="row cells1" style="margin-bottom: 5px;">
                            <div class="cell vehicle-label">
                                TITLE
                            </div>
                        </div>
                        <div class="row cells4">
                            <div class="cell fms-info-box">
                                <div class="fms-item-title">Ignition Status or an even longer</div>
                                <div class="fms-item-value">ON</div>
                            </div>
                            <div class="cell fms-info-box">
                                <div class="fms-chart-title">Ignition Status</div>
                                <div class="fms-chart-value" id="fuelLevelChart"></div>
                            </div>
                            <div class="cell fms-info-box">
                                b3
                            </div>
                            <div class="cell fms-info-box">
                                b4
                            </div>
                        </div>
                    </div>
                    
                    <div class="single-vehicle-box">
                        <div class="row cells1">
                            <div class="cell">
                                TITLE
                            </div>
                        </div>
                        <div class="row cells4">
                            <div class="cell">
                                b1
                            </div>
                            <div class="cell">
                                b2
                            </div>
                            <div class="cell">
                                b3
                            </div>
                            <div class="cell">
                                b4
                            </div>

                        </div>
                    </div>-->
                </div>
            </div>
        </div>
    </body>
</html>
