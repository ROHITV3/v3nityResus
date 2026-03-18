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

    TpsSiteTicketingAppDataHandler dataHandler = new TpsSiteTicketingAppDataHandler();

    Connection connection = null;

    JSONArray assetList = null;

    try
    {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

        assetList = dataHandler.getAssetList(listProperties.getUser().getInt("customer_id"));
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

            });

            function dispose()
            {

            }

            function filter()
            {
                $.ajax({
                    url: "tps?type=diagnostic&action=getAssetEntryInfo",
                    type: "POST",
                    data: {
                        asset_id: selectedAsset()
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

                                appendCellText(row, '(' + record.asset_id + ')' + record.label);

                                appendCellText(row, '(' + record.driver_id + ')' + record.name);

                                appendCellText(row, record.last_login_dt);

                                appendCellText(row, '(' + record.site_id + ')' + record.site);

                                appendCellText(row, record.last_entered_dt);

                                appendCellText(row, '(' + record.site_geofence_id + ')' + record.site_geofence);

                                appendCellText(row, '(' + record.fms_entry_geofence_id + ')' + record.fms_entry_geofence);

                                appendCellText(row, record.fms_entry_timestamp);

                                appendCellText(row, record.fms_last_entry_time);

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

            function selectedAsset()
            {
                var id = $('#select-asset').find('select :selected').val();

                if (id === '')
                {
                    id = 0;
                }

                return id;
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
            <h1 class="text-light">Vehicle's Current Site Entry Info</h1>
            <h4 class="text-light">To provide visibility of the vehicle's current entry info to determine if it has entered the site using the smartphone location and FMS location.</h4>
        </div>
        <div id="select-asset" class="input-control" data-role="select">
            <select>
                <%  for (int i = 0; i < assetList.size(); i++)
                    {
                        JSONObject asset = (JSONObject) assetList.get(i);

                        out.println("<option value=\"" + asset.get("id") + "\">" + asset.get("label") + "</option>");
                    }
                %>
            </select>
        </div>
        <button class="button" type="button" title="Apply Filter" onclick="filter()"><span class="mif-filter"></span></button>
        <table class="tg">
            <thead>
                <tr>
                    <th class="tg-header">Vehicle</th>
                    <th class="tg-header">Driver Name</th>
                    <th class="tg-header">Driver Login Time</th>
                    <th class="tg-header">Site Entered</th>
                    <th class="tg-header">Site Entry Time</th>
                    <th class="tg-header">Site Assigned Geofence</th>
                    <th class="tg-header">FMS Geofence Entered</th>
                    <th class="tg-header">FMS Geofence Entry Time</th>
                    <th class="tg-header">FMS Geofence # Minutes</th>
                </tr>
            </thead>
            <tbody id="table-1">

            </tbody>
        </table>
    </body>
</html>