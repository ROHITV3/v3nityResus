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
        <script type="text/javascript" src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function (e) {
                $('#upload').on('click', function () {
                    var form_data = new FormData();
                    var ins = document.getElementById('multiFiles').files.length;
                    for (var x = 0; x < ins; x++) {
                        form_data.append("files[]", document.getElementById('multiFiles').files[x]);
                    }
                    $.ajax({
                        url: 'ImportEWarrantController?type=system&action=upload', // point to server-side
                        dataType: 'text', // what to expect back from the PHP script
                        cache: false,
                        contentType: false,
                        processData: false,
                        data: form_data,
                        type: 'post',
                        success: function (response) {
                            $('#msg').html(response); // display success response from the PHP script
                        },
                        error: function (response) {
                            $('#msg').html(response); // display error response from the PHP script
                        }
                    });
                });
            });
        </script>
    </head>
    <body>
        <input type="file" id="multiFiles" name="files[]" multiple="multiple"/>
        <button id="upload">Upload</button>
    </form>
</body>
</html>