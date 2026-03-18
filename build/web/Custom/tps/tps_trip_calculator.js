
/**
 * @description TPS Trip Calculator Map
 * @file        tps_trip_calculator.js
 * @author      Sunil
 */

$('head').append('<script type=\"text/javascript\" src=\"https://polyfill.io/v3/polyfill.min.js?features=default\"></script>');

var waypts = [];
var ways = [];
var directionsService;
var directionsRenderer;
var directionsRenderer2;
var directionsRenderer3;
var existSimpleMarker = {};
var points = 0;
var markerStack = [];
var tripMap;
var gDistance, gTimeInMins, gHookRate, gWaitingRate, gTripRate, gTotalTripRate;

var line1Result = '';
var line2Result = '';
var line3Result = '';
    
function initTripMap() 
{
    tripMap = new google.maps.Map(document.getElementById("trip-map"), {
        zoom: 12,
        center: {
            lat: 1.357739,
            lng: 103.825788
        },
        fullscreenControl: false
    });

    const twoPointsDiv = document.createElement("div");

    pointsControl(twoPointsDiv, tripMap, '2 Points', 'Click To set 2 Points on Map', setPoints, 2, 'point-div');

    tripMap.controls[google.maps.ControlPosition.TOP_LEFT].push(twoPointsDiv);
    
    const threePointsDiv = document.createElement("div");

    pointsControl(threePointsDiv, tripMap, '3 Points', 'Click To set 3 Points on Map', setPoints, 3, 'point-div');

    tripMap.controls[google.maps.ControlPosition.TOP_LEFT].push(threePointsDiv);

    const undoMarkerDiv = document.createElement("div");

    pointsControl(undoMarkerDiv, tripMap, 'Undo Marker', 'Click To Undo Marker', undoMarker);

    tripMap.controls[google.maps.ControlPosition.TOP_LEFT].push(undoMarkerDiv);

    const removeAllMarkerDiv = document.createElement("div");

    pointsControl(removeAllMarkerDiv, tripMap, 'Remove All Markers', 'Click To remove all Markers', removeAllMarker);

    tripMap.controls[google.maps.ControlPosition.TOP_LEFT].push(removeAllMarkerDiv);

    directionsService = new google.maps.DirectionsService();
    directionsRenderer = new google.maps.DirectionsRenderer({
        draggable: true,
        panel: document.getElementById("panel"),
        suppressMarkers: true,
        polylineOptions: {
            strokeColor: "red",
            strokeWeight: 6,
            strokeOpacity: 0.6
          }
    });
    
    directionsRenderer2 = new google.maps.DirectionsRenderer({
        draggable: true,
        panel: document.getElementById("panel"),
        suppressMarkers: true,
        polylineOptions: {
            strokeColor: "green",
            strokeWeight: 6,
            strokeOpacity: 0.6
          }
    });
    
    directionsRenderer3 = new google.maps.DirectionsRenderer({
        draggable: true,
        panel: document.getElementById("panel"),
        suppressMarkers: true,
        polylineOptions: {
            strokeColor: "blue",
            strokeWeight: 6,
            strokeOpacity: 0.6
          }
    });

    directionsRenderer.addListener("directions_changed", () => {
        const directions = directionsRenderer.getDirections();

        if (directions) {
            line1Result = directions;
            computeCombinedLines();
            //computeDistanceTime(directions);
        }
    });
    
    directionsRenderer2.addListener("directions_changed", () => {
        const directions = directionsRenderer2.getDirections();

        if (directions) {
            line2Result = directions;
            computeCombinedLines();
            //computeDistanceTime(directions);
        }
    });
    
    directionsRenderer3.addListener("directions_changed", () => {
        const directions = directionsRenderer3.getDirections();

        if (directions) {
            line3Result = directions;
            computeCombinedLines();
            //computeDistanceTime(directions);
        }
    });
    
    

    var geocoder = new google.maps.Geocoder();

    google.maps.event.addListener(tripMap, 'click', function (e) {

     if (points == 0)
     {
         alert('Please indicate either 2 or 3 points');
         return;
     }
        var input = e.latLng;
        var lat = parseFloat(input.lat());
        var lng = parseFloat(input.lng());
        var latlng = new google.maps.LatLng(lat, lng);
        geocoder.geocode({
            'latLng': latlng
        }, function (results, status) {

            if (status == google.maps.GeocoderStatus.OK) {
                //console.log(JSON.stringify(results));
                if (waypts.length >= points)
                {
                    undoMarker();
                }

                if (waypts.length < points)
                {
                    addMarker(lat, lng, '<h5>' + results[1].formatted_address + '</h5><h6>[' + (Math.round(lng * 100000) / 100000) + ',' + (Math.round(lat * 100000) / 100000) + ']</h6>', tripMap);
                }

                var add = results[1].formatted_address;

                if (waypts.length < points) {
                    waypts.push({
                        location: add,
                        stopover: true
                    });
                }

                //alert(JSON.stringify(waypts));
                if (waypts.length > 1) {
                    ways = [];
                    for (var i = 1; i < waypts.length; i++) {
                        ways.push({
                            location: waypts[i].location,
                            stopover: true
                        });
                    }
                }
            }
        });
    });

    $('#travelDistanceTd input').on('change', function () {
        calculate();
    });

    $('#travelTimeTd input').on('change', function () {
        calculate();
    });

    $('#hookTd input').on('change', function () {
        calculate();
    });

    $('#waitingTimeTd input').on('change', function () {
        calculate();
    });

    $('#tripRateTd input').on('change', function () {

        let tripRate = $('#tripRateTd input').val();

        if (tripRate !== '')
        {
            tripRate = parseFloat(tripRate);
        } else
        {
            tripRate = 0;
        }

        var hookRate = $('#hookTd input').val();

        if (hookRate !== '')
        {
            hookRate = parseFloat(hookRate);
        } else
        {
            hookRate = 0;
        }

        var waitingRate = $('#waitingTimeTd input').val();

        if (waitingRate !== '')
        {
            waitingRate = parseFloat(waitingRate);
        } else
        {
            waitingRate = 0;
        }

        var totalTripRate = hookRate + waitingRate + tripRate;
        
        totalTripRate = totalTripRate.toFixed(2);
        
        var behindComma = totalTripRate.toString().split('.')[1];
        
        if (parseInt(behindComma,10) > 49)
        {
            totalTripRate = Math.ceil(totalTripRate);
        }
        else
        {
            totalTripRate = Math.floor(totalTripRate);
        }

        $('#totalRateTd').text(totalTripRate.toFixed(2));
        
        var distance = $('#travelDistanceTd input').val();

        if (distance !== '')
        {
            distance = parseFloat(distance);
        } else
        {
            distance = 0;
        }

        var timeInMins = $('#travelTimeTd input').val();

        if (timeInMins !== '')
        {
            timeInMins = parseFloat(timeInMins);
        } else
        {
            timeInMins = 0;
        }
        
        //pass the values

//        setTripInfo(distance, timeInMins, hookRate, waitingRate, tripRate, totalTripRate);
        gDistance = distance;
        gTimeInMins= timeInMins;
        gHookRate = hookRate;
        gWaitingRate = waitingRate;
        gTripRate = tripRate;
        gTotalTripRate = totalTripRate;
    });
}

