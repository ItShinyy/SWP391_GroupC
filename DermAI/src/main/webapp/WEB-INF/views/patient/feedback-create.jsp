<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-gradient-warning text-white text-center py-4">
                    <h2 class="mb-0">
                        <i class="fas fa-star me-2"></i>Đánh Giá Dịch Vụ
                    </h2>
                    <p class="mb-0 mt-2">Chia sẻ trải nghiệm của bạn để chúng tôi cải thiện dịch vụ</p>
                </div>
                
                <div class="card-body p-5">
                    <!-- Appointment Info -->
                    <div class="alert alert-info mb-4">
                        <h5 class="alert-heading">
                            <i class="fas fa-info-circle me-2"></i>Thông Tin Lịch Hẹn
                        </h5>
                        <div class="row">
                            <div class="col-md-6">
                                <p class="mb-1"><strong>Mã lịch hẹn:</strong> #${appointment.id.substring(0, 8)}...</p>
                                <p class="mb-1"><strong>Bác sĩ:</strong> ${doctor.fullName}</p>
                            </div>
                            <div class="col-md-6">
                                <p class="mb-1"><strong>Thời gian:</strong> 
                                    <c:set var="appointmentTimeStr" value="${appointment.appointmentTime.toString()}" />
                                    <c:set var="dateOnly" value="${appointmentTimeStr.substring(0, 10)}" />
                                    <c:set var="timeOnly" value="${appointmentTimeStr.substring(11, 16)}" />
                                    <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                    <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                    <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                    ${day}/${month}/${year} ${timeOnly}
                                </p>
                                <p class="mb-1"><strong>Trạng thái:</strong> 
                                    <span class="badge bg-success">Đã hoàn thành</span>
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Feedback Form -->
                    <form method="POST" action="${pageContext.request.contextPath}/patient/feedback" class="needs-validation" novalidate>
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="create">
                        <input type="hidden" name="appointmentId" value="${appointment.id}">

                        <!-- Overall Rating -->
                        <div class="mb-4">
                            <label class="form-label fw-bold">
                                <i class="fas fa-star text-warning me-2"></i>Đánh giá tổng thể
                                <span class="text-danger">*</span>
                            </label>
                            <div class="rating-container text-center p-3 bg-light rounded">
                                <div class="star-rating mb-2">
                                    <input type="radio" id="star5" name="rating" value="5" required>
                                    <label for="star5" class="star">&#9733;</label>
                                    <input type="radio" id="star4" name="rating" value="4">
                                    <label for="star4" class="star">&#9733;</label>
                                    <input type="radio" id="star3" name="rating" value="3">
                                    <label for="star3" class="star">&#9733;</label>
                                    <input type="radio" id="star2" name="rating" value="2">
                                    <label for="star2" class="star">&#9733;</label>
                                    <input type="radio" id="star1" name="rating" value="1">
                                    <label for="star1" class="star">&#9733;</label>
                                </div>
                                <div class="rating-text fw-bold text-primary"></div>
                            </div>
                        </div>

                        <!-- Category -->
                        <div class="mb-4">
                            <label for="category" class="form-label fw-bold">
                                <i class="fas fa-tag me-2"></i>Loại đánh giá
                            </label>
                            <select class="form-select" id="category" name="category">
                                <option value="Khen">Khen ngợi dịch vụ</option>
                                <option value="Góp ý">Góp ý cải thiện</option>
                                <option value="Khiếu nại">Khiếu nại vấn đề</option>
                            </select>
                        </div>

                        <!-- Content -->
                        <div class="mb-4">
                            <label for="content" class="form-label fw-bold">
                                <i class="fas fa-comment-dots me-2"></i>Nội dung đánh giá
                                <span class="text-danger">*</span>
                            </label>
                            <textarea class="form-control" id="content" name="content" rows="6" maxlength="1000" required
                                      placeholder="Hãy chia sẻ trải nghiệm chi tiết của bạn về dịch vụ khám chữa bệnh..."></textarea>
                            <div class="form-text">Chia sẻ chi tiết sẽ giúp chúng tôi cải thiện dịch vụ tốt hơn</div>
                        </div>

                        <!-- Submit Buttons -->
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                            <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-outline-secondary btn-lg me-md-2">
                                <i class="fas fa-arrow-left me-2"></i>Quay lại
                            </a>
                            <button type="submit" class="btn btn-warning btn-lg">
                                <i class="fas fa-paper-plane me-2"></i>Gửi đánh giá
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.bg-gradient-warning {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.star-rating {
    direction: rtl;
    font-size: 2rem;
}

.star-rating input[type="radio"] {
    display: none;
}

.star-rating label {
    color: #ddd;
    cursor: pointer;
    transition: color 0.3s ease-in-out;
}

.star-rating label:hover,
.star-rating label:hover ~ label,
.star-rating input[type="radio"]:checked ~ label {
    color: #fbbf24;
}

.card {
    transition: transform 0.2s ease-in-out;
}

.form-control:focus, .form-select:focus {
    border-color: #f59e0b;
    box-shadow: 0 0 0 0.2rem rgba(245, 158, 11, 0.25);
}

@media (max-width: 768px) {
    .card-body {
        padding: 2rem !important;
    }
    
    .star-rating {
        font-size: 1.5rem;
    }
}
</style>

<script>
// Star rating functionality
document.addEventListener('DOMContentLoaded', function() {
    const starInputs = document.querySelectorAll('input[name="rating"]');
    const ratingText = document.querySelector('.rating-text');
    
    const ratingDescriptions = {
        1: 'Rất không hài lòng',
        2: 'Không hài lòng', 
        3: 'Bình thường',
        4: 'Hài lòng',
        5: 'Rất hài lòng'
    };
    
    starInputs.forEach(input => {
        input.addEventListener('change', function() {
            if (this.checked) {
                ratingText.textContent = ratingDescriptions[this.value];
                ratingText.className = 'rating-text fw-bold ' + 
                    (this.value >= 4 ? 'text-success' : 
                     this.value >= 3 ? 'text-warning' : 'text-danger');
            }
        });
    });

    // Form validation
    const form = document.querySelector('.needs-validation');
    form.addEventListener('submit', function(event) {
        if (!form.checkValidity()) {
            event.preventDefault();
            event.stopPropagation();
        }
        
        const ratingSelected = document.querySelector('input[name="rating"]:checked');
        if (!ratingSelected) {
            event.preventDefault();
            alert('Vui lòng chọn đánh giá từ 1 đến 5 sao');
            return;
        }
        
        form.classList.add('was-validated');
    });
});
</script>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
