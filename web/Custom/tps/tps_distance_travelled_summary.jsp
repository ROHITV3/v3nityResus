<%@page import="v3nity.cust.biz.tps.data.TpsTicket"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.report.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%
  

    ListMetaData metaData = null;

   

    

    String columnList = "";

   

    try
    {

       

        columnList = "{ \"data\": \"1\", \"title\": \"Year\", \"orderable\": true },"
                 + "{ \"data\": \"2\", \"title\": \"Month\", \"orderable\": true },"
                      + "{ \"data\": \"3\", \"title\": \"Loading Site\", \"orderable\": true },"
                      + "{ \"data\": \"4\", \"title\": \"Unloading Site\", \"orderable\": true },"
                      + "{ \"data\": \"5\", \"title\": \"Total Closed Trips\", \"orderable\": true },"
                      + "{ \"data\": \"6\", \"title\": \"Minimum Distance Travelled(KM)\", \"orderable\": true },"
                      + "{ \"data\": \"7\", \"title\": \"Maximum Distance Travelled(KM)\", \"orderable\": true },"
                      + "{ \"data\": \"8\", \"title\": \"Average Distance Travelled(KM)\", \"orderable\": true }";
                     

     
    }
    catch (Exception e)
    {

    }
    finally
    {}
      


    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String selectDate = dateTimeFormatter.format(today);

    




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
            
            var dj = "";
            
            

            $(document).ready(function()
            {
                
                
                var my_csv = new csvDownload('TpsReportController?type=tps&action=site_to_site_distance_travelled_csv', 'V3NITY');

                
                $('#driverFilter').append("<option value='/'>--Select All--</option>");
                $.ajax({
                    type: 'POST',
                    url: 'TpsReportController',
                    data: {
                        action: 'driverFilter',
                        type: 'filter'
                    },
                    success: function (data)
                    {
                        var dataofallaset = data.dataValue;

                        for (var i = 0; i < dataofallaset.length; i++)
                        {
                            $('#driverFilter').append("<option value='" + dataofallaset[i] + "'>" + dataofallaset[i] + "</option>");
                        }

                    }
                });
             
                
                $('#assetFilter').append("<option value='/'>--Select All</option>");
                $.ajax({
                    type: 'POST',
                    url: 'TpsReportController',
                    data: {
                        action: 'assetFilter',
                        type: 'filter'
                    },
                    success: function (data)
                    {
                        var dataofallaset = data.dataValue;

                        for (var i = 0; i < dataofallaset.length; i++)
                        {
                            $('#assetFilter').append("<option value='" + dataofallaset[i] + "'>" + dataofallaset[i] + "</option>");
                        }

                    }
                });
                
                
                $('#shiftFilter').append("<option value='/'>--Select All--</option>");
                $.ajax({
                    type: 'POST',
                    url: 'TpsReportController',
                    data: {
                        action: 'shiftFilter',
                        type: 'filter'
                    },
                    success: function (data)
                    {
                        var dataofallaset = data.dataValue;

                        for (var i = 0; i < dataofallaset.length; i++)
                        {
                            $('#shiftFilter').append("<option value='" + dataofallaset[i] + "'>" + dataofallaset[i] + "</option>");
                        }

                    }
                });
                
                $('#loadingSiteFilter').append("<option value='/'>--Select All--</option>");
                $.ajax({
                    type: 'POST',
                    url: 'TpsReportController',
                    data: {
                        action: 'loadingSiteFilter',
                        type: 'filter'
                    },
                    success: function (data)
                    {
                        var dataofallaset = data.dataValue;

                        for (var i = 0; i < dataofallaset.length; i++)
                        {
                            $('#loadingSiteFilter').append("<option value='" + dataofallaset[i] + "'>" + dataofallaset[i] + "</option>");
                        }

                    }
                });
                
                $('#unloadingSiteFilter').append("<option value='/'>--Select All--</option>");
                $.ajax({
                    type: 'POST',
                    url: 'TpsReportController',
                    data: {
                        action: 'loadingSiteFilter',
                        type: 'filter'
                    },
                    success: function (data)
                    {
                        var dataofallaset = data.dataValue;

                        for (var i = 0; i < dataofallaset.length; i++)
                        {
                            $('#unloadingSiteFilter').append("<option value='" + dataofallaset[i] + "'>" + dataofallaset[i] + "</option>");
                        }

                    }
                });


                
                
                drawTable();
               
              
              $("#dateTimePicker-mydate").AnyTime_picker({format: "%m/%Y"});
//              $("#dateTimePicker-mydate2").AnyTime_picker({format: "%m/%Y"});

                

                $("#downloadCSV").click(function()
                {

                    debugger;
//                    $('#driverFilter').val();
                    
                    my_csv.startDownload(20000, {customFilterQuery: null, visibleColumnIndexes: null, monthyear: $('#dateTimePicker-mydate').val(), loadingSite: $('#loadingSiteFilter').val(), unloadingSite: $('#unloadingSiteFilter').val()
});
          
                    });
                    
                    
            
            });
            
            
            function drawTable()
            {
                 tbl = $("#resultTable").DataTable(
                    {
                        dom: 'tip',
                        pageLength: 20,
                        deferRender: true,
                        deferLoading: 0,
                        orderClasses: false,
                        columns: [<%=columnList%>],
                        autoWidth: false,
                        serverSide: false,
                        processing: true,
                        responsive: true,
                        paging: true,
                        ajax: {
                            url: 'TpsReportController?type=tps&action=site_to_site_distance_travelled',
                            data: function(d)
                            {
                               // d.driverId1 = $("#driverId1").val();
                               // d.driverId2 = $("#driverId2").val();
                               d.monthyear = $('#dateTimePicker-mydate').val();
                               d.loadingSite = $('#loadingSiteFilter').val();
                               d.unloadingSite = $('#unloadingSiteFilter').val();

//                               d.toDate = $('#dateTimePicker-mydate2').val();
                                
                            },
                            dataSrc: function(json)
                            {
                                if (json.result === false && json.warning !== undefined)
                                {
                                    dialog('Error', json.warning, 'alert');

                                    $('.toolbar-button').prop("disabled", false);
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
                            infoFiltered:"",
                            emptyTable: 'No data available',
                            loadingRecords: 'Loading...',
                            processing: 'Retrieving...',
                            zeroRecords: 'No data available',
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

            }
      
            

            function dispose()
            {
                $("#dateTimePicker-mydate").AnyTime_noPicker();
//                $("#dateTimePicker-mydate2").AnyTime_noPicker();
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
                    $("#reload").val("yes");
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
                table.page.len(20).draw();
            }
            
            
            
            function searchData()
            {
                var searchText = $('#search-data').val();
                
                requireOverallCount = true;

                $('#resultTable').DataTable().search(searchText).draw();
            }
           

           function searchData2()
            {
                var searchText = $('#search-data').val();
                
                var loadingSite = $('#loadingSiteFilter').val();
                
                var unloadingSite = $('#unloadingSiteFilter').val();
                
                var shiftName = $('#shiftFilter').val();
                
                
                if($('#dateTimePicker-mydate').val() !== "")
                {
                tbl.clear().destroy();
                
                drawTable();
                
                
                
                }
                else
                {
                    dialog('Failed','Please Select Year and Month','alert');
                }
                
                

//                requireOverallCount = true;
//
//                $('#resultTable').DataTable().search(searchText).draw();
            }

            

            function customFilter()
            {
                
                $("#journeyDiv").show();

                refreshDataTable();
            }

           
            
            
            
            
            

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light">Site to Site Distance Travelled Report</h1>
        </div>
        <input type="hidden" name="reload" id="reload">
        <br/>
        <div class="grid">
            <div class="toolbar">
                        <div class="toolbar-section">
                            <button class="toolbar-button" id ="downloadCSV" name="downloadCSV"><span class="text-light text-small">CSV</span></button>
                        </div>
                        <div class="toolbar-section">
                       <!--     <button class="toolbar-button" onclick="generateCompareTable()"><span class="mif-search"></span></button>
                       -->
                             <button class="toolbar-button" onclick="searchData2()"><span class="mif-search"></span></button>
                       
                        </div>
            </div>
             </div>
        
            <br/>
            
            
            
            <div class="grid filter-menu">
            <div class="row cell2">
            <div class="cell" style="width:250px;display:inline-table;" >
                <h4 class="text-light">Year and Month<span style="color: red; font-weight: bold"> *</span></h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-mydate" type="text" placeholder="Select Start Date" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div><br>
<!--                    <span >&nbsp;-</span><br>-->
<!--                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-mydate2" type="text" placeholder="Select End Date" value="" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>-->
            </div>
                
                <div class="cell" style="width:250px;display:inline-table;" >
                    <h4 class="text-light">Loading Site</h4>
                    <div class="input-control text" data-role="input">
                        <%
                            out.write("<div class=\"input-control text\" style=\"width: 200px;\">");
                            out.write("<select name = \" Select Loading Site\" id=\"loadingSiteFilter\">");
                            out.write("</select>");
                            out.write("</div>");
//                            out.write("</div>");

                        %>
                   </div>
                </div>
                
                
                <div class="cell" style="width:250px;display:inline-table;" >
                    <h4 class="text-light">Unloading Site</h4>
                    <div class="input-control text" data-role="input">
                        <%
                            out.write("<div class=\"input-control text\" style=\"width: 200px;\">");
                            out.write("<select name = \" Select Unloading Site\" id=\"unloadingSiteFilter\">");
                            out.write("</select>");
                            out.write("</div>");
//                            out.write("</div>");

                        %>
                   </div>
                </div>
                   
                   

            </div>
    </div>
      
     
        <div class="grid filter-menu">
            <div class="row cells2">
                <div class="cell">
        <div class="list-show-result-control">
            <div class="input-control text" style="margin: 0">
                <input id="page-length" type="text" value="20" maxlength="4">
                <div class="button-group">
                    <button class="button" id="refresh" name="refresh" value="" title="" onclick="refreshPageLength()"><span class="mif-loop2"></span></button>
                    <button class="button" id="resetForm" name="resetForm" value="" title="" onclick="resetPageLength()" style="display: none;"><span class="mif-undo"></span></button>
                </div>
            </div>
        </div>
                </div>
                <div class="cell">
        <div class="list-search-control place-right">
            <%
            //    if (data.hasSearchBox())
                {
            %>
            <div class="input-control text full-size" style="margin: 0">
                <input id="search-data" type="text" placeholder="Search Keyword"/>
                <button id="searchDataButton" class="button" onclick="searchData('search-data')"><span class="mif-search"></span></button>
            </div>
            <%
                }
            %>
        </div>
                </div>
            </div>
    </div>
        <div id="journeyDiv">
            <table width="100%" class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="resultTable"></table>
            <br/><br/>
            
        </div>
       
    </body>
</html>
