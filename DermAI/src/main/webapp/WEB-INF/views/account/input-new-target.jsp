<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container py-5 mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm border-0 rounded-4 p-4">
                <div class="text-center mb-4">
                    <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 60px; height: 60px;">
                        <i class="fa-solid fa-pen-to-square fa-2x" style="color: var(--skin-primary);"></i>
                    </div>
                    <h4 class="fw-bold mb-1">Cập nhật thông tin</h4>
                    <p class="text-muted small">
                        <c:choose>
                            <c:when test="${target == 'EMAIL'}">Vui lòng nhập địa chỉ Email mới của bạn.</c:when>
                            <c:when test="${target == 'PASSWORD'}">Vui lòng nhập mật khẩu mới.</c:when>
                        </c:choose>
                    </p>
                </div>
                
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4 py-2" role="alert">
                        <i class="fa-solid fa-circle-xmark me-2"></i> ${errorMessage}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/account/profile" method="post">
                    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="submit_new_target">
                    
                    <c:choose>
                        <c:when test="${target == 'EMAIL'}">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-semibold small">Địa chỉ Email mới</label>
                                <input type="email" name="newValue" class="form-control" placeholder="name@example.com" required>
                            </div>
                        </c:when>
                        <c:when test="${target == 'PASSWORD'}">
                            <div class="mb-3">
                                <label class="form-label text-muted fw-semibold small">Mật khẩu mới</label>
                                <input type="password" name="newValue" class="form-control" placeholder="Nhập mật khẩu mới" required autocomplete="new-password" minlength="${passwordMinLength}" data-password-pattern="${passwordPattern}" data-password-message="${passwordMessage}" data-password-confirmation="confirmValue" data-password-mismatch-message="${passwordMismatchMessage}">
                                <div class="form-text small">${passwordRequirements}</div>
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-semibold small">Xác nhận Mật khẩu mới</label>
                                <input type="password" name="confirmValue" class="form-control" placeholder="Nhập lại mật khẩu mới" required autocomplete="new-password" minlength="${passwordMinLength}">
                            </div>
                        </c:when>
                    </c:choose>

                    <button type="submit" class="btn btn-skin w-100 fw-bold mb-3">Tiếp tục</button>
                    
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/account/profile" class="text-decoration-none text-muted small">Hủy và quay lại</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/password-policy.js"></script>
<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
