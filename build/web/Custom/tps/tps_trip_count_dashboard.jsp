<%--
    Document   : tps_trip_count_dashboard
    Created on : 15 Feb, 2021, 2:51:36 PM
    Author     : Kevin
--%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.cust.biz.tps.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    TpsDataHandler dataHandler = new TpsDataHandler();

    Connection connection = null;

    JSONArray siteList = null;

    try
    {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

//        siteList = dataHandler.getSiteList(listProperties.getUser().getInt("customer_id"));
    }
    catch (Exception e)
    {

    }
    finally
    {
        listProperties.getDatabasePool().closeConnection(connection);
    }

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trip Count Dashboard</title>
        <script>

            var refreshTimer = null;

            $(document).ready(function()
            {
                $("#input-date-1").AnyTime_picker({format: "%d/%m/%Y"});

                $("#input-date-2").AnyTime_picker({format: "%d/%m/%Y"});
            });

            function dispose()
            {
                $("#input-date-1").AnyTime_noPicker();

                $("#input-date-2").AnyTime_noPicker();
            }

            function refresh()
            {
                var d1 = $('#input-date-1').val();

                var date1 = new Date(d1.substr(6, 4) + '-' + d1.substr(3, 2) + '-' + d1.substr(0, 2));

                var d2 = $('#input-date-2').val();

                var date2 = new Date(d2.substr(6, 4) + '-' + d2.substr(3, 2) + '-' + d2.substr(0, 2));

                if (isToday(date1))
                {
                    filter_1();
                }

                if (isToday(date2))
                {
                    filter_2();
                }
            }

            function filter_1()
            {
                $.ajax({
                    url: "TpsTripCountDashboardController?type=dashboard&action=byLoadingSite",
                    type: "POST",
                    data: {
                        start_date: selectedDate(1),
                        site_id: selectedSite(1),
                        shift_id: selectedShift(1)
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var table = document.getElementById('table-1');

                            table.innerHTML = '';

                            var total = {
                                loading_point: 0,
                                order_quantity: 0,
                                order_deployed: 0,
                                trip_quantity: 0,
                                trip_actual: 0
                            };

                            var data = response.data;

                            for (var i = 0; i < data.length; i++)
                            {
                                var record = data[i];

                                var row = document.createElement('tr');   // Create a <button> element

                                appendCellText(row, (i + 1));

                                appendCellText(row, record.project_site);

                                appendCellText(row, record.dump_site);

                                appendCellText(row, record.location);

                                appendCellText(row, record.loading_point);

                                total.loading_point += record.loading_point;

                                appendCellText(row, record.order_quantity);

                                total.order_quantity += record.order_quantity;

                                appendCellText(row, record.order_deployed);

                                total.order_deployed += record.order_deployed;

                                appendCellText(row, record.trip_quantity);

                                total.trip_quantity += record.trip_quantity;

                                appendCellText(row, record.trip_actual);

                                total.trip_actual += record.trip_actual;

                                table.appendChild(row);
                            }

                            document.getElementById('total-1-1').innerHTML = total.loading_point;

                            document.getElementById('total-1-2').innerHTML = total.order_quantity;

                            document.getElementById('total-1-3').innerHTML = total.order_deployed;

                            document.getElementById('total-1-4').innerHTML = total.trip_quantity;

                            document.getElementById('total-1-5').innerHTML = total.trip_actual;

                            if (refreshTimer !== null)
                            {
                                clearInterval(refreshTimer);
                            }

                            refreshTimer = setInterval(refresh, 120000);
                        }
                    }
                });
            }

            function filter_2()
            {
                $.ajax({
                    url: "TpsTripCountDashboardController?type=dashboard&action=byUnloadingSite",
                    type: "POST",
                    data: {
                        start_date: selectedDate(2),
                        site_id: selectedSite(2),
                        shift_id: selectedShift(2)
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var table = document.getElementById('table-2');

                            table.innerHTML = '';

                            var total = {
                                total_load: 0
                            };

                            var data = response.data;

                            for (var i = 0; i < data.length; i++)
                            {
                                var record = data[i];

                                var row = document.createElement('tr');   // Create a <button> element

                                appendCellText(row, (i + 1));

                                appendCellText(row, record.dump_site);

                                appendCellText(row, record.project_site);

                                appendCellText(row, record.trip_actual);

                                total.total_load += record.trip_actual;

                                table.appendChild(row);
                            }

                            document.getElementById('total-2-1').innerHTML = total.total_load;

                            if (refreshTimer !== null)
                            {
                                clearInterval(refreshTimer);
                            }

                            refreshTimer = setInterval(refresh, 120000);
                        }
                    }
                });
            }

            function appendCellText(row, text)
            {
                var cell = document.createElement('td');

                cell.classList.add('tg-record');

                cell.innerHTML = text;

                row.appendChild(cell);
            }

            function selectedDate(index)
            {
                var d = $('#input-date-' + index).val();

                if (d === '')
                {
                    return '';
                }

                return d.substr(6, 4) + d.substr(3, 2) + d.substr(0, 2);
            }

            function selectedShift(index)
            {
                var id = $('#select-shift-' + index).find('select :selected').val();

                if (id === '')
                {
                    id = 0;
                }

                return id;
            }

            function selectedSite(index)
            {
                var id = $('#select-site-' + index).find('select :selected').val();

                if (id === '')
                {
                    id = 0;
                }

                return id;
            }

            function isToday(date)
            {
                var today = new Date();

                return date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear();
            }

        </script>
        <style type="text/css">

            .tg {
                border-collapse: collapse;
                border-spacing: 0;
                width: 100%;
            }

            .tg td {
                border-style: solid;
                border-width: 2px;
                font-size: 16px;
                overflow: hidden;
                padding: 12px 8px;
                word-break: normal;
            }

            .tg th {
                border-style: solid;
                border-width: 2px;
                font-size: 16px;
                font-weight: normal;
                overflow: hidden;
                padding: 12px 8px;
                word-break: normal;
            }

            .tg .tg-record {
                background-color: #ECE3E3;
                border-color: #ffffff;
                text-align: center;
                vertical-align: top
            }

            .tg .tg-header {
                background-color: #b32323;
                border-color: #ffffff;
                color: #ffffff;
                font-weight: bold;
                text-align: center;
                vertical-align: top
            }

            .tg .tg-footer {
                background-color: #D2C8C8;
                border-color: #ffffff;
                color: #000;
                font-weight: bold;
                text-align: center;
                vertical-align: top
            }

            .tg .tg-footer:first-child {
                text-align: right;
            }

        </style>
    </head>
    <body>
        <div style="margin-bottom: 32px;">
            <h1 class="text-light">Trip Count Report</h1>
        </div>
        <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <h3 class="text-light">Project Site</h3>
                    <div class="input-control text" data-role="input" style="width:72px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="input-date-1" type="text" placeholder="Select Date" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div id="select-site-1" class="input-control" data-role="select">
                        <select>
                            <%  for (int i = 0; i < siteList.size(); i++)
                                {
                                    JSONObject site = (JSONObject) siteList.get(i);

                                    out.println("<option value=\"" + site.get("id") + "\">" + site.get("site") + "</option>");
                                }
                            %>
                        </select>
                    </div>
                    <div id="select-shift-1" class="input-control" data-role="select">
                        <select>
                            <option value="1">DAY</option>
                            <option value="2">NIGHT</option>
                        </select>
                    </div>
                    <button class="button" type="button" title="Apply Filter" onclick="filter_1()"><span class="mif-filter"></span></button>
                    <table class="tg">
                        <thead>
                            <tr>
                                <th class="tg-header" rowspan="2">No</th>
                                <th class="tg-header" rowspan="2">Project Site</th>
                                <th class="tg-header" rowspan="2">Dump Site</th>
                                <th class="tg-header" rowspan="2">Location</th>
                                <th class="tg-header" rowspan="2">Loading Points</th>
                                <th class="tg-header" colspan="2">Truck Orders</th>
                                <th class="tg-header" colspan="2">Total Trips</th>
                            </tr>
                            <tr>
                                <td class="tg-header">Order</td>
                                <td class="tg-header">Deploy</td>
                                <td class="tg-header">Plan</td>
                                <td class="tg-header">Actual</td>
                            </tr>
                        </thead>
                        <tfoot>
                            <tr>
                                <td class="tg-footer" colspan="4">TOTAL</td>
                                <td class="tg-footer" id="total-1-1">0</td>
                                <td class="tg-footer" id="total-1-2">0</td>
                                <td class="tg-footer" id="total-1-3">0</td>
                                <td class="tg-footer" id="total-1-4">0</td>
                                <td class="tg-footer" id="total-1-5">0</td>
                            </tr>
                        </tfoot>
                        <tbody id="table-1">

                        </tbody>
                    </table>
                </div>
                <div class="cell">
                    <h3 class="text-light">Show how many load disposal out</h3>
                    <div class="input-control text" data-role="input" style="width:72px">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="input-date-2" type="text" placeholder="Select Date" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div id="select-site-2" class="input-control" data-role="select">
                        <select>
                            <%  for (int i = 0; i < siteList.size(); i++)
                                {
                                    JSONObject site = (JSONObject) siteList.get(i);

                                    out.println("<option value=\"" + site.get("id") + "\">" + site.get("site") + "</option>");
                                }
                            %>
                        </select>
                    </div>
                    <div id="select-shift-2" class="input-control" data-role="select">
                        <select>
                            <option value="1">DAY</option>
                            <option value="2">NIGHT</option>
                        </select>
                    </div>
                    <button class="button" type="button" title="Apply Filter" onclick="filter_2()"><span class="mif-filter"></span></button>
                    <table class="tg">
                        <thead>
                            <tr>
                                <th class="tg-header">No</th>
                                <th class="tg-header">Dump Site</th>
                                <th class="tg-header">From Project Site</th>
                                <th class="tg-header">No of Load</th>
                            </tr>
                        </thead>
                        <tfoot>
                            <tr>
                                <td class="tg-footer" colspan="3">TOTAL</td>
                                <td class="tg-footer" id="total-2-1">0</td>
                            </tr>
                        </tfoot>
                        <tbody id="table-2">

                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </body>
</html>