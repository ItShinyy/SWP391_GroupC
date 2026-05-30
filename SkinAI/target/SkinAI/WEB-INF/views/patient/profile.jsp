<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/public-header.jsp" />

<div class="container py-5 mt-5">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-4 mb-4">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-body text-center p-4">
                    <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 100px; height: 100px;">
                        <i class="fa-solid fa-user fa-3x" style="color: var(--skin-primary);"></i>
                    </div>
                    <h4 class="fw-bold mb-1">${user.fullName}</h4>
                    <p class="text-muted mb-3">@${user.username}</p>
                    <span class="badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill">
                        <i class="fa-solid fa-circle-check me-1"></i> Tài khoản hoạt động
                    </span>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-8">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-white border-0 pt-4 pb-0 px-4">
                    <h4 class="fw-bold mb-0" style="color: var(--skin-primary);">Cài đặt tài khoản</h4>
                </div>
                <div class="card-body p-4">
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

                    <!-- Form Update Info -->
                    <form action="${pageContext.request.contextPath}/patient/profile" method="post" class="mb-5">
                        <input type="hidden" name="action" value="update_info">
                        <h5 class="fw-bold mb-3 border-bottom pb-2">Thông tin cá nhân</h5>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Họ và tên</label>
                                <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Tên đăng nhập</label>
                                <input type="text" name="username" class="form-control" value="${user.username}" required>
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="form-label text-muted fw-semibold small">Email</label>
                                <div class="input-group">
                                    <input type="email" class="form-control bg-light" value="${user.email}" readonly>
                                    <button type="button" class="btn btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#changeEmailModal">
                                        Thay đổi Email
                                    </button>
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-skin fw-bold">Lưu thông tin</button>
                    </form>

                    <!-- Form Change Password -->
                    <form action="${pageContext.request.contextPath}/patient/profile" method="post">
                        <input type="hidden" name="action" value="request_change_password">
                        <h5 class="fw-bold mb-3 border-bottom pb-2">Đổi mật khẩu</h5>
                        
                        <div class="mb-3">
                            <label class="form-label text-muted fw-semibold small">Mật khẩu hiện tại</label>
                            <input type="password" name="oldPassword" class="form-control" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Mật khẩu mới</label>
                                <input type="password" name="newPassword" class="form-control" required>
                                <div class="form-text small">Tối thiểu 8 kí tự, bao gồm chữ và số.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" class="form-control" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-dark fw-bold">Lấy mã OTP để Đổi mật khẩu</button>
                    </form>

                    <!-- OTP Verification Section -->
                    <c:if test="${not empty sessionScope.pendingPassword || not empty sessionScope.pendingEmail}">
                        <div class="mt-5 p-4 border rounded bg-light border-warning">
                            <h5 class="fw-bold text-warning mb-3">Xác thực OTP</h5>
                            <p class="small text-muted">Mã OTP đã được gửi đến email của bạn. Vui lòng nhập mã để hoàn tất thao tác.</p>
                            <form action="${pageContext.request.contextPath}/patient/profile" method="post">
                                <input type="hidden" name="action" value="${not empty sessionScope.pendingPassword ? 'verify_password_otp' : 'verify_email_otp'}">
                                <div class="input-group mb-3">
                                    <input type="text" name="otp" class="form-control" placeholder="Nhập mã 6 số" required>
                                    <button class="btn btn-warning text-white fw-bold" type="submit">Xác nhận OTP</button>
                                </div>
                            </form>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Change Email -->
<div class="modal fade" id="changeEmailModal" tabindex="-1">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/patient/profile" method="post">
            <input type="hidden" name="action" value="request_change_email">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Thay đổi Email</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Email mới</label>
                        <input type="email" name="newEmail" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">Gửi mã OTP</button>
                </div>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/public-footer.jsp" />
