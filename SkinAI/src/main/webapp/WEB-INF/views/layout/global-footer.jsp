<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

</main>
<!-- End Main Content -->

<style>
    /* CSS hiệu ứng tương tác nâng cao cho Footer */
    .footer-link {
        color: #64748b;
        text-decoration: none;
        transition: all 0.3s ease;
        display: inline-block;
    }
    .footer-link:hover {
        color: #198754 !important; /* Màu xanh lá cây đặc trưng của DermAI */
        transform: translateX(4px);
    }
    .social-icon {
        color: #64748b;
        transition: all 0.3s ease;
    }
    .social-icon:hover {
        color: #198754;
        transform: translateY(-3px);
    }
    .disclaimer-box {
        border-left: 4px solid #ffc107;
        background-color: #fffbeb;
        border-radius: 12px;
        padding: 1rem;
        transition: transform 0.3s ease;
    }
    .disclaimer-box:hover {
        transform: translateY(-2px);
    }
</style>

<footer class="bg-white pt-5 pb-4 mt-5 border-top">
    <div class="container">
        <div class="row g-4">
            <!-- Column 1: Brand & Socials -->
            <div class="col-12 col-md-4 mb-4">
                <h3 class="fw-bold m-0" style="color: #198754; font-family: 'Inter', sans-serif;">
                    Derm<span class="text-dark">AI</span>
                </h3>
                <p class="text-muted mt-3 mb-4" style="font-size: 0.9rem; line-height: 1.6;">
                    Nền tảng trí tuệ nhân tạo hỗ trợ chẩn đoán sơ bộ các bệnh lý da liễu qua hình ảnh. Nhanh chóng, an toàn và tiện lợi.
                </p>
                <div class="d-flex gap-3">
                    <a href="#" class="social-icon fs-4"><i class="fa-brands fa-facebook"></i></a>
                    <a href="#" class="social-icon fs-4"><i class="fa-brands fa-twitter"></i></a>
                    <a href="#" class="social-icon fs-4"><i class="fa-brands fa-linkedin"></i></a>
                </div>
            </div>
            
            <!-- Column 2: Quick Links -->
            <div class="col-12 col-md-4 mb-4 px-md-5">
                <h5 class="fw-bold mb-4 text-dark" style="font-size: 1.1rem; letter-spacing: -0.2px;">Liên Kết Nhanh</h5>
                <ul class="list-unstyled m-0">
                    <li class="mb-2">
                        <a href="`${pageContext.request.contextPath}/home" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Trang Chủ
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="`${pageContext.request.contextPath}/patient/diagnose" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Chẩn Đoán AI
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="`${pageContext.request.contextPath}/articles" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Kiến Thức Y Khoa
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="`${pageContext.request.contextPath}/global/clinics" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Danh Bạ Phòng Khám
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Column 3: Medical Disclaimer -->
            <div class="col-12 col-md-4 mb-4">
                <h5 class="fw-bold mb-4 text-warning d-flex align-items-center" style="font-size: 1.1rem; letter-spacing: -0.2px;">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i> Khuyến Cáo Y Tế
                </h5>
                <div class="disclaimer-box text-muted small">
                    Hệ thống DermAI chỉ mang tính chất <strong>tham khảo sơ bộ</strong> dựa trên thuật toán thị giác máy tính. Kết quả AI <strong>không thể thay thế</strong> chẩn đoán lâm sàng chuyên môn được thực hiện bởi Bác sĩ Da liễu có chứng chỉ hành nghề. Vui lòng tham khảo ý kiến chuyên gia y tế nếu bạn gặp các triệu chứng nghiêm trọng.
                </div>
            </div>
        </div>
        
        <hr class="mt-4 mb-4 text-muted" style="opacity: 0.1;">
        
        <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center text-muted small gap-2">
            <div>
                &copy; 2026 DermAI Project - SWP391. Bảo lưu mọi quyền.
            </div>
            <div class="d-flex gap-3">
                <a href="#" class="text-muted text-decoration-none hover-primary">Điều Khoản Dịch Vụ</a>
                <span class="text-light-muted">|</span>
                <a href="#" class="text-muted text-decoration-none hover-primary">Chính Sách Bảo Mật</a>
            </div>
        </div>
    </div>
</footer>

<!-- Bootstrap 5 JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>

