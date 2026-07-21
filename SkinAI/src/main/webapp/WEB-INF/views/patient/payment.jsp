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
                        <i class="fas fa-receipt fa-3x text-success mb-3"></i>
                        <h2 class="fw-bold">Thanh Toán Hóa Đơn</h2>
                        <p class="text-muted">Hoàn tất thanh toán cho dịch vụ khám chữa bệnh</p>
                        
                        <!-- Total Amount Display -->
                        <c:if test="${not empty invoice}">
                            <div class="alert alert-info d-inline-block px-4 py-3 mt-3">
                                <div class="d-flex align-items-center justify-content-center">
                                    <i class="fas fa-money-bill-wave fa-2x text-success me-3"></i>
                                    <div class="text-start">
                                        <div class="small text-muted fw-bold">TỔNG TIỀN CẦN THANH TOÁN</div>
                                        <div class="fs-2 fw-bold text-success">
                                            <fmt:formatNumber value="${invoice.totalAmount}" type="currency" pattern="#,###" />đ
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
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
                            <i class="fas fa-exclamation-circle me-2"></i>${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty invoice}">
                        <!-- Invoice Details -->
                        <div class="card mb-4 border-info">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-file-invoice me-2"></i>Thông Tin Hóa Đơn
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p class="mb-2">
                                            <strong>Mã hóa đơn:</strong> 
                                            <span class="text-muted">#${invoice.id.substring(0, 8)}...</span>
                                        </p>
                                        <p class="mb-2">
                                            <strong>Mô tả:</strong> 
                                            <span class="text-muted">${invoice.description}</span>
                                        </p>
                                        <c:if test="${not empty appointment}">
                                            <p class="mb-2">
                                                <strong>Thời gian hẹn:</strong> 
                                                <span class="text-muted">
                                                    <c:set var="appointmentTimeStr" value="${appointment.appointmentTime.toString()}" />
                                                    <c:set var="dateOnly" value="${appointmentTimeStr.substring(0, 10)}" />
                                                    <c:set var="timeOnly" value="${appointmentTimeStr.substring(11, 16)}" />
                                                    <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                    <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                    <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                    ${day}/${month}/${year} ${timeOnly}
                                                </span>
                                            </p>
                                        </c:if>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="mb-2">
                                            <strong>Trạng thái:</strong>
                                            <c:choose>
                                                <c:when test="${invoice.status eq 'PAID'}">
                                                    <span class="badge bg-success">Đã Thanh Toán</span>
                                                </c:when>
                                                <c:when test="${invoice.status eq 'UNPAID'}">
                                                    <span class="badge bg-warning">Chưa Thanh Toán</span>
                                                </c:when>
                                                <c:when test="${invoice.status eq 'CANCELLED'}">
                                                    <span class="badge bg-secondary">Đã Hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-info">${invoice.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p class="mb-2">
                                            <strong>Tổng tiền:</strong>
                                        </p>
                                        <div class="p-3 bg-success bg-opacity-10 border border-success rounded mb-2">
                                            <div class="text-center">
                                                <div class="fs-1 fw-bold text-success">
                                                    <fmt:formatNumber value="${invoice.totalAmount}" type="currency" 
                                                                    pattern="#,###" />đ
                                                </div>
                                                <small class="text-success fw-semibold">Phí khám bệnh</small>
                                            </div>
                                        </div>
                                        <c:if test="${invoice.paidAt != null}">
                                            <p class="mb-0">
                                                <strong>Đã thanh toán:</strong> 
                                                <span class="text-muted">
                                                    <c:set var="paidAtStr" value="${invoice.paidAt.toString()}" />
                                                    <c:set var="dateOnly" value="${paidAtStr.substring(0, 10)}" />
                                                    <c:set var="timeOnly" value="${paidAtStr.substring(11, 16)}" />
                                                    <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                    <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                    <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                    ${day}/${month}/${year} ${timeOnly}
                                                </span>
                                            </p>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="alert alert-warning mb-4" role="alert">
                            <c:if test="${invoice.status eq 'UNPAID' and paymentRequired}">
                                <div class="mb-2">
                                    <i class="fas fa-clock me-2"></i>Vui lòng chọn một phương thức thanh toán để tiếp tục. Giao dịch sẽ hết hạn sau 3 phút 30 giây.
                                </div>
                            </c:if>
                            <div class="text-danger fw-semibold">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                Lưu ý: Nếu khách hàng đã thanh toán online thành công thì khi hủy lịch hẹn quý khách sẽ không được hoàn lại tiền đã trả.
                            </div>
                        </div>

                        <c:if test="${invoice.status eq 'UNPAID' and not paymentViewOnly}">
                            <!-- Payment Options -->
                            <div class="row g-4">
                                <!-- Offline Payment -->
                                <div class="col-md-6">
                                    <div class="card h-100 border-primary">
                                        <div class="card-header bg-primary text-white text-center">
                                            <h5 class="mb-0">
                                                <i class="fas fa-cash-register me-2"></i>Thanh Toán Tại Quầy
                                            </h5>
                                        </div>
                                        <div class="card-body d-flex flex-column">
                                            <div class="text-center mb-3">
                                                <i class="fas fa-building fa-4x text-primary mb-3"></i>
                                                <h6 class="text-primary">Thanh Toán Trực Tiếp</h6>
                                            </div>                                                                                    
                                            <div class="mt-auto">
                                                <form method="post" action="${pageContext.request.contextPath}/patient/payment" 
                                                      onsubmit="return confirm('Gửi yêu cầu thanh toán tại quầy?\nYêu cầu sẽ chờ lễ tân xác nhận.\nSố tiền: ' + '<fmt:formatNumber value="${invoice.totalAmount}" type="currency" pattern="#,###" />đ');">
                                                    <input type="hidden" name="action" value="pay-offline">
                                                    <input type="hidden" name="invoiceId" value="${invoice.id}">
                                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                                        <i class="fas fa-cash-register me-2"></i>
                                                        Gửi Yêu Cầu Tại Quầy
                                                        <div class="small">(<fmt:formatNumber value="${invoice.totalAmount}" type="currency" pattern="#,###" />đ)</div>
                                                    </button>
                                                </form>
                                                <small class="text-muted d-block mt-2 text-center">
                                                    * Vui lòng đến quầy lễ tân để hoàn tất
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Online Payment -->
                                <div class="col-md-6">
                                    <div class="card h-100 border-success">
                                        <div class="card-header bg-success text-white text-center">
                                            <h5 class="mb-0">
                                                <i class="fas fa-credit-card me-2"></i>Thanh Toán Online
                                            </h5>
                                        </div>
                                        <div class="card-body d-flex flex-column">
                                            <div class="text-center mb-3">
                                                <i class="fas fa-mobile-alt fa-4x text-success mb-3"></i>
                                                <h6 class="text-success">Thanh Toán Điện Tử</h6>
                                            </div>

                                            
                                            <div class="mt-auto">
                                                <form method="post" action="http://localhost:3000/api/invoices/${invoice.id}/payments/vnpay">
                                                    <input type="hidden" name="locale" value="vn">
                                                    <button type="submit" class="btn btn-success btn-lg w-100">
                                                        <i class="fas fa-credit-card me-2"></i>
                                                        Thanh Toán Online
                                                        <div class="small">(<fmt:formatNumber value="${invoice.totalAmount}" type="currency" pattern="#,###" />đ)</div>
                                                    </button>
                                                </form>
                                                <small class="text-muted d-block mt-2 text-center">
                                                    * Chuyển hướng đến VNPay
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${invoice.status eq 'PAID'}">
                            <!-- Payment Completed -->
                            <div class="text-center py-4">
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle fa-3x text-success mb-3"></i>
                                    <h4 class="text-success">Thanh Toán Hoàn Tất!</h4>
                                    <p class="mb-0">Hóa đơn đã được thanh toán thành công.</p>
                                </div>
                            </div>
                        </c:if>

                        <!-- Action Buttons -->
                        <div class="text-center mt-4">
                            <c:if test="${not paymentRequired or invoice.status ne 'UNPAID'}">
                                <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-outline-primary btn-lg me-3">
                                    <i class="fas fa-arrow-left me-2"></i>Về Danh Sách Lịch Hẹn
                                </a>
                            </c:if>
                            <c:if test="${invoice.status eq 'PAID'}">
                                <button class="btn btn-outline-success btn-lg" onclick="window.print()">
                                    <i class="fas fa-print me-2"></i>In Hóa Đơn
                                </button>
                            </c:if>
                        </div>
                    </c:if>

                    <c:if test="${empty invoice}">
                        <!-- No Invoice Found -->
                        <div class="text-center py-5">
                            <i class="fas fa-file-invoice fa-4x text-muted mb-4"></i>
                            <h4 class="text-muted">Không Tìm Thấy Hóa Đơn</h4>
                            <p class="text-muted mb-4">Hóa đơn không tồn tại hoặc bạn không có quyền truy cập.</p>
                            <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-primary btn-lg">
                                <i class="fas fa-arrow-left me-2"></i>Về Danh Sách Lịch Hẹn
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<c:if test="${not empty invoice}">
    <div class="text-center mt-3">
        <a class="small text-muted text-decoration-none" href="${pageContext.request.contextPath}/patient/issue-report?category=PAYMENT">
            <i class="fa-solid fa-bug me-1 text-danger"></i>Gặp vấn đề khi thanh toán? Báo lỗi
        </a>
    </div>
