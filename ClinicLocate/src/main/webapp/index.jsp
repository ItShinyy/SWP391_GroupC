<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ClinicLocate - Phân tích ảnh da</title>
    <link rel="stylesheet" href="css/diagnosis.css">
</head>
<body class="diagnosis-page">
    <header class="diagnosis-header">
        <a class="brand" href="index.jsp">
            <span class="brand-icon">+</span>
            <span>Clinic<span>Locate</span></span>
        </a>
        <a class="clinic-cta" href="location.jsp">
            <span class="location-pin" aria-hidden="true"></span>
            Tìm cơ sở y tế gần tôi
        </a>
    </header>

    <main class="diagnosis-main">
        <section class="upload-panel">
            <div class="panel-heading">
                <div>
                    <span class="section-label">Phân tích hình ảnh</span>
                    <h1>Tải ảnh vùng da cần kiểm tra</h1>
                    <p>Chọn ảnh rõ nét để hệ thống hỗ trợ đánh giá ban đầu.</p>
                </div>
            </div>

            <input id="image-input" type="file" accept="image/*" hidden>

            <div class="upload-zone" id="upload-zone">
                <div class="upload-placeholder" id="upload-placeholder">
                    <div class="upload-icon" aria-hidden="true"><span></span></div>
                    <h2>Chưa có ảnh nào</h2>
                    <p>Nhấn nút bên dưới để chọn ảnh từ thiết bị.</p>
                    <button class="select-image-btn" id="select-image-btn" type="button">Chọn ảnh</button>
                </div>

                <div class="image-preview hidden" id="image-preview">
                    <img id="preview-image" alt="Ảnh đã chọn">
                    <div class="preview-overlay">
                        <span id="file-name"></span>
                        <button id="remove-image-btn" type="button">Xóa ảnh</button>
                    </div>
                </div>
            </div>

            <button class="primary-btn analyze-btn" id="analyze-btn" type="button" disabled>
                Phân tích ảnh
            </button>
        </section>

        <section class="results-panel">
            <div class="results-heading">
                <div>
                    <span class="section-label">Kết quả</span>
                    <h2 id="result-status">Chưa phân tích</h2>
                </div>
            </div>

            <div class="med-warn">
                <strong>Lưu ý</strong>
                <p>Kết quả chỉ mang tính tham khảo. Nếu cần kiểm tra trực tiếp,
                     hãy dùng nút <b>Tìm cơ sở y tế</b> ở trên.</p>
            </div>
        </section>
    </main>

    <script>
        const input = document.getElementById('image-input');
        const placeholder = document.getElementById('upload-placeholder');
        const preview = document.getElementById('image-preview');
        const previewImage = document.getElementById('preview-image');
        const fileName = document.getElementById('file-name');
        const analyzeBtn = document.getElementById('analyze-btn');
        const resultStatus = document.getElementById('result-status');

        //mở thư mục chọn ảnh khi nhấn nút
        document.getElementById('select-image-btn').onclick = () => input.click();

        //ấn nút
        input.onchange = () => {
            const file = input.files[0];
            //không chọn ảnh nào
            if (!file)
             return;

             // tạo đường dẫn tạm thời, gắn thẻ <img> hiện ảnh lên
            previewImage.src = URL.createObjectURL(file);
            //ẩn phần gia diện ban đầu
            placeholder.classList.add('hidden');
            // hiện phần ảnh upload lên
            preview.classList.remove('hidden');
            // hiện nút phân tích ảnh
            analyzeBtn.disabled = false;
            resultStatus.textContent = 'Sẵn sàng phân tích';
        };

        document.getElementById('remove-image-btn').onclick = () => {
            input.value = '';
            previewImage.removeAttribute('src');
            preview.classList.add('hidden');
            placeholder.classList.remove('hidden');
            analyzeBtn.disabled = true;
            resultStatus.textContent = 'Chưa phân tích';
        };

        analyzeBtn.onclick = () => {
            resultStatus.textContent = 'Chưa kết nối mô hình AI';
        };
    </script>
</body>
</html>
