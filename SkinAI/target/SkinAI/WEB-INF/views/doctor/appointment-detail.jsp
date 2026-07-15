<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<style>
    .detail-card {
        border-radius: 16px;
        border: none;
        overflow: hidden;
    }
    .detail-card-header {
        padding: 1.2rem 1.5rem;
        font-weight: 700;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    .detail-card-body {
        padding: 1.5rem;
    }
    .info-row {
        display: flex;
        justify-content: space-between;
        padding: 0.7rem 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .info-row:last-child { border-bottom: none; }
    .info-label {
        font-size: 0.85rem;
        font-weight: 600;
        color: #64748b;
    }
    .info-value {
        font-size: 0.9rem;
        font-weight: 600;
        color: #0f172a;
        text-align: right;
    }
    .diagnosis-image-container {
        border-radius: 12px;
        overflow: hidden;
        background: #f1f5f9;
        aspect-ratio: 1;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .diagnosis-image-container img {
        max-width: 100%;
        max-height: 100%;
        object-fit: cover;
    }
    .score-circle {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        font-weight: 800;
        font-size: 1.5rem;
        margin: 0 auto;
    }
    .action-card {
        border-radius: 16px;
        border: 2px solid #e2e8f0;
        background: white;
    }
    .btn-accept {
        background: linear-gradient(135deg, #22c55e, #16a34a);
        color: white;
        border: none;
        padding: 0.7rem 2rem;
        border-radius: 10px;
        font-weight: 700;
        font-size: 0.95rem;
        transition: all 0.2s;
    }
    .btn-accept:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(34, 197, 94, 0.4);
        color: white;
    }
    .btn-reject {
        background: linear-gradient(135deg, #ef4444, #dc2626);
        color: white;
        border: none;
        padding: 0.7rem 2rem;
        border-radius: 10px;
        font-weight: 700;
        font-size: 0.95rem;
        transition: all 0.2s;
    }
    .btn-reject:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
        color: white;
    }
    .status-banner {
        border-radius: 12px;
        padding: 1.2rem 1.5rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .status-banner-accepted {
        background: linear-gradient(135deg, #f0fdf4, #dcfce7);
        color: #166534;
        border: 1px solid #bbf7d0;
    }
    .status-banner-rejected {
        background: linear-gradient(135deg, #fef2f2, #fecaca);
        color: #991b1b;
        border: 1px solid #fecaca;
    }

    .risk-badge {
        padding: 0.25rem 0.6rem;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 700;
    }
    .risk-high { background: #fecaca; color: #991b1b; }
    .risk-medium { background: #fef3c7; color: #92400e; }
    .risk-low { background: #dcfce7; color: #166534; }
</style>

<div class="container-fluid py-4 px-4">

    <!-- Back Button -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/doctor/dashboard" class="text-decoration-none text-muted fw-semibold" style="font-size: 0.9rem;">
            <i class="fa-solid fa-arrow-left me-2"></i>Quay lại danh sách
        </a>
    </div>

    <!-- Success/Error Alerts -->
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i>Cập nhật trạng thái hồ sơ thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i>Có lỗi xảy ra khi cập nhật. Vui lòng thử lại.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Page Title -->
    <h4 class="fw-bold mb-4">
        <i class="fa-solid fa-file-medical me-2 text-primary"></i>Chi Tiết Hồ Sơ Bệnh Nhân
    </h4>

    <div class="row g-4">
        <!-- Left Column: Patient Info -->
        <div class="col-lg-5">
            <div class="detail-card shadow-sm">
                <div class="detail-card-header bg-primary text-white">
                    <i class="fa-solid fa-user"></i> Thông Tin Bệnh Nhân
                </div>
                <div class="detail-card-body">
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-user me-2"></i>Họ và tên</span>
                        <span class="info-value">${appointment.patientName != null ? appointment.patientName : 'N/A'}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-envelope me-2"></i>Email</span>
                        <span class="info-value">${appointment.patientEmail != null ? appointment.patientEmail : 'N/A'}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-phone me-2"></i>Số điện thoại</span>
                        <span class="info-value">${appointment.patientPhone != null ? appointment.patientPhone : 'N/A'}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-venus-mars me-2"></i>Giới tính</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${appointment.patientGender == 'MALE'}">Nam</c:when>
                                <c:when test="${appointment.patientGender == 'FEMALE'}">Nữ</c:when>
                                <c:when test="${appointment.patientGender == 'OTHER'}">Khác</c:when>
                                <c:otherwise>N/A</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-cake-candles me-2"></i>Ngày sinh</span>
                        <span class="info-value">${appointment.patientDob != null ? appointment.patientDob : 'N/A'}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-location-dot me-2"></i>Địa chỉ</span>
                        <span class="info-value">${appointment.patientAddress != null ? appointment.patientAddress : 'N/A'}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-calendar me-2"></i>Ngày đặt lịch</span>
                        <span class="info-value">${appointment.createdAtFormatted}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label text-primary"><i class="fa-solid fa-calendar-check me-2"></i>Ngày hẹn khám</span>
                        <span class="info-value text-primary fw-bold">${appointment.appointmentTimeFormatted}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="fa-solid fa-note-sticky me-2"></i>Ghi chú BN</span>
                        <span class="info-value">${appointment.notes != null ? appointment.notes : 'Không có'}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: AI Diagnosis -->
        <div class="col-lg-7">
            <div class="detail-card shadow-sm">
                <div class="detail-card-header" style="background: linear-gradient(135deg, #1e3a8a, #3b82f6); color: white;">
                    <i class="fa-solid fa-brain"></i> Kết Quả Chẩn Đoán AI
                </div>
                <div class="detail-card-body">
                    <div class="row g-4">
                        <!-- Image -->
                        <div class="col-md-6">
                            <p class="fw-bold text-muted mb-2" style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px;">Ảnh Phân Tích</p>
                            <div class="diagnosis-image-container">
                                <c:choose>
                                    <c:when test="${appointment.imageUrl != null}">
                                        <img src="${pageContext.request.contextPath}/${appointment.imageUrl}" alt="Diagnosis Image">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center text-muted">
                                            <i class="fa-solid fa-image" style="font-size: 3rem;"></i>
                                            <p class="mt-2 mb-0">Không có ảnh</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <p class="fw-bold text-muted mb-2" style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px;">Heatmap</p>
                            <div class="diagnosis-image-container">
                                <c:choose>
                                    <c:when test="${appointment.heatmapUrl != null}">
                                        <img src="${pageContext.request.contextPath}/${appointment.heatmapUrl}" alt="Heatmap">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center text-muted">
                                            <i class="fa-solid fa-fire" style="font-size: 3rem;"></i>
                                            <p class="mt-2 mb-0">Không có heatmap</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Diagnosis Info -->
                        <div class="col-12">
                            <div class="row g-3 mt-1">
                                <div class="col-md-4 text-center">
                                    <div class="score-circle" style="background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #1e40af;">
                                        <span><fmt:formatNumber value="${appointment.confidenceScore}" pattern="#0.0"/>%</span>
                                        <small style="font-size: 0.55rem; font-weight: 600;">ĐỘ CHÍNH XÁC</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <p class="fw-bold text-muted mb-1" style="font-size: 0.75rem;">BỆNH PHÁT HIỆN</p>
                                    <p class="fw-bold mb-0" style="font-size: 1.05rem;">${appointment.diseaseName != null ? appointment.diseaseName : 'Chưa xác định'}</p>
                                </div>
                                <div class="col-md-4">
                                    <p class="fw-bold text-muted mb-1" style="font-size: 0.75rem;">MỨC RỦI RO</p>
                                    <c:choose>
                                        <c:when test="${appointment.riskLevel == 'HIGH'}"><span class="risk-badge risk-high" style="font-size: 0.9rem;"><i class="fa-solid fa-triangle-exclamation me-1"></i>Cao</span></c:when>
                                        <c:when test="${appointment.riskLevel == 'MEDIUM'}"><span class="risk-badge risk-medium" style="font-size: 0.9rem;"><i class="fa-solid fa-exclamation me-1"></i>Trung bình</span></c:when>
                                        <c:when test="${appointment.riskLevel == 'LOW'}"><span class="risk-badge risk-low" style="font-size: 0.9rem;"><i class="fa-solid fa-shield-halved me-1"></i>Thấp</span></c:when>
                                        <c:otherwise><span class="text-muted">N/A</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- AI Recommendation -->
                        <div class="col-12">
                            <p class="fw-bold text-muted mb-2" style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px;">Khuyến Nghị AI</p>
                            <div class="p-3 rounded-3" style="background: #f8fafc; border-left: 4px solid #3b82f6; font-size: 0.9rem; line-height: 1.7;">
                                ${appointment.recommendation != null ? appointment.recommendation : 'Không có khuyến nghị.'}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Action Section -->
    <div class="mt-4">
        <c:choose>
            <c:when test="${appointment.doctorStatus == 'PENDING'}">
                <!-- Show action form -->
                <div class="action-card p-4">
                    <h5 class="fw-bold mb-3">
                        <i class="fa-solid fa-pen-to-square me-2 text-primary"></i>Xử Lý Hồ Sơ
                    </h5>
                    <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail">
                        <input type="hidden" name="appointmentId" value="${appointment.id}">
                        <div class="mb-4">
                            <label for="doctorNotes" class="form-label fw-semibold">Nhận xét của bác sĩ</label>
                            <textarea class="form-control" id="doctorNotes" name="doctorNotes" rows="4" 
                                placeholder="Nhập nhận xét, chẩn đoán sơ bộ hoặc hướng dẫn cho bệnh nhân..." 
                                style="border-radius: 10px; border: 2px solid #e2e8f0; resize: none;"></textarea>
                        </div>
                        <div class="d-flex gap-3">
                            <button type="submit" name="action" value="accept" class="btn-accept">
                                <i class="fa-solid fa-check me-2"></i>Xác Nhận Lịch Hẹn
                            </button>
                            <button type="submit" name="action" value="reject" class="btn-reject">
                                <i class="fa-solid fa-times me-2"></i>Từ Chối
                            </button>
                        </div>
                    </form>
                </div>
            </c:when>
            <c:when test="${appointment.doctorStatus == 'ACCEPTED'}">
                <div class="status-banner status-banner-accepted">
                    <i class="fa-solid fa-circle-check" style="font-size: 1.5rem;"></i>
                    <div>
                        <div class="fw-bold">Hồ sơ đã được chấp nhận</div>
                        <c:if test="${appointment.doctorNotes != null}">
                            <div class="mt-1" style="font-weight: 500; opacity: 0.85;">Nhận xét: ${appointment.doctorNotes}</div>
                        </c:if>
                    </div>
                </div>
            </c:when>
            <c:when test="${appointment.doctorStatus == 'REJECTED'}">
                <div class="status-banner status-banner-rejected">
                    <i class="fa-solid fa-circle-xmark" style="font-size: 1.5rem;"></i>
                    <div>
                        <div class="fw-bold">Hồ sơ đã bị từ chối</div>
                        <c:if test="${appointment.doctorNotes != null}">
                            <div class="mt-1" style="font-weight: 500; opacity: 0.85;">Lý do: ${appointment.doctorNotes}</div>
                        </c:if>
                    </div>
                </div>
            </c:when>
        </c:choose>
    </div>

</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
