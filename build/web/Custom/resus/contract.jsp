
<%@page import="java.util.List"%>
<%@page import="v3nity.std.biz.data.plan.JobSchedulePestControlView"%>
<%@page import="v3nity.std.biz.data.common.DriverDropDown"%>
<%@page import="v3nity.std.biz.data.plan.ContractJobSchedule"%>
<%@page import="v3nity.std.biz.data.common.Operation"%>
<%@page import="v3nity.std.biz.data.common.Resource"%>
<%@page import="v3nity.std.biz.data.common.DriverTreeView"%>
<%@page import="java.sql.Connection"%>
<%@page import="v3nity.std.biz.data.plan.JobFormTemplateDropDown"%>
<%@page import="v3nity.std.biz.data.plan.Contract"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    String lib = "v3nity.std.biz.data.plan";

    String type = "Contract";

    ListData data = new Contract();

    ListData data2 = new ContractJobSchedule();

    MetaData metaDataSubType = (MetaData) request.getAttribute("metaDataSubType");

    boolean add = (boolean) request.getAttribute("add");

    String searchContract = request.getParameter("searchContractForCustomer");
    if (searchContract == null) {
        searchContract = "";
    }

    System.out.print(searchContract);

    boolean update = (boolean) request.getAttribute("update");

    boolean delete = (boolean) request.getAttribute("delete");

    int formOperations = listProperties.getOperations(Resource.JOB_SCHEDULE_FORM_TEMPLATE);

    boolean addTemplate = listProperties.canAccessAdd(formOperations);

    boolean editTemplate = listProperties.canAccessUpdate(formOperations);

    boolean deleteTemplate = listProperties.canAccessDelete(formOperations);

    boolean viewTemplate = listProperties.canAccessView(formOperations);
//    
//     boolean editTemplate = listProperties.canAccess(formOperations, Operation.UPDATE);

    DriverDropDown driverDropDown = new DriverDropDown(listProperties);

    JobFormTemplateDropDown formTemplateDropDown = new JobFormTemplateDropDown(listProperties);

    int customerId = (listProperties.getUser().getInt("customer_id"));

    try {

        // create the edit column...
        driverDropDown.setIdentifier("filter-driver-schedule");

        driverDropDown.loadData(listProperties);

        formTemplateDropDown.setIdentifier("filter-form-template");

        formTemplateDropDown.loadData(listProperties);

        //countryDataHandler.closeConnection();
    } catch (Exception e) {

    } finally {

    }
    Data dataSched = new JobSchedulePestControlView();

    ListMetaData metaData = null;

    List<MetaData> metaDataList = dataSched.getMetaDataList();

    int metaListSize = metaDataList.size();

//    int metaListSizeSched = metaDataListSched.size();
//    int pageLengthSched = dataSched.g();
    String columnListSched = "";

    for (int i = 0; i < metaListSize; i++) {
        metaData = (ListMetaData) metaDataList.get(i);

        // construct the column definition for the data table...
        if (metaData.getViewable()) {
            if (columnListSched.length() > 0) {
                columnListSched += ",";
            }

            columnListSched += "{ \"data\": \"" + i + "\", \"title\": \"" + listProperties.getLanguage(metaData.getDisplayName()) + "\", \"orderable\": " + metaData.getOrderable() + " }";
        }
    }