function makeRoute(callback) 
{
    var start;
    var mid;
    var end;
    
    if (waypts.length == 2)
    {
        start = waypts[0].location;
        end = waypts[1].location;
    
        directionsService.route({
            origin: start,
            destination: end,
            waypoints: [],
            travelMode: google.maps.TravelMode.DRIVING,
            avoidTolls: true,
        }).then((result) => {
            directionsRenderer.setDirections(result);
            directionsRenderer.setMap(tripMap);
            callback();
        })
        .catch((e) => {
            alert("Could not display directions due to: " + e);
        });
        
        directionsService.route({
            origin: end,
            destination: start,
            waypoints: [],
            travelMode: google.maps.TravelMode.DRIVING,
            avoidTolls: true,
        }).then((result) => {
            directionsRenderer2.setDirections(result);
            directionsRenderer2.setMap(tripMap);
            callback();
        })
        .catch((e) => {
            alert("Could not display directions due to: " + e);
        });
    }
    else if (waypts.length == 3)
    {
        start = waypts[0].location;
        mid = waypts[1].location;
        end = waypts[2].location;
        
        
        directionsService.route({
            origin: start,
            destination: mid,
            waypoints: [],
            travelMode: google.maps.TravelMode.DRIVING,
            avoidTolls: true,
        }).then((result) => {
            directionsRenderer.setDirections(result);
            directionsRenderer.setMap(tripMap);
            callback();
        })
        .catch((e) => {
            alert("Could not display directions due to: " + e);
        });
        
        directionsService.route({
            origin: mid,
            destination: end,
            waypoints: [],
            travelMode: google.maps.TravelMode.DRIVING,
            avoidTolls: true,
        }).then((result) => {
            directionsRenderer2.setDirections(result);
            directionsRenderer2.setMap(tripMap);
            callback();
        })
        .catch((e) => {
            alert("Could not display directions due to: " + e);
        });
        
        directionsService.route({
            origin: end,
            destination: start,
            waypoints: [],
            travelMode: google.maps.TravelMode.DRIVING,
            avoidTolls: true,
        }).then((result) => {
            directionsRenderer3.setDirections(result);
            directionsRenderer3.setMap(tripMap);
            callback();
        })
        .catch((e) => {
            alert("Could not display directions due to: " + e);
        });
    }
    
//    var start = waypts[0].location;
//
//    if (waypts.length > 1) 
//    {
//        directionsService.route({
//            origin: start,
//            destination: end,
//            waypoints: ways,
//            travelMode: google.maps.TravelMode.DRIVING,
//            avoidTolls: true,
//        }).then((result) => {
//            directionsRenderer.setDirections(result);
//            directionsRenderer.setMap(tripMap);
//            callback();
//        })
//        .catch((e) => {
//            alert("Could not display directions due to: " + e);
//        });
//        
//        directionsRenderer2.route({
//            origin: end,
//            destination: start,
//            waypoints: ways,
//            travelMode: google.maps.TravelMode.DRIVING,
//            avoidTolls: true,
//        }).then((result) => {
//            directionsRenderer2.setDirections(result);
//            directionsRenderer2.setMap(tripMap);
//            callback();
//        })
//        .catch((e) => {
//            alert("Could not display directions due to: " + e);
//        });
//    }
}

