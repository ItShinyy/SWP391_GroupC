<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - DermAI</title>
    <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:wght@400..800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="d-flex align-items-center justify-content-center vh-100 bg-light">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-4">
                <div class="text-center mb-4">
                    <a href="${pageContext.request.contextPath}/home" class="text-decoration-none">
                        <h1 class="fw-bold m-0" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Skin<span class="text-dark">AI</span></h1>
                    </a>
                    <p class="text-muted mt-2 mb-1">Tạo mật khẩu mới</p>
                    <c:if test="${not empty sessionScope.maskedIdentifier}">
                        <p class="small text-muted mb-0">Mã xác thực đã được gửi đến <strong>${sessionScope.maskedIdentifier}</strong></p>
                    </c:if>
                </div>

                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth/reset-password" method="post">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <!-- Hidden identifier -->
                        <input type="hidden" name="identifier" value="${identifier}">

                        <div class="mb-3">
                            <label class="form-label text-muted fw-semibold small">Mã xác thực OTP (6 số)</label>
                            <!-- Reusable OTP Component -->
                            <jsp:include page="/WEB-INF/views/global/otp-input.jsp">
                                <jsp:param name="inputName" value="token"/>
                                <jsp:param name="ttlSeconds" value="300"/>
                            </jsp:include>
                        </div>

                        <div class="mb-3">
                            <label class="form-label text-muted fw-semibold small">Mật khẩu mới</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-lock"></i></span>
                                <input type="password" name="newPassword" class="form-control border-start-0 ps-0" placeholder="Nhập mật khẩu" required minlength="6">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label text-muted fw-semibold small">Xác nhận mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-lock"></i></span>
                                <input type="password" name="confirmPassword" class="form-control border-start-0 ps-0" placeholder="Nhập mật khẩu" required minlength="6">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Đổi mật khẩu</button>
                    </form>

                    <div class="text-center mt-3">
                        <span class="text-muted small">Chưa nhận được mã?</span>
                        <form action="${pageContext.request.contextPath}/auth/forgot-password" method="POST" class="d-inline">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="identifier" value="${identifier}">
                            <button type="submit" class="btn btn-link btn-sm text-decoration-none fw-bold p-0" formnovalidate>Gửi lại mã</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>



