<%--
    Document   : tps_ticket
    Created on : 9 Jun, 2021, 9:13:09 PM
    Author     : Kevin
--%>
<%@page import="org.json.simple.*"%>
<%@page import="v3nity.std.util.Utility"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.cust.biz.tps.data.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%

%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>customized page on top of standard list page</title>
        <style>

        </style>
        <script>

            function closeTicket(id)
            {
                $.ajax({
                    url: "tps?type=ticket&action=close",
                    type: "POST",
                    data: {
                        id: id
                    },
                    success: function(response)
                    {
                        if (response.result)
                        {
                            refreshDataTable_${namespace}();

                            dialog('Information', 'ticket closed', 'success');
                        }
                        else
                        {
                            dialog('Error', response.text, 'alert');
                        }
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    }
                });
            }

        </script>
    </head>
    <body>

    </body>
</html>