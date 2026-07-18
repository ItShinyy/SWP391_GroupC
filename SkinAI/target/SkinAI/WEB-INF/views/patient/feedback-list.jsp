<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">
                <i class="fas fa-star me-2 text-warning"></i>Đánh Giá Của Tôi
            </h1>
            <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-primary">
                <i class="fas fa-calendar-check me-2"></i>Về Lịch Hẹn
            </a>
        </div>
        
        <!-- Success/Error Messages -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-triangle-exclamation me-2"></i><strong>Lỗi:</strong> ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Summary Statistics -->
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card bg-light border-0">
                    <div class="card-body py-3">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-chart-line fa-2x text-warning me-3"></i>
                            <div>
                                <h6 class="mb-0">Tổng số đánh giá: <strong>${totalFeedbacks}</strong></h6>
                                <small class="text-muted">Cảm ơn bạn đã chia sẻ trải nghiệm</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Feedback List -->
        <div class="row">
            <c:choose>
                <c:when test="${empty feedbacks}">
                    <div class="col-12">
                        <div class="text-center py-5 text-muted">
                            <i class="fas fa-star fa-3x mb-3 text-light"></i>
                            <h5>Chưa Có Đánh Giá</h5>
                            <p>Bạn chưa đánh giá lịch hẹn nào. Hãy hoàn thành lịch hẹn và chia sẻ trải nghiệm của bạn!</p>
                            <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-primary mt-2">
                                <i class="fas fa-calendar-check me-2"></i>Xem Lịch Hẹn
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="feedback" items="${feedbacks}">
                        <div class="col-md-6 mb-4">
                            <div class="card h-100 border-0 shadow-sm">
                                <div class="card-header bg-gradient-primary text-white">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6 class="mb-0">
                                                <i class="fas fa-calendar-check me-2"></i>
                                                Lịch hẹn #${feedback.appointmentId.substring(0, 8)}...
                                            </h6>
                                        </div>
                                        <div class="d-flex align-items-center">
                                            <!-- Star Rating -->
                                            <c:forEach begin="1" end="5" var="i">
                                                <i class="fas fa-star ${i <= feedback.rating ? 'text-warning' : 'text-muted'}"></i>
                                            </c:forEach>
                                            <span class="ms-2 fw-bold">${feedback.rating}/5</span>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="card-body">
                                    <!-- Rating Description -->
                                    <div class="mb-3">
                                        <span class="badge ${feedback.rating >= 4 ? 'bg-success' : feedback.rating >= 3 ? 'bg-warning' : 'bg-danger'} px-3 py-2">
                                            ${feedback.ratingDescription}
                                        </span>
                                        <%-- Anonymous badge removed - not in Feedback model 
                                        <c:if test="${feedback.anonymous}">
                                            <span class="badge bg-secondary ms-1">Ẩn danh</span>
                                        </c:if>
                                        --%>
                                    </div>

                                    <!-- Comment -->
                                    <c:if test="${not empty feedback.content}">
                                        <div class="mb-3">
                                            <h6 class="fw-bold text-primary">
                                                <i class="fas fa-comment-dots me-2"></i>Nội dung:
                                            </h6>
                                            <p class="text-muted mb-0">"${feedback.content}"</p>
                                        </div>
                                    </c:if>

                                    <!-- Category -->
                                    <c:if test="${not empty feedback.category}">
                                        <div class="mb-3">
                                            <span class="badge bg-info px-3 py-2">
                                                <i class="fas fa-tag me-1"></i>${feedback.category}
                                            </span>
                                        </div>
                                    </c:if>

                                    <!-- Admin Reply -->
                                    <c:if test="${feedback.hasAdminReply()}">
                                        <div class="mb-3">
                                            <div class="alert alert-info">
                                                <h6 class="fw-bold text-info">
                                                    <i class="fas fa-reply me-2"></i>Phản hồi từ Admin:
                                                </h6>
                                                <p class="mb-0">"${feedback.adminReply}"</p>
                                                <c:if test="${feedback.repliedAt != null}">
                                                    <small class="text-muted d-block mt-2">
                                                        <c:set var="repliedAtStr" value="${feedback.repliedAt.toString()}" />
                                                        <c:set var="dateOnly" value="${repliedAtStr.substring(0, 10)}" />
                                                        <c:set var="timeOnly" value="${repliedAtStr.substring(11, 16)}" />
                                                        <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                        <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                        <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                        Phản hồi lúc: ${day}/${month}/${year} ${timeOnly}
                                                    </small>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="card-footer bg-light">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <small class="text-muted">
                                            <i class="fas fa-calendar me-1"></i>
                                            <c:set var="createdAtStr" value="${feedback.createdAt.toString()}" />
                                            <c:set var="dateOnly" value="${createdAtStr.substring(0, 10)}" />
                                            <c:set var="timeOnly" value="${createdAtStr.substring(11, 16)}" />
                                            <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                            <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                            <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                            ${day}/${month}/${year} ${timeOnly}
                                        </small>
                                        <a href="${pageContext.request.contextPath}/patient/feedback?action=edit&id=${feedback.id}" 
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-edit me-1"></i>Chỉnh sửa
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav aria-label="Pagination" class="mt-4">
                <ul class="pagination justify-content-center">
                    <!-- Previous Page -->
                    <c:if test="${currentPage > 1}">
                        <li class="page-item">
                            <a class="page-link" href="?page=${currentPage - 1}" aria-label="Previous">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>
                    </c:if>

                    <!-- Page Numbers -->
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <li class="page-item active">
                                    <span class="page-link">${i}</span>
                                </li>
                            </c:when>
                            <c:otherwise>
                                <li class="page-item">
                                    <a class="page-link" href="?page=${i}">${i}</a>
                                </li>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <!-- Next Page -->
                    <c:if test="${currentPage < totalPages}">
                        <li class="page-item">
                            <a class="page-link" href="?page=${currentPage + 1}" aria-label="Next">
                                <span aria-hidden="true">&raquo;</span>
                            </a>
                        </li>
                    </c:if>
                </ul>
                
                <!-- Page Info -->
                <div class="text-center text-muted mt-2">
                    <small>
                        Trang ${currentPage} / ${totalPages} - Tổng ${totalFeedbacks} đánh giá
                    </small>
                </div>
            </nav>
        </c:if>
    </div>
</div>

<style>
.page-title {
    color: #f59e0b;
    font-weight: 700;
}

.bg-gradient-primary {
    background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
}

.card {
    transition: transform 0.2s ease-in-out;
}

.card:hover {
    transform: translateY(-2px);
}

.badge {
    font-size: 0.8rem;
}

.table-container {
    min-height: 400px;
}

@media (max-width: 768px) {
    .row .col-md-6 {
        margin-bottom: 1rem;
    }
    
    .badge {
        font-size: 0.7rem;
        padding: 0.25rem 0.5rem !important;
    }
}
</style>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />