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
    boolean accessGpsChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_GPS_STATUS));
    boolean accessSpeedChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_SPEED_SUMMARY));
    boolean accessConnectionChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_CONNECTION_STATUS));
    boolean accessIgnitionChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_IGNITION_STATUS));
    boolean accessGeoFenceOccurenceChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_GEO_FENCE_OCCURENCE));
    boolean accessJobStatusChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_JOB_STATUS));
    boolean accessBinStatusChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_BIN_STATUS));
    boolean accessFillCountMonthlyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FILL_COUNT_MONTHLY));
    boolean accessJobProgressChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_JOB_PROGRESS));
    boolean accessJobScheduleChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_JOB_SCHEDULE));
    boolean accessJobDurationChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_JOB_DURATION));
    boolean accessProductivityTrendChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_PRODUCTIVITY_TREND));

    List<String> statusChartIds = new ArrayList<>();

    if (accessGpsChart)
    {
        statusChartIds.add("gps-chart");
    }

    if (accessSpeedChart)
    {
        statusChartIds.add("speed-chart");
    }

    if (accessConnectionChart)
    {
        statusChartIds.add("connection-chart");
    }

    if (accessIgnitionChart)
    {
        statusChartIds.add("ignition-chart");
    }

    if (accessBinStatusChart)
    {
        statusChartIds.add("bin-status-chart");
    }

    if (accessGeoFenceOccurenceChart)
    {
        // this one is span across all cells...
    }

    if (accessJobStatusChart)
    {
        statusChartIds.add("job-status-chart");
    }

    if (accessFillCountMonthlyChart)
    {
        statusChartIds.add("fill-count-monthly-chart");
    }
    if (accessJobScheduleChart)
    {
        statusChartIds.add("job-schedule-deviation-chart");
    }
    if (accessJobDurationChart)
    {
        statusChartIds.add("job-duration-deviation-chart");
    }
    if (accessProductivityTrendChart)
    {
        statusChartIds.add("productivity-trend-chart");
    }
    if (accessJobProgressChart)
    {
        statusChartIds.add("job-progress-chart");
    }

    // For Cluster Dashboard
    boolean accessClusterLocationGroup = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_CLUSTER_GROUP));
    boolean accessClusterLocationGroupIndividual = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_CLUSTER_GROUP_INDIVIDUAL));
    boolean accessClusterLocationTracking = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_TTC));

    List<String> clusterChartIds = new ArrayList<>();

    if (accessClusterLocationGroup)
    {
        clusterChartIds.add("cluster-location-group-chart");
    }
    if (accessClusterLocationGroupIndividual)
    {
        clusterChartIds.add("cluster-location-group-individual-chart");
    }

    if (accessClusterLocationTracking)
    {
        clusterChartIds.add("cluster-location-chart");
    }

    //For Utilization Dashboard
    boolean accessBrakeUtilizationChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_BRAKE_UTILIZATION));
    boolean accessPTOUtilizationChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_PTO_UTILIZATION));
    boolean accessFuelEfficiencyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FUEL_EFFICIENCY));
    boolean accessBrakeUtilizationMonthlyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_BRAKE_UTILIZATION_MONTHLY));
    boolean accessPTOUtilizationMonthlyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_PTO_UTILIZATION_MONTHLY));
    boolean accessFuelEfficiencyMonthlyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FUEL_EFFICIENCY_MONTHLY));
    boolean accessFillLevelDailyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FILL_LEVEL_DAILY));
    boolean accessFillLevelMonthlyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FILL_LEVEL_MONTHLY));

    List<String> utilizationChartIds = new ArrayList<>();

    if (accessBrakeUtilizationChart)
    {
        utilizationChartIds.add("brake-utilization-chart");
    }

    if (accessPTOUtilizationChart)
    {
        utilizationChartIds.add("pto-utilization-chart");
    }

    if (accessFuelEfficiencyChart)
    {
        utilizationChartIds.add("fuel-efficiency-chart");
    }
    if (accessFillLevelDailyChart)
    {
        utilizationChartIds.add("fill-level-daily-chart");
    }
    if (accessBrakeUtilizationMonthlyChart)
    {
        utilizationChartIds.add("brake-utilization-monthly-chart");
    }

    if (accessPTOUtilizationMonthlyChart)
    {
        utilizationChartIds.add("pto-utilization-monthly-chart");
    }

    if (accessFuelEfficiencyMonthlyChart)
    {
        utilizationChartIds.add("fuel-efficiency-monthly-chart");
    }

    if (accessFillLevelMonthlyChart)
    {
        utilizationChartIds.add("fill-level-monthly-chart");
    }
    //For Driver Safety Dashboard
    boolean accessDriverSafetyChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_DRIVER_SAFETY_SCORECARD));
    boolean accessManoeuvreSummaryChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_MANOEUVRE_SUMMARY));
    boolean accessPTOSafetyViolation = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_PTO_SAFETY_VIOLATION));

    List<String> safetyChartIds = new ArrayList<>();

    if (accessDriverSafetyChart)
    {
        safetyChartIds.add("driver-safety-chart");
    }

    if (accessManoeuvreSummaryChart)
    {
        safetyChartIds.add("manoeuvre-summary-chart");
    }

    if (accessPTOSafetyViolation)
    {
        safetyChartIds.add("pto-safety-violation-chart");
    }

    //For Health Dashboard
    boolean accessEngineTemperatureChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_ENGINE_TEMPERATURE));
    boolean accessEngineWearAndTearChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_ENGINE_WEAR_AND_TEAR));
    boolean accessOverallHealthChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_OVERALL_HEALTH));
    boolean accessBatteryHealthChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_BATTERY_HEALTH));

    List<String> healthChartIds = new ArrayList<>();

    if (accessOverallHealthChart)
    {
        healthChartIds.add("overall-health-chart");
    }

    if (accessEngineTemperatureChart)
    {
        healthChartIds.add("engine-temperature-chart");
    }

    if (accessEngineWearAndTearChart)
    {
        healthChartIds.add("engine-wear-and-tear-chart");
    }
    if (accessBatteryHealthChart)
    {
        healthChartIds.add("battery-health-chart");
    }

    // For telematics analysis
    boolean accessFuelLevelChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FUEL_LEVEL));
    boolean accessFuelConsumptionChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_FUEL_CONSUMPTION));
    boolean accessIdlingTimeLimitChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_IDLING_TIME_LIMIT));
    boolean accessEngineCheckChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_ENGINE_CHECK_DTC));
    boolean accessEngineTempChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_ENGINE_TEMP));
    boolean accessEngineLoadChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_ENGINE_LOAD));
    boolean accessExhaustBrakeChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_EXHAUST_BRAKE));
    boolean accessMileageServiceChart = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_MILEAGE_SERVICE));
    boolean accessEngineAnalytics = userProperties.canAccessView(userProperties.getOperations(Resource.DASHBOARD_ENGINE_ANALYTICS));

    List<String> telematicsChartIds = new ArrayList<>();
    List<String> engineAnalyticsChart = new ArrayList<>();

    if (accessEngineAnalytics)
    {
        engineAnalyticsChart.add("engine-analytics-chart");
    }

    if (accessFuelLevelChart)
    {
        telematicsChartIds.add("fuel-level-chart");
    }
    if (accessFuelConsumptionChart)
    {
        telematicsChartIds.add("fuel-consumption-chart");
    }
    if (accessIdlingTimeLimitChart)
    {
        telematicsChartIds.add("idling-time-limit-chart");
    }
    if (accessEngineCheckChart)
    {
        telematicsChartIds.add("engine-check-chart");
    }
    if (accessEngineTempChart)
    {
        telematicsChartIds.add("engine-temp-chart");
    }
    if (accessEngineLoadChart)
    {
        telematicsChartIds.add("engine-load-chart");
    }
    if (accessExhaustBrakeChart)
    {
        telematicsChartIds.add("exhaust-brake-chart");
    }
    if (accessMileageServiceChart)
    {
        telematicsChartIds.add("mileage-service-chart");
    }

    String attributeHideDashboardFilter = userProperties.getCustomerAttribute("HideDashboardFilter");

    boolean hideDashboardFilter = (attributeHideDashboardFilter != null);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <script type="text/javascript">

            var gpsChart, speedChart, connectionChart, ignitionChart, binStatusChart, geoFenceOccurence, jobStatusChart, fillCountMonthlyChart, jobProgressChart, jobScheduleChart, jobDurationChart, productivityTrendChart;
            var brakeUtilizationChart, brakeUtilizationMonthlyChart, ptoUtilizationChart, ptoUtilizationMonthlyChart, fuelEfficiencyChart, fuelEfficiencyMonthlyChart, fillLevelDailyChart, fillLevelMonthlyChart;
            var driverSafetyChart, manoeuvreSummaryChart, ptoSafetyViolationChart;
            var engineTemperatureChart, engineWearAndTearChart, overallHealthChart, batteryHealthChart;
            var healthCharts = [];
            var fuelLevelChart, fuelConsumptionChart, idlingTimeLimitChart, engineCheckChart, engineTempChart, engineLoadChart, exhaustBrakeChart, mileageServiceChart;
            var clusterLocationTrackingChart, clusterLocationGroup, clusterLocationGroupIndividual;
            var engineAnalytics;
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

            $(document).ready(function()
            {
                //For Status Dashboard
            <%
                if (accessGpsChart)
                {
            %>
                gpsChart = new GPSChart('gps-chart', {title: '<%=userProperties.getLanguage("ddTitleGPS")%>', description: '<%=userProperties.getLanguage("ddDescGPS")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                gpsChart.create();
            <%
                }
            %>
            <%
                if (accessSpeedChart)
                {
            %>
                speedChart = new SpeedSummaryChart('speed-chart', {title: '<%=userProperties.getLanguage("ddTitleSpeed")%>', description: '<%=userProperties.getLanguage("ddDescSpeed")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                speedChart.create();
            <%
                }
            %>
            <%
                if (accessConnectionChart)
                {
            %>
                //connectionChart = new ConnectionStatusChart('connection-chart', {title: '<%=userProperties.getLanguage("ddTitleConnection")%>', description: '<%=userProperties.getLanguage("ddDescConnection")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});
                connectionChart = new OutdatedConnectionSummaryChart('connection-chart', {title: '<%=userProperties.getLanguage("ddTitleConnection")%>', description: '<%=userProperties.getLanguage("ddDescConnection")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                connectionChart.create();
            <%
                }
            %>
            <%
                if (accessIgnitionChart)
                {
            %>
                ignitionChart = new IgnitionStatusChart('ignition-chart', {title: '<%=userProperties.getLanguage("ddTitleIgnition")%>', description: '<%=userProperties.getLanguage("ddDescIgnition")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                ignitionChart.create();
            <%
                }
            %>
            <%
                if (accessBinStatusChart)
                {
            %>
                binStatusChart = new BinStatusChart('bin-status-chart', {title: '<%=userProperties.getLanguage("ddTitleBin")%>', description: '<%=userProperties.getLanguage("ddDescBin")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                binStatusChart.create();
            <%
                }
            %>
            <%
                if (accessGeoFenceOccurenceChart)
                {
            %>
                geoFenceOccurence = new GeoFenceOccurenceChart('geofence-occurence-chart', {title: '<%=userProperties.getLanguage("ddTitleGeoFence")%>', description: '<%=userProperties.getLanguage("ddDescGeoFence")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                geoFenceOccurence.create();

            <%
                }
            %>
            <%
                if (accessJobStatusChart)
                {
            %>
                jobStatusChart = new JobStatusChart('job-status-chart', {title: '<%=userProperties.getLanguage("ddTitleJob")%>', description: '<%=userProperties.getLanguage("ddDescJob")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                jobStatusChart.create();
            <%
                }
            %>
            <%
                if (accessFillCountMonthlyChart)
                {
            %>
                fillCountMonthlyChart = new FillCountMonthlyChart('fill-count-monthly-chart', {title: '<%=userProperties.getLanguage("ddTitleFillCount")%>', description: '<%=userProperties.getLanguage("ddDescFillCount")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                fillCountMonthlyChart.create();
            <%
                }
            %>

                //For Utilization Dashboard
            <%
                if (accessBrakeUtilizationChart)
                {
            %>
                brakeUtilizationChart = new BrakeUtilizationChart('brake-utilization-chart', {title: '<%=userProperties.getLanguage("ddTitleBrake")%>', description: '<%=userProperties.getLanguage("ddDescBrake")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                brakeUtilizationChart.create();
            <%
                }
            %>
            <%
                if (accessBrakeUtilizationMonthlyChart)
                {
            %>
                brakeUtilizationMonthlyChart = new BrakeUtilizationMonthlyChart('brake-utilization-monthly-chart', {title: '<%=userProperties.getLanguage("ddTitleBrakeMth")%>', description: '<%=userProperties.getLanguage("ddDescBrakeMth")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                brakeUtilizationMonthlyChart.create();
            <%
                }
            %>
            <%
                if (accessPTOUtilizationChart)
                {
            %>
                ptoUtilizationChart = new PTOUtilizationChart('pto-utilization-chart', {title: '<%=userProperties.getLanguage("ddTitlePTO")%>', description: '<%=userProperties.getLanguage("ddDescPTO")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                ptoUtilizationChart.create();
            <%
                }
            %>
            <%
                if (accessPTOUtilizationMonthlyChart)
                {
            %>
                ptoUtilizationMonthlyChart = new PTOUtilizationMonthlyChart('pto-utilization-monthly-chart', {title: '<%=userProperties.getLanguage("ddTitlePTOMth")%>', description: '<%=userProperties.getLanguage("ddDescPTOMth")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                ptoUtilizationMonthlyChart.create();
            <%
                }
            %>
            <%
                if (accessFuelEfficiencyChart)
                {
            %>
                fuelEfficiencyChart = new FuelEfficiencyChart('fuel-efficiency-chart', {title: '<%=userProperties.getLanguage("ddTitleFuel")%>', description: '<%=userProperties.getLanguage("ddDescFuel")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                fuelEfficiencyChart.create();
            <%
                }
            %>
            <%
                if (accessFuelEfficiencyMonthlyChart)
                {
            %>
                fuelEfficiencyMonthlyChart = new FuelEfficiencyMonthlyChart('fuel-efficiency-monthly-chart', {title: '<%=userProperties.getLanguage("ddTitleFuelMonthly")%>', description: '<%=userProperties.getLanguage("ddDescFuelMonthly")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                fuelEfficiencyMonthlyChart.create();
            <%
                }
            %>
            <%
                if (accessFillLevelDailyChart)
                {
            %>
                fillLevelDailyChart = new FillLevelDailyChart('fill-level-daily-chart', {title: '<%=userProperties.getLanguage("ddTitleFillDailys")%>', description: '<%=userProperties.getLanguage("ddDescFillDailys")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                fillLevelDailyChart.create();
            <%
                }
            %>
            <%
                if (accessFillLevelMonthlyChart)
                {
            %>
                fillLevelMonthlyChart = new FillLevelMonthlyChart('fill-level-monthly-chart', {title: '<%=userProperties.getLanguage("ddTitleFillMonthly")%>', description: '<%=userProperties.getLanguage("ddDescFillMonthly")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                fillLevelMonthlyChart.create();
            <%
                }
            %>
            <%
                if (accessJobProgressChart)
                {
            %>
                jobProgressChart = new JobProgressChart('job-progress-chart', {title: '<%=userProperties.getLanguage("ddTitleJobProgress")%>', description: '<%=userProperties.getLanguage("ddDescJobProgress")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                jobProgressChart.create();
            <%
                }
            %>
            <%
                if (accessJobScheduleChart)
                {
            %>
                jobScheduleChart = new JobScheduleChart('job-schedule-deviation-chart', {title: '<%=userProperties.getLanguage("ddTitleJobSchedule")%>', description: '<%=userProperties.getLanguage("ddDescJobSchedule")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                jobScheduleChart.create();
            <%
                }
            %>
            <%
                if (accessJobDurationChart)
                {
            %>
                jobDurationChart = new JobDurationChart('job-duration-deviation-chart', {title: '<%=userProperties.getLanguage("ddTitleJobDuration")%>', description: '<%=userProperties.getLanguage("ddDescJobDuration")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                jobDurationChart.create();
            <%
                }
            %>
            <%
                if (accessProductivityTrendChart)
                {
            %>
                productivityTrendChart = new ProductivityTrendChart('productivity-trend-chart', {title: '<%=userProperties.getLanguage("ddTitleProductivityTrend")%>', description: '<%=userProperties.getLanguage("ddDescProductivityTrend")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                productivityTrendChart.create();
            <%
                }
            %>
                //For Driver Safety Dashboard
            <%
                if (accessDriverSafetyChart)
                {
            %>
                driverSafetyChart = new DriverSafetyChart('driver-safety-chart', {title: '<%=userProperties.getLanguage("ddTitleDriver")%>', description: '<%=userProperties.getLanguage("ddDescDriver")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                driverSafetyChart.create();
            <%
                }
            %>
            <%
                if (accessManoeuvreSummaryChart)
                {
            %>
                manoeuvreSummaryChart = new ManoeuvreSummaryChart('manoeuvre-summary-chart', {title: '<%=userProperties.getLanguage("ddTitleManoeuvre")%>', description: '<%=userProperties.getLanguage("ddDescManoeuvre")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                manoeuvreSummaryChart.create();
            <%
                }

                if (accessPTOSafetyViolation)
                {
            %>
                ptoSafetyViolationChart = new PTOSafetyViolationChart('pto-safety-violation-chart', {title: '<%=userProperties.getLanguage("ddTitlePTOSafetyViolation")%>', description: '<%=userProperties.getLanguage("ddDescPTOSafetyViolation")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                ptoSafetyViolationChart.create();
            <%
                }
            %>
                //For Health Dashboard
            <%
                if (accessEngineTemperatureChart)
                {
            %>
                engineTemperatureChart = new EngineTemperatureChart('engine-temperature-chart', {title: '<%=userProperties.getLanguage("ddTitleEngineTemperature")%>', description: '<%=userProperties.getLanguage("ddDescEngineTemperature")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0, update: updateHealthChart});

                engineTemperatureChart.create();
            <%
                }
            %>
            <%
                if (accessEngineWearAndTearChart)
                {
            %>
                engineWearAndTearChart = new EngineWearAndTearChart('engine-wear-and-tear-chart', {title: '<%=userProperties.getLanguage("ddTitleEngineWearAndTear")%>', description: '<%=userProperties.getLanguage("ddDescEngineWearAndTear")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0, update: updateHealthChart});

                engineWearAndTearChart.create();
            <%
                }
            %>
            <%
                if (accessOverallHealthChart)
                {
            %>
                overallHealthChart = new OverallHealthChart('overall-health-chart', {title: '<%=userProperties.getLanguage("ddTitleOverallHealth")%>', description: '<%=userProperties.getLanguage("ddDescOverallHealth")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                overallHealthChart.create();
            <%
                }
            %>
            <%
                if (accessBatteryHealthChart)
                {
            %>
                batteryHealthChart = new BatteryHealthChart('battery-health-chart', {title: '<%=userProperties.getLanguage("ddTitleBatteryHealth")%>', description: '<%=userProperties.getLanguage("ddDescBatteryHealth")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, interval: 0});

                batteryHealthChart.create();
            <%
                }
            %>
            <%
                if (accessEngineAnalytics)
                {
            %>
                engineAnalytics = new EngineAnalytics('engine-analytics-chart', {title: 'Vehicle Health', description: '', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS', interval: 180000});

                engineAnalytics.create();

                setTimeout(function()
                {
                    getAssetTree()
                }, 2000);
                function getAssetTree()
                {
                    var ids = getAllTreeId('tree-view-filter-asset', 'filter-asset-id');
                    if (ids == "")
                    {
                        setTimeout(function()
                        {
                            getAssetTree()
                        }, 2000);
                    }
                    else
                    {
                        if (engineAnalytics !== undefined)
                        {
                            engineAnalytics.setFilter(ids);

                            engineAnalytics.refresh();
                        }
                    }
                }

            <%
                }
            %>


            <%
                if (accessFuelLevelChart)
                {
            %>
                fuelLevelChart = new FuelLevelChart('fuel-level-chart', {title: '<%=userProperties.getLanguage("ddFuelLevel")%>', description: '<%=userProperties.getLanguage("ddFuelLevelDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                fuelLevelChart.createWithoutCanvas();
            <%
                }
            %>

            <%
                if (accessFuelConsumptionChart)
                {
            %>
                fuelConsumptionChart = new FuelConsumptionChart('fuel-consumption-chart', {title: '<%=userProperties.getLanguage("ddFuelConsumption")%>', description: '<%=userProperties.getLanguage("ddFuelConsumptionDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                fuelConsumptionChart.createWithoutCanvas();
            <%
                }
            %>
            <%
                if (accessIdlingTimeLimitChart)
                {
            %>
                idlingTimeLimitChart = new IdlingTimeLimitChart('idling-time-limit-chart', {title: '<%=userProperties.getLanguage("ddIdlingTimeLimit")%>', description: '<%=userProperties.getLanguage("ddIdlingTimeLimitDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                idlingTimeLimitChart.createWithoutCanvas();
            <%
                }
            %>

            <%
                if (accessEngineCheckChart)
                {
            %>
                engineCheckChart = new EngineCheckChart('engine-check-chart', {title: '<%=userProperties.getLanguage("ddEngineCheck")%>', description: '<%=userProperties.getLanguage("ddEngineCheckDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                engineCheckChart.createWithoutCanvas();
            <%
                }
            %>

            <%
                if (accessEngineTempChart)
                {
            %>
                engineTempChart = new EngineTempChart('engine-temp-chart', {title: '<%=userProperties.getLanguage("ddEngineTemp")%>', description: '<%=userProperties.getLanguage("ddEngineTempDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                engineTempChart.createWithoutCanvas();
            <%
                }
            %>

            <%
                if (accessEngineLoadChart)
                {
            %>
                engineLoadChart = new EngineLoadChart('engine-load-chart', {title: '<%=userProperties.getLanguage("ddEngineLoad")%>', description: '<%=userProperties.getLanguage("ddEngineLoadDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                engineLoadChart.createWithoutCanvas();
            <%
                }
            %>


            <%
                if (accessExhaustBrakeChart)
                {
            %>
                exhaustBrakeChart = new ExhaustBrakeChart('exhaust-brake-chart', {title: '<%=userProperties.getLanguage("ddExhaustBrake")%>', description: '<%=userProperties.getLanguage("ddExhaustBrakeDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                exhaustBrakeChart.createWithoutCanvas();
            <%
                }
            %>

            <%
                if (accessMileageServiceChart)
                {
            %>
                mileageServiceChart = new MileageServiceChart('mileage-service-chart', {title: '<%=userProperties.getLanguage("ddMileageService")%>', description: '<%=userProperties.getLanguage("ddMileageServiceDesc")%>', timezone: <%=userProperties.getDouble("time_zone")%>, language: language, filterDays: 'LAST 7 DAYS'});

                mileageServiceChart.createWithoutCanvas();
            <%
                }
            %>


            <%
                if (accessClusterLocationTracking)
                {
            %>
                clusterLocationTrackingChart = new ClusterLocationTrackingChart('cluster-location-chart', {title: 'Daily Cluster Progress', description: 'Show the cluster completion progress', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                clusterLocationTrackingChart.create();
            <%
                }
            %>


            <%
                if (accessClusterLocationGroup)
                {
            %>
                clusterLocationGroup = new ClusterGroupProgress('cluster-location-group-chart', {title: 'Daily Progress by Group', description: 'Show the cluster completion progress by group', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                clusterLocationGroup.create();
            <%
                }
            %>

            <%
                if (accessClusterLocationGroupIndividual)
                {
            %>
                clusterLocationGroupIndividual = new ClusterGroupIndividualProgress('cluster-location-group-individual-chart', {title: 'Daily Progress by Individual Group', description: 'Show the cluster completion progress by individual group', timezone: <%=userProperties.getDouble("time_zone")%>, language: language});

                clusterLocationGroupIndividual.create();
            <%
                }
            %>

            <%
                if (hideDashboardFilter)
                {
                    /*
                     * if filtering option is hidden, then we will auto select one asset id to refresh the chart...
                     */
            %>
                $('#treeview-panel').hide();

                var id = $("li[data-name='filter-asset']").attr('data-filter-asset-id');

                filterChart(id);
            <%
                }
            %>


            });

            function dispose()
            {

                //For Status Dashboard
                if (gpsChart !== undefined)
                {
                    gpsChart.dispose();
                    gpsChart = undefined;
                }

                if (speedChart !== undefined)
                {
                    speedChart.dispose();
                    speedChart = undefined;
                }

                if (connectionChart !== undefined)
                {
                    connectionChart.dispose();
                    connectionChart = undefined;
                }

                if (ignitionChart !== undefined)
                {
                    ignitionChart.dispose();
                    ignitionChart = undefined;
                }

                if (binStatusChart !== undefined)
                {
                    binStatusChart.dispose();
                    binStatusChart = undefined;
                }

                if (geoFenceOccurence !== undefined)
                {
                    geoFenceOccurence.dispose();
                    geoFenceOccurence = undefined;
                }

                if (jobStatusChart !== undefined)
                {
                    jobStatusChart.dispose();
                    jobStatusChart = undefined;
                }
                if (fillCountMonthlyChart !== undefined)
                {
                    fillCountMonthlyChart.dispose();
                    fillCountMonthlyChart = undefined;
                }
                if (jobProgressChart !== undefined)
                {
                    jobProgressChart.dispose();
                    jobProgressChart = undefined;
                }
                if (jobScheduleChart !== undefined)
                {
                    jobScheduleChart.dispose();
                    jobScheduleChart = undefined;
                }
                if (jobDurationChart !== undefined)
                {
                    jobDurationChart.dispose();
                    jobDurationChart = undefined;
                }
                if (productivityTrendChart !== undefined)
                {
                    productivityTrendChart.dispose();
                    productivityTrendChart = undefined;
                }
                //For Utilization Dashboard
                if (brakeUtilizationChart !== undefined)
                {
                    brakeUtilizationChart.dispose();
                    brakeUtilizationChart = undefined;
                }

                if (brakeUtilizationMonthlyChart !== undefined)
                {
                    brakeUtilizationMonthlyChart.dispose();
                    brakeUtilizationMonthlyChart = undefined;
                }

                if (ptoUtilizationChart !== undefined)
                {
                    ptoUtilizationChart.dispose();
                    ptoUtilizationChart = undefined;
                }

                if (ptoUtilizationMonthlyChart !== undefined)
                {
                    ptoUtilizationMonthlyChart.dispose();
                    ptoUtilizationMonthlyChart = undefined;
                }

                if (fuelEfficiencyChart !== undefined)
                {
                    fuelEfficiencyChart.dispose();
                    fuelEfficiencyChart = undefined;
                }

                if (fuelEfficiencyMonthlyChart !== undefined)
                {
                    fuelEfficiencyMonthlyChart.dispose();
                    fuelEfficiencyMonthlyChart = undefined;
                }
                if (fillLevelDailyChart !== undefined)
                {
                    fillLevelDailyChart.dispose();
                    fillLevelDailyChart = undefined;
                }
                if (fillLevelMonthlyChart !== undefined)
                {
                    fillLevelMonthlyChart.dispose();
                    fillLevelMonthlyChart = undefined;
                }
                //For Driver Safety Dashboard
                if (driverSafetyChart !== undefined)
                {
                    driverSafetyChart.dispose();
                    driverSafetyChart = undefined;
                }

                if (manoeuvreSummaryChart !== undefined)
                {
                    manoeuvreSummaryChart.dispose();
                    manoeuvreSummaryChart = undefined;
                }

                if (ptoSafetyViolationChart !== undefined)
                {
                    ptoSafetyViolationChart.dispose();
                    ptoSafetyViolationChart = undefined;
                }

                //For Health Dashboard
                if (engineTemperatureChart !== undefined)
                {
                    engineTemperatureChart.dispose();
                    engineTemperatureChart = undefined;
                }

                if (engineWearAndTearChart !== undefined)
                {
                    engineWearAndTearChart.dispose();
                    engineWearAndTearChart = undefined;
                }

                if (overallHealthChart !== undefined)
                {
                    overallHealthChart.dispose();
                    overallHealthChart = undefined;
                }
                if (batteryHealthChart !== undefined)
                {
                    batteryHealthChart.dispose();
                    batteryHealthChart = undefined;
                }

                if (fuelLevelChart !== undefined)
                {
                    fuelLevelChart.dispose();
                    fuelLevelChart = undefined;
                }
                if (fuelConsumptionChart !== undefined)
                {
                    fuelConsumptionChart.dispose();
                    fuelConsumptionChart = undefined;
                }

                if (idlingTimeLimitChart !== undefined)
                {
                    idlingTimeLimitChart.dispose();
                    idlingTimeLimitChart = undefined;
                }

                if (engineCheckChart !== undefined)
                {
                    engineCheckChart.dispose();
                    engineCheckChart = undefined;
                }

                if (engineTempChart !== undefined)
                {
                    engineTempChart.dispose();
                    engineTempChart = undefined;
                }

                if (engineLoadChart !== undefined)
                {
                    engineLoadChart.dispose();
                    engineLoadChart = undefined;
                }

                if (exhaustBrakeChart !== undefined)
                {
                    exhaustBrakeChart.dispose();
                    exhaustBrakeChart = undefined;
                }
                if (mileageServiceChart !== undefined)
                {
                    mileageServiceChart.dispose();
                    mileageServiceChart = undefined;
                }

                /*  Start of TTC Wifi Dashboard               */
                if (clusterLocationTrackingChart !== undefined)
                {
                    clusterLocationTrackingChart.dispose();
                    clusterLocationTrackingChart = undefined
                }
                if (clusterLocationGroup !== undefined)
                {
                    clusterLocationGroup.dispose();
                    clusterLocationGroup = undefined;
                }

                if (clusterLocationGroupIndividual !== undefined)
                {
                    clusterLocationGroupIndividual.dispose();
                    clusterLocationGroupIndividual = undefined;
                }
                /* End of TTC Wifi Dashboard */


                if (engineAnalytics !== undefined)
                {
                    engineAnalytics.dispose();
                    engineAnalytics = undefined;
                }
            }
            
            function filterChart(ids)
            {
                //For Status Dashboard
                if (connectionChart !== undefined)
                {
                    connectionChart.setFilter(ids);

                    connectionChart.refresh();
                }

                if (gpsChart !== undefined)
                {
                    gpsChart.setFilter(ids);

                    gpsChart.refresh();
                }

                if (speedChart !== undefined)
                {
                    speedChart.setFilter(ids);

                    speedChart.refresh();
                }

                if (ignitionChart !== undefined)
                {
                    ignitionChart.setFilter(ids);

                    ignitionChart.refresh();
                }

                if (binStatusChart !== undefined)
                {
                    binStatusChart.setFilter(ids);

                    binStatusChart.refresh();
                }

                if (geoFenceOccurence !== undefined)
                {
                    geoFenceOccurence.setFilter(ids);

                    geoFenceOccurence.refresh();
                }
                if (fillCountMonthlyChart !== undefined)
                {
                    fillCountMonthlyChart.setFilter(ids);

                    fillCountMonthlyChart.refresh();
                }
                if (jobProgressChart !== undefined)
                {
                    jobProgressChart.setFilter(ids);

                    jobProgressChart.refresh();
                }
                if (jobScheduleChart !== undefined)
                {
                    jobScheduleChart.setFilter(ids);

                    jobScheduleChart.refresh();
                }
                if (jobDurationChart !== undefined)
                {
                    jobDurationChart.setFilter(ids);

                    jobDurationChart.refresh();
                }
                if (productivityTrendChart !== undefined)
                {
                    productivityTrendChart.setFilter(ids);

                    productivityTrendChart.refresh();
                }
                //For Utilization Dashboard
                if (brakeUtilizationChart !== undefined)
                {
                    brakeUtilizationChart.setFilter(ids);

                    brakeUtilizationChart.refresh();
                }

                if (brakeUtilizationMonthlyChart !== undefined)
                {
                    brakeUtilizationMonthlyChart.setFilter(ids);

                    brakeUtilizationMonthlyChart.refresh();
                }

                if (ptoUtilizationChart !== undefined)
                {
                    ptoUtilizationChart.setFilter(ids);

                    ptoUtilizationChart.refresh();
                }

                if (ptoUtilizationMonthlyChart !== undefined)
                {
                    ptoUtilizationMonthlyChart.setFilter(ids);

                    ptoUtilizationMonthlyChart.refresh();
                }

                if (fuelEfficiencyChart !== undefined)
                {
                    fuelEfficiencyChart.setFilter(ids);

                    fuelEfficiencyChart.refresh();
                }

                if (fuelEfficiencyMonthlyChart !== undefined)
                {
                    fuelEfficiencyMonthlyChart.setFilter(ids);

                    fuelEfficiencyMonthlyChart.refresh();
                }

                if (fillLevelDailyChart !== undefined)
                {
                    fillLevelDailyChart.setFilter(ids);

                    fillLevelDailyChart.refresh();
                }
                if (fillLevelMonthlyChart !== undefined)
                {
                    fillLevelMonthlyChart.setFilter(ids);

                    fillLevelMonthlyChart.refresh();
                }
                //For Driver Safety Dashboard
                if (driverSafetyChart !== undefined)
                {
                    driverSafetyChart.setFilter(ids);

                    driverSafetyChart.refresh();
                }

                if (manoeuvreSummaryChart !== undefined)
                {
                    manoeuvreSummaryChart.setFilter(ids);

                    manoeuvreSummaryChart.refresh();
                }

                if (ptoSafetyViolationChart !== undefined)
                {
                    ptoSafetyViolationChart.setFilter(ids);

                    ptoSafetyViolationChart.refresh();
                }

                if (jobStatusChart !== undefined)
                {
                    jobStatusChart.setFilter(ids);

                    jobStatusChart.refresh();
                }

                //For Health Dashboard
                if (engineTemperatureChart !== undefined)
                {
                    engineTemperatureChart.setFilter(ids);

                    engineTemperatureChart.refresh();
                }

                if (batteryHealthChart !== undefined)
                {
                    batteryHealthChart.setFilter(ids);

                    batteryHealthChart.refresh();
                }

                if (engineWearAndTearChart !== undefined)
                {
                    engineWearAndTearChart.setFilter(ids);

                    engineWearAndTearChart.refresh();
                }

                if (fuelLevelChart !== undefined)
                {
                    fuelLevelChart.setFilter(ids);

                    fuelLevelChart.refresh();
                }
                if (fuelConsumptionChart !== undefined)
                {
                    fuelConsumptionChart.setFilter(ids);

                    fuelConsumptionChart.refresh();
                }
                if (idlingTimeLimitChart !== undefined)
                {
                    idlingTimeLimitChart.setFilter(ids);

                    idlingTimeLimitChart.refresh();
                }
                if (engineCheckChart !== undefined)
                {
                    engineCheckChart.setFilter(ids);

                    engineCheckChart.refresh();
                }
                if (engineTempChart !== undefined)
                {
                    engineTempChart.setFilter(ids);

                    engineTempChart.refresh();
                }
                if (engineLoadChart !== undefined)
                {
                    engineLoadChart.setFilter(ids);

                    engineLoadChart.refresh();
                }
                if (exhaustBrakeChart !== undefined)
                {
                    exhaustBrakeChart.setFilter(ids);

                    exhaustBrakeChart.refresh();
                }
                if (mileageServiceChart !== undefined)
                {
                    mileageServiceChart.setFilter(ids);

                    mileageServiceChart.refresh();
                }

                //JX: Cluster Location to send additional groupId over. See ChartDataHandler getAllDriverId() method for explaination
                if (clusterLocationTrackingChart !== undefined)
                {
                    clusterLocationTrackingChart.setFilter(ids, getGroupId('tree-view-filter-asset', 'filter-asset'));

                    clusterLocationTrackingChart.refresh();
                }
                if (clusterLocationGroup !== undefined)
                {
                    clusterLocationGroup.setFilter(ids, getGroupId('tree-view-filter-asset', 'filter-asset'));

                    clusterLocationGroup.refresh();
                }
                if (clusterLocationGroupIndividual !== undefined)
                {
                    clusterLocationGroupIndividual.setFilter(ids, getGroupId('tree-view-filter-asset', 'filter-asset'));

                    clusterLocationGroupIndividual.refresh();
                }
                if (engineAnalytics !== undefined)
                {
                    engineAnalytics.setFilter(ids);

                    engineAnalytics.refresh();
                }
            }

            function onTreeviewCheckboxClicked(treeview, parent, children, checked)
            {
                if (treeview === 'tree-view-filter-asset')
                {
                    var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

                    if (ids === null || ids === undefined || ids === "")
                    {
                        return false;
                    }

                    filterChart(ids);

                }
                else
                {
                    return;
                }
            }

            function updateHealthChart(result)
            {
                healthCharts.push(result);

                // wait for 2 charts to update prior to overall health...
                if (healthCharts.length === 2)
                {
                    var total = 0;

                    healthCharts.forEach(function(val)
                    {
                        total += val;
                    });

                    overallHealthChart.updateChart(overallHealthChart.chart, {data: (total / healthCharts.length)});

                    healthCharts.length = 0;
                }
            }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("dashboard")%></h1>
        </div>
        <br>
        <div class="grid" style="max-width: 100%">
            <div class="row cells4">
                <div id="treeview-panel" class="cell dashboard-chart">
                    <h3 class="text-light align-left"><%=userProperties.getLanguage("filter")%></h3>
                    <div  class="treeview-control" style="height: 100%">
                        <%
                            assetTreeView.outputHTML(out, userProperties);
                        %>
                    </div>
                </div>
                <div class="cell colspan3">

                    <%
                        //initilize parent variable for all the charts
                        int cells;
                        int cols;
                        int rows;

//                        Telematics Analysis Dashboard
                        cells = telematicsChartIds.size();
                        cols = 4;
                        rows = (int) Math.ceil((double) cells / (double) cols);

                        if (cells > 0)
                        {
                            out.write("<div class=\"dashboard-section-title\">Telematics Analysis Dashboard</div>");
                        }

                        for (int row = 0; row < rows; row++)
                        {
                            out.write("<div class=\"row cells4\">");

                            for (int col = 0; col < cols; col++)
                            {
                                int indexOfChart = col + (row * cols);

                                if (indexOfChart < cells)
                                {
                                    out.write("<div class=\"cell\">");
                                    out.write("<div id=\"" + telematicsChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\" style=\"min-height:250px;\"></div>");
                                    out.write("</div>");
                                }
                            }

                            out.write("</div>");
                        }

                        //Health Dashboard
                        cells = healthChartIds.size();
                        cols = 3;
                        rows = (int) Math.ceil((double) cells / (double) cols);

                        if (cells > 0)
                        {
                            out.write("<div class=\"dashboard-section-title\">Vehicle Health</div>");
                        }

                        if (engineAnalyticsChart.size() > 0)
                        {
                            out.write("<div class=\"row cells\">");
                            out.write("<div class=\"cell\">");
                            out.write("<div id=\"" + engineAnalyticsChart.get(0) + "\" class=\"dashboard-chart\"></div>");
                            out.write("</div>");
                            out.write("</div>");
                        }

                        for (int row = 0; row < rows; row++)
                        {
                            out.write("<div class=\"row cells3\">");

                            for (int col = 0; col < cols; col++)
                            {
                                int indexOfChart = col + (row * cols);

                                if (indexOfChart < cells)
                                {
                                    out.write("<div class=\"cell\">");
                                    out.write("<div id=\"" + healthChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");
                                    out.write("</div>");
                                }
                            }

                            out.write("</div>");
                        }

                        //Utilization Dashboard
                        cells = utilizationChartIds.size();
                        if (cells == 4)
                        {
                            cols = 2;
                            rows = (int) Math.ceil((double) cells / (double) cols);
                            out.write("<div class=\"dashboard-section-title\">Vehicle Utilization</div>");

                            for (int row = 0; row < rows; row++)
                            {
                                out.write("<div class=\"row cells3\">");

                                for (int col = 0; col < cols; col++)
                                {
                                    int indexOfChart = col + (row * cols);

                                    if (indexOfChart < cells)
                                    {
                                        out.write("<div class=\"cell\">");
                                        out.write("<div id=\"" + utilizationChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");
                                        out.write("</div>");
                                    }
                                }

                                out.write("</div>");
                            }
                        }
                        else
                        {
                            cols = 3;
                            rows = (int) Math.ceil((double) cells / (double) cols);

                            if (cells > 0)
                            {
                                out.write("<div class=\"dashboard-section-title\">Vehicle Utilization</div>");
                            }

                            for (int row = 0; row < rows; row++)
                            {
                                out.write("<div class=\"row cells3\">");

                                for (int col = 0; col < cols; col++)
                                {
                                    int indexOfChart = col + (row * cols);

                                    if (indexOfChart < cells)
                                    {
                                        out.write("<div class=\"cell\">");
                                        out.write("<div id=\"" + utilizationChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");
                                        out.write("</div>");
                                    }
                                }

                                out.write("</div>");
                            }
                        }

                        //Driver Safety Dashboard
                        cells = safetyChartIds.size();
                        cols = 3;
                        rows = (int) Math.ceil((double) cells / (double) cols);

                        if (cells > 0)
                        {
                            out.write("<div class=\"dashboard-section-title\">Driver Safety</div>");
                        }

                        for (int row = 0; row < rows; row++)
                        {
                            out.write("<div class=\"row cells3\">");

                            for (int col = 0; col < cols; col++)
                            {
                                int indexOfChart = col + (row * cols);

                                if (indexOfChart < cells)
                                {
//                                    if (safetyChartIds.get(indexOfChart).equals("manoeuvre-summary-chart"))
//                                    {
//                                        out.write("<div class=\"cell colspan2\">");
//
//                                        col = col + 1;
//                                    }
//                                    else
//                                    {
                                    out.write("<div class=\"cell\">");
//                                    }

                                    out.write("<div id=\"" + safetyChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");

                                    out.write("</div>");
                                }
                            }

                            out.write("</div>");
                        }

                        //Status Dashboard
                        cells = statusChartIds.size();
                        cols = 3;
                        rows = (int) Math.ceil((double) cells / (double) cols);

                        if (cells > 0)
                        {
                            out.write("<div class=\"dashboard-section-title\">Status Dashboard</div>");
                        }

                        for (int row = 0; row < rows; row++)
                        {
                            out.write("<div class=\"row cells3\">");

                            for (int col = 0; col < cols; col++)
                            {
                                int indexOfChart = col + (row * cols);

                                if (indexOfChart < cells)
                                {
                                    if (statusChartIds.get(indexOfChart).equals("job-progress-chart"))
                                    {
                                        out.write("<div class=\"cell colspan2\" >");
                                        out.write("<div id=\"" + statusChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");
                                        out.write("</div>");
                                    }
                                    else
                                    {
                                        out.write("<div class=\"cell\">");
                                        out.write("<div id=\"" + statusChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");
                                        out.write("</div>");
                                    }
                                }
                            }

                            out.write("</div>");
                        }
                        // Cluster Dashboard 2
                        cells = clusterChartIds.size() - 1;
                        cols = 3;
                        rows = (int) Math.ceil((double) cells / (double) cols);

                        if (clusterChartIds.size() > 0)
                        {
                            if (cells > 0)
                            {
                                out.write("<div class=\"dashboard-section-title\">Status Dashboard</div>");
                            }

                            for (int row = 0; row < rows; row++)
                            {
                                out.write("<div class=\"row cells3\">");

                                for (int col = 0; col < cols; col++)
                                {
                                    int indexOfChart = col + (row * cols);

                                    if (indexOfChart < cells)
                                    {
                                        out.write("<div class=\"cell\">");
                                        out.write("<div id=\"" + clusterChartIds.get(indexOfChart) + "\" class=\"dashboard-chart\"></div>");
                                        out.write("</div>");
                                    }
                                }

                                out.write("</div>");
                            }
                            if (cells < 1)
                            {
                                out.write("<div class=\"dashboard-section-title\">Status Dashboard</div>");
                            }
                            out.write("<div class=\"row\">");

                            out.write("<div class=\"cell\">");
                            out.write("<div id=\"cluster-location-chart\" class=\"dashboard-chart\"></div>");
                            out.write("</div>");
                            out.write("</div>");
                        }
                    %>

                    <div class="row">
                        <%  if (accessGeoFenceOccurenceChart)
                            {
                        %>
                        <div class="cell">
                            <div id="geofence-occurence-chart" class="dashboard-chart"></div>
                        </div>
                        <%
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
