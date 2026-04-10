<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.cust.biz.resus.data.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    ListData data = (ListData) request.getAttribute("data");

    MetaData metaDataSubType = (MetaData) request.getAttribute("metaDataSubType");

    boolean add = (boolean) request.getAttribute("add");

    boolean update = (boolean) request.getAttribute("update");

    boolean delete = (boolean) request.getAttribute("delete");

    int userId = listProperties.getUser().getId();

    String domainUrl = listProperties.getSystemProperties().getDomainURL();

    ResusCustomerDropDown resusCustomerDropDown = new ResusCustomerDropDown(listProperties);
    resusCustomerDropDown.setIdentifier("dropdown-resus-customer");
    resusCustomerDropDown.loadData(listProperties);

    ResusQuotationDescDropDown resusQuotationDescDropDown = new ResusQuotationDescDropDown(listProperties);
    resusQuotationDescDropDown.setIdentifier("dropdown-quotation-desc");
    resusQuotationDescDropDown.loadData(listProperties);

    ResusQuotationContactPsnDropDown resusQuotationContactPsnDropDown = new ResusQuotationContactPsnDropDown(listProperties);
    resusQuotationContactPsnDropDown.setIdentifier("dropdown-quotation-contactPsn");
    resusQuotationContactPsnDropDown.loadData(listProperties);

    ResusQuotationTypeDropDown resusQuotationTypeDropDown = new ResusQuotationTypeDropDown(listProperties);
    resusQuotationTypeDropDown.setIdentifier("dropdown-quotation-type");
    resusQuotationTypeDropDown.loadData(listProperties);

    ResusCostCentreDropDown resusCostCentreDropDown = new ResusCostCentreDropDown(listProperties);
    resusCostCentreDropDown.setIdentifier("dropdown-cost-centre-customer");
    resusCostCentreDropDown.loadData(listProperties);

    ResusJobshetOrderTypeDropDown resusOrderTypeDropDown = new ResusJobshetOrderTypeDropDown(listProperties);
    resusOrderTypeDropDown.setIdentifier("dropdown-jobsheet-order-type");
    resusOrderTypeDropDown.loadData(listProperties);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />

        <title>${title}</title>
        <%            data.outputScriptHtml(out);
        %>
        <style>
            #container {
                width: 100%;
                height: 100%;
                position: relative;
            }

            #map-view {
                position: absolute;
                top: 0;
                left: 0;
            }

            #infoi {
                top: 48px;
                right: 8px;
                z-index: 10;
            }

            .cap-box{
                float: left;
                height: 30px;
                padding: 3px;

                border-radius: 5px;
                background: #87CEFA;
                margin-right: 5px;
                margin-top: 3px;
            }

            .single-cap{
                float: left;
                height: 20px;
                line-height: 20px;
                font-size: 14px;
                margin-left: 3px;
            }

            .cap-icon{
                float: left;
                width: 20px;
                height: 20px;
                margin-left: 5px;

                background: url("img/bin.png") no-repeat;
                background-position: center;
                background-size: 80%;

                cursor: pointer;
            }

            .cap-icon:hover{
                background: url("img/bin_hover_2.png") no-repeat;
                background-position: center;
                background-size: 80%;
            }


            .add-box{
                float: left;
                clear: both;
                height: 30px;
                padding: 5px;
                color: #000;

                border-radius: 5px;
                border-width: 1px;
                border-style: solid;
                border-color: #aaa;

                background: #ddd;
                margin-top: 10px;

                -webkit-transition:background 0.3s;
                -moz-transition:background 0.3s;
                -o-transition:background 0.3s;
                transition:background 0.3s;

            }

            .single-add{
                float: left;
                height: 20px;
                line-height: 20px;
                font-size: 14px;
                font-weight: bold;

                margin-left: 3px;
                margin-right: 5px;
            }

            .add-icon{
                float: left;
                width: 20px;
                height: 20px;

                background: url("img/add.png") no-repeat;
                background-position: center;
                background-size: 80%;

                cursor: pointer;
            }

            .add-box:hover{
                color: #fff;
                background: #007700;
                cursor: pointer;
            }

            select:invalid {
                color: gray;
            }

            .confirm-icon{
                float: left;
                width: 30px;
                height: 30px;
                margin-top: 5px;

                background: url("img/ic_confirm.png") no-repeat;
                background-position: center;
                background-size: 80%;

                cursor: pointer;
            }
            .confirm-icon:hover{
                background: url("img/ic_confirm_hover.png") no-repeat;
                background-position: center;
                background-size: 80%;
            }

            .cancel-icon{
                float: left;
                width: 30px;
                height: 30px;
                margin-top: 5px;

                background: url("img/ic_cancel.png") no-repeat;
                background-position: center;
                background-size: 80%;

                cursor: pointer;
            }
            .cancel-icon:hover
            {
                background: url("img/ic_cancel_hover.png") no-repeat;
                background-position: center;
                background-size: 80%;
            }

            label{
                font-size: 16px;
                font-weight: bold;
            }

            .waste-type{
                margin-right: 10px;
            }

            .waste-type .caption{
                font-size: 12px;
            }

            .float-left{
                float:left;
            }


        </style>
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">

        <script src="js/metro.js"></script>
        <script type="text/javascript">

            var csv_${namespace} = new csvDownload('ListController?lib=${lib}&type=${type}&action=view', 'V3NITY');

            var totalRecords_${namespace} = -1;

            var requireOverallCount_${namespace} = true;

            var listForm_${namespace};

            var customFilterQuery_${namespace} = [];

            var filterLoaded_${namespace} = false;

            var treeFilterQuery_${namespace} = [];
            var finalFilterQuery_${namespace} = [];

            var listFields = [];
            var tbl;

            $(document).ready(function ()
            {


                $('select[name=dropdownCustomer]').on('change', function ()
                {
                    console.log("Onchange customer : " + $('select[name=dropdownCustomer]').val());
                    $.ajax({
                        type: 'POST',
                        url: 'ResusQuotationController',
                        data: {
                            type: 'plan',
                            action: 'getCustomerDetails',
                            resusCustomerId: $('select[name=dropdownCustomer]').val()
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            $('textarea[name=company_name]').val(data.header);
                            $('input[name=customer_name]').val(data.attentionTo);
                            $('input[name=designation]').val(data.designation);
                            $('textarea[name=billing_address]').val(data.address);
                            $('input[name=tel_no]').val(data.contactNumber);
                            $('textarea[name=email]').val(data.email);
                            postalCode = data.postalCode;
                            console.log('postalCode : ' + postalCode);

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
                });

                if (typeof ${namespace}ListForm !== 'undefined' && typeof ${namespace}ListForm === 'function')
                {
                    listForm_${namespace} = new ${namespace}ListForm('${namespace}-specific-filter');
                } else
                {
                    listForm_${namespace} = new ListForm('${namespace}-specific-filter');
                }

                tbl = $('#${namespace}-result-table').DataTable(
                        {
                            dom: 'rtip',
                            pageLength: 20000,
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
                                url: 'ListController?lib=${lib}&type=${type}&format=json&action=view',
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
                                    console.log("FULL RESPONSE:", json);
                                    console.log("TABLE DATA:", json.data);
//                                console.log("FIRST ROW:", json.data[0]);
//                                  // 🔥 Populate filter only once
//           // 🔥 Populate filter only once
//    if (!filterLoaded_${namespace}) {
//        // Make sure json.data is an array
//        const tableData = Array.isArray(json.data) ? json.data : [];
//        populateColumnFilters_${namespace}(tableData);
//        filterLoaded_${namespace} = true;
//    }
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
                // existing xhr event (keep it)
                tbl.on('xhr', function () {

                    // turn off draw event
                    tbl.off('draw.dt.dtSelect');

                    // unselect all
                    $('#${namespace}-selectAll').removeClass('selected');
                });


// ✅ ADD THIS SEPARATELY (NO COMMA)
                tbl.on('xhr', function (e, settings, json) {


                    const tableData = Array.isArray(json.data) ? json.data : [];

                    populateDropdowns_${namespace}(tableData);
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
                        url: 'ListController?lib=${lib}&type=${type}&action=edit',
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
                    url: 'ListController?lib=${lib}&type=${type}&action=sync',
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
                        url: 'ListController?lib=${lib}&type=${type}&action=email&format=csv',
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
                    $('#${namespace}-sub-type').load('ListController?lib=${lib}&type=<%=subType%>&filter=' + id + '&foreignKey=<%=subTypeForeignKey%>');
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
                        url: 'ListController?lib=${lib}&type=${type}&action=' + action + '&id=' + id,
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
                    url: 'ListController?lib=${lib}&type=${type}&action=data',
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


                let listFilters = listForm_${namespace}.filter() || [];
                let treeFilters = treeFilterQuery_${namespace} || [];

                let merged = [];

                listFilters.forEach(function (lf) {
                    merged.push(lf);
                });

                treeFilters.forEach(function (tf) {

                    merged = merged.filter(function (f) {
                        return f.field !== tf.field;
                    });

                    merged.push(tf);
                });

                customFilterQuery_${namespace} = merged;

                console.log("Final Filters:", merged);

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

            function previewJobsheet() {

                var pdfName = $('#button-view').data('pdf');

                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }

                let creatorUserIdPreview = <%=listProperties.getUser().getId()%>;
                let company_name = $('textarea[name=company_name]').val();
                let postal_code = $('input[name=postal_code]').val();
                let customer_name = $('input[name=customer_name]').val();
                let designation = $('input[name=designation]').val();
                let tel_no = $('input[name=tel_no]').val();
                let fax_no = $('input[name=fax_no]').val();
                let date_of_commencement = $('input[name=dateTimePicker_date_of_commencement]').val();
                let date_of_completion = $('input[name=dateTimePicker_date_of_completion]').val();
                let purchase_order = $('input[name=purchase_order]').val();
                let payment_term = $('input[name=payment_term]').val();
                let cost_centre = $('input[name=cost_centre]').val();
//                let cost_centre_dropdown = $("#dropdownCostCentreId option:selected").text();
//                if ($("#dropdownCostCentreId option:selected").val()==='0'){
//                    cost_centre_dropdown = '';
//                }
                let amount = $('input[name=amount]').val();
                let approved_by = $('input[name=approved_by]').val();
                let completed_by = $('input[name=completed_by]').val();
                let job_description = $('textarea[name=job_description]').val();
                let billing_address = $('textarea[name=billing_address]').val();
                let remarks = $('textarea[name=remarks]').val();
                let email = $('textarea[name=email]').val();

                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'savePreviewJobsheet',
                        company_name: company_name,
                        postal_code: postal_code,
                        customer_name: customer_name,
                        designation: designation,
                        tel_no: tel_no,
                        fax_no: fax_no,
                        date_of_commencement: date_of_commencement,
                        date_of_completion: date_of_completion,
                        purchase_order: purchase_order,
                        payment_term: payment_term,
                        cost_centre: cost_centre,
                        job_description: job_description,
                        remarks: remarks,
                        amount: amount,
                        approved_by: approved_by,
                        completed_by: completed_by,
                        address: billing_address,
                        email: email,
                        creatorUserIdPreview: creatorUserIdPreview,
                        jobsheet_document: pdfName

                    },
                    beforeSend: function ()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            console.log("data.result true with id " + data.id);
                            var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadJobsheetPreview&id=" + data.id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                            pdfdialog.moveTo(0, 0);

                        } else
                        {
                            dialog('Failed', data.text, 'alert');
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
                    async: false
                });

            }

            function getJobsheetData(id)
            {
                console.log('getJobsheetData');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: id
                    },
                    success: function (data)
                    {
                        result = true;
                        $('input[name=company_name]').val(data.jobsheet_company_name);
                        $('input[name=postal_code]').val(data.jobsheet_billing_postal_code);
                        $('input[name=customer_name]').val(data.jobsheet_billing_contact_person);
                        $('input[name=designation]').val(data.jobsheet_billing_designation);
                        $('input[name=tel_no]').val(data.jobsheet_billing_tel_no);
                        $('input[name=fax_no]').val(data.jobsheet_billing_fax_no);
                        $('input[name=dateTimePicker_date_of_commencement]').val(data.jobsheet_date_start);
                        $('input[name=dateTimePicker_date_of_completion]').val(data.jobsheet_date_end);
                        $('input[name=purchase_order]').val(data.jobsheet_po);
                        $('input[name=payment_term]').val(data.jobsheet_payment_terms);
                        $('input[name=cost_centre]').val(data.jobsheet_cost_centre);
                        $('input[name=amount]').val(data.jobsheet_amount);
                        $('input[name=approved_by]').val(data.jobsheet_approved_by);
                        $('input[name=completed_by]').val(data.jobsheet_completed_by);
                        $('textarea[name=job_description]').val(data.jobsheet_job_description);
                        $('textarea[name=billing_address]').val(data.jobsheet_billing_address);
                        $('textarea[name=remarks]').val(data.jobsheet_remarks);
                        $('textarea[name=email]').val(data.jobsheet_billing_email);
                        $('#button-view').data('pdf', data.jobsheet_document);
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

            function closeAddJobsheet()
            {
                refreshDataTable();
                $('#${namespace}-form-dialog').data('dialog').close();
                clearJobsheetDataInDialog();
            }

            function endJobsheet(id, jobsheetNo)
            {
                console.log('id : ' + id);
                console.log('jobsheetNo : ' + jobsheetNo);
                $('textarea[name=closeRemarks]').val('');
                $('#closeQuotation-dialog-title').html('Close Jobsheet - ' + jobsheetNo);
                $('#button-void-quotation').show();
                $('#button-void-quotation').data('id', id);
                $('#closeQuotation-dialog').data('dialog').open();
            }

            function cancelEndJobsheet() {
                $('#closeQuotation-dialog').data('dialog').close();
            }

            function closeJobsheet()
            {
                var jobsheetId = $('#button-void-quotation').data('id');

                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController?type=plan&action=closeJobsheet',
                    data:
                            {
                                jobsheetId: jobsheetId,
                                remarks: $('textarea[name=closeRemarks]').val(),
                            },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', 'Jobsheet Closed', 'success');
                            } else
                            {
                                dialog('Failed', 'Unable to close jobsheet', 'alert');
                            }
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    async: true
                });
                $('#closeQuotation-dialog').data('dialog').close();
            }

            function clearJobsheetDataInDialog() {
                $('select[name=dropdownCustomer]').val(0);
                $('input[name=company_name]').val('');
                $('input[name=postal_code]').val('');
                $('input[name=customer_name]').val('');
                $('input[name=designation]').val('');
                $('input[name=tel_no]').val('');
                $('input[name=fax_no]').val('');
                $('input[name=dateTimePicker_date_of_commencement]').val('');
                $('input[name=dateTimePicker_date_of_completion]').val('');
                $('input[name=purchase_order]').val('');
                $('input[name=payment_term]').val('');
                $('input[name=cost_centre]').val('');
                $('input[name=amount]').val('');
                $('input[name=approved_by]').val('');
                $('input[name=completed_by]').val('');
                $('textarea[name=job_description]').val('');
                $('textarea[name=billing_address]').val('');
                $('textarea[name=remarks]').val('');
                $('textarea[name=email]').val('');
                $('#button-view').data('pdf', '');
            }

            function refreshDataTable()
            {
                requireOverallCount = true;

                //refreshPageLength_ResusJobsheet();
                refreshPageLength_${namespace}();

            }

            function refreshPageLength()
            {
                var pageLength = $('#page-length').val();

                if (isInteger(pageLength))
                {
                    var table = $('#${namespace}-result-table').DataTable();

                    table.page.len(pageLength).draw();
                } else
                {
                    //refreshPageLength_ResusJobsheet();
                    refreshPageLength_${namespace}();
                }
            }

            function getJobsheetData(id)
            {
                console.log('getJobsheetData');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: jobsheetId
                    },
                    success: function (data)
                    {
                        result = true;
                        $('textarea[name=company_name]').val(data.jobsheet_company_name);
                        $('input[name=postal_code]').val(data.jobsheet_billing_postal_code);
                        $('input[name=customer_name]').val(data.jobsheet_billing_contact_person);
                        $('input[name=designation]').val(data.jobsheet_billing_designation);
                        $('input[name=tel_no]').val(data.jobsheet_billing_tel_no);
                        $('input[name=fax_no]').val(data.jobsheet_billing_fax_no);
                        $('input[name=dateTimePicker_date_of_commencement]').val(data.jobsheet_date_start);
                        $('input[name=dateTimePicker_date_of_completion]').val(data.jobsheet_date_end);
                        $('input[name=purchase_order]').val(data.jobsheet_po);
                        $('input[name=payment_term]').val(data.jobsheet_payment_terms);
                        $('input[name=cost_centre]').val(data.jobsheet_cost_centre);
//                        var dd = document.getElementById('dropdownCostCentreId');
//                        var cost_centre_found = false;
//                        for (var i = 0; i < dd.options.length; i++) {
//                            if (dd.options[i].text === data.jobsheet_cost_centre) {
//                            dd.selectedIndex = i;
//                            cost_centre_found = true;
//                            break;
//                            }
//                        }
//                        console.log("cost center found : " + cost_centre_found);
//                        if (!cost_centre_found){
//                            $('select[name=dropdownCostCentre]').val(0);
//                        }

                        $('input[name=amount]').val(data.jobsheet_amount);
                        //amount = data.jobsheet_amount;
                        $('input[name=approved_by]').val(data.jobsheet_approved_by);
                        $('input[name=completed_by]').val(data.jobsheet_completed_by);
                        $('textarea[name=job_description]').val(data.jobsheet_job_description);
                        $('textarea[name=billing_address]').val(data.jobsheet_billing_address);
                        $('textarea[name=remarks]').val(data.jobsheet_remarks);
                        $('textarea[name=email]').val(data.jobsheet_billing_email);
                        //quotationId = data.jobsheet_quotation_id;
                        console.log('data.jobsheet_document ' + data.jobsheet_document);
                        $('#button-view').data('pdf', data.jobsheet_document);

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

            function getJobsheetEmailOnlyForSignOFf(id)
            {
                console.log('getJobsheetData');
                let result = false;


                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: id
                    },
                    success: function (data)
                    {
                        result = true;
                        $('textarea[name=signOffTextArea]').val(data.jobsheet_billing_email);
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

            function downloadJobsheet(id) {
                var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadJobsheet&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function sendForAuthorize(id) {
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationController',
                    data: {
                        type: 'plan',
                        action: 'sendForAuthorize',
                        id: id
                    },
                    beforeSend: function () {
                        return confirm("Are you sure you want to send this quotation for authorization?");
                    },
                    success: function (data)
                    {
                        refreshDataTable();
                        if (data.result === true) {
                            dialog('Success', 'Quotation is sent for authorization', 'success');
                        } else {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error a', 'alert');
                    },
                    async: false
                });
            }

            function signOffJobsheet(id, jobsheetNo) {

                let link = '<%=domainUrl%>' + "jobsheetSignoff?id=" + id;

                var table = $('#${namespace}-result-table').DataTable();

                const dtrow = table.row('#' + id);

                var testColIndexStatus = table.column(':contains(Job Sheet Status Type)');
                var testColIndexRefNo = table.column(':contains(Ref Number)');

                var columnStatusData = table.cell(dtrow[0], testColIndexStatus[0]).data();
                console.log('columnStatusData : ' + columnStatusData);
                //var columnRefNoData = table.cell(dtrow[0], testColIndexRefNo[0]).data();

                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#signoff-dialog-title').html('Signoff JS No:' + jobsheetNo);
                $('#signoff-dialog-content').html('');
                $('#signoff-dialog').animate({width: '550px', height: '200px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').hide();
                getJobsheetEmailOnlyForSignOFf(id);

                if (columnStatusData.includes('New') || columnStatusData.includes('Edited') || columnStatusData.includes('Revised') || columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }

                if (columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-recall').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }

                if (columnStatusData.includes('Approved')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                }

                $('#button-close').show();
                $('#signoff-dialog').data('dialog').open();
            }

            function closeSignoffForm() {
                $('#signoff-dialog').data('dialog').close();
            }

            function signOffEmail() {
                $('#button-yes').data('action', 'signOffByEmail');
                $('#signoff-dialog-content').html('Sign Off By Email?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffLink() {
                $('#button-yes').data('action', 'signOffByLink');
                $('#signoff-dialog-content').html('Sign Off By Link?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('textarea[name=signOffTextArea]').val("");
                //$('#signoff-dialog').animate({width: '600px', height: '300px'});
                //$('textarea[name=signOffTextArea]').show();
            }
            function noSignOff() {
                $('#button-yes').data('action', 'noSignOff');
                $('#signoff-dialog-content').html('No Sign Off Needed?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffVoid() {
                $('#button-yes').data('action', 'signOffVoid');
                $('#signoff-dialog-content').html('Void Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffRecall() {
                $('#button-yes').data('action', 'signOffRecall');
                $('#signoff-dialog-content').html('Recall Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function selectYesSignoff() {

                var id = $('#button-yes').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: $('#button-yes').data('action'),
                        data: $('textarea[name=signOffTextArea]').val(),
                        id: id
                    },
                    success: function (data)
                    {
                        if (data.result === true) {
                            //refreshDataTable_${namespace}();
                            refreshDataTable();
                            jobsheetShowResultViaPromptBeforeClose();
                        } else {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error a', 'alert');
                    },
                    async: false
                });
            }

            function jobsheetShowResultViaPromptBeforeClose() {
                console.log('jobsheetShowResultViaPromptBeforeClose');
                let action = $('#button-yes').data('action');
                if (action === 'signOffByEmail') {
                    $('#signoff-dialog-content').html('Email is sent to customer');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffByLink') {
                    let urlLink = $('#button-link').data('link');
                    $('#signoff-dialog-content').html('Please copy and send this link to customer : <br>');
                    $('#signoff-dialog').animate({width: '600px', height: '300px'});
                    $('textarea[name=signOffTextArea]').val(urlLink);
                    $('textarea[name=signOffTextArea]').show();
                } else if (action === 'noSignOff') {
                    $('#signoff-dialog-content').html('Jobsheet is close without sign off');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffVoid') {
                    $('#signoff-dialog-content').html('Jobsheet Void');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffRecall') {
                    $('#signoff-dialog-content').html('Jobsheet recalled');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                }
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#button-close').show();
            }

            function selectNoSignoff() {
                $('#signoff-dialog').data('dialog').close();
            }

            function copyUrl() {
                let urlLink = $('#button-link').data('link');
                navigator.clipboard.writeText(urlLink);
                alert("Copied the link " + urlLink);
            }

            function downloadJobsheet(id) {
                var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadJobsheet&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            function clearUpload() {
                const file = document.querySelector('.file');
                file.value = '';
            }

            $('#button-clear').on('click', function () {
                $('#button-view').data('pdf', '');
                $('#button-view').hide();
                $('#button-clear').hide();
            });

            $('#button-add-attachment').on('click', function () {
                $('#file').click();
                return false;
            });

            let fileUpload = document.getElementById("file");
            fileUpload.onchange = function () {
                let now = new Date();
                let year = now.getFullYear();
                let month = now.getMonth() + 1;
                let day = now.getDate();
                let hour = now.getHours();
                let minute = now.getMinutes();
                let second = now.getSeconds();
                if (month.toString().length == 1) {
                    month = '0' + month;
                }
                if (day.toString().length == 1) {
                    day = '0' + day;
                }
                if (hour.toString().length == 1) {
                    hour = '0' + hour;
                }
                if (minute.toString().length == 1) {
                    minute = '0' + minute;
                }
                if (second.toString().length == 1) {
                    second = '0' + second;
                }

                let uploaderUserId = <%=listProperties.getUser().getId()%>;

                let filename = uploaderUserId + '_' + year + '_' + month + '_' + day + '_' + hour + '_' + minute + '_' + second;

                let filenameWithType = filename + '.pdf';

                let fd = new FormData();
                let file = $('#file')[0].files[0];
                fd.append('file', file, filenameWithType);

                $.ajax({
                    url: 'ResusJobsheetController?type=plan&action=uploadJobsheetAttachment',
                    type: 'post',
                    data: fd,
                    contentType: false,
                    processData: false,
                    success: function (data) {
                        if (data.result === true) {
                            dialog('Success', 'Attachment Uploaded', 'success');
                            $('#button-view').data('pdf', filenameWithType);
                            //show button
                            $('#button-view').show();
                            $('#button-clear').show();
                        } else {
                            dialog('Failed', 'Failed Uploading Attachement', 'alert');
                        }
                    },
                });
            };

            $('#button-view').on('click', function () {
                var pdfName = $('#button-view').data('pdf');
                console.log('View Attachment : ' + pdfName);
                var pdfdialog = window.open("ResusJobsheetController?type=plan&action=downloadAttachment&filename=" + pdfName, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            });

            function saveJobsheetForm()
            {
                //addJobSheetDataWithQuotation
                //editJobSheetDataWithQuotation
                //console.log("Add|Edit for Ref ID" + quotationRefInit);
                var action = $('#button-save').data('action');
                var jobsheetId = $('#button-save').data('jobsheetId');
                var quotationId = $('#button-save').data('quotationId');
                console.log("action : " + action);
                console.log("jobsheetId : " + jobsheetId);
                console.log("quotationId : " + quotationId);


                var pdfName = $('#button-view').data('pdf');
                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }
                console.log("pdfName : " + pdfName);

                if ($('textarea[name=company_name]').val().trim().length === 0) {
                    dialog('Error', 'Please key in company name', 'alert');
                    return;
                }
                if ($('textarea[name=billing_address]').val().trim().length === 0) {
                    dialog('Error', 'Please key in billing address', 'alert');
                    return;
                }
                if ($('input[name=customer_name]').val().trim().length === 0) {
                    dialog('Error', 'Please key in customer name', 'alert');
                    return;
                }
                if ($('input[name=tel_no]').val().trim().length === 0) {
                    dialog('Error', 'Please key in telephone number', 'alert');
                    return;
                }
                if ($('textarea[name=email]').val().trim().length === 0) {
                    dialog('Error', 'Please key in email', 'alert');
                    return;
                }
                if ($('input[name=dateTimePicker_date_of_commencement]').val().trim().length === 0) {
                    dialog('Error', 'Please key in date of commencement', 'alert');
                    return;
                }
                if ($('input[name=dateTimePicker_date_of_completion]').val().trim().length === 0) {
                    dialog('Error', 'Please key in date of completion', 'alert');
                    return;
                }
                if (action === 'addJobSheetDataWithQuotation' || action === 'editJobSheetDataWithQuotation') {
                    if ($('select[name=dropdownOrderType]').val() === '0') {
                        dialog('Error', 'Please select Job Order Type', 'alert');
                        return;
                    }
                }
                if ($('textarea[name=job_description]').val().trim().length === 0) {
                    dialog('Error', 'Please key in the job description', 'alert');
                    return;
                }
                if ($('input[name=amount]').val().trim().length === 0) {
                    dialog('Error', 'Please key in the amount', 'alert');
                    return;
                }
                if ($('input[name=completed_by]').val().trim().length === 0) {
                    dialog('Error', 'Please key in completed by', 'alert');
                    return;
                }


                let jobsheetType = 'withQuotation';
//                if ($('input[name="partialCheckBox"]').prop("checked") === false) {
//                    jobsheetType = 'withQuotation';
//                } else {
//                    jobsheetType = 'partial';
//                }

                let company_name = $('textarea[name=company_name]').val();
                let postal_code = $('input[name=postal_code]').val();
                let customer_name = $('input[name=customer_name]').val();
                let designation = $('input[name=designation]').val();
                let tel_no = $('input[name=tel_no]').val();
                let fax_no = $('input[name=fax_no]').val();
                let date_of_commencement = $('input[name=dateTimePicker_date_of_commencement]').val();
                let date_of_completion = $('input[name=dateTimePicker_date_of_completion]').val();
                let purchase_order = $('input[name=purchase_order]').val();
                let payment_term = $('input[name=payment_term]').val();
                let cost_centre = $('input[name=cost_centre]').val();
                let orderTypeId = $('select[name=dropdownOrderType]').val();
                let amount = $('input[name=amount]').val();
                let approved_by = $('input[name=approved_by]').val();
                let completed_by = $('input[name=completed_by]').val();
                let job_description = $('textarea[name=job_description]').val();
                let billing_address = $('textarea[name=billing_address]').val();
                let remarks = $('textarea[name=remarks]').val();
                let email = $('textarea[name=email]').val();
                let jobsheetCreatorId = <%=userId%>;

                //Create JobSheet
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: action,
                        jobsheet_type: jobsheetType,
                        jobsheet_quotation_id: quotationId,
                        company_name: company_name,
                        postal_code: postal_code,
                        customer_name: customer_name,
                        designation: designation,
                        tel_no: tel_no,
                        fax_no: fax_no,
                        date_of_commencement: date_of_commencement,
                        date_of_completion: date_of_completion,
                        purchase_order: purchase_order,
                        payment_term: payment_term,
                        cost_centre: cost_centre,
                        order_type_id: orderTypeId,
                        job_description: job_description,
                        remarks: remarks,
                        amount: amount,
                        approved_by: approved_by,
                        completed_by: completed_by,
                        address: billing_address,
                        email: email,
                        id: jobsheetId,
                        operatorId: jobsheetCreatorId,
                        jobsheetDoc: pdfName
                    },
                    beforeSend: function ()
                    {
                        //$('#button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.result === true)
                        {
                            dialog('Success', data.text, 'success');
                            //After adding jobsheet, use the jobsheet id and update the resus_job table
                            console.log('Jobsheet Id with quotation:' + data.jobsheetId);
                            if (action === 'addJobSheetDataWithQuotation') {
                                updateJobWhenAdd(data.jobsheetId);
                                updateQuotationJobAssigned(data.jobsheetId, quotationId);
                            }
                            if (action === 'editJobSheetDataWithQuotation') {
                                updateJobWhenEdit(data.jobsheetId);
                                updateQuotationJobAssigned(data.jobsheetId, quotationId);
                            }
                            refreshDataTable();
                            closeAddJobsheet();
                            //If save from Add jobsheet (Must not have refreshJobsheetDataTable if not will have issues as the table is not initialized)
                            //If save from View jobsheet-Edit (Need to have refreshJobsheetDataTable)
                            if (action === 'editJobSheetDataWithQuotation') {
                                refreshJobsheetDataTable();
                            }

                        } else
                        {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        //$('#button-save').prop("disabled", false);  
                    },
                    async: false
                });
            }

            //To edit Job Sheet tied to the quotation
            function editJobSheet(jobsheetId)
            {
                $('select[name=dropdownCostCentre]').val(0);
                //get jobsheet data
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: jobsheetId
                    },
                    success: function (data)
                    {
                        result = true;
                        $('textarea[name=company_name]').val(data.jobsheet_company_name);
                        $('input[name=postal_code]').val(data.jobsheet_billing_postal_code);
                        $('input[name=customer_name]').val(data.jobsheet_billing_contact_person);
                        $('input[name=designation]').val(data.jobsheet_billing_designation);
                        $('input[name=tel_no]').val(data.jobsheet_billing_tel_no);
                        $('input[name=fax_no]').val(data.jobsheet_billing_fax_no);
                        $('input[name=dateTimePicker_date_of_commencement]').val(data.jobsheet_date_start);
                        $('input[name=dateTimePicker_date_of_completion]').val(data.jobsheet_date_end);
                        $('input[name=purchase_order]').val(data.jobsheet_po);
                        $('input[name=payment_term]').val(data.jobsheet_payment_terms);
                        $('input[name=cost_centre]').val(data.jobsheet_cost_centre);
                        $('select[name=dropdownOrderType]').val(data.jobsheet_order_type_id);
//                        var dd = document.getElementById('dropdownCostCentreId');
//                        var cost_centre_found = false;
//                        for (var i = 0; i < dd.options.length; i++) {
//                            if (dd.options[i].text === data.jobsheet_cost_centre) {
//                            dd.selectedIndex = i;
//                            cost_centre_found = true;
//                            break;
//                            }
//                        }
//                        console.log("cost center found : " + cost_centre_found);
//                        if (!cost_centre_found){
//                            $('select[name=dropdownCostCentre]').val(0);
//                        }
                        $('input[name=amount]').val(data.jobsheet_amount);
                        $('input[name=approved_by]').val(data.jobsheet_approved_by);
                        $('input[name=completed_by]').val(data.jobsheet_completed_by);
                        $('textarea[name=job_description]').val(data.jobsheet_job_description);
                        $('textarea[name=billing_address]').val(data.jobsheet_billing_address);
                        $('textarea[name=remarks]').val(data.jobsheet_remarks);
                        $('textarea[name=email]').val(data.jobsheet_billing_email);
                        console.log('data.jobsheet_document ' + data.jobsheet_document);
                        $('#button-view').data('pdf', data.jobsheet_document);

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
                $('#button-save').data('action', 'editJobSheetDataWithoutQuotation');
                $('#button-save').data('jobsheetId', jobsheetId);

                var pdfName = $('#button-view').data('pdf');
                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }
                if (pdfName === '') {
                    $('#button-view').hide();
                    $('#button-clear').hide();
                } else {
                    $('#button-view').show();
                    $('#button-clear').show();
                }

                console.log('editJobSheet');
                console.log('jobsheetId:' + jobsheetId);
                //console.log('refNo : ' + quotationRef)
                document.getElementsByClassName('form-dialog')[0].style.visibility = 'visible';
                $('#${namespace}-form-dialog').data('dialog').open();
            }

            //To edit Job Sheet tied to the quotation
            function uploadJobSheetAttachement(jobsheetId)
            {
                $('select[name=dropdownCostCentre]').val(0);
                //get jobsheet data
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: 'getJobsheetData',
                        id: jobsheetId
                    },
                    success: function (data)
                    {
                        result = true;
                        $('textarea[name=company_name]').val(data.jobsheet_company_name);
                        $('input[name=postal_code]').val(data.jobsheet_billing_postal_code);
                        $('input[name=customer_name]').val(data.jobsheet_billing_contact_person);
                        $('input[name=designation]').val(data.jobsheet_billing_designation);
                        $('input[name=tel_no]').val(data.jobsheet_billing_tel_no);
                        $('input[name=fax_no]').val(data.jobsheet_billing_fax_no);
                        $('input[name=dateTimePicker_date_of_commencement]').val(data.jobsheet_date_start);
                        $('input[name=dateTimePicker_date_of_completion]').val(data.jobsheet_date_end);
                        $('input[name=purchase_order]').val(data.jobsheet_po);
                        $('input[name=payment_term]').val(data.jobsheet_payment_terms);
                        $('input[name=cost_centre]').val(data.jobsheet_cost_centre);
//                        var dd = document.getElementById('dropdownCostCentreId');
//                        var cost_centre_found = false;
//                        for (var i = 0; i < dd.options.length; i++) {
//                            if (dd.options[i].text === data.jobsheet_cost_centre) {
//                            dd.selectedIndex = i;
//                            cost_centre_found = true;
//                            break;
//                            }
//                        }
//                        console.log("cost center found : " + cost_centre_found);
//                        if (!cost_centre_found){
//                            $('select[name=dropdownCostCentre]').val(0);
//                        }
                        $('input[name=amount]').val(data.jobsheet_amount);
                        $('input[name=approved_by]').val(data.jobsheet_approved_by);
                        $('input[name=completed_by]').val(data.jobsheet_completed_by);
                        $('textarea[name=job_description]').val(data.jobsheet_job_description);
                        $('textarea[name=billing_address]').val(data.jobsheet_billing_address);
                        $('textarea[name=remarks]').val(data.jobsheet_remarks);
                        $('textarea[name=email]').val(data.jobsheet_billing_email);
                        console.log('data.jobsheet_document ' + data.jobsheet_document);
                        $('#button-view').data('pdf', data.jobsheet_document);
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
                $('#button-save').data('action', 'editUploadAttachment');
                $('#button-save').data('jobsheetId', jobsheetId);

                var pdfName = $('#button-view').data('pdf');
                if (pdfName === undefined || pdfName === null) {
                    pdfName = '';
                }
                if (pdfName === '') {
                    $('#button-view').hide();
                    $('#button-clear').hide();
                } else {
                    $('#button-view').show();
                    $('#button-clear').show();
                }

                console.log('editJobSheet');
                console.log('jobsheetId:' + jobsheetId);
                //console.log('refNo : ' + quotationRef)
                document.getElementsByClassName('form-dialog')[0].style.visibility = 'hidden';
                $('#${namespace}-form-dialog').data('dialog').open();
            }

            function signOffJobsheet(id, jobsheetNo) {

                let link = '<%=domainUrl%>' + "jobsheetSignoff?id=" + id;

                var table = $('#${namespace}-result-table').DataTable();

                const dtrow = table.row('#' + id);

                var testColIndexStatus = table.column(':contains(Status)');
                var testColIndexRefNo = table.column(':contains(Ref Number)');

                var columnStatusData = table.cell(dtrow[0], testColIndexStatus[0]).data();
                //console.log('columnStatusData : ' + columnStatusData[1]);
                var columnRefNoData = table.cell(dtrow[0], testColIndexRefNo[0]).data();

                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#signoff-dialog-title').html('Signoff JS No:' + jobsheetNo);
                $('#signoff-dialog-content').html('');
                $('#signoff-dialog').animate({width: '550px', height: '200px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').hide();
                getJobsheetEmailOnlyForSignOFf(id);

                if (columnStatusData.includes('New') || columnStatusData.includes('Edited') || columnStatusData.includes('Revised') || columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }

                if (columnStatusData.includes('Pending Approval')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                    $('#button-recall').show();
                    $('#button-email').show();
                    $('#button-link').show();
                    $('#button-nosignoff').show();
                    $('#button-no').hide();
                    $('#button-yes').hide();
                }

                if (columnStatusData.includes('Approved')) {
                    $('#button-yes').data('id', id);
                    $('#button-email').data('id', id);
                    $('#button-email').data('link', link);
                    $('#button-link').data('id', id);
                    $('#button-link').data('link', link);
                    $('#button-nosigning').data('id', id);
                    $('#button-void').show();
                }

                $('#button-close').show();
                $('#signoff-dialog').data('dialog').open();
            }

            function closeSignoffForm() {
                $('#signoff-dialog').data('dialog').close();
            }

            function signOffEmail() {
                $('#button-yes').data('action', 'signOffByEmail');
                $('#signoff-dialog-content').html('Sign Off By Email?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffLink() {
                $('#button-yes').data('action', 'signOffByLink');
                $('#signoff-dialog-content').html('Sign Off By Link?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('textarea[name=signOffTextArea]').val("");
                //$('#signoff-dialog').animate({width: '600px', height: '300px'});
                //$('textarea[name=signOffTextArea]').show();
            }
            function noSignOff() {
                $('#button-yes').data('action', 'noSignOff');
                $('#signoff-dialog-content').html('No Sign Off Needed?');
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffVoid() {
                $('#button-yes').data('action', 'signOffVoid');
                $('#signoff-dialog-content').html('Void Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function signOffRecall() {
                $('#button-yes').data('action', 'signOffRecall');
                $('#signoff-dialog-content').html('Recall Job Sheet?');
                $('#button-void').hide();
                $('#button-recall').hide();
                $('#button-email').hide();
                $('#button-link').hide();
                $('#button-nosignoff').hide();
                $('#button-close').hide();
                $('#button-no').show();
                $('#button-yes').show();
                $('#signoff-dialog').animate({width: '600px', height: '300px'});
                $('textarea[name=signOffTextArea]').val("");
                $('textarea[name=signOffTextArea]').show();
            }
            function selectYesSignoff() {

                var id = $('#button-yes').data('id');
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetController',
                    data: {
                        type: 'plan',
                        action: $('#button-yes').data('action'),
                        data: $('textarea[name=signOffTextArea]').val(),
                        id: id
                    },
                    success: function (data)
                    {
                        if (data.result === true) {
                            //refreshDataTable_${namespace}();
                            refreshDataTable();
                            jobsheetShowResultViaPromptBeforeClose();
                        } else {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error a', 'alert');
                    },
                    async: false
                });
            }

            function jobsheetShowResultViaPromptBeforeClose() {
                console.log('jobsheetShowResultViaPromptBeforeClose');
                let action = $('#button-yes').data('action');
                if (action === 'signOffByEmail') {
                    $('#signoff-dialog-content').html('Email is sent to customer');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffByLink') {
                    let urlLink = $('#button-link').data('link');
                    $('#signoff-dialog-content').html('Please copy and send this link to customer : <br>');
                    $('#signoff-dialog').animate({width: '600px', height: '300px'});
                    $('textarea[name=signOffTextArea]').val(urlLink);
                    $('textarea[name=signOffTextArea]').show();
                } else if (action === 'noSignOff') {
                    $('#signoff-dialog-content').html('Jobsheet is close without sign off');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffVoid') {
                    $('#signoff-dialog-content').html('Jobsheet Void');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                } else if (action === 'signOffRecall') {
                    $('#signoff-dialog-content').html('Jobsheet recalled');
                    $('textarea[name=signOffTextArea]').hide();
                    $('#signoff-dialog').animate({width: '600px', height: '150px'});
                }
                $('#button-no').hide();
                $('#button-yes').hide();
                $('#button-close').show();
            }

            function selectNoSignoff() {
                $('#signoff-dialog').data('dialog').close();
            }

            function extractText(value) {

                if (!value)
                    return "";

                let temp = $('<div>').html(value);

                return temp.text().trim();
            }

            function populateDropdowns_${namespace}(data) {

                const creatorSet = new Set();
                const statusSet = new Set();

                data.forEach(function (row) {
                    if (row[3])
                        creatorSet.add(extractText(row[3]));
                    if (row[6])
                        statusSet.add(extractText(row[6]));
                });

               
                treeFilterQuery_${namespace} = [];

                
                loadIdsFromBackend("jobsheet_creator", Array.from(creatorSet), "creatorTree");
                loadIdsFromBackend("jobsheet_status_type", Array.from(statusSet), "statusTree");
            }

            function loadIdsFromBackend(field, names, containerId) {

                $.ajax({
                    type: "POST",
                    url: "ResusQuotationController",
                    data: {
                        type: 'plan',
                        action: "getIdsByNames",
                        field: field,
                        names: JSON.stringify(names)
                    },
                    success: function (res) {

                        console.log("API SUCCESS:", res);

                        if (res && res.data) {
                            buildMetroTree(containerId, field, res.data);
                        } else {
                            console.log("No data received");
                        }
                    },
                    error: function (err) {
                        console.log("ERROR:", err);
                    }
                });
            }


            function buildMetroTree(containerId, field, values) {

                var html = '';

                html += '<li data-mode="checkbox" class="node">';
                html += '<label class="input-control checkbox small-check">';
                html += '<input type="checkbox"><span class="check"></span></label>';
                html += '<span class="leaf text-bold">Select All</span>';
                html += '<span class="node-toggle"></span>';
                html += '<ul>';

                values.forEach(function (obj) {

                    html += '<li data-mode="checkbox" data-value="' + obj.id + '">';
                    html += '<label class="input-control checkbox small-check">';
                    html += '<input type="checkbox"><span class="check"></span></label>';
                    html += '<span class="leaf">' + obj.name + '</span>';
                    html += '</li>';
                });

                html += '</ul></li>';

                $('#' + containerId).find('ul').html(html);

                if (window.Metro) {
                    Metro.init();
                }
            }
            function getTreeSelectedValues_${namespace}(field) {

                var values = [];

                $('[name="' + field + '"] .treeview li[data-value]').each(function () {

                    if ($(this).find('input[type="checkbox"]').prop('checked')) {
                        values.push($(this).attr('data-value')); // ✅ ID
                    }
                });

                return values;
            }

            $(document).on('click', '.treeview li', function () {

                var container = $(this).closest('.tree-container');
                var field = container.attr('name');

                setTimeout(function () {
                    var selectedValues = getTreeSelectedValues_${namespace}(field);

                    // remove old
                    treeFilterQuery_${namespace} =
                            treeFilterQuery_${namespace} || [];
                    treeFilterQuery_${namespace} = treeFilterQuery_${namespace}.filter(function (f) {
                        return f.field !== field;
                    });

                    // add new
                    if (selectedValues.length > 0) {
                        treeFilterQuery_${namespace}.push({
                            field: field,
                            type: "Integer",
                            operator: "IN",
                            value: selectedValues
                        });
                    }

                    console.log("Tree Filters:", treeFilterQuery_${namespace});

                    // 🔹 merge with listform filters and refresh table
                    // customFilter_${namespace}();

                }, 10);
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
        <div id=${namespace}-specific-filter class="grid filter-menu">
            <%
                ListFilter listFilter = new ListFilter(data.getFilterColumns(), (String) request.getAttribute("namespace"));

                listFilter.outputHtml(data, listProperties, out);

                data.outputFilteringHtml(listProperties, out);
            %>
            <div class="row cells5">

                <!-- Created By -->
                <div class="cell">
                    <b>Created By</b>
                    <div id="creatorTree" name="jobsheet_creator_id" class="tree-container">
                        <div class="treeview" data-role="treeview">
                            <ul></ul>
                        </div>
                    </div>
                </div>

                <!-- Status -->
                <div class="cell">
                    <b>Job Sheet Status Type</b>
                    <div id="statusTree" name="jobsheet_status_type_id" class="tree-container">
                        <div class="treeview" data-role="treeview">
                            <ul></ul>
                        </div>
                    </div>
                </div>

            </div>
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
        <!-- 🔥 ADD THIS BLOCK -->

        <table class="dataTable striped border bordered hovered" cellpadding="0" cellspacing="0" border="0" id=${namespace}-result-table>
            <thead>

            </thead>
            <tbody>

            </tbody>
        </table>
        <div data-role="dialog" id=${namespace}-form-dialog class="<%=data.getDialogSize()%>" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 id=form-dialog-title class="text-light"></h1>
                <div class="form-dialog-content">
                    <form id=form-dialog-data method="post" action="list.jsp" autocomplete="off">
                        <div class="grid">

                            <div class="row cells1" id="header1">
                                <div class="cell">
                                    <label>Customer</label>
                                    <!--                                    <span style="color: red; font-weight: bold"> *</span>-->
                                    <div class="input-control select full-size">
                                        <select name="dropdownCustomer" id="dropdownCustomerId">
                                            <option value="0">- Customer -</option>
                                            <%
                                                resusCustomerDropDown.outputHTML(out, listProperties);
                                            %>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells1">
                                <div class="cell">
                                    <label>Company Name</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <!--                                    <div class="input-control text full-size">
                                                                            <input type="text" name="company_name" maxlength="300" placeholder="">
                                                                        </div>-->
                                    <div class="input-control textarea full-size">
                                        <textarea name="company_name" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells1">
                                <div class="cell">
                                    <label>Billing Address</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control textarea full-size">
                                        <textarea name="billing_address" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Customer Name</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="customer_name" maxlength="300" placeholder="">
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Designation</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="designation" maxlength="300" placeholder="">
                                </div>
                            </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Tel No:</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="tel_no" maxlength="300" placeholder="">
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Fax No:</label>
                                    <div class="input-control text full-size">
                                        <input type="text" name="fax_no" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Email</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control textarea full-size">
                                        <textarea name="email" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                                <div class="cell">
                                    <div>
                                        <label>Date of Commencement</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text" data-role="input" >
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="dateTimePicker-date-of-commencement-id" name="dateTimePicker_date_of_commencement" class="start" type="text" placeholder="" value="" readonly="" style="padding-right: 36px;">
                                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                    <div>
                                        <label>Date of Completion</label>
                                        <span style="color: red; font-weight: bold"> *</span>
                                        <div class="input-control text" data-role="input" >
                                            <span class="mif-calendar prepend-icon"></span>
                                            <input id="dateTimePicker-date-of-completion-id" name="dateTimePicker_date_of_completion" class="end" type="text" placeholder="" value="" readonly="" style="padding-right: 36px;">
                                            <button class="button helper-button clear" tabindex="-1" type="button"><span class="mif-cross"></span></button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells1">
                                <div class="cell">
                                    <label>Purchase Order No</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="purchase_order" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <!--                                <div class="cell">
                                                                    <label>Payment Term</label>
                                                                    <div class="input-control text full-size">
                                                                        <input type="text" name="payment_term" maxlength="300" placeholder="">
                                                                    </div>
                                                                </div>-->
                                <div class="cell">
                                    <label>Cost Centre</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="cost_centre" maxlength="300" placeholder="">
                                    </div>
                                    <!--                                    <label>Cost Centre</label>
                                                                        <span style="color: red; font-weight: bold"> *</span>
                                                                        <div class="input-control select full-size">
                                                                            <select name="dropdownCostCentre" id="dropdownCostCentreId">
                                                                                <option value="0">- Cost Centre -</option>
                                    <%
                                        //resusCostCentreDropDown.outputHTML(out, userProperties);
                                    %>
                                </select>
                            </div>-->
                                </div>
                                <div class="cell">
                                    <label>Order Type</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control select full-size">
                                        <select name="dropdownOrderType" id="dropdownOrderTypeId">
                                            <option value="0">- Order Type -</option>
                                            <%                                                resusOrderTypeDropDown.outputHTML(out, listProperties);
                                            %>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <div class="cell">
                                    <label>Job Description</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control textarea full-size">
                                        <textarea name="job_description" maxlength="5000" rows="8" placeholder=""></textarea>
                                    </div>
                                </div>
                                <div class="cell">
                                    <label>Amount</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="number" name="amount" maxlength="10" placeholder="">
                                    </div>
                                    <label>Remarks</label>
                                    <div class="input-control text full-size">
                                        <textarea name="remarks" maxlength="255" rows="3" placeholder=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row cells2">
                                <!--                                <div class="cell">
                                                                    <label>Approved By</label>
                                                                    <span style="color: red; font-weight: bold"> *</span>
                                                                    <div class="input-control text full-size">
                                                                        <input type="text" name="approved_by" maxlength="300" placeholder="">
                                                                    </div>
                                                                </div>-->
                                <div class="cell">
                                    <label>Completed By</label>
                                    <span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size">
                                        <input type="text" name="completed_by" maxlength="300" placeholder="">
                                    </div>
                                </div>
                            </div>
                        </div> 
                    </form>

                </div>    
            </div>
            <div class="form-dialog-control">
                <div class="row">     
                    <div class="column" style="float:left; width:60%;">
                        <input id="file" class="file" accept="application/pdf" name="fileToUpload" type="file" style="display: none;"/>
                        <button id="button-add-attachment" class="button" style="float:left; margin-right:10px">Upload Attachment</button>
                        <button id=button-view type="button" class="button primary" style="float:left; margin-right:10px; display:none;">View Attachment</button>
                        <button id=button-clear type="button" class="mif-cross cycle-button" style="float:left; display:none;"></button>
                    </div>
                    <div class="column" style="float:left; width:40%;">
                        <button id=button-save type="button" class="button primary" onclick="saveJobsheetForm()">Save</button>
                        <button id="button-cancel" type="button" class="button" onclick="closeAddJobsheet()">Close</button>
                        <button id=button-preview type="button" class="button" onclick="previewJobsheet()">Preview</button>
                    </div>
                </div>
            </div>
        </div>

        <div data-role="dialog" id="signoff-dialog" class="padding20" data-close-button="true" data-width="600" data-height="200" data-overlay="true" data-background="bg-lightOlive" data-color="fg-white">
            <h1 id=signoff-dialog-title class="text-light"></h1>
            <p id="signoff-dialog-content"></p>
            <textarea name="signOffTextArea" data-role="textarea" cols="65" rows="7"></textarea>
            <div class="form-dialog-control">
                <div class="float-left">
                    <button id=button-void type="button" class="button alert" onclick="signOffVoid()">Void</button>
                    <button id=button-recall type="button" class="button warning" onclick="signOffRecall()">Recall</button>
                </div>
                <button id=button-yes type="button" class="button" onclick="selectYesSignoff()">Yes</button>
                <button id=button-no type="button" class="button" onclick="selectNoSignoff()">No</button>
                <button id=button-email type="button" class="button primary" onclick="signOffEmail()">Via Email</button>
                <button id=button-link type="button" class="button alert" onclick="signOffLink()">Via Link</button>
                <button id=button-nosignoff type="button" class="button" onclick="noSignOff()">No Sign Off</button>
                <button id=button-close type="button" class="button" onclick="closeSignoffForm()">Close</button>
            </div>
        </div>

    </body>
</html>
