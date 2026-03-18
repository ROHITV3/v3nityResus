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

            $("#uploadBtn").on("click", function ()
            {
                var form = $("#sampleUploadFrm")[0];
                Console.out(form);
                var data = new FormData(form);
                Console.out(data);
                $.ajax({
                    type: 'POST',
                    url: 'EvImportController?type=system&action=upload',
                    data: $("#sampleUploadFrm").serialize(),
                    dataType: "file",
                    enctype: 'multipart/form-data',
                    beforeSend: function ()
                    {
                        $('#button-upload').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        $('#green-pending-dialog').data('dialog').close();
                        dialog('Successfully', 'Green Card Uploaded successfully', 'success');
                    },
                    error: function ()
                    {

                        $('#output').append('<p class="output-error">System has encountered an error</p>');
                    },
                    complete: function ()
                    {
                        $('#button-upload').prop("disabled", false);

                        $('#input-file').val('');   // reset the input file value so that can allow upload the same file again...
                    },
                    async: false
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
            <p><%=userProperties.getLanguage("jobImportInstructions1")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructions2")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructions3")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructions4")%></p>
        </div>
        <div class="section">
            <h4 class="text-light align-left"><%=userProperties.getLanguage("selectImportTemplate")%></h4>
            <div class="treeview-control" style="height:auto">
                <% importTreeView.outputHTML(out, userProperties);%>
            </div>
        </div>

        <input id="choose" type="file" style="display: none" accept=".csv"/>
        <form id="sampleUploadFrm" method="POST" enctype="multipart/form-data">
            <label for="file-upload-input">Select file to upload</label>
            <input type="file" id="file-upload-input" name="file">
            <button type="submit" id="uploadBtn" class="btn btn-primary">Submit</button>
        </form>

    </body>
</html>