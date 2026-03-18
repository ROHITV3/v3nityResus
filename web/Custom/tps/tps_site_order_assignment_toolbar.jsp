<%--
    Document   : tps_site_order_assignment_toolbar
    Created on : 16 Mar, 2020, 8:31:40 PM
    Author     : Kevin
--%>

<%@page import="v3nity.cust.biz.tps.data.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    TpsSiteOrder data = (TpsSiteOrder) request.getAttribute("data");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>It is just a customized toolbar</title>
    </head>
    <body>
        <%  if (data.hasAssignmentPool())
            {
        %>
        <div class="toolbar-section">
            <button class="toolbar-button" type="button" title="Toggle vehicle assignment menu" onclick="togglePool()" id=button-pool><span class="mif-truck"></span></button>
        </div>
        <%
            }
        %>
        <%  if (data.hasSiteOrderCopying())
            {
        %>
        <div class="toolbar-section">
            <button class="toolbar-button" type="button" title="Copy selected site orders" onclick="openCopy()"><span class="mif-files-empty"></span></button>
        </div>
        <%
            }
        %>
        <%  if (data.hasSiteOrderOverlaying())
            {
        %>
        <div class="toolbar-section">
            <button class="toolbar-button" type="button" title="Overlay site orders from another date" onclick="openOverlay()"><span class="mif-layers"></span></button>
        </div>
        <%
            }
        %>
        <%  if (data.getUpdatableStatus() > 0)
            {
                int fromStatusId = data.getUpdatableStatus();

                int toStatusId = data.getUpdatingStatus();
        %>
        <div class="toolbar-section">
            <button class="toolbar-button" type="button" title="Update site orders by selection" onclick="selectionUpdate(<%=fromStatusId%>, <%=toStatusId%>)"><span class="mif-checkmark"></span></button>
        </div>
        <div class="toolbar-section">
            <button class="toolbar-button" type="button" title="Update all site orders" onclick="selectionUpdateAll(<%=fromStatusId%>, <%=toStatusId%>)"><span class="mif-checkmark"></span> All</button>
        </div>
        <%
            }
        %>
    </body>
</html>
