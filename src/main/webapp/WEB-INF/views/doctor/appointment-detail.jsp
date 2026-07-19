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
            <i class="fa-solid fa-circle-check me-2"></i>Cập nhật thông tin hồ sơ bệnh án thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i>Có lỗi xảy ra khi cập nhật. Vui lòng thử lại.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'overload'}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Lỗi chuyển ca:</strong> Bác sĩ nhận chuyển đã nhận đủ số lượng bệnh nhân tối đa (đạt giới hạn ca khám). Vui lòng chọn bác sĩ khác.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Clinical Progress Status Banners -->
    <c:if test="${appointment.status == 'COMPLETED'}">
        <div class="alert alert-success d-flex align-items-center rounded-3 border-0 shadow-sm mb-4" role="alert" style="background-color: #dcfce7; color: #166534;">
            <i class="fa-solid fa-circle-check fs-4 me-3 text-success"></i>
            <div>
                <strong>Ca khám đã hoàn thành!</strong> Hồ sơ bệnh án này đã hoàn thành khám chữa bệnh lâm sàng và được lưu trữ lịch sử y tế.
            </div>
        </div>
    </c:if>
    <c:if test="${appointment.status == 'CANCELLED'}">
        <div class="alert alert-danger d-flex align-items-center rounded-3 border-0 shadow-sm mb-4" role="alert" style="background-color: #fee2e2; color: #991b1b;">
            <i class="fa-solid fa-circle-xmark fs-4 me-3 text-danger"></i>
            <div>
                <strong>Ca khám đã bị hủy!</strong> Lịch hẹn này đã bị hủy bỏ và không thể tiến hành thực hiện các quy trình khám.
            </div>
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

            <!-- 3. Referral Card (Moved and minimized here) -->
            <c:if test="${appointment.status == 'CONFIRMED'}">
                <div class="card border-0 shadow-sm rounded-4 mt-4" id="referral-card">
                    <div class="card-header bg-white border-0 pt-3 px-3 pb-1">
                        <h6 class="fw-bold mb-0 text-muted" style="font-size: 0.85rem;">
                            <i class="fa-solid fa-share-from-square me-1 text-warning"></i> Chuyển giao Bác sĩ điều trị
                        </h6>
                    </div>
                    <div class="card-body p-3 pt-1">
                        <c:choose>
                            <c:when test="${not empty sameClinicDoctors}">
                                <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#referral-card">
                                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                                    <input type="hidden" name="action" value="transfer">
                                    <div class="mb-2">
                                        <select class="form-select form-select-sm rounded-3" name="newDoctorId" required style="font-size: 0.8rem; height: 34px;">
                                            <option value="" disabled selected>-- Chọn bác sĩ tiếp nhận --</option>
                                            <c:forEach var="doc" items="${sameClinicDoctors}">
                                                <option value="${doc.id}">${doc.fullName} (${doc.specialization})</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="mb-2">
                                        <input type="text" class="form-control form-control-sm rounded-3" name="transferNotes" placeholder="Lý do bàn giao..." required style="font-size: 0.8rem; height: 34px;">
                                    </div>
                                    <button type="submit" class="btn btn-warning btn-sm fw-bold w-100 rounded-pill text-dark" style="font-size: 0.8rem; height: 34px;">
                                        <i class="fa-solid fa-share me-1"></i>Chuyển ca khám
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-light border rounded-3 p-2 mb-0 text-muted small" style="font-size: 0.75rem;">
                                    <i class="fa-solid fa-circle-info me-1 text-primary"></i>Phòng khám không có bác sĩ khác để chuyển giao.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
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


                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Unified Doctor Workspace -->
    <div class="mt-4">
        <!-- 1. Prescription Card -->
        <div class="card border-0 shadow-sm rounded-4 mb-4" id="prescription-card">
            <div class="card-header bg-white border-0 pt-4 px-4 pb-2">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-prescription-bottle-medical me-2 text-success"></i>Đơn Thuốc Điều Trị
                </h5>
            </div>
            <div class="card-body px-4 pb-4">
                <c:choose>
                    <c:when test="${empty prescriptions}">
                        <div class="alert alert-light border rounded-3 p-3 mb-3 text-muted small">
                            <i class="fa-solid fa-circle-info me-2 text-success"></i>Hiện chưa có đơn thuốc nào được kê cho bệnh nhân.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive mb-4">
                            <table class="table align-middle table-bordered mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Tên Thuốc</th>
                                        <th style="width: 120px;">Số Lượng</th>
                                        <th>Liều Lượng & Hướng Dẫn Sử Dụng</th>
                                        <c:if test="${appointment.status == 'CONFIRMED'}">
                                            <th style="width: 80px;" class="text-center">Thao tác</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="presc" items="${prescriptions}">
                                        <tr>
                                            <td class="fw-bold text-dark">${presc.drugName}</td>
                                            <td><span class="badge bg-light text-dark border px-3 py-1 font-monospace">${presc.quantity}</span></td>
                                            <td>${presc.dosage}</td>
                                            <c:if test="${appointment.status == 'CONFIRMED'}">
                                                <td class="text-center">
                                                    <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#prescription-card" class="m-0 p-0" onsubmit="return confirm('Bạn chắc chắn muốn xóa thuốc này khỏi đơn?');">
                                                        <input type="hidden" name="appointmentId" value="${appointment.id}">
                                                        <input type="hidden" name="prescriptionId" value="${presc.id}">
                                                        <input type="hidden" name="action" value="deletePrescription">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger border-0 rounded-circle">
                                                            <i class="fa-regular fa-trash-can"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Form to Add Drug (Only if appointment is CONFIRMED) -->
                <c:if test="${appointment.status == 'CONFIRMED'}">
                    <div class="p-3 border rounded-3 bg-light">
                        <h6 class="fw-bold text-success mb-3"><i class="fa-solid fa-plus me-1"></i>Thêm thuốc vào đơn thuốc</h6>
                        <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#prescription-card" class="row g-2 align-items-end">
                            <input type="hidden" name="appointmentId" value="${appointment.id}">
                            <input type="hidden" name="action" value="addPrescription">
                            
                            <div class="col-md-4">
                                <label class="form-label small fw-bold text-muted mb-1">Tên thuốc <span class="text-danger">*</span></label>
                                <select class="form-select rounded-3" name="drugName" id="drugNameSelect" required onchange="fillPrescriptionPreset(this.value)" style="height: 38px; font-size: 0.85rem;">
                                    <option value="" disabled selected>-- Chọn tên thuốc --</option>
                                    <option value="Thuốc A">Thuốc A</option>
                                    <option value="Thuốc B">Thuốc B</option>
                                    <option value="Thuốc C">Thuốc C</option>
                                    <option value="custom">-- Nhập tên thuốc khác --</option>
                                </select>
                                <input type="text" class="form-control rounded-3 mt-2 d-none" name="customDrugName" id="customDrugNameInput" placeholder="Nhập tên thuốc tự do..." style="height: 38px; font-size: 0.85rem;">
                            </div>

                            <div class="col-md-2">
                                <label class="form-label small fw-bold text-muted mb-1">Số lượng <span class="text-danger">*</span></label>
                                <input type="number" class="form-control rounded-3" name="quantity" min="1" max="100" value="10" required style="height: 38px; font-size: 0.85rem;">
                            </div>

                            <div class="col-md-4">
                                <label class="form-label small fw-bold text-muted mb-1">Cách dùng & Liều lượng <span class="text-danger">*</span></label>
                                <input type="text" class="form-control rounded-3" name="dosage" id="dosageInput" placeholder="Ví dụ: Uống 2 lần/ngày, mỗi lần 1 viên" required style="height: 38px; font-size: 0.85rem;">
                            </div>

                            <div class="col-md-2">
                                <button type="submit" class="btn btn-success fw-bold w-100 rounded-3" style="height: 38px; font-size: 0.85rem;">
                                    <i class="fa-solid fa-plus me-1"></i>Thêm thuốc
                                </button>
                            </div>
                        </form>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- 2. Treatment Notes Card -->
        <div class="card border-0 shadow-sm rounded-4 mb-4" id="notes-card">
            <div class="card-header bg-white border-0 pt-4 px-4 pb-2">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-user-doctor me-2 text-primary"></i>Nhận xét & Chẩn đoán của Bác sĩ
                </h5>
            </div>
            <div class="card-body px-4 pb-4">
                <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#notes-card">
                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                    <input type="hidden" name="action" value="saveNotes">
                    <div class="mb-3">
                        <textarea class="form-control" name="doctorNotes" rows="4" 
                            placeholder="Nhập nhận xét y khoa, kết luận chẩn đoán hoặc hướng dẫn tự chăm sóc tại nhà cho bệnh nhân..." 
                            style="border-radius: 12px; border: 2px solid #e2e8f0; resize: none;"
                            ${appointment.status == 'COMPLETED' || appointment.status == 'CANCELLED' ? 'readonly' : ''}>${appointment.doctorNotes}</textarea>
                    </div>
                    <c:choose>
                        <c:when test="${appointment.status == 'CONFIRMED'}">
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary fw-bold px-4 rounded-3">
                                    <i class="fa-solid fa-floppy-disk me-2"></i>Lưu nhận xét
                                </button>
                                <button type="button" class="btn btn-success fw-bold px-4 rounded-3" onclick="submitComplete()">
                                    <i class="fa-solid fa-circle-check me-2"></i>Hoàn thành ca khám
                                </button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 w-100">
                                <span class="text-muted small fw-bold"><i class="fa-solid fa-lock me-1"></i>Hồ sơ bệnh án đã đóng, không thể chỉnh sửa nhận xét.</span>
                                <c:if test="${appointment.status == 'COMPLETED'}">
                                    <a href="${pageContext.request.contextPath}/doctor/appointments/detail?id=${appointment.id}&action=exportPdf" target="_blank" class="btn btn-danger fw-bold rounded-pill px-4 shadow-sm transition hover-scale">
                                        <i class="fa-solid fa-file-pdf me-2"></i>Tải Phiếu Khám & Đơn Thuốc (PDF)
                                    </a>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </form>

                <form id="completeForm" method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#notes-card" style="display: none;">
                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                    <input type="hidden" name="action" value="completeAppointment">
                </form>
            </div>
        </div>
    </div>

