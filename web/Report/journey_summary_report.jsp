<%@page import="java.sql.Connection"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@page import="v3nity.std.biz.report.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%  UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    ListData data = new Journey();
    
    Connection connection = null;

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    String columnList = "";

    try
    {
        connection = userProperties.getConnection();
        
        dataHandler.setConnection(connection);

        columnList = "{ \"data\": \"1\", \"title\": \"Asset\", \"orderable\": true },{ \"data\": \"2\", \"title\": \"Distance[km]\", "
                     + "\"orderable\": true },{ \"data\": \"3\", \"title\": \"Ignition On Duration[HH:mm]\", \"orderable\": true },"
                     + "{ \"data\": \"4\", \"title\": \"Ignition Off Duration[HH:mm]\", \"orderable\": true },"
                     + "{ \"data\": \"5\", \"title\": \"Idling Duration[HH:mm]\", \"orderable\": true },"
                     + "{ \"data\": \"6\", \"title\": \"Longest Ignition On Duration[HH:mm]\", \"orderable\": true },"
                     + "{ \"data\": \"7\", \"title\": \"Longest Ignition Off Duration[HH:mm]\", \"orderable\": true },"
                     + "{ \"data\": \"8\", \"title\": \"First Ignition On\", \"orderable\": true },"
                     + "{ \"data\": \"9\", \"title\": \"Last Ignition On\", \"orderable\": true },"
                     + "{ \"data\": \"10\", \"title\": \"First Ignition Off\", \"orderable\": true },"
                     + "{ \"data\": \"11\", \"title\": \"Last Ignition Off\", \"orderable\": true },";

    }
    catch (Exception e)
    {

    }
    finally
    {
        userProperties.closeConnection(connection);
    }

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today);
%>

<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <script type="text/javascript">

            var totalRecords = -1;

            var requireOverallCount = true;

            $(document).ready(function()
            {

                var tbl = $("#resultTable").DataTable(
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
                        url: 'JourneySummaryController?type=system&action=get',
                        data: function(d)
                        {
                            d.totalRecords = totalRecords;
                            d.requireOverallCount = requireOverallCount;
                            d.date = $("#dateTimePicker-history-start-date").val();
                            d.day = $("#numDays").val();
                        },
                        beforeSend: function()
                        {
                            $('#button-refresh-data').prop("disabled", true);
                        },
                        complete: function()
                        {
                            $('#button-refresh-data').prop("disabled", false);
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

                $("#dateTimePicker-history-start-date").AnyTime_picker({format: "%d/%m/%Y"});

                $("#downloadSummary").click(function()
                {
                    if ($("#dateTimePicker-history-start-date").val())
                    {
                        window.open("JourneySummaryController?type=system&action=csv&date=" + $("#dateTimePicker-history-start-date").val() + "&day=" + $("#numDays").val(), "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                    }
                    else
                    {
                        alert("Please choose a date.");
                    }
                });

            });


            function dispose()
            {

                $("#dateTimePicker-history-start-date").AnyTime_noPicker();
            }

            function toggleSelect()
            {
                if ($('#selectAll').hasClass('selected'))
                {
                    $('#resultTable').DataTable().button(1).trigger();
                    $('#selectAll').removeClass('selected');
                }
                else
                {
                    $('#resultTable').DataTable().button(0).trigger();
                    $('#selectAll').addClass('selected');
                }
            }

            function searchData()
            {
                var searchText = $('#search-data').val();

                requireOverallCount = true;
                $("#reload").val("yes");
                $('#resultTable').DataTable().search(searchText).draw();
                $("#reload").val("no");
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
                    $("#reload").val("yes");
                    var table = $('#resultTable').DataTable();
                    table.ajax.reload(null, false);
                    table.page.len(pageLength).draw();

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
                // reset default value in page length control...
                $('#page-length').val(20);
                // reset search box...
                $('#search-data').val('');
                // reset table search...
                table.search('');
                // reset default page length...
                table.ajax.reload(null, false);

            }

            function resetDate()
            {
                var resetDate = '<%=inputStartDate%>';
                $("#dateTimePicker-history-start-date").val(resetDate);
            }


        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("journeySummary")%></h1>
        </div>
        <input type="hidden" name="reload" id="reload">
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id ="downloadSummary" name="downloadSummary"><span class="text-light text-small">CSV</span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="button-refresh-data" onclick="refreshDataTable()"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset"  value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>
        </div>
        <br>
        <div class="grid">
            <div class="row">
                <div class="cell">
                    Journey Summary Report for the past
                    <div class="input-control select" style="display: inline; bottom: 4px; margin: 4px;">
                        <select id="numDays" name="numDays" style="width: 48px">
                            <%
                                for (int i = 1; i <= 7; i++)
                                {
                            %>
                            <option value="<%=i%>"><%=i%></option>
                            <%
                                }
                            %>
                        </select>
                    </div>day(s) ending on
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-start-date" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                </div>
            </div>
        </div>
        <br>
        <div class="list-show-result-control">
            <div class="input-control text" style="margin: 0">
                <input id="page-length" type="text" value="20" maxlength="4">
                <div class="button-group">
                    <button class="button" id="button-refresh" name="refresh" value="" title="<%=userProperties.getLanguage("refresh")%>" onclick="refreshPageLength()"><span class="mif-loop2"></span></button>
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

            <%}%>
        </div>
        <div id="result">
            <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="resultTable"></table>
        </div>
    </body>
</html>
