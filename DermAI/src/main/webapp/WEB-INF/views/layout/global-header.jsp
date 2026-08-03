<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title></title>

            <!-- Google Fonts -->
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link
                href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">

            <!-- Bootstrap 5 CSS -->
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

            <!-- FontAwesome 6 -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

            <!-- Custom Style -->
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

            <style>
                body {
                    font-family: 'Inter', sans-serif;
                    background-color: #f8f9fa;
                    display: flex;
                    flex-direction: column;
                    min-height: 100vh;
                }

                main {
                    flex: 1 0 auto;
                }

                /* Navbar Tùy Chỉnh - Tinh tế và Tối giản */
                .navbar-custom {
                    background-color: #ffffff;
                    box-shadow: 0 4px 20px -5px rgba(0, 0, 0, 0.05);
                    padding-top: 1rem;
                    padding-bottom: 1rem;
                }

                /* Style Logo */
                .navbar-brand {
                    letter-spacing: -0.5px;
                    transition: opacity 0.3s;
                }

                .navbar-brand:hover {
                    opacity: 0.9;
                }

                .brand-leaf-user {
                    color: #198754;
                }

                .brand-text-user {
                    background: linear-gradient(135deg, #146c43 0%, #198754 45%, #20c997 100%);
                    -webkit-background-clip: text;
                    background-clip: text;
                    -webkit-text-fill-color: transparent;
                    color: transparent;
                    font-family: 'Fragment Mono', sans-serif;
                }

                /* Links Navigation chính */
                .navbar-custom .nav-link {
                    color: #64748b;
                    font-weight: 500;
                    font-size: 0.95rem;
                    padding: 0.5rem 1rem;
                    margin: 0 0.25rem;
                    transition: all 0.3s ease;
                    position: relative;
                }

                /* Hiệu ứng gạch dưới khi hover Navigation */
                .navbar-custom .nav-link::after {
                    content: '';
                    position: absolute;
                    bottom: 0;
                    left: 50%;
                    width: 0;
                    height: 2px;
                    background: linear-gradient(90deg, #146c43, #198754, #20c997);
                    /* green gradient */
                    transition: all 0.3s ease;
                    transform: translateX(-50%);
                    border-radius: 2px;
                }

                .navbar-custom .nav-link:hover::after,
                .navbar-custom .nav-link.active::after {
                    width: 80%;
                }

                .navbar-custom .nav-link:hover,
                .navbar-custom .nav-link.active {
                    color: #0f172a;
                    /* Màu tối đậm khi hover/active */
                }

                /* Button Đăng nhập nổi bật */
                .nav-link-highlight {
                    background-color: #198754;
                    color: white !important;
                    border-radius: 8px;
                    padding: 0.6rem 1.25rem !important;
                    font-weight: 600;
                    display: inline-flex;
                    align-items: center;
                    transition: all 0.3s ease;
                    box-shadow: 0 4px 10px rgba(25, 135, 84, 0.2);
                    text-decoration: none;
                }

                .nav-link-highlight:hover {
                    background-color: #146c43;
                    transform: translateY(-2px);
                    box-shadow: 0 6px 15px rgba(25, 135, 84, 0.3);
                    color: white !important;
                }

                /* Dropdown User Profile */
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

                .nav-avatar {
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    object-fit: cover;
                    flex-shrink: 0;
                }

                /* Hiệu ứng trượt mượt mà cho Dropdown */
                .dropdown-menu-custom {
                    border-radius: 8px;
                    border: 1px solid #e2e8f0;
                    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
                    min-width: 200px;
                    animation: slideDownFade 0.3s ease forwards;
                    transform-origin: top center;
                }

                @keyframes slideDownFade {
                    from {
                        opacity: 0;
                        transform: translateY(-10px) scale(0.98);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0) scale(1);
                    }
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
                    /* Dịch chút nhẹ sang phải khi hover */
                }

                /* Cải thiện Icon Logout */
                .dropdown-item.text-danger:hover {
                    background-color: #fef2f2 !important;
                    color: #dc2626 !important;
                }

                .btn-skin {
                    background-color: #198754;
                    color: white;
                }

                .btn-skin:hover {
                    background-color: #146c43;
                    color: white;
                }

                .brand-role-badge {
                    font-size: 0.65rem;
                    font-weight: 700;
                    padding: 0.25rem 0.65rem;
                    border-radius: 999px;
                    background: linear-gradient(135deg, #198754, #146c43);
                    color: #fff;
                    letter-spacing: 0.04em;
                    text-transform: uppercase;
                    white-space: nowrap;
                }
            </style>
        </head>

        <body>

            <nav class="navbar navbar-expand-lg navbar-custom sticky-top">
                <div class="container-fluid px-4">

                    <div class="d-flex align-items-center gap-3">
                        <a class="navbar-brand d-flex align-items-center fw-bold m-0"
                            href="${pageContext.request.contextPath}/home">
                            <i class="fa-solid fa-leaf brand-leaf-user me-2 fs-4"></i>
                            <span class="fs-4 brand-text-user">DermAI</span>
                        </a>
                    </div>

                    <!-- Mobile Toggle Button -->
                    <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse"
                        data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false"
                        aria-label="Toggle navigation">
                        <i class="fa-solid fa-bars"></i>
                    </button>

                    <div class="collapse navbar-collapse" id="navbarContent">

                        <!-- Center/Right: Navigation Links (ms-auto pushes it to the right) -->
                        <ul class="navbar-nav ms-auto align-items-lg-center">

                            <li class="nav-item ms-lg-2">
                                <a class="nav-link " href="${pageContext.request.contextPath}/home">Trang Chủ</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link " href="${pageContext.request.contextPath}/patient/diagnose">Sàng lọc
                                    AI</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link " href="${pageContext.request.contextPath}/global/clinics">Phòng
                                    Khám</a>
                            </li>

                            <!-- Vertical Divider (Desktop Only) -->
                            <div class="vr mx-3 d-none d-lg-block"
                                style="opacity: 0.15; height: 24px; align-self: center;"></div>

                            <!-- Right: Profile Dropdown / Login -->
                            <c:choose>
                                <c:when test="${empty sessionScope.user}">
                                    <li class="nav-item mt-3 mt-lg-0">
                                        <a href="${pageContext.request.contextPath}/auth/login"
                                            class="nav-link-highlight">
                                            <i class="fa-solid fa-right-to-bracket me-2"></i> Đăng Nhập
                                        </a>
                                    </li>
                                </c:when>
                                <c:otherwise>
                                    <c:if
                                        test="${sessionScope.user.role == 'USER' or sessionScope.user.role == 'PATIENT'}">
                                        <li class="nav-item me-lg-1">
                                            <a id="notificationLink" class="nav-link position-relative"
                                                href="${pageContext.request.contextPath}/patient/notifications"
                                                aria-label="Thông báo">
                                                <i class="fa-regular fa-bell"></i>
                                                <span id="notificationBadge"
                                                    class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none"
                                                    style="font-size: 0.65rem;">0</span>
                                            </a>
                                        </li>
                                    </c:if>
                                    <li class="nav-item dropdown mt-3 mt-lg-0">
                                        <button
                                            class="nav-link profile-dropdown-toggle dropdown-toggle w-100 text-start"
                                            type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            <c:set var="avatarUser" value="${sessionScope.user}" scope="request" />
                                            <c:set var="fallbackIcon" value="fa-regular fa-user" scope="request" />
                                            <jsp:include page="/WEB-INF/views/layout/_nav-avatar.jsp" />
                                            ${sessionScope.user.fullName}
                                        </button>
                                        <ul
                                            class="dropdown-menu dropdown-menu-end dropdown-menu-custom mt-2 border-0 shadow-sm">
                                            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                                <li>
                                                    <a class="dropdown-item d-flex align-items-center"
                                                        href="${pageContext.request.contextPath}/admin/dashboard">
                                                        <i class="fa-solid fa-chart-line fa-fw me-2 text-muted"></i>
                                                        Trang Quản Trị
                                                    </a>
                                                </li>
                                                <li>
                                                    <hr class="dropdown-divider">
                                                </li>
                                            </c:if>
                                            <c:if test="${sessionScope.user.role == 'DOCTOR'}">
                                                <li>
                                                    <a class="dropdown-item d-flex align-items-center"
                                                        href="${pageContext.request.contextPath}/doctor/dashboard">
                                                        <i class="fa-solid fa-stethoscope fa-fw me-2 text-muted"></i>
                                                        Trang Quản Trị Bác Sĩ
                                                    </a>
                                                </li>
                                                <li>
                                                    <hr class="dropdown-divider">
                                                </li>
                                            </c:if>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/account/profile">
                                                    <i class="fa-regular fa-id-badge fa-fw me-2 text-muted"></i> Hồ Sơ
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/patient/appointments">
                                                    <i class="fa-regular fa-calendar-check fa-fw me-2 text-muted"></i>
                                                    Lịch Hẹn
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/patient/reports">
                                                    <i class="fa-solid fa-robot fa-fw me-2 text-muted"></i> Kết quả sàng
                                                    lọc
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/patient/medical-records">
                                                    <i class="fa-solid fa-file-medical fa-fw me-2 text-muted"></i> Hồ sơ
                                                    bệnh án
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/patient/invoice">
                                                    <i class="fa-solid fa-receipt fa-fw me-2 text-muted"></i> Hóa đơn
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/patient/feedback">
                                                    <i class="fa-regular fa-comment-dots fa-fw me-2 text-muted"></i>
                                                    Đánh giá của tôi
                                                </a>
                                            </li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center"
                                                    href="${pageContext.request.contextPath}/patient/issue-report">
                                                    <i class="fa-solid fa-life-ring fa-fw me-2 text-muted"></i> Báo sự
                                                    cố
                                                </a>
                                            </li>
                                            <li>
                                                <hr class="dropdown-divider">
                                            </li>
                                            <li>
                                                <form action="${pageContext.request.contextPath}/auth/logout"
                                                    method="post" class="m-0 p-0">
                                                    <input type="hidden" name="csrf_token"
                                                        value="${sessionScope.csrfToken}">
                                                    <button type="submit"
                                                        class="dropdown-item d-flex align-items-center text-danger w-100 bg-transparent border-0">
                                                        <i class="fa-solid fa-arrow-right-from-bracket fa-fw me-2"></i>
                                                        Đăng Xuất
                                                    </button>
                                                </form>
                                            </li>
                                        </ul>
                                    </li>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                    </div>
                </div>
            </nav>

            <!-- Start Main Content -->
            <main>

                <script>
                    (function () {
                        var badge = document.getElementById('notificationBadge');
                        if (!badge) return;
                        var ctx = '${pageContext.request.contextPath}';
                        fetch(ctx + '/patient/notifications?format=count', { credentials: 'same-origin' })
                            .then(function (r) { return r.ok ? r.json() : null; })
                            .then(function (data) {
                                if (!data || !data.unread) return;
                                badge.textContent = data.unread > 99 ? '99+' : String(data.unread);
                                badge.classList.remove('d-none');
                            })
                            .catch(function () { });
                    })();
                </script>