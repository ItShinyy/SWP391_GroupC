let map;
let userLat;
let userLng;
let userMarker;
let clinicMarkers = [];

const CONFIG = {
    radius: 15000, // Radius in meters
    zoom:14, // Zoom level for the map
    recommendedRadius: 25000, // Recommended radius in meters
    mapTilerAPI: 'DQhKue8zixGpuVf943EY' // MapTiler API key
    overpassUrl: 'https://overpass-api.de/api/interpreter' // Overpass API endpoint
    databaseUrl: '${pathContext.request.contextPath}/api/clinics-fallback' // Database API endpoint
    ipLocationUrl: 'https://ipapi.co/json/' // IP-based geolocation API endpoint
};