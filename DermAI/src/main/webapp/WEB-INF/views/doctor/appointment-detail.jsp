<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />



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
    <c:if test="${param.screeningReviewed == '1'}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-stethoscope me-2"></i>Đã lưu duyệt sàng lọc AI.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'review_denied' || param.error == 'override_required' || param.error == 'review_stale'}">
        <div class="alert alert-warning alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <c:choose>
                <c:when test="${param.error == 'override_required'}">Ghi đè cần chẩn đoán cuối và lý do.</c:when>
                <c:when test="${param.error == 'review_stale'}">Kết quả sàng lọc đã được duyệt hoặc không thể cập nhật.</c:when>
                <c:otherwise>Hãy nhận khám trước khi duyệt sàng lọc AI, hoặc bạn thiếu quyền duyệt.</c:otherwise>
            </c:choose>
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
            <div class="card rounded-4 border-0 shadow-sm overflow-hidden">
                <div class="card-header bg-primary text-white fw-bold py-3 px-4 d-flex align-items-center gap-2">
                    <i class="fa-solid fa-user"></i> Thông Tin Bệnh Nhân
                </div>
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-user me-2"></i>Họ và tên</span>
                        <span class="text-dark fw-bold text-end small">${appointment.patientName != null ? appointment.patientName : 'N/A'}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-envelope me-2"></i>Email</span>
                        <span class="text-dark fw-bold text-end small">${appointment.patientEmail != null ? appointment.patientEmail : 'N/A'}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-phone me-2"></i>Số điện thoại</span>
                        <span class="text-dark fw-bold text-end small">${appointment.patientPhone != null ? appointment.patientPhone : 'N/A'}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-venus-mars me-2"></i>Giới tính</span>
                        <span class="text-dark fw-bold text-end small">
                            <c:choose>
                                <c:when test="${appointment.patientGender == 'MALE'}">Nam</c:when>
                                <c:when test="${appointment.patientGender == 'FEMALE'}">Nữ</c:when>
                                <c:when test="${appointment.patientGender == 'OTHER'}">Khác</c:when>
                                <c:otherwise>N/A</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-cake-candles me-2"></i>Ngày sinh</span>
                        <span class="text-dark fw-bold text-end small">${appointment.patientDobFormatted}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-location-dot me-2"></i>Địa chỉ</span>
                        <span class="text-dark fw-bold text-end small">${appointment.patientAddress != null ? appointment.patientAddress : 'N/A'}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-calendar me-2"></i>Ngày đặt lịch</span>
                        <span class="text-dark fw-bold text-end small">${appointment.createdAtFormatted}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-primary fw-semibold small"><i class="fa-solid fa-calendar-check me-2"></i>Ngày hẹn khám</span>
                        <span class="text-primary fw-bold text-end small">${appointment.appointmentTimeFormatted}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted fw-semibold small"><i class="fa-solid fa-note-sticky me-2"></i>Ghi chú BN</span>
                        <span class="text-dark fw-bold text-end small">${appointment.notes != null ? appointment.notes : 'Không có'}</span>
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
                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
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
            <div class="card rounded-4 border-0 shadow-sm overflow-hidden" id="ai-screening-card">
                <div class="card-header fw-bold py-3 px-4 d-flex align-items-center gap-2 text-white bg-primary bg-gradient">
                    <i class="fa-solid fa-brain"></i> Sàng lọc AI hỗ trợ
                </div>
                <div class="card-body p-4">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <p class="fw-bold text-muted mb-2" style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px;">Ảnh phân tích</p>
                            <div class="bg-light rounded-3 d-flex align-items-center justify-content-center overflow-hidden ratio ratio-1x1">
                                <c:choose>
                                    <c:when test="${not empty screeningReport and not empty screeningReport.inputImageObjectKey}">
                                        <img src="${pageContext.request.contextPath}/reports/${screeningReport.id}/media/input"
                                             alt="Ảnh sàng lọc" class="object-fit-cover w-100 h-100"
                                             onerror="this.replaceWith(Object.assign(document.createElement('div'),{className:'text-center text-muted p-3',innerHTML:'<i class=&quot;fa-solid fa-triangle-exclamation&quot;></i><p class=&quot;mt-2 mb-0 small&quot;>Không tải được ảnh. Kiểm tra Cloudinary hoặc media key.</p>'}));">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center text-muted p-3">
                                            <i class="fa-solid fa-image" style="font-size: 3rem;"></i>
                                            <p class="mt-2 mb-0">Không có ảnh đầu vào cho sàng lọc này</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <p class="fw-bold text-muted mb-2" style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px;">Heatmap</p>
                            <div class="bg-light rounded-3 d-flex align-items-center justify-content-center overflow-hidden ratio ratio-1x1">
                                <c:choose>
                                    <c:when test="${not empty screeningReport and not empty screeningReport.eigencamObjectKey}">
                                        <img src="${pageContext.request.contextPath}/reports/${screeningReport.id}/media/eigencam"
                                             alt="Heatmap giải thích AI" class="object-fit-cover w-100 h-100"
                                             onerror="this.replaceWith(Object.assign(document.createElement('div'),{className:'text-center text-muted p-3',innerHTML:'<i class=&quot;fa-solid fa-triangle-exclamation&quot;></i><p class=&quot;mt-2 mb-0 small&quot;>Không tải được heatmap.</p>'}));">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center text-muted p-3">
                                            <i class="fa-solid fa-fire" style="font-size: 3rem;"></i>
                                            <p class="mt-2 mb-0">Không có EigenCAM cho sàng lọc này</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="col-12">
                            <c:choose>
                                <c:when test="${empty screeningReport and empty appointment.diagnosisReportId}">
                                    <div class="alert alert-light border mb-0">Lịch hẹn này chưa gắn kết quả sàng lọc AI.</div>
                                </c:when>
                                <c:when test="${empty screeningReport}">
                                    <div class="alert alert-warning mb-0">Có liên kết sàng lọc nhưng không tải được báo cáo.</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="row g-3 mt-1">
                                        <div class="col-md-3 text-center">
                                            <div class="rounded-circle d-flex flex-column align-items-center justify-content-center fw-bold mx-auto bg-primary bg-opacity-10 text-primary" style="width: 100px; height: 100px; font-size: 1.5rem;">
                                                <c:set var="confPct" value="${appointment.confidenceScore <= 1 ? appointment.confidenceScore * 100 : appointment.confidenceScore}"/>
                                                <span><fmt:formatNumber value="${confPct}" pattern="#0.0"/>%</span>
                                                <small style="font-size: 0.55rem; font-weight: 600;">ĐỘ TIN CẬY</small>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <p class="fw-bold text-muted mb-1" style="font-size: 0.75rem;">GỢI Ý AI</p>
                                            <p class="fw-bold mb-0" style="font-size: 1.05rem;">
                                                <c:out value="${not empty screeningReport.diseaseName ? screeningReport.diseaseName : (not empty appointment.diseaseName ? appointment.diseaseName : 'Chưa xác định')}"/>
                                            </p>
                                        </div>
                                        <div class="col-md-3">
                                            <p class="fw-bold text-muted mb-1" style="font-size: 0.75rem;">THỜI ĐIỂM SÀNG LỌC</p>
                                            <p class="mb-0 small"><c:out value="${empty screeningReport.createdAtDisplay ? '—' : screeningReport.createdAtDisplay}"/></p>
                                        </div>
                                        <div class="col-md-3">
                                            <p class="fw-bold text-muted mb-1" style="font-size: 0.75rem;">DUYỆT LÂM SÀNG</p>
                                            <span class="badge text-bg-light border"><c:out value="${screeningReport.doctorReviewStatus}"/></span>
                                            <div class="small text-muted mt-1">Trạng thái BS: <c:out value="${appointment.doctorStatus}"/></div>
                                        </div>
                                    </div>

                                    <c:if test="${appointment.doctorStatus != 'ACCEPTED' && screeningReport.doctorReviewStatus == 'PENDING_DOCTOR_REVIEW'}">
                                        <div class="alert alert-info mt-3 mb-0">
                                            Hãy nhấn <strong>Nhận khám</strong> trước để mở duyệt sàng lọc AI.
                                        </div>
                                    </c:if>

                                    <c:if test="${canReviewScreening}">
                                        <div class="border rounded-4 p-3 mt-4 bg-light">
                                            <h6 class="fw-bold mb-3">Duyệt sàng lọc AI</h6>
                                            <p class="small text-muted">Đây không phải chẩn đoán tự động. Hãy xem ảnh và ngữ cảnh trước khi chia sẻ với bệnh nhân.</p>
                                            <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail">
                                                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="appointmentId" value="${appointment.id}">
                                                <div class="mb-3">
                                                    <label class="form-label small fw-semibold" for="doctorNote">Ghi chú lâm sàng</label>
                                                    <textarea class="form-control" id="doctorNote" name="doctorNote" rows="3" maxlength="2000"></textarea>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label small fw-semibold" for="patientGuidance">Hướng dẫn cho bệnh nhân</label>
                                                    <textarea class="form-control" id="patientGuidance" name="patientGuidance" rows="2" maxlength="2000"
                                                              placeholder="Để trống để dùng hướng dẫn từ chính sách lâm sàng đã duyệt."></textarea>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label small fw-semibold" for="selectedDiseaseId">Chẩn đoán cuối (chỉ khi ghi đè)</label>
                                                    <select class="form-select" id="selectedDiseaseId" name="selectedDiseaseId">
                                                        <option value="">Chỉ chọn khi ghi đè</option>
                                                        <c:forEach items="${diseases}" var="d">
                                                            <option value="${d.id}"><c:out value="${d.diseaseName}"/></option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label small fw-semibold" for="overrideReason">Lý do ghi đè</label>
                                                    <textarea class="form-control" id="overrideReason" name="overrideReason" rows="2" maxlength="1000"></textarea>
                                                </div>
                                                <div class="form-check mb-3">
                                                    <input class="form-check-input" id="visibleToPatient" name="visibleToPatient" type="checkbox" checked>
                                                    <label class="form-check-label" for="visibleToPatient">Cho bệnh nhân xem kết luận</label>
                                                </div>
                                                <div class="d-flex flex-wrap gap-2">
                                                    <button class="btn btn-success btn-sm" name="action" value="reviewConfirm" type="submit">Xác nhận AI</button>
                                                    <button class="btn btn-warning btn-sm" name="action" value="reviewOverride" type="submit">Ghi đè</button>
                                                    <button class="btn btn-outline-secondary btn-sm" name="action" value="reviewDismiss" type="submit">Bỏ qua</button>
                                                    <button class="btn btn-outline-danger btn-sm" name="action" value="reviewInPerson" type="submit">Yêu cầu khám trực tiếp</button>
                                                </div>
                                            </form>
                                        </div>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
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
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
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
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
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
                    <i class="fa-solid fa-user-doctor me-2 text-primary"></i>Nhận xét & chẩn đoán lâm sàng
                </h5>
            </div>
            <div class="card-body px-4 pb-4">
                <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#notes-card">
                    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                    <input type="hidden" name="action" value="saveNotes">
                    <div class="mb-3">
                        <textarea class="form-control" name="doctorNotes" rows="4" 
                            placeholder="Nhập nhận xét y khoa, kết luận chẩn đoán hoặc hướng dẫn tự chăm sóc tại nhà cho bệnh nhân..." 
                            style="border-radius: 12px; border: 2px solid #e2e8f0; resize: none;"
                            ${appointment.status == 'COMPLETED' || appointment.status == 'CANCELLED' ? 'readonly' : ''}>${appointment.doctorNotes}</textarea>
                    </div>
                    <c:choose>
                        <c:when test="${appointment.status == 'CONFIRMED' || appointment.status == 'CHECKED_IN'}">
                            <div class="d-flex gap-2 flex-wrap">
                                <c:if test="${appointment.doctorStatus != 'ACCEPTED'}">
                                    <button type="button" class="btn btn-success fw-bold px-4 rounded-3" onclick="submitAccept()">
                                        <i class="fa-solid fa-handshake me-2"></i>Nhận khám
                                    </button>
                                </c:if>
                                <button type="submit" class="btn btn-primary fw-bold px-4 rounded-3">
                                    <i class="fa-solid fa-floppy-disk me-2"></i>Lưu nhận xét
                                </button>
                                <c:if test="${appointment.status == 'CONFIRMED'}">
                                    <button type="button" class="btn btn-outline-primary fw-bold px-4 rounded-3" onclick="submitCheckIn()">
                                        <i class="fa-solid fa-user-check me-2"></i>Check-in bệnh nhân
                                    </button>
                                </c:if>
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
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="appointmentId" value="${appointment.id}">
                    <input type="hidden" name="action" value="completeAppointment">
                </form>
            <form id="checkInForm" method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#notes-card" style="display: none;">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="appointmentId" value="${appointment.id}">
                <input type="hidden" name="action" value="checkIn">
            </form>
            <form id="acceptForm" method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail#ai-screening-card" style="display: none;">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="appointmentId" value="${appointment.id}">
                <input type="hidden" name="action" value="acceptAppointment">
            </form>
            </div>
        </div>

        <c:if test="${appointment.status == 'COMPLETED'}">
            <div class="card border-0 shadow-sm rounded-4 mb-4" id="medical-report-card">
                <div class="card-header bg-white border-0 pt-4 px-4 pb-2">
                    <h5 class="fw-bold mb-0">
                        <i class="fa-solid fa-notes-medical me-2 text-success"></i>Hồ sơ y tế
                    </h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <c:if test="${not empty invoice}">
                        <p class="small text-muted mb-3">Hóa đơn: <strong><c:out value="${invoice.status}"/></strong>
                            — <c:out value="${invoice.totalAmount}"/> VND</p>
                    </c:if>
                    <form method="post" action="${pageContext.request.contextPath}/doctor/appointments/detail">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="appointmentId" value="${appointment.id}">
                        <input type="hidden" name="action" value="finalizeMedicalReport">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Lý do khám</label>
                            <textarea class="form-control" name="chiefComplaint" rows="2" style="border-radius: 12px;"><c:out value="${empty medicalReport ? appointment.notes : medicalReport.chiefComplaint}"/></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Chẩn đoán lâm sàng</label>
                            <textarea class="form-control" name="doctorDiagnosis" rows="3" style="border-radius: 12px;"><c:out value="${empty medicalReport ? appointment.doctorNotes : medicalReport.doctorDiagnosis}"/></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Kế hoạch điều trị</label>
                            <textarea class="form-control" name="treatmentPlan" rows="3" style="border-radius: 12px;"><c:out value="${empty medicalReport ? '' : medicalReport.treatmentPlan}"/></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Ghi chú đơn thuốc</label>
                            <textarea class="form-control" name="prescriptionNote" rows="2" style="border-radius: 12px;"><c:out value="${empty medicalReport ? '' : medicalReport.prescriptionNote}"/></textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold" for="followUpDate">Tái khám (tuỳ chọn)</label>
                            <input type="text" class="form-control" id="followUpDate" name="followUpDate"
                                   inputmode="numeric" placeholder="dd/MM/yyyy" autocomplete="off"
                                   title="Nhập ngày theo định dạng dd/MM/yyyy"
                                   style="border-radius: 12px; max-width: 240px;"
                                   value="${not empty medicalReport && not empty medicalReport.followUpDate ? medicalReport.followUpDateDisplayForInput : ''}">
                            <div class="form-text">Để trống nếu không hẹn tái khám. Định dạng: dd/MM/yyyy</div>
                        </div>
                        <button type="submit" class="btn btn-success fw-bold px-4 rounded-3">
                            <i class="fa-solid fa-floppy-disk me-2"></i>Lưu / hoàn tất hồ sơ y tế
                        </button>
                        <c:if test="${not empty medicalReport}">
                            <span class="ms-2 badge text-bg-light border"><c:out value="${medicalReport.status}"/></span>
                        </c:if>
                    </form>
                </div>
            </div>
        </c:if>
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

    function submitCheckIn() {
        if (confirm("Xác nhận bệnh nhân đã check-in?")) {
            document.getElementById('checkInForm').submit();
        }
    }

    function submitAccept() {
        if (confirm("Nhận lịch khám này? Sau khi Accept bạn có thể review AI screening.")) {
            document.getElementById('acceptForm').submit();
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
