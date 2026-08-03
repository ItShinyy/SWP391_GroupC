<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<style>
    body.diagnose-page { background-color: #F8FAFC; height: 100dvh; overflow: hidden; }
    body.diagnose-page > nav { flex-shrink: 0; }
    body.diagnose-page > main { flex: 1; display: flex; flex-direction: column; overflow: hidden; min-height: 0; }
    
    .diagnose-container { flex: 1; display: flex; flex-direction: column; overflow: hidden; max-width: 1400px; padding: 1.5rem 1rem; margin: 0 auto; width: 100%; }
    .diagnose-content { flex: 1; display: flex; overflow: hidden; gap: 2rem; min-height: 0; }
    
    /* Left Panel */
    .photo-guide-card { background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); border: 1px solid #F1F5F9; padding: 2rem; height: 100%; overflow-y: auto; }
    .guide-icon { width: 48px; height: 48px; background: #DCFCE7; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #16A34A; font-size: 1.25rem; flex-shrink: 0; }
    
    /* Right Panel */
    .upload-card { background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); border: 1px solid #F1F5F9; display: flex; flex-direction: column; height: 100%; overflow: hidden; position: relative; }
    
    .capture-choice { border: 2px dashed #E2E8F0; border-radius: 16px; padding: 2rem 1rem; text-align: center; cursor: pointer; transition: all 0.2s; background: #F8FAFC; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; }
    .capture-choice:hover { border-color: #16A34A; background: #F0FDF4; transform: translateY(-2px); }
    
    .preview-container { flex: 1; min-height: 0; display: flex; flex-direction: column; justify-content: center; align-items: center; background: #F8FAFC; border-radius: 16px; border: 2px dashed #E2E8F0; overflow: hidden; position: relative; padding: 1rem; }
    .capture-preview, .camera-video { width: 100%; height: 100%; object-fit: contain; border-radius: 8px; }
    
    .action-bar { padding: 1.25rem 2rem; background: white; border-top: 1px solid #F1F5F9; display: flex; justify-content: space-between; align-items: center; flex-shrink: 0; }
    
    .btn-green { background: #16A34A; color: white; border-radius: 12px; padding: 0.75rem 1.5rem; font-weight: 600; transition: transform 0.2s; border: none; text-decoration: none; display: inline-flex; align-items: center; }
    .btn-green:hover:not(:disabled) { background: #15803d; color: white; transform: scale(1.02); }
    .btn-green:disabled { background: #94A3B8; cursor: not-allowed; }
    
    .btn-gray { background: white; color: #475569; border: 1px solid #E2E8F0; border-radius: 12px; padding: 0.75rem 1.5rem; font-weight: 600; transition: all 0.2s; text-decoration: none; display: inline-flex; align-items: center; }
    .btn-gray:hover { background: #F8FAFC; color: #0F172A; border-color: #CBD5E1; }
    
    /* Trust Banner & Footer */
    .trust-banner { display: flex; justify-content: space-around; align-items: center; background: white; border-radius: 16px; padding: 1rem; box-shadow: 0 4px 15px rgba(0,0,0,0.02); flex-shrink: 0; margin-top: 1.5rem; }
    .trust-item { display: flex; align-items: center; gap: 0.75rem; color: #475569; font-weight: 500; font-size: 0.9rem; }
    
    .slim-footer { display: flex; justify-content: space-between; align-items: center; padding-top: 1rem; font-size: 0.85rem; color: #64748B; flex-shrink: 0; }
    
    /* Utility */
    .text-green { color: #16A34A; }
    .bg-green-soft { background: #DCFCE7; }
</style>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="d-none" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.95); z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column;">
    <div class="spinner-border text-green" style="width: 4rem; height: 4rem; margin-bottom: 20px;" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
    <h3 class="fw-bold text-green mb-2" style="font-family: 'Fragment Mono', sans-serif;">AI đang phân tích...</h3>
    <p class="text-muted">Vui lòng không đóng trình duyệt (Quá trình này mất khoảng 3-5 giây)</p>
</div>

<script>document.body.classList.add('diagnose-page');</script>

<div class="diagnose-container">
    <div class="diagnose-content">
        <!-- Left Panel (Photo Guide) -->
        <div class="d-none d-lg-block" style="width: 35%;">
            <div class="photo-guide-card d-flex flex-column h-100">
                <div class="d-flex align-items-center mb-4">
                    <div class="guide-icon me-3 rounded-circle"><i class="fa-solid fa-camera"></i></div>
                    <h4 class="fw-bold mb-0" style="color: #16A34A;">Hướng dẫn chụp ảnh</h4>
                </div>
                
                <div class="d-flex flex-column flex-grow-1">
                    <div class="d-flex align-items-start pb-3 border-bottom" style="border-color:#F1F5F9 !important;">
                        <div class="guide-icon rounded-circle" style="width:36px;height:36px;font-size:1rem;"><i class="fa-solid fa-sun"></i></div>
                        <div class="ms-3">
                            <h6 class="fw-bold mb-1" style="color: #0F172A;">1. Đủ ánh sáng</h6>
                            <p class="text-muted small mb-0">Hãy chụp ảnh ở nơi có ánh sáng tự nhiên, tránh bóng đổ lên vùng da.</p>
                        </div>
                    </div>
                    
                    <div class="d-flex align-items-start py-3 border-bottom" style="border-color:#F1F5F9 !important;">
                        <div class="guide-icon rounded-circle" style="width:36px;height:36px;font-size:1rem;"><i class="fa-solid fa-crosshairs"></i></div>
                        <div class="ms-3">
                            <h6 class="fw-bold mb-1" style="color: #0F172A;">2. Chụp rõ nét (Focus)</h6>
                            <p class="text-muted small mb-0">Đảm bảo camera lấy nét chuẩn vào vùng da tổn thương, không mờ nhòe.</p>
                        </div>
                    </div>
                    
                    <div class="d-flex align-items-start py-3 border-bottom" style="border-color:#F1F5F9 !important;">
                        <div class="guide-icon rounded-circle" style="width:36px;height:36px;font-size:1rem;"><i class="fa-solid fa-ruler-combined"></i></div>
                        <div class="ms-3">
                            <h6 class="fw-bold mb-1" style="color: #0F172A;">3. Khoảng cách phù hợp</h6>
                            <p class="text-muted small mb-0">Cách vùng da khoảng 10-15cm, chỉ bao gồm vùng da cần kiểm tra.</p>
                        </div>
                    </div>
                    
                    <div class="d-flex align-items-start pt-3">
                        <div class="guide-icon rounded-circle" style="width:36px;height:36px;font-size:1rem;background:#FEE2E2;color:#DC2626;"><i class="fa-solid fa-circle-exclamation"></i></div>
                        <div class="ms-3">
                            <h6 class="fw-bold mb-1" style="color: #0F172A;">4. Quy định tệp</h6>
                            <p class="text-muted small mb-0">Chỉ chấp nhận ảnh JPG/PNG. Máy chủ kiểm tra kích thước và định dạng trước khi xử lý.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Right Panel (Upload & Results) -->
        <div class="w-100" style="width: 65%;">
            <div class="upload-card">
                <!-- Header -->
                <div class="p-4 pb-0 flex-shrink-0 text-center">
                    <h3 class="fw-bold mb-3" style="color: #16A34A;">Tải ảnh vùng da cần kiểm tra</h3>
                    
                    <div class="alert text-start d-flex align-items-start mb-3" style="background:#F0F9FF; border:1px solid #E0F2FE; border-radius:12px; padding:12px 16px;">
                        <i class="fa-solid fa-circle-info me-3 mt-1" style="color:#0284C7; font-size:1.1rem;"></i>
                        <p class="mb-0 small" style="color:#0369A1; line-height:1.5;">Đây là hỗ trợ sàng lọc AI — không phải chẩn đoán cuối cùng.<br>Kết quả sơ bộ cần bác sĩ da liễu xác nhận.</p>
                    </div>
                    
                    <c:if test="${not empty errorMessage && screeningResultStatus ne 'REJECTED'}">
                        <div class="alert alert-danger py-2 px-3 small mb-2 text-start"><i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/></div>
                    </c:if>
                    <c:if test="${not screeningAvailable}">
                        <div class="alert alert-warning py-2 px-3 small mb-2 text-start"><i class="fa-solid fa-triangle-exclamation me-2"></i>AI đang tạm dừng. Có thể tải ảnh để lưu hồ sơ.</div>
                    </c:if>
                </div>
                
                <!-- Main Body (Form or Results) -->
                <div class="px-4 py-2 flex-grow-1 d-flex flex-column min-height-0 overflow-auto">
                
                    <!-- SUCCESS STATE -->
                    <c:if test="${screeningResultStatus eq 'SUCCESS'}">
                        <div class="h-100 d-flex flex-column justify-content-center">
                            <div class="text-center mb-4">
                                <div class="d-inline-flex align-items-center justify-content-center bg-green-soft rounded-circle mb-3" style="width:64px;height:64px;">
                                    <i class="fa-solid fa-check text-green fs-2"></i>
                                </div>
                                <h4 class="fw-bold" style="color: #0F172A;">Hoàn tất sàng lọc AI</h4>
                            </div>
                            
                            <div class="row g-3 mb-4">
                                <div class="col-4 text-center p-3 rounded-3" style="background:#F8FAFC;border:1px solid #E2E8F0;">
                                    <div class="text-muted small fw-semibold text-uppercase mb-1">Gợi ý bệnh</div>
                                    <div class="fw-bold" style="color:#0F172A;"><c:out value="${empty preliminaryDiseaseName ? 'Không có' : preliminaryDiseaseName}"/></div>
                                </div>
                                <div class="col-4 text-center p-3 rounded-3" style="background:#F8FAFC;border:1px solid #E2E8F0;">
                                    <div class="text-muted small fw-semibold text-uppercase mb-1">Độ tin cậy</div>
                                    <div class="fw-bold text-green fs-5"><c:out value="${empty preliminaryConfidencePercent ? '—' : preliminaryConfidencePercent += '%'}"/></div>
                                </div>
                                <div class="col-4 text-center p-3 rounded-3" style="background:#F8FAFC;border:1px solid #E2E8F0;">
                                    <div class="text-muted small fw-semibold text-uppercase mb-1">Mức rủi ro</div>
                                    <div>
                                        <c:choose>
                                            <c:when test="${preliminaryRiskLevel eq 'HIGH' or preliminaryRiskLevel eq 'High'}"><span class="badge bg-danger">Cao</span></c:when>
                                            <c:when test="${preliminaryRiskLevel eq 'MEDIUM' or preliminaryRiskLevel eq 'Medium'}"><span class="badge bg-warning text-dark">Trung bình</span></c:when>
                                            <c:when test="${preliminaryRiskLevel eq 'LOW' or preliminaryRiskLevel eq 'Low'}"><span class="badge bg-success">Thấp</span></c:when>
                                            <c:otherwise><span class="badge bg-secondary"><c:out value="${empty preliminaryRiskLevel ? '—' : preliminaryRiskLevel}"/></span></c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- REJECTED STATE -->
                    <c:if test="${screeningResultStatus eq 'REJECTED'}">
                        <div class="h-100 d-flex flex-column justify-content-center text-center">
                            <div class="d-inline-flex align-items-center justify-content-center bg-danger bg-opacity-10 rounded-circle mb-3 mx-auto" style="width:64px;height:64px;">
                                <i class="fa-solid fa-xmark text-danger fs-2"></i>
                            </div>
                            <h4 class="fw-bold mb-2" style="color: #0F172A;">Ảnh chưa đạt chất lượng</h4>
                            <p class="text-muted mx-auto" style="max-width: 400px;">
                                <c:out value="${empty errorMessage ? 'Ảnh không vượt qua kiểm tra chất lượng. Vui lòng chụp lại ảnh rõ, đủ sáng rồi thử lại.' : errorMessage}"/>
                            </p>
                        </div>
                    </c:if>
                
                    <!-- CAPTURE FORM -->
                    <c:if test="${screeningResultStatus ne 'SUCCESS'}">
                        <form id="screeningForm" class="h-100 d-flex flex-column min-height-0" method="post" action="${pageContext.request.contextPath}/patient/diagnose" enctype="multipart/form-data" data-max-upload-bytes="${maxUploadBytes}" data-screening-available="${screeningAvailable}" novalidate onsubmit="if (document.getElementById('loadingOverlay')) { document.getElementById('loadingOverlay').classList.remove('d-none'); document.getElementById('loadingOverlay').style.display='flex'; }">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="idempotencyKey" value="${idempotencyKey}">
                            <input class="d-none" id="skinImage" name="skinImage" type="file" accept="image/*" capture="environment">
                            
                            <!-- State 1: Choose Method (Visible by default) -->
                            <div id="captureChoices" class="flex-grow-1 d-flex">
                                <div class="capture-choice w-100" style="border: 2px dashed #16A34A; background: #ffffff;">
                                    <div class="bg-green-soft rounded-circle d-flex justify-content-center align-items-center mb-3" style="width:72px;height:72px;">
                                        <i class="fa-solid fa-arrow-up text-green fs-3"></i>
                                    </div>
                                    <h5 class="fw-bold mb-2" style="color:#0F172A;">Kéo thả ảnh vào đây</h5>
                                    <span class="small text-muted mb-3">hoặc</span>
                                    <div class="d-flex gap-2 justify-content-center mb-4">
                                        <button class="btn btn-outline-success px-3 bg-white" style="border-radius:12px; font-weight:600;" id="chooseImage" type="button">
                                            <i class="fa-solid fa-image me-2"></i>Chọn ảnh
                                        </button>
                                        <button class="btn btn-outline-success px-3 bg-white" style="border-radius:12px; font-weight:600;" id="openCamera" type="button">
                                            <i class="fa-solid fa-camera me-2"></i>Chụp ảnh
                                        </button>
                                    </div>
                                    <span class="small text-muted">Định dạng: JPG, PNG • Kích thước tối đa: 10MB</span>
                                </div>
                            </div>
                            
                            <!-- State 2: Camera Preview (Hidden initially) -->
                            <div id="cameraPanel" class="preview-container d-none p-0 bg-dark">
                                <video id="cameraPreview" class="camera-video" autoplay playsinline muted></video>
                                <div class="position-absolute bottom-0 start-0 w-100 p-3 d-flex justify-content-center gap-3" style="background: linear-gradient(transparent, rgba(0,0,0,0.8));">
                                    <button class="btn btn-outline-light rounded-pill px-4" id="cancelCamera" type="button">Hủy</button>
                                    <button class="btn btn-light rounded-pill px-4" id="capturePhoto" type="button"><i class="fa-solid fa-circle-dot text-danger me-2"></i>Chụp</button>
                                </div>
                            </div>
                            
                            <!-- State 3: Selected Image Preview (Hidden initially) -->
                            <div id="selectedImagePanel" class="preview-container d-none">
                                <img id="selectedImagePreview" class="capture-preview mb-2" alt="Preview">
                                <div class="d-flex align-items-center gap-3 mt-auto bg-white p-2 rounded-3 shadow-sm w-100 justify-content-between">
                                    <div class="text-truncate small fw-medium text-muted ms-2" id="selectedImageName" style="max-width:200px;"></div>
                                    <button class="btn btn-sm btn-outline-secondary rounded-pill" id="replaceImage" type="button"><i class="fa-solid fa-arrows-rotate me-1"></i>Đổi ảnh</button>
                                </div>
                            </div>
                            
                            <div id="captureError" class="alert alert-danger py-2 mt-2 mb-0 d-none small"></div>
                            
                            <!-- Invisible submit button to bind form logic, actual button is in action-bar below -->
                            <button type="submit" id="hiddenSubmit" class="d-none"></button>
                        </form>
                    </c:if>
                </div>
                
                <!-- Action Bar (Always at bottom) -->
                <div class="action-bar" style="background:#F8FAFC; border-radius: 0 0 20px 20px; border-top: 1px solid #E2E8F0; padding: 1.25rem 2rem;">
                    <c:choose>
                        <c:when test="${screeningResultStatus eq 'SUCCESS'}">
                            <a class="btn-gray" href="${pageContext.request.contextPath}/patient/reports/view?id=${bookingReportId}">
                                Xem chi tiết
                            </a>
                            <a class="btn-green" href="${pageContext.request.contextPath}/patient/booking?reportId=${bookingReportId}">
                                Đặt lịch ngay <i class="fa-solid fa-arrow-right ms-2"></i>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn-gray" href="${pageContext.request.contextPath}/patient/booking">
                                <i class="fa-regular fa-calendar-check me-2"></i>Đặt lịch không kèm ảnh
                            </a>
                            <button class="btn-green" type="button" onclick="document.getElementById('hiddenSubmit').click()" ${not screeningAvailable ? 'disabled' : ''}>
                                <i class="fa-solid fa-wand-magic-sparkles me-2"></i>${screeningAvailable ? 'Bắt đầu phân tích AI' : 'AI đang tạm dừng'}
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Trust Banner -->
    <div class="trust-banner d-none d-md-flex mt-3 py-3 px-4" style="background:#F8FAFC; border:1px solid #F1F5F9;">
        <div class="trust-item">
            <div class="guide-icon bg-green-soft rounded-circle" style="width:40px;height:40px;font-size:1rem;"><i class="fa-solid fa-shield-check text-green"></i></div>
            <div>
                <div class="fw-bold" style="color:#0F172A;">Quyền riêng tư & bảo mật</div>
                <div class="small text-muted">Ảnh của bạn được mã hóa và bảo mật tuyệt đối.</div>
            </div>
        </div>
        <div class="trust-item">
            <div class="guide-icon bg-green-soft rounded-circle" style="width:40px;height:40px;font-size:1rem;"><i class="fa-regular fa-clock text-green"></i></div>
            <div>
                <div class="fw-bold" style="color:#0F172A;">Xử lý nhanh chóng</div>
                <div class="small text-muted">Kết quả sơ bộ chỉ trong vài giây.</div>
            </div>
        </div>
        <div class="trust-item">
            <div class="guide-icon bg-green-soft rounded-circle" style="width:40px;height:40px;font-size:1rem;"><i class="fa-regular fa-circle-check text-green"></i></div>
            <div>
                <div class="fw-bold" style="color:#0F172A;">Hỗ trợ bác sĩ</div>
                <div class="small text-muted">Bác sĩ da liễu sẽ kiểm tra và xác nhận.</div>
            </div>
        </div>
    </div>
    
    <!-- Minimal Footer -->
    <footer class="slim-footer">
        <div>© 2026 DermAI</div>
        <div class="d-flex gap-3">
            <a href="${pageContext.request.contextPath}/global/clinics" class="text-decoration-none text-muted hover-primary">Phòng khám</a>
            <a href="${pageContext.request.contextPath}/patient/diagnose" class="text-decoration-none text-muted hover-primary">Sàng lọc AI</a>
        </div>
    </footer>
</div>

<script>
(() => {
    const form = document.getElementById('screeningForm');
    if (!form) return;
    const fileInput = document.getElementById('skinImage');
    const chooseImage = document.getElementById('chooseImage');
    const openCamera = document.getElementById('openCamera');
    const cameraPanel = document.getElementById('cameraPanel');
    const cameraPreview = document.getElementById('cameraPreview');
    const capturePhoto = document.getElementById('capturePhoto');
    const cancelCamera = document.getElementById('cancelCamera');
    const captureChoices = document.getElementById('captureChoices');
    const selectedPanel = document.getElementById('selectedImagePanel');
    const selectedPreview = document.getElementById('selectedImagePreview');
    const selectedName = document.getElementById('selectedImageName');
    const replaceImage = document.getElementById('replaceImage');
    const errorBox = document.getElementById('captureError');
    const loadingOverlay = document.getElementById('loadingOverlay');
    const maxUploadBytes = Number(form.dataset.maxUploadBytes);
    const screeningAvailable = form.dataset.screeningAvailable === 'true';
    let cameraStream;
    let previewUrl;

    const hideLoading = () => {
        if (!loadingOverlay) return;
        loadingOverlay.classList.add('d-none');
        loadingOverlay.style.display = 'none';
    };
    const showError = (message) => {
        hideLoading();
        errorBox.textContent = message;
        errorBox.classList.remove('d-none');
    };
    const clearError = () => {
        errorBox.textContent = '';
        errorBox.classList.add('d-none');
    };
    const showState = (state) => {
        captureChoices.classList.add('d-none');
        cameraPanel.classList.add('d-none');
        selectedPanel.classList.add('d-none');
        if (state === 'choices') { captureChoices.classList.remove('d-none'); captureChoices.classList.add('d-flex'); }
        else { captureChoices.classList.remove('d-flex'); }
        if (state === 'camera') cameraPanel.classList.remove('d-none');
        if (state === 'preview') selectedPanel.classList.remove('d-none');
    };
    const stopCamera = () => {
        if (cameraStream) cameraStream.getTracks().forEach((track) => track.stop());
        cameraStream = undefined;
        cameraPreview.srcObject = null;
        showState('choices');
    };
    const previewFile = (file) => {
        if (!file) return;
        if (!file.type.startsWith('image/')) {
            fileInput.value = '';
            showError('Vui lòng chọn tệp ảnh.');
            showState('choices');
            return;
        }
        if (Number.isFinite(maxUploadBytes) && file.size > maxUploadBytes) {
            fileInput.value = '';
            showError('Ảnh vượt quá giới hạn dung lượng cho phép.');
            showState('choices');
            return;
        }
        clearError();
        if (previewUrl) URL.revokeObjectURL(previewUrl);
        previewUrl = URL.createObjectURL(file);
        selectedPreview.src = previewUrl;
        selectedName.textContent = file.name || 'Captured Photo';
        showState('preview');
    };

    chooseImage.addEventListener('click', () => fileInput.click());
    replaceImage.addEventListener('click', () => fileInput.click());
    fileInput.addEventListener('change', () => previewFile(fileInput.files[0]));

    openCamera.addEventListener('click', async () => {
        clearError();
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            showError('Trình duyệt không hỗ trợ camera. Hãy dùng Tải ảnh lên.');
            return;
        }
        try {
            stopCamera();
            cameraStream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: 'environment' } }, audio: false });
            cameraPreview.srcObject = cameraStream;
            showState('camera');
        } catch (error) {
            showError('Không được cấp quyền camera. Bạn có thể tải ảnh có sẵn.');
        }
    });

    capturePhoto.addEventListener('click', () => {
        if (!cameraStream || !cameraPreview.videoWidth || !cameraPreview.videoHeight) {
            showError('Camera chưa sẵn sàng. Vui lòng thử lại.');
            return;
        }
        const canvas = document.createElement('canvas');
        canvas.width = cameraPreview.videoWidth;
        canvas.height = cameraPreview.videoHeight;
        canvas.getContext('2d').drawImage(cameraPreview, 0, 0, canvas.width, canvas.height);
        canvas.toBlob((blob) => {
            if (!blob) { showError('Không chụp được ảnh.'); return; }
            const photo = new File([blob], 'skin-screening-' + Date.now() + '.jpg', { type: 'image/jpeg' });
            const transfer = new DataTransfer();
            transfer.items.add(photo);
            fileInput.files = transfer.files;
            stopCamera();
            previewFile(photo);
        }, 'image/jpeg', 0.92);
    });

    cancelCamera.addEventListener('click', stopCamera);
    form.addEventListener('submit', (event) => {
        if (!screeningAvailable) {
            event.preventDefault();
            showError('AI đang tạm dừng. Bạn vẫn có thể đặt lịch tư vấn không kèm ảnh sàng lọc.');
            return;
        }
        if (!fileInput.files.length) {
            event.preventDefault();
            showError('Hãy chọn hoặc chụp ảnh trước khi tiếp tục.');
        }
    });
    window.addEventListener('beforeunload', () => {
        stopCamera();
        if (previewUrl) URL.revokeObjectURL(previewUrl);
    });
})();
</script>

<%-- Close main manually, we have our own flex container and footer --%>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
