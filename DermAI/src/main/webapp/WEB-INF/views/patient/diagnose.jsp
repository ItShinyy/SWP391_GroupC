<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<style>
    .capture-choice { min-height: 160px; border: 2px dashed #cbd5e1; cursor: pointer; transition: .2s ease; }
    .capture-choice:hover, .capture-choice:focus-within { border-color: #0d6efd; background: #f8fbff; }
    .capture-preview { display: none; max-height: 360px; object-fit: contain; background: #0f172a; }
    .camera-panel { display: none; background: #0f172a; border-radius: 1rem; overflow: hidden; }
    .camera-panel video { display: block; width: 100%; max-height: 360px; object-fit: cover; }
    .upload-dropzone { position: relative; border: 2px dashed #cbd5e1; border-radius: 1rem; }
</style>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="d-none" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.95); z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column;">
    <div class="spinner-border text-primary" style="width: 4rem; height: 4rem; margin-bottom: 20px;" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
    <h3 class="fw-bold" style="color: var(--skin-primary, #0d6efd); font-family: 'Fragment Mono', sans-serif;">AI đang phân tích...</h3>
    <p class="text-muted">Vui lòng không đóng trình duyệt (Quá trình này mất khoảng 3-5 giây)</p>
</div>

<section class="diagnose-section py-5">
    <div class="container py-4">
        <div class="row align-items-start">

            <!-- Left: Tips (tempo shell) -->
            <div class="col-lg-5 mb-5 mb-lg-0 pe-lg-5">
                <h2 class="fw-bold mb-4" style="color: var(--skin-primary, #0d6efd);">Hướng dẫn chụp ảnh</h2>

                <div class="d-flex mb-4 align-items-start">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-sun text-primary fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Đủ ánh sáng</h5>
                        <p class="text-muted small mb-0">Hãy chụp ảnh ở nơi có ánh sáng tự nhiên, tránh bóng đổ lên vùng da.</p>
                    </div>
                </div>

                <div class="d-flex mb-4 align-items-start">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-crosshairs text-primary fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Chụp rõ nét (Focus)</h5>
                        <p class="text-muted small mb-0">Đảm bảo camera lấy nét chuẩn vào vùng da tổn thương, không mờ nhòe.</p>
                    </div>
                </div>

                <div class="d-flex mb-4 align-items-start">
                    <div class="flex-shrink-0 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-ruler-combined text-primary fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Khoảng cách phù hợp</h5>
                        <p class="text-muted small mb-0">Cách vùng da khoảng 10-15cm, chỉ bao gồm vùng da cần kiểm tra.</p>
                    </div>
                </div>

                <div class="d-flex align-items-start">
                    <div class="flex-shrink-0 bg-danger bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-circle-exclamation text-danger fs-5"></i>
                    </div>
                    <div class="ms-3 flex-grow-1">
                        <h5 class="fw-bold mb-1">Quy định tệp</h5>
                        <p class="text-muted small mb-0">Chỉ chấp nhận ảnh JPG/PNG. Máy chủ kiểm tra kích thước và định dạng trước khi xử lý.</p>
                    </div>
                </div>
            </div>

            <!-- Right: Form / Results -->
            <div class="col-lg-7">
                <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                    <div class="card-body">
                        <h3 class="text-center fw-bold mb-3" style="color: var(--skin-primary, #0d6efd);">Tải ảnh vùng da cần kiểm tra</h3>

                        <div class="alert alert-info">
                            Đây là hỗ trợ sàng lọc AI — không phải chẩn đoán cuối cùng. Kết quả sơ bộ cần bác sĩ da liễu xác nhận.
                        </div>

                        <c:if test="${not screeningAvailable}">
                            <div class="alert alert-secondary">
                                <i class="fa-solid fa-circle-pause me-2"></i>Chuẩn bị ảnh (camera/upload) vẫn dùng được, nhưng xử lý AI đang tạm dừng trong môi trường này.
                            </div>
                        </c:if>

                        <c:if test="${not empty errorMessage && screeningResultStatus ne 'REJECTED'}">
                            <div class="alert alert-warning d-flex align-items-center rounded-3 mb-4" role="alert">
                                <i class="fa-solid fa-circle-xmark me-2 fs-5"></i>
                                <div><c:out value="${errorMessage}"/></div>
                            </div>
                        </c:if>

                        <!-- SUCCESS panel (Derma) -->
                        <c:if test="${screeningResultStatus eq 'SUCCESS'}">
                            <div class="card border-primary shadow-sm mb-0">
                                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center py-3">
                                    <h2 class="h5 mb-0 fw-bold"><i class="fa-solid fa-robot me-2"></i>Kết quả sàng lọc AI</h2>
                                    <span class="badge bg-light text-primary">Sơ bộ</span>
                                </div>
                                <div class="card-body p-4">
                                    <div class="row g-4 mb-4">
                                        <div class="col-md-4">
                                            <div class="text-muted small fw-semibold text-uppercase mb-1">Gợi ý bệnh</div>
                                            <div class="fs-5 fw-bold text-dark"><c:out value="${empty preliminaryDiseaseName ? 'Không có' : preliminaryDiseaseName}"/></div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="text-muted small fw-semibold text-uppercase mb-1">Độ tin cậy</div>
                                            <div class="d-flex align-items-center">
                                                <div class="fs-5 fw-bold text-dark me-2">
                                                    <c:choose>
                                                        <c:when test="${not empty preliminaryConfidencePercent}">${preliminaryConfidencePercent}%</c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <c:if test="${not empty preliminaryConfidencePercent}">
                                                    <div class="progress flex-grow-1" style="height: 8px;">
                                                        <div class="progress-bar bg-primary" role="progressbar" style="width: ${preliminaryConfidencePercent}%" aria-valuenow="${preliminaryConfidencePercent}" aria-valuemin="0" aria-valuemax="100"></div>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="text-muted small fw-semibold text-uppercase mb-1">Mức rủi ro</div>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${preliminaryRiskLevel eq 'HIGH' or preliminaryRiskLevel eq 'High'}"><span class="badge bg-danger fs-6"><i class="fa-solid fa-triangle-exclamation me-1"></i>Cao</span></c:when>
                                                    <c:when test="${preliminaryRiskLevel eq 'MEDIUM' or preliminaryRiskLevel eq 'Medium'}"><span class="badge bg-warning text-dark fs-6"><i class="fa-solid fa-circle-exclamation me-1"></i>Trung bình</span></c:when>
                                                    <c:when test="${preliminaryRiskLevel eq 'LOW' or preliminaryRiskLevel eq 'Low'}"><span class="badge bg-success fs-6"><i class="fa-solid fa-check-circle me-1"></i>Thấp</span></c:when>
                                                    <c:otherwise><span class="badge bg-secondary fs-6"><c:out value="${empty preliminaryRiskLevel ? '—' : preliminaryRiskLevel}"/></span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="alert alert-warning mb-4">
                                        <div class="d-flex">
                                            <i class="fa-solid fa-circle-info fs-4 me-3 text-warning"></i>
                                            <div>
                                                <h5 class="alert-heading fw-bold mb-1">Lưu ý</h5>
                                                <p class="mb-0 small">Kết quả AI là sơ bộ và cần bác sĩ xác nhận. Báo cáo sàng lọc được tái sử dụng khi đặt lịch — không chạy lại suy luận.</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="d-flex flex-column flex-sm-row justify-content-end align-items-sm-center gap-3">
                                        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/patient/reports/view?id=${bookingReportId}">
                                            <i class="fa-solid fa-file-medical me-2"></i>Xem trạng thái sàng lọc
                                        </a>
                                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/patient/booking?reportId=${bookingReportId}">
                                            Tiếp tục đặt lịch <i class="fa-solid fa-arrow-right ms-2"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- REJECTED panel (Derma) -->
                        <c:if test="${screeningResultStatus eq 'REJECTED'}">
                            <div class="card border-warning shadow-sm mb-4">
                                <div class="card-header bg-warning text-dark py-3">
                                    <h2 class="h5 mb-0 fw-bold"><i class="fa-solid fa-triangle-exclamation me-2"></i>Ảnh chưa đạt chất lượng</h2>
                                </div>
                                <div class="card-body">
                                    <p class="mb-3">
                                        <c:out value="${empty errorMessage ? 'Ảnh không vượt qua kiểm tra chất lượng sàng lọc. Vui lòng chụp lại ảnh rõ, đủ sáng rồi thử lại.' : errorMessage}"/>
                                    </p>
                                    <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/patient/booking">
                                        Đặt lịch không kèm ảnh sàng lọc
                                    </a>
                                </div>
                            </div>
                        </c:if>

                        <!-- Capture form (Derma camera/upload + idempotency) -->
                        <c:if test="${screeningResultStatus ne 'SUCCESS'}">
                            <form id="screeningForm" method="post" action="${pageContext.request.contextPath}/patient/diagnose"
                                  enctype="multipart/form-data"
                                  data-max-upload-bytes="${maxUploadBytes}"
                                  data-screening-available="${screeningAvailable}"
                                  novalidate
                                  onsubmit="if (document.getElementById('loadingOverlay')) { document.getElementById('loadingOverlay').classList.remove('d-none'); document.getElementById('loadingOverlay').style.display='flex'; }">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="idempotencyKey" value="${idempotencyKey}">
                                <input class="d-none" id="skinImage" name="skinImage" type="file" accept="image/*" capture="environment">

                                <div id="captureChoices" class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <button class="capture-choice card w-100 h-100 bg-white text-center p-4" id="chooseImage" type="button">
                                            <i class="fa-solid fa-cloud-arrow-up text-primary fs-2 mb-3"></i>
                                            <span class="fw-semibold d-block">Tải ảnh lên</span>
                                            <span class="small text-muted">Chọn ảnh da rõ nét từ thiết bị</span>
                                        </button>
                                    </div>
                                    <div class="col-md-6">
                                        <button class="capture-choice card w-100 h-100 bg-white text-center p-4" id="openCamera" type="button">
                                            <i class="fa-solid fa-camera-retro text-primary fs-2 mb-3"></i>
                                            <span class="fw-semibold d-block">Chụp ảnh</span>
                                            <span class="small text-muted">Dùng camera sau nếu thiết bị hỗ trợ</span>
                                        </button>
                                    </div>
                                </div>

                                <div id="cameraPanel" class="camera-panel mb-3">
                                    <video id="cameraPreview" autoplay playsinline muted aria-label="Camera preview"></video>
                                    <div class="d-flex flex-wrap gap-2 justify-content-center p-3 bg-dark">
                                        <button class="btn btn-light" id="capturePhoto" type="button"><i class="fa-solid fa-circle-dot me-2 text-danger"></i>Chụp</button>
                                        <button class="btn btn-outline-light" id="cancelCamera" type="button">Hủy</button>
                                    </div>
                                </div>

                                <div id="selectedImagePanel" class="card border mb-4 d-none">
                                    <div class="card-body p-3">
                                        <img id="selectedImagePreview" class="capture-preview rounded w-100" alt="Selected skin photo preview">
                                        <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-2 mt-3">
                                            <span id="selectedImageName" class="small text-muted"></span>
                                            <button class="btn btn-sm btn-outline-secondary" id="replaceImage" type="button"><i class="fa-solid fa-arrows-rotate me-2"></i>Chọn ảnh khác</button>
                                        </div>
                                    </div>
                                </div>

                                <div id="captureError" class="alert alert-warning d-none" role="alert"></div>
                                <p class="small text-muted mb-4">Dùng một ảnh đủ sáng, lấy nét tốt. Máy chủ sẽ kiểm tra định dạng và kích thước trước khi xử lý.</p>

                                <div class="d-flex flex-column flex-sm-row gap-2 justify-content-end">
                                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/patient/booking">Đặt lịch không kèm ảnh</a>
                                    <button class="btn btn-skin btn-lg fw-bold" id="submitScreening" type="submit" ${not screeningAvailable ? 'disabled' : ''}>
                                        <i class="fa-solid fa-wand-magic-sparkles me-2"></i>
                                        ${screeningAvailable ? 'Bắt đầu phân tích AI' : 'AI đang tạm dừng'}
                                    </button>
                                </div>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

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
    const stopCamera = () => {
        if (cameraStream) cameraStream.getTracks().forEach((track) => track.stop());
        cameraStream = undefined;
        cameraPreview.srcObject = null;
        cameraPanel.style.display = 'none';
    };
    const previewFile = (file) => {
        if (!file) return;
        if (!file.type.startsWith('image/')) {
            fileInput.value = '';
            showError('Vui lòng chọn tệp ảnh.');
            return;
        }
        if (Number.isFinite(maxUploadBytes) && file.size > maxUploadBytes) {
            fileInput.value = '';
            showError('Ảnh vượt quá giới hạn dung lượng cho phép.');
            return;
        }
        clearError();
        if (previewUrl) URL.revokeObjectURL(previewUrl);
        previewUrl = URL.createObjectURL(file);
        selectedPreview.src = previewUrl;
        selectedPreview.style.display = 'block';
        selectedName.textContent = file.name;
        selectedPanel.classList.remove('d-none');
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
            cameraPanel.style.display = 'block';
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

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
