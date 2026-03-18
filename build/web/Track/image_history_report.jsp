<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%    
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    AssetTreeView assetTreeView = new AssetTreeView(userProperties);

    assetTreeView.setIdentifier("filter-asset");

    assetTreeView.loadData(userProperties);

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today) + " 00:00:00";

    String inputEndDate = dateTimeFormatter.format(today) + " 23:59:59";

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <link href="css/metricsgraphics.css" rel="stylesheet">
        <title>${title}</title>
        <script src="js/d3.min.js"></script>
        <script src="js/metricsgraphics.min.js"></script>
        <script type="text/javascript" >

            $(document).ready(function()
            {

                $("#getChart").click(function()
                {
                    var ids = getTreeId('tree-view-filter-asset', 'filter-asset-id');

                    if (ids.split(',').length > 3)
                    {
                        dialog('Maximum Reached', 'You can only select up to 3 assets', 'alert');
                    }
                    else
                    {
                        if (ids.length == 0)
                        {
                            dialog('No asset selected', 'Please select an asset', 'alert');
                        }
                        getImage(ids);
                    }

                    $('#getChart').click(function()
                    {

                        $("#images").empty();

                        $("#preview").attr("src", "");

                        getImage(ids);

                    });
                });

                $("#historyFromDate").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#historyToDate").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
            });



            function resetDate()
            {
                var resetStartDate = '<%=inputStartDate%>';

                var resetEndDate = '<%=inputEndDate%>';

                $("#historyFromDate").val(resetStartDate);

                $("#historyToDate").val(resetEndDate);
            }

            function dispose()
            {

                $("#historyFromDate").AnyTime_noPicker();

                $("#historyToDate").AnyTime_noPicker();

            }

            function getImage(ids)
            {

                var startDate = document.getElementById("historyFromDate").value;

                var endDate = document.getElementById("historyToDate").value;

                $.ajax({
                    type: 'POST',
                    url: 'ImageHistoryController',
                    data: {
                        action: 'get',
                        type: 'image_history_report',
                        ids: ids,
                        startDate: startDate,
                        endDate: endDate
                    },
                    success: function(data)
                    {

                        if (data.data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                if (data.data.length > 0)
                                {
                                    for (var i = 0; i < data.data.length; i++)
                                    {
                                        var filepath = data.data[i].filedata;
                                        $("<img/>").attr({
                                            onClick: "getPreview(\"" + filepath + "\"," + i + ")",
                                            width: 96,
                                            height: 72,
                                            border: 2,
                                            src: filepath
                                        }).appendTo(("#images"));
                                        ;

                                    }
                                }
                                else
                                {
                                    dialog('No image found', 'Please select an appropriate date', 'alert');
                                }
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
//                        else
//                        {
//                            $('#main').load('Common/expired.jsp');
//                        }
                    },
                    error: function(jqXHR)
                    {

                        alert("Error!!" + jqXHR.status + jqXHR.responseText);

                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }
            function getPreview(filepath, i)
            {  // Generate preview
                $('#images div').contents().unwrap();
                $("#" + i + "").wrap("<div style=\"height: 72px; width: 96px;\" class=\"image-container element-selected\"></div>");
                $("#preview").attr("src", filepath);
            }

        </script>
    </head>
    <body>
        <%@ include file="../Common/dialog.jsp"%>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("imageHistory")%></h1>
            <input id="assetId" value="" type="hidden">
        </div>
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="getChart" name="getChart"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" name="reset" value="" onclick="resetDate()"><span class="mif-undo"></span></button>
            </div>
        </div>
        <br>
        <div class="grid" style="max-width: 100%">
            <div class="row cells3">
                <div class="cell dashboard-chart">
                    <h3 class="text-light align-left"><%=userProperties.getLanguage("filter")%></h3>
                    <% assetTreeView.outputHTML(out, userProperties);%>
                </div>
                <div class="cell">
                    Date-Range
                    <br/>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="historyFromDate" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="historyToDate" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="<%=inputEndDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <br/><br/><br/>
                    <h3 class="text-light">Image Preview</h3>
                    <img id="preview" style="height:384px;width:512px;" src=""/>
                </div>
                <h3 class="text-light">Image Gallery</h3>
                <div class="cell">
                    <div class="dataTables_scrollbody" style="overflow:auto; height:500px; width:100%;">
                        <table border="0" cellpadding="0" cellspacing="0" width="80%">
                            <tbody id ="emptyTable">
                            <div id="images"></div>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </body>
</html>
