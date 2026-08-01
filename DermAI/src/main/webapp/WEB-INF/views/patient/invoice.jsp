<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">
                <i class="fas fa-file-invoice me-2 text-primary"></i>Danh Sách Hóa Đơn
            </h1>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-primary">
                    <i class="fas fa-calendar-check me-2"></i>Lịch Hẹn
                </a>
            </div>
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
                        <div class="row text-center g-4">
                            <div class="col-md-3">
                                <div class="d-flex align-items-center justify-content-center">
                                    <i class="fas fa-receipt fa-2x text-info me-3"></i>
                                    <div>
                                        <h6 class="mb-0">Tổng Hóa Đơn</h6>
                                        <strong class="text-info">${totalInvoices}</strong>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <div class="d-flex align-items-center justify-content-center">
                                    <i class="fas fa-check-circle fa-2x text-success me-3"></i>
                                    <div>
                                        <h6 class="mb-0">Thành Công</h6>
                                        <strong class="text-success">
                                            <c:set var="successCount" value="0" />
                                            <c:forEach var="payment" items="${invoiceHistory}">
                                                <c:if test="${payment.paid}">
                                                    <c:set var="successCount" value="${successCount + 1}" />
                                                </c:if>
                                            </c:forEach>
                                            ${successCount}
                                        </strong>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <div class="d-flex align-items-center justify-content-center">
                                    <i class="fas fa-clock fa-2x text-warning me-3"></i>
                                    <div>
                                        <h6 class="mb-0">Chờ Xử Lý</h6>
                                        <strong class="text-warning">
                                            <c:set var="pendingCount" value="0" />
                                            <c:forEach var="payment" items="${invoiceHistory}">
                                                <c:if test="${payment.paymentStatus eq 'PENDING'}">
                                                    <c:set var="pendingCount" value="${pendingCount + 1}" />
                                                </c:if>
                                            </c:forEach>
                                            ${pendingCount}
                                        </strong>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <div class="d-flex align-items-center justify-content-center">
                                    <i class="fas fa-times-circle fa-2x text-danger me-3"></i>
                                    <div>
                                        <h6 class="mb-0">Thất Bại</h6>
                                        <strong class="text-danger">
                                            <c:set var="failedCount" value="0" />
                                            <c:forEach var="payment" items="${invoiceHistory}">
                                                <c:if test="${payment.paymentStatus eq 'FAILED'}">
                                                    <c:set var="failedCount" value="${failedCount + 1}" />
                                                </c:if>
                                            </c:forEach>
                                            ${failedCount}
                                        </strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Invoice History Table -->
        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 12%">Mã Hóa Đơn</th>
                        <th scope="col" style="width: 18%">Phòng Khám</th>
                        <th scope="col" style="width: 15%">Ngày Khám</th>
                        <th scope="col" style="width: 12%">Số Tiền</th>
                        <th scope="col" style="width: 12%">Phương Thức</th>
                        <th scope="col" style="width: 12%">Trạng Thái</th>
                        <th scope="col" style="width: 12%">Ngày Thanh Toán</th>
                        <th scope="col" style="width: 7%" class="text-center">Chi Tiết</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty invoiceHistory}">
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="fas fa-receipt fa-3x mb-3 text-light"></i>
                                    <h5>Chưa Có Hóa Đơn</h5>
                                    <p>Bạn chưa có hóa đơn nào.</p>
                                    <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary mt-2">
                                        <i class="fas fa-plus me-2"></i>Đặt Lịch Hẹn Đầu Tiên
                                    </a>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="payment" items="${invoiceHistory}">
                                <tr>
                                    <td>
                                        <div class="d-flex flex-column">
                                            <span class="uuid-text text-secondary font-monospace small" title="${payment.invoiceId}">
                                                #<c:out value="${empty payment.invoiceId ? payment.paymentId.substring(0, 8) : payment.invoiceId.substring(0, 8)}"/>
                                            </span>
                                            <c:if test="${not empty payment.txnRef}">
                                                <small class="text-muted">
                                                    TXN: ${payment.txnRef.length() > 15 ? payment.txnRef.substring(0, 15).concat('...') : payment.txnRef}
                                                </small>
                                            </c:if>
                                        </div>
                                    </td>
                                    
                                    <td>
                                        <div class="fw-medium">${payment.clinicName}</div>
                                        <small class="text-muted">
                                            <i class="fas fa-file-medical me-1"></i>
                                            #${payment.appointmentId.substring(0, 8)}...
                                        </small>
                                    </td>
                                    
                                    <td>
                                        <c:if test="${not empty payment.appointmentTime}">
                                            <div class="fw-medium">
                                                <c:set var="appointmentTimeStr" value="${payment.appointmentTime.toString()}" />
                                                <c:set var="dateOnly" value="${appointmentTimeStr.substring(0, 10)}" />
                                                <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                ${day}/${month}/${year}
                                            </div>
                                            <small class="text-muted">
                                                <i class="far fa-clock me-1"></i>
                                                <c:set var="timeOnly" value="${appointmentTimeStr.substring(11, 16)}" />
                                                ${timeOnly}
                                            </small>
                                        </c:if>
                                    </td>
                                    
                                    <td>
                                        <div class="fw-bold text-primary">
                                            <fmt:formatNumber value="${payment.amount}" type="currency" pattern="#,###" />đ
                                        </div>
                                        <small class="text-muted">${payment.description}</small>
                                    </td>
                                    
                                    <td>
                                        <c:choose>
                                            <c:when test="${payment.paymentMethod == 'CASH'}">
                                                <span class="badge bg-info px-3 py-2">
                                                    <i class="fas fa-cash-register me-1"></i>Tại Quầy
                                                </span>
                                            </c:when>
                                            <c:when test="${payment.paymentMethod == 'VNPAY'}">
                                                <span class="badge bg-success px-3 py-2">
                                                    <i class="fas fa-credit-card me-1"></i>VNPay
                                                </span>
                                            </c:when>
                                            <c:when test="${payment.paymentMethod == 'BANK_TRANSFER'}">
                                                <span class="badge bg-warning px-3 py-2">
                                                    <i class="fas fa-university me-1"></i>Chuyển Khoản
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-3 py-2">${payment.paymentMethod}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    
                                    <td>
                                        <c:choose>
                                            <c:when test="${payment.paymentStatus == 'SUCCESS' && payment.invoiceStatus == 'PAID'}">
                                                <span class="badge bg-success px-3 py-2">
                                                    <i class="fas fa-check-circle me-1"></i>Thành Công
                                                </span>
                                            </c:when>
                                            <c:when test="${payment.paymentStatus == 'PENDING'}">
                                                <span class="badge bg-warning px-3 py-2">
                                                    <i class="fas fa-clock me-1"></i>Chờ Xử Lý
                                                </span>
                                            </c:when>
                                            <c:when test="${payment.paymentStatus == 'FAILED'}">
                                                <span class="badge bg-danger px-3 py-2">
                                                    <i class="fas fa-times-circle me-1"></i>Thất Bại
                                                </span>
                                            </c:when>
                                            <c:when test="${payment.paymentStatus == 'EXPIRED'}">
                                                <span class="badge bg-secondary px-3 py-2">
                                                    <i class="fas fa-clock me-1"></i>Hết Hạn
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark px-3 py-2">${payment.paymentStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty payment.paidAt}">
                                                <div class="fw-medium">
                                                    <c:set var="paidAtStr" value="${payment.paidAt.toString()}" />
                                                    <c:set var="dateOnly" value="${paidAtStr.substring(0, 10)}" />
                                                    <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                    <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                    <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                    ${day}/${month}/${year}
                                                </div>
                                                <small class="text-muted">
                                                    <c:set var="timeOnly" value="${paidAtStr.substring(11, 16)}" />
                                                    ${timeOnly}
                                                </small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Chưa thanh toán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/patient/payment?action=view&invoiceId=${payment.invoiceId}" 
                                           class="btn btn-sm btn-outline-primary" 
                                           title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
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
                        Trang ${currentPage} / ${totalPages} - Tổng ${totalInvoices} hóa đơn
                    </small>
                </div>
            </nav>
        </c:if>
    </div>
</div>

<style>
.uuid-text {
    font-size: 0.8rem;
}

.table th {
    font-weight: 600;
    font-size: 0.9rem;
    border-bottom: 2px solid #dee2e6;
}

.badge {
    font-size: 0.8rem;
}

.page-title {
    color: #2563eb;
    font-weight: 700;
}

.table-container {
    min-height: 400px;
}

@media (max-width: 768px) {
    .table-responsive {
        font-size: 0.85rem;
    }
    
    .badge {
        font-size: 0.7rem;
        padding: 0.25rem 0.5rem !important;
    }
}
</style>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />