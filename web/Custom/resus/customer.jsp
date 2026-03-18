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

    String lib2 = request.getParameter("lib");

    String type2 = request.getParameter("type");

    System.out.println("testlist.jsp load");
    System.out.println("lib:" + lib2);
    System.out.println("type2" + type2);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <%            data.outputScriptHtml(out);
        %>
        <script type="text/javascript">

            var csv_${namespace} = new csvDownload('ResusCustomerListController?lib=${lib}&type=${type}&action=view', 'V3NITY');

            var totalRecords_${namespace} = -1;

            var requireOverallCount_${namespace} = true;

            var listForm_${namespace};

            var customFilterQuery_${namespace} = [];

            var listFields = [];

            $(document).ready(function ()
            {
                if (typeof ${namespace}ListForm !== 'undefined' && typeof ${namespace}ListForm === 'function')
                {
                    listForm_${namespace} = new ${namespace}ListForm('${namespace}-specific-filter');
                } else
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
                                url: 'ResusCustomerListController?lib=${lib}&type=${type}&format=json&action=view',
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

                                            if (typeof ondatasuccess === 'function')
                                            {
                                                ondatasuccess();
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
                            select: <%=(data.hasSelection()) ? "{ style: 'single' }" : "{}"%>,
                            buttons: [
                                'selectAll',
                                'selectNone',
                                'csv'
                            ],
                            language: {
                                info: '<%=listProperties.getLanguage("showing")%>' + ' _START_ ' + '<%=listProperties.getLanguage("to")%>'.toLowerCase() + ' _END_ ' + '<%=listProperties.getLanguage("of")%>'.toLowerCase() + ' _TOTAL_ ' + '<%=listProperties.getLanguage("entries")%>'.toLowerCase() + ' ',
                                infoEmpty: '<%=listProperties.getLanguage("showing")%>' + ' 0 ' + '<%=listProperties.getLanguage("to")%>'.toLowerCase() + ' 0 ' + '<%=listProperties.getLanguage("of")%>'.toLowerCase() + ' 0 ' + '<%=listProperties.getLanguage("entries")%>'.toLowerCase() + ' ',
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
                        url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=edit',
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
                            url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=delete',
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

                // we need to dispose the callback function otherwise other jsp will get affected...
                ondatasuccess = null;
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
                    url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=sync',
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
                        url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=email&format=csv',
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
                    $('#${namespace}-sub-type').load('ResusCustomerListController?lib=${lib}&type=<%=subType%>&filter=' + id + '&foreignKey=<%=subTypeForeignKey%>');
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

                    var id = $('#${namespace}-button-save').data('id');

                    if (id === undefined)
                    {
                        id = 0;
                    }

                    $.ajax({
                        type: 'POST',
                        url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=' + action + '&id=' + id,
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
                    } else if (element.tagName.toLowerCase() === 'textarea')
                    {
                        element.value = "";
                    }
                }

                /*
                 * perform custom form reset...
                 */
                listForm_${namespace}.reset();

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

                clearForm_${namespace}();
            }

            function getData_${namespace}(id)
            {
                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=data',
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

            function delete_${namespace}(id)
            {
                var c = confirm("Are you sure you want to delete?");

                if (c === true)
                {
                    $.ajax({
                        type: 'POST',
                        url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=delete',
                        data: {
                            id: id
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', data.text, 'success');

                                    refreshPageLength_${namespace}();
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

                        },
                        async: true
                    });
                }
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

            function influencerChanged()
            {
                if (this.value === '')
                {
                    return;
                }

                var metadataIndex = $(this).attr('data-influenced-metadata-index');

                $.ajax({
                    type: 'POST',
                    url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=influence',
                    data: {
                        index: metadataIndex,
                        foreign: this.value
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                var element = $('select[name="' + data.identifier + '"');

                                element.html('');

                                for (var i = 0; i < data.options.length; i++)
                                {
                                    var option = data.options[i];

                                    element.append('<option value=' + option.id + '>' + option.value + '</option>');
                                }
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

                    },
                    async: false
                });
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
                            url: 'ResusCustomerListController?lib=${lib}&type=${type}&action=deleteByFilter',
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
        </script>
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
            <h1 class="text-light"><%=listProperties.getLanguage(data.getDisplayName())%><span id='list-sub-title'></span></h1>
        </div>
        <%
            if (!data.getCustomizedPage().equals("")) {
        %>
        <jsp:include page="<%=data.getCustomizedPage()%>"/>
        <%
            }
        %>
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
            <%
                if (data.hasSelection()) {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("SelectOrUnselect")%>" onclick="${namespace}_toggleSelect()" id=${namespace}-selectAll><span class="mif-table"></span></button>
            </div>
            <%
                }
            %>
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
        <%
            ListDataHandler dataHandler = new ListDataHandler(data.getListDataSupport());

            try {
                dataHandler.setConnection(listProperties.getDatabasePool().getConnection());
        %>
        <div id=${namespace}-specific-filter class="grid filter-menu">
            <%
                ListFilter listFilter = new ListFilter(data.getFilterColumns(), (String) request.getAttribute("namespace"));

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
        <div data-role="dialog" id=${namespace}-form-dialog class="<%=data.getDialogSize()%>" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=${namespace}-form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <div class="form-dialog-description text-light"><%=data.getListFormDescription()%></div>
                    <form id=${namespace}-form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <%
                                ListForm listForm = new ListForm();

                                listForm.outputHtml(listProperties, data, dataHandler, out);
                            %>                           
                        </div>
                        
                        <div class="row cells">
                            <div class="cell">
                                <label>Company Name</label>
                                <div class="input-control text full-size"><input type="text" name="company_name" maxlength="300" placeholder="" value=""></div>
                            </div>
                        </div>
                        
                        <div class="row cells">
                            <div class="cell">
                                <label>Company Address</label>
                                <div class="input-control text full-size" style="height: auto;">
                                    <textarea data-role="textarea"></textarea>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row cells2">
                            <div class="cell"><label>Contact Person</label><div class="input-control text full-size"><input type="text" name="customer_name" maxlength="300" placeholder="" value=""></div></div>
                            <div class="cell"><label>Contact Number</label><div class="input-control text full-size"><input type="text" name="customer_name" maxlength="300" placeholder="" value=""></div></div>
                        </div>
                        
                        <div class="row cells2">
                            <div class="cell"><label>Email</label><div class="input-control text full-size"><input type="text" name="customer_name" maxlength="300" placeholder="" value=""></div></div>
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
                                    e.printStackTrace();
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
