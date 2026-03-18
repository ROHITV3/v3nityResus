<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.report.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    ListData data = new JourneyElement();

    DataHandler dataHandler = new DataHandler();

    ListMetaData metaData = null;

    List<MetaData> metaDataList = data.getMetaDataList();

    int metaListSize = metaDataList.size();

    String columnList = "";

    String columnList1 = "";

    AssetDropDown assetDropDown = new AssetDropDown(userProperties);

    DriverDropDown driverDropDown = new DriverDropDown(userProperties);

    try
    {
        dataHandler.setConnection(userProperties.getConnection());

        for (int i = 0; i < metaListSize; i++)
        {
            metaData = (ListMetaData) metaDataList.get(i);

            // construct the column definition for the data table...
            if (metaData.getViewable())
            {
                if (columnList.length() > 0)
                {
                    columnList += ",";
                }

                columnList += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + "\", \"orderable\": " + metaData.getOrderable() + " }";
                //columnList += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + " }";
            }
        }

        columnList1 = "{ \"data\": \"1\", \"title\": \"Start Time\", \"orderable\": true },"
                      + "{ \"data\": \"2\", \"title\": \"Status\", \"orderable\": true },"
                      + "{ \"data\": \"3\", \"title\": \"Duration[HH:mm]\", \"orderable\": true },"
                      + "{ \"data\": \"4\", \"title\": \"Distance[km]\", \"orderable\": true },"
                      + "{ \"data\": \"5\", \"title\": \"Start\", \"orderable\": true }";

        assetDropDown.setIdentifier("dropdown-asset");

        assetDropDown.loadData(userProperties);

        driverDropDown.setIdentifier("dropdown-driver");

        driverDropDown.loadData(userProperties);
    }
    catch (Exception e)
    {

    }
    finally
    {
        dataHandler.closeConnection();
    }

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today) + " 00:00:00";

    String inputEndDate = dateTimeFormatter.format(today) + " 23:59:59";
%>

