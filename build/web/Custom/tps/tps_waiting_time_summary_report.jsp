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

        siteList = dataHandler.getSiteList(listProperties.getUser().getInt("customer_id"));
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

            $(document).ready(function()
            {
                $("#input-start-date").AnyTime_picker({format: "%d/%m/%Y"});

                $("#input-end-date").AnyTime_picker({format: "%d/%m/%Y"});
            });

            function dispose()
            {
                $("#input-start-date").AnyTime_noPicker();

                $("#input-end-date").AnyTime_noPicker();
            }

            function filter()
            {
                $.ajax({
                    url: "TpsWaitingTimeSummaryReportController?type=report&action=get",
                    type: "POST",
                    data: {
                        start_date: selectedDate('input-start-date'),
                        end_date: selectedDate('input-end-date'),
                        start_hour: selectedHour('select-start-hour'),
                        end_hour: selectedHour('select-end-hour'),
                        site_id: selectedSite()
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            var table = document.getElementById('table-1');

                            table.innerHTML = '';

                            var data = response.data;

                            for (var i = 0; i < data.length; i++)
                            {
                                var record = data[i];

                                var row = document.createElement('tr');

                                appendCellText(row, (i + 1));

                                appendCellText(row, record.date);

                                appendCellText(row, record.time);

                                appendCellText(row, record.site);

                                appendCellText(row, record.trip_count);

                                appendCellText(row, record.shortest_time);

                                appendCellText(row, record.longest_time);

                                appendCellText(row, record.average_time);

                                table.appendChild(row);
                            }
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

            function selectedDate(id)
            {
                var d = $('#' + id).val();

                if (d === '')
                {
                    return '';
                }

                return d.substr(6, 4) + d.substr(3, 2) + d.substr(0, 2);
            }

            function selectedSite()
            {
                var id = $('#select-site').find('select :selected').val();

                if (id === '')
                {
                    id = 0;
                }

                return id;
            }

            function selectedHour(id)
            {
                var id = $('#' + id).find('select :selected').val();

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
            <h1 class="text-light">Waiting Time Summary Report</h1>
            <h4 class="text-light">Computes the average time spent by vehicles waiting at the site.</h4>
        </div>
        <div class="input-control text" data-role="input" style="width:72px">
            <span class="mif-calendar prepend-icon"></span>
            <input id="input-start-date" type="text" placeholder="Select Start Date" value="" autocomplete="on">
            <button class="button helper-button clear"><span class="mif-cross"></span></button>
        </div>
        <div class="input-control text" data-role="input" style="width:72px">
            <span class="mif-calendar prepend-icon"></span>
            <input id="input-end-date" type="text" placeholder="Select End Date" value="" autocomplete="on">
            <button class="button helper-button clear"><span class="mif-cross"></span></button>
        </div>
        <div id="select-start-hour" class="input-control" data-role="select">
            <select>
                <%  for (int i = 0; i < 24; i++)
                    {
                        out.println("<option value=\"" + i + "\">" + String.format("%02d:00", i) + "</option>");
                    }
                %>
            </select>
        </div>
        <div id="select-end-hour" class="input-control" data-role="select">
            <select>
                <%  for (int i = 0; i < 24; i++)
                    {
                        out.println("<option value=\"" + i + "\">" + String.format("%02d:00", (i + 1) % 24) + "</option>");
                    }
                %>
            </select>
        </div>
        <div id="select-site" class="input-control" data-role="select">
            <select>
                <%  for (int i = 0; i < siteList.size(); i++)
                    {
                        JSONObject site = (JSONObject) siteList.get(i);

                        out.println("<option value=\"" + site.get("id") + "\">" + site.get("site") + "</option>");
                    }
                %>
            </select>
        </div>
        <button class="button" type="button" title="Apply Filter" onclick="filter()"><span class="mif-filter"></span></button>
        <table class="tg">
            <thead>
                <tr>
                    <th class="tg-header">No</th>
                    <th class="tg-header">Date</th>
                    <th class="tg-header">Time</th>
                    <th class="tg-header">Site</th>
                    <th class="tg-header">Trip Count</th>
                    <th class="tg-header">Shortest Time (mins)</th>
                    <th class="tg-header">Longest Time (mins)</th>
                    <th class="tg-header">Average Time (mins)</th>
                </tr>
            </thead>
            <tbody id="table-1">

            </tbody>
        </table>
    </body>
</html>