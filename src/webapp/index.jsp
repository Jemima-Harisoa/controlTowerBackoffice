<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirection automatique vers le dashboard si connecté, sinon vers login
    HttpSession userSession = request.getSession(false);
    if (userSession != null && userSession.getAttribute("user") != null) {
        response.sendRedirect("dashboard");
    } else {
        response.sendRedirect("login");
    }
%>