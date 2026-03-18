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

    int resourceId = (int) request.getAttribute("resource");
    
    String reportDisplay = (String) request.getAttribute("reportDisplay");
    
    String dateFilterDisplay = (String) request.getAttribute("dateFilterDisplay");
    
    AssetTreeView assetTreeView = new AssetTreeView(userProperties);
  
    assetTreeView.setIdentifier("filter-asset");

    assetTreeView.loadData(userProperties);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <style>
            .cell.total-box {
                height: 100px;
                text-align: center;
            }
            
            .cell.total-box h1 {
                font-size: 42px;
            }
            
            .treeview-control {
                padding: 0px;
                height: 320px;
            }
        </style>
        <script type="text/javascript">

            var chart;
            var pickerFormat;
            var ids = '';
            var isTopReport = false;
            var isAirQualityReport = false;
            
            var language = {
                lastUpdated: '<%=userProperties.getLanguage("ddLastUpdated")%>',
                peopleCount: '<%=userProperties.getLanguage("peopleCount")%>',
                hour: '<%=userProperties.getLanguage("hour")%>',
                day: '<%=userProperties.getLanguage("day")%>',
                month: '<%=userProperties.getLanguage("month")%>'
            };

            $(document).ready(function()
            {
                
            <%
                if (resourceId == Resource.HOURLY_USAGE_BY_DATE)
                {
            %>
                chart = new HourlyUsageChart('chart-container', {title: '', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                chart.create();
                
                pickerFormat = "%d/%m/%Y";
            <%
                }
                else if (resourceId == Resource.DAILY_USAGE_BY_MONTH)
                {
            %>
                chart = new DailyUsageChart('chart-container', {title: '', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                chart.create();
                
                pickerFormat = "%b %Y";
            <%
                }
                else if (resourceId == Resource.MONTHLY_USAGE_BY_YEAR)
                {
            %>
                chart = new MonthlyUsageChart('chart-container', {title: '', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                chart.create();
                
                pickerFormat = "%Y";
            <%
                }
                else if (resourceId == Resource.TOP_HIGHEST_USAGE_BY_MONTH)
                {
            %>
                chart = new TopHighestUsageChart('chart-container', {title: '', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                chart.create();
                
                pickerFormat = "%b %Y";
                
                isTopReport = true;
            <%
                }
                else if (resourceId == Resource.TOP_LOWEST_USAGE_BY_MONTH)
                {
            %>
                chart = new TopLowestUsageChart('chart-container', {title: '', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                chart.create();
                
                pickerFormat = "%b %Y";
                
                isTopReport = true;
            <%
                }
                else if (resourceId == Resource.AIR_QUALITY_LEVEL_BY_PERCENTAGE)
                {
            %>
                chart = new AirQualityLevelByPercentage('chart-container', {title: '', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                chart.create();
                
                pickerFormat = "%b %Y";
                
                isAirQualityReport = true;
            <%
                }
            %>
            
            $("#date-time-picker").AnyTime_picker({format: pickerFormat});
            
            var converter = new AnyTime.Converter({format: pickerFormat});
            
            $("#date-time-picker").val(converter.format(new Date())).change();
                    
//            filterChart();
            
            });

            function dispose()
            {
                if (chart !== undefined)
                {
                    chart.dispose();
                    
                    chart = undefined;
                }
                
                $("#date-time-picker").AnyTime_noPicker();
            }
            
            function filterChart()
            {
                if (chart !== undefined)
                {
                    if(!isTopReport)
                    {
                        if(ids.length === 0)
                        {
                            dialog('Error', 'Please Select Asset', 'alert');

                            return;
                        }

                        var idArr = ids.split(',');

                        if(idArr.length > 1 && !isAirQualityReport)
                        {
                            dialog('Error', 'Please Select One Asset at a Time', 'alert');

                            return;
                        }
                        
                        chart.setFilter(ids, $('#date-time-picker').val());
                    }
                    else
                    {
                        if($('#select-top').val() === '0')
                        {
                            dialog('Error', 'Please Select the Top Number', 'alert');
                            
                            return;
                        }
                        
                        chart.setFilter($('#select-top').val(), $('#date-time-picker').val());
                    }
                    
                    chart.refresh();
                }
            }
            
            function onTreeviewCheckboxClicked(treeview, parent, children, checked)
            {
                if (treeview === 'tree-view-filter-asset')
                {
                    ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');
                }
            }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage(reportDisplay)%></h1>
        </div>
        
        <div class="toolbar" style="margin: 16px 0">
            <div class="toolbar-section">
                <button class="toolbar-button" onclick="filterChart()" id="searchFleet"><span class="mif-search"></span></button>
            </div>
        </div>
        <h3 class="text-light">Search By</h3>
        <div class="grid" >
            <div class="row cells4">
                <%
                    if(resourceId != Resource.TOP_HIGHEST_USAGE_BY_MONTH && resourceId != Resource.TOP_LOWEST_USAGE_BY_MONTH)
                    {
                %>
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("location")%></h4>
                    <div id="chartFrame" class="treeview-control">
                        <%
                            assetTreeView.outputHTML(out, userProperties);
                        %>
                    </div>
                </div>
                <%
                    }
                    else
                    {
                %>
                <div class="cell">
                    <h4 class="text-light align-left">Top</h4>
                    <div class="input-control select full-size">
                        <select id="select-top">
                            <option value="0">Select Top</option>
                            <option value="3">3</option>
                            <option value="5">5</option>
                            <option value="10">10</option>
                        </select>
                    </div>
                </div>
                <%
                    }
                %>
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage(dateFilterDisplay)%></h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="date-time-picker" type="text" placeholder="<%=userProperties.getLanguage("select")%> <%=userProperties.getLanguage("dateFilterDisplay")%>" autocomplete="on">
                        <!--<button class="button helper-button clear"><span class="mif-cross"></span></button>-->
                    </div>
                </div>
            </div>
        </div>
                                
        <div class="grid" style="max-width: 100%; margin-top: 80px;">
            <div class="cell colspan3">
                <div class="row cells2">
                    <div class="cell">
                        <div id="chart-container" class="dashboard-chart"></div>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </body>
</html>
