<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SkinAI - Admin Portal</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        /* Nền trang màu xám nhạt để làm nổi bật Card trắng */
        body { background-color: #f3f6f9; font-family: 'Inter', sans-serif; }
        
        /* --- CSS CHO HEADER MỚI --- */
        .navbar-custom { background-color: #fcfcfc; border-bottom: 1px solid #eaeaea; }
        .navbar-custom .nav-link { font-size: 0.85rem; font-weight: 600; color: #6c757d; text-transform: uppercase; letter-spacing: 0.5px; padding: 0.5rem 1rem; }
        .navbar-custom .nav-link:hover, .navbar-custom .nav-link.active { color: #1a233a; }
        .profile-btn { background-color: #162044; color: white; border-radius: 50px; font-weight: 500; padding: 0.5rem 1.5rem; transition: 0.3s; border: none; }
        .profile-btn:hover { background-color: #0f1630; color: white; }
        .dropdown-menu-custom { border-radius: 12px; border: 1px solid #eaeaea; box-shadow: 0 10px 30px rgba(0,0,0,0.05); padding: 0.5rem 0; }
        .dropdown-menu-custom .dropdown-item { padding: 0.6rem 1.2rem; font-size: 0.95rem; font-weight: 500; color: #495057; }
        .dropdown-menu-custom .dropdown-item:hover { background-color: #f8f9fa; color: #162044; }
        .dropdown-menu-custom .dropdown-divider { margin: 0.2rem 0; border-color: #f1f1f1; }
        /* -------------------------- */
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-custom py-3 px-4 shadow-sm sticky-top">
    <div class="container-fluid">
        <!-- Logo -->
        <a class="navbar-brand d-flex align-items-center fw-bold fs-4 text-dark" href="${pageContext.request.contextPath}/home">
            <i class="fa-solid fa-leaf text-success me-2"></i> SkinAI
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <!-- Center Nav Links -->
            <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link ${pageContext.request.requestURI.contains('dashboard') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${pageContext.request.requestURI.contains('ai-results') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/ai-results">AI Diagnosis Results</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${pageContext.request.requestURI.contains('users') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">User Management</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${pageContext.request.requestURI.contains('audit') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/audit-logs">Audit Logs</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${pageContext.request.requestURI.contains('home') ? 'active' : ''}" href="${pageContext.request.contextPath}/home">Home Page</a>
                </li>
            </ul>
            
            <!-- Profile Dropdown -->
            <div class="dropdown">
                <button class="btn profile-btn dropdown-toggle d-flex align-items-center" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="fa-regular fa-user me-2"></i> ${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Admin'}
                </button>
                <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom mt-2">
                    <li>
                        <a class="dropdown-item d-flex align-items-center" href="${pageContext.request.contextPath}/patient/profile">
                            <i class="fa-solid fa-user fa-fw me-2 text-muted"></i> Profile
                        </a>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="m-0 p-0">
                            <button type="submit" class="dropdown-item d-flex align-items-center text-danger fw-bold w-100 border-0 bg-transparent">
                                <i class="fa-solid fa-arrow-right-from-bracket fa-fw me-2"></i> Logout
                            </button>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</nav>
