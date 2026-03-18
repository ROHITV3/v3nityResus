<%@page import="v3nity.std.biz.data.track.GeoFenceTreeView"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    ListData data = (ListData) request.getAttribute("data");

    MetaData metaDataSubType = (MetaData) request.getAttribute("metaDataSubType");

    boolean add = (boolean) request.getAttribute("add");

    boolean update = (boolean) request.getAttribute("update");

    boolean delete = (boolean) request.getAttribute("delete");
    
    GeoFenceTreeView geoFenceTreeView = new GeoFenceTreeView(listProperties);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <script type="text/javascript">

            

            var totalRecords_${namespace} = -1;

            var requireOverallCount_${namespace} = true;

            var listForm_${namespace};

            var customFilterQuery_${namespace} = [];

            var listFields = [];

            $(document).ready(function()
            {
                if (typeof ${namespace}ListForm !== 'undefined' && typeof ${namespace}ListForm === 'function')
                {
                    listForm_${namespace} = new ${namespace}ListForm('${namespace}-specific-filter');
                }
                else
                {
                    listForm_${namespace} = new ListForm('${namespace}-specific-filter');
                }

                var tbl = $('#${namespace}-result-table').DataTable(
                    {
                        dom: 'rtip',
                        pageLength: ${pageLength},
                        deferLoading: <%=(data.hasInitialData() ? "null" : "0")%>,
                        autoWidth: false,
                        deferRender: true,
                        orderClasses: false,
                        columns: [${columnList}],
                        order: [${orderList}],
                        processing: true,
                        serverSide: true,
                        responsive: true,
                        ajax: {
                            url: 'geofencePair?lib=${lib}&type=${type}&format=json&action=view',
                            type: 'POST',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords_${namespace};
                                d.requireOverallCount = requireOverallCount_${namespace};
                                d.customFilterQuery = JSON.stringify(customFilterQuery_${namespace});
                                d.filter = '${filter}';
                                d.foreignKey = '${foreignKey}';
                                d.visibleColumnIndexes = listForm_${namespace}.getColumns();
                            },
                            beforeSend: function()
                            {
                                $('.toolbar-button').prop("disabled", true);
                            },
                            error: function(xhr, error, thrown)
                            {
                                dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                            },
                            complete: function()
                            {
                                $('.toolbar-button').prop("disabled", false);
                            },
                            dataSrc: function(json)
                            {

                                var data = json;

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        if (data.visibleColumns !== undefined)
                                        {
                                            showColumns(tbl, data.visibleColumns);
                                        }

                                        if (data.data !== undefined && data.data.length === 0 && totalRecords_${namespace} !== -1)
                                        {
                                            dialog('No Record', 'No record found', 'alert');
                                        }
                                    }
                                    else
                                    {
                                        dialog('Search Failed', data.text, 'alert');

                                       
                                        json.data = [];
                                    }
                                }
                                else
                                {
                                    
                                    json.data = [];
                                }

                                return json.data;
                                }
                        },
                        drawCallback: function(settings)
                        {

                            if (settings.json === undefined)
                            {
                                return;
                            }

                            if (settings.json.errorText !== undefined)
                            {
                                dialog('Error', settings.json.errorText, 'alert');

                                return;
                            }

                            
                            if (tbl !== undefined)
                            {
                                if (tbl.page.info().recordsTotal === 0 && totalRecords_${namespace} !== -1)
                                {

                                }

                                totalRecords_${namespace} = tbl.page.info().recordsTotal;

                                if (isNaN(totalRecords_${namespace}))
                                {
                                    totalRecords_${namespace} = 0;
                                }

                                requireOverallCount_${namespace} = false;
                            }
                        },
                        headerCallback: function(thead, data, start, end, display)
                        {

                        },
                        createdRow: function(row, data, dataIndex)
                        {
            ${highlight};
                        },
                        select: <%=(data.hasSelection()) ? "{ style: 'multi' }" : "{}"%>,
                        buttons: [
                            'selectAll',
                            'selectNone',
                            'csv'
                        ],
                        language: {
                            info: '<%=listProperties.getLanguage("showing")%>' + ' _START_ ' + '<%=listProperties.getLanguage("to")%>'.toLowerCase() + ' _END_ ' + '<%=listProperties.getLanguage("of")%>'.toLowerCase() + ' _TOTAL_ ' + '<%=listProperties.getLanguage("entries")%>'.toLowerCase(),
                            infoEmpty: '<%=listProperties.getLanguage("showing")%>' + ' 0 ' + '<%=listProperties.getLanguage("to")%>'.toLowerCase() + ' 0 ' + '<%=listProperties.getLanguage("of")%>'.toLowerCase() + ' 0 ' + '<%=listProperties.getLanguage("entries")%>'.toLowerCase(),
                            emptyTable: '<%=listProperties.getLanguage("noDataAvailable")%>',
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

                if (getBrowser() !== 'ie')
                {
                    tbl.MakeCellsEditable({
                      
                        'inputCss': 'list-input-field',
                        'columns': ${columnEditableArray}
                    });
                }

                tbl.on('xhr', function()
                {

                   
                    tbl.off('draw.dt.dtSelect');

                    
                    $('#${namespace}-selectAll').removeClass('selected');
                });
            });

            

            $("#${namespace}-tool-button-add").click(function()
            {
                var endId = getTreeId('tree-view-filter-end-geofence', 'filter-end-geofence-id');
                
                var startId = getTreeId('tree-view-filter-start-geofence', 'filter-start-geofence-id');
                
                  if(startId === undefined || startId === '')
                  {
                       dialog('Failed', 'Please select one Start Geo fence', 'alert');
                  }
                  else if(endId === undefined || endId === '')
                  {
                       dialog('Failed','Please select one End Geo fence', 'alert');
                  }
                  else
                  {
                            $.ajax({
                                    type: 'POST',
                                    url: 'geofencePair?lib=${lib}&type=${type}&action=add',
                                    data: {
                                        startId: startId,
                                        endId:  endId,
                                    },
                                    beforeSend: function()
                                    {

                                    },
                                    success: function(data)
                                    {

                                        if (data.expired === undefined)
                                        {
                                            if (data.result === true)
                                            {

                                                dialog('Success', data.text, 'success');

                                                refreshDataTable_${namespace}();


                                            }
                                            else
                                            {
                                                dialog('Failed', data.text, 'alert');
                                            }
                                        }
                                    },
                                    error: function()
                                    {
                                        dialog('Error', 'System has encountered an error', 'alert');
                                    },
                                    complete: function()
                                    {

                                    },
                                    async: true
                                });
                                
                    }
                
            });


            $("#${namespace}-tool-button-delete").click(function()
            {
                
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        var ids = data.join();

                        $.ajax({
                            type: 'POST',
                            url: 'geofencePair?lib=${lib}&type=${type}&action=delete',
                            data: {
                                id: ids
                            },
                            beforeSend: function()
                            {
                               
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshDataTable_${namespace}();

                                        
                                    }
                                    else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
                            },
                            error: function()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function()
                            {
                               
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'alert');
                }
            });


            function ${namespace}_toggleSelect()
            {
                if ($('#${namespace}-selectAll').hasClass('selected'))
                {
                    $('#${namespace}-result-table').DataTable().button(1).trigger();
                    $('#${namespace}-selectAll').removeClass('selected');
                }
                else
                {
                    $('#${namespace}-result-table').DataTable().button(0).trigger();
                    $('#${namespace}-selectAll').addClass('selected');
                }
            }

            function ${namespace}_searchData()
            {
                var searchText = $('#${namespace}-search-data').val();

                requireOverallCount_${namespace} = true;

                $('#${namespace}-result-table').DataTable().search(searchText).draw();
            }

            function refreshDataTable_${namespace}()
            {
                requireOverallCount_${namespace} = true;

                refreshPageLength_${namespace}();
            }

            function refreshPageLength_${namespace}()
            {
                var pageLength = $('#${namespace}-page-length').val();

                if (isInteger(pageLength))
                {
                    var table = $('#${namespace}-result-table').DataTable();

                    table.page.len(pageLength).draw();
                }
                else
                {
                    resetPageLength_${namespace}();
                }
            }

            function resetPageLength_${namespace}()
            {
                var table = $('#${namespace}-result-table').DataTable();

                // reset default value in page length control...
                $('#${namespace}-page-length').val(${pageLength});

                // reset search box...
                $('#${namespace}-search-data').val('');

                // reset table search...
                table.search('');

                // reset default page length...
                table.page.len(${pageLength}).draw();
            }


            function ${namespace}_downloadFile()
            {
                 window.open("geofencePair?type=GeoFencePair&action=view&format=csv&draw=0&totalRecords=1&start=0&length=20000"," _blank,toolbar=no,status=no,scrollbars=no,menubar=no,height=0,width=0,resizeable=no");
            }

         


            function customFilter_${namespace}()
            {
                customFilterQuery_${namespace} = listForm_${namespace}.filter();

                refreshDataTable_${namespace}();
            }

            function showColumns(table, ids)
            {
                table.columns().visible(true);

                for (var i = 0; i < ids.length; i++)
                {
                    var id = ids[i];

                    table.column(id).visible(false, false);
                }
            }


        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
       
        <div>
            <h1 class="text-light"><%=listProperties.getLanguage(data.getDisplayName())%></h1>
        </div>
        <div class="toolbar" style="margin: 16px 0">
            <%
                if ((add && data.hasAddButton()) || (update && data.hasEditButton()) || (delete && data.hasDeleteButton()))
                {
            %>
            <div class="toolbar-section">
                <%
                    if (add && data.hasAddButton())
                    {
                %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-add name="add" value="" title="<%=listProperties.getLanguage("add")%>"><span class="mif-plus"></span></button>
                    <%
                        }

                        if (update && data.hasEditButton())
                        {
                    %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-edit name="edit" value="" title="<%=listProperties.getLanguage("edit")%>"><span class="mif-pencil"></span></button>
                    <%
                        }

                        if (delete && data.hasDeleteButton())
                        {
                    %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-delete name="delete" value="" title="<%=listProperties.getLanguage("delete")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>

                <%
                    if (data.hasDeleteByFilterButton())
                    {
                %>

                <button class="toolbar-button" type="button" id=${namespace}-tool-button-delete-filter name="delete" value="" title="<%=listProperties.getLanguage("deleteByFilter")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>
            </div>
            <%
                }
            %>

           

            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("SelectOrUnselect")%>" onclick="${namespace}_toggleSelect()" id=${namespace}-selectAll><span class="mif-table"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("downloadCSV")%>" onclick="${namespace}_downloadFile()"><span class="text-light text-small">CSV</span></button>

            </div>

            
        </div>
                
        <div class="grid" >
            <div class="row cells4">
                <div class="cell">
                    <h4 class="text-light align-left"><%=listProperties.getLanguage("startGeofence")%></h4>
                    <div id="chartFrame" class="treeview-control">
                        <%
                            geoFenceTreeView.setIdentifier("filter-start-geofence");

                            geoFenceTreeView.loadData(listProperties);
                            geoFenceTreeView.outputHTML(out, listProperties);
                        %>

                    </div>
                </div>

                <div class="cell">
                    <div class="cell">
                    <h4 class="text-light align-left"><%=listProperties.getLanguage("endGeofence")%></h4>
                        <div id="chartFrame" class="treeview-control">
                            <%
                                geoFenceTreeView.setIdentifier("filter-end-geofence");

                                geoFenceTreeView.loadData(listProperties);
                                geoFenceTreeView.outputHTML(out, listProperties);
                            %>

                        </div>
                    </div>
                </div>


            </div>
        </div>
       
        <div id=${namespace}-specific-filter class="grid filter-menu">
           
            <div class="row cells2">
                <div class="cell">
                    <div class="list-show-result-control">
                        <div class="input-control text" style="margin: 0">
                            <input id=${namespace}-page-length type="text" value="${pageLength}" maxlength="3">
                            <div class="button-group">
                                <button class="button" id=${namespace}-refresh name="refresh" value="" title="<%=listProperties.getLanguage("refresh")%>" onclick="refreshPageLength_${namespace}()"><span class="mif-loop2"></span></button>
                                <button class="button" id=${namespace}-resetForm name="resetForm" value="" title="<%=listProperties.getLanguage("reset")%>" onclick="resetPageLength_${namespace}()"><span class="mif-undo"></span></button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="cell">
                    <%
                        if (data.hasSearchBox())
                        {
                    %>
                    <div class="list-search-control place-right">
                        <div class="input-control text full-size" style="margin: 0">
                            <input id=${namespace}-search-data type="text" placeholder="<%=listProperties.getLanguage("searchKeyword")%>"/>
                            <button id=${namespace}-searchDataButton class="button" onclick="${namespace}_searchData('search-data')"><span class="mif-search"></span></button>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id=${namespace}-result-table>
            <thead>

            </thead>
            <tbody>

            </tbody>
        </table>
       
    </body>
</html>
