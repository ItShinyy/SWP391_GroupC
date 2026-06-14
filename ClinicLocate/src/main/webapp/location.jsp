<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ClinicLocate - Cơ sở y tế gần bạn</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="map-page">
    <div class="loading-overlay" id="loading-overlay">
        <div class="loading-logo">+</div>
        <div class="spinner"></div>
        <p id="loading-text">Đang xác định vị trí...</p>
        <button type="button" class="primary-btn hidden" id="retry-button" onclick="locateUser()">
            Thử lại
        </button>
    </div>

    <div class="app-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-brand-row">
                    <a class="brand" href="index.jsp">
                        <span class="brand-icon">+</span><span>Clinic<span>Locate</span></span>
                    </a>
                    <a class="back-link" href="index.jsp">← Trang chủ</a>
                </div>
                <span class="title-label">Khám phá khu vực</span>
                <h1 id="main-title">Cơ sở y tế gần bạn</h1>
                <p id="location-text">Đang xác định vị trí hiện tại...</p>
            </div>

            <div class="search-box">
                <button type="button" onclick="locateUser()"><span class="refresh-icon"></span>Cập nhật vị trí</button>
            </div>

            <div class="stats" id="stats-text">
                 <span id="total-count">0</span> cơ sở y tế gần bạn
            </div>
            <div class="clinic-list" id="clinic-list"></div>
        </aside>

        <div class="map-container">
            <div id="map"></div>
            <div class="map-corner-note">Nhấn vào một cơ sở để xem vị trí</div>
        </div>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

    <script>
        // Cấu hình chung cho bản đồ, phạm vi tìm kiếm và các API bên ngoài.
        const CONFIG = {
            radius: 10000,
            recommendationRadius: 25000,
            zoom: 14,
            maptilerKey: 'DQhKue8zixGpuVf943EY',
            overpassUrl: 'https://overpass-api.de/api/interpreter',
            ipLocationUrls: [
                'https://ipapi.co/json/',
                'https://ipwho.is/'
            ]
        };

        // Trạng thái bản đồ và tọa độ đang được dùng để tìm cơ sở y tế.
        let map;
        let userLat;
        let userLng;
        let userMarker;
        let clinicMarkers = [];
        let recommendationMode = false;
        let detectedCity = '';

        // Ưu tiên lấy vị trí chính xác từ trình duyệt.
        // Nếu người dùng từ chối cấp quyền, ứng dụng chuyển sang vị trí gần đúng theo IP.
        function locateUser() {
            showLoading('Đang xác định vị trí...');

            if (!navigator.geolocation) {
                suggestHealthcareByCity();
                return;
            }

            navigator.geolocation.getCurrentPosition(
                function (position) {
                    recommendationMode = false;
                    detectedCity = '';
                    userLat = position.coords.latitude;
                    userLng = position.coords.longitude;
                    findNearbyClinics();
                },
                function (error) {
                    if (error.code === 1) {
                        suggestHealthcareByCity();
                        return;
                    }

                    showError('Không thể lấy vị trí hiện tại. Vui lòng thử lại.');
                },
                {
                    enableHighAccuracy: true,
                    timeout: 15000,
                    maximumAge: 0
                }
            );
        }

        // Xác định thành phố gần đúng và tìm cả bệnh viện lẫn phòng khám trong thành phố đó.
        async function suggestHealthcareByCity() {
            try {
                showLoading('Đang xác định thành phố gần đúng để gợi ý cơ sở y tế...');

                const location = await getApproximateCity();

                recommendationMode = true;
                detectedCity = location.city || location.region || 'khu vực của bạn';
                userLat = Number(location.latitude);
                userLng = Number(location.longitude);
                findNearbyClinics();
            } catch (error) {
                console.error(error);
                showError('Không thể xác định thành phố gần đúng để gợi ý cơ sở y tế. Vui lòng thử lại.');
            }
        }

        // Thử lần lượt nhiều dịch vụ định vị IP. Dịch vụ đầu tiên trả về tọa độ hợp lệ sẽ được dùng.
        async function getApproximateCity() {
            for (const url of CONFIG.ipLocationUrls) {
                try {
                    const response = await fetch(url);
                    if (!response.ok) continue;

                    const data = await response.json();
                    const latitude = Number(data.latitude);
                    const longitude = Number(data.longitude);

                    if (Number.isFinite(latitude) && Number.isFinite(longitude)) {
                        return {
                            city: data.city,
                            region: data.region,
                            latitude: latitude,
                            longitude: longitude
                        };
                    }
                } catch (error) {
                    console.warn('IP location provider failed:', url, error);
                }
            }

            throw new Error('All IP location providers failed.');
        }

        // Gửi truy vấn đến Overpass API để lấy dữ liệu OpenStreetMap.
        // "amenity" và "healthcare" là hai khóa OSM có thể mô tả cùng một cơ sở y tế:
        // - amenity=hospital/clinic/doctors
        // - healthcare=hospital/clinic/doctor
        // Cần truy vấn cả hai khóa để không bỏ sót bệnh viện hoặc phòng khám.
        async function findNearbyClinics() {
            try {
                showLoading(recommendationMode
                    ? 'Đang tìm bệnh viện và phòng khám tại ' + detectedCity + '...'
                    : 'Đang tìm cơ sở y tế gần bạn...');
                showUserOnMap();

                const radius = recommendationMode ? CONFIG.recommendationRadius : CONFIG.radius;
                const amenityPattern = 'hospital|clinic|doctors';
                const healthcarePattern = 'hospital|clinic|doctor';

                // nwr tìm trên cả node, way và relation. "out center tags" trả về
                // tọa độ trung tâm và các thuộc tính như tên, địa chỉ, loại cơ sở.
                const query = '[out:json][timeout:25];'
                    + '('
                    + 'nwr(around:' + radius + ',' + userLat + ',' + userLng + ')["amenity"~"^(' + amenityPattern + ')$"];'
                    + 'nwr(around:' + radius + ',' + userLat + ',' + userLng + ')["healthcare"~"^(' + healthcarePattern + ')$"];'
                    + ');'
                    + 'out center tags;';

                const response = await fetch(CONFIG.overpassUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: 'data=' + encodeURIComponent(query)
                });

                if (!response.ok) {
                    throw new Error('Overpass API đang bận hoặc không phản hồi. Vui lòng thử lại.');
                }

                const data = await response.json();
                displayClinics(data.elements || []);
                hideLoading();
            } catch (error) {
                console.error(error);
                showError(error.message || 'Không thể tìm cơ sở y tế.');
            }
        }

        // Khởi tạo Leaflet một lần, sau đó chỉ cập nhật tâm bản đồ và marker vị trí.
        function showUserOnMap() {
            if (!map) {
                map = L.map('map').setView([userLat, userLng], CONFIG.zoom);

                L.tileLayer(
                    'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=' + CONFIG.maptilerKey,
                    {
                        attribution: '<a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>',
                        maxZoom: 20
                    }
                ).addTo(map);
            } else {
                map.setView([userLat, userLng], CONFIG.zoom);
            }

            if (userMarker) {
                map.removeLayer(userMarker);
            }

            userMarker = L.marker([userLat, userLng])
                .addTo(map)
                .bindPopup(recommendationMode
                    ? '<b>Vị trí gần đúng của ' + escapeHtml(detectedCity) + '</b>'
                    : '<b>Vị trí hiện tại của bạn</b>')
                .openPopup();

            document.getElementById('main-title').textContent = recommendationMode
                ? 'Cơ sở y tế được gợi ý tại ' + detectedCity
                : 'Cơ sở y tế gần bạn';
            document.getElementById('location-text').textContent = recommendationMode
                ? 'Đang hiển thị gợi ý theo vị trí gần đúng tại ' + detectedCity + '.'
                : 'Vị trí: ' + userLat.toFixed(5) + ', ' + userLng.toFixed(5);
        }

        // Chuẩn hóa dữ liệu OSM, tạo marker và dựng danh sách bệnh viện/phòng khám.
        function displayClinics(elements) {
            // Xóa marker của lần tìm trước để tránh hiển thị dữ liệu cũ trên bản đồ.
            clinicMarkers.forEach(function (marker) {
                map.removeLayer(marker);
            });
            clinicMarkers = [];

            let clinics = elements.map(function (element) {
                const tags = element.tags || {};
                const lat = element.lat !== undefined
                    ? element.lat
                    : element.center && element.center.lat;
                const lng = element.lon !== undefined
                    ? element.lon
                    : element.center && element.center.lon;

                if (lat === undefined || lng === undefined || !tags.name) {
                    return null;
                }

                // Cơ sở có một trong hai khóa mang giá trị hospital được xem là bệnh viện.
                // Các kết quả clinic, doctor hoặc doctors được hiển thị là phòng khám.
                const isHospital = tags.amenity === 'hospital' || tags.healthcare === 'hospital';

                return {
                    name: tags.name,
                    address: buildAddress(tags),
                    type: isHospital ? 'hospital' : 'clinic',
                    lat: lat,
                    lng: lng,
                    score: calculateFacilityScore(tags)
                };
            }).filter(Boolean);

            if (recommendationMode) {
                clinics.sort(function (first, second) {
                    return second.score - first.score;
                });
            }

            if (recommendationMode) {
                clinics = clinics.slice(0, 20);
            }

            document.getElementById('stats-text').innerHTML = recommendationMode
                ? 'Gợi ý bệnh viện và phòng khám tại ' + escapeHtml(detectedCity)
                : 'Tìm thấy <span id="total-count">' + clinics.length + '</span> cơ sở y tế gần bạn';
            const clinicList = document.getElementById('clinic-list');

            if (clinics.length === 0) {
                clinicList.innerHTML = '<p class="empty">Không tìm thấy bệnh viện hoặc phòng khám trong khu vực này.</p>';
                return;
            }

            const bounds = L.latLngBounds([[userLat, userLng]]);
            let html = '';

            clinics.forEach(function (clinic) {
                const marker = L.marker([clinic.lat, clinic.lng])
                    .addTo(map)
                    .bindPopup('<b>' + escapeHtml(clinic.name) + '</b><br>' + escapeHtml(clinic.address));

                clinicMarkers.push(marker);
                bounds.extend([clinic.lat, clinic.lng]);

                html += '<button class="clinic-card" type="button" onclick="focusClinic('
                    + clinic.lat + ',' + clinic.lng + ')">'
                    + '<span class="card-type ' + clinic.type + '">'
                    + (clinic.type === 'hospital' ? 'Bệnh viện: ' : 'Phòng khám: ')
                    + '</span>'
                    + '<span class="card-name">' + escapeHtml(clinic.name) + '</span>'
                    + '<span class="card-address">' + escapeHtml(clinic.address) + '</span>'
                    + '</button>';
            });

            clinicList.innerHTML = html;
            map.fitBounds(bounds, { padding: [40, 40] });
        }

        // Di chuyển bản đồ đến cơ sở được chọn trong danh sách.
        function focusClinic(lat, lng) {
            map.flyTo([lat, lng], 17);
        }

        // Ghép các trường địa chỉ rời rạc của OpenStreetMap thành một chuỗi dễ đọc.
        function buildAddress(tags) {
            const street = [tags['addr:housenumber'], tags['addr:street']]
                .filter(Boolean)
                .join(' ');
            const area = tags['addr:district'] || tags['addr:suburb'];
            const city = tags['addr:city'] || tags['addr:province'];
            const address = [street, area, city].filter(Boolean).join(', ');

            return address || tags['contact:address'] || 'Chưa có địa chỉ chi tiết';
        }

        // Chấm điểm mức độ đầy đủ/nổi bật của cơ sở để sắp xếp danh sách gợi ý thành phố.
        // Điểm này không phải đánh giá chất lượng y khoa; nó chỉ dựa trên dữ liệu OSM hiện có.
        function calculateFacilityScore(tags) {
            let score = 0;
            if (tags.emergency === 'yes') score += 4;
            if (tags.operator) score += 2;
            if (tags.website || tags['contact:website']) score += 2;
            if (tags.beds) score += 1;
            if (tags['healthcare:speciality']) score += 1;
            return score;
        }

        // Hiển thị lớp chờ và ẩn nút thử lại trong lúc đang xử lý.
        function showLoading(message) {
            document.getElementById('loading-text').textContent = message;
            document.getElementById('retry-button').classList.add('hidden');
            document.getElementById('loading-overlay').style.display = 'flex';
        }

        // Đóng lớp chờ sau khi dữ liệu đã được hiển thị.
        function hideLoading() {
            document.getElementById('loading-overlay').style.display = 'none';
        }

        // Hiển thị lỗi và cho phép người dùng thực hiện lại thao tác định vị.
        function showError(message) {
            document.getElementById('loading-text').textContent = message;
            document.getElementById('retry-button').classList.remove('hidden');
            document.getElementById('loading-overlay').style.display = 'flex';
        }

        // Mã hóa dữ liệu lấy từ API trước khi chèn vào HTML để tránh chèn mã độc vào trang.
        function escapeHtml(value) {
            return String(value).replace(/[&<>"']/g, function (character) {
                return {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                }[character];
            });
        }

        // Tự động bắt đầu định vị ngay khi trang tải xong.
        locateUser();
    </script>
</body>
</html>
