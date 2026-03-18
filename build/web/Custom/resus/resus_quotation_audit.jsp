<%--
    Document   : wars_work_order_plan
    Created on : 23 Mar, 2022, 1:24:58 PM
    Author     : Kevin
--%>
<%@page import="org.json.simple.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.cust.biz.resus.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%

    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    //WarsDataHandler dataHandler = new WarsDataHandler();

    Connection connection = null;

    JSONArray staffList = null;

    JSONArray warrantStatusList = null;

    try {
        connection = listProperties.getDatabasePool().getConnection();

        //dataHandler.setConnection(connection);

        //staffList = dataHandler.getStaffList(listProperties.getUser().getInt("customer_id"));

        //warrantStatusList = dataHandler.getWarrantStatusList();

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
            #update_address {
                float:left; 
            }
            #update_expiry_date{
                float:left; 
                padding-left:15px;
            }
            #update_agency_ic{
                float:left;
            }
            #update_chargable{
                float:left;
                padding-left:15px;
            }
        </style> 
        <script>
            $(document).ready(function ()
            {
                $("#dateTimePicker-expiry-date").AnyTime_picker({
                    format: "%d/%m/%Y"
                            //earliest: (new Date()).getTime(),
                            //latest: (new Date()).getTime() + 604800000      // 7 days...
                });
            });

            function filterOffenderId(offenderId)
            {
                $('div[name="offender_id_number"] :input').val(offenderId);

                customFilter_${namespace}();
            }

            function filterWarrantNo(warrantNo)
            {
                $('div[name="warrant_number"] :input').val(warrantNo);

                customFilter_${namespace}();
            }
            
            function downloadQuotation(id) {
                var pdfdialog = window.open("ResusQuotationController?type=plan&action=downloadQuotationAudit&id=" + id, "_blank", "toolbar=no,status=no,scrollbars=no,menubar=no,height=" + screen.height + ",width=" + screen.width + ",resizeable=no");
                pdfdialog.moveTo(0, 0);
            }

            
        </script>
    </head>
    <body>
    </body>
</html>
