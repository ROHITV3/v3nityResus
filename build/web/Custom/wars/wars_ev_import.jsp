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
        <title></title>
        <script type="text/javascript">

            var successCount = 0;

            $(document).ready(function () {
                $("#but_upload").click(function () {
                    var fd = new FormData();
                    var files = $('#file')[0].files[0];
                    fd.append('file', files);

                    $.ajax({
                        url: 'EvImportController?type=system&action=upload',
                        type: 'post',
                        data: fd,
                        contentType: false,
                        processData: false,
                        beforeSend: function ()
                        {
                            $('#but_upload').prop("disabled", true);
                            $('#file').prop("disabled", true);
                        },
                        success: function (response) {
                            alert(response.text);
                            if (response.result != 0) {
                                //alert('file uploaded');
                            } else {
                                //alert('file not uploaded');
                            }
                        },
                        complete: function ()
                        {
                            $('#but_upload').prop("disabled", false);
                            $('#file').prop("disabled", false);
                        },
                        async: true
                    });
                });
            });

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("jobImport")%></h1>
        </div>
        <div class="help-tag" >

            <h4><%=userProperties.getLanguage("instructions")%>:</h4>
            <p><%=userProperties.getLanguage("jobImportInstructionsEV1")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructionsEV2")%></p>
        </div>
        <div class="section">
            <div class="treeview-control" style="height:auto">
                <% importTreeView.outputHTML(out, userProperties);%>
            </div>
        </div>

        <form method="post" action="" enctype="multipart/form-data" id="myform">
            <div >
                <input type="file" id="file" name="file" />
                <input type="button" class="button" value="Upload" id="but_upload">
            </div>
        </form>

    </body>
</html>