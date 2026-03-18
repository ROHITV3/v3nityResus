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

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <script type="text/javascript">

            var csv_expense = new csvDownload('ExpenseController?lib=${lib}&type=${type}&action=view', 'V3NITY');

            var totalRecords_expense = -1;

            var requireOverallCount_expense = true;

            var listForm_expense;

            var customFilterQuery_expense = [];

            var listFields = [];

            $(document).ready(function()
            {
                if (typeof expenseListForm !== 'undefined' && typeof expenseListForm === 'function')
                {
                    listForm_expense = new expenseListForm('expense-specific-filter');
                }
                else
                {
                    listForm_expense = new ListForm('expense-specific-filter');
                }

                var tbl = $('#expense-result-table').DataTable(
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
                           
                            url: 'ExpenseController??format=json&action=view',
                            type: 'POST',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords_expense;
                                d.requireOverallCount = requireOverallCount_expense;
                                d.customFilterQuery = JSON.stringify(customFilterQuery_expense);
                                d.filter = '${filter}';
                                d.foreignKey = '${foreignKey}';
                                d.visibleColumnIndexes = listForm_expense.getColumns();
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

                                        if (data.data !== undefined && data.data.length === 0 && totalRecords_expense !== -1)
                                        {
                                            dialog('No Record', 'No record found', 'alert');
                                        }
                                    }
                                    else
                                    {
                                        dialog('Search Failed', data.text, 'alert');

                                        // we need this for the data-table to read...
                                        json.data = [];
                                    }
                                }
                                else
                                {
                                    // we need this for the data-table to read...
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
                                if (tbl.page.info().recordsTotal === 0 && totalRecords_expense !== -1)
                                {

                                }

                                totalRecords_expense = tbl.page.info().recordsTotal;

                                if (isNaN(totalRecords_expense))
                                {
                                    totalRecords_expense = 0;
                                }

                                requireOverallCount_expense = false;
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
                        'onUpdate': cellEditCallback_expense,
                        'inputCss': 'list-input-field',
                        'columns': ${columnEditableArray}
                    });
                }

                //     every ajax call, turn off the draw event otherwise,
                //     all rows will be selected from the table upon selecting buttons within the table.
                //     there is something wrong with the datatable with server side processing.
                tbl.on('xhr', function()
                {

                    // this will turn off the event...
                    tbl.off('draw.dt.dtSelect');

                    // whenever there is a ajax call, unselect all the items...
                    $('#expense-selectAll').removeClass('selected');
                });
            });

            function cellEditCallback_expense(cell, row, oldValue)
            {

                if (cell.data() !== oldValue)
                {
                    var table = $('#expense-result-table').DataTable();

                    var colIndex = cell.index().column;

                    var fieldname = table.settings().init().columns[colIndex].name;

                    var dataEdit = {'id': row.id()};

                    dataEdit[fieldname] = cell.data();

                    $.ajax({
                        type: 'POST',
                        url: 'ExpenseController?lib=${lib}&type=${type}&action=edit',
                        data: dataEdit,
                        success: function(data)
                        {

                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {

                                    dialog('Success', data.text, 'success');

                                    cell.data(cell.data()).draw();

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
                        async: true
                    });
                }
            }

            $("input[id^=dateTimePicker]").change(function()
            {

                $('#expense-email-button').prop("disabled", false);
            });

            $("#expense-tool-button-add").click(function()
            {
                showAdd_expense();
            });

            $("#expense-tool-button-edit").click(function()
            {
                var table = $('#expense-result-table').DataTable();
                var data = table.rows('.selected').ids();
                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Warning', 'Please aware that you have selected more than one records', 'warning');
                    }

                    var id = data.join();
                    alert(id);
                    showEdit_expense(id);
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            });

            $("#expense-tool-button-delete").click(function()
            {
                var table = $('#expense-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        var ids = data.join();

                        $.ajax({
                            type: 'POST',
                            url: 'ExpenseController?lib=${lib}&type=${type}&action=delete',
                            data: {
                                id: ids
                            },
                            beforeSend: function()
                            {
                                $('#expense-button-save').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength_expense();

                                        closeForm_expense();
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
                                $('#expense-button-save').prop("disabled", false);
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

            $("#expense-tool-button-copy").click(function()
            {
                var table = $('#expense-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    if (data.length > 1)
                    {
                        dialog('Warning', 'Please aware that you have selected more than one records', 'warning');
                    }

                    var id = data.join();

                    showCopy_expense(id);
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
                }
            });

            function dispose()
            {
                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function(index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            }

            function expense_toggleSelect()
            {
                if ($('#expense-selectAll').hasClass('selected'))
                {
                    $('#expense-result-table').DataTable().button(1).trigger();
                    $('#expense-selectAll').removeClass('selected');
                }
                else
                {
                    $('#expense-result-table').DataTable().button(0).trigger();
                    $('#expense-selectAll').addClass('selected');
                }
            }

            function expense_searchData()
            {
                var searchText = $('#expense-search-data').val();

                requireOverallCount_expense = true;

                $('#expense-result-table').DataTable().search(searchText).draw();
            }

            function refreshDataTable_expense()
            {
                requireOverallCount_expense = true;

                refreshPageLength_expense();
            }

            function refreshPageLength_expense()
            {
                var pageLength = $('#expense-page-length').val();

                if (isInteger(pageLength))
                {
                    var table = $('#expense-result-table').DataTable();

                    table.page.len(pageLength).draw();
                }
                else
                {
                    resetPageLength_expense();
                }
            }

            function resetPageLength_expense()
            {
                var table = $('#expense-result-table').DataTable();

                // reset default value in page length control...
                $('#expense-page-length').val(${pageLength});

                // reset search box...
                $('#expense-search-data').val('');

                // reset table search...
                table.search('');

                // reset default page length...
                table.page.len(${pageLength}).draw();
            }

            function deviceSync_expense()
            {
                $.ajax({
                    type: 'POST',
                    url: 'ExpenseController?lib=${lib}&type=${type}&action=sync',
                    data: $('#expense-form-dialog-data').serialize(),
                    beforeSend: function()
                    {
                        $('#expense-button-deviceSync').prop("disabled", true);
                    },
                    success: function(data)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
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
                        $('#expense-button-deviceSync').prop("disabled", false);
                    },
                    async: true
                });
            }

            function expense_downloadFile()
            {
                csv_expense.startDownload(20000, {customFilterQuery: JSON.stringify(listForm_expense.filter()), visibleColumnIndexes: listForm_expense.getColumns()});
            }

            function expense_downloadFileEmail()
            {
                var prefix = getPrefix();

                if (prefix !== '')  // must select at least 1 asset...
                {
                    var options = {
                        customFilterQuery: JSON.stringify(listForm_expense.filter()),
                        emailTitle: 'V3NITY REPORT',
                        filePrefix: '<%=data.getDisplayName().toUpperCase()%>_' + prefix + '_'
                    };

                    var result;

                    $.ajax({
                        type: 'POST',
                        url: 'ExpenseController?lib=${lib}&type=${type}&action=email&format=csv',
                        data: options,
                        async: true,
                        success: function(data)
                        {
                            if (data.expired === undefined)
                            {
                                result = data.result;
                                if (result)
                                {
                                    dialog('Report Download', 'Download link will be sent via email when report is ready for download', 'success');

                                }
                                else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                                $('#expense-email-button').prop("disabled", false);
                            }
                        },
                        beforeSend: function()
                        {
                            $('#expense-email-button').prop("disabled", true);
                        }
                    });
                }
                else
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
                    }
                    else
                    {
                        return ids.split(',').length + 'assets';
                    }
                }
                else
                {
                    return '';
                }
            }

            function loadSubType_expense(id)
            {
            <%
                if (metaDataSubType != null)
                {
                    String subType = metaDataSubType.getForeignListClass().getSimpleName();

                    String subTypeForeignKey = metaDataSubType.getForeignKeyName();

                    String subTypeDisplayName = listProperties.getLanguage(metaDataSubType.getDisplayName());
            %>
                if (id === -1)
                {
                    $('#expense-sub-type').html('<p class="note">Please save and click edit to manage <%=subTypeDisplayName%>.</p>');
                }
                else
                {
                    $('#expense-sub-type').load('ExpenseController?lib=${lib}&type=<%=subType%>&filter=' + id + '&foreignKey=<%=subTypeForeignKey%>');
                }
            <%
                }
            %>
            }

            function expense_saveForm()
            {
                if (listForm_expense.save())
                {
                    var action = $('#expense-button-save').data('action');

                    var id = $('#expense-button-save').data('id');

                    if (id === undefined)
                    {
                        id = 0;
                    }

                    $.ajax({
                        type: 'POST',
                        url: 'ExpenseController?lib=${lib}&type=${type}&action=' + action + '&id=' + id,
                        data: $('#expense-form-dialog-data').serialize(),
                        beforeSend: function()
                        {
                            $('#expense-button-save').prop("disabled", true);
                        },
                        success: function(data)
                        {
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {

                                    dialog('Success', data.text, 'success');

                                    refreshPageLength_expense();

                                    closeForm_expense();
                                }
                                else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            }
                            else
                            {
                                closeForm_expense();
                            }
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            $('#expense-button-save').prop("disabled", false);
                        },
                        async: true
                    });
                }
                else
                {
                    dialog('Error', listForm_expense.saveError, 'alert');
                }
            }

            function showAdd_expense()
            {
                var dialog = $('#expense-form-dialog').data('dialog');

                $('#expense-form-dialog-title').html('<%=listProperties.getLanguage("add")%> ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                $('#expense-button-save').data('action', 'add');

                clearForm_expense();

                loadSubType_expense(-1);

                dialog.open();
            }

            function showEdit_expense(id)
            {
                if (getData_expense(id))
                {
                    alert("javascript")
                    var dialog = $('#expense-form-dialog').data('dialog');
                    $('#expense-form-dialog-title').html('<%=listProperties.getLanguage("edit")%> ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                    $('#expense-button-save').data('action', 'edit');
                    $('#expense-button-save').data('id', id);

                    loadSubType_expense(id);

                    dialog.options.onDialogClose = dialogClose;

                    dialog.open();
                }
            }

            function showCopy_expense(id)
            {
                if (getData_expense(id))
                {
                    var dialog = $('#expense-form-dialog').data('dialog');
                    $('#expense-form-dialog-title').html('<%=listProperties.getLanguage("copy")%> ' + '<%=listProperties.getLanguage(data.getDisplayName())%>');
                    $('#expense-button-save').data('action', 'add');
                    $('#expense-button-save').data('id', id);

                    loadSubType_expense(id);

                    dialog.options.onDialogClose = dialogClose;

                    dialog.open();
                }
            }

            function dialogClose(dialog)
            {
                clearForm_expense();
            }

            function clearForm_expense()
            {
                /*
                 * perform form reset manually...
                 */
                var frm = document.getElementById('expense-form-dialog-data');

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
                    }
                    else if (element.tagName.toLowerCase() === 'select')
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
                listForm_expense.reset();

                listFields.forEach(function(value, index)
                {
                    value.clear();
                });
            }

            function closeForm_expense()
            {

            <%
                if (metaDataSubType != null)
                {
                    String subType = metaDataSubType.getForeignListClass().getSimpleName();
            %>
                // we need to unload the datetime picker of the sub class because if not, when the dialog opens again it will load redundantly and cause error.
                $('#<%=subType%>-form-dialog').find('[id^="dateTimePicker"]').each(function(index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            <%
                }
            %>

                $('#expense-form-dialog').data('dialog').close();

                clearForm_expense();
            }

            function getData_expense(id)
            {
                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'ExpenseController?lib=${lib}&type=${type}&action=data',
                    data: {
                        id: id
                    },
                    success: function(data, status, request)
                    {
                        alert(JSON.stringify(data))
                        if (request.getResponseHeader('content-type').includes('json'))
                        {
                            populateForm_expense(data);

                            listForm_expense.populate(data);

                            result = true;
                        }
                        else
                        {
                            $('body').html(data);
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });

                return result;
            }

            function populateForm_expense(result)
            {
                $.each(result.data, function(i, field)
                {
                    if (field.type === 'text')
                    {
                        $('input[name=' + field.name + ']').val(field.value);
                    }
                    else if (field.type === 'textarea')
                    {
                        $('textarea[name=' + field.name + ']').val(field.value);
                    }
                    else if (field.type === 'selection')
                    {
                        if (field.value === 0)
                        {
                            $('select[name=' + field.name + ']').val('').trigger('change');
                        }
                        else
                        {
                            $('select[name=' + field.name + ']').val(field.value).trigger('change');
                        }
                    }
                    else if (field.type === 'searchable')
                    {
                        $('input[name=' + field.name + ']').val(field.value);

                        $('#list-data-field-' + field.name).val(field.text);
                    }
                    else if (field.type === 'checkbox')
                    {
                        $('input[name=' + field.name + ']').prop('checked', field.value);
                    }
                    else if (field.type === 'html')
                    {

                    }
                });
            }

            function customFilter_expense()
            {
                customFilterQuery_expense = listForm_expense.filter();

                refreshDataTable_expense();
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

            $("#expense-tool-button-delete-filter").click(function()
            {
                if (customFilterQuery_expense.length > 0 && totalRecords_expense > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'ExpenseController?lib=${lib}&type=${type}&action=deleteByFilter',
                            data: {
                                filterQuery: JSON.stringify(customFilterQuery_expense)
                            },
                            beforeSend: function()
                            {
                                $('#expense-tool-button-delete-filter').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength_expense();

                                        closeForm_expense();
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
                                $('#expense-tool-button-delete-filter').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'default');
                }
            });

        </script>
        <%
            data.outputScriptHtml(out);
        %>
    </head>
    <body>
        <%
            if (data.hasUpload())
            {
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
                if ((add && data.hasAddButton()) || (update && data.hasEditButton()) || (delete && data.hasDeleteButton()))
                {
            %>
            <div class="toolbar-section">
                <%
                    if (add && data.hasAddButton())
                    {
                %>
                <button class="toolbar-button" type="button" id=expense-tool-button-add name="add" value="" title="<%=listProperties.getLanguage("add")%>"><span class="mif-plus"></span></button>
                    <%
                        }

                        if (update && data.hasEditButton())
                        {
                    %>
                <button class="toolbar-button" type="button" id=expense-tool-button-edit name="edit" value="" title="<%=listProperties.getLanguage("edit")%>"><span class="mif-pencil"></span></button>
                    <%
                        }

                        if (delete && data.hasDeleteButton())
                        {
                    %>
                <button class="toolbar-button" type="button" id=expense-tool-button-delete name="delete" value="" title="<%=listProperties.getLanguage("delete")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>

                <%
                    if (data.hasDeleteByFilterButton())
                    {
                %>

                <button class="toolbar-button" type="button" id=expense-tool-button-delete-filter name="delete" value="" title="<%=listProperties.getLanguage("deleteByFilter")%>"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>
            </div>
            <%
                }
            %>

            <%
                if (data.hasCopyButton())
                {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("copy")%>" id=expense-tool-button-copy><span class="mif-files-empty"></span></button>
            </div>
            <%
                }
            %>

            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("SelectOrUnselect")%>" onclick="expense_toggleSelect()" id=expense-selectAll><span class="mif-table"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("downloadCSV")%>" onclick="expense_downloadFile()"><span class="text-light text-small">CSV</span></button>

                <%
                    if (data.hasEmailButton())
                    {
                %>
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("email")%>" onclick="expense_downloadFileEmail()" id=expense-email-button><span class="mif-envelop"></span></button>
                    <%
                        }
                    %>
            </div>

            <%
                if (data.hasCustomFilterButton())
                {
            %>

            <div class="toolbar-section">
                <button class="toolbar-button" type="button" onclick="customFilter_expense()"><span class="mif-search"></span></button>
            </div>

            <%
                }
            %>

            <%
                if (data instanceof IDeviceSynchronizable)
                {
            %>
            <div class="toolbar-section">
                <button class="toolbar-button" type="button" title="<%=listProperties.getLanguage("deviceSync")%>" onclick="deviceSync_expense()" id=expense-button-deviceSync><span class="mif-embed"></span></button>
            </div>
            <%
                }
            %>
            <%
                String toolbarPath = data.toolbarOutputJsp();

                if (!toolbarPath.equals(""))
                {
                    request.setAttribute("properties", listProperties);

                    pageContext.include(toolbarPath);
                }
            %>
        </div>
        <%
            if (data.hasCustomFilterButton())
            {
        %>
        <h3 class="text-light"><%=listProperties.getLanguage("searchBy")%></h3>
        <%
            }
        %>
        <div>
            <%
                ListDataHandler dataHandler = new ListDataHandler(data.getListDataSupport());

                try
                {
                    dataHandler.setConnection(listProperties.getDatabasePool().getConnection());
            %>
        </div>
        <div id=expense-specific-filter class="grid filter-menu">
            <%
                ListFilter listFilter = new ListFilter(data.getFilterColumns());

                listFilter.outputHtml(data, listProperties, out);

                data.outputFilteringHtml(listProperties, out);
            %>
            <div class="row cells2">
                <div class="cell">
                    <div class="list-show-result-control">
                        <div class="input-control text" style="margin: 0">
                            <input id=expense-page-length type="text" value="${pageLength}" maxlength="3">
                            <div class="button-group">
                                <button class="button" id=expense-refresh name="refresh" value="" title="<%=listProperties.getLanguage("refresh")%>" onclick="refreshPageLength_expense()"><span class="mif-loop2"></span></button>
                                <button class="button" id=expense-resetForm name="resetForm" value="" title="<%=listProperties.getLanguage("reset")%>" onclick="resetPageLength_expense()"><span class="mif-undo"></span></button>
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
                            <input id=expense-search-data type="text" placeholder="<%=listProperties.getLanguage("searchKeyword")%>"/>
                            <button id=expense-searchDataButton class="button" onclick="expense_searchData('search-data')"><span class="mif-search"></span></button>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id=expense-result-table>
            <thead>

            </thead>
            <tbody>

            </tbody>
        </table>
        <div data-role="dialog" id=expense-form-dialog class="<%=data.getDialogSize()%>" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=expense-form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <div class="form-dialog-description text-light"><%=data.getListFormDescription()%></div>
                    <form id=expense-form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">
                            <%
                                ListForm listForm = new ListForm();

                                listForm.outputHtml(listProperties, data, dataHandler, out);
                            %>
                        </div>
                        <div>
                            <%
                                    data.outputHtml(listProperties, out);

                                    String jspPath = data.outputJsp();

                                    if (!jspPath.equals(""))
                                    {
                                        request.setAttribute("properties", listProperties);

                                        pageContext.include(jspPath);
                                    }
                                }
                                catch (Exception e)
                                {

                                }
                                finally
                                {
                                    dataHandler.closeConnection();
                                }
                            %>
                        </div>
                    </form>
                    <div id=expense-sub-type></div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=expense-button-save type="button" class="button primary" onclick="expense_saveForm()"><%=listProperties.getLanguage("save")%></button>
                <button id=expense-button-cancel type="button" class="button" onclick="closeForm_expense()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>
    </body>
</html>
