let map;
let userLat;
let userLng;
let userMarker;
let clinicMarkers = [];

navigator.geolocation.getCurrentPosition(
    function (position) {
        userLat = position.coords.latitude;
        userLng = position.coords.longitude;
        console.log(userLat+', ' + userLng);
    },function (error) {
        console.log(error);
    });