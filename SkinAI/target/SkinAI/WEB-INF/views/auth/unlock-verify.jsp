<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
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
                    <h1 class="fw-bold m-0 text-success" style="font-family: 'Fragment Mono', sans-serif;"><i class="fa-solid fa-unlock-keyhole"></i></h1>
                    <h4 class="fw-bold mt-2">Xác nhận OTP</h4>
                    <p class="text-muted mt-2">Nhập mã 6 số chúng tôi vừa gửi đến <b>${email}</b></p>
                </div>

                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth/unlock-account" method="post">
                        <input type="hidden" name="action" value="verify">
                        <input type="hidden" name="email" value="${email}">

                        <div class="mb-4">
                            <label class="form-label text-muted fw-semibold small">Mã xác thực OTP</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-key"></i></span>
                                <input type="text" name="token" class="form-control border-start-0 ps-0 text-center fw-bold fs-5" placeholder="------" maxlength="6" required>
                            </div>
                            <div class="form-text text-danger small">Mã OTP sẽ hết hạn sau 5 phút.</div>
                        </div>

                        <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Xác thực & Mở khóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
