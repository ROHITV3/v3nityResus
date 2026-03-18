<%--
    Document   : wars_work_order_plan
    Created on : 23 Mar, 2022, 1:24:58 PM
    Author     : Kevin
--%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.cust.biz.wars.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    WarsDataHandler dataHandler = new WarsDataHandler();

    Connection connection = null;

    JSONArray staffList = null;

    JSONArray warrantStatusList = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        dataHandler.setConnection(connection);

        staffList = dataHandler.getStaffList(listProperties.getUser().getInt("customer_id"));

        warrantStatusList = dataHandler.getWarrantStatusList();

    } catch (Exception e) {

    } finally {
        listProperties.getDatabasePool().closeConnection(connection);
    }


%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>work order plan</title>
        <style type="text/css"> 
            .container_work_order_plan_1 {
                position: relative;
                width:1200px;
                height:150px;
                padding-top:20px;
                padding-right:15px;
            } 
            #schedule_enforcment {
                float:left; 
            }
            #change_warrant_status{
                float:left; 
                padding-left:15px;
            }
            #update_agency_ic{
                float:right;
            }
        </style> 
        <script>

            $(document).ready(function ()
            {

            });

        </script>
    </head>
    <body>
        
    </body>
</html>
