<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<link rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
      crossorigin="">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/clinic-locator.css">

<main class="clinic-locator-page">
    <div class="locator-loading" id="loading-overlay" role="status" aria-live="polite">
        <div class="locator-loading-icon"><i class="fa-solid fa-location-dot"></i></div>
        <div class="locator-spinner"></div>
        <p id="loading-text">Đang xác định vị trí của bạn...</p>
        <button type="button" class="locator-primary-button hidden" id="retry-button" onclick="locateUser()">
            <i class="fa-solid fa-rotate-right"></i> Thử lại
        </button>
    </div>

    <section class="locator-shell" aria-label="Định vị cơ sở y tế">
        <aside class="locator-sidebar">
            <header class="locator-heading">
                <span class="locator-eyebrow"><i class="fa-solid fa-location-crosshairs"></i> Khám phá khu vực</span>
                <h1 id="main-title">Cơ sở y tế gần bạn</h1>
                <p id="location-text">Cho phép trình duyệt sử dụng vị trí để tìm bệnh viện và phòng khám xung quanh.</p>
            </header>

            <div class="locator-actions">
                <button type="button" class="locator-primary-button" onclick="locateUser()">
                    <i class="fa-solid fa-location-crosshairs"></i> Cập nhật vị trí
                </button>
            </div>

            <div class="locator-stats" id="stats-text">
                <span id="total-count">0</span> cơ sở y tế gần bạn
            </div>
            <div class="locator-list" id="clinic-list"></div>
        </aside>

        <div class="locator-map-wrap">
            <div id="map" aria-label="Bản đồ bệnh viện và phòng khám"></div>
            <div class="locator-map-note">
                <i class="fa-solid fa-hand-pointer"></i> Chọn một cơ sở để xem vị trí
            </div>
        </div>
    </section>
</main>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
        crossorigin=""></script>
<script src="${pageContext.request.contextPath}/assets/javascript/app.js"></script>

</body>
</html>
