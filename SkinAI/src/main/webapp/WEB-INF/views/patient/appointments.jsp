<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">
                <i class="fa-regular fa-calendar-check me-2"></i>Lịch Hẹn
            </h1>
            <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary">
                <i class="fas fa-plus me-2"></i>Đặt Lịch Hẹn Mới
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

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-triangle-exclamation me-2"></i><strong>Error:</strong> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Appointments Statistics -->
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card bg-light border-0">
                    <div class="card-body py-2">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-info-circle fa-2x text-info me-3"></i>
                            <div>
                                <h6 class="mb-0">Tổng số lịch hẹn: <strong>${totalAppointments}</strong></h6>
                                <small class="text-muted">Quản lý các cuộc hẹn y tế của bạn bên dưới</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 10%">Mã ID</th>
                        <th scope="col" style="width: 20%">Phòng khám</th>
                        <th scope="col" style="width: 15%">Ngày & Giờ</th>
                        <th scope="col" style="width: 12%">Trạng thái</th>
                        <th scope="col" style="width: 15%">Mục đích</th>
                        <th scope="col" style="width: 18%">Ghi chú</th>
                        <th scope="col" style="width: 10%" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty appointments}">
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fa-regular fa-calendar fa-3x mb-3 text-light"></i>
                                    <h5>Không tìm thấy lịch hẹn</h5>
                                    <p>Bạn chưa đặt lịch hẹn nào.</p>
                                    <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary mt-2">
                                        <i class="fas fa-plus me-2"></i>Đặt Lịch Hẹn Đầu Tiên
                                    </a>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="apt" items="${appointments}">
                                <tr>
                                    <td>
                                        <span class="uuid-text text-secondary font-monospace" title="${apt.id}">
                                            #${apt.id.substring(0, 8)}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="fw-bold">${apt.clinicName}</div>
                                    </td>
                                    <td>
                                        <div class="fw-medium">
                                            <c:set var="appointmentDate" value="${apt.appointmentTime.toString()}" />
                                            <c:set var="dateOnly" value="${appointmentDate.substring(0, 10)}" />
                                            <c:set var="timeOnly" value="${appointmentDate.substring(11, 16)}" />
                                            
                                            <div>
                                                <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                ${day}/${month}/${year}
                                            </div>
                                            <small class="text-muted">
                                                <i class="far fa-clock me-1"></i>
                                                ${timeOnly}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${apt.status == 'CREATED'}">
                                                <span class="badge bg-secondary px-3 py-2">Chờ xử lý</span>
                                            </c:when>
                                            <c:when test="${apt.status == 'CONFIRMED'}">
                                                <span class="badge bg-success px-3 py-2">Đã xác nhận</span>
                                            </c:when>
                                            <c:when test="${apt.status == 'CHECKED_IN'}">
                                                <span class="badge bg-info px-3 py-2">Đã check-in</span>
                                            </c:when>
                                            <c:when test="${apt.status == 'COMPLETED'}">
                                                <span class="badge bg-primary px-3 py-2">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${apt.status == 'CANCELLED'}">
                                                <span class="badge bg-danger px-3 py-2">Đã hủy</span>
                                            </c:when>
                                            <c:when test="${apt.status == 'NO_SHOW'}">
                                                <span class="badge bg-warning text-dark px-3 py-2">Vắng mặt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark px-3 py-2">${apt.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty apt.diagnosisReportId}">
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-file-medical text-info me-2"></i>
                                                    <div>
                                                        <small class="fw-semibold">Tư vấn chẩn đoán</small>
                                                        <div class="text-muted small">Báo cáo: #${apt.diagnosisReportId.substring(0, 8)}...</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-stethoscope text-primary me-2"></i>
                                                    <small>Tư vấn chung</small>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty apt.notes}">
                                                <span class="text-truncate" style="max-width: 200px;" title="${apt.notes}">
                                                    ${apt.notes.length() > 50 ? apt.notes.substring(0, 50).concat('...') : apt.notes}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Không có ghi chú</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <div class="btn-group" role="group">
                                            <c:if test="${apt.status == 'CREATED' or apt.status == 'CONFIRMED'}">
                                                <button type="button" 
                                                        class="btn btn-sm btn-outline-danger" 
                                                        onclick="cancelAppointment('${apt.id}')" 
                                                        title="Cancel Appointment">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Cancel Appointment Modal -->
<div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fas fa-exclamation-triangle text-warning me-2"></i>Cancel Appointment
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to cancel this appointment?</p>
                <p class="text-muted small">This action cannot be undone. You will need to book a new appointment if needed.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Keep Appointment</button>
                <form id="cancelForm" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="appointmentId" id="cancelAppointmentId">
                    <button type="submit" class="btn btn-danger">Yes, Cancel</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function cancelAppointment(appointmentId) {
    document.getElementById('cancelAppointmentId').value = appointmentId;
    const modal = new bootstrap.Modal(document.getElementById('cancelModal'));
    modal.show();
}
</script>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />