<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title>${title}</title>
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/v3nity-admin.css?v=${code}" rel="stylesheet">
        <%  if (!((String) request.getAttribute("custom")).isEmpty())
            {
        %>
        <link href="Custom/${custom}/v3nity-custom.css?v=${code}" rel="stylesheet">
        <%
            }
        %>
    </head>
    <body>
        <div style="margin: 32px 16px;">
            <h1 class="text-light">Unauthorized Access</h1>
            <h4 class="text-light">You do not have permission to access this page. <a href="login?custom=${custom}">Click here to login</a></h4>
        </div>
    </body>
</html>