<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.dermathologyai.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user != null) {
        if ("ADMIN".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        } else if ("DOCTOR".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
            return;
        }
    }
    response.sendRedirect(request.getContextPath() + "/home");
%>
