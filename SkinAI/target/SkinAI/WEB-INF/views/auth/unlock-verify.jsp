<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận Mở Khóa - SkinAI</title>
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
                    <h1 class="fw-bold m-0 text-success" style="font-family: 'Fragment Mono', sans-serif;">
                        <i class="fa-solid fa-unlock-keyhole"></i>
                    </h1>
                    <h4 class="fw-bold mt-2">Xác nhận OTP</h4>
                    <p class="text-muted mt-2">Nhập mã 6 số chúng tôi vừa gửi đến <b>${email}</b></p>
                </div>

                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <form id="unlockVerifyForm" action="${pageContext.request.contextPath}/auth/unlock-account" method="post">
                        <input type="hidden" name="action" value="verify">
                        <input type="hidden" name="email" value="${email}">

                        <!-- Reusable OTP Component -->
                        <jsp:include page="/WEB-INF/views/layout/otp-input.jsp">
                            <jsp:param name="inputName" value="token"/>
                            <jsp:param name="ttlSeconds" value="300"/>
                        </jsp:include>

                        <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Xác thực &amp; Mở khóa</button>
                        
                        <div class="text-center mb-3">
                            <span class="text-muted small">Chưa nhận được mã?</span>
                            <button type="submit" name="action" value="resend" class="btn btn-link btn-sm p-0 text-decoration-none fw-bold" formnovalidate>
                                Gửi lại mã
                            </button>
                        </div>
                        <div class="text-center">
                            <a href="${pageContext.request.contextPath}/auth/unlock-account" class="text-muted small">
                                <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
