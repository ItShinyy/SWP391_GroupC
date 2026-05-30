<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - SkinAI</title>
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
                    <p class="text-muted mt-2">Khôi phục mật khẩu tài khoản</p>
                </div>

                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth/forgot-password" method="post">
                        <div class="mb-4">
                            <label class="form-label text-muted fw-semibold small">Nhập địa chỉ Email đã đăng ký</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-regular fa-envelope"></i></span>
                                <input type="email" name="email" class="form-control border-start-0 ps-0" placeholder="name@example.com" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Nhận mã OTP qua Email</button>
                    </form>
                </div>
                <div class="text-center mt-4 text-muted small">
                    <a href="${pageContext.request.contextPath}/auth/login" class="text-decoration-none fw-bold text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại đăng nhập</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
