<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.skinai.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user != null && "ADMIN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    } else {
        response.sendRedirect(request.getContextPath() + "/home");
    }
%>
