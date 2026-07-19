<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />
    </c:when>
    <c:when test="${user.role == 'DOCTOR'}">
        <jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/global-header.jsp" />
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
                    <c:if test="${user.role == 'DOCTOR'}">
                        <div class="mt-4 pt-3 border-top w-100">
                            <button type="button" class="btn btn-outline-danger w-100 fw-bold rounded-pill shadow-sm transition hover-scale" data-bs-toggle="modal" data-bs-target="#bugReportModal">
                                <i class="fa-solid fa-bug me-2"></i>Báo lỗi hệ thống
                            </button>
                        </div>
                    </c:if>
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
                    <form action="${pageContext.request.contextPath}/account/profile" method="post" class="mb-5">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
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
                    <form action="${pageContext.request.contextPath}/account/profile" method="post" class="mb-5">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
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
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold small">Mật khẩu Mới <span class="text-muted fw-normal">(Tùy chọn)</span></label>
                                        <input type="password" name="newPassword" class="form-control" placeholder="Nhập mật khẩu mới">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold small">Xác nhận Mật khẩu Mới</label>
                                        <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu mới">
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info d-flex align-items-center rounded-3 mb-3 py-2" role="alert">
                                    <i class="fa-brands fa-google me-2"></i> Bạn đang sử dụng tài khoản Google. Mã OTP sẽ được dùng để xác thực các thay đổi mà không cần mật khẩu.
                                </div>
                            </c:otherwise>
                        </c:choose>

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
    <c:when test="${user.role == 'DOCTOR'}">
        <jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
    </c:otherwise>
</c:choose>

<!-- Bug Report Modal -->
<div class="modal fade" id="bugReportModal" tabindex="-1" aria-labelledby="bugReportModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg rounded-4">
            <div class="modal-header bg-danger text-white rounded-top-4 p-4 border-0">
                <h5 class="modal-title fw-bold" id="bugReportModalLabel"><i class="fa-solid fa-bug me-2"></i>Báo Cáo Lỗi Hệ Thống</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/account/profile" method="post" id="bugReportForm" class="needs-validation" novalidate>
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="report_bug">
                <input type="hidden" name="urlPath" id="bugUrlPath" value="">
                
                <div class="modal-body p-4">
                    <p class="text-muted small">Nếu bạn phát hiện lỗi hoặc sự cố kỹ thuật trong quá trình sử dụng hệ thống, vui lòng phản hồi tại đây. Admin sẽ kiểm tra và khắc phục sớm nhất.</p>
                    
                    <div class="mb-3">
                        <label for="bugTitle" class="form-label fw-bold small text-dark">Tiêu đề lỗi <span class="text-danger">*</span></label>
                        <input type="text" class="form-control rounded-3" name="title" id="bugTitle" placeholder="Ví dụ: Lỗi trắng màn hình khi xem chi tiết" required>
                        <div class="invalid-feedback">Vui lòng nhập tiêu đề lỗi.</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="bugDescription" class="form-label fw-bold small text-dark">Mô tả chi tiết lỗi <span class="text-danger">*</span></label>
                        <textarea class="form-control rounded-3" name="description" id="bugDescription" rows="4" placeholder="Vui lòng mô tả các bước dẫn đến lỗi hoặc thông tin chi tiết sự cố..." required></textarea>
                        <div class="invalid-feedback">Vui lòng nhập mô tả chi tiết lỗi.</div>
                    </div>
                </div>
                
                <div class="modal-footer p-3 bg-light rounded-bottom-4 border-0">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4 fw-bold">Gửi Báo Cáo</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const urlInput = document.getElementById("bugUrlPath");
        if (urlInput) {
            urlInput.value = window.location.href;
        }
        
        // Modal Form Validation
        const bugForm = document.getElementById('bugReportForm');
        if (bugForm) {
            bugForm.addEventListener('submit', function (event) {
                if (!bugForm.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                bugForm.classList.add('was-validated');
            }, false);
        }
    });
</script>

<style>
    .transition {
        transition: all 0.3s ease;
    }
    .hover-scale:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(220, 53, 69, 0.2) !important;
    }
</style>