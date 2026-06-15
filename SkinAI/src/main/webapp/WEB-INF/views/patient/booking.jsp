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

                    <!-- Report Context (if booking from a report) -->
                    <c:if test="${not empty reportId}">
                        <div class="alert alert-info d-flex align-items-center mb-4" role="alert">
                            <i class="fas fa-file-medical fa-2x me-3 text-info"></i>
                            <div>
                                <strong>Đặt lịch tư vấn cho báo cáo chẩn đoán</strong>
                                <p class="mb-0 small">Mã báo cáo: #${reportId.substring(0, 8)}...</p>
                                <p class="mb-0 small text-muted">Bạn đang đặt lịch hẹn để thảo luận về kết quả chẩn đoán AI với bác sĩ da liễu.</p>
                            </div>
                        </div>
                    </c:if>

                    <!-- Booking Form -->
                    <form action="${pageContext.request.contextPath}/patient/booking" method="post" id="bookingForm">
                        <input type="hidden" name="requestId" value="${requestId}">
                        <c:if test="${not empty reportId}">
                            <input type="hidden" name="reportId" value="${reportId}">
                        </c:if>

                        <!-- Select Clinic -->
                        <div class="mb-4">
                            <label for="clinicId" class="form-label fw-semibold">
                                <i class="fas fa-hospital me-2"></i>Chọn Phòng Khám <span class="text-danger">*</span>
                            </label>
                            <select class="form-select form-select-lg" id="clinicId" name="clinicId" required>
                                <option value="">-- Chọn phòng khám --</option>
                                <c:forEach var="clinic" items="${clinics}">
                                    <option value="${clinic.id}" 
                                            ${selectedClinic != null && selectedClinic.id == clinic.id ? 'selected' : ''}>
                                        ${clinic.clinicName} - ${clinic.address}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Appointment Date & Time -->
                        <div class="mb-4">
                            <label for="appointmentTime" class="form-label fw-semibold">
                                <i class="fas fa-clock me-2"></i>Ngày & Giờ Hẹn <span class="text-danger">*</span>
                            </label>
                            <input type="datetime-local" 
                                   class="form-control form-control-lg" 
                                   id="appointmentTime" 
                                   name="appointmentTime" 
                                   required
                                   min="">
                            <small class="text-muted">Vui lòng chọn ngày và giờ cho cuộc hẹn của bạn</small>
                        </div>

                        <!-- Notes -->
                        <div class="mb-4">
                            <label for="notes" class="form-label fw-semibold">
                                <i class="fas fa-comment-medical me-2"></i>Ghi Chú Bổ Sung (Tùy chọn)
                            </label>
                            <textarea class="form-control" 
                                      id="notes" 
                                      name="notes" 
                                      rows="4" 
                                      placeholder="Vui lòng mô tả các triệu chứng hoặc mối quan tâm của bạn..."></textarea>
                        </div>

                        <!-- Submit Buttons -->
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fas fa-check me-2"></i>Xác Nhận Đặt Lịch
                            </button>
                            <a href="${pageContext.request.contextPath}/patient/reports" class="btn btn-outline-secondary btn-lg">
                                <i class="fas fa-arrow-left me-2"></i>Trở Về Báo Cáo
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Information Card -->
            <div class="card shadow-sm border-0 rounded-4 mt-4 bg-light">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-3"><i class="fas fa-lightbulb text-warning me-2"></i>Thông Tin Đặt Lịch</h5>
                    <ul class="mb-0">
                        <li class="mb-2">Lịch hẹn phụ thuộc vào khả năng sẵn có của phòng khám</li>
                        <li class="mb-2">Bạn sẽ nhận được xác nhận qua email</li>
                        <li class="mb-2">Vui lòng đến trước 15 phút so với giờ đã lên lịch</li>
                        <li>Mang theo CMND và hồ sơ y tế liên quan</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Set minimum date to today
    document.addEventListener('DOMContentLoaded', function() {
        const appointmentInput = document.getElementById('appointmentTime');
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        appointmentInput.min = now.toISOString().slice(0, 16);
    });

    // Form validation
    document.getElementById('bookingForm').addEventListener('submit', function(e) {
        const clinicId = document.getElementById('clinicId').value;
        const appointmentTime = document.getElementById('appointmentTime').value;
        
        if (!clinicId || !appointmentTime) {
            e.preventDefault();
            alert('Vui lòng điền vào tất cả các trường bắt buộc');
            return false;
        }

        // Check if appointment is in the future
        const selectedDate = new Date(appointmentTime);
        const now = new Date();
        if (selectedDate <= now) {
            e.preventDefault();
            alert('Vui lòng chọn ngày và giờ trong tương lai');
            return false;
        }
    });
</script>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />