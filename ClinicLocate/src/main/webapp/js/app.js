// Geoapify version for comparing with the inline script in location.jsp.
// To test it, load this file from a separate JSP/page that has the same HTML IDs.
const GEOAPIFY_API_KEY = '830c8b879c6b4c918a05603c1558b6d4';
const pathParts = window.location.pathname.split('/').filter(Boolean);
const APP_CONTEXT_PATH = pathParts.length > 1 ? pathParts[0] : '';
const DATABASE_URL = APP_CONTEXT_PATH
    ? '/' + APP_CONTEXT_PATH + '/api/clinic-fallback'
    : '/api/clinic-fallback';

const GEOAPIFY_CONFIG = {
    radius: 20000,
    zoom: 16,
    placesUrl: 'https://api.geoapify.com/v2/places',
    tileUrl: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png',
    retinaTileUrl: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}@2x.png',
    databaseUrl: DATABASE_URL,
    categories: 'healthcare.hospital,healthcare.clinic_or_praxis'
};

let geoMap;
let geoUserLat;
let geoUserLng;
let geoUserMarker;
let geoClinicMarkers = [];
let geoFallbackMode = false;

function locateUser() {
    showLoading('Đang xác định vị trí...');

    if (!navigator.geolocation) {
        showDatabaseClinics('Trình duyệt không hỗ trợ định vị.');
        return;
    }

    navigator.geolocation.getCurrentPosition(
        function (position) {
            geoFallbackMode = false;
            geoUserLat = position.coords.latitude;
            geoUserLng = position.coords.longitude;
            findNearbyClinics();
        },
        function (error) {
            if (error.code === 1) {
                showDatabaseClinics('Bạn đã từ chối chia sẻ vị trí.');
            } else {
                showDatabaseClinics('Không thể lấy vị trí hiện tại.');
            }
        },
        {
            enableHighAccuracy: true,
            timeout: 15000,
            maximumAge: 0
        }
    );
}

async function findNearbyClinics() {
    try {
        showLoading('Đang tìm cơ sở y tế gần bạn bằng Geoapify...');
        showUserOnMap();

        const params = new URLSearchParams({
            categories: GEOAPIFY_CONFIG.categories,
            filter: 'circle:' + geoUserLng + ',' + geoUserLat + ',' + GEOAPIFY_CONFIG.radius,
            bias: 'proximity:' + geoUserLng + ',' + geoUserLat,
            limit: '50',
            lang: 'vi',
            apiKey: GEOAPIFY_API_KEY
        });

        const response = await fetch(GEOAPIFY_CONFIG.placesUrl + '?' + params.toString());
        if (!response.ok) {
            throw new Error('Geoapify API đang bận hoặc không phản hồi.');
        }

        const data = await response.json();
        const displayedCount = displayClinics(normalizeGeoapifyFeatures(data.features || []));
        if (displayedCount === 0) {
            await showDatabaseClinics('Không tìm thấy cơ sở nào trên Geoapify.');
            return;
        }
        hideLoading();
    } catch (error) {
        console.error(error);
        await showDatabaseClinics('Không thể tải dữ liệu từ Geoapify.');
    }
}

function normalizeGeoapifyFeatures(features) {
    return features.map(function (feature) {
        const properties = feature.properties || {};
        const raw = properties.datasource && properties.datasource.raw || {};
        const coordinates = feature.geometry && feature.geometry.coordinates;

        if (!Array.isArray(coordinates) || coordinates.length < 2 || !properties.name) {
            return null;
        }

        const lng = Number(coordinates[0]);
        const lat = Number(coordinates[1]);
        if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
            return null;
        }

        return {
            lat: lat,
            lon: lng,
            tags: {
                name: properties.name,
                amenity: detectFacilityType(properties.categories),
                'contact:address': properties.formatted || buildGeoapifyAddress(properties),
                'contact:phone': properties.contact && properties.contact.phone || raw.phone,
                website: properties.website || raw.website || raw['contact:website'],
                emergency: raw.emergency,
                operator: raw.operator,
                beds: raw.beds,
                'healthcare:speciality': raw['healthcare:speciality']
            }
        };
    }).filter(Boolean);
}

function detectFacilityType(categories) {
    const joined = Array.isArray(categories) ? categories.join('|') : String(categories || '');
    return joined.indexOf('healthcare.hospital') !== -1 ? 'hospital' : 'clinic';
}

function buildGeoapifyAddress(properties) {
    return [
        properties.housenumber,
        properties.street,
        properties.district || properties.suburb,
        properties.city || properties.county || properties.state
    ].filter(Boolean).join(', ');
}

