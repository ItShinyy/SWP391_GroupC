<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<style>
    .record-detail-page { background: #f8fafc; min-height: calc(100vh - 80px); }
    .record-detail-card { border: 1px solid #e2e8f0; border-radius: 16px; }
    .detail-label { color: #64748b; font-size: .9rem; font-weight: 600; margin-bottom: .3rem; }
    .detail-value { color: #0f172a; white-space: pre-line; }
    .section-title { border-bottom: 2px solid #e2e8f0; padding-bottom: .7rem; }
    .prescription-table thead th { background: #198754; color: #fff; }
</style>

<section class="record-detail-page py-4">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center gap-3 mb-3">
            <div>
                <h1 class="mb-1">Chi tiết hồ sơ bệnh án</h1>
                <div class="text-muted">Người khám: <strong>${examinedPersonLabel}</strong></div>
            </div>
            <a class="btn btn-outline-secondary"
               href="${pageContext.request.contextPath}/patient/medical-records?person=${selectedPerson}">
                <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
            </a>
        </div>

        <div class="record-detail-card bg-white shadow-sm p-4 mb-4">
            <div class="d-flex flex-wrap justify-content-between gap-2 section-title mb-4">
                <h4 class="mb-0">Thông tin lần khám</h4>
                <span class="badge bg-success px-3 py-2">Đã hoàn thành</span>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="detail-label">Mã hồ sơ</div>
                    <div class="detail-value font-monospace">#${report.shortId}</div>
                </div>
                <div class="col-md-4">
                    <div class="detail-label">Ngày khám</div>
                    <div class="detail-value">${report.appointmentTimeDisplay}</div>
                </div>
                <div class="col-md-4">
                    <div class="detail-label">Ngày tái khám</div>
                    <div class="detail-value">${report.followUpDateDisplay}</div>
                </div>
                <div class="col-md-6">
                    <div class="detail-label">Bác sĩ</div>
                    <div class="detail-value">${report.doctorName}</div>
                </div>
                <div class="col-md-6">
                    <div class="detail-label">Phòng khám</div>
                    <div class="detail-value">${report.clinicName}</div>
                </div>
            </div>
        </div>

        <div class="record-detail-card bg-white shadow-sm p-4 mb-4">
            <h4 class="section-title mb-4">Kết luận của bác sĩ</h4>
            <div class="row g-4">
                <div class="col-12">
                    <div class="detail-label">Triệu chứng/Lý do khám</div>
                    <div class="detail-value">${report.chiefComplaint}</div>
                </div>
                <div class="col-12">
                    <div class="detail-label">Chẩn đoán</div>
                    <div class="detail-value fw-semibold">${report.doctorDiagnosis}</div>
                </div>
                <div class="col-12">
                    <div class="detail-label">Hướng điều trị</div>
                    <div class="detail-value">${report.treatmentPlan}</div>
                </div>
            </div>
        </div>

        <div class="record-detail-card bg-white shadow-sm p-4">
            <h4 class="section-title mb-4"><i class="fa-solid fa-prescription-bottle-medical me-2 text-success"></i>Đơn thuốc</h4>
            <div class="table-responsive">
                <table class="table table-bordered align-middle prescription-table mb-0">
                    <thead>
                        <tr>
                            <th style="width: 28%">Tên thuốc</th>
                            <th style="width: 12%">Số lượng</th>
                            <th>Liều dùng</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty report.prescriptions}">
                                <tr><td colspan="3" class="text-center text-muted py-4">Không có thuốc trong lần khám này.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="prescription" items="${report.prescriptions}">
                                    <tr>
                                        <td class="fw-semibold">${prescription.drugName}</td>
                                        <td>${prescription.quantity}</td>
                                        <td>${prescription.dosage}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
