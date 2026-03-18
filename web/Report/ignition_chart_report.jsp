<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
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
        <script src="js/Chart.js"></script>        
        <script type="text/javascript" >

            var intervalId = 0;

            var legendColors = ['#4e89e8', '#c40179', '#488906'];
            

            $(document).ready(function()
            {            
                $("#getChart").click(function()
                {
                    var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

                    if (ids.split(',').length > 5)
                    {
                        dialog('Maximum Reached', 'You can only select up to 5 assets', 'alert');
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
                var chart = null;                                
                
                var startDate = document.getElementById("historyFromDate").value;

                var endDate = document.getElementById("historyToDate").value;       
                
                var mode =   $('#input-header').prop('checked');
                
                $('#chart').replaceWith('<canvas id="chart"   style="height: 500px"></canvas>');                                
                
                if (mode){
                    var  stepSize = 1;
                }
                else{
                    stepSize = 1000;
                }
                
                $('#chart').empty();// should change to redraw

                $.ajax({
                    type: 'POST',
                    url: 'ChartController',
                    data: {
                        action: 'get',
                        type: 'ignition_chart_report',
                        ids: ids,
                        mode: mode,
                        startDate: startDate,
                        endDate: endDate
                    },
                    beforeSend: function()
                    {

                    },
                    success: function(data,stepSize,labelstring)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {

                                var dataSeries = data.records;

                                if (dataSeries.length > 0)
                                {
                                    createChart(data,  stepSize, labelstring);
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
                        else
                        {
                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
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

            function resetDate()
            {
                var resetStartDate = '<%=inputStartDate%>';

                var resetEndDate = '<%=inputEndDate%>';

                $("#historyFromDate").val(resetStartDate);

                $("#historyToDate").val(resetEndDate);
            }
            
                 function  createChart (data, stepSize,labelstring) {                     
                    var canvas =  document.getElementById("chart");
                    var ctx = canvas.getContext("2d");                            

                    var barChartData = {
                        backgroundColor: ["#00b386", "#ffd633", "#ff9999","#437DC6","#DC143C"],
                        datasets: []                         
                    };                                           
                   
                    var chart = new Chart(ctx, {
                        type: 'horizontalBar',
                        data: barChartData,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>'
                            },
                            legend: {
                                display: true
                            },
                            scales: {
                                yAxes: [],
                                xAxes:[{
                                        ticks: {
                                            min: 0,
                                            stepSize: stepSize,                                            
                                        },
                                         scaleLabel: {
                                            display: true,
                                            labelString: "Total duration in of ignition on status",
                                         }
                                    }]
                            },                       
                        }
                    });
                    updateChart(chart,data);
                    chart.update();
                 }
            
             function updateChart (chart, data) {
                var result = data.records;
                chart.data.datasets.splice(0, chart.data.datasets.length);
                for (var i = 0; i < result.length; i++) {
                    var newDataset = {
                        label: [],
                        backgroundColor: [],
                        data: []
                    };
                    newDataset.label.push(result[i].label);
                    newDataset.backgroundColor.push(chart.data.backgroundColor[i]);
                    newDataset.data.push(result[i].hour);
                    chart.data.datasets.push(newDataset);
                }
             }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("ignitionChart")%></h1>
        </div>
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="getChart" name="getChart"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset" value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>
             <div class="section"><br>
            <h4 class="text-light align-left">Options</h4>
            <label class="input-control checkbox">
                <input id="input-header" type="checkbox" checked>
                <span class="check"></span>
                <span class="caption">Monthly Interval (Hourly interval when unchecked)</span>
            </label>
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
                </div>
                <div id =" chartcontainer" class="cell colspan4">
                    <canvas  id="chart" style="height: 500px"></canvas>
                </div>
            </div>
        </div>
    </body>
</html>