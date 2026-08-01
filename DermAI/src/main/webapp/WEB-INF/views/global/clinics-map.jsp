<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css" crossorigin="" />
<style>
    #clinic-map { min-height: 540px; border-radius: 1rem; }
    .clinic-map-popup { min-width: 190px; }
</style>

<div class="bg-light py-5">
    <div class="container mt-4">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
            <div>
                <a href="${pageContext.request.contextPath}/global/clinics" class="text-decoration-none small text-muted">
                    <i class="fa-solid fa-arrow-left me-2"></i>Quay lại danh sách phòng khám
                </a>
                <h1 class="h2 fw-bold text-dark mt-2 mb-1">Bản đồ phòng khám</h1>
                <p class="text-muted mb-0">Chọn một điểm đánh dấu để xem thông tin phòng khám.</p>
            </div>
            <a href="${pageContext.request.contextPath}/global/clinics" class="btn btn-outline-primary rounded-pill px-4">Xem dạng danh sách</a>
        </div>

        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
            <div class="card-body p-3">
                <div id="clinic-map" role="region" aria-label="Bản đồ vị trí phòng khám"></div>
                <p id="clinic-map-empty" class="text-muted text-center py-5 mb-0 d-none">
                    Chưa có phòng khám nào có tọa độ hợp lệ để hiển thị trên bản đồ.
                </p>
            </div>
        </div>

        <ul id="clinic-markers" class="d-none"
            data-context-path="<c:out value='${pageContext.request.contextPath}'/>"
            data-selected-id="<c:out value='${selectedClinicId}'/>">
            <c:forEach var="clinic" items="${clinics}">
                <li data-id="<c:out value='${clinic.id}'/>"
                    data-name="<c:out value='${clinic.clinicName}'/>"
                    data-address="<c:out value='${clinic.address}'/>"
                    data-specialty="<c:out value='${clinic.specialty}'/>"
                    data-latitude="${clinic.latitude}"
                    data-longitude="${clinic.longitude}"></li>
            </c:forEach>
        </ul>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const markerList = document.getElementById('clinic-markers');
        const mapElement = document.getElementById('clinic-map');
        const emptyMessage = document.getElementById('clinic-map-empty');
        const contextPath = markerList.dataset.contextPath;
        const selectedId = markerList.dataset.selectedId;
        const clinics = Array.from(markerList.children).map(function (element) {
            return {
                id: element.dataset.id,
                name: element.dataset.name,
                address: element.dataset.address,
                specialty: element.dataset.specialty,
                latitude: Number(element.dataset.latitude),
                longitude: Number(element.dataset.longitude)
            };
        }).filter(function (clinic) {
            return Number.isFinite(clinic.latitude) && Number.isFinite(clinic.longitude)
                && Math.abs(clinic.latitude) <= 90 && Math.abs(clinic.longitude) <= 180
                && !(clinic.latitude === 0 && clinic.longitude === 0);
        });

        if (typeof L === 'undefined') {
            mapElement.classList.add('d-none');
            emptyMessage.textContent = 'Không thể tải thư viện bản đồ. Vui lòng kiểm tra kết nối mạng hoặc cho phép tải tài nguyên bản đồ.';
            emptyMessage.classList.remove('d-none');
            return;
        }

        if (clinics.length === 0) {
            mapElement.classList.add('d-none');
            emptyMessage.classList.remove('d-none');
            return;
        }

        const map = L.map('clinic-map');
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        const bounds = [];
        let selectedMarker;
        clinics.forEach(function (clinic) {
            const marker = L.marker([clinic.latitude, clinic.longitude]).addTo(map);
            const popup = document.createElement('div');
            popup.className = 'clinic-map-popup';

            const name = document.createElement('strong');
            name.textContent = clinic.name;
            popup.appendChild(name);

            if (clinic.specialty) {
                const specialty = document.createElement('div');
                specialty.className = 'small text-muted mt-1';
                specialty.textContent = clinic.specialty;
                popup.appendChild(specialty);
            }

            const address = document.createElement('div');
            address.className = 'small mt-2';
            address.textContent = clinic.address;
            popup.appendChild(address);

            const detail = document.createElement('a');
            detail.className = 'btn btn-sm btn-primary mt-2';
            detail.href = contextPath + '/global/clinics/detail?id=' + encodeURIComponent(clinic.id);
            detail.textContent = 'Xem chi tiết';
            popup.appendChild(detail);

            marker.bindPopup(popup);
            bounds.push([clinic.latitude, clinic.longitude]);
            if (clinic.id === selectedId) {
                selectedMarker = marker;
            }
        });

        if (selectedMarker) {
            map.setView(selectedMarker.getLatLng(), 16);
            selectedMarker.openPopup();
        } else if (bounds.length === 1) {
            map.setView(bounds[0], 15);
        } else {
            map.fitBounds(bounds, { padding: [32, 32] });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
