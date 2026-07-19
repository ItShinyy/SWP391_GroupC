<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="bg-light py-5">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-lg-8 col-md-10">
                
                <!-- Back Button -->
                <a href="${pageContext.request.contextPath}/global/clinics" class="btn btn-link text-decoration-none text-muted mb-4 d-inline-flex align-items-center gap-2 ps-0">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách phòng khám
                </a>

                <div class="card border-0 shadow-lg rounded-4 overflow-hidden">
                    <div class="card-header border-0 text-white p-4 d-flex align-items-center justify-content-between" style="background: linear-gradient(135deg, #198754 0%, #146c43 100%);">
                        <div>
                            <h3 class="fw-bold mb-1"><i class="fa-regular fa-calendar-plus me-2"></i>Đặt Lịch Hẹn Khám</h3>
                            <p class="mb-0 text-white-50 small">Vui lòng điền đầy đủ thông tin để tiến hành hẹn khám chuyên khoa</p>
                        </div>
                        <i class="fa-solid fa-hospital fa-3x opacity-25"></i>
                    </div>
                    
                    <div class="card-body p-4 p-lg-5">
                        
                        <!-- Error/Success Messages -->
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger alert-dismissible fade show rounded-3" role="alert">
                                <i class="fa-solid fa-circle-exclamation me-2"></i> ${errorMessage}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty successMessage}">
                            <div class="alert alert-success alert-dismissible fade show rounded-3" role="alert">
                                <i class="fa-solid fa-circle-check me-2"></i> ${successMessage}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/patient/booking" method="post" id="bookingForm" class="needs-validation" novalidate>
                            <input type="hidden" name="requestId" value="${requestId}">
                            
                            <!-- Clinic Selection Details -->
                            <div class="mb-4 p-3 bg-light rounded-3 border-start border-4 border-success">
                                <h5 class="fw-bold text-success mb-2"><i class="fa-solid fa-hospital-user me-2"></i>Phòng khám đã chọn</h5>
                                <c:choose>
                                    <c:when test="${not empty selectedClinic}">
                                        <input type="hidden" name="clinicId" value="${selectedClinic.id}">
                                        <h6 class="fw-bold text-dark mb-1">${selectedClinic.clinicName}</h6>
                                        <p class="text-muted small mb-0"><i class="fa-solid fa-location-dot me-1 text-danger"></i> ${selectedClinic.address}</p>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="mb-3">
                                            <label for="clinicIdSelect" class="form-label fw-bold">Chọn phòng khám</label>
                                            <select class="form-select rounded-3" name="clinicId" id="clinicIdSelect" required>
                                                <option value="" disabled selected>-- Chọn phòng khám gần nhất --</option>
                                                <c:forEach var="clinic" items="${clinics}">
                                                    <option value="${clinic.id}" ${param.clinicId == clinic.id ? 'selected' : ''}>${clinic.clinicName} (${clinic.address})</option>
                                                </c:forEach>
                                            </select>
                                            <div class="invalid-feedback">Vui lòng chọn một phòng khám.</div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Appointment Time selection -->
                            <div class="row g-3 mb-4">
                                <div class="col-md-12">
                                    <label for="appointmentTime" class="form-label fw-bold text-dark"><i class="fa-regular fa-clock me-1 text-muted"></i> Ngày & Giờ hẹn khám</label>
                                    <input type="datetime-local" class="form-control rounded-3" id="appointmentTime" name="appointmentTime" required>
                                    <div class="invalid-feedback">Vui lòng chọn ngày giờ đặt khám.</div>
                                    <div class="form-text text-muted small">Khuyên dùng đặt trước ít nhất 1 ngày để đảm bảo bác sĩ trống lịch.</div>
                                </div>
                            </div>

                            <!-- Booking Type Selection (Self vs Relative) -->
                            <div class="mb-4">
                                <label class="form-label fw-bold text-dark"><i class="fa-solid fa-users me-1 text-muted"></i> Đối tượng đăng ký khám</label>
                                <div class="d-flex gap-4 mt-2">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="patientType" id="patientSelf" value="self" checked>
                                        <label class="form-check-label fw-semibold" for="patientSelf">
                                            Đặt lịch cho bản thân
                                        </label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="patientType" id="patientRelative" value="relative">
                                        <label class="form-check-label fw-semibold" for="patientRelative">
                                            Đặt lịch cho người thân
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- Relative Information Fields (Toggleable) -->
                            <div id="relativeInfoSection" class="p-4 bg-light rounded-4 border mb-4 d-none">
                                <h5 class="fw-bold text-dark mb-3"><i class="fa-regular fa-id-card me-2 text-primary"></i>Thông tin người bệnh (Người thân)</h5>
                                
                                <div class="row g-3">
                                    <div class="col-md-12">
                                        <label for="patientName" class="form-label fw-bold">Họ và Tên <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control rounded-3" id="patientName" name="patientName" placeholder="Nhập đầy đủ họ và tên người bệnh">
                                        <div class="invalid-feedback">Vui lòng nhập họ tên người bệnh.</div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label for="patientDob" class="form-label fw-bold">Ngày sinh <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control rounded-3" id="patientDob" name="patientDob">
                                        <div class="invalid-feedback">Vui lòng chọn ngày sinh.</div>
                                    </div>

                                    <div class="col-md-6">
                                        <label for="patientGender" class="form-label fw-bold">Giới tính <span class="text-danger">*</span></label>
                                        <select class="form-select rounded-3" id="patientGender" name="patientGender">
                                            <option value="" disabled selected>-- Chọn giới tính --</option>
                                            <option value="MALE">Nam (Male)</option>
                                            <option value="FEMALE">Nữ (Female)</option>
                                            <option value="OTHER">Khác (Other)</option>
                                        </select>
                                        <div class="invalid-feedback">Vui lòng chọn giới tính.</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Notes -->
                            <div class="mb-4">
                                <label for="notes" class="form-label fw-bold text-dark"><i class="fa-regular fa-comment-dots me-1 text-muted"></i> Lý do khám / Ghi chú triệu chứng</label>
                                <textarea class="form-control rounded-3" id="notes" name="notes" rows="4" placeholder="Nhập tóm tắt triệu chứng da liễu của bạn (ví dụ: ngứa đỏ vùng cổ, rát sau khi bôi kem dưỡng...)"></textarea>
                            </div>

                            <!-- Action buttons -->
                            <div class="d-grid mt-4">
                                <button type="submit" class="btn btn-success btn-lg rounded-pill py-3 fw-bold shadow-sm transition hover-scale">
                                    Xác nhận Đặt Lịch Hẹn <i class="fa-solid fa-circle-check ms-2"></i>
                                </button>
                            </div>

                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Logic hiển thị / ẩn form thông tin người thân
    const radioSelf = document.getElementById('patientSelf');
    const radioRelative = document.getElementById('patientRelative');
    const relativeSection = document.getElementById('relativeInfoSection');
    
    const inputName = document.getElementById('patientName');
    const inputDob = document.getElementById('patientDob');
    const selectGender = document.getElementById('patientGender');

    function toggleRelativeFields() {
        if (radioRelative.checked) {
            relativeSection.classList.remove('d-none');
            inputName.setAttribute('required', 'required');
            inputDob.setAttribute('required', 'required');
            selectGender.setAttribute('required', 'required');
        } else {
            relativeSection.classList.add('d-none');
            inputName.removeAttribute('required');
            inputDob.removeAttribute('required');
            selectGender.removeAttribute('required');
        }
    }

    radioSelf.addEventListener('change', toggleRelativeFields);
    radioRelative.addEventListener('change', toggleRelativeFields);

    // Bootstrap Form Validation Client Side
    (function () {
        'use strict'
        var forms = document.querySelectorAll('.needs-validation')
        Array.prototype.slice.call(forms)
            .forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    if (!form.checkValidity()) {
                        event.preventDefault()
                        event.stopPropagation()
                    }
                    form.classList.add('was-validated')
                }, false)
            })
    })()

    // Hạn chế chọn thời gian cũ (Past Dates)
    const timeInput = document.getElementById('appointmentTime');
    const now = new Date();
    const tzOffset = now.getTimezoneOffset() * 60000; 
    const localISOTime = (new Date(now - tzOffset)).toISOString().slice(0, 16);
    timeInput.min = localISOTime;
</script>

<style>
    .transition {
        transition: all 0.3s ease;
    }
    .hover-scale:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(25, 135, 84, 0.3) !important;
    }
</style>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
