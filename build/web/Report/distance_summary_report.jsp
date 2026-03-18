<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@page import="v3nity.std.biz.report.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    ListData data = new DistanceJourney();

    DataTreeView assetTreeView = new AssetTreeView(listProperties);

    if (!listProperties.getDataCache().isDataTreeViewCached(assetTreeView))
    {
        assetTreeView.loadData(listProperties);

        listProperties.getDataCache().cacheDataTreeView(assetTreeView);
    }
    else
    {
        assetTreeView = listProperties.getDataCache().getDataTreeViewCache(assetTreeView);
    }

    assetTreeView.setIdentifier("filter-asset");

    String columnList = "";

    String namespace = "distance_summary_report";

    try
    {
        columnList = "{ \"data\": \"1\", \"title\": \"Vehicle Number\", "
                     + "\"orderable\": true },{ \"data\": \"2\", \"title\": \"Vehicle Type\", \"orderable\": true },"
                     + "{ \"data\": \"3\", \"title\": \"Owner\", \"orderable\": true },"
                     + "{ \"data\": \"4\", \"title\": \"1\", \"orderable\": true },"
                     + "{ \"data\": \"5\", \"title\": \"2\", \"orderable\": true },"
                     + "{ \"data\": \"6\", \"title\": \"3\", \"orderable\": true },"
                     + "{ \"data\": \"7\", \"title\": \"4\", \"orderable\": true },"
                     + "{ \"data\": \"8\", \"title\": \"5\", \"orderable\": true },"
                     + "{ \"data\": \"9\", \"title\": \"6\", \"orderable\": true },"
                     + "{ \"data\": \"10\", \"title\": \"7\", \"orderable\": true },"
                     + "{ \"data\": \"11\", \"title\": \"8\", \"orderable\": true },"
                     + "{ \"data\": \"12\", \"title\": \" 9\", \"orderable\": true },"
                     + "{ \"data\": \"13\", \"title\": \"10\", \"orderable\": true },"
                     + "{ \"data\": \"14\", \"title\": \"11\", \"orderable\": true },"
                     + "{ \"data\": \"15\", \"title\": \"12\", \"orderable\": true },"
                     + "{ \"data\": \"16\", \"title\": \"13\", \"orderable\": true },"
                     + "{ \"data\": \"17\", \"title\": \"14\", \"orderable\": true },"
                     + "{ \"data\": \"18\", \"title\": \" 15\", \"orderable\": true },"
                     + "{ \"data\": \"19\", \"title\": \"16\", \"orderable\": true },"
                     + "{ \"data\": \"20\", \"title\": \"17\", \"orderable\": true },"
                     + "{ \"data\": \"21\", \"title\": \"18\", \"orderable\": true },"
                     + "{ \"data\": \"22\", \"title\": \"19\", \"orderable\": true },"
                     + "{ \"data\": \"23\", \"title\": \"20\", \"orderable\": true },"
                     + "{ \"data\": \"24\", \"title\": \"21\", \"orderable\": true },"
                     + "{ \"data\": \"25\", \"title\": \"22\", \"orderable\": true },"
                     + "{ \"data\": \"26\", \"title\": \"23\", \"orderable\": true },"
                     + "{ \"data\": \"27\", \"title\": \"24\", \"orderable\": true },"
                     + "{ \"data\": \"28\", \"title\": \"25\", \"orderable\": true },"
                     + "{ \"data\": \"29\", \"title\": \"26\", \"orderable\": true },"
                     + "{ \"data\": \"30\", \"title\": \"27\", \"orderable\": true },"
                     + "{ \"data\": \"31\", \"title\": \"28\", \"orderable\": true },"
                     + "{ \"data\": \"32\", \"title\": \"29\", \"orderable\": true },"
                     + "{ \"data\": \"33\", \"title\": \"30\", \"orderable\": true },"
                     + "{ \"data\": \"34\", \"title\": \"31\", \"orderable\": true },";

    }
    catch (Exception e)
    {
        e.printStackTrace();
    }
    finally
    {

    }

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today);

    String identifier = "filter-asset";

%>

