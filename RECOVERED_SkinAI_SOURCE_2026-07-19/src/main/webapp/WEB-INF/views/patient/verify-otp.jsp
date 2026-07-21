<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />
    </c:otherwise>
</c:choose>

<div class="container py-5 mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-white border-0 pt-4 pb-0 px-4 text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                        <i class="fa-solid fa-shield-halved fa-2x text-warning"></i>
                    </div>
                    <h4 class="fw-bold mb-0 text-dark">Xác Thực OTP</h4>
                </div>
                <div class="card-body p-4">
                    <p class="text-center text-muted mb-4">
                        Một mã xác thực gồm 6 chữ số đã được gửi đến <strong>${maskedTarget}</strong>. Vui lòng nhập mã vào bên dưới để xác nhận thay đổi bảo mật của bạn.
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

                    <form action="${pageContext.request.contextPath}/patient/profile" method="post" class="mb-4">
                        <input type="hidden" name="action" value="verify_security_otp">
                        
                        <div class="mb-4">
                            <label class="form-label text-muted fw-semibold small">Nhập mã OTP</label>
                            <jsp:include page="/WEB-INF/views/layout/otp-input.jsp">
                                <jsp:param name="inputName" value="otp"/>
                            </jsp:include>
                        </div>
                        
                        <button type="submit" class="btn btn-warning text-white fw-bold w-100 py-2">Xác nhận & Cập nhật</button>
                    </form>
                    
                    <form action="${pageContext.request.contextPath}/patient/profile" method="post" id="resendForm">
                        <input type="hidden" name="action" value="resend_otp">
                        <div class="text-center">
                            <button type="submit" id="resendBtn" class="btn btn-link text-decoration-none p-0 fw-bold small" formnovalidate>
                                <i class="fa-solid fa-rotate-right me-1"></i> Gửi lại mã OTP
                            </button>
                        </div>
                    </form>
                    
                    <div class="text-center mt-4">
                        <a href="${pageContext.request.contextPath}/patient/profile" class="text-muted text-decoration-none small">
                            <i class="fa-solid fa-arrow-left me-1"></i> Hủy & Quay lại Hồ sơ
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript removed to comply with Non-JS requirement -->

<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
    </c:otherwise>
</c:choose>
