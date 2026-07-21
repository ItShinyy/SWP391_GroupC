<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<!-- Loading Overlay -->
<div id="loadingOverlay" class="d-none" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.95); z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column;">
    <div class="spinner-border text-primary" style="width: 4rem; height: 4rem; margin-bottom: 20px;" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
    <h3 class="fw-bold" style="color: var(--skin-primary); font-family: 'Fragment Mono', sans-serif;">AI đang phân tích...</h3>
    <p class="text-muted">Vui lòng không đóng trình duyệt (Quá trình này mất khoảng 3-5 giây)</p>
</div>

<section class="diagnose-section py-5">
    <div class="container py-4">
        <div class="row align-items-center">
            
            <!-- Cột trái: Hướng dẫn -->
            <div class="col-lg-5 mb-5 mb-lg-0 pe-lg-5">
                <h2 class="fw-bold mb-4" style="color: var(--skin-primary);">Hướng dẫn chụp ảnh</h2>
                
                <div class="d-flex mb-4 align-items-start">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-sun text-primary fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Đủ ánh sáng</h5>
                        <p class="text-muted small">Hãy chụp ảnh ở nơi có ánh sáng tự nhiên, tránh bóng đổ lên vùng da.</p>
                    </div>
                </div>

                <div class="d-flex mb-4 align-items-start">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-crosshairs text-primary fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Chụp rõ nét (Focus)</h5>
                        <p class="text-muted small">Đảm bảo camera lấy nét chuẩn vào vùng da tổn thương, không mờ nhòe.</p>
                    </div>
                </div>

                <div class="d-flex mb-4 align-items-start">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-ruler-combined text-primary fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Khoảng cách phù hợp</h5>
                        <p class="text-muted small">Cách vùng da khoảng 10-15cm, chỉ bao gồm vùng da cần kiểm tra.</p>
                    </div>
                </div>

                <div class="d-flex align-items-start">
                    <div class="flex-shrink-0 bg-danger bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-circle-exclamation text-danger fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Quy định tệp</h5>
                        <p class="text-muted small">Chỉ chấp nhận ảnh JPG/PNG. Kích thước tối đa 5MB.</p>
                    </div>
                </div>
            </div>

            <!-- Cột phải: Form Upload -->
            <div class="col-lg-7">
                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <div class="card-body">
                        <h3 class="text-center fw-bold mb-4" style="color: var(--skin-primary);">Tải ảnh vùng da cần kiểm tra</h3>
                        
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger d-flex align-items-center rounded-3 mb-4" role="alert">
                                <i class="fa-solid fa-circle-xmark me-2 fs-5"></i>
                                <div>${errorMessage}</div>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/patient/diagnose" method="POST" enctype="multipart/form-data" onsubmit="document.getElementById('loadingOverlay').classList.remove('d-none'); document.getElementById('loadingOverlay').style.display='flex';">
                            
                            <!-- Dropzone -->
                            <div class="upload-dropzone p-5 text-center bg-white shadow-sm mb-4">
                                <i class="fa-solid fa-cloud-arrow-up fa-4x mb-3" style="color: var(--skin-secondary);"></i>
                                <h4 class="fw-bold" style="color: var(--skin-primary);">Nhấn để tải ảnh lên</h4>
                                <p class="text-muted small mb-0">Hỗ trợ JPG, PNG (Tối đa 5MB)</p>
                                <input type="file" name="skinImage" id="skinImage" accept="image/jpeg, image/png" class="form-control" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer;" required>
                            </div>
                            
                            <!-- Image Preview -->
                            <div id="imagePreviewContainer" class="text-center d-none mb-4">
                                <img id="imagePreview" src="#" alt="Preview" class="img-fluid rounded-3 shadow-sm" style="max-height: 300px; object-fit: contain;">
                            </div>

                            <button type="submit" class="btn btn-skin w-100 btn-lg fw-bold fs-5">
                                <i class="fa-solid fa-wand-magic-sparkles me-2"></i> Bắt đầu phân tích AI
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</section>

<script>
    document.getElementById('skinImage').addEventListener('change', function(event) {
        const file = event.target.files[0];
        const previewContainer = document.getElementById('imagePreviewContainer');
        const previewImage = document.getElementById('imagePreview');
        
        if (file) {
            if(file.size > 5 * 1024 * 1024) {
                alert('Dung lượng tệp vượt quá 5MB. Vui lòng chọn ảnh khác.');
                this.value = ''; 
                previewContainer.classList.add('d-none');
                return;
            }

            const reader = new FileReader();
            reader.onload = function(e) {
                previewImage.src = e.target.result;
                previewContainer.classList.remove('d-none');
            }
            reader.readAsDataURL(file);
        } else {
            previewContainer.classList.add('d-none');
        }
    });
</script>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
