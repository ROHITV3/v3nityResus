<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%  
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    AssetDropDown assetDropDown = new AssetDropDown(userProperties);

    DriverDropDown driverDropDown = new DriverDropDown(userProperties);

    assetDropDown.setIdentifier("dropdown-asset");

    assetDropDown.loadData(userProperties);

    driverDropDown.setIdentifier("dropdown-driver");

    driverDropDown.loadData(userProperties);

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today) + " 00:00:00";

    String inputEndDate = dateTimeFormatter.format(today) + " 23:59:59";
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" type="text/css" href="css/nv.d3.min.css" />
        <style>
            svg
            {
                display: block;
            }
            #chart1, #chart3, svg
            {
                height: 300px;
                width: 100%;
                padding-right: 4px;
            }
            #chart2
            {
                height: 400px !important;
                width: 100%;
                padding-right: 4px;
            }

        </style>
        <script src="js/d3.min.js"></script>
        <script src="js/nv.d3.min.js"></script>
        <script type="text/javascript">

            $(document).ready(function()
            {

                $("#scorePercentagePieChart").hide();

                $("#dateTimePicker-history-start-date").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#dateTimePicker-history-end-date").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                function NASort(a, b)
                {

                    return (a.innerHTML > b.innerHTML) ? 1 : -1;
                }
                ;

                $('#deviceId1 option').sort(NASort).appendTo('#deviceId1');
                $('#deviceId1').prepend($('<option>', {value: ''}).text('Select Asset'));
                $("#deviceId1").val($("#deviceId1 option:first").val());
            });

            function drawChart()
            {

                if ($("#dateTimePicker-history-start-date").val() != null && $("#dateTimePicker-history-start-date").val() != ""
                        && $("#dateTimePicker-history-end-date").val() != null && $("#dateTimePicker-history-end-date").val() != ""
                        && $("#deviceId1").val() != "")
                {

                    var aoData = [];

                    aoData.push({"name": "type", "value": "system"});
                    aoData.push({"name": "action", "value": "behavioural"});
                    aoData.push({"name": "fromDate", "value": $("#dateTimePicker-history-start-date").val()});
                    aoData.push({"name": "toDate", "value": $("#dateTimePicker-history-end-date").val()});
                    aoData.push({"name": "driverId", "value": $("#driverId1").val()});
                    aoData.push({"name": "assetId", "value": $("#deviceId1").val()});

                    $.getJSON("BehaviouralReportController", aoData, function(json)
                    {
                        if (json !== null)
                        {
                            if (json.scoreData[0] === "")
                            {
                                alert('There is No Data For the Selected Vehicle.');
                            }
                            else
                            {
                                var jsonScore = json.scoreData;
                                populateColor(jsonScore, Math.round(json.averageScore * 10) / 10);
                                populateScore(jsonScore);
                                drawNewGraph();
                                drawMultiGraph(json.manoeuvresCount);
                                drawPie(json.scorePercentages);

                                $("#scoreTitle").html("Score: " + Math.round(json.averageScore * 10) / 10);
                                $("#trips").html("Number of Trips: " + json.trips);
                                $("#highest").html("Highest Score: " + Math.round(json.highestScore * 10) / 10);
                                $("#lowest").html("Lowest Score: " + Math.round(json.lowestScore * 10) / 10);
                                $("#scoreSummaryTitle").html("Score Summary");
                                $("#manouvreTitle").html("Manoeuvre Summary");
                                $("#pieTitle").html("Score Determination Components");
                                $("#braking").html(Math.round(json.scorePercentages[0].y * 10) / 10 + "%");
                                $("#speeding").html(Math.round(json.scorePercentages[1].y * 10) / 10 + "%");
                                $("#turning").html(Math.round(json.scorePercentages[2].y * 10) / 10 + "%");
                                $("#turningAcc").html(Math.round(json.scorePercentages[3].y * 10) / 10 + "%");
                                $("#turningDec").html(Math.round(json.scorePercentages[4].y * 10) / 10 + "%");
                                $("#wideTurning").html(Math.round(json.scorePercentages[5].y * 10) / 10 + "%");
                                $("#wideTurningAcc").html(Math.round(json.scorePercentages[6].y * 10) / 10 + "%");
                                $("#wideTurningDec").html(Math.round(json.scorePercentages[7].y * 10) / 10 + "%");
                                $("#acceleration").html(Math.round(json.scorePercentages[8].y * 10) / 10 + "%");
                                $("#overTaking").html(Math.round(json.scorePercentages[9].y * 10) / 10 + "%");
                                $("#laneChange").html(Math.round(json.scorePercentages[10].y * 10) / 10 + "%");
                                $("#speedBump").html(Math.round(json.scorePercentages[11].y * 10) / 10 + "%");

                            }
                        }
                        else
                        {

                        }
                    });
                }
            }

            var chart;
            var jsonScoreChart;
            var scorePercentages;
            var pieWidth = 400;
            var pieHeight = 400;
            var jsonScoreColor = [];
            var jsonManoeuvreColor = ['#009900', '#999900', '#990000'];

            function dispose()
            {

                $("#dateTimePicker-history-start-date").AnyTime_noPicker();

                $("#dateTimePicker-history-end-date").AnyTime_noPicker();

            }

            function populateScore(jsonScore)
            {
                jsonScoreChart = [
                    {
                        key: "JSON Scores",
                        values: jsonScore
                    }
                ];
            }

            function populateColor(jsonScore, jsonScoreAverage)
            {
                var i;
                for (i = 0; i < jsonScore.length; i++)
                {
                    if (jsonScore[i].value >= jsonScoreAverage)
                    {
                        jsonScoreColor[i] = '#00bfff';
                    }
                    else
                    {
                        jsonScoreColor[i] = '#87ceeb';
                    }
                }
            }

            function drawNewGraph()
            {
                nv.addGraph(function()
                {
                    var chart = nv.models.discreteBarChart()
                            .x(function(d)
                            {
                                return d.label
                            })
                            .y(function(d)
                            {
                                return d.value
                            })
                            .staggerLabels(true)
                            //.staggerLabels(historicalBarChart[0].values.length > 8)
                            .showValues(true)
                            .duration(250)
                            .margin({bottom: 100, left: 70})
                            .rotateLabels(-45)
                            .color(jsonScoreColor)
                            .forceY([0, 100])
                            ;

                    chart.yAxis
                            .axisLabel("Score");

                    d3.select('#chart1 svg')
                            .datum(jsonScoreChart)
                            .call(chart);

                    nv.utils.windowResize(chart.update);
                    return chart;
                });
            }


            function drawMultiGraph(data)
            {
                nv.addGraph(function()
                {
                    chart = nv.models.multiBarChart()
//                .barColor(d3.scale.category20().range())
                            .duration(300)
                            .margin({bottom: 100, left: 70})
                            .rotateLabels(-45)
                            .groupSpacing(0.1)
                            .color(jsonManoeuvreColor)
                            .reduceXTicks(false)
                            .stacked(false)
                            .showControls(false)
                            ;

                    chart.reduceXTicks(false).staggerLabels(true);

                    chart.yAxis
                            .axisLabel("Frequency")
                            .axisLabelDistance(-5)
                            .tickFormat(d3.format('0f'))
                            .ticks(5)
                            ;

                    chart.dispatch.on('renderEnd', function()
                    {
                        nv.log('Render Complete');
                    });

                    d3.select('#chart2 svg')
                            .datum(data)
                            .call(chart);

                    nv.utils.windowResize(chart.update);

                    chart.dispatch.on('stateChange', function(e)
                    {
                        nv.log('New State:', JSON.stringify(e));
                    });
                    chart.state.dispatch.on('change', function(state)
                    {
                        nv.log('state', JSON.stringify(state));
                    });

                    return chart;
                });
            }

            function drawPie(data)
            {
                nv.addGraph(function()
                {
                    var chart = nv.models.pie()
                            .x(function(d)
                            {
                                return d.key;
                            })
                            .y(function(d)
                            {
                                return d.y;
                            })
                            .margin({bottom: 150, left: 70, top: 30})
                            .width(pieWidth)
                            .height(pieHeight)
                            .showLabels(true)
                            .labelsOutside(true)
                            ;

                    d3.select("#chart3 svg")
                            .datum([data])
                            .transition().duration(1200)
                            .attr('width', pieWidth)
                            .attr('height', pieHeight)
                            .call(chart);

                    return chart;
                });

                $("#scorePercentagePieChart").show();
            }


            function drawScoreChart(data, seriesData)
            {
                $.jqplot('scorechart', data, {
                    series: seriesData,
                    title: '<%=userProperties.getLanguage("score")%>',
                    /*legend:{show:true}, */
                    axes:
                    {
                        xaxis:
                        {
                            renderer: $.jqplot.DateAxisRenderer,
                            rendererOptions: {tickRenderer: $.jqplot.CanvasAxisTickRenderer},
                            tickOptions:
                            {
                                formatString: '%d/%m/%y %H:%M:%S',
                                fontSize: '10pt',
                                fontFamily: 'Tahoma',
                                angle: -30,
                                autoscale: true
                            },
                            label: '<%=userProperties.getLanguage("date")%>',
                            labelRenderer: $.jqplot.CanvasAxisLabelRenderer
                        },
                        yaxis:
                        {
                            min: 0,
                            max: 100,
                            tickInterval: 20,
                            tickOptions: {formatString: '%.1f'},
                            label: '<%=userProperties.getLanguage("score")%>',
                            labelRenderer: $.jqplot.CanvasAxisLabelRenderer
                        }
                    },
                    highlighter:
                    {
                        show: true,
                        sizeAdjust: 1.0
                    },
                    cursor:
                    {
                        showTooltip: false
                    }
                });
            }

            function printPNG()
            {
                saveSvgAsPng(document.getElementById("piesvg"), "blah", 3);
            }

            function resetDate()
            {

                var resetStartDate = '<%=inputStartDate%>';
                var resetEndDate = '<%=inputEndDate%>';
                $("#dateTimePicker-history-start-date").val(resetStartDate);
                $("#dateTimePicker-history-end-date").val(resetEndDate);

            }

        </script>
        <title>V3Nity</title>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("behaviouralReport")%></h1>
        </div>
        <input type="hidden" name="reload" id="reload">
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="getChart" name="getChart" onclick="drawChart()"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset" value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>
        </div>
        <br/>
        <div class="grid">
            <div class="row cells6">
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("dateRange")%></h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-start-date" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="${inputStartDate}" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <span> - </span>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-end-date" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="${inputEndDate}" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <br/>
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("asset")%></h4>
                    <div class="input-control select">
                        <select id="deviceId1" name="deviceId1">
                            <% assetDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                    <br/>
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("driver")%></h4>
                    <div class="input-control select">
                        <select id="driverId1" name="driverId1">
                            <option value = "">Select Staff</option>
                            <% driverDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                </div>
                <div class="cell">
                    <h2 id="scoreTitle" class="text-light align-left"></h2>
                    <h4 id="trips" class="text-light align-left"></h4>
                    <h4 id="lowest" class="text-light align-left"></h4>
                    <h4 id="highest" class="text-light align-left"></h4>
                </div>
                <div class="cell colspan4">
                    <h2 id="scoreSummaryTitle" class="text-light align-left"></h2>
                    <div id="chart1" class='with-3d-shadow with-transitions'>
                        <svg></svg>
                    </div>
                </div>
            </div>
            <div class="row cells2">
                <div class="cell">
                    <h2 id="manouvreTitle" class="text-light align-left"></h2>
                    <div id="chart2" class='with-3d-shadow with-transitions'>
                        <svg></svg>
                    </div>
                </div>
                <div class="cell">
                    <h2 id="pieTitle" class="text-light align-left"></h2>
                    <div id="chart3" class='with-3d-shadow with-transitions'>
                        <svg id="piesvg"></svg>
                    </div>
                    <table id = "scorePercentagePieChart">
                        <tr>
                            <td>
                                Braking:
                            </td>
                            <td>
                                <div id="braking"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Speeding:
                            </td>
                            <td>
                                <div id="speeding"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Turning:
                            </td>
                            <td>
                                <div id="turning"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Turning (Acc):
                            </td>
                            <td>
                                <div id="turningAcc"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Turning (Dec):
                            </td>
                            <td>
                                <div id="turningDec"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Wide Turning:
                            </td>
                            <td>
                                <div id="wideTurning"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Wide Turning (Acc):
                            </td>
                            <td>
                                <div id="wideTurningAcc"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Wide Turning (Dec):
                            </td>
                            <td>
                                <div id="wideTurningDec"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Acceleration:
                            </td>
                            <td>
                                <div id="acceleration"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Over Taking:
                            </td>
                            <td>
                                <div id="overTaking"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Lane Change:
                            </td>
                            <td>
                                <div id="laneChange"></div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Speed Bump:
                            </td>
                            <td>
                                <div id="speedBump"></div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>
