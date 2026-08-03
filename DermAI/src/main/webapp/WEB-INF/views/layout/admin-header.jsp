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
            <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

            <style>
                body {
                    background-color: #f8fafc;
                    font-family: 'Inter', system-ui, -apple-system, sans-serif;
                }

                .navbar-custom {
                    background-color: #ffffff;
                    border-bottom: 1px solid #e2e8f0;
                    padding-top: 0.4rem;
                    padding-bottom: 0.4rem;
                    transition: box-shadow 0.3s ease;
                }

                .navbar-custom:hover {
                    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
                }

                .navbar-brand {
                    font-size: 1.3rem;
                    letter-spacing: -0.5px;
                    transition: transform 0.3s ease;
                }

                .navbar-brand:hover {
                    transform: scale(1.02);
                }

                .brand-leaf-admin {
                    color: #0f172a;
                }

                .brand-text-admin {
                    background: linear-gradient(135deg, #000000 0%, #1e293b 45%, #475569 100%);
                    -webkit-background-clip: text;
                    background-clip: text;
                    -webkit-text-fill-color: transparent;
                    color: transparent;
                }

                .admin-badge {
                    font-size: 0.65rem;
                    font-weight: 700;
                    padding: 0.25rem 0.65rem;
                    border-radius: 999px;
                    background: linear-gradient(135deg, #000000, #334155);
                    color: #fff;
                    letter-spacing: 0.04em;
                    text-transform: uppercase;
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
                    background: linear-gradient(90deg, #000000, #475569);
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
                }

                /* --- Highlighted Back Button --- */
                .nav-link-highlight {
                    font-size: 0.75rem;
                    font-weight: 700;
                    color: #0f172a;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                    padding: 0.5rem 1rem;
                    background: linear-gradient(135deg, rgba(15, 23, 42, 0.08), rgba(71, 85, 105, 0.12));
                    border-radius: 20px;
                    text-decoration: none;
                    transition: all 0.3s ease;
                    display: inline-flex;
                    align-items: center;
                }

                .nav-link-highlight:hover {
                    background: linear-gradient(135deg, rgba(15, 23, 42, 0.14), rgba(71, 85, 105, 0.2));
                    color: #000;
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
                    /* Dịch chữ nhẹ sang phải khi hover */
                }

                /* Cải thiện Icon Logout */
                .dropdown-item.text-danger:hover {
                    background-color: #fef2f2 !important;
                    color: #dc2626 !important;
                }
            </style>
        </head>

        <body style="overflow: hidden;">

            <nav class="navbar navbar-custom sticky-top" style="height: 64px; flex-wrap: nowrap;">
                <div class="container-fluid px-4 d-flex align-items-center justify-content-between">

                    <div class="d-flex align-items-center gap-3">
                        <a class="navbar-brand d-flex align-items-center fw-bold m-0"
                            href="${pageContext.request.contextPath}/admin/dashboard" aria-label="Trang chủ Admin">
                            <i class="fa-solid fa-leaf brand-leaf-admin me-2 fs-4"></i>
                            <span class="fs-4 brand-text-admin">DermAI</span>
                        </a>
                        <span class="admin-badge">Admin</span>
                    </div>

                    <div class="flex-grow-1 mx-4 d-none d-md-block" style="max-width: 400px;">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-0 rounded-start-pill px-3"><i
                                    class="fa-solid fa-search text-muted"></i></span>
                            <input type="text" id="global-search"
                                class="form-control border-0 bg-light rounded-end-pill ps-0"
                                placeholder="Tìm kiếm nhanh..." aria-label="Tìm kiếm">
                        </div>
                    </div>

                    <div class="d-flex align-items-center gap-3">
                        <a href="${pageContext.request.contextPath}/admin/notifications"
                            class="btn btn-light rounded-circle shadow-sm d-flex align-items-center justify-content-center position-relative"
                            style="width: 40px; height: 40px;" title="Thông báo" aria-label="Thông báo">
                            <i class="fa-regular fa-bell"></i>
                            <span id="admin-notif-badge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none" style="font-size: 0.6rem;">
                                0
                            </span>
                        </a>

                        <div class="dropdown">
                            <button
                                class="nav-link profile-dropdown-toggle dropdown-toggle text-start d-flex align-items-center border-0 bg-transparent p-0"
                                type="button" data-bs-toggle="dropdown" aria-label="Tài khoản">
                                <c:set var="avatarUser" value="${sessionScope.user}" scope="request" />
                                <c:set var="fallbackIcon" value="fa-regular fa-user" scope="request" />
                                <jsp:include page="/WEB-INF/views/layout/_nav-avatar.jsp" />
                                <span class="d-none d-lg-inline ms-2 fw-semibold text-dark">${sessionScope.user.fullName
                                    != null ? sessionScope.user.fullName : 'Super Admin'}</span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom mt-2 border-0 shadow-sm">
                                <li>
                                    <a class="dropdown-item d-flex align-items-center"
                                        href="${pageContext.request.contextPath}/account/profile">
                                        <i class="fa-regular fa-id-badge fa-fw me-2 text-muted"></i> Hồ Sơ
                                    </a>
                                </li>
                                <li>
                                    <hr class="dropdown-divider">
                                </li>
                                <li>
                                    <form action="${pageContext.request.contextPath}/auth/logout" method="post"
                                        class="m-0 p-0">
                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                        <button type="submit"
                                            class="dropdown-item d-flex align-items-center text-danger w-100 bg-transparent border-0">
                                            <i class="fa-solid fa-arrow-right-from-bracket fa-fw me-2"></i> Đăng Xuất
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </nav>

            <div class="d-flex" style="height: calc(100vh - 64px); overflow: hidden;">
                <jsp:include page="/WEB-INF/views/layout/_admin-sidebar.jsp" />
                <main class="flex-grow-1" style="overflow-y: auto; background-color: #f8fafc; position: relative;"
                    id="main-content">