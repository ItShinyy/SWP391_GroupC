<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

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

.disabled-form {
    position: relative;
}

.form-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.9);
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 0.375rem;
}

.overlay-message {
    text-align: center;
    color: #6c757d;
}

.disabled-form input, 
.disabled-form select, 
.disabled-form textarea, 
.disabled-form button {
    pointer-events: none;
    opacity: 0.6;
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
                                <div class="row g-3">
                                    <!-- Tên bác sĩ -->
                                    <div class="col-md-3">
                                        <label for="doctorName" class="form-label fw-semibold">
                                            <i class="fas fa-user-doctor me-1"></i>Tên Bác Sĩ
                                        </label>
                                        <input type="text" class="form-control" id="doctorName" name="doctorName" 
                                               value="${param.doctorName}" placeholder="Nhập tên bác sĩ...">
                                    </div>
                                    
                                    <!-- Từ ngày -->
                                    <div class="col-md-2">
                                        <label for="fromDate" class="form-label fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Từ Ngày
                                        </label>
                                        <input type="date" class="form-control" id="fromDate" name="fromDate" 
                                               value="${param.fromDate}">
                                    </div>
                                    
                                    <!-- Đến ngày -->
                                    <div class="col-md-2">
                                        <label for="toDate" class="form-label fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Đến Ngày
                                        </label>
                                        <input type="date" class="form-control" id="toDate" name="toDate" 
                                               value="${param.toDate}">
                                    </div>
                                    
                                    <!-- Chuyên khoa -->
                                    <div class="col-md-2">
                                        <label for="specialization" class="form-label fw-semibold">
                                            <i class="fas fa-stethoscope me-1"></i>Chuyên Khoa
                                        </label>
                                        <select class="form-select" id="specialization" name="specialization">
                                            <option value="">Tất cả chuyên khoa</option>
                                            <c:forEach var="spec" items="${specializations}">
                                                <option value="${spec}" ${param.specialization eq spec ? 'selected' : ''}>
                                                    ${spec}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    
                                    <!-- Ca làm việc -->
                                    <div class="col-md-2">
                                        <label for="timeSlot" class="form-label fw-semibold">
                                            <i class="fas fa-clock me-1"></i>Ca Làm Việc
                                        </label>
                                        <select class="form-select" id="timeSlot" name="timeSlot">
                                            <option value="">Tất cả ca</option>
                                            <option value="MORNING" ${param.timeSlot eq 'MORNING' ? 'selected' : ''}>
                                                🌅 Ca Sáng (07:00-11:30)
                                            </option>
                                            <option value="AFTERNOON" ${param.timeSlot eq 'AFTERNOON' ? 'selected' : ''}>
                                                🌤️ Ca Chiều (13:00-17:00)
                                            </option>
                                            <option value="EVENING" ${param.timeSlot eq 'EVENING' ? 'selected' : ''}>
                                                🌙 Ca Tối (18:00-21:00)
                                            </option>
                                        </select>
                                    </div>
                                    
                                    <!-- Nút tìm kiếm -->
                                    <div class="col-md-1">
                                        <label class="form-label">&nbsp;</label>
                                        <button type="submit" class="btn btn-success d-block w-100" title="Tìm kiếm">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>
                                
                                <!-- Clear filters -->
                                <c:if test="${not empty param.doctorName || not empty param.fromDate || not empty param.toDate || not empty param.specialization || not empty param.timeSlot}">
                                    <div class="mt-3">
                                        <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-outline-secondary btn-sm">
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
                                                    <span class="fw-bold">${doctor.fullName.substring(0, 1)}</span>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <h6 class="mb-1 fw-bold text-primary">${doctor.fullName}</h6>
                                                <p class="mb-1 text-muted">
                                                    <i class="fas fa-stethoscope me-2"></i>${doctor.specialization}
                                                </p>
                                                <p class="mb-1 small text-muted">
                                                    <i class="fas fa-hospital me-2"></i>${doctor.clinicName}
                                                </p>
                                                <c:if test="${not empty doctor.bio}">
                                                    <p class="mb-0 small text-muted">${doctor.bio}</p>
                                                </c:if>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="text-center">
                                                    <i class="fas fa-calendar-alt text-success me-1"></i>
                                                    <span class="badge bg-success">Có lịch</span>
                                                </div>
                                            </div>
                                            <div class="col-md-3 text-end">
                                                <button type="button" class="btn btn-primary btn-sm w-100" 
                                                        onclick="selectDoctor('${doctor.id}', '${doctor.fullName}', '${doctor.specialization}')">
                                                    <i class="fas fa-user-check me-1"></i>Chọn Bác Sĩ Này
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- Success/Error Messages -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="errorMessage" scope="session"/>
                    </c:if>

                    <!-- Report Context -->
                    <c:if test="${not empty reportId}">
                        <div class="alert alert-info d-flex align-items-center mb-4" role="alert">
                            <i class="fas fa-file-medical fa-2x me-3 text-info"></i>
                            <div>
                                <strong>Đặt lịch tư vấn cho báo cáo chẩn đoán</strong>
                                <p class="mb-0 small">Mã báo cáo: #${reportId.substring(0, 8)}...</p>
                            </div>
                        </div>
                    </c:if>

                    <!-- Incomplete Appointment Warning -->
                    <c:if test="${hasIncompleteAppointment}">
                        <div class="alert alert-warning d-flex align-items-center mb-4" role="alert">
                            <i class="fas fa-exclamation-triangle fa-2x me-3 text-warning"></i>
                            <div class="flex-grow-1">
                                <h6 class="alert-heading mb-2">
                                    <i class="fas fa-clock me-1"></i>Bạn có lịch hẹn chưa hoàn thành
                                </h6>
                                <p class="mb-2">Bạn cần hoàn thành lịch khám cũ trước khi đặt lịch mới.</p>
                                <c:if test="${not empty incompleteAppointment}">
                                    <div class="small">
                                        <strong>Lịch hẹn:</strong> 
                                        ${incompleteAppointment.appointmentTime.toString().replace("T", " ")}
                                        <br>
                                        <strong>Phòng khám:</strong> ${incompleteAppointment.clinicName}
                                        <br>
                                        <strong>Trạng thái:</strong> 
                                        <c:choose>
                                            <c:when test="${incompleteAppointment.status == 'CREATED'}">
                                                <span class="badge bg-secondary">Đã tạo</span>
                                            </c:when>
                                            <c:when test="${incompleteAppointment.status == 'CONFIRMED'}">
                                                <span class="badge bg-primary">Đã xác nhận</span>
                                            </c:when>
                                            <c:when test="${incompleteAppointment.status == 'IN_PROGRESS'}">
                                                <span class="badge bg-info">Đang khám</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">${incompleteAppointment.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:if>
                            </div>
                            <div>
                                <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-warning">
                                    <i class="fas fa-calendar-check me-1"></i>Xem Lịch Hẹn
                                </a>
                            </div>
                        </div>
                    </c:if>

                    <!-- Booking Form -->
                    <form action="${pageContext.request.contextPath}/patient/booking" method="post" id="bookingForm" ${blockBooking ? 'class="disabled-form"' : ''}>
                        <input type="hidden" name="requestId" value="${requestId}">
                        <c:if test="${not empty reportId}">
                            <input type="hidden" name="reportId" value="${reportId}">
                        </c:if>

                        <c:if test="${blockBooking}">
                            <div class="position-relative">
                                <div class="form-overlay">
                                    <div class="overlay-message">
                                        <i class="fas fa-lock fa-3x mb-3 text-muted"></i>
                                        <h5>Không thể đặt lịch mới</h5>
                                        <p>Vui lòng hoàn thành lịch hẹn hiện tại trước</p>
                                    </div>
                                </div>
                        </c:if>

                        <!-- Step 1: Select Clinic -->
                        <div class="mb-4">
                            <label for="clinicId" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">1</span>
                                <i class="fas fa-hospital me-2"></i>Chọn Phòng Khám <span class="text-danger">*</span>
                            </label>
                            <select class="form-select form-select-lg" id="clinicId" name="clinicId" required>
                                <option value="">-- Chọn phòng khám --</option>
                                <c:forEach var="clinic" items="${clinics}">
                                    <option value="${clinic.id}">
                                        ${clinic.clinicName} - ${clinic.address}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Step 2: Select Doctor -->
                        <div class="mb-4" id="doctorStep">
                            <label for="doctorId" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">2</span>
                                <i class="fas fa-user-doctor me-2"></i>Chọn Bác Sĩ <span class="text-danger">*</span>
                            </label>
                            <select class="form-select form-select-lg" id="doctorId" name="doctorId" required>
                                <option value="">-- Chọn bác sĩ --</option>
                            </select>
                            <small class="text-muted">💡 Chọn bác sĩ để xem ngày làm việc của họ</small>
                            <div id="doctorInfo" class="mt-3" style="display: none;"></div>
                        </div>

                        <!-- Step 3: Select Date -->
                        <div class="mb-4" id="dateStep">
                            <label for="appointmentDate" class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">3</span>
                                <i class="fas fa-calendar me-2"></i>Chọn Ngày Khám <span class="text-danger">*</span>
                            </label>
                            <select class="form-select form-select-lg" id="appointmentDate" name="appointmentDate" required>
                                <option value="">-- Chọn ngày --</option>
                            </select>
                            <small class="text-muted">💡 Chọn ngày để xem bác sĩ nào có lịch làm việc</small>
                        </div>

                        <!-- Step 4: Select Time Slot -->
                        <div class="mb-4" id="slotStep">
                            <label class="form-label fw-semibold">
                                <span class="badge bg-primary me-2">4</span>
                                <i class="fas fa-clock me-2"></i>Chọn Ca Khám <span class="text-danger">*</span>
                            </label>
                            <div id="slotList" class="row g-3"></div>
                        </div>

                        <!-- Hidden fields -->
                        <input type="hidden" id="slotId" name="slotId" required>
                        <input type="hidden" id="appointmentTime" name="appointmentTime" required>

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
                            <textarea class="form-control" id="notes" name="notes" rows="4" 
                                      placeholder="Mô tả triệu chứng hoặc mối quan tâm..."></textarea>
                        </div>

                        <!-- Submit Buttons -->
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg" id="submitBtn" ${blockBooking ? 'disabled' : 'disabled'}>
                                <i class="fas fa-check me-2"></i>Xác Nhận Đặt Lịch
                            </button>
                            <a href="${pageContext.request.contextPath}/patient/reports" class="btn btn-outline-secondary btn-lg">
                                <i class="fas fa-arrow-left me-2"></i>Trở Về
                            </a>
                        </div>
                        
                        <c:if test="${blockBooking}">
                            </div> <!-- Close position-relative div -->
                        </c:if>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
let selectedClinicName = '';
let selectedDoctorName = '';
let selectedDate = '';

document.addEventListener('DOMContentLoaded', function() {
    const today = new Date();
    document.getElementById('appointmentDate').min = today.toISOString().split('T')[0];
    
    // Clinic selection
    document.getElementById('clinicId').addEventListener('change', function() {
        console.log('Clinic changed. Selected index:', this.selectedIndex);
        console.log('Selected option value:', this.value);
        console.log('Selected option text:', this.options[this.selectedIndex].text);
        
        selectedClinicName = this.options[this.selectedIndex].text;
        if (this.value) {
            console.log('Calling loadDoctors with clinicId:', this.value);
            loadDoctors(this.value);
            // Clear date and slots when clinic changes
            clearDateSelection();
        } else {
            document.getElementById('doctorId').innerHTML = '<option value="">-- Chọn bác sĩ --</option>';
            clearDateSelection();
        }
    });
    
    // Doctor selection - load doctor's available dates
    document.getElementById('doctorId').addEventListener('change', function() {
        if (this.value) {
            selectedDoctorName = this.options[this.selectedIndex].textContent;
            showDoctorInfo(this.options[this.selectedIndex]);
            loadDoctorAvailableDates(this.value);
        } else {
            document.getElementById('doctorInfo').style.display = 'none';
            clearDateSelection();
        }
    });
    
    // Date selection - load doctors available on this date or slots if doctor already selected
    document.getElementById('appointmentDate').addEventListener('change', function() {
        selectedDate = this.value;
        console.log('Date selected:', selectedDate);
        
        if (selectedDate) {
            const clinicId = document.getElementById('clinicId').value;
            const doctorId = document.getElementById('doctorId').value;
            
            if (doctorId) {
                // Doctor already selected, load slots for this date
                loadSlots(doctorId, selectedDate);
            } else if (clinicId) {
                // No doctor selected, load doctors for this date
                loadDoctorsForDate(clinicId, selectedDate);
            }
        } else {
            // Clear slots if no date selected
            document.getElementById('slotList').innerHTML = '';
            document.getElementById('appointmentSummary').style.display = 'none';
            document.getElementById('submitBtn').disabled = true;
        }
    });
});

function clearDateSelection() {
    const dateSelect = document.getElementById('appointmentDate');
    dateSelect.innerHTML = '<option value="">-- Chọn ngày --</option>';
    document.getElementById('slotList').innerHTML = '';
    document.getElementById('appointmentSummary').style.display = 'none';
    document.getElementById('submitBtn').disabled = true;
}

function loadDoctorAvailableDates(doctorId) {
    const dateSelect = document.getElementById('appointmentDate');
    dateSelect.innerHTML = '<option value="">Đang tải...</option>';
    
    console.log('Loading available dates for doctor:', doctorId);
    
    // Load doctor's schedule
    const url = '/SkinAI/api/doctors?action=getDoctorSchedule&doctorId=' + encodeURIComponent(doctorId);
    
    fetch(url)
        .then(function(response) {
            return response.json();
        })
        .then(function(data) {
            console.log('Doctor schedule response:', data);
            dateSelect.innerHTML = '<option value="">-- Chọn ngày --</option>';
            
            if (data.success && data.schedules && data.schedules.length > 0) {
                // Group schedules by date and only show dates with available slots
                const availableDates = {};
                
                data.schedules.forEach(function(schedule) {
                    if (schedule.available > 0) {
                        const date = schedule.date;
                        if (!availableDates[date]) {
                            availableDates[date] = [];
                        }
                        availableDates[date].push(schedule);
                    }
                });
                
                // Sort dates and add to select
                const sortedDates = Object.keys(availableDates).sort();
                console.log('Available dates:', sortedDates);
                
                for (let i = 0; i < sortedDates.length; i++) {
                    const date = sortedDates[i];
                    const schedules = availableDates[date];
                    const option = document.createElement('option');
                    option.value = date;
                    
                    // Format date for display
                    const dateObj = new Date(date + 'T00:00:00');
                    const formattedDate = dateObj.toLocaleDateString('vi-VN', {
                        weekday: 'short',
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric'
                    });
                    
                    option.textContent = formattedDate + ' (' + schedules.length + ' ca)';
                    dateSelect.appendChild(option);
                }
                
                if (sortedDates.length === 0) {
                    dateSelect.innerHTML = '<option value="">Không có ngày nào có lịch</option>';
                }
            } else {
                dateSelect.innerHTML = '<option value="">Không có lịch làm việc</option>';
            }
        })
        .catch(function(error) {
            console.error('Error loading dates:', error);
            dateSelect.innerHTML = '<option value="">Lỗi tải ngày</option>';
        });
}

function loadDoctorsForDate(clinicId, date) {
    // When user selects date first, load doctors available on that date
    fetch(`${window.location.origin}/SkinAI/api/doctors?action=getAvailableByDate&clinicId=${clinicId}&date=${date}`)
        .then(r => r.json())
        .then(data => {
            if (data.success && data.doctors) {
                updateDoctorSelectForDate(data.doctors);
            }
        })
        .catch(() => {});
}

function updateDoctorSelectForDate(doctors) {
    const select = document.getElementById('doctorId');
    select.innerHTML = '<option value="">-- Chọn bác sĩ có lịch hôm này --</option>';
    
    doctors.forEach(d => {
        const opt = document.createElement('option');
        opt.value = d.id;
        opt.textContent = `${d.fullName} - ${d.specialization} (Có ${d.availableSlots.length} ca)`;
        opt.dataset.bio = d.bio || '';
        opt.dataset.license = d.licenseNumber || '';
        opt.dataset.hasSlots = 'true'; // Mark that this doctor has slots for the selected date
        select.appendChild(opt);
    });
}

function loadDoctors(clinicId) {
    const select = document.getElementById('doctorId');
    select.innerHTML = '<option value="">Đang tải...</option>';
    
    console.log('Raw clinicId:', clinicId);
    console.log('clinicId type:', typeof clinicId);
    
    if (!clinicId || clinicId.trim() === '') {
        console.error('clinicId is empty or null');
        select.innerHTML = '<option value="">Lỗi: không có clinic ID</option>';
        return;
    }
    
    // Use simple string concatenation
    const url = '/SkinAI/api/doctors?action=getByClinic&clinicId=' + encodeURIComponent(clinicId);
    
    console.log('Final API URL:', url);
    
    fetch(url)
        .then(function(response) {
            console.log('Response status:', response.status);
            return response.json();
        })
        .then(function(data) {
            console.log('API response:', data);
            select.innerHTML = '<option value="">-- Chọn bác sĩ --</option>';
            if (data.success && data.doctors && data.doctors.length > 0) {
                console.log('Number of doctors:', data.doctors.length);
                for (let i = 0; i < data.doctors.length; i++) {
                    const doctor = data.doctors[i];
                    console.log('Adding doctor:', doctor.fullName);
                    const option = document.createElement('option');
                    option.value = doctor.id;
                    option.textContent = doctor.fullName + ' - ' + doctor.specialization;
                    option.setAttribute('data-bio', doctor.bio || '');
                    option.setAttribute('data-license', doctor.licenseNumber || '');
                    select.appendChild(option);
                }
            } else {
                console.log('No doctors found or API error:', data.message || 'Unknown error');
                select.innerHTML = '<option value="">Không có bác sĩ nào</option>';
            }
        })
        .catch(function(error) {
            console.error('API Error:', error);
            select.innerHTML = '<option value="">Lỗi tải danh sách</option>';
        });
}

function showDoctorInfo(option) {
    const div = document.getElementById('doctorInfo');
    let html = '<div class="card border-primary"><div class="card-body">';
    html += '<h6 class="text-primary"><i class="fas fa-user-doctor me-2"></i>' + option.textContent + '</h6>';
    
    const license = option.getAttribute('data-license');
    const bio = option.getAttribute('data-bio');
    
    if (license) {
        html += '<p class="mb-1 small"><strong>Giấy phép:</strong> ' + license + '</p>';
    }
    if (bio) {
        html += '<p class="mb-0 small">' + bio + '</p>';
    }
    html += '</div></div>';
    div.innerHTML = html;
    div.style.display = 'block';
}

function loadSlots(doctorId, date) {
    const list = document.getElementById('slotList');
    list.innerHTML = '<div class="col-12 text-center"><div class="spinner-border"></div><p class="mt-2">Đang tải ca khám...</p></div>';
    
    console.log('Loading slots for doctor:', doctorId, 'date:', date);
    
    // Build URL - avoid template literals
    let url = '/SkinAI/api/doctors?action=getDoctorSchedule&doctorId=' + encodeURIComponent(doctorId);
    if (date) {
        url += '&date=' + encodeURIComponent(date);
    }
    
    console.log('Slots API URL:', url);
    
    fetch(url)
        .then(function(response) {
            console.log('Slots response status:', response.status);
            return response.json();
        })
        .then(function(data) {
            console.log('Slots API response:', data);
            
            if (data.success && data.schedules && data.schedules.length > 0) {
                // Filter schedules for specific date if provided
                let filteredSchedules = data.schedules;
                if (date) {
                    filteredSchedules = data.schedules.filter(function(s) {
                        return s.date === date;
                    });
                    console.log('Filtered schedules for date', date, ':', filteredSchedules);
                }
                
                if (filteredSchedules.length > 0) {
                    displaySlots(filteredSchedules);
                } else {
                    list.innerHTML = '<div class="col-12"><div class="alert alert-info">Không có ca khám trong ngày này</div></div>';
                }
            } else {
                list.innerHTML = '<div class="col-12"><div class="alert alert-info">Không có lịch làm việc</div></div>';
            }
        })
        .catch(function(error) {
            console.error('Slots API Error:', error);
            list.innerHTML = '<div class="col-12"><div class="alert alert-danger">Lỗi tải lịch</div></div>';
        });
}

function displaySlots(schedules) {
    const list = document.getElementById('slotList');
    let html = '';
    
    schedules.forEach(s => {
        const avail = s.available || 0;
        const cls = avail > 0 ? 'btn-outline-primary' : 'btn-outline-secondary';
        const slotName = getSlotName(s.slot);
        const txt = avail > 0 ? slotName + ' (Còn ' + avail + ' chỗ)' : slotName + ' (Đầy)';
        const disabled = avail === 0 ? 'disabled' : '';
        
        html += '<div class="col-md-4">';
        html += '<button type="button" class="btn ' + cls + ' btn-lg w-100 slot-btn" ';
        html += 'data-slot-id="' + s.id + '" data-slot="' + s.slot + '" ';
        html += disabled + ' onclick="selectSlot(this)">';
        html += txt;
        html += '</button>';
        html += '</div>';
    });
    
    list.innerHTML = html;
}

function selectSlot(btn) {
    console.log('Slot selected:', btn);
    console.log('Slot data:', btn.dataset);
    
    document.querySelectorAll('.slot-btn').forEach(function(b) {
        b.classList.remove('btn-primary');
        b.classList.add('btn-outline-primary');
    });
    
    btn.classList.remove('btn-outline-primary');
    btn.classList.add('btn-primary');
    
    const slot = btn.dataset.slot;
    const slotId = btn.dataset.slotId;
    
    console.log('Selected slot:', slot, 'slotId:', slotId);
    
    document.getElementById('slotId').value = slotId;
    document.getElementById('appointmentTime').value = getDateTime(selectedDate, slot);
    
    document.getElementById('summaryClinic').textContent = selectedClinicName;
    document.getElementById('summaryDoctor').textContent = selectedDoctorName;
    document.getElementById('summaryDate').textContent = new Date(selectedDate).toLocaleDateString('vi-VN');
    document.getElementById('summarySlot').textContent = getSlotName(slot);
    document.getElementById('appointmentSummary').style.display = 'block';
    document.getElementById('submitBtn').disabled = false;
    
    console.log('Slot selection completed');
}

// Function to select doctor from search results
function selectDoctor(doctorId, doctorName, specialization) {
    console.log('Selecting doctor:', doctorId, doctorName);
    
    // Set doctor in the form
    const doctorSelect = document.getElementById('doctorId');
    
    // Clear existing options and add selected doctor
    doctorSelect.innerHTML = '<option value="">-- Chọn bác sĩ --</option>';
    
    const option = document.createElement('option');
    option.value = doctorId;
    option.textContent = doctorName + ' - ' + specialization;
    option.selected = true;
    doctorSelect.appendChild(option);
    
    // Update selected doctor name for display
    selectedDoctorName = doctorName;
    
    // Show doctor info
    showDoctorInfo(option);
    
    // Load available dates for selected doctor
    loadDoctorAvailableDates(doctorId);
    
    // Scroll to booking form
    document.getElementById('bookingForm').scrollIntoView({ behavior: 'smooth' });
    
    // Show success message
    showTempMessage('Đã chọn bác sĩ: ' + doctorName, 'success');
}

// Function to show temporary message
function showTempMessage(message, type = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 1050; min-width: 300px;';
    alertDiv.innerHTML = `
        <i class="fas fa-check-circle me-2"></i>${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    // Auto remove after 3 seconds
    setTimeout(() => {
        if (alertDiv && alertDiv.parentNode) {
            alertDiv.parentNode.removeChild(alertDiv);
        }
    }, 3000);
}

function getSlotName(slot) {
    const names = {
        'MORNING': '🌅 Sáng (07:00-11:30)',
        'AFTERNOON': '🌤️ Chiều (13:00-17:00)',
        'EVENING': '🌙 Tối (18:00-21:00)'
    };
    return names[slot] || slot;
}

function getDateTime(date, slot) {
    const times = {'MORNING': '09:00', 'AFTERNOON': '14:00', 'EVENING': '19:00'};
    return date + 'T' + (times[slot] || '09:00');
}
</script>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
