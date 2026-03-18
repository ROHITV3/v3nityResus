<%@page import="v3nity.std.biz.data.common.UserProperties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
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
                    load('Custom/${custom}/support.jsp');
                }
            });

        </script>
    </head>
    <body>       
        <h1 class="text-light">Support Information</h1>
        <h4 class="text-light"><span class="mif-mail"> Email: support@v3smarttech.com</span></h4>
        <h4 class="text-light"><span class="mif-phone"> SG Tel: +65 64884175 </span></h4>
        <h4 class="text-light"><span class="mif-phone"> VN Tel: +84 896699033 </span></h4>
    
    </body>
</html>
