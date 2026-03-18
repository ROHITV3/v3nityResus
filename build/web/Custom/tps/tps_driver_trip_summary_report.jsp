<%@page import="java.io.*"%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.cust.biz.tps.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%

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

                $("input[id^=input-filter]").on('focusout', filterRecord);
            });

            function dispose()
            {
                $("#input-start-date").AnyTime_noPicker();

                $("#input-end-date").AnyTime_noPicker();
            }

            function filter()
            {
                $.ajax({
                    url: "TpsDriverTripSummaryReportController?type=report&action=get",
                    type: "POST",
                    data: {
                        start_date: selectedDate('input-start-date'),
                        end_date: selectedDate('input-end-date')
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

                                appendCellText(row, record.from_date);

                                appendCellText(row, record.to_date);

                                appendCellText(row, record.controller);

                                appendCellText(row, record.label);

                                appendCellText(row, record.name);

                                appendCellText(row, record.nationality);

                                appendCellText(row, record.join_duration);

                                appendCellText(row, record.age);

                                appendCellText(row, record.description);

                                appendCellText(row, record.shift);

                                appendCellText(row, record.total_trip);

                                appendCellText(row, record.from_site);

                                appendCellText(row, record.to_site);

                                appendCellText(row, record.plan_work_hour);

                                appendCellText(row, record.actual_work_hour);

                                appendCellText(row, record.work_hour_diff);

                                appendCellText(row, record.total_income);

                                table.appendChild(row);
                            }
                        }
                    }
                });
            }

            $("#downloadCSV").click(function()
            {
                window.location.href = "TpsDriverTripSummaryReportController?type=report&action=get&start_date=" + selectedDate('input-start-date') + "&end_date=" + selectedDate('input-end-date') + "&format=csv";
            });

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

            function getFilterValues()
            {
                var option = document.getElementById("filtering-option");

                var th = option.getElementsByTagName("th");

                var values = [];

                for (var i = 0; i < th.length; i++)
                {
                    if (th[i].innerHTML !== '')
                    {
                        var input = th[i].getElementsByTagName("input");

                        if (input)
                        {
                            values.push(input[0].value.toUpperCase());
                        }
                    }
                    else
                    {
                        values.push('');
                    }
                }

                return values;
            }

            function filterRecord()
            {
                var tr, td, cell, txtValue;

                var table = document.getElementById("table-1");

                var tr = table.getElementsByTagName("tr");

                var filterValues = getFilterValues();

                for (var i = 0; i < tr.length; i++)
                {
                    tr[i].style.display = "";

                    td = tr[i].getElementsByTagName("td");

                    for (var j = 0; j < td.length; j++)
                    {
                        cell = td[j];

                        if (cell)
                        {
                            if (filterValues[j] !== '')
                            {
                                txtValue = cell.textContent || cell.innerText;

                                if (txtValue.toUpperCase().indexOf(filterValues[j]) > -1)
                                {
                                    tr[i].style.display = "";
                                }
                                else
                                {
                                    tr[i].style.display = "none";

                                    break;
                                }
                            }
                        }
                    }
                }
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
                font-size: 14px;
                overflow: hidden;
                padding: 12px 8px;
                word-break: normal;
            }

            .tg th {
                border-style: solid;
                border-width: 2px;
                font-size: 14px;
                font-weight: normal;
                overflow: hidden;
                padding: 12px 8px;
                word-break: normal;
            }

            .tg .tg-record {
                background-color: #ECE3E3;
                border-color: #ffffff;
                text-align: center;
                vertical-align: top;
            }

            .tg .tg-header {
                background-color: #b32323;
                border-color: #ffffff;
                color: #ffffff;
                font-weight: bold;
                text-align: center;
                vertical-align: top
            }

            .tg .tg-header-filter {
                border-color: #ffffff;
                color: #ffffff;
                font-weight: bold;
                text-align: center;
                vertical-align: top;
                padding: 0;
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
            <h1 class="text-light">Driver Trip Summary Report</h1>
            <h4 class="text-light">Computes the driver's trip summary and working time.</h4>
        </div>
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id ="downloadCSV" name="downloadCSV"><span class="text-light text-small">CSV</span></button>
            </div>
        </div>
        <div class="input-control text" data-role="input" style="width:72px">
            <span class="mif-calendar prepend-icon"></span>
            <input id="input-start-date" type="text" placeholder="From Date" value="" autocomplete="on">
            <button class="button helper-button clear"><span class="mif-cross"></span></button>
        </div>
        <div class="input-control text" data-role="input" style="width:72px">
            <span class="mif-calendar prepend-icon"></span>
            <input id="input-end-date" type="text" placeholder="To Date" value="" autocomplete="on">
            <button class="button helper-button clear"><span class="mif-cross"></span></button>
        </div>
        <button class="button" type="button" title="Apply Filter" onclick="filter()"><span class="mif-filter"></span></button>
        <table class="tg">
            <thead>
                <tr>
                    <th class="tg-header">No</th>
                    <th class="tg-header">From Date</th>
                    <th class="tg-header">To Date</th>
                    <th class="tg-header">Controller</th>
                    <th class="tg-header">Truck Number</th>
                    <th class="tg-header">Name</th>
                    <th class="tg-header">Nationality</th>
                    <th class="tg-header">Join Duration</th>
                    <th class="tg-header">Age</th>
                    <th class="tg-header">Model</th>
                    <th class="tg-header">Shift</th>
                    <th class="tg-header">Total Trips</th>
                    <th class="tg-header">From Site</th>
                    <th class="tg-header">To Site</th>
                    <th class="tg-header">Planned Working Hour</th>
                    <th class="tg-header">Total Working Hour</th>
                    <th class="tg-header">Working Hour Diff</th>
                    <th class="tg-header">Total Income ($)</th>
                </tr>
                <tr id='filtering-option'>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-controller' type="text" placeholder='Filter controller'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-truck' type="text" placeholder='Filter truck number'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-name' type="text" placeholder='Filter name'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-nationality' type="text" placeholder='Filter nationality'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-model' type="text" placeholder='Filter model'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-shift' type="text" placeholder='Filter shift'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-from-site' type="text" placeholder='Filter from site'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-to-site' type="text" placeholder='Filter to site'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter">
                        <div class="input-control text full-size" data-role="input">
                            <input id='input-filter-planned-working-hour' type="text" placeholder='Filter working hour'>
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter"></th>
                    <th class="tg-header-filter"></th>
                </tr>
            </thead>
            <tbody id="table-1">

            </tbody>
        </table>
    </body>
</html>