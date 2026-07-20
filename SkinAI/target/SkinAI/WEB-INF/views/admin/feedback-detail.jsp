<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="page-title">
            <i class="fas fa-comment-dots me-2 text-primary"></i>Chi Tiết Đánh Giá
        </h1>
        <a href="${pageContext.request.contextPath}/admin/feedback" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-2"></i>Quay lại danh sách
        </a>
    </div>

    <!-- Success/Error Messages -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="row">
        <!-- Feedback Details -->
        <div class="col-lg-8">
            <div class="card mb-4">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-star me-2"></i>Thông Tin Đánh Giá
                    </h5>
                </div>
                <div class="card-body">
                    <!-- Rating -->
                    <div class="row mb-3">
                        <div class="col-sm-3"><strong>Đánh giá:</strong></div>
                        <div class="col-sm-9">
                            <div class="d-flex align-items-center">
                                <c:forEach begin="1" end="5" var="i">
                                    <i class="fas fa-star ${i <= feedback.rating ? 'text-warning' : 'text-muted'} me-1"></i>
                                </c:forEach>
                                <span class="ms-3 fw-bold">${feedback.rating}/5 - ${feedback.ratingDescription}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Category -->
                    <div class="row mb-3">
                        <div class="col-sm-3"><strong>Loại đánh giá:</strong></div>
                        <div class="col-sm-9">
                            <span class="badge ${feedback.category == 'Khen' ? 'bg-success' : feedback.category == 'Góp ý' ? 'bg-info' : 'bg-warning'} px-3 py-2">
                                ${feedback.category}
                            </span>
                        </div>
                    </div>

                    <!-- Content -->
                    <div class="row mb-3">
                        <div class="col-sm-3"><strong>Nội dung:</strong></div>
                        <div class="col-sm-9">
                            <div class="bg-light p-3 rounded">
                                <p class="mb-0">"${feedback.content}"</p>
                            </div>
                        </div>
                    </div>

                    <!-- Created Date -->
                    <div class="row mb-3">
                        <div class="col-sm-3"><strong>Ngày tạo:</strong></div>
                        <div class="col-sm-9">
                            <c:set var="createdAtStr" value="${feedback.createdAt.toString()}" />
                            <c:set var="dateOnly" value="${createdAtStr.substring(0, 10)}" />
                            <c:set var="timeOnly" value="${createdAtStr.substring(11, 16)}" />
                            <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                            <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                            <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                            <i class="fas fa-calendar me-2 text-muted"></i>
                            ${day}/${month}/${year} lúc ${timeOnly}
                        </div>
                    </div>

                    <!-- Status -->
                    <div class="row">
                        <div class="col-sm-3"><strong>Trạng thái:</strong></div>
                        <div class="col-sm-9">
                            <span class="badge ${feedback.status == 'Chưa xử lý' ? 'bg-warning' : 'bg-success'} px-3 py-2">
                                ${feedback.status}
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Patient & Appointment Info -->
            <div class="card mb-4">
                <div class="card-header bg-info text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-info-circle me-2"></i>Thông Tin Liên Quan
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h6 class="text-primary">Bệnh nhân</h6>
                            <c:choose>
                                <c:when test="${patientUser != null}">
                                    <p class="mb-1"><strong>Tên:</strong> ${patientUser.fullName}</p>
                                    <p class="mb-1"><strong>Email:</strong> ${patientUser.email}</p>
                                    <p class="mb-0"><strong>ID:</strong> ${patientUser.id.substring(0, 8)}...</p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">Không tìm thấy thông tin bệnh nhân</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="col-md-6">
                            <h6 class="text-primary">Lịch hẹn</h6>
                            <c:choose>
                                <c:when test="${appointment != null}">
                                    <p class="mb-1"><strong>Mã:</strong> #${appointment.id.substring(0, 8)}...</p>
                                    <c:set var="appointmentTimeStr" value="${appointment.appointmentTime.toString()}" />
                                    <c:set var="appDateOnly" value="${appointmentTimeStr.substring(0, 10)}" />
                                    <c:set var="appTimeOnly" value="${appointmentTimeStr.substring(11, 16)}" />
                                    <c:set var="appYear" value="${appDateOnly.substring(0, 4)}" />
                                    <c:set var="appMonth" value="${appDateOnly.substring(5, 7)}" />
                                    <c:set var="appDay" value="${appDateOnly.substring(8, 10)}" />
                                    <p class="mb-1"><strong>Thời gian:</strong> ${appDay}/${appMonth}/${appYear} ${appTimeOnly}</p>
                                    <p class="mb-0"><strong>Trạng thái:</strong> 
                                        <span class="badge bg-success">
                                            ${appointment.status}
                                        </span>
                                    </p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">Không tìm thấy thông tin lịch hẹn</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Admin Reply Section -->
            <c:if test="${feedback.hasAdminReply()}">
                <div class="card mb-4">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-reply me-2"></i>Phản Hồi Hiện Tại
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="bg-light p-3 rounded">
                            <p class="mb-0">"${feedback.adminReply}"</p>
                        </div>
                        <c:if test="${feedback.repliedAt != null}">
                            <small class="text-muted">
                                <i class="fas fa-clock me-1"></i>
                                <c:set var="repliedAtStr" value="${feedback.repliedAt.toString()}" />
                                <c:set var="repDateOnly" value="${repliedAtStr.substring(0, 10)}" />
                                <c:set var="repTimeOnly" value="${repliedAtStr.substring(11, 16)}" />
                                <c:set var="repYear" value="${repDateOnly.substring(0, 4)}" />
                                <c:set var="repMonth" value="${repDateOnly.substring(5, 7)}" />
                                <c:set var="repDay" value="${repDateOnly.substring(8, 10)}" />
                                Phản hồi vào ${repDay}/${repMonth}/${repYear} lúc ${repTimeOnly}
                            </small>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- Action Panel -->
        <div class="col-lg-4">
            <!-- Status Update -->
            <div class="card mb-4">
                <div class="card-header bg-warning text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-edit me-2"></i>Cập Nhật Trạng Thái
                    </h5>
                </div>
                <div class="card-body">
                    <form method="POST" action="${pageContext.request.contextPath}/admin/feedback">
                        <input type="hidden" name="action" value="updateStatus">
                        <input type="hidden" name="feedbackId" value="${feedback.id}">
                        
                        <div class="mb-3">
                            <label for="status" class="form-label">Trạng thái mới:</label>
                            <select class="form-select" id="status" name="status" required>
                                <option value="Chưa xử lý" ${feedback.status == 'Chưa xử lý' ? 'selected' : ''}>Chưa xử lý</option>
                                <option value="Đã xử lý" ${feedback.status == 'Đã xử lý' ? 'selected' : ''}>Đã xử lý</option>
                            </select>
                        </div>
                        
                        <button type="submit" class="btn btn-warning w-100">
                            <i class="fas fa-save me-2"></i>Cập nhật trạng thái
                        </button>
                    </form>
                </div>
            </div>

            <!-- Admin Reply -->
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-reply me-2"></i>Phản Hồi Admin
                    </h5>
                </div>
                <div class="card-body">
                    <form method="POST" action="${pageContext.request.contextPath}/admin/feedback">
                        <input type="hidden" name="action" value="reply">
                        <input type="hidden" name="feedbackId" value="${feedback.id}">
                        
                        <div class="mb-3">
                            <label for="adminReply" class="form-label">Nội dung phản hồi:</label>
                            <textarea class="form-control" id="adminReply" name="adminReply" rows="6" required
                                      placeholder="Nhập nội dung phản hồi cho bệnh nhân...">${feedback.adminReply}</textarea>
                            <div class="form-text">Phản hồi này sẽ được gửi đến bệnh nhân</div>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-paper-plane me-2"></i>
                            ${feedback.hasAdminReply() ? 'Cập nhật phản hồi' : 'Gửi phản hồi'}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.page-title {
    color: #0d6efd;
    font-weight: 700;
}

.card {
    border: none;
    box-shadow: 0 0 20px rgba(0,0,0,0.1);
    border-radius: 10px;
}

.card-header {
    border-radius: 10px 10px 0 0 !important;
    border: none;
}

.badge {
    font-size: 0.8rem;
}

.bg-light {
    background-color: #f8f9fa !important;
}

@media (max-width: 768px) {
    .row .col-sm-3 {
        font-weight: bold;
        margin-bottom: 0.5rem;
    }
    
    .row .col-sm-9 {
        margin-bottom: 1rem;
    }
}
</style>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />