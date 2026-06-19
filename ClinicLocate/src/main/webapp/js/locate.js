let map;
let userLat;
let userLng;
let userMarker;
let clinicMarkers = [];
let fallback = false;

const CONFIG = {
    radius: 15000, // Radius in meters
    zoom: 14, // Zoom level for the map
    recommendedRadius: 25000, // Recommended radius in meters
    mapTilerAPI: 'DQhKue8zixGpuVf943EY', // MapTiler API key
    overpassUrl: 'https://overpass-api.de/api/interpreter', // Overpass API endpoint
    databaseUrl: '${pathContext.request.contextPath}/api/clinics-fallback' // Database API endpoint
}
function locateUser() {
    showLoading('Đang định vị vị trí bạn ....');
    if (!navigator.geolocation) {
        showDatabaseClinics('Trình duyệt không hỗ trợ định vị')
        return;
    }
    navigator.geolocation.getCurrentPosition(
        function (position) {
            fallback = false;
            userLat = position.coords.latitude;
            userLng = position.coords.longitude;
            findNearbyClinic();

        }, function (error) {
            if (error.code === 1) {
                showDatabaseClinics('Bạn đã từ chối chia sẻ vị trí.');
                return;
            }

            showDatabaseClinics('Không thể lấy vị trí hiện tại.');
        },
        {
            enableHighAccuracy: true,
            timeout: 15000,
            maximumAge: 0
        }
    )
}
// Gửi truy vấn đến Overpass API để lấy dữ liệu OpenStreetMap.
// "amenity" và "healthcare" là hai khóa OSM có thể mô tả cùng một cơ sở y tế:
// - amenity=hospital/clinic/doctors
// - healthcare=hospital/clinic/doctor
// Cần truy vấn cả hai khóa để không bỏ sót bệnh viện hoặc phòng khám.
async function findNearbyClinic() {
    try {
        showLoading('Đang tìm cơ sở ý tế bạn...');
        showUserOnMap();
        const rad = CONFIG.radius
        const amenityPatt = 'hospital|clinic|doctor';
        const healthcarePatt = 'hospital|clinic|doctor';
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
            body: 'data=' + encodeURIComponent(query),
        });
        if (!response.ok) {
            throw new Error('Hiện API đang không phản hồi. Vui lòng thử lại.');
        }
        const data = await response.json();
        const displayCount = displayClinics(data.elements);
        if (displayedCount === 0) {
            await showDatabaseClinics('Không tìm thấy cơ sở phù hợp trên OpenStreetMap.');
        }
    } catch (error) {
        console.log(error);
        await showDatabaseClinics('Không thể tải dữ liệu từ OpenStreetMap.');
    }
}
//ghép các địa chỉ với nhau
function buildAddress(tags){
    //đưa số nhà và tên đường vào cùng 1 mảng, nếu 1 cái empty hoặc null
    //thì boolean sẽ bỏ cái đó và để khoảng trống
    const street = [tags['addr:housenumber'],tags['addr:street']].filter(Boolean).join(' ');
    const area = tags['addr:district']||tags['addr:suburb'];
    const city = tags['addr:city']||tags['addr:province'];
    const address = [street, area,city].filter(Boolean).join(', ');
    return address || tags['contact:address'] || 'Chưa có địa chỉ chi tiết';
}

function buildPhone(tags) {
    return tags.phone
        || tags['contact:phone']
        || tags['contact:mobile']
        || 'Chưa có số điện thoại';
}

async function showDatabaseClinics(reason) {
    try {
        showLoading('Đang tải dữ liệu dự phòng');
        const response = await fetch(CONFIG.databaseUrl);
        if (!response.ok) {
            throw new Error('Database API không phản hồi.');
        }
        const clinic = await response.json();
        userLat = undefined;
        userLng = undefined;

        const elements = clinic.map(function (clinic) {
            return {
                lat: clinic.lat,
                lng: clinic.lng,
                tags: {
                    name: clinic.name,
                    amenity: clinic.type === 'HOSPITAL' ? 'hospital' : 'clinic',
                    'contact:address': clinic.address,
                    'contact:phone': clinic.phone
                }
            };

        });
        ensureFallback();
        const displayedCount = displayClinics(elements);
        document.getElementById('main-title').textContent = 'Cơ sở y tế từ dữ liệu hệ thống';
        document.getElementById('location-text').textContent = reason;

        if (displayedCount === 0) {
            showError('Database chưa có cơ sở y tế có tọa độ hợp lệ.');
            return;
        }
        hideLoading();
    } catch (error) {
        console.error(error);
        showError('không thể tải dữ liệu dự phòng')
    }
}
function ensureFallbackMap() {
    if (!map) {
        map = L.map('map').setView([16.0, 106.0], 6);
        L.titleLayer(
            'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=' + CONFIG.maptilerKey,
            {
                attribution: '<a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>',
                maxZoom: 20,
            }
        ).addTo(map);
    }
    if (userMarker) {
        map.removeLayer(userMarker);
        userMarker = null;
    }

}
function showUserOnMap() {
    if (!map) {
        map = L.map('map').setView([userLat, userLng], CONFIG.zoom);
        L.titleLayer(
            'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=' + CONFIG.maptilerKey,
            {
                attribution: '<a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>',
                maxZoom: 20
            }
        ).addTo(map);
    }
    if (userMarker) {
        map.removeLayer(userMarker);
    }
    userMarker = L.marker([userLat, userLng]).addTo(map).bindPopup('<b>Vị trí hiện tại của bạn</b>')
        .openPopup();
    document.getElementById('main-title').textContent = 'Cơ sở y tế gần bạn';
    document.getElementById('location-text').textContent =
        'Vị trí: ' + userLat.toFixed(5) + ', ' + userLng.toFixed(5);
}

//bay đến vị trí của cơ sở y tế được chọn
function flyToClinic(lat, lng) {
    if (map) {
        map.flyTo([lat, lng], 17);
    }
}
// Hiển thị lỗi và cho phép người dùng thực hiện lại thao tác định vị.
function showError(message) {
    document.getElementById('loading-text').textContent = message;
    document.getElementById('retry-button').classList.remove('hidden');
    document.getElementById('loading-overlay').style.display = 'flex';
}
function showLoading(message) {
    document.getElementById('loading-text').textContent = message;
    document.getElementById('retry-button').style.display = 'none';
    document.getElementById('loading-overlay').style.display = 'flex';
}

