<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập - SkinAI</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:wght@400..800&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>
    <body class="d-flex align-items-center justify-content-center vh-100 bg-light">

        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-6 col-lg-4">

                    <!-- Logo -->
                    <div class="text-center mb-4">
                        <a href="${pageContext.request.contextPath}/home" class="text-decoration-none">
                            <h1 class="fw-bold m-0" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Skin<span class="text-dark">AI</span></h1>
                        </a>
                        <p class="text-muted mt-2">Đăng nhập để sử dụng AI chẩn đoán</p>
                    </div>

                    <!-- Card -->
                    <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">

                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger d-flex flex-column rounded-3 mb-4 py-2" role="alert">
                                <div class="d-flex align-items-center">
                                    <i class="fa-solid fa-circle-xmark me-2"></i> <span>${errorMessage}</span>
                                </div>
                                <c:if test="${param.error == 'account_locked_inactive'}">
                                    <div class="mt-2 ms-4">
                                        <a href="${pageContext.request.contextPath}/auth/unlock-account" class="btn btn-sm btn-outline-danger fw-bold">Mở khóa tài khoản ngay</a>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/auth/login" method="post">
                            <!-- Email or Username -->
                            <div class="mb-3">
                                <label class="form-label text-muted fw-semibold small">Tên đăng nhập hoặc Email</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-regular fa-user"></i></span>
                                    <input type="text" name="usernameOrEmail" class="form-control border-start-0 ps-0" placeholder="Username hoặc Email" required>
                                </div>
                            </div>

                            <!-- Password -->
                            <div class="mb-4">
                                <label for="password" class="form-label text-muted fw-semibold small">
                                    Password
                                </label>

                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted">
                                        <i class="fa-solid fa-lock"></i>
                                    </span>
                                    <input
                                        type="password"
                                        id="password"
                                        name="password"
                                        class="form-control border-start-0 ps-0"
                                        placeholder="Enter your password"
                                        required>
                                </div>

                                <div class="text-end mt-2">
                                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="text-decoration-none small" style="color: var(--skin-secondary);">
                                        Forgot Password?
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
                            <a href="${pageContext.request.contextPath}/auth/google" class="btn btn-outline-dark w-100 fw-bold rounded-pill">
                                <img src="https://cdn-icons-png.flaticon.com/512/2991/2991148.png" width="20" class="me-2" alt="Google"> Đăng nhập bằng Google
                            </a>
                        </form>

                    </div>

                    <!-- Footer Text -->
                    <div class="text-center mt-4 text-muted small">
                        Chưa có tài khoản? <a href="${pageContext.request.contextPath}/auth/register" class="text-decoration-none fw-bold" style="color: var(--skin-secondary);">Đăng ký ngay</a>
                    </div>

                </div>
            </div>
        </div>

    </body>
</html>
