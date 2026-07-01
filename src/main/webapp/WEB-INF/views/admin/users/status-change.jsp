<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid pt-4 px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold mb-0 text-dark">
            <c:choose>
                <c:when test="${action == 'lock'}">Khóa Tài Khoản</c:when>
                <c:otherwise>Mở Khóa Tài Khoản</c:otherwise>
            </c:choose>
        </h4>
        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">
            <i class="fa-solid fa-arrow-left me-2"></i> Quay Lại Danh Sách
        </a>
    </div>

    <div class="row">
        <!-- Patient Information Card -->
        <div class="col-md-5">
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-header bg-white border-bottom-0 pt-4 px-4 pb-0">
                    <h6 class="fw-bold text-dark"><i class="fa-solid fa-user-injured me-2 text-primary"></i> Thông Tin Bệnh Nhân</h6>
                </div>
                <div class="card-body p-4">
                    <table class="table table-borderless table-sm">
                        <tbody>
                            <tr>
                                <td class="text-muted" width="40%">Họ và Tên:</td>
                                <td class="fw-bold text-dark">${targetUser.fullName}</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Tên Đăng Nhập:</td>
                                <td>${targetUser.username}</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Email:</td>
                                <td>${targetUser.email}</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Trạng Thái:</td>
                                <td>
                                    <span class="badge ${targetUser.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">${targetUser.status}</span>
                                </td>
                            </tr>
                            <c:if test="${not empty patient}">
                                <tr>
                                    <td class="text-muted">SĐT:</td>
                                    <td>${patient.phone}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Giới tính:</td>
                                    <td>${patient.gender}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Ngày sinh:</td>
                                    <td>${patient.dob}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Địa chỉ:</td>
                                    <td>${patient.address}</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Form Card -->
        <div class="col-md-7">
            <div class="card shadow-sm border-0 rounded-3">
                <div class="card-header bg-white border-bottom-0 pt-4 px-4 pb-0">
                    <h6 class="fw-bold text-dark"><i class="fa-solid fa-pen-to-square me-2 text-warning"></i> Lý Do Xử Lý</h6>
                </div>
                <div class="card-body p-4">
                    <form action="${pageContext.request.contextPath}/admin/users/status" method="post">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="id" value="${targetUser.id}">
                        <input type="hidden" name="action" value="${action}">
                        
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Lý Do Phổ Biến</label>
                            <select class="form-select" id="commonReasons" onchange="updateReasonText()">
                                <option value="">-- Chọn một lý do phổ biến --</option>
                                <c:choose>
                                    <c:when test="${action == 'lock'}">
                                        <option value="Spam hoặc hành vi lạm dụng">Spam hoặc hành vi lạm dụng</option>
                                        <option value="Vi phạm điều khoản dịch vụ">Vi phạm điều khoản dịch vụ</option>
                                        <option value="Hoạt động đăng nhập đáng ngờ">Hoạt động đăng nhập đáng ngờ</option>
                                        <option value="Người dùng yêu cầu">Người dùng yêu cầu</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="Người dùng đã xác minh danh tính">Người dùng đã xác minh danh tính</option>
                                        <option value="Hết hạn khóa tạm thời">Hết hạn khóa tạm thời</option>
                                        <option value="Vấn đề đã được giải quyết">Vấn đề đã được giải quyết</option>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                        </div>

                        <div class="mb-4">
                            <label for="reason" class="form-label fw-semibold">Lý Do Chi Tiết <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="reason" name="reason" rows="4" required placeholder="Vui lòng cung cấp thông tin chi tiết..."></textarea>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn ${action == 'lock' ? 'btn-danger' : 'btn-success'} py-2 fw-bold">
                                <i class="fa-solid ${action == 'lock' ? 'fa-lock' : 'fa-unlock'} me-2"></i> Confirm ${action == 'lock' ? 'Lock' : 'Unlock'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function updateReasonText() {
        const select = document.getElementById("commonReasons");
        const textarea = document.getElementById("reason");
        if (select.value !== "") {
            textarea.value = select.value;
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />


