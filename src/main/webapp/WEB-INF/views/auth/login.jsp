<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập - SkinAI</title>
        <meta name="description" content="Đăng nhập vào SkinAI để sử dụng AI chẩn đoán bệnh da liễu.">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:wght@400..800&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <style>
            .lock-card { border-left: 4px solid; border-radius: 10px; padding: 1rem 1.2rem; }
            .lock-temp  { border-color: #f59e0b; background: #fffbeb; }
            .lock-perm  { border-color: #ef4444; background: #fef2f2; }
            .masked-info { font-family: 'Fragment Mono', monospace; font-size: .9rem; background: #f8f9fa; border-radius: 6px; padding: 4px 10px; display: inline-block; }

        </style>
    </head>
    <body class="d-flex align-items-center justify-content-center min-vh-100 bg-light">

        <div class="container py-4">
            <div class="row justify-content-center">
                <div class="col-md-6 col-lg-4">

                    <!-- Logo -->
                    <div class="text-center mb-4">
                        <a href="${pageContext.request.contextPath}/home" class="text-decoration-none">
                            <h1 class="fw-bold m-0" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Skin<span class="text-dark">AI</span></h1>
                        </a>
                        <p class="text-muted mt-2">Đăng nhập để sử dụng AI chẩn đoán</p>
                    </div>

                    <!-- Success message (e.g. after unlock) -->
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success d-flex align-items-center rounded-3 mb-3 py-2" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i> <span>${successMessage}</span>
                        </div>
                    </c:if>

                    <!-- ═══════════════════════════════════════════════════════
                         LOCKED ACCOUNT BANNER (Case A or B)
                    ═══════════════════════════════════════════════════════ -->
                    <c:if test="${isLocked}">

                        <!-- Case A: TEMPORARY lock -->
                        <c:if test="${isTemporaryLocked}">
                            <div class="lock-card lock-temp mb-3">
                                <div class="fw-bold mb-2"><i class="fa-solid fa-lock me-2 text-warning"></i>Tài khoản tạm khóa</div>
                                <p class="mb-2 small text-muted">${errorMessage}</p>

                                <!-- Masked contact info -->
                                <div class="mb-3">
                                    <c:if test="${not empty maskedEmail}">
                                        <div class="mb-1 small">Email: <span class="masked-info">${maskedEmail}</span></div>
                                    </c:if>
                                    <c:if test="${not empty maskedPhone}">
                                        <div class="small">Điện thoại: <span class="masked-info">${maskedPhone}</span></div>
                                    </c:if>
                                </div>

                                <form action="${pageContext.request.contextPath}/auth/unlock-account" method="POST" class="mt-1">
                                    <button type="submit" class="btn btn-warning btn-sm fw-bold w-100">
                                        <i class="fa-solid fa-envelope me-2"></i>Gửi OTP để mở khóa
                                    </button>
                                </form>
                            </div>
                        </c:if>

                        <!-- Case B: PERMANENT ban -->
                        <c:if test="${not isTemporaryLocked}">
                            <div class="lock-card lock-perm mb-3">
                                <div class="fw-bold mb-2"><i class="fa-solid fa-ban me-2 text-danger"></i>Tài khoản đã bị khóa vĩnh viễn</div>
                                <c:if test="${not empty lockReason}">
                                    <p class="mb-2 small">Lý do: <strong>${lockReason}</strong></p>
                                </c:if>

                                <!-- Masked contact -->
                                <div class="mb-3">
                                    <c:if test="${not empty maskedEmail}">
                                        <div class="mb-1 small">Email: <span class="masked-info">${maskedEmail}</span></div>
                                    </c:if>
                                    <c:if test="${not empty maskedPhone}">
                                        <div class="small">Điện thoại: <span class="masked-info">${maskedPhone}</span></div>
                                    </c:if>
                                </div>

                            </div>
                        </c:if>

                    </c:if><!-- end isLocked -->

                    <!-- ═══════════════════════════════════════════════════════
                         STANDARD LOGIN FORM (always shown)
                    ═══════════════════════════════════════════════════════ -->
                    <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">

                        <!-- Generic error message (only if not locked) -->
                        <c:if test="${not isLocked and not empty errorMessage}">
                            <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                                <i class="fa-solid fa-circle-xmark me-2"></i> <span>${errorMessage}</span>
                            </div>
                        </c:if>

                        <form id="loginForm" action="${pageContext.request.contextPath}/auth/login" method="post">
                            <!-- Email or Username -->
                            <div class="mb-3">
                                <label class="form-label text-muted fw-semibold small">Tên đăng nhập hoặc Email</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-regular fa-user"></i></span>
                                    <input type="text" name="usernameOrEmail" class="form-control border-start-0 ps-0"
                                           placeholder="Username hoặc Email" required autocomplete="username">
                                </div>
                            </div>

                            <!-- Password -->
                            <div class="mb-4">
                                <label for="password" class="form-label text-muted fw-semibold small">Mật khẩu</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-lock"></i></span>
                                    <input type="password" id="password" name="password"
                                           class="form-control border-start-0 ps-0"
                                           placeholder="Nhập mật khẩu" required autocomplete="current-password">
                                </div>
                                <div class="text-end mt-2">
                                    <a href="${pageContext.request.contextPath}/auth/forgot-password"
                                       class="text-decoration-none small" style="color: var(--skin-secondary);">
                                        Quên mật khẩu?
                                    </a>
                                </div>
                            </div>

                            <!-- Submit -->
                            <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Đăng nhập</button>

                            <div class="position-relative mb-4 mt-4 text-center">
                                <hr class="text-muted">
                                <span class="position-absolute top-50 start-50 translate-middle px-3 bg-white text-muted small">HOẶC</span>
                            </div>

                            <!-- Google Auth -->
                            <a href="${pageContext.request.contextPath}/auth/google"
                               class="btn btn-outline-dark w-100 fw-bold rounded-pill">
                                <img src="https://cdn-icons-png.flaticon.com/512/2991/2991148.png" width="20" class="me-2" alt="Google"> Đăng nhập bằng Google
                            </a>
                        </form>

                    </div>

                    <!-- Footer Text -->
                    <div class="text-center mt-4 text-muted small">
                        Chưa có tài khoản? <a href="${pageContext.request.contextPath}/auth/register"
                            class="text-decoration-none fw-bold" style="color: var(--skin-secondary);">Đăng ký ngay</a>
                    </div>

                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <!-- JavaScript removed to comply with Non-JS requirement -->
    </body>
</html>