function computeCombinedLines() 
{
//    console.log(JSON.stringify(result));
    let totalDistance = 0;

    let totalDuration = 0;
    
    var line1Distance = 0;
    var line1Duration = 0;
    var line2Distance = 0;
    var line2Duration = 0;
    var line3Distance = 0;
    var line3Duration = 0;
    
    var route = null;

    if (line1Result)
    {
        route = line1Result.routes[0];

        for (let i = 0; i < route.legs.length; i++) {
            line1Distance += route.legs[i].distance.value;
            line1Duration += route.legs[i].duration.value;
        }

        line1Distance = line1Distance / 1000;
        

        line1Duration = line1Duration / 60;
    }
    
    if (line2Result)
    {
        route = line2Result.routes[0];

        for (let i = 0; i < route.legs.length; i++) {
            line2Distance += route.legs[i].distance.value;
            line2Duration += route.legs[i].duration.value;
        }

        line2Distance = line2Distance / 1000;

        line2Duration = line2Duration / 60;
    }
    
    if (line3Result)
    {
        route = line3Result.routes[0];

        for (let i = 0; i < route.legs.length; i++) {
            line3Distance += route.legs[i].distance.value;

            line3Duration += route.legs[i].duration.value;
        }

        line3Distance = line3Distance / 1000;

        line3Duration = line3Duration / 60;
    }
    
    totalDistance = line1Distance + line2Distance + line3Distance;
    
    totalDuration = line1Duration + line2Duration + line3Duration;

    $('#travelDistanceTd input').val(totalDistance.toFixed(2));

    $('#travelTimeTd input').val(totalDuration.toFixed(2));
    
    calculate();
}


function computeDistanceTime(result) 
{
//    console.log(JSON.stringify(result));
    let totalDistance = 0;

    let totalDuration = 0;

    const route = result.routes[0];

    if (!route) {
        return;
    }

    for (let i = 0; i < route.legs.length; i++) {
        totalDistance += route.legs[i].distance.value;

        totalDuration += route.legs[i].duration.value;
    }

    totalDistance = totalDistance / 1000;

    totalDuration = totalDuration / 60;

    $('#travelDistanceTd input').val(totalDistance.toFixed(2));

    $('#travelTimeTd input').val(totalDuration.toFixed(2));
    
}

function addMarker(lat, lng, text, map) 
{
    var latLng = new google.maps.LatLng(lat, lng);
    var marker = new google.maps.Marker({
        position: latLng,
        title: text
    });

    marker.info = new google.maps.InfoWindow({
        content: text
    });

    google.maps.event.addListener(marker, 'click', function () {
        marker.info.open(map, marker);
    });

    if (existSimpleMarker[text] === undefined) {

        marker.setMap(map);
        existSimpleMarker[text] = marker;
        markerStack.push(marker);
    } else {

        var simpleMarker = existSimpleMarker[text];
        simpleMarker.setMap(map);
        markerStack.push(marker);
    }
}

