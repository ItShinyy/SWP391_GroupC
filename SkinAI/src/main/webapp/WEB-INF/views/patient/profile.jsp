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
                        <a class="btn btn-danger btn-sm d-table mx-auto mt-3" href="${pageContext.request.contextPath}/patient/issue-report">
                            <i class="fa-solid fa-bug me-1"></i> Báo lỗi / Hỗ trợ
                        </a>
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

                    <!-- Family Members -->
                    <section class="mb-5">
                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-3">
                            <h5 class="fw-bold mb-0">Thành viên gia đình</h5>
                            <c:if test="${not empty familyMembers}">
                                <a class="btn btn-outline-primary btn-sm" href="${pageContext.request.contextPath}/patient/family-members?action=create">
                                    <i class="fa-solid fa-user-plus me-1"></i> Thêm thành viên
                                </a>
                            </c:if>
                        </div>

                        <c:choose>
                            <c:when test="${empty familyMembers}">
                                <div class="text-center border rounded-3 bg-light p-4">
                                    <i class="fa-solid fa-people-roof text-primary fs-3 mb-2"></i>
                                    <p class="mb-3 text-muted">Bạn chưa thêm thành viên gia đình nào.</p>
                                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/patient/family-members?action=create">
                                        <i class="fa-solid fa-user-plus me-2"></i>Thêm thành viên gia đình
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive border rounded-3">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Người thân</th>
                                                <th class="text-end">Thông tin cá nhân</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="member" items="${familyMembers}">
                                                <tr>
                                                    <td>
                                                        <i class="fa-solid fa-people-roof text-primary me-2"></i>
                                                        <span class="fw-semibold"><c:out value="${member.relationshipLabel}" /> - <c:out value="${member.fullName}" /></span>
                                                    </td>
                                                    <td class="text-end">
                                                        <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/patient/family-members?action=view&amp;id=${member.id}">
                                                            Xem <i class="fa-solid fa-chevron-right ms-1"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>

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
                                <label class="form-label fw-bold small">Mật khẩu Mới <span class="text-muted fw-normal"></span></label>
                                <input type="password" name="newPassword" class="form-control" placeholder="Nhập mật khẩu mới">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold small">Xác nhận Mật khẩu Mới <span class="text-muted fw-normal"></span></label>
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
        <jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
    </c:otherwise>
</c:choose>
