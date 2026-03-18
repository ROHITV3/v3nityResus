<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    JobImportTemplateTreeView importTreeView = new JobImportTemplateTreeView(userProperties);

    try {
        importTreeView.setIdentifier("filter-import");

        importTreeView.loadData(userProperties);
    } catch (Exception e) {

    } finally {

    }
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <script type="text/javascript" src="js/jquery.uploadfile.min.js"></script>
        <link href="css/uploadfile.css" rel="stylesheet">
        <title></title>
        <script type="text/javascript">
            $(document).ready(function ()
            {
                var settings = {
                    url: "ImportEWarrantController?type=system&action=upload",
                    method: "POST",
                    allowedTypes: "pdf",
                    fileName: "myfile",
                    multiple: true,
                    onSuccess: function (files, data, xhr)
                    {
                        $("#status").html("<font color='green'>Upload is success</font>");

                    },
                    onError: function (files, status, errMsg)
                    {
                        $("#status").html("<font color='red'>Upload failed</font>");
                    }
                }
                $("#mulitplefileuploader").uploadFile(settings);
            });
        </script>
    </head>
    <body>

        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("importEWarrant")%></h1>
        </div>
        <div class="help-tag" >

            <h4><%=userProperties.getLanguage("instructions")%>:</h4>
            <p><%=userProperties.getLanguage("eWarrantImportInstructionsEV1")%></p>
            <p><%=userProperties.getLanguage("eWarrantImportInstructionsEV2")%></p>
            <p><%=userProperties.getLanguage("eWarrantImportInstructionsEV3")%></p>
        </div>
        
        <div id="mulitplefileuploader">Upload</div>

        <div id="status"></div>
    </body>
</html>