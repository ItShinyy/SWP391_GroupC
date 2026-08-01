<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<style>
.hover-highlight:hover {
    background-color: #f8f9fa;
    transition: all 0.2s ease;
}
.doctor-result {
    transition: all 0.2s ease;
}
.doctor-result:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}
.search-form .form-control:focus,
.search-form .form-select:focus {
    border-color: #0d6efd;
    box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}
.slot-btn.selected {
    background-color: #0d6efd;
    border-color: #0d6efd;
    color: #fff;
}
</style>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-body p-5">
                    <div class="text-center mb-4">
                        <i class="fas fa-calendar-check fa-3x text-primary mb-3"></i>
                        <h2 class="fw-bold">Đặt Lịch Hẹn</h2>
                        <p class="text-muted">Lên lịch tư vấn với các chuyên gia da liễu của chúng tôi</p>
                    </div>

                    <!-- Search Form -->
                    <div class="card mb-4 border-primary search-form">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">
                                <i class="fas fa-search me-2"></i>Tìm Kiếm Bác Sĩ
                            </h5>
                        </div>
                        <div class="card-body">
                            <form id="searchForm" method="get" action="${pageContext.request.contextPath}/patient/booking">
                                <c:if test="${not empty screeningReportId}">
                                    <input type="hidden" name="reportId" value="${screeningReportId}">
                                </c:if>
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label for="doctorName" class="form-label fw-semibold">
                                            <i class="fas fa-user-doctor me-1"></i>Tên Bác Sĩ
                                        </label>
                                        <input type="text" class="form-control" id="doctorName" name="doctorName"
                                               value="${param.doctorName}" placeholder="Nhập tên bác sĩ...">
                                    </div>
                                    <div class="col-md-2">
                                        <label for="fromDate" class="form-label fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Từ Ngày
                                        </label>
                                        <input type="date" class="form-control" id="fromDate" name="fromDate"
                                               value="${param.fromDate}">
                                    </div>
                                    <div class="col-md-2">
                                        <label for="toDate" class="form-label fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Đến Ngày
                                        </label>
                                        <input type="date" class="form-control" id="toDate" name="toDate"
                                               value="${param.toDate}">
                                    </div>
                                    <div class="col-md-2">
                                        <label for="specialization" class="form-label fw-semibold">
                                            <i class="fas fa-stethoscope me-1"></i>Chuyên Khoa
                                        </label>
                                        <select class="form-select" id="specialization" name="specialization">
                                            <option value="">Tất cả chuyên khoa</option>
                                            <c:forEach var="spec" items="${specializations}">
                                                <option value="${spec}" ${param.specialization eq spec ? 'selected' : ''}>
                                                    <c:out value="${spec}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-2">
                                        <label for="timeSlot" class="form-label fw-semibold">
                                            <i class="fas fa-clock me-1"></i>Ca Làm Việc
                                        </label>
                                        <select class="form-select" id="timeSlot" name="timeSlot">
                                            <option value="">Tất cả ca</option>
                                            <option value="MORNING" ${param.timeSlot eq 'MORNING' ? 'selected' : ''}>Ca Sáng</option>
                                            <option value="AFTERNOON" ${param.timeSlot eq 'AFTERNOON' ? 'selected' : ''}>Ca Chiều</option>
                                            <option value="EVENING" ${param.timeSlot eq 'EVENING' ? 'selected' : ''}>Ca Tối</option>
                                        </select>
                                    </div>
                                    <div class="col-md-1">
                                        <label class="form-label">&nbsp;</label>
                                        <button type="submit" class="btn btn-success d-block w-100" title="Tìm kiếm">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>
                                <c:if test="${not empty param.doctorName || not empty param.fromDate || not empty param.toDate || not empty param.specialization || not empty param.timeSlot}">
                                    <div class="mt-3">
                                        <a href="${pageContext.request.contextPath}/patient/booking<c:if test='${not empty screeningReportId}'>?reportId=${screeningReportId}</c:if>"
                                           class="btn btn-outline-secondary btn-sm">
                                            <i class="fas fa-times me-1"></i>Xóa Bộ Lọc
                                        </a>
                                    </div>
                                </c:if>
                            </form>
                        </div>
                    </div>

                    <!-- Search Results -->
                    <c:if test="${not empty searchResults}">
                        <div class="card mb-4 border-success">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-search me-2"></i>Kết Quả Tìm Kiếm
                                    <span class="badge bg-light text-dark ms-2">${searchResults.size()} bác sĩ</span>
                                </h5>
                            </div>
                            <div class="card-body p-0">
                                <c:forEach var="doctor" items="${searchResults}" varStatus="status">
                                    <div class="doctor-result p-4 ${status.last ? '' : 'border-bottom'} hover-highlight">
                                        <div class="row align-items-center">
                                            <div class="col-md-1">
                                                <div class="doctor-avatar bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                                                    <span class="fw-bold"><c:out value="${empty doctor.fullName ? '?' : doctor.fullName.substring(0, 1)}"/></span>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <h6 class="mb-1 fw-bold text-primary"><c:out value="${doctor.fullName}"/></h6>
                                                <p class="mb-1 text-muted">
                                                    <i class="fas fa-stethoscope me-2"></i><c:out value="${doctor.specialization}"/>
                                                </p>
                                                <p class="mb-1 small text-muted">
                                                    <i class="fas fa-hospital me-2"></i><c:out value="${doctor.clinicName}"/>
                                                </p>
                                                <c:if test="${not empty doctor.bio}">
                                                    <p class="mb-0 small text-muted"><c:out value="${doctor.bio}"/></p>
                                                </c:if>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="text-center">
                                                    <i class="fas fa-calendar-alt text-success me-1"></i>
                                                    <span class="badge bg-success">Có lịch</span>
                                                </div>
                                            </div>
                                            <div class="col-md-3 text-end">
                                                <button type="button" class="btn btn-primary btn-sm w-100 btn-select-doctor"
                                                        data-doctor-id="${doctor.id}"
                                                        data-doctor-name="<c:out value='${doctor.fullName}'/>"
                                                        data-specialization="<c:out value='${doctor.specialization}'/>"
                                                        data-clinic-id="${doctor.clinicId}">
                                                    <i class="fas fa-user-check me-1"></i>Chọn Bác Sĩ Này
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i><c:out value="${errorMessage}"/>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i><c:out value="${sessionScope.errorMessage}"/>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="errorMessage" scope="session"/>
                    </c:if>

                    <!-- Screening context (Derma) -->
                    <c:if test="${not empty screeningReportId}">
                        <div class="alert alert-info d-flex align-items-center mb-4" role="alert">
                            <i class="fas fa-file-medical fa-2x me-3 text-info"></i>
                            <div>
                                <strong>Đặt lịch kèm báo cáo sàng lọc AI</strong>
                                <p class="mb-0 small">
                                    <c:out value="${empty screeningDiseaseName ? 'AI result' : screeningDiseaseName}"/>
                                    <c:if test="${not empty screeningConfidencePercent}">
                                        · ${screeningConfidencePercent}% confidence
                                    </c:if>
                                </p>
                            </div>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/patient/booking" method="post" id="bookingForm">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="requestId" value="${requestId}">
                        <c:if test="${not empty screeningReportId}">
                            <input type="hidden" name="reportId" value="${screeningReportId}">
                        </c:if>
                        <input type="hidden" id="slot" name="slot" value="" required>

                        <!-- Person being examined (display; booking POST currently books for account owner) -->
                        <div class="mb-4">
                            <label for="examinedPerson" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">1</span>
                                <i class="fas fa-user-group me-2"></i>Người khám
                            </label>
                            <select class="form-select form-select-lg" id="examinedPerson" name="examinedPerson">
                                <option value="SELF" ${empty selectedExaminedPerson or selectedExaminedPerson == 'SELF' ? 'selected' : ''}>
                                    Tôi - <c:out value="${sessionScope.user.fullName}" />
                                </option>
                                <c:forEach var="member" items="${familyMembers}">
                                    <option value="FAMILY:${member.id}" ${selectedExaminedPerson == ('FAMILY:'.concat(member.id)) ? 'selected' : ''}>
                                        <c:out value="${member.relationshipLabel}" /> - <c:out value="${member.fullName}" />
                                    </option>
                                </c:forEach>
                            </select>
                            <small class="text-muted">Bạn có thể thêm người thân trong Hồ sơ cá nhân.</small>
                        </div>

                        <!-- Clinic -->
                        <div class="mb-4">
                            <label for="clinicId" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">2</span>
                                <i class="fas fa-hospital me-2"></i>Chọn Phòng Khám <span class="text-danger">*</span>
                            </label>
                            <select class="form-select form-select-lg" id="clinicId" name="clinicId" required>
                                <option value="">-- Chọn phòng khám --</option>
                                <c:forEach var="clinic" items="${clinics}">
                                    <option value="${clinic.id}"
                                            data-address="<c:out value='${clinic.address}'/>"
                                            ${selectedClinic != null && selectedClinic.id == clinic.id ? 'selected' : ''}>
                                        <c:out value="${clinic.clinicName}"/> - <c:out value="${clinic.address}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Doctor -->
                        <div class="mb-4" id="doctorStep">
                            <label for="doctorId" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">3</span>
                                <i class="fas fa-user-doctor me-2"></i>Chọn Bác Sĩ <span class="text-danger">*</span>
                            </label>
                            <select class="form-select form-select-lg" id="doctorId" name="doctorId" required>
                                <option value="">-- Chọn bác sĩ --</option>
                            </select>
                            <small class="text-muted">Chọn phòng khám trước để tải danh sách bác sĩ</small>
                            <div id="doctorInfo" class="mt-3" style="display: none;"></div>
                        </div>

                        <!-- Date -->
                        <div class="mb-4" id="dateStep">
                            <label for="scheduleDate" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">4</span>
                                <i class="fas fa-calendar me-2"></i>Chọn Ngày Khám <span class="text-danger">*</span>
                            </label>
                            <input type="date" class="form-control form-control-lg" id="scheduleDate" name="scheduleDate" required disabled>
                            <small class="text-muted">Chọn bác sĩ rồi chọn ngày để xem ca khám</small>
                        </div>

                        <!-- Slots -->
                        <div class="mb-4" id="slotStep">
                            <label class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">5</span>
                                <i class="fas fa-clock me-2"></i>Chọn Ca Khám <span class="text-danger">*</span>
                            </label>
                            <div id="slotList" class="row g-3">
                                <div class="col-12"><div class="text-muted small">Chọn bác sĩ và ngày để xem ca khám.</div></div>
                            </div>
                        </div>

                        <!-- Summary -->
                        <div class="mb-4" id="appointmentSummary" style="display: none;">
                            <div class="alert alert-success">
                                <h6 class="alert-heading"><i class="fas fa-check-circle me-2"></i>Thông Tin Lịch Hẹn</h6>
                                <hr>
                                <p class="mb-1"><strong>Phòng khám:</strong> <span id="summaryClinic"></span></p>
                                <p class="mb-1"><strong>Bác sĩ:</strong> <span id="summaryDoctor"></span></p>
                                <p class="mb-1"><strong>Ngày khám:</strong> <span id="summaryDate"></span></p>
                                <p class="mb-0"><strong>Ca khám:</strong> <span id="summarySlot"></span></p>
                            </div>
                        </div>

                        <!-- Notes -->
                        <div class="mb-4">
                            <label for="notes" class="form-label fw-semibold">
                                <i class="fas fa-comment-medical me-2"></i>Ghi Chú (Tùy chọn)
                            </label>
                            <textarea class="form-control" id="notes" name="notes" rows="4" maxlength="1000"
                                      placeholder="Mô tả triệu chứng hoặc mối quan tâm..."></textarea>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg" id="submitBtn" disabled>
                                <i class="fas fa-check me-2"></i>Xác Nhận Đặt Lịch
                            </button>
                            <a href="${pageContext.request.contextPath}/patient/reports" class="btn btn-outline-secondary btn-lg">
                                <i class="fas fa-arrow-left me-2"></i>Trở Về
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
(() => {
    const contextPath = '${pageContext.request.contextPath}';
    let selectedClinicName = '';
    let selectedDoctorName = '';
    let selectedSlotLabel = '';

    const clinicSelect = document.getElementById('clinicId');
    const doctorSelect = document.getElementById('doctorId');
    const dateInput = document.getElementById('scheduleDate');
    const slotInput = document.getElementById('slot');
    const slotList = document.getElementById('slotList');
    const submitBtn = document.getElementById('submitBtn');
    const summary = document.getElementById('appointmentSummary');

    dateInput.min = new Date().toISOString().slice(0, 10);

    const clearSlots = (message) => {
        slotInput.value = '';
        selectedSlotLabel = '';
        slotList.innerHTML = '<div class="col-12"><div class="text-muted small">' + (message || 'Chọn bác sĩ và ngày để xem ca khám.') + '</div></div>';
        summary.style.display = 'none';
        submitBtn.disabled = true;
    };

    const updateSummary = () => {
        if (!clinicSelect.value || !doctorSelect.value || !dateInput.value || !slotInput.value) {
            summary.style.display = 'none';
            submitBtn.disabled = true;
            return;
        }
        document.getElementById('summaryClinic').textContent = selectedClinicName;
        document.getElementById('summaryDoctor').textContent = selectedDoctorName;
        document.getElementById('summaryDate').textContent = new Date(dateInput.value + 'T00:00:00').toLocaleDateString('vi-VN');
        document.getElementById('summarySlot').textContent = selectedSlotLabel;
        summary.style.display = 'block';
        submitBtn.disabled = false;
    };

    const showDoctorInfo = (option) => {
        const div = document.getElementById('doctorInfo');
        if (!option || !option.value) {
            div.style.display = 'none';
            return;
        }
        let html = '<div class="card border-primary"><div class="card-body">';
        html += '<h6 class="text-primary"><i class="fas fa-user-doctor me-2"></i>' + option.textContent + '</h6>';
        const specialization = option.getAttribute('data-specialization');
        if (specialization) {
            html += '<p class="mb-0 small"><strong>Chuyên khoa:</strong> ' + specialization + '</p>';
        }
        html += '</div></div>';
        div.innerHTML = html;
        div.style.display = 'block';
    };

    const loadDoctors = async (selectedDoctorId) => {
        doctorSelect.innerHTML = '<option value="">Đang tải...</option>';
        dateInput.value = '';
        dateInput.disabled = true;
        clearSlots();
        document.getElementById('doctorInfo').style.display = 'none';

        if (!clinicSelect.value) {
            doctorSelect.innerHTML = '<option value="">-- Chọn bác sĩ --</option>';
            return;
        }

        selectedClinicName = clinicSelect.options[clinicSelect.selectedIndex].text;
        try {
            const res = await fetch(contextPath + '/patient/booking?ajax=doctors&clinicId=' + encodeURIComponent(clinicSelect.value));
            const doctors = await res.json();
            doctorSelect.innerHTML = '<option value="">-- Chọn bác sĩ --</option>';
            if (!Array.isArray(doctors) || doctors.length === 0) {
                doctorSelect.innerHTML = '<option value="">Không có bác sĩ nào</option>';
                return;
            }
            doctors.forEach((d) => {
                const option = document.createElement('option');
                option.value = d.id;
                option.textContent = d.fullName + (d.specialization ? ' - ' + d.specialization : '');
                option.setAttribute('data-specialization', d.specialization || '');
                doctorSelect.appendChild(option);
            });
            if (selectedDoctorId) {
                doctorSelect.value = selectedDoctorId;
                if (doctorSelect.value === selectedDoctorId) {
                    selectedDoctorName = doctorSelect.options[doctorSelect.selectedIndex].textContent;
                    showDoctorInfo(doctorSelect.options[doctorSelect.selectedIndex]);
                    dateInput.disabled = false;
                }
            }
        } catch (e) {
            doctorSelect.innerHTML = '<option value="">Lỗi tải danh sách</option>';
        }
    };

    const loadSlots = async () => {
        clearSlots('Đang tải ca khám...');
        if (!doctorSelect.value || !dateInput.value) {
            clearSlots();
            return;
        }
        slotList.innerHTML = '<div class="col-12 text-center"><div class="spinner-border text-primary"></div><p class="mt-2 mb-0">Đang tải ca khám...</p></div>';
        try {
            const url = contextPath + '/patient/booking?ajax=slots&doctorId=' + encodeURIComponent(doctorSelect.value)
                + '&date=' + encodeURIComponent(dateInput.value);
            const res = await fetch(url);
            const slots = await res.json();
            if (!Array.isArray(slots) || slots.length === 0) {
                clearSlots('Không có ca khám trong ngày này.');
                return;
            }
            let html = '';
            slots.forEach((s) => {
                const available = s.state === 'available';
                const cls = available ? 'btn-outline-primary' : 'btn-outline-secondary';
                const label = s.label || s.slot;
                const txt = available
                    ? label + ' (Còn ' + (s.remaining || 0) + ' chỗ)'
                    : label + (s.state === 'booked' ? ' (Đầy)' : ' (Đóng)');
                html += '<div class="col-md-4">';
                html += '<button type="button" class="btn ' + cls + ' btn-lg w-100 slot-btn" ';
                html += 'data-slot="' + s.slot + '" data-label="' + label.replace(/"/g, '&quot;') + '" ';
                if (!available) html += 'disabled ';
                html += 'onclick="window.__selectSlot(this)">';
                html += txt;
                html += '</button></div>';
            });
            slotList.innerHTML = html;
            const bookable = slots.some((s) => s.state === 'available');
            if (!bookable) {
                submitBtn.disabled = true;
            }
        } catch (e) {
            clearSlots('Lỗi tải lịch. Vui lòng thử lại.');
        }
    };

    window.__selectSlot = (btn) => {
        document.querySelectorAll('.slot-btn').forEach((b) => b.classList.remove('selected', 'btn-primary'));
        document.querySelectorAll('.slot-btn:not(:disabled)').forEach((b) => {
            b.classList.add('btn-outline-primary');
            b.classList.remove('btn-primary');
        });
        btn.classList.remove('btn-outline-primary');
        btn.classList.add('btn-primary', 'selected');
        slotInput.value = btn.dataset.slot;
        selectedSlotLabel = btn.dataset.label || btn.dataset.slot;
        updateSummary();
    };

    const selectDoctor = (doctorId, doctorName, specialization, clinicId) => {
        if (!clinicId || !Array.from(clinicSelect.options).some((o) => o.value === clinicId)) {
            showTempMessage('Không tìm thấy phòng khám của bác sĩ này.', 'warning');
            return;
        }
        clinicSelect.value = clinicId;
        selectedClinicName = clinicSelect.options[clinicSelect.selectedIndex].text;
        selectedDoctorName = doctorName;
        loadDoctors(doctorId).then(() => {
            document.getElementById('bookingForm').scrollIntoView({ behavior: 'smooth' });
            showTempMessage('Đã chọn bác sĩ: ' + doctorName, 'success');
        });
    };

    document.querySelectorAll('.btn-select-doctor').forEach((btn) => {
        btn.addEventListener('click', () => {
            selectDoctor(btn.dataset.doctorId, btn.dataset.doctorName, btn.dataset.specialization, btn.dataset.clinicId);
        });
    });

    const showTempMessage = (message, type) => {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-' + (type || 'info') + ' alert-dismissible fade show position-fixed';
        alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 1050; min-width: 300px;';
        alertDiv.innerHTML = '<i class="fas fa-check-circle me-2"></i>' + message
            + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
        document.body.appendChild(alertDiv);
        setTimeout(() => {
            if (alertDiv.parentNode) alertDiv.parentNode.removeChild(alertDiv);
        }, 3000);
    };

    clinicSelect.addEventListener('change', () => loadDoctors(''));
    doctorSelect.addEventListener('change', () => {
        if (doctorSelect.value) {
            selectedDoctorName = doctorSelect.options[doctorSelect.selectedIndex].textContent;
            showDoctorInfo(doctorSelect.options[doctorSelect.selectedIndex]);
            dateInput.disabled = false;
            if (dateInput.value) loadSlots();
            else clearSlots();
        } else {
            dateInput.disabled = true;
            dateInput.value = '';
            document.getElementById('doctorInfo').style.display = 'none';
            clearSlots();
        }
    });
    dateInput.addEventListener('change', loadSlots);

    document.getElementById('bookingForm').addEventListener('submit', (e) => {
        if (!clinicSelect.value || !doctorSelect.value || !dateInput.value || !slotInput.value) {
            e.preventDefault();
        }
    });

    if (clinicSelect.value) {
        loadDoctors('');
    }
})();
</script>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
