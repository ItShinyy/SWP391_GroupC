<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>DermAI - Admin Portal</title>

        <!-- Bootstrap 5 & Font Awesome -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

        <style>
            body {
                background-color: #f8fafc;
                font-family: 'Inter', system-ui, -apple-system, sans-serif;
            }

            /* --- Custom Modern Navbar --- */
            .navbar-custom {
                background-color: #ffffff;
                border-bottom: 1px solid #e2e8f0;
                padding-top: 0.8rem;
                padding-bottom: 0.8rem;
                transition: box-shadow 0.3s ease;
            }
            .navbar-custom:hover {
                box-shadow: 0 4px 20px rgba(0,0,0,0.02);
            }
            
            .navbar-brand {
                font-size: 1.3rem;
                letter-spacing: -0.5px;
                transition: transform 0.3s ease;
            }
            .navbar-brand:hover {
                transform: scale(1.02);
            }

            .navbar-custom .nav-link {
                font-size: 0.8rem;
                font-weight: 600;
                color: #64748b;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                padding: 0.5rem 1rem;
                transition: color 0.3s ease;
                position: relative;
            }
            
            /* Hiệu ứng gạch chân trượt ra từ giữa khi Hover */
            .navbar-custom .nav-link::after {
                content: '';
                position: absolute;
                width: 0;
                height: 2px;
                bottom: 0;
                left: 50%;
                background-color: #198754; /* Màu xanh lá đồng bộ với logo */
                transition: all 0.3s ease;
                transform: translateX(-50%);
                border-radius: 2px;
            }
            .navbar-custom .nav-link:hover::after, 
            .navbar-custom .nav-link.active::after {
                width: 80%;
            }

            .navbar-custom .nav-link:hover, .navbar-custom .nav-link.active {
                color: #0f172a;
            }

            /* --- Highlighted Back Button --- */
            .nav-link-highlight {
                font-size: 0.75rem;
                font-weight: 700;
                color: #198754;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                padding: 0.5rem 1rem;
                background-color: rgba(25, 135, 84, 0.1);
                border-radius: 20px;
                text-decoration: none;
                transition: all 0.3s ease;
                display: inline-flex;
                align-items: center;
            }
            .nav-link-highlight:hover {
                background-color: rgba(25, 135, 84, 0.2);
                color: #146c43;
                transform: translateY(-1px);
            }
            
            /* Profile Dropdown Minimalist */
            .profile-dropdown-toggle {
                color: #475569;
                font-weight: 500;
                font-size: 0.95rem;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                background: transparent;
                border: none;
                padding: 0.5rem;
                transition: color 0.3s, transform 0.2s;
            }
            .profile-dropdown-toggle:hover {
                color: #0f172a;
            }
            .profile-dropdown-toggle:active {
                transform: scale(0.95);
            }

            /* Hiệu ứng trượt mượt mà cho Dropdown */
            .dropdown-menu-custom {
                border-radius: 8px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1);
                min-width: 200px;
                animation: slideDownFade 0.3s ease forwards;
                transform-origin: top center;
            }
            
            @keyframes slideDownFade {
                from { opacity: 0; transform: translateY(-10px) scale(0.98); }
                to { opacity: 1; transform: translateY(0) scale(1); }
            }

            .dropdown-menu-custom .dropdown-item {
                font-size: 0.9rem;
                font-weight: 500;
                padding: 0.6rem 1.2rem;
                color: #475569;
                transition: all 0.2s;
                border-radius: 4px;
                margin: 0 0.3rem;
                width: auto;
            }
            .dropdown-menu-custom .dropdown-item:hover {
                background-color: #f1f5f9;
                color: #0f172a;
                transform: translateX(3px); /* Dịch chữ nhẹ sang phải khi hover */
            }
            
            /* Cải thiện Icon Logout */
            .dropdown-item.text-danger:hover {
                background-color: #fef2f2 !important;
                color: #dc2626 !important;
            }
        </style>
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-custom sticky-top">
            <div class="container-fluid px-4">
                
                <!-- Left: Logo & Home Page Link -->
                <div class="d-flex align-items-center gap-4">
                    <a class="navbar-brand d-flex align-items-center fw-bold text-dark m-0" href="${pageContext.request.contextPath}/home">
                        <i class="fa-solid fa-leaf text-success me-2 fs-4"></i>
                        <span class="fs-4">DermAI</span>
                    </a>
                </div>

                <!-- Mobile Toggle Button -->
                <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                    <i class="fa-solid fa-bars"></i>
                </button>

                <div class="collapse navbar-collapse" id="navbarContent">
                    
                    <!-- Center/Right: Navigation Links (ms-auto pushes it to the right) -->
                    <ul class="navbar-nav ms-auto align-items-lg-center">
                        
                        <!-- Highlighted external navigation link -->
                        <li class="nav-item me-lg-3 mb-2 mb-lg-0">
                            <a class="nav-link-highlight" href="${pageContext.request.contextPath}/home">
                                <i class="fa-solid fa-arrow-left me-2"></i> Trở Về Trang Chủ
                            </a>
                        </li>

                        <!-- Vertical Divider (Desktop Only) -->
                        <div class="vr mx-2 d-none d-lg-block" style="opacity: 0.15; height: 24px; align-self: center;"></div>
                        
                        <!-- Internal Admin Links -->
                        <li class="nav-item ms-lg-2">
                            <a class="nav-link ${pageContext.request.requestURI.contains('dashboard') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">Thống Kê</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('ai-results') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/ai-results">Kết Quả Chẩn Đoán AI</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('users') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">Quản Lý Người Dùng</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('bookings') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/bookings">Quản Lý Đặt Lịch</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('clinics') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/clinics">Quản Lý Phòng Khám</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('audit') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/audit-logs">Nhật Ký Hoạt Động</a>
                        </li>

                        <!-- Vertical Divider (Desktop Only) -->
                        <div class="vr mx-3 d-none d-lg-block" style="opacity: 0.15; height: 24px; align-self: center;"></div>

                        <!-- Right: Profile Dropdown -->
                        <li class="nav-item dropdown mt-3 mt-lg-0">
                            <button class="nav-link profile-dropdown-toggle dropdown-toggle w-100 text-start" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fa-regular fa-user me-1"></i> 
                                ${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Super Admin'}
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom mt-2 border-0 shadow-sm">
                                <li>
                                    <a class="dropdown-item d-flex align-items-center" href="${pageContext.request.contextPath}/account/profile">
                                        <i class="fa-regular fa-id-badge fa-fw me-2 text-muted"></i> Hồ Sơ
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="m-0 p-0">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="dropdown-item d-flex align-items-center text-danger w-100 bg-transparent border-0">
                                            <i class="fa-solid fa-arrow-right-from-bracket fa-fw me-2"></i> Đăng Xuất
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>



