<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid pt-3 pb-5">
    
    <!-- HEADER -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/admin/bookings" class="text-decoration-none text-muted mb-2 d-inline-block fw-semibold small">
            <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
        </a>
        <h3 class="page-title mb-1 fw-bold">Chi Tiết Lịch Hẹn</h3>
        <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
            <span>Mã lịch hẹn (Booking ID): <span class="font-monospace">${appointment.id}</span></span>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger shadow-sm rounded-3">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
        </div>
    </c:if>

    <c:if test="${not empty appointment}">
        
        <!-- CARD 1: BOOKING INFORMATION -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-calendar-check text-warning me-2"></i> Thông tin lịch hẹn</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Trạng thái</div>
                        <c:choose>
                            <c:when test="${appointment.status == 'CREATED'}"><span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary px-2 py-1 fs-6">Khởi tạo</span></c:when>
                            <c:when test="${appointment.status == 'CONFIRMED'}"><span class="badge bg-info bg-opacity-10 text-info border border-info px-2 py-1 fs-6">Xác nhận</span></c:when>
                            <c:when test="${appointment.status == 'COMPLETED'}"><span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1 fs-6">Hoàn thành</span></c:when>
                            <c:when test="${appointment.status == 'CANCELLED'}"><span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1 fs-6">Đã hủy</span></c:when>
                            <c:when test="${appointment.status == 'NO_SHOW'}"><span class="badge bg-warning bg-opacity-10 text-warning border border-warning px-2 py-1 fs-6">Không đến</span></c:when>
                            <c:otherwise><span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary px-2 py-1 fs-6">${appointment.status}</span></c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Ngày tạo</div>
                        <div class="fw-bold text-dark">
                            <fmt:parseDate value="${appointment.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedCreatedAt" type="both" />
                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedCreatedAt}" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Thời gian khám</div>
                        <div class="fw-bold text-primary">
                            <fmt:parseDate value="${appointment.appointmentTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedTime" type="both" />
                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedTime}" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Mã báo cáo chẩn đoán</div>
                        <div class="d-flex align-items-center gap-2">
                            <c:choose>
                                <c:when test="${empty appointment.diagnosisReportId}">
                                    <span class="text-muted small">N/A</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/admin/ai-results/detail/${appointment.diagnosisReportId}" class="font-monospace small text-primary bg-primary bg-opacity-10 px-2 py-1 rounded border border-primary text-decoration-none">ID: ${appointment.diagnosisReportId} <i class="fa-solid fa-external-link-alt ms-1"></i></a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 2: ACTOR & TARGET -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-user-shield text-primary me-2"></i> Đối tượng & Mục tiêu</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Người thực hiện (Bệnh nhân)</div>
                        <div class="fw-bold text-primary text-break">
                            ${not empty appointment.patientName ? appointment.patientName : appointment.patientId}
                            <c:if test="${not empty appointment.patientEmail}">
                                <div class="text-muted fw-normal small">${appointment.patientEmail}</div>
                            </c:if>
                            <c:if test="${not empty appointment.patientPhone}">
                                <div class="text-muted fw-normal small"><i class="fa-solid fa-phone ms-1 me-1"></i>${appointment.patientPhone}</div>
                            </c:if>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Phòng khám</div>
                        <span class="badge bg-info bg-opacity-10 text-info border px-2 py-1 fs-6">
                            <i class="fa-solid fa-hospital me-1"></i> ${appointment.clinicName}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 3: NOTES -->
        <div class="card shadow-sm border-0 rounded-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-note-sticky text-success me-2"></i> Ghi chú</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-3">
                    <c:choose>
                        <c:when test="${not empty appointment.notes}">
                            <div class="col-12 d-flex flex-column">
                                <pre class="p-3 border border-secondary border-opacity-25 rounded small flex-grow-1 mb-0" style="background-color: #f8f9fa; color: #212529; white-space: pre-wrap; word-break: break-all; min-height: 100px; max-height: 500px; overflow-y: auto;"><c:out value="${appointment.notes}" /></pre>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12 text-center py-4 mt-3 text-muted bg-light rounded">
                                <i class="fa-solid fa-box-open fa-2x mb-2 text-secondary opacity-50"></i>
                                <p class="mb-0 small">Không có ghi chú nào cho lịch hẹn này.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