<html>
    <head>
        <style>
            .inline {
                position: absolute;
                left: 500px;
                top: -20px;
                overflow-y: auto;
                height: 300px;
                width: 250px;
            }

        </style>
        <script type="text/javascript">

            var ids = "";
            var totalRecords = -1;
            var s = "";
            var requireOverallCount = true;
            var asset1 = [];
            var checkedValues;
            $(document).ready(function()
            {

                $("#result").hide();

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
                        iDisplayLength: 40,
                        paging: true,
                        ajax: {
                            url: 'DistanceJourneyController?type=system&action=get',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords;
                                d.requireOverallCount = requireOverallCount;
                                d.journeySummaryToDate = $("#dateTimePicker-history-start-date").val();
                                d.assetID = ids;
                                d.reload = $("#reload").val();
                                d.iDisplayLength = $('#page-length').val();
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

                tbl.on('xhr', function()
                {

                    // this will turn off the event...
                    tbl.off('draw.dt.dtSelect');
                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });



                $("#dateTimePicker-history-start-date").AnyTime_picker({format: "%m/%Y"});

                $("#downloadSummary").click(function()
                {
                    if ($("#dateTimePicker-history-start-date").val())
                    {


                        window.open("DistanceJourneyController?type=system&action=download&journeySummaryToDate=" + $("#dateTimePicker-history-start-date").val() + "&assetID=" + ids, "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
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
                var pageLength = $('#page-length').val();


                if (isInteger(pageLength))
                {

                    $("#reload").val("yes");
                    var table = $('#resultTable').DataTable();
                    table.ajax.reload(null, true);
                    table.page.len(pageLength).clear().draw();
                    $("#reload").val("no");
                    $("#result").hide();
                    $("#result").show();
                }
                else
                {
                    resetPageLength();
                }
            }

            function resetPageLength()
            {
                var table = $('#resultTable').DataTable();
                // var table = drawtable();
                // reset default value in page length control...
                $('#page-length').val(20);
                // reset search box...
                $('#search-data').val('');
                // reset table search...
                table.search('');
                // reset default page length...
                table.ajax.reload(null, false);
                $("#result").show();
            }

            function resetDate()
            {
                var resetDate = '<%=inputStartDate%>';
                $("#dateTimePicker-history-start-date").val(resetDate);
            }


            function <%=namespace%>_toggleSelect()
            {
                if ($('#<%=namespace%>-selectAll').hasClass('selected'))
                {
                    $('#<%=namespace%>-result-table').DataTable().button(1).trigger();
                    $('#<%=namespace%>-selectAll').removeClass('selected');
                }
                else
                {
                    $('#<%=namespace%>-result-table').DataTable().button(0).trigger();
                    $('#<%=namespace%>-selectAll').addClass('selected');
                }
            }

            function onTreeviewCheckboxClicked(treeview, parent, children, checked)
            {
                if (treeview === 'tree-view-filter-asset')
                {

                    ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

                }
            }

            function refreshPageLength()
            {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength))
                {
                    $("#reload").val("yes");
                    var table = $('#resultTable').DataTable();
                    table.ajax.reload(null, false);
                    table.page.len(pageLength).clear().draw();
                    $("#result").show();
                    $("#reload").val("no");
                }
                else
                {
                    resetPageLength();
                }
            }

        </script>
        <title>V3Nity</title>

    </head>
    <body>
        <div>
            <h1 class="text-light"><%=listProperties.getLanguage("distanceSummary")%></h1>
        </div>

        <input type="hidden" name="reload" id="reload">
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("SelectOrUnselect")%>" onclick="toggleSelect()" id="selectAll"><span class="mif-table"></span></button>
            </div>

            <div class="toolbar-section">
                <button class="toolbar-button" id ="downloadSummary" name="downloadSummary"><span class="text-light text-small">CSV</span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" onclick="refreshDataTable()"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset"  value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>
        </div>

        <br>
        <div class="grid">
            <div class="row cells4">
                <div class="cell" >
                    <h4 class="text-light align-left"><%=listProperties.getLanguage("dateRange")%></h4>

                    <div class="input-control text" data-role="input" >
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-start-date" type="text" placeholder="<%=listProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                </div>

                <div class="cell">
                    <h4 class="text-light align-left">Select Asset</h4>
                    <div id="chartFrame" class="treeview-control">
                        <%

                            assetTreeView.outputHTML(out, listProperties);
                        %>
                        <form>
                            <fieldset style="display:none;">
                                <input type="hidden" name="formset" id="formset">
                            </fieldset>
                        </form>

                    </div>
                </div>



            </div>
        </div>
        <br>
        <br><br><br><br><br><br><br><br><br>
        <div class="list-show-result-control">
            <div class="input-control text" style="margin: 0">
                <input id="page-length" type="text" value="20" maxlength="4">
                <div class="button-group">
                    <button class="button" id="refresh" name="refresh" value="" title="<%=listProperties.getLanguage("refresh")%>" onclick="refreshPageLength()"><span class="mif-loop2"></span></button>
                    <button class="button" id="resetForm" name="resetForm" value="" title="<%=listProperties.getLanguage("reset")%>" onclick="resetPageLength()"><span class="mif-undo"></span></button>
                </div>
            </div>
        </div>
        <div class="list-search-control">
            <%
                if (data.hasSearchBox())
                {
            %>

            <div class="input-control text" style="margin: 0">
                <input id="search-data" type="text" placeholder="<%=listProperties.getLanguage("search")%>"/>
                <button id="searchDataButton" class="button" onclick="searchData('search-data')"><span class="mif-search"></span></button>
            </div>

            <%}%>
        </div>

        <div id="result">
            <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="resultTable"></table>
        </div>
    </body>


</html>