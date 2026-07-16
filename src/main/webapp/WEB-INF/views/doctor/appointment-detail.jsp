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
        <!-- 1. Treatment Notes Card -->
        <div class="card border-0 shadow-sm rounded-4 mb-4">
            <div class="card-header bg-white border-0 pt-4 px-4 pb-2">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-user-doctor me-2 text-primary"></i>Nhận xét & Chẩn đoán của Bác sĩ
                </h5>
            </div>
            <div class="card-body px-4 pb-4">
                <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail">
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
                            <span class="text-muted small fw-bold"><i class="fa-solid fa-lock me-1"></i>Hồ sơ bệnh án đã đóng, không thể chỉnh sửa nhận xét.</span>
                        </c:otherwise>
                    </c:choose>
                </form>

                <form id="completeForm" method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail" style="display: none;">
                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                    <input type="hidden" name="action" value="completeAppointment">
                </form>
            </div>
        </div>

        <!-- 2. Lab Tests Card -->
        <div class="card border-0 shadow-sm rounded-4 mb-4">
            <div class="card-header bg-white border-0 pt-4 px-4 pb-2">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-flask-vial me-2 text-primary"></i>Chỉ định Xét nghiệm cận lâm sàng
                </h5>
            </div>
            <div class="card-body px-4 pb-4">
                <c:choose>
                    <c:when test="${empty labTests}">
                        <c:choose>
                            <c:when test="${appointment.status == 'CONFIRMED'}">
                                <p class="text-muted small mb-3">Hiện chưa có chỉ định xét nghiệm nào cho bệnh nhân này. Bác sĩ có thể chọn chỉ định bên dưới:</p>
                                <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail">
                                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                                    <input type="hidden" name="action" value="orderTest">
                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <div class="form-check p-3 border rounded-3 h-100 d-flex align-items-center">
                                                <input class="form-check-input ms-0 me-2" type="checkbox" name="testNames" value="Sinh thiết da" id="test1">
                                                <label class="form-check-label fw-semibold" for="test1">Sinh thiết da (Skin Biopsy)</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-check p-3 border rounded-3 h-100 d-flex align-items-center">
                                                <input class="form-check-input ms-0 me-2" type="checkbox" name="testNames" value="Soi tươi tìm nấm" id="test2">
                                                <label class="form-check-label fw-semibold" for="test2">Soi tươi tìm nấm/ký sinh trùng</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-check p-3 border rounded-3 h-100 d-flex align-items-center">
                                                <input class="form-check-input ms-0 me-2" type="checkbox" name="testNames" value="Xét nghiệm dị ứng IgE" id="test3">
                                                <label class="form-check-label fw-semibold" for="test3">Xét nghiệm dị ứng máu IgE</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-check p-3 border rounded-3 h-100 d-flex align-items-center">
                                                <input class="form-check-input ms-0 me-2" type="checkbox" name="testNames" value="Soi da Dermoscopy" id="test4">
                                                <label class="form-check-label fw-semibold" for="test4">Soi da Dermoscopy chuyên sâu</label>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-success fw-bold px-4 rounded-3">
                                        <i class="fa-solid fa-square-plus me-2"></i>Yêu cầu xét nghiệm
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-light border rounded-3 p-3 mb-0 text-muted small">
                                    <i class="fa-solid fa-circle-info me-2 text-primary"></i>Không có chỉ định xét nghiệm nào được thực hiện cho ca khám này.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table align-middle table-bordered mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width: 250px;">Tên Xét Nghiệm</th>
                                        <th style="width: 180px;">Trạng Thái</th>
                                        <th>Kết Quả / Chi Tiết</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="test" items="${labTests}">
                                        <tr>
                                            <td class="fw-bold text-dark">${test.testName}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${test.status == 'PENDING'}">
                                                        <span class="badge bg-warning text-dark rounded-pill px-3 py-1"><i class="fa-solid fa-clock-rotate-left me-1"></i>Chờ kết quả</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-success rounded-pill px-3 py-1"><i class="fa-solid fa-circle-check me-1"></i>Đã có kết quả</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${test.status == 'PENDING'}">
                                                        <!-- Form Trả kết quả giả lập nhanh -->
                                                        <div class="p-3 border rounded-3 bg-light">
                                                            <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail" class="row g-2 align-items-center">
                                                                <input type="hidden" name="appointmentId" value="${appointment.id}">
                                                                <input type="hidden" name="testId" value="${test.id}">
                                                                <input type="hidden" name="testName" value="${test.testName}">
                                                                <input type="hidden" name="action" value="submitMockResult">
                                                                
                                                                <div class="col-md-4">
                                                                    <label class="form-label small fw-bold text-muted mb-1">Chọn kết quả mẫu:</label>
                                                                    <select class="form-select form-select-sm" name="preset" required
                                                                        onchange="fillPreset('${test.id}', '${test.testName}', this.value)" style="border-radius: 8px;">
                                                                        <option value="">-- Chọn Preset mẫu --</option>
                                                                        <option value="positive">Có bất thường (Dương tính)</option>
                                                                        <option value="negative">Bình thường (Âm tính)</option>
                                                                        <option value="suspicious">Nghi ngờ / Cần theo dõi</option>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-8">
                                                                    <label class="form-label small fw-bold text-muted mb-1">Chi tiết kết luận:</label>
                                                                    <textarea class="form-control form-control-sm" id="summary_${test.id}" name="resultSummary" rows="2" 
                                                                        placeholder="Nhập kết quả xét nghiệm..." required style="border-radius: 8px; resize: none;"></textarea>
                                                                </div>
                                                                <div class="col-12 text-end mt-2">
                                                                    <button type="submit" class="btn btn-sm btn-primary fw-bold px-3 rounded-2">
                                                                        <i class="fa-solid fa-paper-plane me-1"></i>Trả kết quả
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                         <!-- Kết quả đã trả -->
                                                         <div class="p-2 text-center bg-light rounded-3">
                                                             <c:choose>
                                                                 <c:when test="${test.isPdf()}">
                                                                     <span class="d-inline-block small text-muted me-3 fw-bold">Phiếu kết quả:</span>
                                                                     <a href="${pageContext.request.contextPath}/${test.resultImageUrl}" target="_blank" class="btn btn-outline-danger btn-sm fw-bold rounded-3">
                                                                         <i class="fa-solid fa-file-pdf me-1"></i> Xem PDF kết quả
                                                                     </a>
                                                                 </c:when>
                                                                 <c:otherwise>
                                                                     <div class="row align-items-center g-3 text-start">
                                                                         <div class="col-8">
                                                                             <p class="fw-bold mb-1 text-primary small">Kết luận y khoa:</p>
                                                                             <p class="mb-0 text-dark small fw-semibold" style="line-height: 1.5;">${test.resultSummary}</p>
                                                                         </div>
                                                                         <c:if test="${test.resultImageUrl != null}">
                                                                             <div class="col-4 text-center">
                                                                                 <span class="d-block small text-muted mb-1 fw-bold">Ảnh tế bào</span>
                                                                                 <a href="${pageContext.request.contextPath}/${test.resultImageUrl}" target="_blank">
                                                                                     <img src="${pageContext.request.contextPath}/${test.resultImageUrl}" class="img-thumbnail rounded-3 shadow-sm" style="max-height: 80px; object-fit: cover;" alt="Lab result">
                                                                                 </a>
                                                                             </div>
                                                                         </c:if>
                                                                     </div>
                                                                 </c:otherwise>
                                                             </c:choose>
                                                         </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 3. Referral Card -->
        <c:if test="${appointment.status == 'CONFIRMED'}">
            <div class="card border-0 shadow-sm rounded-4 mb-4">
                <div class="card-header bg-white border-0 pt-4 px-4 pb-2">
                    <h5 class="fw-bold mb-0">
                        <i class="fa-solid fa-arrows-spin me-2 text-primary"></i>Chuyển giao Bác sĩ điều trị
                    </h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <c:choose>
                        <c:when test="${not empty sameClinicDoctors}">
                            <p class="text-muted small mb-3">Bác sĩ có thể chuyển hồ sơ bệnh án này cho một đồng nghiệp cùng phòng khám để tiếp tục điều trị hoặc hội chẩn:</p>
                            <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail">
                                <input type="hidden" name="appointmentId" value="${appointment.id}">
                                <input type="hidden" name="action" value="transfer">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="newDoctorId" class="form-label small fw-bold text-muted">Chọn bác sĩ tiếp nhận:</label>
                                        <select class="form-select" id="newDoctorId" name="newDoctorId" required style="border-radius: 8px;">
                                            <option value="">-- Chọn bác sĩ cùng phòng khám --</option>
                                            <c:forEach var="doc" items="${sameClinicDoctors}">
                                                <option value="${doc.id}">${doc.fullName} (${doc.specialization})</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="transferNotes" class="form-label small fw-bold text-muted">Lý do / Hướng điều trị bàn giao:</label>
                                        <input type="text" class="form-control" id="transferNotes" name="transferNotes" 
                                            placeholder="Nhập lý do chuyển hồ sơ hoặc lời dặn..." required style="border-radius: 8px;">
                                    </div>
                                    <div class="col-12 mt-3">
                                        <button type="submit" class="btn btn-warning fw-bold px-4 rounded-3 text-dark">
                                            <i class="fa-solid fa-share-from-square me-2"></i>Chuyển giao hồ sơ
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-light border rounded-3 p-3 mb-0">
                                <i class="fa-solid fa-circle-info me-2 text-primary"></i>Phòng khám hiện chưa có bác sĩ khác phù hợp để thực hiện chuyển giao.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
    </div>