</c:if>

<!-- Mock VNPay Payment Modal (for demo purposes) -->
<c:if test="${param.action eq 'vnpay-mock'}">
<div class="modal fade" id="vnpayModal" tabindex="-1" aria-labelledby="vnpayModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="vnpayModalLabel">
                    <i class="fas fa-credit-card me-2"></i>VNPay - Cổng Thanh Toán
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="text-center mb-4">
                    <img src="${pageContext.request.contextPath}/assets/images/vnpay-logo.png" 
                         alt="VNPay" style="height: 60px;" 
                         onerror="this.style.display='none';">
                    <h6 class="mt-3">Mô Phỏng Thanh Toán VNPay</h6>
                </div>
                
                <div class="card border-info">
                    <div class="card-body">
                        <h6 class="card-title text-info">Thông Tin Thanh Toán</h6>
                        <p class="card-text">
                            <strong>Mã giao dịch:</strong> ${param.txnRef}<br>
                            <strong>Số tiền:</strong> <fmt:formatNumber value="${invoice.totalAmount}" type="currency" pattern="#,###" />đ<br>
                            <strong>Nội dung:</strong> ${invoice.description}
                        </p>
                    </div>
                </div>
                
                <div class="alert alert-warning mt-3">
                    <i class="fas fa-info-circle me-2"></i>
                    Đây là môi trường demo. Chọn kết quả thanh toán bên dưới.
                </div>
            </div>
            <div class="modal-footer">
                <a href="${pageContext.request.contextPath}/patient/payment?action=vnpay-mock&txnRef=${param.txnRef}&result=failed" 
                   class="btn btn-danger">
                    <i class="fas fa-times me-2"></i>Hủy Thanh Toán
                </a>
                <a href="${pageContext.request.contextPath}/patient/payment?action=vnpay-mock&txnRef=${param.txnRef}&result=success" 
                   class="btn btn-success">
                    <i class="fas fa-check me-2"></i>Thanh Toán Thành Công
                </a>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var vnpayModal = new bootstrap.Modal(document.getElementById('vnpayModal'));
    vnpayModal.show();
});
</script>
</c:if>

<style>
@media print {
    .btn, .alert .btn-close, .modal, nav, footer {
        display: none !important;
    }
    
    .card {
        border: 1px solid #000 !important;
        box-shadow: none !important;
    }
    
    .text-success, .text-primary, .text-info {
        color: #000 !important;
    }
}
</style>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