//    if (update && data.hasEditButton()) {
//        columnListSched += ",{ \"data\": \"" + "editButton" + "\", \"title\": \"" + listProperties.getLanguage("edit") + "\", \"orderable\": false, \"width\": \"64px\" }";
//    }

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <style>
            .active{

                background-color: green;
                color:white;
            }

            .dialog.small {
                width: 80% !important;
                height: 85% !important;
                top: 10% !important;
                bottom: 10% !important;
                max-width: 700px;
                margin-left: -350px;
                left: 50% !important;
            }
            
            #staff{
                color: red;
                font-size: 20px
            }
        </style>
        <script type="text/javascript" src="js/jszip.min.js"></script>
        <script type="text/javascript">

            var csv_${namespace} = new csvDownload('ContractController?lib=${lib}&type=${type}&action=view', 'V3NITY');

            var totalRecords_${namespace} = -1;

            var totalRecords = -1;


            var requireOverallCount_${namespace} = true;

            var requireOverallCount = true;

            var listForm_${namespace};
            var listForm;
            var customer_id;
            var cancelJobId;
            var editJobScheduleId;

            var customFilterQuery_${namespace} = [];

            var customFilterQuery = "[]";

            var listFields = [];

            var addTemplate = (<%=(addTemplate) ? "true" : "false"%>);

            var editTemplate = (<%=(editTemplate) ? "true" : "false"%>);

            var deleteTemplate = (<%=(deleteTemplate) ? "true" : "false"%>);

            var viewTemplate = (<%=(viewTemplate) ? "true" : "false"%>);

            var sContract = '<%=searchContract%>';


            var importFile;

            var fileName;

            var contractId;
            var conId;
	    var distinct = {};


            $(document).ready(function ()
            {

                initiateYears();
				
	//  This function remove duplicate value from option     
                $("select[name='contract_customer_id'] option").each(function () {
                  if (distinct[this.value]) {
                    $(this).remove()
                        }
                      distinct[this.value] = true;
                        })

                if (typeof ${namespace}ListForm !== 'undefined' && typeof ${namespace}ListForm === 'function')
                {
                    listForm_${namespace} = new ${namespace}ListForm('${namespace}-specific-filter');
                } else
                {
                    listForm_${namespace} = new ListForm('${namespace}-specific-filter');
                }

                $('select[name=inputFormTemplateName]').on('change', function ()
                {

                    $.ajax({
                        type: 'POST',
                        url: 'JobReportController',
                        data: {
                            type: 'system',
                            action: 'template',
                            templateId: $("#inputFormTemplateNameId").val()
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {



                            reportTemplates = data.templates;

                            var html;

                            html += "<option value='0'>- <%=listProperties.getLanguage("jobReportTemplate")%> -</option>";

                            var selected = ' selected'; // use to default select first item...

                            for (var i = 0; i < reportTemplates.length; i++)
                            {

                                var template = reportTemplates[i];

                                html += "<option value='" + template.id + "' " + selected + ">" + template.name + "</option>";

                                selected = '';
                            }



                            document.getElementById('inputReportTemplateNameId').innerHTML = html;
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function ()
                        {
                        },
                        async: false
                    });

//                    getForm(this.value);
                });
                function getForm(id)
                {


                    if (id === '0')
                    {
                        form.clear();
                    } else
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'ListController?lib=v3nity.std.biz.data.plan&type=JobFormTemplate&action=data',
                            data: {
                                id: id
                            },
                            success: function (result)
                            {

                                $.each(result.data, function (i, field)
                                {

                                    if (field.name === 'template_data')
                                    {
                                        form.setHtml(field.value);
                                    }
                                });

                            },
                            error: function ()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function ()
                            {

                            },
                            async: false
                        });
                    }
                }


                var tbl = $('#${namespace}-result-table').DataTable(
                        {

                            dom: 'rtip',
                            pageLength: ${pageLength},
                            deferLoading: <%=(data.hasInitialData() ? "null" : "0")%>,
                            order: [[0, 'desc']],
                            autoWidth: false,
                            deferRender: true,
                            orderClasses: false,
                            columns: [${columnList}],
                            processing: true,
                            serverSide: true,
                            responsive: true,
                            ajax: {
                                url: 'ContractController?lib=${lib}&type=${type}&format=json&action=view',
                                type: 'POST',
                                data: function (d)
                                {

                                    d.totalRecords = totalRecords_${namespace};
                                    d.requireOverallCount = requireOverallCount_${namespace};
                                    d.customFilterQuery = JSON.stringify(customFilterQuery_${namespace});
                                    d.filter = '${filter}';
                                    d.foreignKey = '${foreignKey}';
                                    d.visibleColumnIndexes = listForm_${namespace}.getColumns();
                                },
                                beforeSend: function ()
                                {
                                    $('.toolbar-button').prop("disabled", true);
                                },
                                error: function (xhr, error, thrown)
                                {
                                    dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                                },
                                complete: function ()
                                {
                                    $('.toolbar-button').prop("disabled", false);
                                },
                                dataSrc: function (json)
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
                                        } else
                                        {
                                            dialog('Search Failed', data.text, 'alert');

                                            // we need this for the data-table to read...
                                            json.data = [];
                                        }
                                    } else
                                    {
                                        // we need this for the data-table to read...
                                        json.data = [];
                                    }

                                    return json.data;
                                    }
                            },
                            drawCallback: function (settings)
                            {

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
                            headerCallback: function (thead, data, start, end, display)
                            {

                            },
                            createdRow: function (row, data, dataIndex)
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
                                price: 'price(MLR)',

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
                        'onUpdate': cellEditCallback_${namespace},
                        'inputCss': 'list-input-field',
                        'columns': ${columnEditableArray}
                    });
                }

                //     every ajax call, turn off the draw event otherwise,
                //     all rows will be selected from the table upon selecting buttons within the table.
                //     there is something wrong with the datatable with server side processing.
                tbl.on('xhr', function ()
                {

                    // this will turn off the event...
                    tbl.off('draw.dt.dtSelect');

                    // whenever there is a ajax call, unselect all the items...
                    $('#${namespace}-selectAll').removeClass('selected');
                });



                $(".schedule-time").AnyTime_picker({format: "%H:%i"});

                $("#recur-start-time").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#timetable-date").AnyTime_picker({format: "%d/%m/%Y"});
                var today = new Date();
                dd = today.getDate();
                if (dd < 10)
                {
                    dd = '0' + dd;
                }
                mm = today.getMonth() + 1;
                if (mm < 10)
                {
                    mm = '0' + mm;
                }
                yyyy = today.getFullYear();
                var todayDate = dd + '/' + mm + '/' + yyyy;
                $("#timetable-date").val(todayDate);
                $(".starting-from").AnyTime_picker({format: "%d/%m/%Y"});
                $(".ending-on").AnyTime_picker({format: "%d/%m/%Y"});



                $('#${namespace}-search-data').val(sContract);

                $('#${namespace}-searchDataButton').click();

            });


            function cellEditCallback_${namespace}(cell, row, oldValue)
            {

                if (cell.data() !== oldValue)
                {
                    var table = $('#${namespace}-result-table').DataTable();

                    var colIndex = cell.index().column;

                    var fieldname = table.settings().init().columns[colIndex].name;

                    var dataEdit = {'id': row.id()};

                    dataEdit[fieldname] = cell.data();

                    $.ajax({
                        type: 'POST',
                        url: 'ContractController?lib=${lib}&type=${type}&action=edit',
                        data: dataEdit,
                        success: function (data)
                        {

                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {

                                    dialog('Success', data.text, 'success');

                                    cell.data(cell.data()).draw();

                                } else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        async: true
                    });
                }
            }

            $("input[id^=dateTimePicker]").change(function ()
            {

                $('#${namespace}-email-button').prop("disabled", false);
            });

            $("#${namespace}-tool-button-add").click(function ()
            {
                showAdd_${namespace}();
            });

            $("#${namespace}-tool-button-edit").click(function ()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Warning', 'Please aware that you have selected more than one records', 'warning');
                    }

                    var id = data.join();

                    showEdit_${namespace}(id);
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            });

            $("#${namespace}-tool-button-delete").click(function ()
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
                            url: 'ContractController?lib=${lib}&type=${type}&action=delete',
                            data: {
                                id: ids
                            },
                            beforeSend: function ()
                            {
                                $('#${namespace}-button-save').prop("disabled", true);
                            },
                            success: function (data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength_${namespace}();

                                        closeForm_${namespace}();
                                    } else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
                            },
                            error: function ()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function ()
                            {
                                $('#${namespace}-button-save').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                } else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'alert');
                }
            });

            $("#${namespace}-tool-button-copy").click(function ()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Warning', 'Please aware that you have selected more than one records', 'warning');
                    }

                    var id = data.join();

                    showCopy_${namespace}(id);
                } else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            });

            function dispose()
            {
                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function (index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            }

            function ${namespace}_toggleSelect()
            {
                if ($('#${namespace}-selectAll').hasClass('selected'))
                {
                    $('#${namespace}-result-table').DataTable().button(1).trigger();
                    $('#${namespace}-selectAll').removeClass('selected');
                } else
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
                } else
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

            function deviceSync_${namespace}()
            {
                $.ajax({
                    type: 'POST',
                    url: 'ContractController?lib=${lib}&type=${type}&action=sync',
                    data: $('#${namespace}-form-dialog-data').serialize(),
                    beforeSend: function ()
                    {
                        $('#${namespace}-button-deviceSync').prop("disabled", true);
                    },
                    success: function (data)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
                            } else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#${namespace}-button-deviceSync').prop("disabled", false);
                    },
                    async: true
                });
            }

            function ${namespace}_downloadFile()
            {
                csv_${namespace}.startDownload(20000, {customFilterQuery: JSON.stringify(listForm_${namespace}.filter()), visibleColumnIndexes: listForm_${namespace}.getColumns()});
            }

            function ${namespace}_downloadFileEmail()
            {
                var prefix = getPrefix();

                if (prefix !== '')  // must select at least 1 asset...
                {
                    var options = {
                        customFilterQuery: JSON.stringify(listForm_${namespace}.filter()),
                        emailTitle: 'V3NITY REPORT',
                        filePrefix: '<%=data.getDisplayName().toUpperCase()%>_' + prefix + '_'
                    };

                    var result;

                    $.ajax({
                        type: 'POST',
                        url: 'ContractController?lib=${lib}&type=${type}&action=email&format=csv',
                        data: options,
                        async: true,
                        success: function (data)
                        {
                            if (data.expired === undefined)
                            {
                                result = data.result;
                                if (result)
                                {
                                    dialog('Report Download', 'Download link will be sent via email when report is ready for download', 'success');

                                } else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                                $('#${namespace}-email-button').prop("disabled", false);
                            }
                        },
                        beforeSend: function ()
                        {
                            $('#${namespace}-email-button').prop("disabled", true);
                        }
                    });
                } else
                {
                    dialog('Error', 'Please select at least 1 asset', 'alert');
                }
            }

            function getPrefix()
            {
                var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

                if (ids !== '')
                {
                    if (ids.indexOf(',') === -1)    // if no ',' it means only 1 id...
                    {
                        var node = $('#tree-view-filter-asset').find('[data-filter-asset-id=' + ids + ']:first-child');

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

            function loadSubType_${namespace}(id)
            {
            <%
                if (metaDataSubType != null) {
                    String subType = metaDataSubType.getForeignListClass().getSimpleName();

                    String subTypeForeignKey = metaDataSubType.getForeignKeyName();

                    String subTypeDisplayName = listProperties.getLanguage(metaDataSubType.getDisplayName());
            %>
                if (id === -1)
                {
                    $('#${namespace}-sub-type').html('<p class="note">Please save and click edit to manage <%=subTypeDisplayName%>.</p>');
                } else
                {
                    $('#${namespace}-sub-type').load('ContractController?lib=${lib}&type=<%=subType%>&filter=' + id + '&foreignKey=<%=subTypeForeignKey%>');
                }
            <%
                }
            %>
            }

            function ${namespace}_saveForm()
            {

                if (listForm_${namespace}.save())
                {
                    var action = $('#${namespace}-button-save').data('action');

                    console.log('data: ' + $('#form-dialog-data').serialize());

                    var id = $('#${namespace}-button-save').data('id');

                    if (id === undefined)
                    {
                        id = 0;
                    }

                    $.ajax({
                        type: 'POST',
                        url: 'ContractController?lib=${lib}&type=${type}&action=' + action + '&id=' + id,
                        data: $('#${namespace}-form-dialog-data').serialize(),
                        beforeSend: function ()
                        {
                            $('#${namespace}-button-save').prop("disabled", true);
                        },
                        success: function (data)
                        {

                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {

                                    dialog('Success', data.text, 'success');

                                    refreshPageLength_${namespace}();

                                    closeForm_${namespace}();
                                } else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            } else
                            {
                                closeForm_${namespace}();
                            }
                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function ()
                        {
                            $('#${namespace}-button-save').prop("disabled", false);
                        },
                        async: true
                    });
                } else
                {
                    dialog('Error', listForm_${namespace}.saveError, 'alert');
                }
            }

            function showAdd_${namespace}()
            {
                var dialog = $('#${namespace}-form-dialog').data('dialog');

                $('#${namespace}-form-dialog-title').html('<%=listProperties.getLanguage("add")%> ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                $('#${namespace}-button-save').data('action', 'add');
                $('#inputFormTemplateNameId').prop("disabled", false);
                $('#inputReportTemplateNameId').prop("disabled", false);
//                $('.price').value("rohit");

                clearForm_${namespace}();

                loadSubType_${namespace}(-1);

                dialog.open();
            }

            function showEdit_${namespace}(id)
            {
                if (getData_${namespace}(id))
                {
                    var dialog = $('#${namespace}-form-dialog').data('dialog');
                    $('#${namespace}-form-dialog-title').html('<%=listProperties.getLanguage("edit")%> ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                    $('#${namespace}-button-save').data('action', 'edit');
                    $('#${namespace}-button-save').data('id', id);
                    loadSubType_${namespace}(id);

                    dialog.options.onDialogClose = dialogClose;

                    dialog.open();
                }
            }

            function showCopy_${namespace}(id)
            {
                if (getData_${namespace}(id))
                {
                    var dialog = $('#${namespace}-form-dialog').data('dialog');
                    $('#${namespace}-form-dialog-title').html('<%=listProperties.getLanguage("copy")%> ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                    $('#${namespace}-button-save').data('action', 'add');
                    $('#${namespace}-button-save').data('id', id);

                    loadSubType_${namespace}(id);

                    dialog.options.onDialogClose = dialogClose;

                    dialog.open();
                }
            }

            function dialogClose(dialog)
            {
                clearForm_${namespace}();
            }

            function clearForm_${namespace}()
            {


                document.getElementById('${namespace}-form-dialog-data').reset();
//Rohit start

                $('#${namespace}-form-dialog-data').find('input[name=price]').attr("placeholder", "Price (MYR)");
                /*
                 * perform form reset manually...
                 */
                var frm = document.getElementById('${namespace}-form-dialog-data');

                var frm_elements = frm.elements;

                for (i = 0; i < frm_elements.length; i++)
                {
                    var element = frm_elements[i];

                    if (element.tagName.toLowerCase() === 'input')
                    {
                        var field_type = element.type.toLowerCase();

                        switch (field_type)
                        {
                            case "text":
                            case "password":
                                element.value = "";
                                break;
                            case "textarea":
                                element.value = "";
                                break;
                            case "radio":
                            case "checkbox":
                                if (element.checked)
                                {
                                    element.checked = false;
                                }
                                break;
                            case "select-one":
                            case "select-multi":
                                element.selectedIndex = 0;
                                break;
                            case "hidden":
                                /*
                                 * somehow have to be careful when implementing as the button-save id is being cleared...
                                 */
                                break;
                            default:
                                break;
                        }
                    } else if (element.tagName.toLowerCase() === 'select')
                    {
                        /*
                         * cater for select2 plugin...
                         */
                        $(element).prop('selectedIndex', 0).trigger('change');
                    }
                }

                /*
                 * perform custom form reset...
                 */
                listForm_${namespace}.reset();

//             4   
                $('#inputFormTemplateNameId option[value=0]').prop('selected', true);

                $('#inputReportTemplateNameId option[value=0]').prop('selected', true);


//             4 
                listFields.forEach(function (value, index)
                {
                    value.clear();
                });
            }

            function closeForm_${namespace}()
            {

            <%
                if (metaDataSubType != null) {
                    String subType = metaDataSubType.getForeignListClass().getSimpleName();
            %>
                // we need to unload the datetime picker of the sub class because if not, when the dialog opens again it will load redundantly and cause error.
                $('#<%=subType%>-form-dialog').find('[id^="dateTimePicker"]').each(function (index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            <%
                }
            %>

                $('#${namespace}-form-dialog').data('dialog').close();

                $('#add-job-dialog').data('dialog').close();

                clearForm_${namespace}();
            }

            function getData_${namespace}(id)
            {
                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'ContractController?lib=${lib}&type=${type}&action=data',
                    data: {
                        id: id
                    },
                    success: function (data, status, request)
                    {
                        if (request.getResponseHeader('content-type').includes('json'))
                        {
                            populateForm_${namespace}(data);

                            listForm_${namespace}.populate(data);

                            result = true;
                        } else
                        {
                            $('body').html(data);
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {

                    },
                    async: false
                });

                return result;
            }

            function populateForm_${namespace}(result)
            {
                $.each(result.data, function (i, field)
                {
                    if (field.type === 'text')
                    {
                        $('input[name=' + field.name + ']').val(field.value);
                    } else if (field.type === 'textarea')
                    {
                        $('textarea[name=' + field.name + ']').val(field.value);
                    } else if (field.type === 'selection')
                    {
                        if (field.value === 0)
                        {
                            $('select[name=' + field.name + ']').val('').trigger('change');
                        } else
                        {
                            $('select[name=' + field.name + ']').val(field.value).trigger('change');
                        }
                    } else if (field.type === 'searchable')
                    {
                        $('input[name=' + field.name + ']').val(field.value);

                        $('#list-data-field-' + field.name).val(field.text);
                    } else if (field.type === 'checkbox')
                    {
                        $('input[name=' + field.name + ']').prop('checked', field.value);
                    } else if (field.type === 'html')
                    {

                    }
                });
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

            $("#${namespace}-tool-button-delete-filter").click(function ()
            {
                if (customFilterQuery_${namespace}.length > 0 && totalRecords_${namespace} > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'ContractController?lib=${lib}&type=${type}&action=deleteByFilter',
                            data: {
                                filterQuery: JSON.stringify(customFilterQuery_${namespace})
                            },
                            beforeSend: function ()
                            {
                                $('#${namespace}-tool-button-delete-filter').prop("disabled", true);
                            },
                            success: function (data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength_${namespace}();

                                        closeForm_${namespace}();
                                    } else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
                            },
                            error: function ()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function ()
                            {
                                $('#${namespace}-tool-button-delete-filter').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                } else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'default');
                }
            });
            function completeOrder(id)
            {

                var orderId;


                var c = confirm("Are you sure you want to complete the order?");

                if (c === true)
                {

                    $.ajax({
                        type: 'POST',
                        url: 'ContractController?lib=${lib}&type=${type}&action=order',
                        data: {

                            orderId: id
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {

                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');



                                refreshDataTable_${namespace}();

                            } else
                            {

                                dialog('Failed', text, 'alert');


                            }

                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function ()
                        {

                        },
                        async: true
                    });

                }

            }

            function completePaymentFalse(id)
            {

                var paymentId;


                var c = confirm("Are you sure you want to revert payment status to incomplete?");

                if (c === true)
                {

                    $.ajax({
                        type: 'POST',
                        url: 'ContractController?lib=${lib}&type=${type}&action=paymentIncomplete',
                        data: {

                            paymentId: id
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {

                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');



                                refreshDataTable_${namespace}();

                            } else
                            {

                                dialog('Failed', text, 'alert');


                            }

                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function ()
                        {

                        },
                        async: true
                    });

                }

            }

            function completePayment(id)
            {

                var c = confirm("Are you sure you want to complete the payment?");

                var payment;

                if (c === true)
                {

                    $.ajax({
                        type: 'POST',
                        url: 'ContractController?lib=${lib}&type=${type}&action=payment',
                        data: {
                            paymentId: id
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            var result = data.result;

                            var text = data.text;

                            if (result === true)
                            {

                                dialog('Success', text, 'success');

                                refreshDataTable_${namespace}();

                            } else
                            {

                                dialog('Failed', text, 'alert');


                            }

//                            $("#price").val(20);

                        },
                        error: function ()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function ()
                        {
                            var resul

                        },
                        async: true
                    });

                }

            }



            function invoiceOpen(id)
            {
                var fileId;
                var pdfdialog = window.open("ContractController?lib=${lib}&type=${type}&action=open&fileId=" + id, "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function greenCardOpen(id)
            {
                var fileId;
                var pdfdialog = window.open("ContractController?lib=${lib}&type=${type}&action=openGreenCard&fileId=" + id, "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");

                pdfdialog.moveTo(0, 0);

            }


            function uploadInvoice(id)
            {
                customer_id = id;


                $('#upload-pending-dialog').data('dialog').open();
            }

            function uploadGreenCard(id)
            {
                customer_id = id;


                $('#green-pending-dialog').data('dialog').open();
            }

            function downloadIMG(id)
            {
                var img = new imgDownload('V3NITY_IMG');
                img.download(id);
            }

            function addJob(id)
            {

                customer_id = id;

                var customer_id;
                document.getElementById('staff').innerHTML='';
                
                $.ajax(
                        {
                            type: 'POST',
                            url: 'ContractJobScheduleController?action=getCustomer',
                            data: {

                                customer_id: id
                            },
                            beforeSend: function () {
                            },
                            success: function (data)
                            {
                                // $('#pending_reason').val(data.pending_reason_id);

                                var customerName = data.customer_name;

                                contractId = data.contract_id;

                                var customerId = data.customer_id;

                                siteAddressFunction(customerId);


                                document.getElementById('service_order_no').innerHTML = 'Customer Name: ' + customerName;





                            },
                            error: function () {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function () {
                            },
                            async: true
                        });


            }


            function   siteAddressFunction(customerId)
            {
                var id = customerId;

                var customer_Id;

                // alert(id);
                $.ajax(
                        {
                            type: 'POST',
                            url: 'ContractJobScheduleController?action=getSiteAddress',
                            data: {

                                customer_Id: id
                            },
                            beforeSend: function () {
                            },
                            success: function (data)
                            {
                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        siteAddress = data.sites;

                                        var html;
                                        html += "<option value='0'>- <%=listProperties.getLanguage("siteAddress")%> -</option>";

                                        var selected = ' selected'; // use to default select first item...

                                        for (var i = 0; i < siteAddress.length; i++)
                                        {

                                            var site = siteAddress[i];

                                            html += "<option value='" + site.id + "' " + selected + ">" + site.name + "</option>";

                                            selected = '';
                                        }



                                        document.getElementById('inputSiteAddress').innerHTML = html;

                                        clearForm();

                                        $('#add-job-dialog').data('dialog').open();
                                    } else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }



                            },
                            error: function () {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function () {
                            },
                            async: true
                        });
            }


            function saveJob()
            {


                var cId = contractId;

                var action = 'add';

                var id = $('#button-save').data('id');

                var dayInput = $('#dayGiven').val();

                var jobFormTemplate = $('#inputFormTemplateNameId').val();

                var scheduleDate = $('#dateTimePicker-schedule_dt').val();

                var selectSiteAddress = $('#inputSiteAddress').val();

                var selecDriver = $('#driverNameId').val();

                var durationValue = $("input[name='duration']").val();


                var oneTime = $('#one').val();

                var recurrJob = $('#recurr').val();



                if ($('#recurr').is(':checked'))
                {
                    if (dayInput == "" || dayInput == "undefined")
                    {
                        dialog('Error', 'Please Input the Days', 'alert');
                        return;
                    }
                }

                if (scheduleDate == "" || scheduleDate == "undefined")
                {

                    dialog('Error', 'Please enter the Schedule Date ', 'alert');
                    return;
                }

                if (durationValue == "" || durationValue == "undefined")
                {

                    dialog('Error', 'Please input the Duration', 'alert');
                    return;
                }


                if (jobFormTemplate == "0" || jobFormTemplate == "undefined")
                {

                    dialog('Error', 'Please Select the Form Template', 'alert');
                    return;
                }

                if (selecDriver == "0" || selecDriver == "undefined")
                {

                    dialog('Error', 'Please Select the Technician', 'alert');
                    return;
                }
                if (selectSiteAddress == "0" || selectSiteAddress == "undefined")
                {

                    dialog('Error', 'Please Select the Site Address', 'alert');
                    return;
                }
                if ($('#recurr').not(':checked') || $('#one').not(':checked'))
                {

                    if ($('#one').is(':checked'))
                    {
                    } else if ($('#recurr').is(':checked'))
                    {
                    } else
                    {
                        dialog('Error', 'Please Select One Time or Recurring ', 'alert');
                        return;
                    }

                }





                if (id === undefined)
                {
                    id = 0;
                }


//                console.log('data: ' + $('#form-dialog-data').serialize());

                $.ajax({
                    type: 'POST',
                    url: 'ContractJobScheduleController?action=' + action + '&contractId=' + cId,
                    data: $('#form-dialog-data').serialize(),
                    beforeSend: function ()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {

                                dialog('Success', data.text, 'success');

                                $('#day').css("display", "none");

                                refreshPageLength_${namespace}();
                                refreshDataTable_${namespace}();

                                closeForm_${namespace}();
                            } else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        } else
                        {
                            closeForm_${namespace}();
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#button-save').prop("disabled", false);
                    },
                    async: true
                });



            }

            function clearForm()
            {


                document.getElementById('form-dialog-data').reset();
//Rohit start


                /*
                 * perform form reset manually...
                 */
                var frm = document.getElementById('form-dialog-data');

                var frm_elements = frm.elements;

                for (i = 0; i < frm_elements.length; i++)
                {
                    var element = frm_elements[i];

                    if (element.tagName.toLowerCase() === 'input')
                    {
                        var field_type = element.type.toLowerCase();

                        switch (field_type)
                        {
                            case "text":
                            case "password":
                                element.value = "";
                                break;
                            case "textarea":
                                element.value = "";
                                break;
                            case "radio":
                            case "checkbox":
                                if (element.checked)
                                {
                                    element.checked = false;
                                }
                                break;
                            case "select-one":
                            case "select-multi":
                                element.selectedIndex = 0;
                                break;
                            case "hidden":
                                /*
                                 * somehow have to be careful when implementing as the button-save id is being cleared...
                                 */
                                break;
                            default:
                                break;
                        }
                    } else if (element.tagName.toLowerCase() === 'select')
                    {
                        /*
                         * cater for select2 plugin...
                         */
                        $(element).prop('selectedIndex', 0).trigger('change');
                    }
                }

                /*
                 * perform custom form reset...
                 */
                listForm_${namespace}.reset();

//             4   
                $('#inputFormTemplateNameId option[value=0]').prop('selected', true);

                $('#inputReportTemplateNameId option[value=0]').prop('selected', true);


//             4 
                listFields.forEach(function (value, index)
                {
                    value.clear();
                });
            }
            function cancelJob()
            {

                $('#day').css("display", "none");
                $('#add-job-dialog').data('dialog').close();

                clearForm_${namespace}();



            }

            function cancelContractJob()
            {

                $('#view_appt_month_select').val(0);
                $('#view_appt_year_select').val(0);
                $('#view_appt_status_select').val(0);
                $('#driverId').val(0);
                customFilterQuery = "[]";
                $('#job-table').DataTable().destroy();
                $('#view-job-dialog').data('dialog').close();


            }
            function viewJob(id)
            {
                var customerId = id;

                jobFunction(customerId);
                $('#view-job-dialog').data('dialog').open();
            }

//           $('.dialog-close-button').on


            function handleFile(e)
            {

                importFile = e.target.files[0];

                fileName = e.target.files[0].name;
                var currentdate = new Date();
                var dateString = currentdate.getFullYear() + "" + ('0' + (currentdate.getMonth() + 1)).slice(-2) + ('0' + currentdate.getDate()).slice(-2) +
                        ('0' + currentdate.getHours()).slice(-2) + ('0' + currentdate.getMinutes()).slice(-2) + ('0' + currentdate.getSeconds()).slice(-2);


            }

            function bs_input_file() {


                $(".input-file").before(
                        function () {
                            if (!$(this).prev().hasClass('input-ghost')) {
                                var element = $("<input type='file'  id='input-file' multiple class='input-ghost' style='visibility:; height:46'>");
                                element.attr("name", $(this).attr("name"));
                                element.change(function () {
                                    element.next(element).find('input').val((element.val()).split('\\').pop());
                                });
                                element.on('change', handleFile);

                                $(this).find("button.btn-choose").click(function () {
                                    element.click();
                                });
                                $(this).find("button.btn-reset").click(function () {
                                    element.val(null);
                                    $(this).parents(".input-file").find('input').val('');
                                });
                                $(this).find('input').css("cursor", "pointer");
                                $(this).find('input').mousedown(function () {
                                    $(this).parents('.input-file').prev().click();
                                    return false;
                                });
                                return element;
                            }
                        }
                );

            }
            bs_input_file();


            function bs_input_file_green() {


                $(".input-file1").before(
                        function () {
                            if (!$(this).prev().hasClass('input-ghost1')) {
                                var element = $("<input type='file'  id='input-file1' multiple class='input-ghost1' style='visibility:; height:46'>");
                                element.attr("name", $(this).attr("name"));
                                element.change(function () {
                                    element.next(element).find('input').val((element.val()).split('\\').pop());
                                });
                                element.on('change', handleFile);

                                $(this).find("button.btn-choose").click(function () {
                                    element.click();
                                });
                                $(this).find("button.btn-reset").click(function () {
                                    element.val(null);
                                    $(this).parents(".input-file1").find('input').val('');
                                });
                                $(this).find('input').css("cursor", "pointer");
                                $(this).find('input').mousedown(function () {
                                    $(this).parents('.input-file1').prev().click();
                                    return false;
                                });
                                return element;
                            }
                        }
                );

            }

            bs_input_file_green();


            $("#uploadBtn").on("click", function () {

//                var filename = $('input[name="document_file_name"').val();

                var filename = fileName;
                var fileCustd = filename + "," + customer_id;



                var form = $("#sampleUploadFrm")[0];

                var data = new FormData(form);

                var infutdocx = $(".input-file").find('input').val();


                if (infutdocx != null && infutdocx != 'undefined' && infutdocx !== '') {

                    $.ajax({
                        type: "POST",
                        encType: "multipart/form-data",
                        url: "ImageUploadController?filename=" + '' + encodeURIComponent(fileCustd) + '',
                        cache: false,
                        processData: false,
                        contentType: false,
                        data: data,
                        success: function (data) {

                            $('#upload-pending-dialog').data('dialog').close();
                            dialog('Successfully', 'Invoice Uploaded Successfully', 'success');
                            refreshDataTable_${namespace}();


                        },
                        error: function (data) {
                            alert("Couldn't upload file");
                        }
                    });
                } else {
                    alert("Please select the file!");
                }

            });

            $("#uploadGreenBtn").on("click", function () {

//                var filename = $('input[name="document_file_name"').val();

                var filename = fileName;
                var fileCustd = filename + "," + customer_id;



                var form = $("#greenUploadFrm")[0];

                var data = new FormData(form);

                var infutdocx = $(".input-file1").find('input').val();


                if (infutdocx != null && infutdocx != 'undefined' && infutdocx !== '') {

                    $.ajax({
                        type: "POST",
                        encType: "multipart/form-data",
                        url: "GreenCardUploadController?filename=" + '' + encodeURIComponent(fileCustd) + '',
                        cache: false,
                        processData: false,
                        contentType: false,
                        data: data,
                        success: function (data) {

                            $('#green-pending-dialog').data('dialog').close();
                            dialog('Successfully', 'Green Card Uploaded successfully', 'success');
                            refreshDataTable_${namespace}();


                        },
                        error: function (data) {
                            alert("Couldn't upload file");
                        }
                    });
                } else {
                    alert("Please select the file!");
                }

            });



            function initiateYears()
            {
                var d = new Date();

                var thisYear = d.getFullYear();
                var prevYear = d.getFullYear() - 1;
                var nextYear = d.getFullYear() + 1;

                $('#view_appt_year_select').empty();

                var yearsSelect = document.getElementById('view_appt_year_select');
                var opt = document.createElement("option");
                opt.value = 0;
                opt.innerHTML = 'ALL YEARS'; // whatever property it has
                yearsSelect.appendChild(opt);

                opt = document.createElement("option");
                opt.value = prevYear;
                opt.innerHTML = prevYear; // whatever property it has
                yearsSelect.appendChild(opt);

                opt = document.createElement("option");
                opt.value = thisYear;
                opt.innerHTML = thisYear; // whatever property it has
                yearsSelect.appendChild(opt);

                opt = document.createElement("option");
                opt.value = nextYear;
                opt.innerHTML = nextYear; // whatever property it has
                yearsSelect.appendChild(opt);
            }

            function changeYear(year)
            {
                if (year == 0)
                {
                    $('#view_appt_month_select').val(0);
                    document.getElementById("view_appt_month_select").disabled = true;
                } else
                {
                    document.getElementById("view_appt_month_select").disabled = false;
                }
            }

            function viewApptFilter()
            {




                customFilterQuery = "VIEW_JOB,"
                        + $('#view_appt_year_select').val() + ","
                        + $('#view_appt_month_select').val() + ","
                        + $('#driverId').val() + ","
                        + $('#view_appt_status_select').val();

                customFilterQuery = customFilterQuery.replace("\\", "");
                refreshDataTable();
                refreshDataTable_${namespace}();
            }
            function refreshDataTable()
            {
                requireOverallCount = true;

                refreshPageLength();

            }

            function refreshPageLength() {
                var pageLength = "200";

                if (isInteger(pageLength))
                {
                    var table = $('#job-table').DataTable();

                    table.page.len(pageLength).draw();
                } else
                {
                    resetPageLength();
                }
            }

            function showEdit_JobSchedulePestControlView(id)
            {

                var dialog = $('#view-job-dialog').data('dialog');
                $('#form-dialog-title').html('<%=listProperties.getLanguage("edit")%> ' + '<%=listProperties.getLanguage(dataSched.getDisplayName())%>');
                $('#button-save').data('action', 'edit');
                $('#button-save').data('id', id);



                dialog.open();
            }

            function downloadPDF(id)
            {

                var geotagCheck = "E";

                if ($("#input-geotag-pdf-" + id + "").length > 0)
                {
                    if ($("#input-geotag-pdf-" + id + "").is(":checked"))
                    {
                        geotagCheck = "Y";
                    } else
                    {
                        geotagCheck = "N";
                    }
                }

                var pdfdialog = window.open("JobScheduleController?type=plan&action=pdf&id=" + id + "&geotagCheck=" + geotagCheck, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");

                pdfdialog.moveTo(0, 0);

                document.getElementById("downloadPdfButton" + id).style.color = 'white';
                document.getElementById("downloadPdfButton" + id).style.backgroundColor = 'green';
            }

            function jobFunction(customerId)
            {

                var contractId = customerId;

                var conId;

                var tblSched = $('#job-table').DataTable(
                        {

                            dom: 'rtip',
                            pageLength: '30',
                            autoWidth: false,
                            deferRender: true,
                            orderClasses: false,
                            order: [[0, 'desc']], // default sort by job id...
                            columns: [<%=columnListSched%>],
                            processing: true,
                            serverSide: true,
                            responsive: true,
                            ajax: {
                                url: 'JobSchedulePestController?lib=v3nity.std.biz.data.plan&type=JobSchedulePestControlView&format=json&action=view&conId=' + contractId,
                                type: 'POST',
                                data: function (d)
                                {


                                    d.totalRecords = totalRecords;
                                    d.requireOverallCount = requireOverallCount;

                                    d.customFilterQuery = customFilterQuery;
                                },
                                beforeSend: function ()
                                {
                                    $('.toolbar-button').prop("disabled", true);
                                },
                                error: function (xhr, error, thrown)
                                {
                                    dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                                },
                                complete: function ()
                                {
                                    $('.toolbar-button').prop("disabled", false);
                                },
                                dataSrc: function (json)
                                {
                                    var data = json;
                                    if (data.expired === undefined)
                                    {
                                        if (data.result === true)
                                        {
                                            if (data.data !== undefined && data.data.length === 0 && totalRecords !== -1)
                                            {
                                                dialog('No Record', 'No record found', 'alert');
                                            }
                                        } else
                                        {
                                            dialog('Failed', data.text, 'alert');
                                        }
                                    } else
                                    {
                                        $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                        json.data = [];
                                    }

                                    return json.data;
                                }
                            },
                            drawCallback: function (settings)
                            {

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
                                if (tblSched !== undefined)
                                {
                                    if (tblSched.page.info().recordsTotal === 0 && totalRecords !== -1)
                                    {

                                    }

                                    totalRecords_${namespace} = tblSched.page.info().recordsTotal;

                                    if (isNaN(totalRecords))
                                    {
                                        totalRecords = 0;
                                    }

                                    requireOverallCount = false;
                                }
                            },
//                            headerCallback: function (thead, data, start, end, display)
//                            {
//
//                            },
                            createdRow: function (row, data, dataIndex)
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

                if (getBrowser() !== 'ie')
                {
                    tblSched.MakeCellsEditable({
                        'onUpdate': cellEditCallback_${namespace},
                        'inputCss': 'list-input-field',
                        'columns': ${columnEditableArray}
                    });
                }

                //     every ajax call, turn off the draw event otherwise,
                //     all rows will be selected from the table upon selecting buttons within the table.
                //     there is something wrong with the datatable with server side processing.
                tblSched.on('xhr', function ()
                {

                    // this will turn off the event...
                    tblSched.off('draw.dt.dtSelect');

                    // whenever there is a ajax call, unselect all the items...
                    $('#selectAll').removeClass('selected');
                });


                refreshDataTable_${namespace}();

//                refreshDataTable();
//              $('#job-table').DataTable().destroy();

            }


            function openCustomerPage(customer)
            {


                load('CustomerContractController?lib=v3nity.std.biz.data.plan&type=ContractCustomer&searchCustomerForContract=' + customer);
            }


            function cancelStatusSave(id)
            {



                var elements = document.querySelectorAll('input[id^="select-checkbox-"]');
                var idArr = '';
                var idOnly = '';

                for (var i = 0; i < elements.length; i++)
                {
                    if (document.getElementById(elements[i].id).checked)
                    {
                        idOnly = elements[i].id.replace("select-checkbox-", "");
                        idArr += idOnly
                        if (i != elements.length - 1)
                        {
                            idArr += ',';
                        }
                    }
                }
                var cancelReason = $('#inputCancelReason').val();



                $.ajax({
                    type: 'POST',
                    url: 'ContractJobScheduleController',
                    data: {
                        type: 'system',
                        action: 'cancel',
                        scheduleId: idArr,
                        reason: cancelReason
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {

                        var result = data.result;

                        var text = data.text;

                        if (result === true)
                        {
                            $('#cancel-job-dialog').data('dialog').close();
                            dialog('Success', text, 'success');
                            refreshDataTable();
                            refreshDataTable_${namespace}();
                            $("inputCancelReason").val('');
                            clearForm();
                        } else
                        {

                            dialog('Failed', text, 'alert');

                            refreshDataTable();
                        }

                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {

                    },
                    async: true
                });

            }

            function cancelJobSchedule(id) {

                cancelJobId = id;
                $("inputCancelReason").val('');

                $('#cancel-job-dialog').data('dialog').open();

            }

            function  cancelJob() {
                clearForm();
                $("inputCancelReason").val('');
                $('#cancel-job-dialog').data('dialog').close();


            }
            function cancelAddJob
                    () {

                $('#add-job-dialog').data('dialog').close();
            }

            function editJobSchedule(id) {

                editJobScheduleId = id;


                var jobScheduleId;
                // alert(customerName);
                $.ajax(
                        {
                            type: 'POST',
                            url: 'ContractJobScheduleController?action=getEditValue',
                            data: {

                                jobScheduleId: id
                            },
                            beforeSend: function () {
                            },
                            success: function (data)
                            {
                                // $('#pending_reason').val(data.pending_reason_id);

                                var staffValue = data.staffValue;
                                var scheduleDate = data.scheduleDateVale;


                                document.getElementById("technicianId").value = staffValue;
                                document.getElementById("dateTimePicker-schedule_edit_dt").value = scheduleDate;


                                $('#edit-job-dialog').data('dialog').open();


                            },
                            error: function () {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function () {
                            },
                            async: true
                        });

            }

            function editJobSave()
            {


                var jobId = editJobScheduleId;
                var editStaffValue = $('#technicianId').val();
                var editScheduleDate = $('#dateTimePicker-schedule_edit_dt').val();

                $.ajax({
                    type: 'POST',
                    url: 'ContractJobScheduleController',
                    data: {
                        type: 'system',
                        action: 'editJob',
                        scheduleId: jobId,
                        staff_id: editStaffValue,
                        schedule_dt: editScheduleDate

                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {

                        var result = data.result;

                        var text = data.text;

                        if (result === true)
                        {
                            $('#edit-job-dialog').data('dialog').close();
                            dialog('Success', text, 'success');
                            refreshDataTable();
                            refreshDataTable_${namespace}();
                        } else
                        {

                            dialog('Failed', text, 'alert');

                            refreshDataTable();
                        }

                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {

                    },
                    async: true
                });



            }
            function  editScheduleJob() {
                $('#edit-job-dialog').data('dialog').close();

            }
            function checkForRadio()
            {
                $('#day').css("display", "block");

            }
            function checkForRadioOne()
            {
                $('#day').css("display", "none");


            }

            function showCancellationDialog()
            {
                var elements = document.querySelectorAll('input[id^="select-checkbox-"]');
                var idArr = '';
                var idOnly = '';

                for (var i = 0; i < elements.length; i++)
                {
                    if (document.getElementById(elements[i].id).checked)
                    {
                        idOnly = elements[i].id.replace("select-checkbox-", "");
                        idArr += idOnly
                        if (i != elements.length - 1)
                        {
                            idArr += ',';
                        }
                    }
                }

                if (idArr == '')
                {
                    alert('Please select the Job');
                    return;
                }

                var dialog = $('#cancel-job-dialog').data('dialog');
                dialog.open();
            }
            
            // for notification job Start
          $('#dateTimePicker-schedule_dt').add('#driverNameId').add('#one').add('#recurr').add('#dayGiven').change(function() {
             
                        var custId = contractId;
                        
                        var scheduleDate = $('#dateTimePicker-schedule_dt').val();
                        
                        var selectDriver = $('#driverNameId').val();
                        
                        var oneTime ="";
                        
                        var recurrJob ="";
                        
                        var dayInput = $('#dayGiven').val();
                        
                         if ($('#recurr').is(':checked'))
                            {
                                
                            recurrJob = $('#recurr').val();    
                              
                  
                             }
                             
                             if ($('#one').is(':checked'))
                            {
                                
                                  oneTime = $('#one').val();
                  
                             }
                        
                        
    if ((selectDriver != "0" && scheduleDate != ""  && oneTime != ""  ) || (selectDriver != "0" && scheduleDate != ""  && recurrJob != "" && dayInput !="" )  ){
                  
             document.getElementById('staff').innerHTML='';
            $.ajax({
                    type: 'POST',
                    url: 'JobCountController',
                    data: {
                        type: 'system',
                        action: 'notification',
                        Contract_Id: custId,
                        staff_id: selectDriver,
                        schedule_dt: scheduleDate,
                        recurr_job: recurrJob,
                        one_time: oneTime,
                        day_input: dayInput

                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {

                        var result = data.result;

                       

                        if (result === true)
                        {
                         
                          
                          
                                var staffName = data.staffValue;

                                var scheduleDate = data.scheduleDateValue;
                                
                                var jobCount  = data.jobCount;

                               


                                document.getElementById('staff').innerHTML = ''+  staffName+ ' already has '+  jobCount + ' job on  '+  scheduleDate;  
                        } else
                        {

                        }

                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {

                    },
                    async: true
                });

                }

            });


          
           // for notification job end
           
        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <%
            if (data.hasUpload()) {
                request.setAttribute("properties", listProperties);
        %>
        <jsp:include page="list_upload.jsp"/>
        <%
            }
        %>
        <div>
            <h1 class="text-light"><%=listProperties.getLanguage(data.getDisplayName())%></h1>
        </div>
        <div class="toolbar" style="margin: 16px 0">
            <%
                if ((add && data.hasAddButton()) || (update && data.hasEditButton()) || (delete && data.hasDeleteButton())) {
            %>
            <div class="toolbar-section">
                <%
                    if (add && data.hasAddButton()) {
                %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-add name="add" value="" title="<%=listProperties.getLanguage("add")%>"><span class="mif-plus"></span></button>
                    <%
                        }

                        if (update && data.hasEditButton()) {
                    %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-edit name="edit" value="" title="<%=listProperties.getLanguage("edit")%>"><span class="mif-pencil"></span></button>
                    <%
                        }

                        if (delete && data.hasDeleteButton()) {
                    %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-delete name="delete" value="" title="<%=listProperties.getLanguage("delete")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>

                <%
                    if (data.hasDeleteByFilterButton()) {
                %>

                <button class="toolbar-button" type="button" id=${namespace}-tool-button-delete-filter name="delete" value="" title="<%=listProperties.getLanguage("deleteByFilter")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>
            </div>
            <%
                }
            %>

            <%
                if (data.hasCopyButton()) {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("copy")%>" id=${namespace}-tool-button-copy><span class="mif-files-empty"></span></button>
            </div>
            <%
                }
            %>

            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("SelectOrUnselect")%>" onclick="${namespace}_toggleSelect()" id=${namespace}-selectAll><span class="mif-table"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("downloadCSV")%>" onclick="${namespace}_downloadFile()"><span class="text-light text-small">CSV</span></button>

                <%
                    if (data.hasEmailButton()) {
                %>
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("email")%>" onclick="${namespace}_downloadFileEmail()" id=${namespace}-email-button><span class="mif-envelop"></span></button>
                    <%
                        }
                    %>
            </div>

            <%
                if (data.hasCustomFilterButton()) {
            %>

            <div class="toolbar-section">
                <button class="toolbar-button" type="button" onclick="customFilter_${namespace}()"><span class="mif-search"></span></button>
            </div>

            <%
                }
            %>

            <%
                if (data instanceof IDeviceSynchronizable) {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("deviceSync")%>" onclick="deviceSync_${namespace}()" id=${namespace}-button-deviceSync><span class="mif-embed"></span></button>
            </div>
            <%
                }
            %>
            <%
                String toolbarPath = data.toolbarOutputJsp();

                if (!toolbarPath.equals("")) {
                    request.setAttribute("properties", listProperties);

                    pageContext.include(toolbarPath);
                }
            %>
        </div>
        <%
            if (data.hasCustomFilterButton()) {
        %>
        <h3 class="text-light"><%=listProperties.getLanguage("searchBy")%></h3>
        <%
            }
        %>
        <div>
            <%
                ListDataHandler dataHandler = new ListDataHandler(data.getListDataSupport());

                try {
                    dataHandler.setConnection(listProperties.getDatabasePool().getConnection());
            %>
        </div>
        <div id=${namespace}-specific-filter class="grid filter-menu">
            <%
                ListFilter listFilter = new ListFilter(data.getFilterColumns());

                listFilter.outputHtml(data, listProperties, out);

                data.outputFilteringHtml(listProperties, out);
            %>
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
                        if (data.hasSearchBox()) {
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
        <!--            //try upload-->

        <div data-role="dialog" id="upload-pending-dialog" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Upload Invoice</h1>
                <!--                <div class="cell">
                                    <h4 class="text-bold align-left" id="service_order_no"></h4>
                                </div>    -->
                <br/>
                <div class="grid" >
                    <div class="row cells2">
                        <form id="sampleUploadFrm" method="POST" action="#" enctype="multipart/form-data">


                            <div class="form-group" style="float: left; align-content: left; display:table">
                                <div class="input-group input-file"  name="file" id="fileId">

                                    <span class="input-group-btn">
                                        <button class="btn btn-default btn-choose" id="choose1" type="button" style="visibility: hidden;">Choose</button>
                                    </span> 
                                    <input type="text" id="form-control" class="form-control" style="left:30px;pointer-events:none;display:none"
                                           placeholder='Choose a file...'     /> 
                                    <span class="input-group-btn">

                                        <button type="button" class="btn btn-primary " id="uploadBtn" style="margin-left:-55px;">Submit</button>
                                    </span>
                                </div>
                            </div>

                        </form>


                    </div>
                </div>
            </div>
        </div>

        <!--            //try upload-->
        <!--            //try green-->

        <div data-role="dialog" id="green-pending-dialog" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Upload Green Card</h1>
                <!--                <div class="cell">
                                    <h4 class="text-bold align-left" id="service_order_no"></h4>
                                </div>    -->
                <br/>
                <div class="grid" >
                    <div class="row cells2">
                        <form id="greenUploadFrm" method="POST" action="#" enctype="multipart/form-data">


                            <div class="form-group" style="float: left; align-content: left; display:table">
                                <div class="input-group input-file1"  name="file" id="fileId">

                                    <span class="input-group-btn">
                                        <button class="btn btn-default btn-choose" id="choose" type="button" style="visibility: hidden;">Choose</button>
                                    </span> 
                                    <input type="text" id="form-control1" class="form-control1" style="left:30px;pointer-events:none;display:none"
                                           placeholder='Choose a file...'     /> 
                                    <span class="input-group-btn">

                                        <button type="button" class="btn btn-primary " id="uploadGreenBtn" style="margin-left:-55px;">Submit</button>
                                    </span>
                                </div>
                            </div>

                        </form>


                    </div>
                </div>
            </div>
        </div>

        <!--            //try invoic green-->

        <!--         add job start -->
        <div data-role="dialog" id="add-job-dialog" class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog" style="overflow-y: scroll;">
                <h1 class="text-light">ADD JOB</h1>
                <div class="cell">
                    <h4 class="text-bold align-left" id="service_order_no"></h4>
                </div>    
                <br/>
                <form id="form-dialog-data" method="post" action="list.jsp" autocomplete="off">
                    <div class="grid">
                        <%
                            ListForm listForm = new ListForm();

                            listForm.outputHtml(listProperties, data2, dataHandler, out);
                        %>
                        <div class="row cells2">
                            <div class="cell">
                                <label><%=listProperties.getLanguage("jobFormTemplate")%></label>
                                <span style="color: red; font-weight: bold"> *</span>
                                <div class="input-control select full-size">
                                    <select name="inputFormTemplateName" id="inputFormTemplateNameId">
                                        <option value="0">- <%=listProperties.getLanguage("jobFormTemplate")%> -</option>
                                        <%
                                            formTemplateDropDown.outputHTML(out, listProperties);
                                        %>
                                    </select>
                                </div>
                            </div> 
                            <div class="cell">
                                <label><%=listProperties.getLanguage("jobReportTemplate")%></label>
                                <span style="color: red; font-weight: bold"> *</span>
                                <div class="input-control select full-size">
                                    <select name="inputReportTemplateName" id="inputReportTemplateNameId">
                                        <option value="0">- <%=listProperties.getLanguage("jobReportTemplate")%> -</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row cells2">
                            <div class="cell">
                                <label><%=listProperties.getLanguage("technician")%></label>
                                <span style="color: red; font-weight: bold"> *</span>
                                <div class="input-control select full-size">
                                    <select name="driverName" id="driverNameId">
                                        <option value="0">- <%=listProperties.getLanguage("technician")%> -</option>
                                        <%
                                            driverDropDown.outputHTML(out, listProperties);
                                        %>
                                    </select>
                                </div>
                            </div>

                            <div class="cell">
                                <label><%=listProperties.getLanguage("siteAddress")%></label>
                                <span style="color: red; font-weight: bold"> *</span>
                                <div class="input-control select full-size">
                                    <select name="inputSiteAddressName" id="inputSiteAddress">
                                        <option value="0">- <%=listProperties.getLanguage("siteAddress")%> -</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row cells2"  style="top:9px;left:5px;">

                            <input type="radio" id="one" name="choose" onclick="checkForRadioOne()" value="one">
                            <label for="one">One Time</label><br>


                        </div>
                        <div class="row cells2"  style="top:9px;left:5px; margin-bottom: 90px;">

                            <input type="radio" id="recurr" name="choose" onclick="checkForRadio()" value="recur">
                            <label for="recurr">Recurring, every(days)</label><br>
                            <div class="cell" id="day" style="display:none;z-index:5;">
                                <div class="input-control text full-size">
                                    <input type="text" name="input" id="dayGiven" maxlength="50" placeholder="" value="0">
                                </div>
                            </div>

                        </div>
                        <br><br><br>
                        <p id="staff"> </p>
                    </div>
                                    
                </form>
            </div>

            <div class="form-dialog-control">

                <button id="button-save" type="button" class="button primary" onclick="saveJob()"><%=listProperties.getLanguage("save")%></button>
                <button id="button-cancel" type="button" class="button" onclick="cancelAddJob()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <!--         add job end-->

        <!--            view job start-->
        <div data-role="dialog" id="view-job-dialog" class="large" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h4 class="text-light align-left" id="apptInfo"></h4>


                <div class="form-dialog-content" style="margin-top: 50px; float: left;">
                    <div class="grid">
                        <div class="row cells6">
                            <div class="cell">
                                <!--<label>Resource</label><br/>-->
                                <div class="input-control select full-size">
                                    <select id = "view_appt_year_select" onchange="changeYear(this.value)">

                                    </select>
                                </div>
                            </div>

                            <div class="cell">
                                <!--<label>Month</label><br/>-->
                                <div class="input-control select full-size">
                                    <select id = "view_appt_month_select" onchange="">
                                        <option value = "0">ALL MONTHS</option>

                                        <option value = "1">January</option>
                                        <option value = "2">February</option>
                                        <option value = "3">March</option>
                                        <option value = "4">April</option>

                                        <option value = "5">May</option>
                                        <option value = "6">June</option>
                                        <option value = "7">July</option>
                                        <option value = "8">August</option>

                                        <option value = "9">September</option>
                                        <option value = "10">October</option>
                                        <option value = "11">November</option>
                                        <option value = "12">December</option>
                                    </select>
                                </div>
                            </div>
                            <div class="cell">
                                <div class="input-control select full-size">
                                    <select id="driverId"  onchange="">
                                        <option value="0">- <%=listProperties.getLanguage("technician")%> -</option>
                                        <%
                                            driverDropDown.outputHTML(out, listProperties);
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="cell">
                                <!--<label>Day</label><br/>-->
                                <div class="input-control select full-size">
                                    <select id = "view_appt_status_select" onchange="">
                                        <option value = "0">ALL STATUS</option>

                                        <option value = "2">Scheduled</option>
                                        <option value = "7">Started</option>
                                        <option value = "8">Ended</option>
                                        <option value = "11">Cancelled</option>
                                        <option value = "12">Received</option>

                                    </select>
                                </div>
                            </div>


                            <div class="cell">
                                <button id="btnNoPreference" type="button" class="button primary full-size" style="margin-top: 5px" 
                                        onclick="viewApptFilter()"><b>FILTER</b></button>
                            </div>
                        </div>

                        <div class="row cells1">
                            <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id="job-table">
                                <thead>	

                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>

                        <br>
                        <br>
                        <br><br>
                        <br>
                        <br><br>

                    </div>
                </div>

                <div class="form-dialog-control">
                    <button id="btnCancelAppointment" type="button" class="button primary" style="background: #990000;  float: left; margin-left: 20px; border: 0px;" onclick="showCancellationDialog()">Cancel Job</button>

                    <button id="button-cancel" type="button" class="button" onclick="cancelContractJob()"><%=listProperties.getLanguage("close")%></button>
                </div>
            </div>
        </div>
        <!-- cancel job start-->

        <div data-role="dialog" id="cancel-job-dialog" class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">CANCEL JOB</h1>
                <form> 

                    <div class="cell">
                        <label><%=listProperties.getLanguage("cancelReason")%></label>
                        <span style="color: red; font-weight: bold"> *</span>
                        <div class="input-control select full-size">
                            <input type="text" id="inputCancelReason" name="reason" maxlength="8000" placeholder="cancel reason" >
                        </div>
                    </div>
                    <br/>
                </form>
            </div>

            <div class="form-dialog-control">
                <button id="button-save" type="button" class="button primary" onclick="cancelStatusSave()"><%=listProperties.getLanguage("save")%></button>
                <button id="button-cancel" type="button" class="button" onclick="cancelJob()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <!-- cancel job end-->

        <!-- edit job start-->

        <div data-role="dialog" id="edit-job-dialog" class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Edit Job</h1>
                <form>

                    <div class="cell"><label>Schedule Date</label><div class="input-control text full-size" data-role="input"><span class="mif-calendar prepend-icon"></span><input id="dateTimePicker-schedule_edit_dt" name="schedule_dt" type="text" placeholder="Schedule Date" value="" readonly="" style="padding-right: 36px;"><button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button></div><script>$("#dateTimePicker-schedule_edit_dt").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});</script></div>

                    <div class="cell">
                        <label><%=listProperties.getLanguage("technician")%></label>
                        <span style="color: red; font-weight: bold"> *</span>
                        <div class="input-control select full-size">
                            <select id="technicianId"  onchange="">
                                <option value="0">- <%=listProperties.getLanguage("technician")%> -</option>
                                <%
                                    driverDropDown.outputHTML(out, listProperties);
                                %>
                            </select>
                        </div>
                    </div>
                    <br/>
                </form>
            </div>

            <div class="form-dialog-control">
                <button id="button-save" type="button" class="button primary" onclick="editJobSave()"><%=listProperties.getLanguage("save")%></button>
                <button id="button-cancel" type="button" class="button" onclick="editScheduleJob()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>

        <!-- edit job end-->


        <div data-role="dialog" id=${namespace}-form-dialog class="<%=data.getDialogSize()%>" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=${namespace}-form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <div class="form-dialog-description text-light"><%=data.getListFormDescription()%></div>
                    <form id=${namespace}-form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <%
                                Contract contractForm = new Contract();

                                contractForm.outputHtml(listProperties, data, dataHandler, out);
                            %>
                        </div>
                        <div>
                            <%
                                    data.outputHtml(listProperties, out);

                                    String jspPath = data.outputJsp();

                                    if (!jspPath.equals("")) {
                                        request.setAttribute("properties", listProperties);

                                        pageContext.include(jspPath);
                                    }
                                } catch (Exception e) {

                                } finally {
                                    dataHandler.closeConnection();
                                }
                            %>
                        </div>
                    </form>
                    <div id=${namespace}-sub-type></div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=${namespace}-button-save type="button" class="button primary" onclick="${namespace}_saveForm()"><%=listProperties.getLanguage("save")%></button>
                <button id=${namespace}-button-cancel type="button" class="button" onclick="closeForm_${namespace}()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>
    </body>
</html>
