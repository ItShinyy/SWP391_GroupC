<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mở Khóa Tài Khoản - SkinAI</title>
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
                    <h1 class="fw-bold m-0 text-danger" style="font-family: 'Fragment Mono', sans-serif;"><i class="fa-solid fa-lock"></i></h1>
                    <h4 class="fw-bold mt-2">Mở Khóa Tài Khoản</h4>
                    <p class="text-muted mt-2">Gửi mã OTP để khôi phục tài khoản bị khóa do không hoạt động.</p>
                </div>

                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth/unlock-account" method="post">
                        <div class="mb-4">
                            <label class="form-label text-muted fw-semibold small">Nhập địa chỉ Email của bạn</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-regular fa-envelope"></i></span>
                                <input type="email" name="email" class="form-control border-start-0 ps-0" placeholder="name@example.com" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Gửi mã OTP mở khóa</button>
                    </form>
                </div>
                <div class="text-center mt-4 text-muted small">
                    <a href="${pageContext.request.contextPath}/auth/login" class="text-decoration-none fw-bold text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
