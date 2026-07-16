<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<div class="container-fluid py-4 px-4">
    <!-- Page Title -->
    <div class="mb-4">
        <h4 class="fw-bold mb-1">
            <i class="fa-solid fa-book-medical me-2 text-primary"></i>Phác Đồ & Hướng Dẫn Y Khoa Lâm Sàng
        </h4>
        <p class="text-muted small mb-0">Tài liệu tham khảo chuyên môn nội bộ về quy trình điều trị và chẩn đoán các bệnh lý da liễu.</p>
    </div>

    <!-- Guidelines Grid -->
    <div class="row g-4">
        <!-- Card 1 -->
        <div class="col-md-6 col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header bg-primary text-white py-3 px-4 rounded-top-4 border-0">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-virus-slash me-2"></i>Phác đồ điều trị Mụn trứng cá</h6>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted small mb-3">Quy trình chuẩn điều trị các thể mụn trứng cá (từ nhẹ đến nặng) áp dụng tại phòng khám SkinAI.</p>
                    
                    <h6 class="fw-bold text-primary mb-2" style="font-size: 0.85rem;">1. Thể nhẹ (Mụn ẩn, mụn đầu đen):</h6>
                    <ul class="text-muted small ps-3 mb-3" style="line-height: 1.6;">
                        <li>Sử dụng sữa rửa mặt dịu nhẹ (pH 5.5) ngày 2 lần.</li>
                        <li>Tẩy tế bào chết hóa học chứa BHA 2% (Salicylic Acid).</li>
                        <li>Thoa Retinoid thế hệ mới (Adapalene 0.1%) vào buổi tối.</li>
                    </ul>

                    <h6 class="fw-bold text-primary mb-2" style="font-size: 0.85rem;">2. Thể trung bình - nặng (Mụn bọc, mụn viêm):</h6>
                    <ul class="text-muted small ps-3 mb-0" style="line-height: 1.6;">
                        <li>Kết hợp bôi Benzoyl Peroxide 2.5% - 5% chấm mụn sáng.</li>
                        <li>Kháng sinh bôi (Clindamycin) phối hợp trị liệu.</li>
                        <li>Chỉ định kháng sinh uống nhóm Cycline (Doxycycline 100mg/ngày) nếu cần.</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Card 2 -->
        <div class="col-md-6 col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header text-white py-3 px-4 rounded-top-4 border-0" style="background: linear-gradient(135deg, #1e3a8a, #3b82f6);">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-magnifying-glass-chart me-2"></i>Chẩn đoán Ung thư hắc tố (Melanoma)</h6>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted small mb-3">Quy trình sàng lọc sớm các tổn thương sắc tố nghi ngờ ác tính sử dụng phương pháp ABCDE.</p>
                    
                    <h6 class="fw-bold text-primary mb-2" style="font-size: 0.85rem;">Quy tắc lâm sàng ABCDE:</h6>
                    <ul class="text-muted small ps-3 mb-3" style="line-height: 1.6;">
                        <li><strong>A (Asymmetry):</strong> Nốt ruồi mất tính đối xứng.</li>
                        <li><strong>B (Border):</strong> Viền nham nhở, không đều hoặc mờ nhạt.</li>
                        <li><strong>C (Color):</strong> Màu sắc không đồng nhất (nhiều màu nâu, đen, đỏ).</li>
                        <li><strong>D (Diameter):</strong> Đường kính tổn thương lớn hơn 6mm.</li>
                        <li><strong>E (Evolving):</strong> Thay đổi nhanh về kích thước, hình dạng hoặc chảy máu.</li>
                    </ul>

                    <h6 class="fw-bold text-primary mb-2" style="font-size: 0.85rem;">Chỉ định cận lâm sàng:</h6>
                    <p class="text-muted small mb-0" style="line-height: 1.6;">
                        Chỉ định soi da chuyên sâu (Dermoscopy). Nếu chỉ số rủi ro cao, bắt buộc chỉ định <strong>Sinh thiết da (Skin Biopsy)</strong> để làm giải phẫu bệnh lý - đây là tiêu chuẩn vàng chẩn đoán xác định.
                    </p>
                </div>
            </div>
        </div>

        <!-- Card 3 -->
        <div class="col-md-6 col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header bg-success text-white py-3 px-4 rounded-top-4 border-0">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-hand-holding-medical me-2"></i>Chăm sóc da sau Sinh thiết</h6>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted small mb-3">Hướng dẫn dặn dò bệnh nhân chăm sóc vết thương sau khi làm thủ thuật sinh thiết lấy mẫu tế bào.</p>
                    
                    <h6 class="fw-bold text-success mb-2" style="font-size: 0.85rem;">1. Chăm sóc trong 24 giờ đầu:</h6>
                    <ul class="text-muted small ps-3 mb-3" style="line-height: 1.6;">
                        <li>Giữ nguyên băng vô khuẩn ép nhẹ trên vết thương.</li>
                        <li>Tuyệt đối không để nước dính vào vùng da sinh thiết.</li>
                        <li>Uống thuốc giảm đau thông thường (Paracetamol) nếu ê ẩm nhẹ.</li>
                    </ul>

                    <h6 class="fw-bold text-success mb-2" style="font-size: 0.85rem;">2. Vệ sinh vết thương hàng ngày:</h6>
                    <ul class="text-muted small ps-3 mb-0" style="line-height: 1.6;">
                        <li>Rửa vết thương nhẹ nhàng bằng nước muối sinh lý (NaCl 0.9%).</li>
                        <li>Thoa một lớp mỏng thuốc mỡ kháng sinh hoặc Vaseline để giữ vết thương ẩm, mau lành sẹo.</li>
                        <li>Tránh gãi, chà xát mạnh hoặc tự ý cạy vảy da bong.</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
