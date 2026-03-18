<%@page import="java.io.FilenameFilter"%>
<%@page import="java.io.FileFilter"%>
<%@page import="java.io.File"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
%>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <style>

            #tableView {
                width: 100%;
            }

            #tableView table {
                width: 100%;
            }

            #tableView table td{
                width: 100px;
            }

            #tableView table td img{
                height: 48px;
                width: 100px;
            }

            #tableView table, #tableView table td {
                border: 1px solid #d9d9d9;
                border-collapse: collapse;
            }

            #tableView table tr, #tableView table td {
                height: 48px;
                padding: 8px;
            }

            #tableView table .selected {
                background: #75AFF8;
            }

            #tableView table td.selected:hover {
                background: #75AFF8;
            }

            #tableView table td:hover {
                background: #DBEAFF;
            }

            #selectDynamicSystemFields, #selectDynamicUserFields{
                width:360px;
                height:2.125rem;
                bottom: 5px !important;
            }

            #splitRow {
                transform: rotate(90deg);
            }

            #preview-frame {
                border: 0;
                width: 100%;
                height: 100%;
            }

        </style>
        <script type="text/javascript">

            var formFields;
            var columns;
            var addRowColumn = 0;
            var rowId;
            var url;

            $(document).ready(function () {

                $('#JobReportTemplate-tool-button-add').click(function () {

                    clearTable();
                });

                $('[name="template_id"]').change(function () {

                    getTemplate();

                    clearTable();
                });

                $("#JobReportTemplate-button-cancel").click(function () {

                    addRowColumn = 0;

                    createDynamicFieldDropDown();

                });

                $("#createTable").click(function () {

                    if ($('[name="template_id"]').val() === "") {

                        dialog('Error', 'Please select Job Form Template before creating report', 'alert');

                    }
                    else if ($('#rows').val() > 20) {

                        dialog('Error', 'Max number of rows is 20', 'alert');

                    }
                    else if ($('#columns').val() > 10) {

                        dialog('Error', 'Max number of columns is 10', 'alert');

                    }
                    else if ($.isNumeric($('#rows').val()) && $.isNumeric($('#columns').val())) {

                        createTable();

                    }
                    else {

                        dialog('Error', 'Row or column inputs are not a number', 'alert');
                    }
                });

                $("#addRow").click(function () {

                    if ($('[name="template_id"]').val() === "") {

                        dialog('Error', 'Please select Job Form Template before adding row', 'alert');

                    }
                    else {

                        addRow();

                    }
                });

                $("#deleteRow").click(function () {

                    if ($('[name="template_id"]').val() === "") {

                        dialog('Error', 'Please select Job Form Template before deleting row', 'alert');

                    }
                    else {

                        deleteRow();

                    }
                });

                $("#topBorderColor").click(function () {

                    setTopBorderColor();

                });

                $("#bottomBorderColor").click(function () {

                    setBottomBorderColor();

                });

                $("#leftBorderColor").click(function () {

                    setLeftBorderColor();

                });

                $("#rightBorderColor").click(function () {

                    setRightBorderColor();

                });
				
				$("#deleteBorder").click(function () {

                    removeBorderColor();

                })

                $("#mergeCell").click(function () {

                    mergeCells();

                });

                $("#splitCol").click(function () {

                    splitCol();

                });

                $("#splitRow").click(function () {

                    splitRow();

                });

                $("#clearTable").click(function () {

                    var c = confirm("Are you sure you want to clear table?");

                    if (c === true) {
                        clearTable();

                        createDynamicFieldDropDown();
                    }
                });

                $("#browseImage").on("change", function (e) {

                    addImage(e);
                });

                $("#orientation").on("change", function (e) {

                    $('#table-settings').attr('data-orientation', this.value);
                });

                $("#font").on("change", function (e) {

                    $('#table-settings').attr('data-font', $("#font :selected").attr('id'));
                });

                $("#margins").on("change", function (e) {

                    $('#table-settings').attr('data-margins', this.value);
                });

                $("#removeCellField").click(function () {

                    if ($("#tableView table .selected").eq(1).attr("class") !== "selected") {

                        if ($("#tableView table .selected").eq(0).attr("data-id") === "") {

                            dialog('Error', 'There is no field in this cell', 'alert');

                        }
                        else {

                            $("#tableView table .selected").eq(0).attr("data-id", '');

                            $("#tableView table .selected").eq(0).attr("data-role", '');

                            $("#tableView table .selected").eq(0).attr("data-name", '');

                            $("#tableView table .selected").eq(0).attr("data-dropdown", '');

                            $("#tableView table .selected").html('');
                        }


                    }


                    else {
                        dialog('Error', 'You can only remove 1 field at 1 time', 'alert');
                        $("#tableView table .selected").removeClass("selected");
                    }

                });

                $("#clearField").click(function () {

                    var c = confirm("Are you sure you want to clear table?");

                    if (c === true) {
                        $("#tableView table td").attr("data-id", "");
                        $("#tableView table td").attr("data-role", "");
                        $("#tableView table td").attr("data-name", "");
                        $("#tableView table td").attr("data-dropdown", "");

                        $("#tableView table td").empty();

                        createDynamicFieldDropDown();
                    }

                });

                $("#addLogo").click(function () {

                    if ($("#tableView table .selected").eq(0).attr("data-id") === "") {

                        $("#browseImage").click();

                        $("#tableView table .selected").html("");

                    }
                    else {

                        dialog('Error', 'Selected cell already have a Field defined in it', 'alert');
                    }

                });

                $("#previewTable").click(function () {

                    $('#preview-id').attr('value', $('[name="template_id"]').val());

                    $('#preview-data').attr('value', $('#tableView').html());

                    $('#preview-dialog').data('dialog').open();

                    $('#preview-form').submit();
                });

                appendPreviewForm();

            });

            function setTopBorderColor()
            {
                var cell = $("#tableView table .selected");
                var checkColor = cell.css("border-top-color").toString()
                if (checkColor === "rgb(217, 217, 217)")
                {
                    cell.css("border-top-color", "black");
                    cell.css("border-top-width", "3px");
                }
                else
                {
                    cell.css("border-top-color", "");
                    cell.css("border-top-width", "");
                }
            }

            function setBottomBorderColor()
            {
                var cell = $("#tableView table .selected");
                var checkColor = cell.css("border-bottom-color").toString()
                if (checkColor === "rgb(217, 217, 217)")
                {
                    cell.css("border-bottom-color", "black");
                    cell.css("border-bottom-width", "3px");
                }
                else
                {
                    cell.css("border-bottom-color", "");
                    cell.css("border-bottom-width", "");
                }
            }

            function setLeftBorderColor()
            {
                var cell = $("#tableView table .selected");
                var checkColor = cell.css("border-left-color").toString()
                if (checkColor === "rgb(217, 217, 217)")
                {
                    cell.css("border-left-color", "black");
                    cell.css("border-left-width", "3px");
                }
                else
                {
                    cell.css("border-left-color", "");
                    cell.css("border-left-width", "");
                }
            }

            function setRightBorderColor()
            {
                var cell = $("#tableView table .selected");
                var checkColor = cell.css("border-right-color").toString()
                if (checkColor === "rgb(217, 217, 217)")
                {
                    cell.css("border-right-color", "black");
                    cell.css("border-right-width", "3px");
                }
                else
                {
                    cell.css("border-right-color", "");
                    cell.css("border-right-width", "");
                }
            }
			function removeBorderColor()
            {
                
                //debugger;           
                if($("#tableView table .selected"))
                {
                  var cell = $("#tableView table .selected");
                  var tablecell = $("#tableView table");
                  var styles = {'border':'none'};
                  
                   cell.css(styles);
                   tablecell.css(styles);
                   //cell.css("border-style","0");
                  // cell.css("background-color","rgb(255,255,255)");
                   
        }
        }

            function appendPreviewForm() {

                /*
                 * we need to append the form html to the actual body in the list.jsp
                 */

                var form = $("<form/>",
                        {
                            id: 'preview-form',
                            method: 'post',
                            target: 'preview-frame',
                            action: 'JobReportController?type=system&action=preview'});

                form.append(
                        $("<input>",
                                {type: 'hidden',
                                    id: 'preview-id',
                                    name: 'id'})
                        );

                form.append(
                        $("<input>",
                                {type: 'hidden',
                                    id: 'preview-data',
                                    name: 'data'})
                        );

                $('body').append(form);
            }

            function addSystemField() {

                if ($("#system-form-field").val() === "") {

                    dialog('Error', 'Please select a Field to add', 'alert');

                }
                else {

                    var cell = $("#tableView table .selected");

                    if (cell.eq(0).attr("data-id") === "") {

                        cell.eq(0).attr("data-id", $("#system-form-field").val());

                        cell.eq(0).attr("data-dropdown", "system");

                        var selected = $("#system-form-field :selected");

                        cell.eq(0).attr("data-role", selected.attr('data-role'));

                        cell.eq(0).attr("data-name", selected.attr('data-name'));

                        cell.eq(0).attr("data-cell-fontsize", $("#font-size :selected").val());

                        cell.eq(0).attr("data-cell-fontstyle", $("#font-style :selected").val());

                        cell.eq(0).attr("data-cell-alignment", $("#alignment :selected").val());

                        cell.eq(0).attr("data-cell-titlestyle", $("#title-style :selected").val());

                        cell.append($('<p/>', {class: 'report-cell-name'}).html(selected.attr('data-name')));

                        cell.append($('<p/>', {class: 'report-cell-tag role'}).html('System'));

                        cell.append($('<p/>', {class: 'report-cell-tag fontsize'}).html('Size ' + $("#font-size :selected").text()));

                        cell.append($('<p/>', {class: 'report-cell-tag fontstyle'}).html($("#font-style :selected").text()));

                        cell.append($('<p/>', {class: 'report-cell-tag alignment'}).html($("#alignment :selected").text()));

                        cell.append($('<p/>', {class: 'report-cell-tag titlestyle'}).html('Title ' + $("#title-style :selected").text()));

                        if (cell.eq(0).attr("data-role") === "camera" || cell.eq(0).attr("data-role") === "drawing" || cell.eq(0).attr("data-role") === "signature" || cell.eq(0).attr("data-role") === "image" || cell.eq(0).attr("data-role") === "gallery" || cell.eq(0).attr("data-role") === 'addcamera' || cell.eq(0).attr("data-role") === 'cameralibrary') {
                            cell.eq(0).attr("data-cell-imagesize", $("#image-size :selected").val());

                            cell.append($('<p/>', {class: 'report-cell-tag imagesize'}).html('Image Size ' + $("#image-size :selected").text()));
                        }
                    }
                    else {

                        dialog('Error', 'Selected cell already have a Field defined in it', 'alert');
                    }
                }

            }

            function addUserField() {

                if ($("#user-form-field").val() === "") {

                    dialog('Error', 'Please select a Field to add', 'alert');
                }
                else {

                    var cell = $("#tableView table .selected");

                    if (cell.eq(0).attr("data-id") === "") {

                        cell.eq(0).attr("data-id", $("#user-form-field").val());

                        cell.eq(0).attr("data-dropdown", "user");

                        cell.eq(0).attr("data-role", $("#user-form-field :selected").attr('data-role'));

                        cell.eq(0).attr("data-name", $("#user-form-field :selected").attr('data-name'));

                        cell.eq(0).attr("data-cell-fontsize", $("#font-size :selected").val());

                        cell.eq(0).attr("data-cell-fontstyle", $("#font-style :selected").val());

                        cell.eq(0).attr("data-cell-alignment", $("#alignment :selected").val());

                        cell.eq(0).attr("data-cell-titlestyle", $("#title-style :selected").val());

                        cell.append($('<p/>', {class: 'report-cell-name'}).html($("#user-form-field :selected").attr('data-name')));

                        cell.append($('<p/>', {class: 'report-cell-tag role'}).html($("#user-form-field :selected").attr('data-role')));

                        cell.append($('<p/>', {class: 'report-cell-tag fontsize'}).html('Size ' + $("#font-size :selected").text()));

                        cell.append($('<p/>', {class: 'report-cell-tag fontstyle'}).html($("#font-style :selected").text()));

                        cell.append($('<p/>', {class: 'report-cell-tag alignment'}).html($("#alignment :selected").text()));

                        cell.append($('<p/>', {class: 'report-cell-tag titlestyle'}).html('Title ' + $("#title-style :selected").text()));

                        if (cell.eq(0).attr("data-role") === "camera" || cell.eq(0).attr("data-role") === "drawing" || cell.eq(0).attr("data-role") === "signature" || cell.eq(0).attr("data-role") === "image" || cell.eq(0).attr("data-role") === "gallery" || cell.eq(0).attr("data-role") === 'addcamera' || cell.eq(0).attr("data-role") === 'cameralibrary') {
                            cell.eq(0).attr("data-cell-imagesize", $("#image-size :selected").val());

                            cell.append($('<p/>', {class: 'report-cell-tag imagesize'}).html('Image Size ' + $("#image-size :selected").text()));
                        }

                    }
                    else {
                        dialog('Error', 'Selected cell already have a Field defined in it', 'alert');
                    }
                }
            }

            function setCellFontSize() {

                var cell = $("#tableView table .selected");

                if (cell.eq(0).attr("data-id") !== "") {

                    var tag = cell.children('.report-cell-tag.fontsize');

                    $(tag).html('Size ' + $("#font-size :selected").text());

                    cell.attr("data-cell-fontsize", $("#font-size :selected").val());
                }
                else {
                    dialog('Error', 'Please select a cell with a field defined in it', 'alert');
                }
            }

            function setCellFontStyle() {

                var cell = $("#tableView table .selected");

                if (cell.eq(0).attr("data-id") !== "") {

                    var tag = cell.children('.report-cell-tag.fontstyle');

                    $(tag).html($("#font-style :selected").text());

                    cell.attr("data-cell-fontstyle", $("#font-style :selected").val());
                }
                else {
                    dialog('Error', 'Please select a cell with a field defined in it', 'alert');
                }
            }

            function setCellAlignment() {

                var cell = $("#tableView table .selected");

                if (cell.eq(0).attr("data-id") !== "") {

                    var tag = cell.children('.report-cell-tag.alignment');

                    $(tag).html($("#alignment :selected").text());

                    cell.attr("data-cell-alignment", $("#alignment :selected").val());
                }
                else {
                    dialog('Error', 'Please select a cell with a field defined in it', 'alert');
                }
            }

            function setCellTitleBold() {

                var cell = $("#tableView table .selected");

                if (cell.eq(0).attr("data-id") !== "") {

                    var tag = cell.children('.report-cell-tag.titlestyle');

                    $(tag).html('Title ' + $("#title-style :selected").text());

                    cell.attr("data-cell-titlestyle", $("#title-style :selected").val());
                }
                else {
                    dialog('Error', 'Please select a cell with a field defined in it', 'alert');
                }
            }

            function setCellImageSize() {

                var cell = $("#tableView table .selected");

                if (cell.eq(0).attr("data-id") !== "") {
                    if (cell.eq(0).attr("data-role") === "camera" || cell.eq(0).attr("data-role") === "drawing" || cell.eq(0).attr("data-role") === "signature" || cell.eq(0).attr("data-role") === "image" || cell.eq(0).attr("data-role") === "gallery" || cell.eq(0).attr("data-role") === 'addcamera' || cell.eq(0).attr("data-role") === 'cameralibrary') {
                        var tag = cell.children('.report-cell-tag.imagesize');

                        $(tag).html('Image Size ' + $("#image-size :selected").text());

                        cell.attr("data-cell-imagesize", $("#image-size :selected").val());
                    }
                    else {
                        dialog('Error', 'This function is only applicable to camera,signature,drawing,image and gallery field', 'alert');
                    }
                }
                else {
                    dialog('Error', 'Please select a cell with a field defined in it', 'alert');
                }
            }

            function addImage(e) {

                var file = e.target.files[0];   // only get first file...

                var reader = new FileReader();

                reader.onload = function () {

                    url = reader.result;

                    $("#tableView table .selected").html("<img src='" + url + "'></img>");

                    $("#tableView table .selected").eq(0).attr("data-id", "10");

                    $("#tableView table .selected").eq(0).attr("data-dropdown", "system");

                    $("#tableView table .selected").eq(0).attr("data-role", "Customer Logo");

                    $("#tableView table .selected").eq(0).attr("data-name", "Customer Logo");
                };

                if (file) {
                    var imageType = /image.*/;

                    if (file.type.match(imageType)) {
                        reader.readAsDataURL(file);
                    }
                    else {
                        $("#tableView table .selected").html("");
                    }
                }
                else {
                    $("#tableView table .selected").html("");
                }
            }

            function getOrientation() {
                return $('#orientation option:selected').val();
            }

            function getFont() {
                 var font = $('#table-settings').attr('data-font');

                            var select = document.getElementById('font');
                            var option = select.children;

                            for (var i = 0; i < option.length; i++) {
                                if (font === option[i].id)
                                {
                                   return select.selectedIndex = "" + i;
                                }
                            };
            }

            function createTable() {

                var i;

                var rows = $('#rows').val();

                columns = $('#columns').val();

                addRowColumn = $('#columns').val();

                $("#tableView").html("<table id=\"table-settings\" data-orientation=\"\" data-font=\"\" data-margins=\"\" style=\"border-collapse: separate; border-spacing: 0;\"></table>");

                for (i = 0; i < rows; i++) {

                    $("<tr onclick='getRowId(this)'></tr>").appendTo("#tableView table");
                }

                for (i = 0; i < columns; i++) {

                    $("<td></td>")
                            .attr("id", i)
                            .attr("colspan", 1)
                            .attr("rowspan", 1)
                            .attr("data-id", "")
                            .attr("data-role", "")
                            .attr("data-name", "")
                            .attr("data-dropdown", "")
                            .appendTo("#tableView table tr");

                }

                $('#table-settings').attr('data-orientation', getOrientation());

                $('#table-settings').attr('data-font', getFont());

                $('#table-settings').attr('data-margins', $('#margins').val());

                createDynamicFieldDropDown();

                bindSelected();
            }

            function getRowId(x) {

                rowId = x.rowIndex;
            }

            function addRow() {
                var count = $('#tableView table .selected').length;
                if (count == 0) {
                    //find the total number of cell in the first row including those cell that have been merge
                    var i;
                    var totalCell = 0;
                    var noCell = $("#tableView").find('tr')[0].cells.length;
                    for (i = 0; i < noCell; i++) {
                        totalCell = totalCell + parseInt($("#tableView table td").eq(i).attr('colspan'));
                    }

                    addRowColumn = totalCell;

                    var newRow = $("<tr onclick='getRowId(this)'></tr>").appendTo("#tableView table");

                    for (i = 0; i < addRowColumn; i++) {

                        $("<td></td>")
                                .attr("id", i)
                                .attr("colspan", 1)
                                .attr("rowspan", 1)
                                .attr("data-id", "")
                                .attr("data-role", "")
                                .attr("data-name", "")
                                .attr("data-dropdown", "")
                                .appendTo(newRow);

                    }

                }
                else if (count == 1) {

                    var selectedCell = $("#tableView table .selected");
                    var selectedRow = $(selectedCell).closest('tr');
                    var children = selectedRow.children('td');
                    var colspan = 0;
                    var newRow = $("<tr onclick='getRowId(this)'></tr>").insertAfter(selectedRow);
                    for (i = 0; i < children.length; i++) {
                        colspan += parseInt(children.eq(i).attr('colspan'));
                    }
                    for (x = 0; x < colspan; x++) {
                        $("<td></td>")
                                .attr("id", x)
                                .attr("colspan", 1)
                                .attr("rowspan", 1)
                                .attr("data-id", "")
                                .attr("data-role", "")
                                .attr("data-name", "")
                                .attr("data-dropdown", "")
                                .appendTo(newRow);
                    }

                }
                else {
                    dialog('Error', 'More than one row are selected', 'alert');
                    return;
                }

                bindSelected();

            }

            function deleteRow() {
                var count = $('#tableView table .selected').length;
                if (count == 0) {
                    dialog('Error', 'Please select at least 1 row to remove', 'alert');
                    return;
                }
                else {
                    var selectedCell = $("#tableView table .selected");
                    var selectedRow = $(selectedCell).closest('tr');
                    selectedRow.remove();
                }
            }

            function clearTable() {

                $("#tableView table").empty();

                $("#reportTemplateName").empty();

                createDynamicFieldDropDown();

            }

            function bindSelected() {

                $("#tableView table td").unbind("click");

                $("#tableView table td").bind("click", function (e) {

                    if ($("#tableView table .selected").length < 2) {

                        $(this).toggleClass("selected");

                    }
                    else if ($("#tableView table .selected").length === 2) {

                        $(this).removeClass("selected");

                    }

                });

            }

            function mergeCells() {

                var mergeRow = parseInt($("#tableView table .selected").eq(0).attr("rowspan"));

                //selected cells are same row
                if ($("#tableView table .selected").eq(0).parent().index() === $("#tableView table .selected").eq(1).parent().index()) {

                    //selected cells are side by side
                    if ($("#tableView table .selected").eq(0).index() - $("#tableView table .selected").eq(1).index() === 1 || $("#tableView table .selected").eq(0).index() - $("#tableView table .selected").eq(1).index() === -1) {

                        if ($("#tableView table .selected").eq(0).attr("data-name") || $("#tableView table .selected").eq(1).attr("data-name")) {

                            dialog('Error', 'Fields are already assigned in this cells', 'alert');

                        }
                        else {
                            //selected cells are same height
                            if ($("#tableView table .selected").eq(0).attr("rowspan") === $("#tableView table .selected").eq(1).attr("rowspan")) {

                                var newspan = parseInt($("#tableView table .selected").eq(0).attr("colspan")) + parseInt($("#tableView table .selected").eq(1).attr("colspan"));

                                $("#tableView table .selected").eq(0).attr("colspan", newspan);

                                $("#tableView table .selected").eq(1).remove();

                            }
                            else {

                                $("#tableView table .selected").removeClass("selected");
                            }
                        }
                    }
                    else {

                        $("#tableView table .selected").removeClass("selected");
                    }
                }
                //merge row
                else if ($("#tableView table .selected").eq(0).attr("id") === $("#tableView table .selected").eq(1).attr("id")) {
                    // selected cells in the same column


                    if ($("#tableView table .selected").eq(0).parent().index() === $("#tableView table .selected").eq(1).parent().index() - mergeRow) {
                        //selected cells are side by side (top bottom)

                        if ($("#tableView table .selected").eq(0).attr("data-name") || $("#tableView table .selected").eq(1).attr("data-name")) {

                            dialog('Error', 'Fields are already assigned in this cells', 'alert');

                        }
                        else {
                            //code to merge row
                            if ($("#tableView table .selected").eq(0).attr("colspan") === $("#tableView table .selected").eq(1).attr("colspan")) { //selected cells are same height

                                var newspan = parseInt($("#tableView table .selected").eq(0).attr("rowspan")) + parseInt($("#tableView table .selected").eq(1).attr("rowspan"));

                                $("#tableView table .selected").eq(0).attr("rowspan", newspan);

                                $("#tableView table .selected").eq(1).remove();


                            }

                            else {

                                $("#tableView table .selected").removeClass("selected");

                            }

                        }
                    }
                    else {

                    }
                }

                $("#tableView table .selected").removeClass("selected");
            }

            function splitCol() {

                var intId = parseInt($("#tableView table .selected").eq(0).attr("id"));
                var intColSpan = parseInt($("#tableView table .selected").eq(0).attr("colspan"));
                var intRowSpan = parseInt($("#tableView table .selected").eq(0).attr("rowspan"));
                var splitColID = intId + intColSpan - 1;
                var incrementalID = $("#tableView table .selected").eq(0).index() + 1;

                if ($("#tableView table .selected").eq(1).attr("class") !== "selected") {

                    if ($("#tableView table .selected").eq(0).attr("data-name")) {

                        dialog('Error', 'Delete field in cells before splitting.', 'alert');

                    }
                    else {

                        var colSpan = parseInt($("#tableView table .selected").eq(0).attr("colspan"));

                        var splitColSpan = parseInt($("#tableView table .selected").eq(0).attr("colspan")) - 1;

                        if (colSpan > 1) {

                            $("#tableView table .selected").eq(0).attr("colspan", splitColSpan);

                            var row = document.getElementById("tableView").getElementsByTagName("tr")[rowId];
                            var x = row.insertCell(incrementalID);
//                            var x = row.insertCell(1);
                            x.setAttribute('id', splitColID);
                            x.setAttribute('colspan', 1);
                            x.setAttribute('rowspan', intRowSpan);
                            x.setAttribute('data-id', "");
                            x.setAttribute('data-role', "");
                            x.setAttribute('data-name', "");
                            x.setAttribute('data-dropdown', "");

                            x.innerHTML = "";

                            bindSelected();
                        }
                        else {
                            dialog('Error', 'The colspan of this cell is 1', 'alert');
                        }
                    }

                }

                else {
                    dialog('Error', 'You can only split 1 cell at 1 time', 'alert');
                    $("#tableView table .selected").removeClass("selected");
                }
            }

            function splitRow() {

                var intId = parseInt($("#tableView table .selected").eq(0).attr("id"));
                var intRowSpan = parseInt($("#tableView table .selected").eq(0).attr("rowspan"));
                var intColSpan = parseInt($("#tableView table .selected").eq(0).attr("colspan"));

                var cellPosition = 0;


                if ($("#tableView table .selected").eq(0).attr("data-name")) {

                    dialog('Error', 'Delete field in cells before splitting.', 'alert');

                }

                //To make sure that only 1 cell is selected to be split
                else if ($("#tableView table .selected").eq(1).attr("class") === "selected") {

                    dialog('Error', 'To split cell, please choose only 1 cell to split', 'alert');
                }

                else {

                    var splitRowSpan = parseInt($("#tableView table .selected").eq(0).attr("rowspan")) - 1;

                    if (intRowSpan > 1) {
                        $("#tableView table .selected").eq(0).attr("rowspan", splitRowSpan);
                        var row = document.getElementById("tableView").getElementsByTagName("tr")[rowId + intRowSpan - 1];

                        //Count the number of the cell left on the last row of the selected cell
                        var cellLength = row.cells.length;

                        //Compare the id of the particular cell. This helps to find the position for the cell to be inserted.
                        for (var i = 0; i < cellLength; i++) {
                            if (row.cells[i].getAttribute("id") < intId) {
                                cellPosition++;
                            }
                        }

                        //Insert Cell at a particular row, and at a particular column
                        var x = row.insertCell(cellPosition);
                        x.setAttribute('id', intId);
                        x.setAttribute('colspan', intColSpan);
                        x.setAttribute('rowspan', 1);
                        x.setAttribute('data-id', "");
                        x.setAttribute('data-role', "");
                        x.setAttribute('data-name', "");
                        x.setAttribute('data-dropdown', "");
                        x.innerHTML = "";
                        bindSelected();
                    }

                    else {
                        dialog('Error', 'The rowspan of this cell is 1', 'alert');
                    }
                }
                if (intRowSpan < 3) {
                    $("#tableView table .selected").removeClass("selected");
                }
            }

            function getTemplate() {

                var templateId = $('[name="template_id"]').val();

                $.ajax({
                    type: 'POST',
                    url: 'JobReportController',
                    data: {
                        type: 'system',
                        action: 'data',
                        templateId: templateId
                    },
                    beforeSend: function () {

                    },
                    success: function (data) {

                        formFields = data.formFields;

                        createDynamicFieldDropDown();

                        //
                        // define the table settings if previous version does not support it...
                        //
                        var table = $('#tableView').children()[0];

                        if ($(table).attr('id') === undefined) {
                            $(table).attr('id', 'table-settings');

                            $(table).attr('data-orientation', 'landscape');

                            $('#orientation').val('landscape');

                            $(table).attr('data-font', $('#font :selected').id);

                            $('#font :selected').id;

                            $(table).attr('data-margins', '36,36,36,36');

                            $('#margins').val('36,36,36,36');
                        }
                        else {
                            var orientation = $('#table-settings').attr('data-orientation');

                            $('#orientation').val(orientation);

                            var font = $('#table-settings').attr('data-font');

                            var select = document.getElementById('font');

                            var option = select.children;

                            for (var i = 0; i < option.length; i++) {
                                if (font === option[i].id)
                                {
                                    select.selectedIndex = "" + i;
                                }
                            }

                            var margins = $('#table-settings').attr('data-margins');

                            $('#margins').val(margins);
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

            function createDynamicFieldDropDown() {

                var html1 = '<select id="system-form-field">';

                html1 += "<option data-dropdown ='system' data-role='' data-name='' value=''>Select System Field To Insert To Cell</option>";
                html1 += "<option data-dropdown ='system' data-role='Job Id' data-name='Job Id' value='0'>Job Id</option>";
                html1 += "<option data-dropdown ='system' data-role='S/N' data-name='S/N' value='20'>S/N</option>";
                html1 += "<option data-dropdown ='system' data-role='Customer Name' data-name='Customer Name' value='1'>Customer Name</option>";
                html1 += "<option data-dropdown ='system' data-role='Driver' data-name='Staff' value='2'>Staff</option>";
                html1 += "<option data-dropdown ='system' data-role='Job Type' data-name='Job Type' value='3'>Job Type</option>";
                html1 += "<option data-dropdown ='system' data-role='Template Name' data-name='Template Name' value='4'>Template Name</option>";
                html1 += "<option data-dropdown ='system' data-role='Duration' data-name='Duration' value='5'>Duration</option>";
                html1 += "<option data-dropdown ='system' data-role='Created Date' data-name='Created Date' value='6'>Created Date</option>";
                html1 += "<option data-dropdown ='system' data-role='Schedule Date Time' data-name='Schedule Date Time' value='7'>Schedule Date Time</option>";
                html1 += "<option data-dropdown ='system' data-role='Location' data-name='Location' value='8'>Location</option>";
                html1 += "<option data-dropdown ='system' data-role='Start Job Coordinate' data-name='Start Job Coordinate' value='18'>Start Job Coordinate</option>";
                html1 += "<option data-dropdown ='system' data-role='End Job Coordinate' data-name='End Job Coordinate' value='19'>End Job Coordinate</option>";
                html1 += "<option data-dropdown ='system' data-role='Actual Start Date Time' data-name='Actual Start Date Time' value='9'>Actual Start Date Time</option>";
                html1 += "<option data-dropdown ='system' data-role='Actual End Date Time' data-name='Actual End Date Time' value='10'>Actual End Date Time</option>";
                html1 += "<option data-dropdown ='system' data-role='Actual Start Date' data-name='Actual Start Date' value='11'>Actual Start Date</option>";
                html1 += "<option data-dropdown ='system' data-role='Actual End Date' data-name='Actual End Date' value=12>Actual End Date</option>";
                html1 += "<option data-dropdown ='system' data-role='Ratings Sub Total' data-name='Ratings Sub Total' value='13'>Ratings Sub Total</option>";
                html1 += "<option data-dropdown ='system' data-role='Ratings Grand Total' data-name='Ratings Grand Total' value='14'>Ratings Grand Total</option>";
                html1 += "<option data-dropdown ='system' data-role='Description' data-name='Description' value='15'>Description</option>";
                html1 += "<option data-dropdown ='system' data-role='Page Break' data-name='Page Break' value='16'>Page Break</option>";
                html1 += "<option data-dropdown ='system' data-role='Job Customer Name' data-name='Job Customer Name' value='17'>Job Customer Name</option>";
                

                html1 += '</select>';

                document.getElementById('selectDynamicSystemFields').innerHTML = html1;

                if ($('[name="template_id"]').val() !== "") {

                    var html = '<select id="user-form-field">';

                    html += "<option data-dropdown ='user' data-role='' data-name='' value=''>Select User Field To Insert To Cell</option>";

                    if (formFields === null || formFields === undefined) {

                    }
                    else {

                        for (var i = 0; i < formFields.length; i++) {

                            var id = formFields[i].id;

                            var name = formFields[i].name;

                            var role = formFields[i].role;

                            if (role !== "ratingsSummary") {

                                html += "<option data-dropdown ='user' data-role='" + role + "' data-name='" + name + "' value='" + id + "'>[" + role + "] " + name + "</option>";
                            }
                        }
                    }
                    html += '</select>';

                    document.getElementById('selectDynamicUserFields').innerHTML = html;

                }
                else {

                    var html = '<select id="user-form-field">';

                    html += "<option data-dropdown ='user' data-role='' data-name='' value=''>Select User Field To Insert To Cell</option>";

                    html += '</select>';

                    document.getElementById('selectDynamicUserFields').innerHTML = html;

                }

                var fontSelect = document.getElementById("font");
                setSelectedValue(fontSelect, "NotoSans-Regular.ttf");
            }

            function setSelectedValue(selectObj, valueToSet) {
                for (var i = 0; i < selectObj.options.length; i++) {
                    if (selectObj.options[i].text== valueToSet) {
                        selectObj.options[i].selected = true;
                        return;
                    }
                }
            }

        </script>
        <title></title>
    </head>
    <body>
        <div class="grid">
            <div class="row cells1">
                <div class="cell" >
                    <div>
                        <h1 class="text-light"><%=userProperties.getLanguage("reportEditor")%></h1>
                    </div>
                    <% if (userProperties.getString("language").equals("en")) {%>
                    <div class="help-tag">
                        <h4>Instructions:</h4>
                        <p>To begin, select a job form template at the top</p>
                        <p>Next, select number of rows and columns</p>
                        <p>Merge cells horizontally as you desire</p>
                        <p>Next, select the field for each cell</p>
                        <p>Once done, click save</p>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>
        <div class="grid">
            <div class="row cells4">
                <div class="cell" >
                    <h2 class="text-light"><%=userProperties.getLanguage("tableOptions")%></h2>
                    <br>
                    <div class="toolbar">
                        <div class="toolbar-section">
                            <button type="button" class="toolbar-button" id=createTable name="createTable" value="" title="<%=userProperties.getLanguage("createTable")%>"><span class="mif-table"></span></button>
                            <button type="button" class="toolbar-button" id=addRow name="addRow" value="" title="<%=userProperties.getLanguage("addRow")%>"><span class="mif-vertical-align-bottom"></span></button>
                            <button type="button" class="toolbar-button" id=deleteRow name="deleteRow" value="" title="<%=userProperties.getLanguage("deleteRow")%>"><span class="mif-cross"></span></button>
                            <button type="button" class="toolbar-button" id=mergeCell name="mergeCell" value="" title="<%=userProperties.getLanguage("mergeCell")%>"><span class="mif-shrink"></span></button>
                            <button type="button" class="toolbar-button" id=splitCol name="splitCol" value="" title="<%=userProperties.getLanguage("splitCol")%>"><span class="mif-tab"></span></button>
                            <button type="button" class="toolbar-button" id=splitRow name="splitRow" value="" title="<%=userProperties.getLanguage("splitRow")%>"><span class="mif-tab"></span></button>
                            <button type="button" class="toolbar-button" id=clearTable name="clearTable" value="" title="<%=userProperties.getLanguage("clearTable")%>"><span class="mif-bin"></span></button>
                            <button type="button" class="toolbar-button" id=previewTable name="previewTable" value="" title="<%=userProperties.getLanguage("previewTable")%>"><span class="mif-file-play"></span></button>
                        </div>
                    </div>
                    <h4 class="text-light">Select Orientation</h4>
                    <div class="input-control select">
                        <select id="orientation">
                            <option value="landscape" selected>Landscape</option>
                            <option value="portrait">Portrait</option>
                        </select>
                    </div>
                    <h4 class="text-light">Font</h4>
                    <div class="input-control select">
                        <select id="font">
                            <%
                                File folder = new File(request.getServletContext().getRealPath("/") + "/fonts");
                                File[] listOfFiles = folder.listFiles(new FilenameFilter() {
                                    public boolean accept(File dir, String name) {
                                        return name.endsWith(".ttf") || name.endsWith(".otf");
                                    }
                                });

                                for (File file : listOfFiles)
                                {
                                    %>
                                    <option id="<%= file.getName()%>" value="<%= file.getAbsolutePath()%>" ><%= file.getName()%> </option>
                                    <%
                                }
                            %>
                        </select>
                    </div>
                    <h4 class="text-light">Margins (Left, Right, Top, Bottom)</h4>
                    <div class="input-control text">
                        <input id = "margins" type="text" placeholder="Input margins" value="36,36,36,36">
                    </div>
                    <h4 class="text-light"><%=userProperties.getLanguage("selectNoRows")%></h4>
                    <div class="input-control text">
                        <input id = "rows" type="text" placeholder="Input number of Rows">
                    </div>
                    <h4 class="text-light"><%=userProperties.getLanguage("selectNoCols")%></h4>
                    <div class="input-control text">
                        <input id = "columns" type="text" placeholder="Input number of Columns">
                    </div>
                    <br>
                    <br>
                    <h2 class="text-light"><%=userProperties.getLanguage("cellOptions")%></h2>
                    <br>
                    <h4 class="text-light">Border Option</h4>
                    <div class="toolbar">
                        <div class="toolbar-section">
                            <button type="button" class="toolbar-button"     id=leftBorderColor      name="leftBorderColor"      value="" title="<%=userProperties.getLanguage("leftBorderColor")%>">   <span class="mif-chevron-thin-left"></span></button>
                            <button type="button" class="toolbar-button"     id=topBorderColor       name="topBorderColor"       value="" title="<%=userProperties.getLanguage("topBorderColor")%>">    <span class="mif-chevron-thin-up"></span></button>
                            <button type="button" class="toolbar-button"     id=rightBorderColor     name="rightBorderColor"     value="" title="<%=userProperties.getLanguage("rightBorderColor")%>">  <span class="mif-chevron-thin-right"></span></button>
                            <button type="button" class="toolbar-button"     id=bottomBorderColor    name="bottomBorderColor"    value="" title="<%=userProperties.getLanguage("bottomBorderColor")%>"> <span class="mif-chevron-thin-down"></span></button>
                        </div>
                    </div>
					<h4 class="text-light">Border-less Option</h4>
                    <div class="toolbar">
                        <div class="toolbar-section">
                          <button type="button" class="toolbar-button" id=deleteBorder name="deleteRow" value="" title="<%=userProperties.getLanguage("deleteRow")%>"><span class="mif-cross"></span></button>

                        </div>
                    </div>
                    <h4 class="text-light">Font Size</h4>
                    <div class="input-control select">
                        <select id="font-size">
                            <option value="8">8</option>
                            <option value="10" selected>10</option>
                            <option value="12">12</option>
                            <option value="14">14</option>
                            <option value="16">16</option>
                            <option value="18">18</option>
                            <option value="20">20</option>
                            <option value="24">24</option>
                            <option value="28">28</option>
                            <option value="32">32</option>
                        </select>
                    </div>
                    <button type="button" class="button" value="" onclick="setCellFontSize()"><span class="mif-chevron-thin-right"></span></button>
                    <h4 class="text-light">Font Style</h4>
                    <div class="input-control select">
                        <select id="font-style">
                            <option value="0" selected>Normal</option>
                            <option value="1" >Bold</option>
                            <option value="2">Italic</option>
                            <option value="4">Underline</option>
                        </select>
                    </div>
                    <button type="button" class="button" value="" onclick="setCellFontStyle()"><span class="mif-chevron-thin-right"></span></button>
                    <h4 class="text-light">Alignment</h4>
                    <div class="input-control select">
                        <select id="alignment">
                            <option value="0" selected>Left</option>
                            <option value="1" >Center</option>
                            <option value="2">Right</option>
                        </select>
                    </div>
                    <button type="button" class="button" value="" onclick="setCellAlignment()"><span class="mif-chevron-thin-right"></span></button>
                    <h4 class="text-light">Title Style</h4>
                    <div class="input-control select">
                        <select id="title-style">
                            <option value="0" selected>Normal</option>
                            <option value="1" >Bold</option>
                            <option value="2">Italic</option>
                            <option value="4">Underline</option>
                        </select>
                    </div>
                    <button type="button" class="button" value="" onclick="setCellTitleBold()"><span class="mif-chevron-thin-right"></span></button>
                    <br>
                    <br>
                    <h2 class="text-light"><%=userProperties.getLanguage("imageSize")%></h2>
                    <br>
                    <div class="input-control select">
                        <select id="image-size">
                            <option value="1.0" >100%</option>
                            <option value="0.75">75%</option>
                            <option value="0.5">50%</option>
                            <option value="0.25">25%</option>
                            <option value="0.0" selected>Auto Fit</option>
                        </select>
                    </div>
                    <button type="button" class="button" value="" onclick="setCellImageSize()"><span class="mif-chevron-thin-right"></span></button>
                    <br>
                </div>

                <div class="cell colspan2" >
                    <h2 class="text-light"><%=userProperties.getLanguage("reportLayout")%></h2>
                    <br>
                    <div id="tableView" class="Test">
                        <table></table>
                    </div>
                </div>
                <div class="cell" >
                    <h2 class="text-light"><%=userProperties.getLanguage("reportTools")%></h2>
                    <br>
                    <div id = "formField">
                        <div class="toolbar">
                            <div class="toolbar-section">
                                <button type="button" class="toolbar-button" id=removeCellField name="remove" value="" title="<%=userProperties.getLanguage("removeField")%>"><span class="mif-minus"></span></button>
                                <button type="button" class="toolbar-button" id=clearField name="Clear" value="" title="<%=userProperties.getLanguage("clearField")%>"><span class="mif-bin"></span></button>
                                <button type="button" class="toolbar-button" id=addLogo name="addLogo" value="" title="<%=userProperties.getLanguage("addLogo")%>"><span class="mif-file-picture"></span></button>
                            </div>
                        </div>
                        <h4 class="text-light align-left"><%=userProperties.getLanguage("systemFields")%></h4>
                        <div id="selSysField" class="input-control text full-size" data-role="input">
                            <div class="input-control select">
                                <div id="selectDynamicSystemFields"></div>
                            </div>
                            <button type="button" class="button" id="systemField" value="" onclick="addSystemField()"><span class="mif-plus"></span></button>
                        </div>
                        <br/>
                        <h4 class="text-light align-left"><%=userProperties.getLanguage("userFields")%></h4>
                        <div id="selUserField" class="input-control text full-size" data-role="input">
                            <div class="input-control select">
                                <div id="selectDynamicUserFields"></div>
                            </div>
                            <button type="button" class="button" id="userField" value="" onclick="addUserField()"><span class="mif-plus"></span></button>
                        </div>
                    </div>
                </div>
                <input type="hidden" name="report_template_data" id="reportTemplateData">
                <input type="file" id="browseImage" style="display:none">
            </div>
        </div>
        <div data-role="dialog" id="preview-dialog" class="large" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <iframe id="preview-frame" name="preview-frame"></iframe>
        </div>
    </body>
</html>
