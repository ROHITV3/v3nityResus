<%-- 
    Document   : client_login.jsp
    Created on : 8 May, 2019, 5:00:14 PM
    Author     : Ankit Rajput 
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="true"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="sun.misc.BASE64Encoder"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.report.*"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
    int id = userProperties.getId();
    String filter = request.getParameter("filter");
    String foreignKey = request.getParameter("foreignKey");
    String namespace = "clientlogin_details";
    ListData data = new ClientLoginDetails();

    ListDataHandler listdataHandler = new ListDataHandler(new ListServices());

    ListData user = new User();

    if (filter != null && foreignKey != null) {
        if (!foreignKey.equals("")) {
            data.setInt(foreignKey, Integer.parseInt(filter));
        }
    } else {
        filter = "";

        foreignKey = "";
    }

    //Map<String, String> languageMap = LanguageMap.request(user);
    /*
     * check user access...
     */
    int operations = userProperties.getOperations(data.getResourceId());

    if (!userProperties.canAccess(operations, Operation.VIEW)) {
        return;
    }

    Connection con = null;

    ExtendDataHandler dataHandler = new ExtendDataHandler();
    con = Database.getConnection();

    
    DataTreeView feedbackdriverTreeView = new FeedbackDriverTreeView(userProperties);
    
    feedbackdriverTreeView.setIdentifier("filter-driver");

    feedbackdriverTreeView.loadData(userProperties);
    


    ListMetaData metaData = null;
    ListMetaData metaDataSubType = null;

    List<MetaData> metaDataList = data.getMetaDataList();
    int metaListSize = metaDataList.size();

    String columnList = "";
    String columnEditableArray = "";
    int columnIndex = 0;

    ListForm listForm = new ListForm();
    ListFilter listFilter = new ListFilter(19);

    int pageLength = data.getPageLength();
    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");
    java.util.Date today = new java.util.Date();
    String inputStartDate = dateTimeFormatter.format(today) + " 00:00:00";
    String inputEndDate = dateTimeFormatter.format(today) + " 23:59:59";

    try {
        for (int i = 0; i < metaListSize; i++) {
            metaData = (ListMetaData) metaDataList.get(i);

            // construct the column definition for the data table...
            if (metaData.getViewable()) {
                if (columnList.length() > 0) {
                    columnList += ",";
                }

                columnList += "{ \"data\": \"" + i + "\", \"title\": \"" + userProperties.getLanguage(metaData.getDisplayName()) + "\", \"name\": \"" + metaData.getFieldName() + "\", \"orderable\": " + metaData.getOrderable() + " }";

                if (metaData.getCellEditable()) {
                    if (!columnEditableArray.equals("")) {
                        columnEditableArray += ",";
                    }

                    columnEditableArray += columnIndex;
                }

                columnIndex++;
            }

            // currently only allow one sub-type list...
            if (metaData.getType() == DataType.LIST && metaDataSubType == null) {
                metaDataSubType = metaData;
            }
        }

        // create the edit column...
//        columnList += ",{ \"data\": \"" + "editButton" + "\", \"title\": \"" + userProperties.getLanguage("edit") + "\", \"orderable\": false, \"width\": \"64px\" }";
        columnEditableArray = "[" + columnEditableArray + "]";
    } catch (Exception e) {
        e.printStackTrace();
    } finally {

    }


