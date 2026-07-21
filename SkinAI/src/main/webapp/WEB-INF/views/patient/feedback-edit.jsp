<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-gradient-info text-white text-center py-4">
                    <h2 class="mb-0">
                        <i class="fas fa-edit me-2"></i>Chỉnh Sửa Đánh Giá
                    </h2>
                    <p class="mb-0 mt-2">Cập nhật đánh giá của bạn về dịch vụ</p>
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
                                <c:if test="${doctor != null}">
                                    <p class="mb-1"><strong>Bác sĩ:</strong> ${doctor.fullName}</p>
                                </c:if>
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

                    <!-- Current Feedback Info -->
                    <div class="alert alert-warning mb-4">
                        <h6><i class="fas fa-clock me-2"></i>Đánh giá hiện tại</h6>
                        <p class="mb-1"><strong>Ngày tạo:</strong> 
                            <c:set var="createdTimeStr" value="${feedback.createdAt.toString()}" />
                            <c:set var="createdDateOnly" value="${createdTimeStr.substring(0, 10)}" />
                            <c:set var="createdTimeOnly" value="${createdTimeStr.substring(11, 16)}" />
                            <c:set var="createdYear" value="${createdDateOnly.substring(0, 4)}" />
                            <c:set var="createdMonth" value="${createdDateOnly.substring(5, 7)}" />
                            <c:set var="createdDay" value="${createdDateOnly.substring(8, 10)}" />
                            ${createdDay}/${createdMonth}/${createdYear} ${createdTimeOnly}
                        </p>
                        <p class="mb-1"><strong>Đánh giá:</strong> 
                            <c:forEach begin="1" end="5" var="i">
                                <i class="fas fa-star ${i <= feedback.rating ? 'text-warning' : 'text-muted'}"></i>
                            </c:forEach>
                            (${feedback.rating}/5 - ${feedback.ratingDescription})
                        </p>
                    </div>

                    <!-- Edit Feedback Form -->
                    <form method="POST" action="${pageContext.request.contextPath}/patient/feedback" class="needs-validation" novalidate>
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="${feedback.id}">

                        <!-- Overall Rating -->
                        <div class="mb-4">
                            <label class="form-label fw-bold">
                                <i class="fas fa-star text-warning me-2"></i>Đánh giá tổng thể
                                <span class="text-danger">*</span>
                            </label>
                            <div class="rating-container text-center p-3 bg-light rounded">
                                <div class="star-rating mb-2">
                                    <input type="radio" id="star5" name="rating" value="5" ${feedback.rating == 5 ? 'checked' : ''} required>
                                    <label for="star5" class="star">&#9733;</label>
                                    <input type="radio" id="star4" name="rating" value="4" ${feedback.rating == 4 ? 'checked' : ''}>
                                    <label for="star4" class="star">&#9733;</label>
                                    <input type="radio" id="star3" name="rating" value="3" ${feedback.rating == 3 ? 'checked' : ''}>
                                    <label for="star3" class="star">&#9733;</label>
                                    <input type="radio" id="star2" name="rating" value="2" ${feedback.rating == 2 ? 'checked' : ''}>
                                    <label for="star2" class="star">&#9733;</label>
                                    <input type="radio" id="star1" name="rating" value="1" ${feedback.rating == 1 ? 'checked' : ''}>
                                    <label for="star1" class="star">&#9733;</label>
                                </div>
                                <div class="rating-text fw-bold text-primary">${feedback.ratingDescription}</div>
                            </div>
                        </div>

                        <!-- Category -->
                        <div class="mb-4">
                            <label for="category" class="form-label fw-bold">
                                <i class="fas fa-tag me-2"></i>Loại đánh giá
                            </label>
                            <select class="form-select" id="category" name="category">
                                <option value="Khen" ${feedback.category == 'Khen' ? 'selected' : ''}>Khen ngợi dịch vụ</option>
                                <option value="Góp ý" ${feedback.category == 'Góp ý' ? 'selected' : ''}>Góp ý cải thiện</option>
                                <option value="Khiếu nại" ${feedback.category == 'Khiếu nại' ? 'selected' : ''}>Khiếu nại vấn đề</option>
                            </select>
                        </div>

                        <!-- Content -->
                        <div class="mb-4">
                            <label for="content" class="form-label fw-bold">
                                <i class="fas fa-comment-dots me-2"></i>Nội dung đánh giá
                                <span class="text-danger">*</span>
                            </label>
                            <textarea class="form-control" id="content" name="content" rows="6" maxlength="1000" required
                                      placeholder="Hãy chia sẻ trải nghiệm chi tiết của bạn về dịch vụ khám chữa bệnh..."><c:out value="${feedback.content}" /></textarea>
                            <div class="form-text">Chia sẻ chi tiết sẽ giúp chúng tôi cải thiện dịch vụ tốt hơn</div>
                        </div>

                        <!-- Admin Reply (if exists) -->
                        <c:if test="${feedback.hasAdminReply()}">
                            <div class="mb-4">
                                <label class="form-label fw-bold text-success">
                                    <i class="fas fa-reply me-2"></i>Phản hồi từ quản trị
                                </label>
                                <div class="alert alert-success">
                                    <p class="mb-1"><c:out value="${feedback.adminReply}" /></p>
                                    <c:if test="${feedback.repliedAt != null}">
                                        <small class="text-muted">
                                            <i class="fas fa-clock me-1"></i>
                                            <c:set var="repliedTimeStr" value="${feedback.repliedAt.toString()}" />
                                            <c:set var="repliedDateOnly" value="${repliedTimeStr.substring(0, 10)}" />
                                            <c:set var="repliedTimeOnly" value="${repliedTimeStr.substring(11, 16)}" />
                                            <c:set var="repliedYear" value="${repliedDateOnly.substring(0, 4)}" />
                                            <c:set var="repliedMonth" value="${repliedDateOnly.substring(5, 7)}" />
                                            <c:set var="repliedDay" value="${repliedDateOnly.substring(8, 10)}" />
                                            ${repliedDay}/${repliedMonth}/${repliedYear} ${repliedTimeOnly}
                                        </small>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>

                        <!-- Submit Buttons -->
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                            <a href="${pageContext.request.contextPath}/patient/feedback" class="btn btn-outline-secondary btn-lg me-md-2">
                                <i class="fas fa-arrow-left me-2"></i>Quay lại
                            </a>
                            <button type="submit" class="btn btn-info btn-lg">
                                <i class="fas fa-save me-2"></i>Cập nhật đánh giá
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.bg-gradient-info {
    background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
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
    border-color: #0ea5e9;
    box-shadow: 0 0 0 0.2rem rgba(14, 165, 233, 0.25);
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

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
