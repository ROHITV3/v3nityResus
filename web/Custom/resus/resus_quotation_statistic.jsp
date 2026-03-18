<%@page import="v3nity.std.biz.data.common.ListServices"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="v3nity.std.core.data.list.ListDataHandler"%>
<%@page import="java.sql.Connection"%>
<%@page import="v3nity.std.biz.data.common.UserProperties"%>
<%

%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
        <script type="text/javascript">

            var columns = [
                {data: '1', title: 'Month', orderable: true},
                {data: '2', title: 'Approved', orderable: true},
                {data: '3', title: 'Pending', orderable: true},
                {data: '4', title: 'Rejected', orderable: true},
            ];

            $(document).ready(function()
            {
                var tbl = $("#quotation-statistic-table").DataTable(
                    {
                        dom: 'tip',
                        pageLength: 20,
                        orderClasses: false,
                        columns: columns,
                        serverSide: false,
                        responsive: true,
                        paging: true,
                        ajax: {
                            url: 'ResusQuotationStatisticController?type=view&action=get',
                            data: function(d)
                            {
                                d.month = $("#dt-month").val();
                                d.location = $("#location-dropdown").val();
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

            });

            function dispose()
            {
                $("#dt-month").AnyTime_noPicker();
            }

            function refreshDataTable()
            {
                $('#quotation-statistic-table').DataTable().ajax.reload(null, false);
            }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light">Quotation Statistic</h1>
        </div>
        <input type="hidden" name="reload" id="reload">
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="button-refresh-data" onclick="refreshDataTable()"><span class="mif-search"></span></button>
            </div>
        </div>
        <div class="grid">
            <div class="row cells4">
                <div class="cell">
                    <label>Select Month</label><br>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dt-month" class="start" type="text" placeholder="Month/Year" value="">
                        <button class="button helper-button clear">
                            <span class="mif-cross"></span></button>
                    </div>
                </div>
                <script>
                    $("#dt-month").AnyTime_picker({format: "%m/%Y"});
                </script>
            </div>
            <div id="result">
                <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="quotation-statistic-table"></table>
            </div>
        </div>
    </body>
</html>