</div>

<script>
    const presets = {
        "Sinh thiết da": {
            "positive": "Kết quả giải phẫu bệnh: Phát hiện sự tăng sinh bất thường của các tế bào hắc tố ác tính xâm nhập lớp hạ bì. Phù hợp với chẩn đoán Melanoma ác tính (Clark Level III). Vết cắt rìa tổn thương chưa hoàn toàn sạch tế bào u.",
            "negative": "Kết quả giải phẫu bệnh: Mô da có cấu trúc bình thường, lớp sừng và biểu bì bình thường. Không phát hiện tế bào dị dạng hay cấu trúc ác tính. Lành tính.",
            "suspicious": "Kết quả sinh thiết: Phát hiện các tế bào hắc tố không điển hình (atypical melanocytic hyperplasia), cần theo dõi sát sao hoặc sinh thiết mở rộng để loại trừ u hắc tố ác tính giai đoạn sớm."
        },
        "Soi tươi tìm nấm": {
            "positive": "Kết quả soi tươi: Tìm thấy nhiều bào tử nấm dạng sợi (Hyphae) và tế bào men nấm dương tính. Kết luận: Nhiễm nấm da.",
            "negative": "Kết quả soi tươi: Không tìm thấy sợi nấm, bào tử nấm hoặc ký sinh trùng trên mẫu cạo da. Âm tính.",
            "suspicious": "Kết quả soi tươi: Mẫu bệnh phẩm chứa quá ít tế bào sừng, nghi ngờ có bào tử nấm nhưng chưa đủ căn cứ kết luận. Đề nghị vệ sinh da sạch và làm lại xét nghiệm sau 3 ngày."
        },
        "Xét nghiệm dị ứng IgE": {
            "positive": "Chỉ số IgE toàn phần tăng cao đạt 385 IU/mL (bình thường < 100 IU/mL). Phản ứng dương tính mạnh với mạt bụi nhà và phấn hoa. Kết luận: Viêm da dị ứng dị nguyên môi trường.",
            "negative": "Chỉ số IgE toàn phần đạt 54 IU/mL (nằm trong giới hạn bình thường). Không phát hiện kháng thể IgE đặc hiệu đối với các dị nguyên nhóm thức ăn và đường hô hấp cơ bản.",
            "suspicious": "Chỉ số IgE toàn phần hơi tăng nhẹ đạt 115 IU/mL. Chưa phát hiện dị nguyên đặc hiệu cụ thể nào. Đề xuất kiểm tra thêm bảng dị nguyên mở rộng nếu triệu chứng ngứa tiếp diễn."
        },
        "Soi da Dermoscopy": {
            "positive": "Kết quả soi da: Phát hiện cấu trúc mạng lưới sắc tố không điển hình, có vùng mất cấu trúc và chấm sắc tố phân bố bất đối xứng. Cần chỉ định sinh thiết để xác định ác tính.",
            "negative": "Kết quả soi da: Mạng lưới sắc tố đồng đều, ranh giới tổn thương rõ ràng, không phát hiện dấu hiệu bất thường. Tổn thương lành tính.",
            "suspicious": "Kết quả soi da: Tổn thương có sắc tố không đồng nhất nhẹ, có vài điểm bất đối xứng nhẹ nhưng chưa đủ tiêu chuẩn ác tính. Hẹn tái khám theo dõi sau 1 tháng."
        }
    };

    function fillPreset(testId, testName, presetValue) {
        const textarea = document.getElementById('summary_' + testId);
        if (!textarea) return;
        
        if (presets[testName] && presets[testName][presetValue]) {
            textarea.value = presets[testName][presetValue];
        } else {
            textarea.value = '';
        }
    }

    function submitComplete() {
        if (confirm("Bạn có chắc chắn muốn hoàn thành ca khám này không?\nSau khi hoàn thành, hồ sơ bệnh án sẽ được khóa lại và lưu trữ lịch sử.")) {
            document.getElementById('completeForm').submit();
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
