<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SkinAI - Chẩn đoán bệnh da liễu bằng AI</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:ital,wght@0,400..800;1,400..800&display=swap" rel="stylesheet">
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm py-3 sticky-top">
    <div class="container">
        <!-- Logo -->
        <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/home">
            <h2 class="m-0 fw-bold" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Skin<span class="text-dark">AI</span></h2>
        </a>

        <!-- Mobile Toggle -->
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Menu -->
        <div class="collapse navbar-collapse justify-content-center" id="navbarNav">
            <ul class="navbar-nav gap-3">
                <li class="nav-item">
                    <a class="nav-link fw-semibold" href="${pageContext.request.contextPath}/home">Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-primary" href="${pageContext.request.contextPath}/patient/diagnose">Chẩn đoán AI</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold" href="${pageContext.request.contextPath}/articles">Kiến thức</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold" href="${pageContext.request.contextPath}/clinics">Phòng khám</a>
                </li>
            </ul>
        </div>

        <!-- Auth / CTA -->
        <div class="d-none d-lg-flex align-items-center">
            <c:choose>
                <c:when test="${empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline-primary rounded-pill px-4 fw-bold">Đăng nhập</a>
                </c:when>
                <c:otherwise>
                    <div class="dropdown">
                        <button class="btn btn-skin dropdown-toggle px-4 fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="${sessionScope.user.avatarUrl != null ? sessionScope.user.avatarUrl : pageContext.request.contextPath.concat('/assets/img/default-avatar.png')}" class="rounded-circle me-2" width="24" height="24" alt="Avatar">
                            ${sessionScope.user.fullName}
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 mt-2" style="border-radius: var(--skin-radius);">
                            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-chart-line me-2 text-muted"></i>Admin Portal</a></li>
                            </c:if>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/patient/profile"><i class="fa-regular fa-id-card me-2 text-muted"></i>Hồ sơ</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/patient/reports"><i class="fa-solid fa-file-medical me-2 text-muted"></i>Lịch sử khám</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <form action="${pageContext.request.contextPath}/auth/logout" method="post" class="m-0 p-0">
                                    <button type="submit" class="dropdown-item text-danger fw-bold"><i class="fa-solid fa-arrow-right-from-bracket me-2"></i>Đăng xuất</button>
                                </form>
                            </li>
                        </ul>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>

<!-- Start Main Content -->
<main>
