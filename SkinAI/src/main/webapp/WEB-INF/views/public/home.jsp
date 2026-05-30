<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/public-header.jsp" />

<!-- Hero Banner -->
<section class="hero-section text-center d-flex align-items-center" style="background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); min-height: 500px;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <h1 class="display-4 fw-bold mb-4" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Chẩn đoán Bệnh Da liễu AI</h1>
                <p class="lead mb-5 text-muted" style="font-size: 1.25rem;">Hệ thống phân tích hình ảnh ứng dụng Trí tuệ Nhân tạo, hỗ trợ phát hiện sơ bộ các bệnh lý về da trong vài giây, bảo mật và chính xác.</p>
                <a href="${pageContext.request.contextPath}/patient/diagnose" class="btn btn-skin btn-lg fw-bold px-5 py-3 shadow-sm" style="font-size: 1.1rem;">
                    Bắt đầu chẩn đoán ngay <i class="fa-solid fa-arrow-right ms-2"></i>
                </a>
            </div>
        </div>
    </div>
</section>

<!-- Quy trình (How it works) -->
<section class="how-it-works py-5 bg-white">
    <div class="container py-5">
        <div class="text-center mb-5">
            <h2 class="fw-bold mb-3" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Quy trình hoạt động</h2>
            <p class="text-muted">Đơn giản, Nhanh chóng và Hoàn toàn bảo mật</p>
        </div>
        
        <div class="row text-center g-4">
            <!-- Bước 1 -->
            <div class="col-md-3 col-sm-6">
                <div class="card h-100 p-4 border-0 shadow-sm rounded-4 hover-shadow transition">
                    <div class="card-body">
                        <div class="icon-wrapper mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #eff6ff;">
                            <i class="fa-solid fa-camera fa-2x text-primary"></i>
                        </div>
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">1. Tải ảnh lên</h4>
                        <p class="text-muted small mb-0">Chụp rõ nét vùng da đang gặp vấn đề bằng điện thoại hoặc máy ảnh.</p>
                    </div>
                </div>
            </div>
            
            <!-- Bước 2 -->
            <div class="col-md-3 col-sm-6">
                <div class="card h-100 p-4 border-0 shadow-sm rounded-4 hover-shadow transition">
                    <div class="card-body">
                        <div class="icon-wrapper mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #eff6ff;">
                            <i class="fa-solid fa-microchip fa-2x text-primary"></i>
                        </div>
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">2. AI Phân tích</h4>
                        <p class="text-muted small mb-0">Hệ thống xử lý hình ảnh qua mô hình Deep Learning tiên tiến nhất.</p>
                    </div>
                </div>
            </div>
            
            <!-- Bước 3 -->
            <div class="col-md-3 col-sm-6">
                <div class="card h-100 p-4 border-0 shadow-sm rounded-4 hover-shadow transition">
                    <div class="card-body">
                        <div class="icon-wrapper mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #eff6ff;">
                            <i class="fa-solid fa-file-medical fa-2x text-primary"></i>
                        </div>
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">3. Nhận báo cáo</h4>
                        <p class="text-muted small mb-0">Xem kết quả bệnh lý dự đoán, tỷ lệ tin cậy và mức độ rủi ro.</p>
                    </div>
                </div>
            </div>
            
            <!-- Bước 4 -->
            <div class="col-md-3 col-sm-6">
                <div class="card h-100 p-4 border-0 shadow-sm rounded-4 hover-shadow transition">
                    <div class="card-body">
                        <div class="icon-wrapper mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #eff6ff;">
                            <i class="fa-solid fa-hospital-user fa-2x text-primary"></i>
                        </div>
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">4. Khám chuyên khoa</h4>
                        <p class="text-muted small mb-0">Nhận gợi ý và đặt lịch khám tại các phòng khám da liễu gần nhất.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Call to action -->
<section class="cta-section py-5" style="background-color: var(--skin-primary);">
    <div class="container text-center py-4">
        <h2 class="text-white fw-bold mb-4">Bạn có vấn đề về da cần kiểm tra?</h2>
        <a href="${pageContext.request.contextPath}/patient/diagnose" class="btn btn-light btn-lg rounded-pill px-5 fw-bold text-primary">Tải ảnh lên ngay</a>
    </div>
</section>

<style>
    .hover-shadow:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 30px rgba(0,0,0,0.1) !important;
    }
    .transition {
        transition: all 0.3s ease;
    }
</style>

<jsp:include page="/WEB-INF/views/layout/public-footer.jsp" />