</div>

<script>
    function fillPrescriptionPreset(val) {
        const customInput = document.getElementById('customDrugNameInput');
        const dosageInput = document.getElementById('dosageInput');
        
        if (val === 'custom') {
            customInput.classList.remove('d-none');
            customInput.setAttribute('required', 'required');
            customInput.focus();
        } else {
            customInput.classList.add('d-none');
            customInput.removeAttribute('required');
        }

        const presets = {
            'Thuốc A': 'Uống 2 lần/ngày, mỗi lần 1 viên sau ăn sáng và tối. Dùng liên tục trong 7 ngày.',
            'Thuốc B': 'Thoa một lớp mỏng lên vùng da tổn thương 1 lần/ngày vào buổi tối trước khi đi ngủ.',
            'Thuốc C': 'Uống 1 lần/ngày vào buổi sáng sau ăn. Tránh ánh nắng mặt trời trực tiếp khi đang dùng thuốc.'
        };

        if (presets[val]) {
            dosageInput.value = presets[val];
        }
    }

    function submitComplete() {
        if (confirm("Bạn có chắc chắn muốn hoàn thành ca khám này không?\nSau khi hoàn thành, hồ sơ bệnh án sẽ được khóa lại và lưu trữ lịch sử.")) {
            document.getElementById('completeForm').submit();
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
