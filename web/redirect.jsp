<%
    String custom = (String) request.getAttribute("custom");
    
    response.sendRedirect("menu?custom=" + custom);
%>