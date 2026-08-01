<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên kết tài khoản Google - DermAI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="d-flex align-items-center justify-content-center vh-100 bg-light">
    <main class="card shadow-sm border-0 rounded-4 p-4 p-md-5" style="max-width: 460px;">
        <h1 class="h4 fw-bold">Liên kết tài khoản Google?</h1>
        <p class="text-muted mb-4">
            Email <strong>${maskedGoogleEmail}</strong> đã có tài khoản DermAI. Bạn có muốn liên kết Google để đăng nhập vào tài khoản đó không?
        </p>
        <form action="${pageContext.request.contextPath}/auth/google/link" method="post" class="d-grid gap-2">
            <input type="hidden" name="csrf_token" value="${csrfToken}">
            <button type="submit" name="action" value="link" class="btn btn-skin fw-bold">Liên kết và đăng nhập</button>
            <button type="submit" name="action" value="cancel" class="btn btn-outline-secondary">Không, quay lại đăng nhập</button>
        </form>
    </main>
</body>
</html>
