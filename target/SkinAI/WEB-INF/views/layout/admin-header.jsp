<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SkinAI - Admin Dashboard</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:ital,wght@0,400..800;1,400..800&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body class="admin-body">

<div class="admin-wrapper">
    <!-- Sidebar -->
    <aside class="admin-sidebar">
        <div class="sidebar-brand">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <span class="text-primary">Skin</span><span class="text-white">AI</span><span class="text-xs">.admin</span>
            </a>
        </div>
        <ul class="sidebar-nav">
            <li>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Dashboard
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/users" class="nav-link">
                    <i class="fa-solid fa-users"></i> Users
                </a>
            </li>
            <!-- MVP: Other links commented out for now -->
            <!--
            <li>
                <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link">
                    <i class="fa-solid fa-file-medical"></i> Reports
                </a>
            </li>
            -->
        </ul>
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-light btn-sm w-100 mb-2">Back to Site</a>
            <form action="${pageContext.request.contextPath}/auth/logout" method="post">
                <button type="submit" class="btn btn-danger btn-sm w-100">Logout</button>
            </form>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="admin-main">
        <header class="admin-header">
            <div class="admin-header-title">
                <h2>Admin Portal</h2>
            </div>
            <div class="admin-header-user">
                <span>Welcome, <strong>${sessionScope.user.fullName}</strong></span>
            </div>
        </header>
        <div class="admin-content">
