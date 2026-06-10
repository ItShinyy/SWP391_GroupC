<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực tài khoản - SkinAI</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:wght@400..800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .verify-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.05);
            padding: 40px 30px;
            border: 1px solid #f1f5f9;
        }
        .icon-circle {
            width: 80px;
            height: 80px;
            background: #f0f9ff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: #0284c7;
            font-size: 32px;
        }
        .otp-input {
            letter-spacing: 12px;
            font-size: 24px;
            text-align: center;
            font-family: 'Courier New', Courier, monospace;
            font-weight: 700;
            padding: 15px;
        }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center vh-100 bg-light">

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                
                <div class="text-center mb-4">
                    <a href="${pageContext.request.contextPath}/home" class="text-decoration-none">
                        <h1 class="fw-bold m-0" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Skin<span class="text-dark">AI</span></h1>
                    </a>
                </div>

                <div class="verify-card text-center">
                    <div class="icon-circle">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <h3 class="fw-bold mb-3">Xác thực tài khoản</h3>
                    <p class="text-muted mb-4">Chúng tôi đã gửi mã OTP 6 số đến 
                        <strong>
                            <c:choose>
                                <c:when test="${isPhone}">${userPhone}</c:when>
                                <c:otherwise>${userEmail}</c:otherwise>
                            </c:choose>
                        </strong>.
                    </p>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" role="alert">
                            ${errorMessage}
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success" role="alert">
                            ${successMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth/verify" method="POST" class="mb-4">
                        <input type="hidden" name="action" value="verify_otp">
                        <div class="mb-3">
                            <!-- Reusable OTP Component -->
                            <jsp:include page="/WEB-INF/views/layout/otp-input.jsp">
                                <jsp:param name="inputName" value="otp"/>
                                <jsp:param name="ttlSeconds" value="300"/>
                            </jsp:include>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2 fw-bold" style="background-color: var(--skin-primary); border: none;">Xác Nhận OTP</button>
                    </form>

                    <hr class="my-4 text-muted">
                    
                    <div class="d-flex flex-column gap-2 align-items-center">
                        <span class="text-muted small">Chưa nhận được mã?</span>
                        <form action="${pageContext.request.contextPath}/auth/verify" method="POST">
                            <input type="hidden" name="action" value="resend">
                            <button type="submit" class="btn btn-link btn-sm text-decoration-none fw-bold p-0" id="resendBtn" formnovalidate>Gửi lại mã</button>
                        </form>
                    </div>

                </div>
                
                <div class="text-center mt-4">
                    <a href="${pageContext.request.contextPath}/auth/login" class="text-decoration-none text-muted">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại đăng nhập
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- JavaScript removed to comply with Non-JS requirement -->
</body>
</html>
