<%
    response.setHeader("X-Frame-Options", "SAMEORIGIN");
    
    response.setHeader("X-XSS-Protection", "1;mode=block");
	
    response.setHeader("X-Content-Type-Options", "nosniff");
    
    response.setHeader("Strict-Transport-Security", "max-age=864000; includeSubDomains");

    String cookieHeader = response.getHeader("Set-Cookie");

    if (cookieHeader == null)
    {
        response.setHeader("Set-Cookie", "path=" + request.getContextPath() + ";SameSite=Strict;HttpOnly");
    }
    else
    {
        response.setHeader("Set-Cookie", cookieHeader + ";SameSite=Strict;HttpOnly");
    }
    
    response.sendRedirect("login");
%>