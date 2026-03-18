
<%@page import="v3nity.std.biz.data.plan.JobCount"%>
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

    ListData data = new JobCount();

    String columnList = "";

    String namespace = "job_count";
    try
    {
        columnList = "{ \"data\": \"0\", \"title\": \"Staff\", "
                     + "\"orderable\": true },{ \"data\": \"1\", \"title\": \"Timestamp\", \"orderable\": true },"
        + "{ \"data\": \"2\", \"title\": \"Job Count\", \"orderable\": true },"
         + "{ \"data\": \"3\", \"title\": \"Customers\", \"orderable\": true },";

    }
    catch (Exception e)
    {
        e.printStackTrace();
    }
    finally
    {

    }

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today);

    String inputEndDate = new SimpleDateFormat("dd/MM/yyyy").format(today);
    inputEndDate = inputEndDate;
            
    String identifier = "filter-asset";

%>

<html>
    <head>
        <style>
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

                var tbl = $("#result-table").DataTable(
                    {
                        dom: 'rtip',
                        pageLength: 20,
                        deferRender: true,
                        deferLoading: 0,
                        orderClasses: false,
                        columns: [<%=columnList%>],
                        processing: true,
                        serverSide: false,
                        responsive: true,
                        iDisplayLength: 40,
                        paging: true,
                        ajax: {
                            url: 'JobCountController?type=system&action=get',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords;
                                d.requireOverallCount = requireOverallCount;
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
                            processing: 'Retrieving...<span class="mif-spinner2 mif-ani-spin"></span>',
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



                $("#dateTimePicker-history-start-date").AnyTime_picker({format: "%d/%m/%Y"});
                $("#dateTimePicker-history-end-date").AnyTime_picker({format: "%d/%m/%Y"});
                
                $("#result-table tbody ").on('click', 'button', function ()
                {
                        var data = tbl.row( $(this).parents('tr') ).data();
                        
                        var jobId = data[0];
                        showJobDetail(jobId);
                });
                


                $("#downloadSummary").click(function()
                {
                  

                        
                            var csv = new csvDownload('JobCountController?type=system&action=download&iDisplayLength=0', 'Job Count Report' );
                            csv.startDownload(1000, {customFilterQuery:''});
                       
            
                });
                
                
                
            });

            function dispose()
            {

                $("#dateTimePicker-history-start-date").AnyTime_noPicker();
                $("#dateTimePicker-history-end-date").AnyTime_noPicker();
            }

            function toggleSelect()
            {
                if ($('#selectAll').hasClass('selected'))
                {
                    $('#result-table').DataTable().button(1).trigger();
                    $('#selectAll').removeClass('selected');
                }
                else
                {
                    $('#result-table').DataTable().button(0).trigger();
                    $('#selectAll').addClass('selected');
                }
            }

            function searchData()
            {
                var searchText = $('#search-data').val();

                requireOverallCount = true;
                $("#reload").val("yes");
                $('#result-table').DataTable().search(searchText).draw();
                $("#reload").val("no");
            }

            function refreshDataTable()
            {
                requireOverallCount = true;
                var pageLength = $('#page-length').val();
                $("#trip_spin").show();

                if (isInteger(pageLength))
                {
                    if ($("#dateTimePicker-history-start-date").val() && $("#dateTimePicker-history-end-date").val())
                    {       
                        if(ids.length>0)
                        {
                           // requireOverallCount = true;
                            $("#tripsearch").attr('disabled', 'disabled');
                            $("#refresh").attr('disabled', 'disabled');
                            $('#search-data').val('');
                            refreshPageLength();
      
                        }
                        else
                        {
                             dialog('Search Failed', "Specify Staff", 'alert');
                        }
                    }
                    else
                    {
                        dialog('Search Failed', "Specify Date", 'alert');
                    }
                }
                else
                {
                    resetPageLength();
                }
                $("#trip_spin").hide();
            }

            function resetPageLength()
            { 
                var table = $('#result-table').DataTable();
          
                $('#page-length').val(20);
                
                $('#search-data').val('');
           
                 table.search('');
                
                table.ajax.reload(null, false);
                $("#result").show();

                            
            }

            function resetDate()
            {
                var resetDate = '<%=inputStartDate%>';
                $("#dateTimePicker-history-start-date").val(resetDate);
                
                var resetEnddate = '<%=inputEndDate%>';
                $("#dateTimePicker-history-end-date").val(resetDate);
                
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

           
            function refreshPageLength()
            {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength))
                {  
                       $("#trip_spin").show();
                  
                     
                     $("#tripsearch").attr('disabled', 'disabled');
                            
                        $("#refresh").attr('disabled', 'disabled');
                            
                        var table = $('#result-table').DataTable();
                            table.ajax.reload(null, false);
                            table.page.len(pageLength).draw();
                            $("#result-table").show();
                            $("#reload").val("no");
                    
                    
                   
                     $("#tripsearch").removeAttr('disabled');
                     $("#refresh").removeAttr('disabled');
                     $("#trip_spin").hide();
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
            <h1 class="text-light"><%=listProperties.getLanguage("jobCount")%></h1>
        </div>

        <input type="hidden" name="reload" id="reload">
        <div class="toolbar" style="margin: 16px 0">
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("SelectOrUnselect")%>" onclick="toggleSelect()" id="selectAll"><span class="mif-table"></span></button>
            </div>

            <div class="toolbar-section">
                <button class="toolbar-button" id ="downloadSummary" name="downloadSummary"><span class="text-light text-small">CSV</span></button>
            </div>
<!--            <div class="toolbar-section">
                <button class="toolbar-button" onclick="refreshDataTable()" id="tripsearch"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset"  value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>-->
        </div>

      
       
       
        <div class="list-show-result-control">
            <div class="input-control text" style="margin: 0">
                <input id="page-length" type="text" value="20" maxlength="4">
                <div class="button-group">
                    <button class="button" id="refresh" name="refresh" value="" title="<%=listProperties.getLanguage("refresh")%>" onclick="refreshPageLength()" ><span class="mif-loop2"></span></button>
                    <button class="button" id="resetForm" name="resetForm" value="" title="<%=listProperties.getLanguage("reset")%>" onclick="resetPageLength()"><span class="mif-undo"></span></button>
                </div>
            </div>
        </div>
        <div class="list-search-control">
            <%
                if (data.hasSearchBox())
                {
            %>

            <!--
            <div class="input-control text" style="margin: 0">
                <input id="search-data" type="text" placeholder="<%=listProperties.getLanguage("search")%>"/>
                <button id="searchDataButton" class="button" onclick="searchData('search-data')"><span class="mif-search"></span></button>
            </div>
            -->

            <%}%>
        </div>

<table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="result-table">
             <thead>

            </thead>
            <tbody>

            </tbody>
</table>


 <div data-role="dialog" id="job-div" class="medium" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Job Summary</h1>
               
                <div class="form-dialog-content" style="margin-top: 150px;">
                    <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="job-result-table">
                    <thead>

                   </thead>
                   <tbody>

                   </tbody>
                    </table>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-cancel-searching type="button" class="button" onclick="closeJobDetail()()">Close</button>
            </div>
 </div>

    </body>


</html>