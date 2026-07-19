<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<div class="container-fluid py-4 px-4">
    <!-- Page Title -->
    <div class="mb-4">
        <h4 class="fw-bold mb-1" style="color: #1e293b;">
            <i class="fa-solid fa-book-medical me-2 text-success"></i>Cẩm Nang & Phác Đồ Y Khoa Lâm Sàng Rút Gọn
        </h4>
        <p class="text-muted small mb-0">Tài liệu tra cứu nhanh, đơn giản, dễ đọc dành cho bác sĩ phòng khám.</p>
    </div>

    <!-- Guidelines Grid -->
    <div class="row g-4">
        
        <!-- Card 1: Sốc phản vệ -->
        <div class="col-md-6 col-lg-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header bg-danger text-white py-3 px-4 rounded-top-4 border-0">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-triangle-exclamation me-2"></i>Quy Trình Cấp Cứu Sốc Phản Vệ (Rút Gọn)</h6>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted small mb-3">Xử trí khẩn cấp ngay khi phát hiện bệnh nhân có dấu hiệu sốc dị ứng (sau tiêm, bôi hoặc uống thuốc):</p>
                    
                    <div class="d-flex mb-3 align-items-start">
                        <div class="badge bg-danger rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">1</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-danger">Ngừng ngay tác nhân gây dị ứng</h6>
                            <p class="text-muted small mb-0">Dừng bôi thuốc, tiêm truyền hoặc rửa sạch vùng da tổn thương dính thuốc dị nguyên.</p>
                        </div>
                    </div>

                    <div class="d-flex mb-3 align-items-start">
                        <div class="badge bg-danger rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">2</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-danger">Đặt bệnh nhân nằm đầu thấp</h6>
                            <p class="text-muted small mb-0">Đặt nằm ngửa, đầu thấp nghiêng sang một bên nếu nôn ói. Gác chân cao lên 30 độ.</p>
                        </div>
                    </div>

                    <div class="d-flex mb-3 align-items-start">
                        <div class="badge bg-danger rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">3</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-danger">Tiêm ngay Adrenaline (Liều khẩn cấp)</h6>
                            <p class="text-muted small mb-0">Tiêm bắp Adrenaline 1:1000 ở mặt trước bên đùi: 1/2 ống cho người lớn, 1/3 - 1/5 ống cho trẻ em.</p>
                        </div>
                    </div>

                    <div class="d-flex mb-0 align-items-start">
                        <div class="badge bg-danger rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">4</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-danger">Hỗ trợ đường thở & Gọi cấp cứu</h6>
                            <p class="text-muted small mb-0">Cho bệnh nhân thở Oxy qua mặt nạ, thiết lập đường truyền tĩnh mạch và gọi ngay xe cấp cứu 115.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 2: Quy trình sinh thiết da -->
        <div class="col-md-6 col-lg-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header bg-success text-white py-3 px-4 rounded-top-4 border-0">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-scissors me-2"></i>Quy Trình Sinh Thiết Da Lấy Mẫu (Rút Gọn)</h6>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted small mb-3">Các bước chuẩn bị thủ thuật sinh thiết da (Skin Biopsy) để lấy mẫu mô tế bào làm giải phẫu bệnh:</p>
                    
                    <div class="d-flex mb-3 align-items-start">
                        <div class="badge bg-success rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">1</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-success">Chuẩn bị dụng cụ & Sát trùng</h6>
                            <p class="text-muted small mb-0">Sát trùng vùng da sinh thiết bằng cồn Iod hoặc Betadine. Chuẩn bị kim sinh thiết, nhíp, kéo phẫu thuật vô khuẩn.</p>
                        </div>
                    </div>

                    <div class="d-flex mb-3 align-items-start">
                        <div class="badge bg-success rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">2</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-success">Gây tê tại chỗ</h6>
                            <p class="text-muted small mb-0">Tiêm gây tê cục bộ dưới da bằng dung dịch Lidocaine 1% - 2% (chờ 1-2 phút cho thuốc tê ngấm).</p>
                        </div>
                    </div>

                    <div class="d-flex mb-3 align-items-start">
                        <div class="badge bg-success rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">3</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-success">Lấy mẫu mô sắc tố</h6>
                            <p class="text-muted small mb-0">Dùng punch sinh thiết xoay tròn lấy khối mô (sâu đến lớp hạ bì), dùng kéo nhỏ cắt gốc mẫu mô.</p>
                        </div>
                    </div>

                    <div class="d-flex mb-0 align-items-start">
                        <div class="badge bg-success rounded-circle p-2 me-3" style="width: 28px; height: 28px; display: inline-flex; align-items: center; justify-content: center;">4</div>
                        <div>
                            <h6 class="fw-bold mb-1 text-success">Cầm máu, khâu & Bảo quản</h6>
                            <p class="text-muted small mb-0">Khâu 1-2 mũi chỉ thẩm mỹ. Cho mẫu mô vào lọ dung dịch bảo quản Formalin 10% gửi phòng lab.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 3: Phác đồ Acne -->
        <div class="col-md-6 col-lg-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header bg-primary text-white py-3 px-4 rounded-top-4 border-0">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-virus-slash me-2"></i>Hướng Dẫn Điều Trị Mụn Trứng Cá Đơn Giản</h6>
                </div>
                <div class="card-body p-4">
                    <h6 class="fw-bold text-primary mb-2" style="font-size: 0.9rem;"><i class="fa-solid fa-check me-2 text-success"></i>Mụn trứng cá nhẹ (Mụn ẩn, mụn đầu đen):</h6>
                    <ul class="text-muted small ps-3 mb-3" style="line-height: 1.6;">
                        <li>Vệ sinh da bằng sữa rửa mặt pH 5.5 ngày 2 lần (sáng & tối).</li>
                        <li>Sử dụng hoạt chất bôi tẩy tế bào chết chứa BHA 2% để thông thoáng cổ nang lông.</li>
                        <li>Bôi một lớp mỏng gel trị mụn Retinoid (ví dụ Adapalene 0.1%) vào buổi tối.</li>
                    </ul>

                    <h6 class="fw-bold text-primary mb-2" style="font-size: 0.9rem;"><i class="fa-solid fa-circle-exclamation me-2 text-warning"></i>Mụn trứng cá viêm nặng (Mụn bọc, mụn mủ):</h6>
                    <ul class="text-muted small ps-3 mb-0" style="line-height: 1.6;">
                        <li>Bôi kết hợp gel chấm mụn chứa Benzoyl Peroxide 2.5% hoặc kháng sinh bôi ngoài da.</li>
                        <li>Trường hợp viêm lan rộng, có thể chỉ định kháng sinh đường uống phối hợp ngắn ngày.</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Card 4: Sàng lọc Melanoma -->
        <div class="col-md-6 col-lg-6">
            <div class="card border-0 shadow-sm rounded-4 h-100 bg-white">
                <div class="card-header text-white py-3 px-4 rounded-top-4 border-0" style="background: linear-gradient(135deg, #1e3a8a, #3b82f6);">
                    <h6 class="fw-bold mb-0"><i class="fa-solid fa-magnifying-glass-chart me-2"></i>Quy Tắc Sàng Lọc Sớm Melanoma (Quy tắc ABCDE)</h6>
                </div>
                <div class="card-body p-4">
                    <p class="text-muted small mb-3">Giúp bác sĩ phân biệt nốt ruồi thông thường với các tổn thương ung thư hắc tố nghi ngờ:</p>
                    
                    <ul class="text-muted small ps-3 mb-0" style="line-height: 1.7;">
                        <li><strong>A (Bất đối xứng):</strong> Nốt ruồi có hình dạng méo mó, hai nửa không đối xứng.</li>
                        <li><strong>B (Bờ viền):</strong> Bờ nốt ruồi nham nhở, không đều hoặc có khía răng cưa.</li>
                        <li><strong>C (Màu sắc):</strong> Màu không đồng đều (chỗ đen, chỗ nâu, đỏ hoặc xám).</li>
                        <li><strong>D (Đường kính):</strong> Kích thước đường kính nốt sắc tố lớn hơn 6mm.</li>
                        <li><strong>E (Biến đổi):</strong> Nốt ruồi thay đổi nhanh về kích thước hoặc có triệu chứng ngứa rát, chảy máu.</li>
                    </ul>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
