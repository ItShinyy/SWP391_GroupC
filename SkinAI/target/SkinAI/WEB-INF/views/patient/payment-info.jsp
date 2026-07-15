<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <!-- Header Section -->
            <div class="text-center mb-5">
                <div class="payment-hero-icon mb-4">
                    <i class="fas fa-credit-card fa-5x text-success"></i>
                </div>
                <h1 class="display-5 fw-bold mb-3" style="color: var(--skin-primary);">
                    Thanh Toán Dịch Vụ
                </h1>
                <p class="lead text-muted">
                    Quản lý và thanh toán các hóa đơn y tế của bạn một cách dễ dàng
                </p>
            </div>

            <!-- Payment Process Steps -->
            <div class="row mb-5">
                <div class="col-12">
                    <div class="card border-0 shadow-sm rounded-4">
                        <div class="card-body p-4">
                            <h4 class="fw-bold mb-4 text-center">
                                <i class="fas fa-route me-2 text-primary"></i>
                                Quy Trình Thanh Toán
                            </h4>
                            
                            <div class="row text-center g-4">
                                <div class="col-md-3">
                                    <div class="step-card p-4 rounded-3 bg-light h-100">
                                        <div class="step-number bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 50px; height: 50px;">
                                            1
                                        </div>
                                        <h6 class="fw-bold">Đặt Lịch Khám</h6>
                                        <p class="text-muted small mb-0">
                                            Hoàn tất cuộc hẹn khám với bác sĩ
                                        </p>
                                    </div>
                                </div>
                                
                                <div class="col-md-3">
                                    <div class="step-card p-4 rounded-3 bg-light h-100">
                                        <div class="step-number bg-info text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 50px; height: 50px;">
                                            2
                                        </div>
                                        <h6 class="fw-bold">Nhận Hóa Đơn</h6>
                                        <p class="text-muted small mb-0">
                                            Hệ thống tự động tạo hóa đơn sau khám
                                        </p>
                                    </div>
                                </div>
                                
                                <div class="col-md-3">
                                    <div class="step-card p-4 rounded-3 bg-light h-100">
                                        <div class="step-number bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 50px; height: 50px;">
                                            3
                                        </div>
                                        <h6 class="fw-bold">Chọn Phương Thức</h6>
                                        <p class="text-muted small mb-0">
                                            Thanh toán tại quầy hoặc online
                                        </p>
                                    </div>
                                </div>
                                
                                <div class="col-md-3">
                                    <div class="step-card p-4 rounded-3 bg-light h-100">
                                        <div class="step-number bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 50px; height: 50px;">
                                            4
                                        </div>
                                        <h6 class="fw-bold">Hoàn Thành</h6>
                                        <p class="text-muted small mb-0">
                                            Nhận xác nhận và hóa đơn điện tử
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Payment Methods -->
            <div class="row mb-5">
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm rounded-4 h-100">
                        <div class="card-body p-4 text-center">
                            <div class="payment-method-icon mb-4">
                                <i class="fas fa-cash-register fa-4x text-primary"></i>
                            </div>
                            <h5 class="fw-bold mb-3">Thanh Toán Tại Quầy</h5>
                            <ul class="list-unstyled text-start">
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Thanh toán bằng tiền mặt
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Thanh toán bằng thẻ ATM/Credit
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Nhận hóa đơn ngay tại quầy
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Hỗ trợ trực tiếp từ nhân viên
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm rounded-4 h-100">
                        <div class="card-body p-4 text-center">
                            <div class="payment-method-icon mb-4">
                                <i class="fas fa-mobile-alt fa-4x text-success"></i>
                            </div>
                            <h5 class="fw-bold mb-3">Thanh Toán Online</h5>
                            <ul class="list-unstyled text-start">
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Thanh toán qua VNPay
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Hỗ trợ Internet Banking
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Thanh toán bằng QR Code
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Xác nhận tức thì
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Section -->
            <div class="row">
                <div class="col-12">
                    <div class="card border-0 shadow-lg rounded-4" style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);">
                        <div class="card-body p-5 text-center">
                            <div class="mb-4">
                                <i class="fas fa-info-circle fa-3x text-info"></i>
                            </div>
                            <h4 class="fw-bold mb-3">Cách Truy Cập Thanh Toán</h4>
                            <p class="text-muted mb-4 lead">
                                Để thanh toán hóa đơn, bạn cần có cuộc hẹn đã hoàn thành. 
                                Xem danh sách lịch hẹn và hóa đơn của bạn bên dưới.
                            </p>
                            
                            <div class="d-grid gap-3 d-md-flex justify-content-md-center">
                                <a href="${pageContext.request.contextPath}/patient/appointments" 
                                   class="btn btn-primary btn-lg rounded-pill px-5 fw-bold">
                                    <i class="fas fa-calendar-check me-2"></i>
                                    Xem Lịch Hẹn & Thanh Toán
                                </a>
                                
                                <a href="${pageContext.request.contextPath}/patient/booking" 
                                   class="btn btn-outline-success btn-lg rounded-pill px-5 fw-bold">
                                    <i class="fas fa-plus me-2"></i>
                                    Đặt Lịch Hẹn Mới
                                </a>
                            </div>
                            
                            <div class="mt-4">
                                <small class="text-muted">
                                    <i class="fas fa-question-circle me-1"></i>
                                    Cần hỗ trợ? Liên hệ: <strong>1900-xxxx</strong> hoặc email: <strong>support@skinai.vn</strong>
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.step-card {
    transition: all 0.3s ease;
    border: 2px solid transparent;
}

.step-card:hover {
    transform: translateY(-5px);
    border-color: #e2e8f0;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

.step-number {
    font-weight: bold;
    font-size: 1.2rem;
}

.payment-hero-icon i {
    animation: bounce 2s ease-in-out infinite;
}

@keyframes bounce {
    0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
    40% { transform: translateY(-10px); }
    60% { transform: translateY(-5px); }
}

.payment-method-icon {
    transition: transform 0.3s ease;
}

.card:hover .payment-method-icon {
    transform: scale(1.1);
}
</style>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />