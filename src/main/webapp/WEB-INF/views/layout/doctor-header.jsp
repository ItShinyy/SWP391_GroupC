<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SkinAI - Bác Sĩ Portal</title>

        <!-- Bootstrap 5 & Font Awesome -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Rethink+Sans:300,400,500,600,700&amp;display=auto" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">

        <style>
            body {
                background-color: var(--skin-bg);
                font-family: 'Rethink Sans', system-ui, -apple-system, sans-serif;
            }

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
            
            .navbar-custom .nav-link::after {
                content: '';
                position: absolute;
                width: 0;
                height: 2px;
                bottom: 0;
                left: 50%;
                background-color: var(--skin-primary);
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

            .nav-link-highlight {
                font-size: 0.75rem;
                font-weight: 700;
                color: var(--skin-primary);
                text-transform: uppercase;
                letter-spacing: 0.5px;
                padding: 0.5rem 1rem;
                background-color: rgba(30, 58, 138, 0.1);
                border-radius: 20px;
                text-decoration: none;
                transition: all 0.3s ease;
                display: inline-flex;
                align-items: center;
            }
            .nav-link-highlight:hover {
                background-color: rgba(30, 58, 138, 0.15);
                color: var(--skin-primary);
                transform: translateY(-1px);
            }
            
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
                transform: translateX(3px);
            }
            
            .dropdown-item.text-danger:hover {
                background-color: #fef2f2 !important;
                color: #dc2626 !important;
            }

            .doctor-badge {
                font-size: 0.65rem;
                font-weight: 700;
                padding: 0.25rem 0.6rem;
                border-radius: 20px;
                background: linear-gradient(135deg, var(--skin-primary), var(--skin-secondary));
                color: white;
                letter-spacing: 0.5px;
                text-transform: uppercase;
            }
        </style>
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-custom sticky-top">
            <div class="container-fluid px-4">
                
                <div class="d-flex align-items-center gap-3">
                    <a class="navbar-brand d-flex align-items-center fw-bold text-dark m-0" href="${pageContext.request.contextPath}/doctor/dashboard">
                        <i class="fa-solid fa-leaf text-primary me-2 fs-4"></i>
                        <span class="fs-4">SkinAI</span>
                    </a>
                    <span class="doctor-badge">Bác Sĩ</span>
                </div>

                <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
                    <i class="fa-solid fa-bars"></i>
                </button>

                <div class="collapse navbar-collapse" id="navbarContent">
                    <ul class="navbar-nav ms-auto align-items-lg-center">
                        
                        <li class="nav-item me-lg-3 mb-2 mb-lg-0">
                            <a class="nav-link-highlight" href="${pageContext.request.contextPath}/doctor/dashboard">
                                <i class="fa-solid fa-gauge-high me-2"></i> Dashboard Bác Sĩ
                            </a>
                        </li>                        
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('schedule') ? 'active' : ''}" href="${pageContext.request.contextPath}/doctor/schedule">
                                <i class="fa-regular fa-calendar-check me-1"></i> Lịch Khám
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('history') ? 'active' : ''}" href="${pageContext.request.contextPath}/doctor/appointments/history">
                                <i class="fa-solid fa-clock-rotate-left me-1"></i> Lịch Sử Khám
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('reports') ? 'active' : ''}" href="${pageContext.request.contextPath}/doctor/reports">
                                <i class="fa-solid fa-chart-line me-1"></i> Báo Cáo
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.requestURI.contains('guidelines') ? 'active' : ''}" href="${pageContext.request.contextPath}/doctor/guidelines">
                                <i class="fa-solid fa-book-medical me-1"></i> Phác Đồ Y Khoa
                            </a>
                        </li>

                        <div class="vr mx-3 d-none d-lg-block" style="opacity: 0.15; height: 24px; align-self: center;"></div>

                        <li class="nav-item dropdown mt-3 mt-lg-0">
                            <button class="nav-link profile-dropdown-toggle dropdown-toggle w-100 text-start" type="button" data-bs-toggle="dropdown">
                                <i class="fa-solid fa-user-doctor me-1"></i> 
                                ${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Bác Sĩ'}
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom mt-2 border-0 shadow-sm">
                                <li>
                                    <a class="dropdown-item d-flex align-items-center" href="${pageContext.request.contextPath}/account/profile">
                                        <i class="fa-regular fa-id-badge fa-fw me-2 text-muted"></i> Hồ Sơ Cá Nhân
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="m-0 p-0">
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