<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <script type="text/javascript">

            var totalRecords = -1;

            var requireOverallCount = true;

            var customFilterQuery = '';

            var tbl;

            var compareTbl1;

            var compareTbl2;

            $(document).ready(function()
            {
                $("#journeyDiv").hide();
                $("#compareDiv").hide();
                $("#deviceId1").select2();
                $("#deviceId2").select2();

                tbl = $("#resultTable").DataTable(
                    {
                        dom: 'tip',
                        pageLength: 20,
                        deferRender: true,
                        deferLoading: 0,
                        orderClasses: false,
                        columns: [<%=columnList%>],
                        serverSide: false,
                        responsive: true,
                        paging: true,
                        ajax: {
                            url: 'JourneyReportController?type=system&action=get',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords;
                                d.requireOverallCount = requireOverallCount;
                                d.deviceId1 = $("#deviceId1").val();
                                d.deviceId2 = $("#deviceId2").val();
                                d.driverId1 = $("#driverId1").val();
                                d.driverId2 = $("#driverId2").val();
                                d.journeyReportFromDate1 = $("#dateTimePicker-history-start-date1").val();
                                d.journeyReportToDate1 = $("#dateTimePicker-history-end-date1").val();
                                d.journeyReportFromDate2 = $("#dateTimePicker-history-start-date2").val();
                                d.journeyReportToDate2 = $("#dateTimePicker-history-end-date2").val();
                                d.fuelUsed1 = $("#fuelUsed1").val();
                                d.fuelCost1 = $("#fuelCost1").val();
                                d.costPerHour1 = $("#costPerHour1").val();
                                d.fuelUsed2 = $("#fuelUsed2").val();
                                d.fuelCost2 = $("#fuelCost2").val();
                                d.costPerHour2 = $("#costPerHour2").val();
                                d.journey = "1";
                                d.basis = $("input:radio[name=basis]:checked").val();
                                d.reload = $("#reload").val();
                            },
                            dataSrc: function(json)
                            {
                                if (json.result === false && json.warning !== undefined)
                                {
                                    dialog('Error', json.warning, 'alert');

                                    $('.toolbar-button').prop("disabled", false);
                                }

                                if (JSON.stringify(json.label))
                                {

                                    var label = json.label;
                                    var distance = json.distance;
                                    var ignition_on_duration = json.ignition_on_duration;
                                    var ignition_off_duration = json.ignition_off_duration;
                                    var idling_duration = json.idling_duration;
                                    var longest_ignition_on_duration = json.longest_ignition_on_duration;
                                    var longest_ignition_off_duration = json.longest_ignition_off_duration;
                                    var first_ignition_on = json.first_ignition_on;
                                    var last_ignition_on = json.last_ignition_on;
                                    var first_ignition_off = json.first_ignition_off;
                                    var last_ignition_off = json.last_ignition_off;
                                    var cost_per_km = json.cost_per_km;
                                    var km_per_litre = json.km_per_litre;
                                    var idling_cost = json.idling_cost;

                                    var str = '';

                                    str += '<div class="field-value"><span>Label</span><span>' + label + '</span></div>';
                                    str += '<div class="field-value"><span>Distance</span><span>' + distance + '</span></div>';
                                    str += '<div class="field-value"><span>Ignition on duration [HH:mm]</span><span>' + ignition_on_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Ignition off duration [HH:mm]</span><span>' + ignition_off_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Idling duration</span><span>' + idling_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Longest ignition on duration [HH:mm]</span><span>' + longest_ignition_on_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Longest ignition off duration [HH:mm]</span><span>' + longest_ignition_off_duration + '</span></div>';
                                    str += '<div class="field-value"><span>First ignition on</span><span>' + first_ignition_on + '</span></div>';
                                    str += '<div class="field-value"><span>Last ignition on</span><span>' + last_ignition_on + '</span></div>';
                                    str += '<div class="field-value"><span>First ignition off</span><span>' + first_ignition_off + '</span></div>';
                                    str += '<div class="field-value"><span>Last ignition off</span><span>' + last_ignition_off + '</span></div>';
                                    str += '<div class="field-value"><span>Cost&#47;km [&#36;]</span><span>' + cost_per_km + '</span></div>';
                                    str += '<div class="field-value"><span>Km&#47;l [km]' + km_per_litre + '</span></div>';
                                    str += '<div class="field-value"><span>Idling cost [&#36;]</span><span>' + idling_cost + '</span></div>';

                                    document.getElementById("journeyTableResult").innerHTML = str;
                                }
                                return json.aaData;
                            },
                            beforeSend: function()
                            {
                                $('.toolbar-button').prop("disabled", true);
                            },
                            complete: function()
                            {
                                $('.toolbar-button').prop("disabled", false);
                            }
                        },
                        drawCallback: function()
                        {
                            // do this so that the total records will not be retrieved from the database again...
                            // greatly increase performance towards retrieving data from datatable...
                            if (tbl !== undefined)
                            {
                                totalRecords = tbl.page.info().recordsTotal;

                                requireOverallCount = false;

                                if (totalRecords === 0)
                                {
                                }
                            }
                        },
                        select: {
                        },
                        buttons: [
                            'selectAll',
                            'selectNone',
                            'csv'
                        ],
                        language: {
                            info: 'Showing _START_ to _END_ of _TOTAL_ entries ',
                            infoEmpty: 'Showing 0 to 0 of 0 entries',
                            emptyTable: 'No data available',
                            loadingRecords: 'Loading...',
                            processing: 'Retrieving...',
                            zeroRecords: 'No matching records found',
                            paginate: {
                                first: '<<',
                                last: '>>',
                                next: '>',
                                previous: '<'
                            }
                        }

                    });

                // every ajax call, turn off the draw event otherwise,
                // all rows will be selected from the table upon selecting buttons within the table.
                // there is something wrong with the datatable with server side processing.
                tbl.on('xhr', function()
                {

                    // this will turn off the event...
                    tbl.off('draw.dt.dtSelect');
                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });

                compareTbl1 = $("#compareTable1").DataTable(
                    {
                        dom: 'tip',
                        pageLength: 20,
                        deferRender: true,
                        deferLoading: 0,
                        orderClasses: false,
                        columns: [<%=columnList1%>],
                        serverSide: false,
                        responsive: true,
                        paging: true,
                        ajax: {
                            url: 'JourneyReportController?type=system&action=get',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords;
                                d.requireOverallCount = requireOverallCount;
                                d.deviceId1 = $("#deviceId1").val();
                                d.deviceId2 = $("#deviceId2").val();
                                d.driverId1 = $("#driverId1").val();
                                d.driverId2 = $("#driverId2").val();
                                d.journeyReportFromDate1 = $("#dateTimePicker-history-start-date1").val();
                                d.journeyReportToDate1 = $("#dateTimePicker-history-end-date1").val();
                                d.journeyReportFromDate2 = $("#dateTimePicker-history-start-date2").val();
                                d.journeyReportToDate2 = $("#dateTimePicker-history-end-date2").val();
                                d.fuelUsed1 = $("#fuelUsed1").val();
                                d.fuelCost1 = $("#fuelCost1").val();
                                d.costPerHour1 = $("#costPerHour1").val();
                                d.fuelUsed2 = $("#fuelUsed2").val();
                                d.fuelCost2 = $("#fuelCost2").val();
                                d.costPerHour2 = $("#costPerHour2").val();
                                d.journey = "1";
                                d.basis = $("input:radio[name=basis]:checked").val();
                                d.compare = "true";
                                //d.basisStr = document.getElementById('journeyReportToDate1').value;
                                d.reload = $("#reload").val();
                            },
                            dataSrc: function(json)
                            {
                                if (json.result === false && json.warning !== undefined)
                                {
                                    dialog('Error', json.warning, 'alert');

                                    $('.toolbar-button').prop("disabled", false);
                                }

                                if (JSON.stringify(json.label))
                                {
                                    var label = json.label;
                                    var distance = json.distance;
                                    var ignition_on_duration = json.ignition_on_duration;
                                    var ignition_off_duration = json.ignition_off_duration;
                                    var idling_duration = json.idling_duration;
                                    var longest_ignition_on_duration = json.longest_ignition_on_duration;
                                    var longest_ignition_off_duration = json.longest_ignition_off_duration;
                                    var first_ignition_on = json.first_ignition_on;
                                    var last_ignition_on = json.last_ignition_on;
                                    var first_ignition_off = json.first_ignition_off;
                                    var last_ignition_off = json.last_ignition_off;
                                    var cost_per_km = json.cost_per_km;
                                    var km_per_litre = json.km_per_litre;
                                    var idling_cost = json.idling_cost;

                                    var str = '';

                                    str += '<div class="field-value"><span>Label</span><span>' + label + '</span></div>';
                                    str += '<div class="field-value"><span>Distance</span><span>' + distance + '</span></div>';
                                    str += '<div class="field-value"><span>Ignition on duration [HH:mm]</span><span>' + ignition_on_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Ignition off duration [HH:mm]</span><span>' + ignition_off_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Idling duration</span><span>' + idling_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Longest ignition on duration [HH:mm]</span><span>' + longest_ignition_on_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Longest ignition off duration [HH:mm]</span><span>' + longest_ignition_off_duration + '</span></div>';
                                    str += '<div class="field-value"><span>First ignition on</span><span>' + first_ignition_on + '</span></div>';
                                    str += '<div class="field-value"><span>Last ignition on</span><span>' + last_ignition_on + '</span></div>';
                                    str += '<div class="field-value"><span>First ignition off</span><span>' + first_ignition_off + '</span></div>';
                                    str += '<div class="field-value"><span>Last ignition off</span><span>' + last_ignition_off + '</span></div>';
                                    str += '<div class="field-value"><span>Cost&#47;km [&#36;]</span><span>' + cost_per_km + '</span></div>';
                                    str += '<div class="field-value"><span>Km&#47;l [km]' + km_per_litre + '</span></div>';
                                    str += '<div class="field-value"><span>Idling cost [&#36;]</span><span>' + idling_cost + '</span></div>';


                                    document.getElementById("journeyTableCompare1").innerHTML = str;
                                }
                                return json.aaData;
                            },
                            beforeSend: function()
                            {
                                $('.toolbar-button').prop("disabled", true);
                            },
                            complete: function()
                            {
                                $('.toolbar-button').prop("disabled", false);
                            }

                        },
                        drawCallback: function()
                        {
                            // do this so that the total records will not be retrieved from the database again...
                            // greatly increase performance towards retrieving data from datatable...
                            if (compareTbl1 !== undefined)
                            {
                                totalRecords = compareTbl1.page.info().recordsTotal;

                                requireOverallCount = false;

                                if (totalRecords === 0)
                                {
                                }
                            }
                        },
                        select: {
                        },
                        buttons: [
                            'selectAll',
                            'selectNone',
                            'csv'
                        ],
                        language: {
                            info: 'Showing _START_ to _END_ of _TOTAL_ entries ',
                            infoEmpty: 'Showing 0 to 0 of 0 entries',
                            emptyTable: 'No data available',
                            loadingRecords: 'Loading...',
                            processing: 'Retrieving...',
                            zeroRecords: 'No matching records found',
                            paginate: {
                                first: '<<',
                                last: '>>',
                                next: '>',
                                previous: '<'
                            }
                        }

                    });
                compareTbl1.on('xhr', function()
                {

                    // this will turn off the event...
                    compareTbl1.off('draw.dt.dtSelect');
                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });

                compareTbl2 = $("#compareTable2").DataTable(
                    {
                        dom: 'tip',
                        pageLength: 20,
                        deferRender: true,
                        deferLoading: 0,
                        orderClasses: false,
                        columns: [<%=columnList1%>],
                        serverSide: false,
                        responsive: true,
                        paging: true,
                        ajax: {
                            url: 'JourneyReportController?type=system&action=get',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords;
                                d.requireOverallCount = requireOverallCount;
                                d.deviceId1 = $("#deviceId1").val();
                                d.deviceId2 = $("#deviceId2").val();
                                d.driverId1 = $("#driverId1").val();
                                d.driverId2 = $("#driverId2").val();
                                d.journeyReportFromDate1 = $("#dateTimePicker-history-start-date1").val();
                                d.journeyReportToDate1 = $("#dateTimePicker-history-end-date1").val();
                                d.journeyReportFromDate2 = $("#dateTimePicker-history-start-date2").val();
                                d.journeyReportToDate2 = $("#dateTimePicker-history-end-date2").val();
                                d.fuelUsed1 = $("#fuelUsed1").val();
                                d.fuelCost1 = $("#fuelCost1").val();
                                d.costPerHour1 = $("#costPerHour1").val();
                                d.fuelUsed2 = $("#fuelUsed2").val();
                                d.fuelCost2 = $("#fuelCost2").val();
                                d.costPerHour2 = $("#costPerHour2").val();
                                d.journey = "2";
                                d.basis = $("input:radio[name=basis]:checked").val();
                                d.compare = "true";
                                //d.basisStr = document.getElementById('journeyReportToDate1').value;
                                d.reload = $("#reload").val();
                            },
                            dataSrc: function(json)
                            {
                                if (json.result === false && json.warning !== undefined)
                                {
                                    dialog('Error', json.warning, 'alert');

                                    $('.toolbar-button').prop("disabled", false);
                                }

                                if (JSON.stringify(json.label))
                                {

                                    var label = json.label;
                                    var distance = json.distance;
                                    var ignition_on_duration = json.ignition_on_duration;
                                    var ignition_off_duration = json.ignition_off_duration;
                                    var idling_duration = json.idling_duration;
                                    var longest_ignition_on_duration = json.longest_ignition_on_duration;
                                    var longest_ignition_off_duration = json.longest_ignition_off_duration;
                                    var first_ignition_on = json.first_ignition_on;
                                    var last_ignition_on = json.last_ignition_on;
                                    var first_ignition_off = json.first_ignition_off;
                                    var last_ignition_off = json.last_ignition_off;
                                    var cost_per_km = json.cost_per_km;
                                    var km_per_litre = json.km_per_litre;
                                    var idling_cost = json.idling_cost;

                                    var str = '';
                                    str += '<div class="field-value"><span>Label</span><span>' + label + '</span></div>';
                                    str += '<div class="field-value"><span>Distance</span><span>' + distance + '</span></div>';
                                    str += '<div class="field-value"><span>Ignition on duration [HH:mm]</span><span>' + ignition_on_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Ignition off duration [HH:mm]</span><span>' + ignition_off_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Idling duration</span><span>' + idling_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Longest ignition on duration [HH:mm]</span><span>' + longest_ignition_on_duration + '</span></div>';
                                    str += '<div class="field-value"><span>Longest ignition off duration [HH:mm]</span><span>' + longest_ignition_off_duration + '</span></div>';
                                    str += '<div class="field-value"><span>First ignition on</span><span>' + first_ignition_on + '</span></div>';
                                    str += '<div class="field-value"><span>Last ignition on</span><span>' + last_ignition_on + '</span></div>';
                                    str += '<div class="field-value"><span>First ignition off</span><span>' + first_ignition_off + '</span></div>';
                                    str += '<div class="field-value"><span>Last ignition off</span><span>' + last_ignition_off + '</span></div>';
                                    str += '<div class="field-value"><span>Cost&#47;km [&#36;]</span><span>' + cost_per_km + '</span></div>';
                                    str += '<div class="field-value"><span>Km&#47;l [km]' + km_per_litre + '</span></div>';
                                    str += '<div class="field-value"><span>Idling cost [&#36;]</span><span>' + idling_cost + '</span></div>';

                                    document.getElementById("journeyTableCompare2").innerHTML = str;
                                }
                                return json.aaData;
                            },
                            beforeSend: function()
                            {
                                $('.toolbar-button').prop("disabled", true);
                            },
                            complete: function()
                            {
                                $('.toolbar-button').prop("disabled", false);
                            }

                        },
                        drawCallback: function()
                        {
                            // do this so that the total records will not be retrieved from the database again...
                            // greatly increase performance towards retrieving data from datatable...
                            if (compareTbl2 !== undefined)
                            {
                                totalRecords = compareTbl2.page.info().recordsTotal;

                                requireOverallCount = false;

                                if (totalRecords === 0)
                                {
                                }
                            }
                        },
                        select: {
                        },
                        buttons: [
                            'selectAll',
                            'selectNone',
                            'csv'
                        ],
                        language: {
                            info: 'Showing _START_ to _END_ of _TOTAL_ entries ',
                            infoEmpty: 'Showing 0 to 0 of 0 entries',
                            emptyTable: 'No data available',
                            loadingRecords: 'Loading...',
                            processing: 'Retrieving...',
                            zeroRecords: 'No matching records found',
                            paginate: {
                                first: '<<',
                                last: '>>',
                                next: '>',
                                previous: '<'
                            }
                        }

                    });

                // every ajax call, turn off the draw event otherwise,
                // all rows will be selected from the table upon selecting buttons within the table.
                // there is something wrong with the datatable with server side processing.
                compareTbl2.on('xhr', function()
                {

                    // this will turn off the event...
                    compareTbl2.off('draw.dt.dtSelect');
                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });

                $("#dateTimePicker-history-start-date1").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#dateTimePicker-history-end-date1").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#dateTimePicker-history-start-date2").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#dateTimePicker-history-end-date2").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#downloadJourney").click(function()
                {
                    window.open("JourneyReportController?type=system&action=downloadJourney&journeyReportFromDate1="
                        + $("#dateTimePicker-history-start-date1").val() + "&journeyReportToDate1="
                        + $("#dateTimePicker-history-end-date1").val() + "&deviceId1=" + $("#deviceId1").val()
                        + "&driverId1=" + $("#driverId1").val() + "&fuelUsed1=" + $("#fuelUsed1").val() + "&fuelCost1="
                        + $("#fuelCost1").val() + "&costPerHour1=" + $("#costPerHour1").val() + "&selectedDevice1="
                        + $("#deviceId1 option:selected").text() + "&selectedDriver1=" + $("#driverId1 option:selected").text()
                        + "&basis=" + $("input:radio[name=basis]:checked").val(), "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                });

                $("#downloadCompare").click(function()
                {
                    window.open("JourneyReportController?type=system&action=downloadCompare&journeyReportFromDate1="
                        + $("#dateTimePicker-history-start-date1").val() + "&journeyReportToDate1="
                        + $("#dateTimePicker-history-end-date1").val() + "&deviceId1=" + $("#deviceId1").val()
                        + "&driverId1=" + $("#driverId1").val() + "&fuelUsed1=" + $("#fuelUsed1").val() + "&fuelCost1="
                        + $("#fuelCost1").val() + "&costPerHour1=" + $("#costPerHour1").val()
                        + "&journeyReportFromDate2=" + $("#dateTimePicker-history-start-date2").val()
                        + "&journeyReportToDate2=" + $("#dateTimePicker-history-end-date2").val()
                        + "&deviceId2=" + $("#deviceId2").val() + "&driverId2=" + $("#driverId2").val()
                        + "&fuelUsed2=" + $("#fuelUsed2").val() + "&fuelCost2=" + $("#fuelCost2").val()
                        + "&costPerHour2=" + $("#costPerHour2").val() + "&selectedDevice1=" + $("#deviceId1 option:selected").text()
                        + "&selectedDriver1=" + $("#driverId1 option:selected").text() + "&selectedDevice2=" + $("#deviceId2 option:selected").text()
                        + "&selectedDriver2=" + $("#driverId2 option:selected").text() + "&basis="
                        + $("input:radio[name=basis]:checked").val(), "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                });
            });

            function dispose()
            {

                $("#dateTimePicker-history-start-date1").AnyTime_noPicker();

                $("#dateTimePicker-history-end-date1").AnyTime_noPicker();

                $("#dateTimePicker-history-start-date2").AnyTime_noPicker();

                $("#dateTimePicker-history-end-date2").AnyTime_noPicker();
            }

            function refreshDataTable()
            {
                requireOverallCount = true;
                refreshPageLength();
            }

            function refreshPageLength()
            {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength))
                {
                    var table = $('#resultTable').DataTable();
                    var compare1 = $('#compareTable1').DataTable();
                    var compare2 = $('#compareTable2').DataTable();
                    $("#reload").val("yes");
                    table.ajax.reload(null, false);
                    table.page.len(pageLength).draw();
                    compare1.page.len(pageLength).draw();
                    compare2.page.len(pageLength).draw();
                    $("#reload").val("no");
                }
                else
                {
                    resetPageLength();
                }
            }

            function resetPageLength()
            {
                var table = $('#resultTable').DataTable();
                var compare1 = $('#compareTable1').DataTable();
                var compare2 = $('#compareTable2').DataTable();
                // reset default value in page length control...
                $('#page-length').val(20);
                // reset search box...
                $('#search-data').val('');
                // reset table search...
                table.search('');
                // reset default page length...
                table.page.len(20).draw();
                compare1.page.len(20).draw();
                compare2.page.len(20).draw();
            }

            function searchData()
            {
                var searchText = $('#search-data').val();

                requireOverallCount = true;

                $('#resultTable').DataTable().search(searchText).draw();
                $('#compareTable1').DataTable().search(searchText).draw();
                $('#compareTable2').DataTable().search(searchText).draw();
            }

            function generateCompareTable()
            {
                $('#reload').val("yes");
                $('#compareTable1').DataTable().ajax.reload(null, false);
                $('#compareTable2').DataTable().ajax.reload(null, false);
                $("#journeyDiv").hide();
                $("#compareDiv").show();
                $('#reload').val("no");
                
                document.getElementById("journeyTableCompare2").innerHTML = '';
            }

            function customFilter()
            {
                $("#compareDiv").hide();
                $("#journeyDiv").show();
                
                document.getElementById("journeyTableResult").innerHTML = '';

                refreshDataTable();
            }

            function resetAllFields1()
            {
                document.getElementById("fuelUsed1").value = "";
                document.getElementById("fuelCost1").value = "";
                document.getElementById("costPerHour1").value = "";
            }

            function resetAllFields2()
            {
                document.getElementById("fuelUsed2").value = "";
                document.getElementById("fuelCost2").value = "";
                document.getElementById("costPerHour2").value = "";
            }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light">Journey Report</h1>
        </div>
        <input type="hidden" name="reload" id="reload">
        <br/>
        <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <h2 class="text-light">Journey 1</h2>
                    <div class="toolbar">
                        <div class="toolbar-section">
                            <button class="toolbar-button" id ="resetForm" name="resetForm" title="<%=userProperties.getLanguage("reset")%>" onclick="resetAllFields1()"><span class="mif-undo"></span></button>
                        </div>
                        <div class="toolbar-section">
                            <button class="toolbar-button" id ="downloadJourney" name="downloadJourney"><span class="text-light text-small">CSV</span></button>
                        </div>
                        <div class="toolbar-section">
                            <button class="toolbar-button" onclick="customFilter()"><span class="mif-search"></span></button>
                        </div>
                    </div>
                    <h4 class="text-light"><%=userProperties.getLanguage("asset")%></h4>
                    <div class="input-control select">
                        <select id="deviceId1" name="deviceId1">
                            <option value = "">Select Asset</option>
                            <% assetDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                    <h4 class="text-light"><%=userProperties.getLanguage("driver")%></h4>
                    <div class="input-control select">
                        <select id="driverId1" name="driverId1">
                            <option value = "">Select Staff</option>
                            <% driverDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                    <br/>
                    <h4 class="text-light">Date Range</h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-start-date1" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    -
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-end-date1" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="<%=inputEndDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                </div>
                <div class="cell">
                    <h2 class="text-light">Journey 2</h2>
                    <div class="toolbar">
                        <div class="toolbar-section">
                            <button class="toolbar-button" id="resetForm" name="resetForm" value="" title="<%=userProperties.getLanguage("reset")%>" onclick="resetAllFields2()"><span class="mif-undo"></span></button>
                        </div>
                        <div class="toolbar-section">
                            <button class="toolbar-button" id ="downloadCompare" name="downloadCompare"><span class="text-light text-small">CSV</span></button>
                        </div>
                        <div class="toolbar-section">
                            <button class="toolbar-button" onclick="generateCompareTable()"><span class="mif-search"></span></button>
                        </div>
                    </div>
                    <h4 class="text-light"><%=userProperties.getLanguage("asset")%></h4>
                    <div class="input-control select">
                        <select id="deviceId2" name="deviceId2">
                            <option value = "">Select Asset</option>
                            <% assetDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                    <h4 class="text-light"><%=userProperties.getLanguage("driver")%></h4>
                    <div class="input-control select">
                        <select id="driverId2" name="driverId2">
                            <option value = "">Select Staff</option>
                            <% driverDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                    <h4 class="text-light">Date Range</h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-start-date2" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    -
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-end-date2" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="<%=inputEndDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                </div>
            </div>
            <div class="row cells2">
                <div class="cell">
                    <div class="input-control text">
                        <h4 class="text-light"><%=userProperties.getLanguage("fuelCost[$]") + ":"%></h4>
                        <input id="fuelCost1" name="fuelCost1" type="text" maxlength="5" size="5" value="">
                    </div>
                    <div class="input-control text">
                        <h4 class="text-light"><%=userProperties.getLanguage("fuelUsed[litres]") + ":"%></h4>
                        <input id="fuelUsed1" name="fuelUsed1" type="text" maxlength="5" size="5" value="">
                    </div>
                    <div class="input-control text">
                        <h4 class="text-light"><%=userProperties.getLanguage("cost/Hr[$]") + ":"%></h4>
                        <input id="costPerHour1" name="costPerHour1" type="text" maxlength="5" size="5" value="">
                    </div>
                </div>
                <div class="cell">
                    <div class="input-control text">
                        <h4 class="text-light"><%=userProperties.getLanguage("fuelCost[$]") + ":"%></h4>
                        <input id="fuelCost2" name="fuelCost2" type="text" maxlength="5" size="5" value="">
                    </div>
                    <div class="input-control text">
                        <h4 class="text-light"><%=userProperties.getLanguage("fuelUsed[litres]") + ":"%></h4>
                        <input id="fuelUsed2" name="fuelUsed2" type="text" maxlength="5" size="5" value="">
                    </div>
                    <div class="input-control text">
                        <h4 class="text-light"><%=userProperties.getLanguage("cost/Hr[$]") + ":"%></h4>
                        <input id="costPerHour2" name="costPerHour2" type="text" maxlength="5" size="5" value="">
                    </div>
                </div>
            </div>
            <br><br>
            <div class="row">
                <div>
                    <h4 class="text-light align-left">Options</h4>
                    <label class="input-control radio">
                        <input type="radio" name="basis" value="ignition" checked="checked"/>
                        <span class="check"></span>
                        <span class="caption"><%=userProperties.getLanguage("basedOnIgnitionOn/Off")%></span>
                    </label>
                    <label class="input-control radio">
                        <input type="radio" name="basis" value="geofence" />
                        <span class="check"></span>
                        <span class="caption"><%=userProperties.getLanguage("basedOnGeoFenceEntry/Exit")%></span>
                    </label>
                </div>
            </div>
        </div>
        <br/><br/>
        <div class="list-show-result-control">
            <div class="input-control text" style="margin: 0">
                <input id="page-length" type="text" value="20" maxlength="4">
                <div class="button-group">
                    <button class="button" id="refresh" name="refresh" value="" title="<%=userProperties.getLanguage("refresh")%>" onclick="refreshPageLength()"><span class="mif-loop2"></span></button>
                    <button class="button" id="resetForm" name="resetForm" value="" title="<%=userProperties.getLanguage("reset")%>" onclick="resetPageLength()"><span class="mif-undo"></span></button>
                </div>
            </div>
        </div>
        <div class="list-search-control">
            <%
                if (data.hasSearchBox())
                {
            %>
            <div class="input-control text" style="margin: 0">
                <input id="search-data" type="text" placeholder="<%=userProperties.getLanguage("search")%>"/>
                <button id="searchDataButton" class="button" onclick="searchData('search-data')"><span class="mif-search"></span></button>
            </div>
            <%
                }
            %>
        </div>
        <div id="journeyDiv">
            <table width="100%" class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="resultTable"></table>
            <br/><br/>
            <p id="journeyTableResult" style="left: inherit"></p>
        </div>
        <div id="compareDiv">
            <table width="100%">
                <tr>
                    <td width="50%">
                        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="compareTable1"></table>
                    </td>
                    <td width="50%" style="vertical-align: top">
                        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="compareTable2"></table>
                    </td>
                </tr>
                <tr>
                    <td width="50%">
                        <p id="journeyTableCompare1" style="left: inherit"></p>
                    </td>
                    <td width="50%">
                        <p id="journeyTableCompare2" style="left: inherit"></p>
                    </td>
                </tr>
            </table>
        </div>
    </body>
</html>