async function showDatabaseClinics(reason) {
    try {
        showLoading('Đang tải danh sách cơ sở y tế dự phòng...');
        const response = await fetch(GEOAPIFY_CONFIG.databaseUrl);
        if (!response.ok) {
            throw new Error('Cơ sở dữ liệu không phản hồi.');
        }

        const clinics = await response.json();
        geoFallbackMode = true;
        const hasUserLocation = Number.isFinite(geoUserLat) && Number.isFinite(geoUserLng);
        if (!hasUserLocation) {
            geoUserLat = undefined;
            geoUserLng = undefined;
        }

        const elements = clinics.map(function (clinic) {
            return {
                lat: Number(clinic.latitude),
                lon: Number(clinic.longitude),
                tags: {
                    name: clinic.name,
                    amenity: clinic.type === 'HOSPITAL' ? 'hospital' : 'clinic',
                    'contact:address': clinic.address,
                    'contact:phone': clinic.phone,
                    website: clinic.website
                }
            };
        });

        ensureFallbackMap();
        const displayedCount = displayClinics(elements);
        document.getElementById('main-title').textContent = 'Cơ sở y tế từ dữ liệu hệ thống';
        document.getElementById('location-text').textContent = reason;

        if (displayedCount === 0) {
            showError('Cơ sở dữ liệu chưa có cơ sở y tế có tọa độ hợp lệ.');
            return;
        }
        hideLoading();
    } catch (error) {
        console.error(error);
        showError('Không thể tải dữ liệu cơ sở y tế dự phòng.');
    }
}

function ensureFallbackMap() {
    if (!geoMap) {
        geoMap = L.map('map').setView([16.0, 106.0], 6);
        addGeoapifyTileLayer();
    }

    const hasUserLocation = Number.isFinite(geoUserLat) && Number.isFinite(geoUserLng);
    if (geoUserMarker && !hasUserLocation) {
        geoMap.removeLayer(geoUserMarker);
        geoUserMarker = null;
    }
}

function showUserOnMap() {
    if (!geoMap) {
        geoMap = L.map('map').setView([geoUserLat, geoUserLng], GEOAPIFY_CONFIG.zoom);
        addGeoapifyTileLayer();
    } else {
        geoMap.setView([geoUserLat, geoUserLng], GEOAPIFY_CONFIG.zoom);
    }

    if (geoUserMarker) {
        geoMap.removeLayer(geoUserMarker);
    }

    geoUserMarker = L.marker([geoUserLat, geoUserLng])
        .addTo(geoMap)
        .bindPopup('<b>Vị trí hiện tại của bạn</b>')
        .openPopup();

    document.getElementById('main-title').textContent = 'Cơ sở y tế gần bạn';
    document.getElementById('location-text').textContent =
        'Vị trí: ' + geoUserLat.toFixed(5) + ', ' + geoUserLng.toFixed(5);
}

function addGeoapifyTileLayer() {
    const tileUrl = L.Browser.retina ? GEOAPIFY_CONFIG.retinaTileUrl : GEOAPIFY_CONFIG.tileUrl;
    L.tileLayer(tileUrl, {
        attribution: 'Powered by <a href="https://www.geoapify.com/" target="_blank">Geoapify</a> | <a href="https://openmaptiles.org/" target="_blank">&copy; OpenMapTiles</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>',
        apiKey: GEOAPIFY_API_KEY,
        maxZoom: 20
    }).addTo(geoMap);
}

