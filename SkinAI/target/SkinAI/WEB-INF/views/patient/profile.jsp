<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/public-header.jsp" />
    </c:otherwise>
</c:choose>

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
                        <i class="fa-solid fa-circle-check me-1"></i> Active Account
                    </span>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-8">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-white border-0 pt-4 pb-0 px-4">
                    <h4 class="fw-bold mb-0" style="color: var(--skin-primary);">Cài đặt Tài khoản</h4>
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
                        <h5 class="fw-bold mb-3 border-bottom pb-2">Thông tin Cá nhân</h5>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Họ và Tên</label>
                                <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Tên đăng nhập</label>
                                <input type="text" name="username" class="form-control" value="${user.username}" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-skin fw-bold">Lưu Thay Đổi</button>
                    </form>

                    <!-- Form Security Settings -->
                    <form action="${pageContext.request.contextPath}/patient/profile" method="post" class="mb-5">
                        <input type="hidden" name="action" value="request_change_security">
                        <h5 class="fw-bold mb-3 border-bottom pb-2">Cài đặt Bảo mật</h5>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Email Hiện tại</label>
                                <input type="email" class="form-control bg-light" value="${user.email}" readonly>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label text-muted fw-semibold small">Số điện thoại Hiện tại</label>
                                <input type="text" class="form-control bg-light" value="${user.phone}" readonly>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold small">Email Mới <span class="text-muted fw-normal">(Tùy chọn)</span></label>
                                <input type="email" name="newEmail" class="form-control" placeholder="Nhập email mới">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold small">Số điện thoại Mới <span class="text-muted fw-normal">(Tùy chọn)</span></label>
                                <input type="text" name="newPhone" class="form-control" placeholder="Nhập số điện thoại mới">
                            </div>
                        </div>

                        <hr class="my-4">

                        <c:choose>
                            <c:when test="${not empty user.passwordHash}">
                                <div class="mb-3">
                                    <label class="form-label fw-bold small text-danger">Mật khẩu Cũ (Bắt buộc khi thay đổi)</label>
                                    <input type="password" name="oldPassword" class="form-control" required placeholder="Nhập mật khẩu hiện tại">
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info d-flex align-items-center rounded-3 mb-3 py-2" role="alert">
                                    <i class="fa-brands fa-google me-2"></i> Bạn đã đăng nhập bằng Google. Không cần mật khẩu cũ — mã OTP sẽ xác thực danh tính của bạn.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold small">Mật khẩu Mới <span class="text-muted fw-normal">(Tùy chọn${empty user.passwordHash ? ' — thiết lập để đăng nhập trực tiếp' : ''})</span></label>
                                <input type="password" name="newPassword" class="form-control" placeholder="Nhập mật khẩu mới">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold small">Xác nhận Mật khẩu Mới <span class="text-muted fw-normal">(Tùy chọn)</span></label>
                                <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu mới">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold small">Gửi mã OTP xác thực qua:</label>
                            <div class="d-flex gap-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="otpMethod" id="otpEmail" value="email" checked>
                                    <label class="form-check-label" for="otpEmail">
                                        Email
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="otpMethod" id="otpPhone" value="phone" ${empty user.phone ? 'disabled' : ''}>
                                    <label class="form-check-label" for="otpPhone">
                                        Số điện thoại ${empty user.phone ? '<span class="text-danger small">(Cập nhật hồ sơ để sử dụng)</span>' : ''}
                                    </label>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-dark fw-bold">Yêu cầu OTP & Cập nhật</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/public-footer.jsp" />
    </c:otherwise>
</c:choose>