%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <style>

            .inline { 

                left: 500px;
                top: -20px;
                overflow-y: auto;
                height: 200px;
                width: 300px;


            }
            .inline2 { 
                position: absolute;
                overflow-y: auto;
                height: 200px;
                width: 200px;
                border-left:  1px #5b5b5b inset;
                border-right: 1px #5b5b5b inset;


            }

        </style>
        <script type="text/javascript">

            var ids = "";
            var status = "";
            var <%=namespace%>_totalRecords = - 1;
            var <%=namespace%>_requireOverallCount = true;
            var <%=namespace%>_listForm;
            var <%=namespace%>_customFilterQuery = [];
            $(document).ready(function () {

            $("#dateTimePicker-history-start-date").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
            $("#dateTimePicker-history-end-date").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
            if (typeof <%=namespace%>ListForm !== 'undefined' && typeof <%=namespace%>ListForm === 'function')
            {
            <%=namespace%>_listForm = new <%=namespace%>ListForm('<%=namespace%>-specific-filter');
                } else
                {
            <%=namespace%>_listForm = new ListForm('<%=namespace%>-specific-filter');
                }

                var tbl = $('#<%=namespace%>-result-table').DataTable(
                {
                dom: 'rtip',
                        pageLength: <%=pageLength%>,
            <%
                                    if (!data.hasInitialData()) {
            %>
                deferLoading: 0,
            <%
                                    }
            %>
                autoWidth: false,
                        deferRender: true,
                        orderClasses: false,
                        columns: [<%=columnList%>],
                        processing: true,
                        serverSide: true,
                        responsive: true,
                        ajax: {
                        url: 'ClientLoginController?format=json&action=view',
                                type: 'POST',
                                data: function (d) {
                                d.reportdate = $("#dateTimePicker-history-start-date").val();
                                d.reportEndDate = $("#dateTimePicker-history-end-date").val();
                                d.status = status;
                                d.assetID = ids;
                                d.totalRecords = <%=namespace%>_totalRecords;
                                d.requireOverallCount = <%=namespace%>_requireOverallCount;
                                d.customFilterQuery = JSON.stringify(<%=namespace%>_customFilterQuery);
                                d.filter = '<%=filter%>';
                                d.foreignKey = '<%=foreignKey%>';
                                d.visibleColumnIndexes = <%=namespace%>_listForm.getColumns();
                                },
                                error: function (xhr, error, thrown) {
                                dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                                },
                                dataSrc: function (json) {

                                var data = json;
                                if (data.expired === undefined)
                                {
                                if (data.result === true) {

                                if (data.visibleColumns !== undefined)
                                {
                                showColumns(tbl, data.visibleColumns);
                                }

                                if (data.data.length === 0)
                                {
                                dialog('No Record', 'No record found', 'alert');
                                }
                                }
                                else
                                {
                                dialog('Failed', data.text, 'alert');
                                }
                                }
                                else
                                {
                                $('#main').load('../Common/expired.jsp');
                                // we need this for the data-table to read...
                                json.data = [];
                                }

                                return json.data;
                                    }
                        },
                        drawCallback: function (settings) {

                        if (settings.json === undefined)
                        {
                        return;
                        }

                        /*
                         * throws error message...
                         */
                        if (settings.json.errorText !== undefined)
                        {
                        dialog('Error', settings.json.errorText, 'alert');
                        return;
                        }

                        /* do this so that the total records will not be retrieved from the database again...
                         * greatly increase performance towards retrieving data from datatable...
                         */
                        if (tbl !== undefined)
                        {
                        if (tbl.page.info().recordsTotal === 0 && <%=namespace%>_totalRecords !== - 1)
                        {

                        }

            <%=namespace%>_totalRecords = tbl.page.info().recordsTotal;
            <%=namespace%>_requireOverallCount = false;
                        }
                        },
                        headerCallback: function(thead, data, start, end, display) {

                        },
                        createdRow: function (row, data, index) {

                        },
                        select: {
            <%=(data.hasSelection()) ? "style: 'multi'" : ""%>
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
               
                //     every ajax call, turn off the draw event otherwise,
                //     all rows will be selected from the table upon selecting buttons within the table.
                //     there is something wrong with the datatable with server side processing.
                tbl.on('xhr', function () {

                // this will turn off the event...
                tbl.off('draw.dt.dtSelect');
                // whenever there is a ajax call, unselect all the items...
                $('#<%=namespace%>-selectAll').removeClass('selected');
                });
                $('#<%=namespace%>-result-table tbody tr td:nth-child(7)').click(function () {
                // var data = table.row( $(this).parents('tr') ).data();

                });
                 $("#downloadSummary").click(function ()
                {
               
                window.open("ClientLoginController?format=csv&action=download&reportdate=" + $("#dateTimePicker-history-start-date").val() + "&reportEndDate=" + $("#dateTimePicker-history-end-date").val()  + "&assetID=" + ids, "toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
                });
                });
                

           
                function dispose()
                {
                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function (index, elem) {
                $(elem).AnyTime_noPicker();
                });
                }

                function <%=namespace%>_toggleSelect()
                {
                if ($('#<%=namespace%>-selectAll').hasClass('selected'))
                {
                $('#<%=namespace%>-result-table').DataTable().button(1).trigger();
                $('#<%=namespace%>-selectAll').removeClass('selected');
                } else
                {
                $('#<%=namespace%>-result-table').DataTable().button(0).trigger();
                $('#<%=namespace%>-selectAll').addClass('selected');
                }
                }

                function <%=namespace%>_searchData()
                {
                var searchText = $('#<%=namespace%>-search-data').val();
            <%=namespace%>_requireOverallCount = true;
                $('#<%=namespace%>-result-table').DataTable().search(searchText).draw();
                }

                function <%=namespace%>_refreshDataTable()
                {
            <%=namespace%>_requireOverallCount = true;
            <%=namespace%>_refreshPageLength();
                }

                function <%=namespace%>_refreshPageLength()
                {
                status = "";
                $.each($("input[name='stat']:checked"), function(){
                status += ($(this).val());
                status += ",";
                });
                var pageLength = $('#<%=namespace%>-page-length').val();
                if (isInteger(pageLength))
                {
                var table = $('#<%=namespace%>-result-table').DataTable();
                table.page.len(pageLength).draw();
                } else
                {
            <%=namespace%>_resetPageLength();
                }
                }

                function <%=namespace%>_resetPageLength()
                {
                var table = $('#<%=namespace%>-result-table').DataTable();
                // reset default value in page length control...
                $('#<%=namespace%>-page-length').val(<%=pageLength%>);
                // reset search box...
                $('#<%=namespace%>-search-data').val('');
                // reset table search...
                table.search('');
                // reset default page length...
                table.page.len(<%=pageLength%>).draw();
                }

              

                function getPrefix()
                {
                var ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');
                if (ids !== '')
                {
                if (ids.indexOf(',') === - 1)    // if no ',' it means only 1 id...
                {
                var node = $('#tree-view-filter-driver').find('[data-filter-driver-id=' + ids + ']:first-child');
                var text = node.children('span')[0].innerHTML;
                return text;
                } else
                {
                return ids.split(',').length + 'assets';
                }
                } else
                {
                return '';
                }
                }

                function <%=namespace%>_loadSubType(id)
                {

            <%
                if (metaDataSubType != null) {
                    String subType = metaDataSubType.getForeignListClass().getSimpleName();
                    String subTypeForeignKey = metaDataSubType.getForeignKeyName();
            %>
                $('#<%=namespace%>-sub-type').load('../common/ClientLoginDetails.jsp?filter=' + id + '&foreignKey=<%=subTypeForeignKey%>');
            <%
                }
            %>
                }


                function <%=namespace%>_customFilter()
                {
                if (<%=namespace%>_listForm.filter() !== undefined)
                {
            <%=namespace%>_customFilterQuery = <%=namespace%>_listForm.filter();
                }

            <%=namespace%>_refreshDataTable();
                }

                function showColumns(table, ids)
                {
                table.columns().visible(true);
                for (var i = 0; i < ids.length; i++)
                {
                table.column(i).visible(false);
                }
                }
                function onTreeviewCheckboxClicked(treeview, parent, children, checked)
                {
                if (treeview === 'tree-view-filter-driver') {

                ids = getTreeId('tree-view-filter-driver', 'filter-driver-id');
                
              //  alert(ids);
                }

                }

        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("clientlogindetails")%></h1>
        </div>
        <div class="toolbar" style="margin: 16px 0">
            <div class="toolbar-section">
                <button class="toolbar-button" onclick="<%=namespace%>_refreshDataTable()"><span class="mif-search"></span></button>
            </div>
	    <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=userProperties.getLanguage("downloadCSV")%>" id="downloadSummary"><span class="text-light text-small">CSV</span></button>
            </div>
        </div>
        <br>
        <div class="grid" >
            <div class="row cells4">
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("dateRange")%></h4>
                    <div class="input-control text" data-role="input">

                        <span class="mif-calendar prepend-icon"></span>

                        <input id="dateTimePicker-history-start-date" type="text" placeholder="<%=userProperties.getLanguage("clientStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control text" data-role="input">

                        <span class="mif-calendar prepend-icon"></span>

                        <input id="dateTimePicker-history-end-date" type="text" placeholder="<%=userProperties.getLanguage("clientEndDate")%>" value="<%=inputEndDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>  
                </div>
		    <div class="cell" >   
                    <h4 class="text-light align-left">Select Client</h4>
                    <div id="chartFrame" name= "chartFrame" style="height: 200px;" class="treeview-control">
                        <%

                            feedbackdriverTreeView.outputHTML(out, userProperties);

                        %>

                    </div>   
                </div>
            </div>

        </div>

        <%
            if (data.hasCustomFilterButton()) {
        %>

        <div class="toolbar-section">
            <button class="toolbar-button" type="button" onclick="<%=namespace%>_customFilter()"><span class="mif-search"></span></button>
        </div>

        <%
            }
        %>

        <%
            if (data instanceof IDeviceSynchronizable) {
        %>
        <div class="toolbar-section">
            <button class="toolbar-button" type="button" title="<%=userProperties.getLanguage("deviceSync")%>" onclick="<%=namespace%>_deviceSync()" id=<%=namespace%>-button-deviceSync><span class="mif-embed"></span></button>
        </div>
        <%
            }
        %>
    </div>
    <%
        if (data.hasCustomFilterButton()) {
    %>
    <h3 class="text-light"><%=userProperties.getLanguage("searchBy")%></h3>
    <%
        }
    %>
    <div>
    </div>
    <div id=<%=namespace%>-specific-filter class="grid filter-menu">
        <%
            listFilter.outputHtml(data, userProperties, out);

            data.outputFilteringHtml(userProperties, out);
        %>
        <div class="row cells2">
            <div class="cell">
                <div class="list-show-result-control">
                <!--<span class="caption"><%=userProperties.getLanguage("show")%></span>-->
                    <div class="input-control text" style="margin: 0">
                        <input id=<%=namespace%>-page-length type="text" value="<%=pageLength%>" maxlength="3">
                        <div class="button-group">
                            <button class="button" id=<%=namespace%>-refresh name="refresh" value="" title="<%=userProperties.getLanguage("refresh")%>" onclick="<%=namespace%>_refreshPageLength()"><span class="mif-loop2"></span></button>
                            <button class="button" id=<%=namespace%>-resetForm name="resetForm" value="" title="<%=userProperties.getLanguage("reset")%>" onclick="<%=namespace%>_resetPageLength()"><span class="mif-undo"></span></button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="cell">
                <%
                    if (data.hasSearchBox()) {
                %>
                <div class="list-search-control place-right">
                    <div class="input-control text full-size" style="margin: 0">
                        <input id=<%=namespace%>-search-data type="text" placeholder="<%=userProperties.getLanguage("searchKeyword")%>"/>
                        <button id=<%=namespace%>-searchDataButton class="button" onclick="<%=namespace%>_searchData('search-data')"><span class="mif-search"></span></button>
                    </div>
                </div>
                <%
                    }
                %>
            </div>
        </div>
    </div>
    <br><br>
    <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id=<%=namespace%>-result-table>
        <thead>

        </thead>
        <tbody>

        </tbody>
    </table>
    
</body>
</html>

