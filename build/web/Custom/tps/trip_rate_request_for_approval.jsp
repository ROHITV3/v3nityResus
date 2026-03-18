<%@page import="v3nity.std.core.web.SystemProperties"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    SystemProperties listProperties = (SystemProperties) request.getAttribute("properties");

    ListData data = (ListData) request.getAttribute("data");

    MetaData metaDataSubType = (MetaData) request.getAttribute("metaDataSubType");

    boolean add = (boolean) request.getAttribute("add");

    boolean update = (boolean) request.getAttribute("update");

    boolean delete = (boolean) request.getAttribute("delete");

%>
<html>
    <head>
             <meta http-equiv="Content-type" content="text/html; charset=utf-8">
     <%
            String approval_id=request.getAttribute("approval_id").toString();
            if(!approval_id.equalsIgnoreCase("undefined")){
            %>
   
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <meta name="referrer" content="no-referrer">
  
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/anytime.5.1.0.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/metro-responsive.css" rel="stylesheet">
        <link href="css/metro-schemes.css" rel="stylesheet">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/select2.min.css" rel="stylesheet">
        <link href="css/responsive.dataTables.css" rel="stylesheet">
        <link href="css/slick.css" rel="stylesheet">
        <link href="css/v3nity-admin.css?v=145016" rel="stylesheet">
        <link href="css/v3nity-form.css?v=145016" rel="stylesheet">
        <link href="css/v3nity-import.css?v=145016" rel="stylesheet">
        <link href="css/v3nity-map.css?v=145016" rel="stylesheet">
        <link href="css/v3nity.css?v=145016" rel="stylesheet">
        
        <style>

            /*      Temporary only, for v4 that still uses v3 UI   */

            .title-bar {
                background-color: #3B6DAB;
                color: #fff;
                margin: 0;
                padding: 4px 8px;
                height: 24px;
            }

            .title-bar .left-side {
                margin: 0;
                padding: 0;
                float: left;
            }

            .title-bar .right-side {
                margin: 0;
                padding: 0;
                float: right;
            }

            .title-bar h5 span {
                margin-right: 4px;
                top: -2px;
            }
            .main-header {
                font-weight:500;
                position: absolute;
            }
            .main-section {
                padding: 16px;
                padding-top: 85px;
                margin-bottom: 64px;
                width: 100%;
            }

            @media screen and (max-width: 480px) {
                .main-section {
                    padding: 8px;
                }
            }

        </style>

        <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?client=gme-v3teletech&amp;v=3&amp;libraries=drawing,geometry"></script>
        <script type="text/javascript" src="js/jquery-2.1.4.min.js"></script>
        <script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" src="js/anytime.5.1.0.js"></script>
        <script type="text/javascript" src="js/dataTables.buttons.min.js"></script>
        <script type="text/javascript" src="js/dataTables.responsive.min.js"></script>
        <script type="text/javascript" src="js/dataTables.select.min.js"></script>
        <script type="text/javascript" src="js/dataTables.cellEdit.js"></script>
        <script type="text/javascript" src="js/metro.js"></script>
        <script type="text/javascript" src="js/select2.min.js"></script>
        <script type="text/javascript" src="js/qrcode.min.js"></script>
        <script type="text/javascript" src="js/slick.js"></script>
        <script type="text/javascript" src="js/markerclusterer.js"></script>
        <script type="text/javascript" src="js/v3nity-chart.js?v=145016"></script><script type="text/javascript" src="js/Chart.js"></script><style type="text/css">/* Chart.js */
@-webkit-keyframes chartjs-render-animation{from{opacity:0.99}to{opacity:1}}@keyframes chartjs-render-animation{from{opacity:0.99}to{opacity:1}}.chartjs-render-monitor{-webkit-animation:chartjs-render-animation 0.001s;animation:chartjs-render-animation 0.001s;}</style><script type="text/javascript" src="js/justgage.js"></script><script type="text/javascript" src="js/raphael-2.1.4.min.js"></script>
        <script type="text/javascript" src="js/v3nity-download.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-file.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-form.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-geocode.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-list.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-timetable.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-tools.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-treeview.js?v=145016"></script>
        <script type="text/javascript" src="js/v3nity-google-map.js?v=145016"></script>
        
    <script type="text/javascript" charset="UTF-8" src="https://maps.googleapis.com/maps-api-v3/api/js/48/12/intl/en_gb/common.js"></script><script type="text/javascript" charset="UTF-8" src="https://maps.googleapis.com/maps-api-v3/api/js/48/12/intl/en_gb/util.js"></script>
    <%
        }
    %>
        <title>${title}</title>
        <%
            data.outputScriptHtml(out);
        %>
        <script type="text/javascript">

            var csv_${namespace} = new csvDownload('TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=view', 'V3NITY');

            var totalRecords_${namespace} = -1;

            var requireOverallCount_${namespace} = true;

            var listForm_${namespace};

            var customFilterQuery_${namespace} = [];