function displayClinics(elements) {
    geoClinicMarkers.forEach(function (marker) {
        geoMap.removeLayer(marker);
    });
    geoClinicMarkers = [];

    let clinics = elements.map(function (element) {
        const tags = element.tags || {};
        const lat = element.lat !== undefined
            ? element.lat
            : element.center && element.center.lat;
        const lng = element.lon !== undefined
            ? element.lon
            : element.center && element.center.lon;

        if (!Number.isFinite(Number(lat))
            || !Number.isFinite(Number(lng))
            || !tags.name) {
            return null;
        }

        const isHospital = tags.amenity === 'hospital' || tags.healthcare === 'hospital';
        const address = buildAddress(tags);

        return {
            name: tags.name,
            address: address,
            phone: buildPhone(tags),
            website: buildWebsite(tags),
            searchUrl: buildClinicSearchUrl(tags.name, address),
            type: isHospital ? 'hospital' : 'clinic',
            lat: Number(lat),
            lng: Number(lng),
            score: calculateFacilityScore(tags)
        };
    }).filter(Boolean);

    if (geoFallbackMode) {
        clinics.sort(function (first, second) {
            return second.score - first.score;
        });
        clinics = clinics.slice(0, 20);
    }

    document.getElementById('stats-text').innerHTML = geoFallbackMode
        ? 'Danh sách cơ sở y tế dự phòng từ hệ thống'
        : 'Tìm thấy <span id="total-count">' + clinics.length + '</span> cơ sở y tế gần bạn';
    const clinicList = document.getElementById('clinic-list');

    if (clinics.length === 0) {
        clinicList.innerHTML = '<p class="empty">Không tìm thấy bệnh viện hoặc phòng khám trong khu vực này.</p>';
        return 0;
    }

    const hasUserLocation = Number.isFinite(geoUserLat) && Number.isFinite(geoUserLng);
    const bounds = hasUserLocation
        ? L.latLngBounds([[geoUserLat, geoUserLng]])
        : L.latLngBounds([]);
    let html = '';

    clinics.forEach(function (clinic) {
        const externalUrl = clinic.website || clinic.searchUrl;
        const externalLabel = clinic.website ? 'Website' : 'Tìm website';
        const websiteLink = externalUrl
            ? '<br><a href="' + escapeHtml(externalUrl) + '" target="_blank" rel="noopener noreferrer">' + externalLabel + '</a>'
            : '';
        const cardWebsiteLink = externalUrl
            ? '<a class="card-website" href="' + escapeHtml(externalUrl) + '" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">' + externalLabel + '</a>'
            : '';
        const marker = L.marker([clinic.lat, clinic.lng])
            .addTo(geoMap)
            .bindPopup(
                '<b>' + escapeHtml(clinic.name) + '</b><br>'
                + 'Địa chỉ: ' + escapeHtml(clinic.address) + '<br>'
                + 'Điện thoại: ' + escapeHtml(clinic.phone)
                + websiteLink
            );

        geoClinicMarkers.push(marker);
        bounds.extend([clinic.lat, clinic.lng]);

        html += '<div class="clinic-card" role="button" tabindex="0" onclick="focusClinic('
            + clinic.lat + ',' + clinic.lng + ')" onkeydown="handleClinicCardKey(event,'
            + clinic.lat + ',' + clinic.lng + ')">'
            + '<span class="card-type ' + clinic.type + '">'
            + (clinic.type === 'hospital' ? 'Bệnh viện: ' : 'Phòng khám: ')
            + '</span>'
            + '<span class="card-name">' + escapeHtml(clinic.name) + '</span>'
            + '<span class="card-address">' + escapeHtml(clinic.address) + '</span>'
            + '<span class="card-address">Điện thoại: ' + escapeHtml(clinic.phone) + '</span>'
            + cardWebsiteLink
            + '</div>';
    });

    clinicList.innerHTML = html;
    geoMap.fitBounds(bounds, { padding: [40, 40] });
    return clinics.length;
}

function focusClinic(lat, lng) {
    geoMap.flyTo([lat, lng], 17);
}

function handleClinicCardKey(event, lat, lng) {
    if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        focusClinic(lat, lng);
    }
}

function buildAddress(tags) {
    const street = [tags['addr:housenumber'], tags['addr:street']]
        .filter(Boolean)
        .join(' ');
    const area = tags['addr:district'] || tags['addr:suburb'];
    const city = tags['addr:city'] || tags['addr:province'];
    const address = [street, area, city].filter(Boolean).join(', ');

    return address || tags['contact:address'] || 'Chưa có địa chỉ chi tiết';
}

function buildPhone(tags) {
    return tags.phone
        || tags['contact:phone']
        || tags['contact:mobile']
        || 'Chưa có số điện thoại';
}

function buildWebsite(tags) {
    const website = tags.website
        || tags['contact:website']
        || tags.url
        || tags['contact:url'];
    if (!website) {
        return '';
    }

    const normalized = String(website).trim();
    if (!normalized) {
        return '';
    }

    if (/^https?:\/\//i.test(normalized)) {
        return normalized;
    }

    return 'https://' + normalized;
}

function buildClinicSearchUrl(name, address) {
    const query = [name, address, 'website']
        .filter(Boolean)
        .join(' ');

    return 'https://www.google.com/search?q=' + encodeURIComponent(query);
}

function calculateFacilityScore(tags) {
    let score = 0;
    if (tags.emergency === 'yes') score += 4;
    if (tags.operator) score += 2;
    if (tags.website || tags['contact:website']) score += 2;
    if (tags.beds) score += 1;
    if (tags['healthcare:speciality']) score += 1;
    return score;
}

function showLoading(message) {
    document.getElementById('loading-text').textContent = message;
    document.getElementById('retry-button').classList.add('hidden');
    document.getElementById('loading-overlay').style.display = 'flex';
}

function hideLoading() {
    document.getElementById('loading-overlay').style.display = 'none';
}

function showError(message) {
    document.getElementById('loading-text').textContent = message;
    document.getElementById('retry-button').classList.remove('hidden');
    document.getElementById('loading-overlay').style.display = 'flex';
}

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

locateUser();


