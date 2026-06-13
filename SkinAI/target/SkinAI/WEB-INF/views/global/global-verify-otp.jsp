<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />
    </c:when>
    <c:when test="${user != null}">
        <jsp:include page="/WEB-INF/views/layout/global-header.jsp" />
    </c:when>
    <c:otherwise>
        <!DOCTYPE html>
        <html lang="vi">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>${pageTitle} - DermAI</title>
            <link href="https://fonts.googleapis.com/css2?family=Fragment+Mono&family=Rethink+Sans:wght@400..800&display=swap" rel="stylesheet">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        </head>
        <body class="d-flex align-items-center justify-content-center vh-100 bg-light">
    </c:otherwise>
</c:choose>

<div class="container py-5 mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-white border-0 pt-4 pb-0 px-4 text-center">
                    <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                        <i class="fa-solid fa-shield-halved fa-2x text-primary"></i>
                    </div>
                    <h4 class="fw-bold mb-0 text-dark">${pageTitle}</h4>
                </div>
                <div class="card-body p-4">
                    <p class="text-center text-muted mb-4">
                        ${pageDescription} <strong>${maskedTarget}</strong>. Vui lòng nhập mã vào bên dưới.
                    </p>
                    
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i> ${successMessage}
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                            <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${formAction}" method="post" class="mb-4">
                        <c:if test="${not empty sessionScope.csrfToken}">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        </c:if>
                        <c:forEach var="entry" items="${hiddenInputs}">
                            <input type="hidden" name="${entry.key}" value="${entry.value}">
                        </c:forEach>
                        
                        <div class="mb-4">
                            <label class="form-label text-muted fw-semibold small">Nhập mã OTP</label>
                            <jsp:include page="/WEB-INF/views/global/otp-input.jsp">
                                <jsp:param name="inputName" value="${otpInputName != null ? otpInputName : 'otp'}"/>
                            </jsp:include>
                        </div>
                        
                        <button type="submit" class="btn btn-primary text-white fw-bold w-100 py-2">Xác nhận</button>
                    </form>
                    
                    <form action="${formAction}" method="post" id="resendForm">
                        <c:if test="${not empty sessionScope.csrfToken}">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        </c:if>
                        <c:forEach var="entry" items="${resendHiddenInputs}">
                            <input type="hidden" name="${entry.key}" value="${entry.value}">
                        </c:forEach>
                        <div class="text-center">
                            <button type="submit" id="resendBtn" class="btn btn-link text-decoration-none p-0 fw-bold small" formnovalidate>
                                <i class="fa-solid fa-rotate-right me-1"></i> Gửi lại mã OTP
                            </button>
                        </div>
                    </form>
                    
                    <c:if test="${not empty backLink}">
                        <div class="text-center mt-4">
                            <a href="${backLink}" class="text-muted text-decoration-none small">
                                <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
    </c:when>
    <c:when test="${user != null}">
        <jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
    </c:when>
    <c:otherwise>
        </body>
        </html>
    </c:otherwise>
</c:choose>

