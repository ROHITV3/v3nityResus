<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%    
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    AssetTreeView assetTreeView = new AssetTreeView(userProperties);

    assetTreeView.setIdentifier("filter-asset");

    assetTreeView.loadData(userProperties);

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today) + " 00:00:00";

    String inputEndDate = dateTimeFormatter.format(today) + " 23:59:59";
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <link href="css/metricsgraphics.css" rel="stylesheet">
        <title>${title}</title>
        <script src="js/d3.min.js"></script>
        <script src="js/metricsgraphics.min.js"></script>
        <script type="text/javascript" >

            var intervalId = 0;

            var legendColors = ['#4e89e8', '#c40179', '#488906'];

            $(document).ready(function()
            {

                $("#getChart").click(function()
                {
                    var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

//                    if (ids.split(',').length > 3)
//                    {
//                        dialog('Maximum Reached', 'You can only select up to 3 assets', 'alert');
//                    }
//                    else
//                    {
//                        getChart(ids);
//                    }

                    if (ids.split(',').length > 1)
                    {
                        dialog('Maximum Reached', 'You can only select 1 asset', 'alert');
                    }
                    else
                    {
                        getChart(ids);
                    }
                });

                $("#historyFromDate").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#historyToDate").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

            });

            function dispose()
            {

                $("#historyFromDate").AnyTime_noPicker();

                $("#historyToDate").AnyTime_noPicker();
            }

            function getChart(ids)
            {
                var startDate = document.getElementById("historyFromDate").value;

                var endDate = document.getElementById("historyToDate").value;

                $('#chart').empty();// should change to redraw

                $.ajax({
                    type: 'POST',
                    url: 'ChartController',
                    data: {
                        action: 'get',
                        type: 'temperature_chart_report',
                        ids: ids,
                        startDate: startDate,
                        endDate: endDate
                    },
                    beforeSend: function()
                    {

                    },
                    success: function(data)
                    {
                        console.log('data', data);
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {

                                var dataSeries = data.dataSeries;

                                var label = data.label;
                                
                                var limits = ($('input:radio[name=temperature]:checked').val() === '1') ? data.primaryLimits : data.secondaryLimits;
                                // if a limit is zero no need to show baseline for that limit
                                
                                if (limits)
                                {
                                    for (var i = 0; i < limits.length; i++)
                                    {

                                        if (limits[i].value == 0){

                                            limits.splice(i,1);
                                            i--;
                                        }
                                    }
                                }
                                
                                if (dataSeries.length > 0)
                                {
                                    for (var i = 0; i < dataSeries.length; i++)
                                    {
                                        dataSeries[i] = MG.convert.date(dataSeries[i], 'timestamp', "%Y%m%d%H%M%S");
                                    }

                                    MG.data_graphic({
                                        data: dataSeries,
                                        right: 40,
                                        left: 90,
                                        bottom: 90,
                                        interpolate: 'basic',
                                        target: document.getElementById('chart'),
                                        x_accessor: 'timestamp',
                                        y_accessor: ($('input:radio[name=temperature]:checked').val() === '1') ? 'value1' : 'value2',
                                        x_label: 'Timestamp',
                                        y_label: 'Temperature [\u00B0C]',
                                        colors: legendColors,
                                        x_extended_ticks: true,
                                        full_width: true,
                                        full_height: true,
                                        aggregate_rollover: true,
                                        baselines: limits
                                    });

                                    var legendContainer = $('#legend');

                                    legendContainer.html('');

                                    for (var i = 0; i < label.length; i++)
                                    {
                                        var legendItem = $('<li/>');

                                        legendItem.html('<span style="background-color:' + legendColors[i] + '"></span>' + label[i] + '');

                                        legendContainer.append(legendItem);
                                    }
                                }
                                else
                                {
                                    dialog('No Data', 'There is no data available', 'alert');
                                }
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
//                        else
//                        {
//                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                        }
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

            function resetDate()
            {
                var resetStartDate = '<%=inputStartDate%>';

                var resetEndDate = '<%=inputEndDate%>';

                $("#historyFromDate").val(resetStartDate);

                $("#historyToDate").val(resetEndDate);
            }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("temperatureChart")%></h1>
        </div>
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="getChart" name="getChart"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset" value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>
        </div>
        <div class="grid">
            <div class="row cells6">
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("asset")%></h4>
                    <div id="chartFrame" class="treeview-control">
                        <% assetTreeView.outputHTML(out, userProperties);%>
                    </div>
                </div>
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("dateRange")%></h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="historyFromDate" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="historyToDate" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="<%=inputEndDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <br>
                    <br>
                    <div>
                        <h4 class="text-light align-left">Temperature Probe</h4>
                        <label class="input-control radio">
                            <input type="radio" name="temperature" value="1" checked>
                            <span class="check"></span>
                            <span class="caption">Primary Temperature</span>
                        </label>
                        <label class="input-control radio">
                            <input type="radio" name="temperature" value="2" >
                            <span class="check"></span>
                            <span class="caption">Secondary Temperature</span>
                        </label>
                    </div>
                </div>
                <div class="cell colspan4">
                    <div><ul id="legend" class="pie-legend"></ul></div>
                    <div id="chart" style="height: 500px"></div>
                </div>
            </div>
        </div>
    </body>
</html>