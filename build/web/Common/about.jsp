<%@page import="v3nity.std.biz.data.common.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%

%>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title></title>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <script type="text/javascript">

            $(document).ready(function()
            {
                if ('${custom}')
                {
                    load('Custom/${custom}/about.jsp');
                }
            });

        </script>
        <style>
            .version {
                font-size: 12px;
                line-height: 20px;
                white-space: pre-line;
            }

        </style>
    </head>
    <body>
        <h1 class="text-light">V3NITY</h1>
        <h4 class="text-light">${name}</h4>
        <h4 class="text-light">Version ${version}</h4>
        <h4 class="text-light">&copy; V3 Smart Technologies Pte. Ltd.</h4>
        <div class="version">
            
        </div>
    </body>
</html>