function submitCalculation()
{
    setTripInfo(gDistance, gTimeInMins, gHookRate, gWaitingRate, gTripRate, gTotalTripRate);
}

function removeAllMarker() 
{
    for (var key in existSimpleMarker) 
    {

        existSimpleMarker[key].setMap(null);
    }

    existSimpleMarker = {};

    waypts = [];
    ways = [];

    directionsRenderer.setMap(null);
    directionsRenderer2.setMap(null);
    directionsRenderer3.setMap(null);
}

function setPoints(n) 
{
    points = n;

    removeAllMarker();
}

function undoMarker() 
{
    if (markerStack.length > 1) {
        markerStack.pop().setMap(null);
    }

    waypts.pop();
    ways.pop();

}

function pointsControl(controlDiv, map, label, title, handler, param, assignclass) 
{
    // Set CSS for the control border.
    const controlUI = document.createElement("div");

    controlUI.style.backgroundColor = "#eb1a30";
    controlUI.style.borderRadius = "3px";
    controlUI.style.boxShadow = "rgb(0 0 0 / 30%) 0px 1px 4px -1px;";
    controlUI.style.cursor = "pointer";
    controlUI.style.margin = "10px";
    controlUI.style.textAlign = "center";
    controlUI.title = title;
    controlUI.className = assignclass;
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    const controlText = document.createElement("div");

    controlText.style.color = "#eeeeee";
    controlText.style.fontFamily = "Roboto,Arial,sans-serif";
    controlText.style.fontSize = "16px";
    controlText.style.lineHeight = "40px";
    controlText.style.paddingLeft = "5px";
    controlText.style.paddingRight = "5px";
    controlText.innerHTML = label;
    controlUI.appendChild(controlText);
    
    controlUI.addEventListener("click", function () {
        handler(param)
        if (assignclass)
        {
            $('.'+assignclass).css( "background-color", "#eb1a30" );
            $(this).css("background-color","black");
        }
    });
    
    $(controlUI).on({
        mouseenter: function () {
            $(this).css("font-weight","bold");
        },
        mouseleave: function () {
            $(this).css("font-weight","normal");
        }
    });
    
}

function openTripMap(from, location, to, material, callback)
{
    var dialog = $('#trip-map-dialog').data('dialog');

    $('#submit-btn').css('background-color', '#eb1a30');
    $('#submit-btn').css('width', '100px');
    $('#submit-btn').css('position', 'absolute');
    $('#submit-btn').css('bottom', '15%');
    $('#submit-btn').css('right', '2%');
    $('#submit-btn').css('font-size', '18px');
    $('#submit-btn').css('color', 'white');
    $('#submit-btn').css('padding', '10px');
    $('#submit-btn').css('border-radius', '10px');
    $('#submit-btn').css('text-align', 'center');
    $('#submit-btn').css('cursor', 'pointer');
    
    $("#submit-btn").on({
        mouseenter: function () {
            $(this).css("background-color","black");
        },
        mouseleave: function () {
            $(this).css("background-color","#eb1a30");
        }
    });
    
    $("#submit-btn").click(function()
    {
        closeTripMap();
        callback(gDistance, gTimeInMins, gHookRate, gWaitingRate, gTripRate, gTotalTripRate);
    });

    
    $('#trip-data-container').css('background-color', 'white');
    $('#trip-data-container').css('width', '98%');
    $('#trip-data-container').css('position', 'absolute');
    $('#trip-data-container').css('bottom', '1%');
    $('#trip-data-container').css('left', '1%');
    $('#trip-data-container').css('z-index', '99');

    $('#trip-data-container').html('<table style="width: 100%;">' +
            '<tbody>' +
            '<tr>' +
            '<th>From Site</th>' +
            '<th>Location</th>' +
            '<th>To Site</th>' +
            '<th>Material</th>' +
            '<th>Travelling Distance (KM)</th>' +
            '<th>Travelling Time (Mins)</th>' +
            '<th>Hook ($)</th>' +
            '<th>Waiting Time ($)</th>' +
            '<th>Trip Rate ($)</th>' +
            '<th>Total Rate ($)</th>' +
            '<th>Calculate</th>' +
            '</tr>' +
            '<tr class="data-row">' +
            '<td id="fromSiteTd">' + from + '</td>' +
            '<td id="locationTd">' + location + '</td>' +
            '<td id="toSiteTd">' + to + '</td>' +
            '<td id="materialTd">' + material + '</td>' +
            '<td id="travelDistanceTd"><input type="number"></td>' +
            '<td id="travelTimeTd"><input type="number"></td>' +
            '<td id="hookTd"><input type="number" value=0></td>' +
            '<td id="waitingTimeTd"><input type="number" value=0></td>' +
            '<td id="tripRateTd"><input type="number"></td>' +
            '<td id="totalRateTd"></td>' +
            '<td id="calculateTd"><button type="button" class="button primary" onclick="createRoute()">Calculate</button></td>' +
            '</tr>' +
            '</tbody>' +
            '</table>');

    $('#trip-data-container table').css('border', '1px solid black');

    $('#trip-data-container table th, #trip-data-container table td').css('border', '1px solid black');

    $('#trip-data-container table th, #trip-data-container table td').css('padding', '3px');

    $('#trip-data-container table tr.data-row input').css('width', '90%');

    $('#trip-data-container table th').css('background-color', '#eb1a30');

    $('#trip-data-container table th').css('color', '#eeeeee');


    dialog.open();

    $('#trip-map-dialog').css('height', '90%');
    $('#trip-map-dialog').css('width', '80%');
    $('#trip-map-dialog').css('top', '5%');
    $('#trip-map-dialog').css('left', '10%');

    if (tripMap == null)
    {
        initTripMap();
    }
    else
    {
        removeAllMarker();
    }
}

