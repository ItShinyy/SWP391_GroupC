<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<!-- Hero Banner -->
<section class="hero-section text-center d-flex align-items-center" style="background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); min-height: 500px;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <h1 class="display-4 fw-bold mb-4" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Chẩn đoán Da liễu AI</h1>
                <p class="lead mb-5 text-muted" style="font-size: 1.25rem;">Hệ thống phân tích hình ảnh sử dụng Trí tuệ Nhân tạo giúp phát hiện các bệnh lý về da trong vài giây, an toàn và chính xác.</p>
                <a href="${pageContext.request.contextPath}/patient/diagnose" class="btn btn-skin btn-lg fw-bold px-5 py-3 shadow-sm" style="font-size: 1.1rem;">
                    Bắt đầu Chẩn đoán <i class="fa-solid fa-arrow-right ms-2"></i>
                </a>
            </div>
        </div>
    </div>
</section>

<!-- Quy trình (How it works) -->
<section class="how-it-works py-5 bg-white">
    <div class="container py-5">
        <div class="text-center mb-5">
            <h2 class="fw-bold mb-3" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">Cách Hoạt Động</h2>
            <p class="text-muted">Đơn giản, Nhanh chóng và Hoàn toàn Bảo mật</p>
        </div>
        
        <div class="row text-center g-4">
            <!-- Bước 1 -->
            <div class="col-md-3 col-sm-6">
                <div class="card h-100 p-4 border-0 shadow-sm rounded-4 hover-shadow transition">
                    <div class="card-body">
                        <div class="icon-wrapper mb-4 d-inline-flex align-items-center justify-content-center rounded-circle" style="width: 80px; height: 80px; background-color: #eff6ff;">
                            <i class="fa-solid fa-camera fa-2x text-primary"></i>
                        </div>
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">1. Tải Ảnh Lên</h4>
                        <p class="text-muted small mb-0">Chụp một bức ảnh rõ nét về tình trạng da của bạn bằng điện thoại hoặc máy ảnh.</p>
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
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">2. AI Phân Tích</h4>
                        <p class="text-muted small mb-0">Hệ thống xử lý hình ảnh của bạn sử dụng mô hình Học Sâu tiên tiến.</p>
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
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">3. Nhận Kết Quả</h4>
                        <p class="text-muted small mb-0">Xem dự đoán bệnh lý, mức độ tự tin của AI và đánh giá mức độ rủi ro.</p>
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
                        <h4 class="fw-bold mb-3" style="color: var(--skin-primary);">4. Khám Chuyên Khoa</h4>
                        <p class="text-muted small mb-0">Nhận đề xuất và đặt lịch khám tại các phòng khám da liễu gần nhất.</p>
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
        <a href="${pageContext.request.contextPath}/patient/diagnose" class="btn btn-light btn-lg rounded-pill px-5 fw-bold text-primary">Tải Ảnh Lên Ngay</a>
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

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