var approveallids="";
var view_data="";
            var listFields = [];
var approval_id=""+${approval_id};
console.log(approval_id);
if(approval_id != "undefined"){
    $('body').css('margin-left','5px');
    $("button[title='Download CSV']").parent().css('display','none')
}
            $(document).ready(function()
            {
                console.log("inside ready")
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
                            url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&format=json&action=view',
                            type: 'POST',
                            data: function(d)
                            {
                                d.totalRecords = totalRecords_${namespace};
                                d.requireOverallCount = requireOverallCount_${namespace};
                                d.customFilterQuery = JSON.stringify(customFilterQuery_${namespace});
                                d.filter = '${filter}';
                                d.foreignKey = '${foreignKey}';
                                d.visibleColumnIndexes = listForm_${namespace}.getColumns();
                                d.approval_id=approval_id;
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
view_data=data.data;
                console.log("view_data")

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
//                                            alert('No Record', 'No record found', 'alert');
                                        }

                                        if (typeof ondatasuccess === 'function')
                                        {
                                            ondatasuccess();
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
                            info: 'Showing' + ' _START_ ' + 'to'.toLowerCase() + ' _END_ ' + 'of'.toLowerCase() + ' _TOTAL_ ' + 'Entries'.toLowerCase() + ' ',
                            infoEmpty: 'Showing' + ' 0 ' + 'to'.toLowerCase() + ' 0 ' + 'of'.toLowerCase() + ' 0 ' + 'entries'.toLowerCase() + ' ',
                            emptyTable: 'No Data Available',
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
                tbl.on('xhr', function()
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
                        url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=edit',
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

                $('#${namespace}-email-button').prop("disabled", false);
            });

            $("#${namespace}-tool-button-add").click(function()
            {
                showAdd_${namespace}();
            });

            $("#${namespace}-tool-button-edit").click(function()
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
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to edit', 'alert');
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
                            url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=delete',
                            data: {
                                id: ids
                            },
                            beforeSend: function()
                            {
                                $('#${namespace}-button-save').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength_${namespace}();

                                        closeForm_${namespace}();
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
                                $('#${namespace}-button-save').prop("disabled", false);
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

            $("#${namespace}-tool-button-copy").click(function()
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

                // we need to dispose the callback function otherwise other jsp will get affected...
                ondatasuccess = null;
            }

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

function approveallmethod(){
approveallids="";
 var view_data_temp="";
     for(var i=0;i<view_data.length;i++){
          view_data_temp=view_data[i];
   console.log(view_data_temp);
//          if(view_data_temp[28]=="Committed" && view_data_temp[19]=="" && view_data_temp[23]==""){
              
              approveallids+=view_data_temp.DT_RowId+","
    
//          }
     }
         approveallids=  approveallids.substring(0,approveallids.length-1)
         if(approveallids!=""){
                $.ajax({
                    type: "POST",
                    encType: "multipart/form-data",
                    url: "TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=ApproveAllStatus&id=" + approveallids + "&approval_id=" + approval_id,
                    cache: false,
                    contentType: false,
                    beforeSend: function ()
                    {
                        $('.toolbar-button').prop("disabled", true);
                        $("button[id*='rejectbutton']").css("display", "none");
                    },
                    error: function (xhr, error, thrown)
                    {
                        dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                    },
                    complete: function ()
                    {
                        $('.toolbar-button').prop("disabled", false);
                             $("button[id*='rejectbutton']").css("display", "block");
                    },
                    success: function (data) {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                changestatusflag="false";

                                alert('Success', data.text, 'success');

                                refreshPageLength_${namespace}();

                                closeForm_${namespace}();
                            } else
                            {
                                alert('Failed', data.text, 'alert');
                            }
                        }
                    },
                });
                }
                else{
                                                alert('No Record Found', "No Record Found", 'alert');

                }
}
function rejectRemarksUpdate(id){
var reject_remarks=$("input[name='reject_remarks"+id+"']").val();
if(reject_remarks!="" && reject_remarks!=undefined && reject_remarks!=null){
  $.ajax({
                    type: "POST",
                    encType: "multipart/form-data",
                    url: "TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=updateRejectRemarks&id=" + id + "&reject_remarks=" + reject_remarks,
                    cache: false,
                    contentType: false,
                    beforeSend: function ()
                    {
                        $('.toolbar-button').prop("disabled", true);
                    },
                    error: function (xhr, error, thrown)
                    {
                        dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                    },
                  
                    success: function (data) {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {

                                alert('Success', data.text, 'success');

                                refreshPageLength_${namespace}();

                                closeForm_${namespace}();
                            } else
                            {
                                alert('Failed', data.text, 'alert');
                            }
                        }
                    },
                      complete: function ()
                    {
                        $('.toolbar-button').prop("disabled", false);
                    },
                });
                }else {
                alert("Please Enter Remarks and try again");
                return;
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

            function deviceSync_${namespace}()
            {
                $.ajax({
                    type: 'POST',
                    url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=sync',
                    data: $('#${namespace}-form-dialog-data').serialize(),
                    beforeSend: function()
                    {
                        $('#${namespace}-button-deviceSync').prop("disabled", true);
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
                        url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=email&format=csv',
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
                                $('#${namespace}-email-button').prop("disabled", false);
                            }
                        },
                        beforeSend: function()
                        {
                            $('#${namespace}-email-button').prop("disabled", true);
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

            function loadSubType_${namespace}(id)
            {
            <%
                if (metaDataSubType != null)
                {
                    String subType = metaDataSubType.getForeignListClass().getSimpleName();

                    String subTypeForeignKey = metaDataSubType.getForeignKeyName();

                    String subTypeDisplayName = "Trip Rate Request For Approval";
            %>
                if (id === -1)
                {
                    $('#${namespace}-sub-type').html('<p class="note">Please save and click edit to manage <%=subTypeDisplayName%>.</p>');
                }
                else
                {
                    $('#${namespace}-sub-type').load('TpsTripRateRequestForApprovalController?lib=${lib}&type=<%=subType%>&filter=' + id + '&foreignKey=<%=subTypeForeignKey%>');
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
                        url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=' + action + '&id=' + id,
                        data: $('#${namespace}-form-dialog-data').serialize(),
                        beforeSend: function()
                        {
                            $('#${namespace}-button-save').prop("disabled", true);
                        },
                        success: function(data)
                        {
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    dialog('Success', data.text, 'success');

                                    refreshPageLength_${namespace}();

                                    closeForm_${namespace}();
                                }
                                else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            }
                            else
                            {
                                closeForm_${namespace}();
                            }
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            $('#${namespace}-button-save').prop("disabled", false);
                        },
                        async: true
                    });
                }
                else
                {
                    dialog('Error', listForm_${namespace}.saveError, 'alert');
                }
            }

            function showAdd_${namespace}()
            {
                var dialog = $('#${namespace}-form-dialog').data('dialog');

                $('#${namespace}-form-dialog-title').html('Add ' + 'Trip Rate Request For Approval');
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
                  $('#${namespace}-form-dialog-title').html('Edit ' + 'Trip Rate Request For Approval');
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
  $('#${namespace}-form-dialog-title').html('Copy ' + 'Trip Rate Request For Approval');
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
                    }
                    else if (element.tagName.toLowerCase() === 'select')
                    {
                        /*
                         * cater for select2 plugin...
                         */
                        $(element).prop('selectedIndex', 0).trigger('change');
                    }
                    else if (element.tagName.toLowerCase() === 'textarea')
                    {
                        element.value = "";
                    }
                }

                /*
                 * perform custom form reset...
                 */
                listForm_${namespace}.reset();

                listFields.forEach(function(value, index)
                {
                    value.clear();
                });
            }

            function closeForm_${namespace}()
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

                $('#${namespace}-form-dialog').data('dialog').close();

                clearForm_${namespace}();
            }

            function getData_${namespace}(id)
            {
                var result = false;

                $.ajax({
                    type: 'POST',
                    url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=data',
                    data: {
                        id: id
                    },
                    success: function(data, status, request)
                    {
                        if (request.getResponseHeader('content-type').includes('json'))
                        {
                            populateForm_${namespace}(data);

                            listForm_${namespace}.populate(data);

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

            function populateForm_${namespace}(result)
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
                        url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=delete',
                        data: {
                            id: id
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

                                    refreshPageLength_${namespace}();
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
                    url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=influence',
                    data: {
                        index: metadataIndex,
                        foreign: this.value
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
                                var element = $('select[name="' + data.identifier + '"');

                                element.html('');

                                for (var i = 0; i < data.options.length; i++)
                                {
                                    var option = data.options[i];

                                    element.append('<option value=' + option.id + '>' + option.value + '</option>');
                                }
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
                    async: false
                });
            }

            $("#${namespace}-tool-button-delete-filter").click(function()
            {
                if (customFilterQuery_${namespace}.length > 0 && totalRecords_${namespace} > 0)
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'TpsTripRateRequestForApprovalController?lib=${lib}&type=${type}&action=deleteByFilter',
                            data: {
                                filterQuery: JSON.stringify(customFilterQuery_${namespace})
                            },
                            beforeSend: function()
                            {
                                $('#${namespace}-tool-button-delete-filter').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        refreshPageLength_${namespace}();

                                        closeForm_${namespace}();
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
                                $('#${namespace}-tool-button-delete-filter').prop("disabled", false);
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
            <h1 class="text-light">Trip Rate Request For Approval<span id='list-sub-title'></span></h1>
        </div>
        <%
            if (!data.getCustomizedPage().equals(""))
            {
        %>
        <jsp:include page="<%=data.getCustomizedPage()%>"/>
        <%
            }
        %>
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
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-add name="add" value="" title="Add"><span class="mif-plus"></span></button>
                    <%
                        }

                        if (update && data.hasEditButton())
                        {
                    %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-edit name="edit" value="" title="Edit"><span class="mif-pencil"></span></button>
                    <%
                        }

                        if (delete && data.hasDeleteButton())
                        {
                    %>
                <button class="toolbar-button" type="button" id=${namespace}-tool-button-delete name="delete" value="" title="Delete"><span class="mif-bin"></span></button>
                    <%
                        }
                    %>

                <%
//                    if (data.hasDeleteByFilterButton())
//                    {
                %>

                    <%
//                        }
                    %>
            </div>
            <%
                }
            %>

            <%
            
            %>
            <div class="toolbar-section">
            </div>
            <%
                
            %>
            <%
//                if (data.hasSelection())
//                {
            %>
            <div class="toolbar-section">
            </div>
            <%
//                }
            %>
            <div class="toolbar-section">

                <%
//                    if (data.hasEmailButton())
//                    {
                %>
                    <%
//                        }
                    %>
            </div>
            
              <div class="toolbar-section">
                <button class="toolbar-button" style="width: 51px;" type="button" title="Approve All" onclick="approveallmethod()"><span class="text-light text-small">Approve All</span></button>
            </div>

            <%
//                if (data.hasCustomFilterButton())
//                {
            %>

            <div class="toolbar-section">
                <button class="toolbar-button" type="button" onclick="customFilter_${namespace}()"><span class="mif-search"></span></button>
            </div>

            <%
//                }
            %>

            <%
//                if (data instanceof IDeviceSynchronizable)
//                {
            %>
            <div class="toolbar-section">
            </div>
            <%
//                }
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
        <%
            }
        %>
        <%
            ListDataHandler dataHandler = new ListDataHandler(data.getListDataSupport());

            try
            {
        %>
        <div id=${namespace}-specific-filter class="grid filter-menu">
            <%
                ListFilter listFilter = new ListFilter(data.getFilterColumns(), (String) request.getAttribute("namespace"));

            
            %>
            <div class="row cells2">
                <div class="cell">
                    <div class="list-show-result-control">
                        <div class="input-control text" style="margin: 0">
                            <input id=${namespace}-page-length type="text" value="${pageLength}" maxlength="3">
                            <div class="button-group">
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

                            %>
                        </div>
                        <div>
                            <%

                                    String jspPath = data.outputJsp();

                                    if (!jspPath.equals(""))
                                    {
                                        request.setAttribute("properties", listProperties);

                                        pageContext.include(jspPath);
                                    }
                                }
                                catch (Exception e)
                                {
                                    e.printStackTrace();
                                }
                                finally
                                {
                                    dataHandler.closeConnection();
                                }
                            %>
                        </div>
                    </form>
                    <div id=${namespace}-sub-type></div>
                </div>
            </div>
            <div class="form-dialog-control">
           
            </div>
        </div>
    </body>
</html>
