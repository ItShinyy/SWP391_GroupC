<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

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

                    <!-- Booking Form -->
                    <form action="${pageContext.request.contextPath}/patient/booking" method="post" id="bookingForm">
                        <input type="hidden" name="requestId" value="${requestId}">
                        <c:if test="${not empty reportId}">
                            <input type="hidden" name="reportId" value="${reportId}">
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
                            <input type="date" 
                                   class="form-control form-control-lg" 
                                   id="appointmentDate" 
                                   name="appointmentDate" 
                                   required>
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
            selectedDoctorName = this.options[this.selectedIndex].text;
            showDoctorInfo(this.options[this.selectedIndex]);
            loadDoctorAvailableDates(this.value);
        } else {
            document.getElementById('doctorInfo').style.display = 'none';
            clearDateSelection();
        }
    });
    
    // Date selection - load doctors available on this date
    document.getElementById('appointmentDate').addEventListener('change', function() {
        selectedDate = this.value;
        const clinicId = document.getElementById('clinicId').value;
        if (clinicId && selectedDate) {
            // If no doctor selected, load doctors for this date
            const doctorId = document.getElementById('doctorId').value;
            if (!doctorId) {
                loadDoctorsForDate(clinicId, selectedDate);
            } else {
                // If doctor selected, load slots for selected doctor on this date
                loadSlots(doctorId, selectedDate);
            }
        }
    });
});

function clearDateSelection() {
    document.getElementById('appointmentDate').value = '';
    document.getElementById('slotList').innerHTML = '';
    document.getElementById('appointmentSummary').style.display = 'none';
    document.getElementById('submitBtn').disabled = true;
}

function loadDoctorAvailableDates(doctorId) {
    // Load doctor's schedule to show available dates
    fetch(`${window.location.origin}/SkinAI/api/doctors?action=getDoctorSchedule&doctorId=${doctorId}`)
        .then(r => r.json())
        .then(data => {
            if (data.success && data.schedules) {
                showAvailableDatesInfo(data.schedules);
            }
        })
        .catch(() => {});
}

function showAvailableDatesInfo(schedules) {
    // Group schedules by date and show available dates
    const dates = {};
    schedules.forEach(s => {
        if (s.available > 0) {
            if (!dates[s.date]) dates[s.date] = [];
            dates[s.date].push(s);
        }
    });
    
    // Update date input with available dates (for user reference)
    const dateInput = document.getElementById('appointmentDate');
    const availableDates = Object.keys(dates);
    
    if (availableDates.length > 0) {
        // Add a data attribute to show available dates
        dateInput.title = 'Ngày có lịch: ' + availableDates.map(d => 
            new Date(d).toLocaleDateString('vi-VN')).join(', ');
    }
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
    console.log('clinicId length:', clinicId ? clinicId.length : 'null/undefined');
    
    if (!clinicId || clinicId.trim() === '') {
        console.error('clinicId is empty or null');
        select.innerHTML = '<option value="">Lỗi: không có clinic ID</option>';
        return;
    }
    
    // Simple URL construction without encoding first
    const url = `/SkinAI/api/doctors?action=getByClinic&clinicId=${clinicId}`;
    
    console.log('Final API URL:', url);
    
    fetch(url)
        .then(r => {
            console.log('Response status:', r.status);
            return r.json();
        })
        .then(data => {
            console.log('API response:', data);
            select.innerHTML = '<option value="">-- Chọn bác sĩ --</option>';
            if (data.success && data.doctors) {
                console.log('Number of doctors:', data.doctors.length);
                data.doctors.forEach(d => {
                    console.log('Adding doctor:', d.fullName);
                    const opt = document.createElement('option');
                    opt.value = d.id;
                    opt.textContent = `${d.fullName} - ${d.specialization}`;
                    opt.dataset.bio = d.bio || '';
                    opt.dataset.license = d.licenseNumber || '';
                    select.appendChild(opt);
                });
            } else {
                console.log('No doctors found or API error:', data.message);
                select.innerHTML = '<option value="">Không có bác sĩ nào</option>';
            }
        })
        .catch(err => {
            console.error('API Error:', err);
            select.innerHTML = '<option value="">Lỗi tải danh sách</option>';
        });
}

function showDoctorInfo(option) {
    const div = document.getElementById('doctorInfo');
    let html = '<div class="card border-primary"><div class="card-body">';
    html += '<h6 class="text-primary"><i class="fas fa-user-doctor me-2"></i>' + option.text + '</h6>';
    if (option.dataset.license) {
        html += '<p class="mb-1 small"><strong>Giấy phép:</strong> ' + option.dataset.license + '</p>';
    }
    if (option.dataset.bio) {
        html += '<p class="mb-0 small">' + option.dataset.bio + '</p>';
    }
    html += '</div></div>';
    div.innerHTML = html;
    div.style.display = 'block';
}

function loadSlots(doctorId, date) {
    const list = document.getElementById('slotList');
    list.innerHTML = '<div class="col-12 text-center"><div class="spinner-border"></div><p class="mt-2">Đang tải ca khám...</p></div>';
    
    // If date is provided, load slots for specific date
    let url = `${window.location.origin}/SkinAI/api/doctors?action=getDoctorSchedule&doctorId=${doctorId}`;
    if (date) {
        url += `&date=${date}`;
    }
    
    fetch(url)
        .then(r => r.json())
        .then(data => {
            if (data.success && data.schedules && data.schedules.length > 0) {
                // Filter schedules for specific date if provided
                let filteredSchedules = data.schedules;
                if (date) {
                    filteredSchedules = data.schedules.filter(s => s.date === date);
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
        .catch(() => list.innerHTML = '<div class="col-12"><div class="alert alert-danger">Lỗi tải lịch</div></div>');
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
    document.querySelectorAll('.slot-btn').forEach(b => {
        b.classList.remove('btn-primary');
        b.classList.add('btn-outline-primary');
    });
    
    btn.classList.remove('btn-outline-primary');
    btn.classList.add('btn-primary');
    
    const slot = btn.dataset.slot;
    document.getElementById('slotId').value = btn.dataset.slotId;
    document.getElementById('appointmentTime').value = getDateTime(selectedDate, slot);
    
    document.getElementById('summaryClinic').textContent = selectedClinicName;
    document.getElementById('summaryDoctor').textContent = selectedDoctorName;
    document.getElementById('summaryDate').textContent = new Date(selectedDate).toLocaleDateString('vi-VN');
    document.getElementById('summarySlot').textContent = getSlotName(slot);
    document.getElementById('appointmentSummary').style.display = 'block';
    document.getElementById('submitBtn').disabled = false;
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
    return `${date}T${times[slot] || '09:00'}`;
}
</script>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