function closeTripMap()
{
    var dialog = $('#trip-map-dialog').data('dialog');

    dialog.close();
}

function createRoute()
{
    makeRoute(calculate);
}

function calculate()
{
    var hookRate = $('#hookTd input').val();

    if (hookRate !== '')
    {
        hookRate = parseFloat(hookRate);
    } else
    {
        hookRate = 0;
    }

    var waitingRate = $('#waitingTimeTd input').val();

    if (waitingRate !== '')
    {
        waitingRate = parseFloat(waitingRate);
    } else
    {
        waitingRate = 0;
    }

    var distance = $('#travelDistanceTd input').val();

    if (distance !== '')
    {
        distance = parseFloat(distance);
    } else
    {
        distance = 0;
    }

    var timeInMins = $('#travelTimeTd input').val();

    if (timeInMins !== '')
    {
        timeInMins = parseFloat(timeInMins);
    } else
    {
        timeInMins = 0;
    }

    const ratePerMin = 0.66;

    const ratePerKm = getRatePerKm(distance);

    var tripRate = ((distance * ratePerKm) + (timeInMins * ratePerMin)) / 2;

    $('#tripRateTd input').val(tripRate.toFixed(2));

    var totalTripRate = hookRate + waitingRate + tripRate;
    
    totalTripRate = totalTripRate.toFixed(2);
        
    var behindComma = totalTripRate.toString().split('.')[1];

    if (parseInt(behindComma,10) > 49)
    {
        totalTripRate = Math.ceil(totalTripRate);
    }
    else
    {
        totalTripRate = Math.floor(totalTripRate);
    }

    $('#totalRateTd').text(totalTripRate.toFixed(2));

    //pass the values

//        setTripInfo(distance, timeInMins, hookRate, waitingRate, tripRate, totalTripRate);
    gDistance = distance;
    gTimeInMins= timeInMins;
    gHookRate = hookRate;
    gWaitingRate = waitingRate;
    gTripRate = tripRate;
    gTotalTripRate = totalTripRate;
    
    console.log('calc called..');
}

function getRatePerKm(distance)
{
    var ratePerKm = 0;

    if (distance < 5)
    {
        ratePerKm = 3.5;
    } else if (distance >= 5 && distance < 10)
    {
        ratePerKm = 1.8;
    } else if (distance >= 10 && distance < 20)
    {
        ratePerKm = 1.7;
    } else if (distance >= 20 && distance < 40)
    {
        ratePerKm = 1.3;
    } else if (distance >= 40 && distance < 60)
    {
        ratePerKm = 1.2;
    } else if (distance >= 60 && distance < 80)
    {
        ratePerKm = 1.1;
    } else if (distance >= 80 && distance < 100)
    {
        ratePerKm = 1;
    } else if (distance >= 100)
    {
        ratePerKm = 0.9;
    }

    return ratePerKm;
}







