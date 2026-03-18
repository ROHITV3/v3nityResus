/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

/*
 * implementation of google map...
 */
var poi;
var existPoi = [];
var geofence;
var geofences = {
    0: {},
    1: {},
    2: {},
    3: {}
};
var drawingManager;
var drawingComplete;
var polylines = [];
var existSimpleMarker = {};
var existPolylines = {};
var locationMarkers = {};
var routeMarkers = new Array();
var mapEvents = new Array();
var sequence = 0;
var route_waypoints = '';
var v3MapLayer;
var overlayLayers = [];
var locationLayer;
var historyLayer;
var trafficLayer;
var startMarker;
var endMarker;
var mouse = {
    x: null,
    y: null
};
var theCluster;
var markerClusterArr = [];
var iconSize = {width: 20, height: 20, offsetX: 0, offsetY: 2};
var directionsService;
var directionsRenderer;
var assetPathArr = [];
var brushMarkers = [];

function v3nityMap(id, options)
{
    if (options === undefined)
    {
        options = {
            clusterMaxZoom: 12
        };
    }

    if (options.iconSize !== undefined)
    {
        iconSize = options.iconSize;
    }

    this._map = new google.maps.Map(document.getElementById(id), {
        zoomControl: false,
        disableDefaultUI: true,
        streetViewControl: true,
        backgroundColor: '#437DC6',
        minZoom: 3,
        maxZoom: 19
    });

    /*
     * to allow capturing of the mouse position when moving in the map...
     */
    document.getElementById(id).onmousemove = function(e)
    {
          mouse.x = e.pageX;
          mouse.y = e.pageY;
    };

    var googleMap = this._map;

    /*
     * we have temporary shut down this feature because of some customers complaint...
     */
    this.markerCluster = new MarkerClusterer(this._map, null, {imagePath: 'img/m', maxZoom: options.clusterMaxZoom});

    this.location_list = '';

    this.geofenceLayer = [];

    trafficLayer = new google.maps.TrafficLayer();

    trafficLayer.autoRefresh = true;

    v3MapLayer = new google.maps.ImageMapType({
        getTileUrl: function(coord, zoom)
        {

            var bounds = googleMap.getBounds();

            var areaBounds = {
                north: bounds.getNorthEast().lat(),
                south: bounds.getSouthWest().lat(),
                east: bounds.getNorthEast().lng(),
                west: bounds.getSouthWest().lng()
            };

            if (zoom < 20 && zoom > 10)
            {
                if (areaBounds.west > 104.3 || areaBounds.east < 103.5 || areaBounds.north < 1.20 || areaBounds.south > 1.48)
                {
                    return null;
                }
                else
                {

                    return "http://map.v3nity.com/v3_sg_tms/" + zoom + "/" + coord.x + "/" + coord.y + ".png";
                }
            }
            else
            {
                return null;

            }
        },
        tileSize: new google.maps.Size(256, 256)
    });

    this._map.overlayMapTypes.push(v3MapLayer);

}

v3nityMap.prototype.getGoogleMap = function()
{
    return this._map;
};

v3nityMap.prototype.addMarkerCluster = function(points)
{
    var thisMap = this;

    for (var i = 0 ; i < points.length ; i++)
    {
        var iconUrl = "http://maps.google.com/mapfiles/ms/icons/blue-dot.png";

        if (points[i].enforce)
        {
            iconUrl = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
        }

        var marker = new google.maps.Marker({
            position: points[i].coord,
            label:{
              text: points[i].name,
              color: "#000",
              fontSize: "11px",
              fontWeight: "bold"
            },
            icon: {
                url: iconUrl
            },
            job_id: points[i].job_id,
            map:thisMap._map
        });

        google.maps.event.addListener(marker, 'click', function()
        {
            window.open("SFAJobScheduleController?type=plan&action=pdf&id=" + this.job_id + "&geotagCheck=Y" , "_blank");
        });

        markerClusterArr.push(marker);
    }


    this.markerCluster = new MarkerClusterer(thisMap._map, markerClusterArr, {imagePath: 'img/m', maxZoom: 15});
}


v3nityMap.prototype.clearMarkerCluster = function()
{
    for (var i = 0; i < markerClusterArr.length; i++)
    {
        markerClusterArr[i].setMap(null);
    }

    this.markerCluster.clearMarkers();

    markerClusterArr = [];
}


v3nityMap.prototype.recentralize = function()
{
    var googleMap = this._map;
    var bounds = googleMap.getCenter();
    google.maps.event.trigger(googleMap, 'resize');
    googleMap.setCenter(bounds);

}
v3nityMap.prototype.addOverlayLayer = function(layerOption)
{

    var extraLayer = new google.maps.ImageMapType({
        getTileUrl: function(coord, zoom)
        {

            if (zoom < layerOption.maxZoom && zoom > layerOption.minZoom)
            {
                /*
                 * most of the map overlays are in http://map.v3nity.com/SGExtraTMS/..
                 */
                return layerOption.url + "/" + zoom + "/" + coord.x + "/" + coord.y + ".png";
            }
            else
            {
                return null;
            }
        },
        tileSize: new google.maps.Size(256, 256)
    });

    overlayLayers.push(extraLayer);

    this._map.overlayMapTypes.push(extraLayer);
};

/*
 * general map functions...
 */
v3nityMap.prototype.getCountry = function(ip)
{
    // country_code: US
    // country_name: United States
    // region_code: CA
    // region_name: California
    // city: San Francisco
    // zip_code: 94107
    // time_zone: America/Los_Angeles
    // latitude: 37.77
    // longitude: -122.394
    // metro_code: 807
    $.ajax({
        type: 'GET',
        url: 'https://freegeoip.net/json/' + ip,
        success: function(data)
        {
            return data;
        }
    });
};

v3nityMap.prototype.convertSerialCoordinatesToLatLng = function(points)
{

    var array = [];

    for (i = 0; i < points.length; i += 2)
    {
        array.push(new google.maps.LatLng(points[i], points[i + 1]));
    }

    return array;
};

v3nityMap.prototype.removeV3Layer = function()
{

    if (this._map.overlayMapTypes.getLength() > 0)
    {

        this._map.overlayMapTypes.clear();
    }
};

v3nityMap.prototype.setTraffic = function(enable)
{

    console.log(enable);
    if (enable)
    {

        this.removeV3Layer();

        trafficLayer.setMap(this._map);
    }
    else
    {

        this._map.overlayMapTypes.push(v3MapLayer);

        trafficLayer.setMap(null);
    }
};

v3nityMap.prototype.remove = function()
{

    // no implementation of disposing resources...
};

v3nityMap.prototype.setDefaultView = function(bounds)
{

    this._bounds = new google.maps.LatLngBounds(new google.maps.LatLng(bounds[1][0], bounds[1][1]), new google.maps.LatLng(bounds[0][0], bounds[0][1]));
    this._map.fitBounds(this._bounds);
};

v3nityMap.prototype.changeBaseLayer = function(indexes)
{

    if (this._map.overlayMapTypes.getLength() > 0)
    {
        this._map.overlayMapTypes.clear();
    }

    switch (indexes)
    {
        case 1:
            this._map.setMapTypeId(google.maps.MapTypeId.ROADMAP);
            this._map.overlayMapTypes.push(v3MapLayer);
            break;
        case 2:
            this._map.setMapTypeId(google.maps.MapTypeId.TERRAIN);
            break;
        case 3:
            this._map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
            break;
        case 4:
            this._map.setMapTypeId(google.maps.MapTypeId.HYBRID);
            break;
    }

    for (var i = 0; i < overlayLayers.length; i++)
    {
        this._map.overlayMapTypes.push(overlayLayers[i]);
    }
};

v3nityMap.prototype.defaultOptions = function(options)
{
    this.setDefaultView([
        [options.bounds[0], options.bounds[1]],
        [options.bounds[2], options.bounds[3]]
    ]);
};

v3nityMap.prototype.getCurrentZoomLevel = function()
{

    return this._map.getZoom();
};

v3nityMap.prototype.zoomTo = function(lat, lng, zoom)
{

    this._map.panTo(new google.maps.LatLng(lat, lng));
    this._map.setZoom(zoom);
};

v3nityMap.prototype.zoomToPolygon = function(polygon)
{

    var bounds = new google.maps.LatLngBounds();

    for (var i = 0; i < polygon.length; i++)
    {
        bounds.extend(polygon[i]);
    }

    this._map.fitBounds(bounds);
};

v3nityMap.prototype.zoomToDefault = function()
{

    this._map.fitBounds(this._bounds);
};

v3nityMap.prototype.zoomIn = function()
{

    if (this._map.getZoom() < 19)
    {

        this._map.setZoom(this._map.getZoom() + 1);
    }
};

v3nityMap.prototype.zoomOut = function()
{

    this._map.setZoom(this._map.getZoom() - 1);
};

v3nityMap.prototype.zoomWorld = function()
{

    this._map.fitWorld();
};

v3nityMap.prototype.zoomBound = function(minLat, minLng, maxLat, maxLng)
{

    var bounds = new google.maps.LatLngBounds();

    bounds.extend({lat: minLat, lng: minLng});

    bounds.extend({lat: maxLat, lng: maxLng});

    if (minLat !== undefined && maxLng !== undefined && maxLat !== undefined && minLng !== undefined)
    {

        this._map.fitBounds(bounds);
    }
};

v3nityMap.prototype.zoomToMarkers = function(locations)
{

    var zoom = this.getCurrentZoomLevel();

    var bounds = new google.maps.LatLngBounds();

    for (var i = 0; i < locations.length; i++)
    {

        bounds.extend(new google.maps.LatLng(locations[i][0], locations[i][1]));
    }

    this._map.fitBounds(bounds);
};

v3nityMap.prototype.enableDropMarker = function(callback, icon)
{

    var thisMap = this;

    thisMap.removeAllSimpleMarker();

    if (mapEvents["clickEvent"] === undefined)
    {

        var clickEvent = google.maps.event.addListener(thisMap._map, 'click', function(event)
        {

            lat = event.latLng.lat();

            lng = event.latLng.lng();

            thisMap.removeAllSimpleMarker();

            reverseGeocode(lng, lat, function(location)
            {

                thisMap.addSimpleMarker(lat, lng, '<h5>' + location + '</h5><h6>[' + (Math.round(lng * 100000) / 100000) + ',' + (Math.round(lat * 100000) / 100000) + ']</h6>');

                callback(lat, lng, location);
            });

        });

        mapEvents["clickEvent"] = clickEvent;
    }
};

v3nityMap.prototype.disableDropMarker = function()
{

    var event = mapEvents["clickEvent"];

    if (event != undefined)
    {

        google.maps.event.removeListener(event);

        delete mapEvents["clickEvent"];
    }

};

v3nityMap.prototype.addSimpleMarker = function(lat, lng, text)
{

    var thisMap = this;

    var myLatLng = new google.maps.LatLng(lat, lng);

    var marker = new google.maps.Marker({
        icon: 'img/marker-location-pin.png',
        position: myLatLng,
        title: text
    });

    marker.info = new google.maps.InfoWindow({
        content: text
    });

    google.maps.event.addListener(marker, 'click', function()
    {
        marker.info.open(thisMap._map, marker);
    });

    if (existSimpleMarker[text] === undefined)
    {

        marker.setMap(thisMap._map);
        existSimpleMarker[text] = marker;
    }
    else
    {

        var simpleMarker = existSimpleMarker[text];
        simpleMarker.setMap(thisMap._map);
    }
};

v3nityMap.prototype.addNumberedMarker = function(lat, lng, text, color, number, hoverText)
{

    var thisMap = this;

    var myLatLng = new google.maps.LatLng(lat, lng);

    var marker = new google.maps.Marker({
        icon: 'img/numbered_markers/number_' + number + '.png',
        position: myLatLng,
        title: hoverText
    });

    marker.info = new google.maps.InfoWindow({
        content: text
    });

    google.maps.event.addListener(marker, 'click', function()
    {
        marker.info.open(thisMap._map, marker);
    });

    if (existSimpleMarker[text] === undefined)
    {

        marker.setMap(thisMap._map);
        existSimpleMarker[text] = marker;
    }
    else
    {

        var simpleMarker = existSimpleMarker[text];
        simpleMarker.setMap(thisMap._map);
    }
};

v3nityMap.prototype.removeAllSimpleMarker = function()
{

    for (var key in existSimpleMarker)
    {

        existSimpleMarker[key].setMap(null);
    }

    existSimpleMarker = {};
};

v3nityMap.prototype.removeLastLocationMarker = function(id)
{

    if (this.locationLayer)
    {
        this.locationLayer.removeMarker(id);
    }
};

v3nityMap.prototype.removeLastLocationLayer = function()
{

    if (this.locationLayer)
    {
        this.locationLayer.remove();
    }
};

v3nityMap.prototype.addHistoryLayer = function(points, enableLine, callback)
{

    if (this.historyLayer)
    {
        this.historyLayer.remove();
    }

    this.historyLayer = new HistoryLayer(points, {map: this._map, callback: callback});

    this.historyLayer.toggleLine(enableLine);
};

v3nityMap.prototype.removeHistoryLayer = function()
{

    if (this.historyLayer)
    {
        this.historyLayer.remove();
    }
};

v3nityMap.prototype.selectHistoryLayer = function(id)
{

    if (this.historyLayer)
    {

        this.historyLayer.select(id);
    }
};

v3nityMap.prototype.toggleHistoryLine = function(on)
{

    this.historyLayer.toggleLine(on);
};

v3nityMap.prototype.addLastLocationLayer = function(locations)
{
    if (this.locationLayer)
    {
        this.locationLayer.remove();
        this.locationLayer.setMap(null);
    }
    this.locationLayer = new LastLocationLayer(locations, {map: this._map});
};


v3nityMap.prototype.toggleLastLocationLayer = function(on)
{

    if (this.locationLayer)
    {
        this.locationLayer.toggle(on);
    }
};

v3nityMap.prototype.toggleLastLocationLayerLabel = function(on)
{

    if (this.locationLayer)
    {
        this.locationLayer.toggleLabel(on);
    }
};
v3nityMap.prototype.openMarkerDetails = function(lat, lng, popupText)
{

    if (this.locationLayer)
    {
        this.locationLayer.openMarkerDetails(lat, lng, popupText);
    }
};

v3nityMap.prototype.draw = function()
{
    this.locationLayer.draw();
};

/*
 * route functions...
 */
v3nityMap.prototype.addPolylineLayer = function(id, polyline)
{

    if (existPolylines[id] == undefined)
    {

        var polylineLayer = new google.maps.Polyline({
            path: polyline,
            polylineOptions: {
                strokeColor: '#3c94e1',
                strokeWeight: 10,
                strokeOpacity: 0.6
            }
        });

        polylineLayer.setMap(this._map);
        existPolylines[id] = polylineLayer;
    }
    else
    {

        var polylineLayer = existPolylines[id];
        polylineLayer.setMap(this._map);
    }
};

v3nityMap.prototype.removepolylineLayer = function(id)
{

    if (existPolylines[id] !== undefined)
    {
        existPolylines[id].setMap(null);
        existPolylines[id] = undefined;
    }
};

v3nityMap.prototype.addRouteMarker = function(lat, lon, title)
{

    var thisMap = this;

    var latLng = new google.maps.LatLng(lat, lon);

    var marker = new google.maps.Marker({
        position: latLng,
        title: title,
        draggable: true,
        map: thisMap._map,
        icon: 'img/marker-location-pin.png'
    });

    marker.sequence = sequence;

    sequence++;

    routeMarkers.push(marker);

    marker.addListener('dragend', function()
    {

        routeMarkers[routeMarkers.sequence].position = marker.position;
    });
};

v3nityMap.prototype.displayRoute = function(origin, destination, service, display, waypoints)
{

    var thisMap = this;

    service.route({
        origin: origin,
        destination: destination,
        waypoints: waypoints,
        //[{location: 'Adelaide, SA'}, {location: 'Broken Hill, NSW'}],
        travelMode: 'DRIVING',
        avoidTolls: true
    }, function(response, status)
    {
        if (status === 'OK')
        {
            display.setDirections(response);
            thisMap.getRoute(response);
        }
        else
        {
            alert('Could not display directions due to: ' + status);
        }
    });
};

v3nityMap.prototype.getRoute = function(directions)
{

    this.location_list = '';

    var overview_path = directions.routes[0].overview_path;

    for (var i = 0; i < overview_path.length; i++)
    {

        var lat = overview_path[i].lat();

        var lng = overview_path[i].lng();

        if (i === overview_path.length - 1)
        {

            this.location_list += lng + ',' + lat;
        }
        else
        {

            this.location_list += lng + ',' + lat + ',';
        }
    }
};

v3nityMap.prototype.removeRouteMarker = function()
{

    for (i = 0; i < routeMarkers.length; i++)
    {

        routeMarkers[i].setMap(null);
    }

    routeMarkers = [];

    sequence = 0;
};

v3nityMap.prototype.getRouteDrawCount = function()
{

    if (polylines.length)
    {
        return polylines.length;
    }
    else
    {
        return 0;
    }
}

v3nityMap.prototype.drawPolylineStart = function()
{

    this.removeRouteMarker();

    route_waypoints = '';

    var thisMap = this;

    if (mapEvents["clickEvent"] === undefined)
    {

        var i = 0;
        var lat = '';
        var lng = '';

        var clickEvent = google.maps.event.addListener(thisMap._map, 'click', function(event)
        {
            i++;
            thisMap.addRouteMarker(event.latLng.lat(), event.latLng.lng(), i + '');
            lat = event.latLng.lat();
            lng = event.latLng.lng();

            if (i == 1)
            {
                route_waypoints += lat + ',' + lng;
            }
            else
            {
                route_waypoints += ',' + lat + ',' + lng;
            }
        });

        mapEvents["clickEvent"] = clickEvent;
    }
};

v3nityMap.prototype.getwaypoints = function()
{

    return route_waypoints;
};

v3nityMap.prototype.modifyPolylineStart = function(points)
{

    this.removeRouteMarker();

    var thisMap = this;

    var event = mapEvents["clickEvent"];

    if (event != undefined)
    {

        google.maps.event.removeListener(event);
        delete mapEvents["clickEvent"];
    }

    var directionsService = new google.maps.DirectionsService;

    var directionsDisplay = new google.maps.DirectionsRenderer({
        draggable: true,
        map: this._map,
        polylineOptions: {
            strokeColor: '#3c94e1',
            strokeWeight: 10,
            strokeOpacity: 0.6
        }

    });

    directionsDisplay.addListener('directions_changed', function()
    {
        var directions = directionsDisplay.getDirections();
        thisMap.getRoute(directions);
    });

    var waypoints = new Array();
    var origin = null;
    var destination = null;

    for (var i = 0; i < points.length; i++)
    {

        thisMap.addRouteMarker(points[i].lat, points[i].lng, i + "");

        var id = points[i].id;

        if (existPolylines[id] == undefined)
        {
            existPolylines[id] = directionsDisplay;
        }
    }

    for (var i = 0; i < routeMarkers.length; i++)
    {
        if (i === 0)
        {
            origin = routeMarkers[i].position.toJSON();
        }
        else if (i === routeMarkers.length - 1)
        {
            destination = routeMarkers[i].position.toJSON();
        }
        else
        {
            var location = new Object();
            location.location = routeMarkers[i].position.toJSON();
            waypoints.push(location);
        }
    }
    if (routeMarkers.length > 1)
    {
        this.displayRoute(origin, destination, directionsService, directionsDisplay, waypoints);
        this.removeRouteMarker();
    }
};

v3nityMap.prototype.drawPolylineStop = function()
{

    var thisMap = this;

    var event = mapEvents["clickEvent"];

    if (event !== undefined)
    {
        google.maps.event.removeListener(event);
        delete mapEvents["clickEvent"];
    }

    var directionsService = new google.maps.DirectionsService;

    var directionsDisplay = new google.maps.DirectionsRenderer({
        draggable: true,
        map: this._map,
        polylineOptions: {
            strokeColor: '#f963d3',
            strokeWeight: 10,
            strokeOpacity: 0.6
        }
    });

    directionsDisplay.addListener('directions_changed', function()
    {

        var directions = directionsDisplay.getDirections();

        var overview_path = directions.routes[0].overview_path;

        //    var array = [];
        //   for (var i = 0; i < overview_path.length; i++) {
        //       var lat = overview_path[i].lat();
        //      var lng = overview_path[i].lng();
        //      array.push(new google.maps.LatLng(lat, lng));
        //  }

        // thisMap.removepolylineLayer(-1);
        // thisMap.addPolylineLayer(-1, array);
        thisMap.getRoute(directions);

    });

    var waypoints = new Array();
    var origin = null;
    var destination = null;

    for (var i = 0; i < routeMarkers.length; i++)
    {

        if (i === 0)
        {
            origin = routeMarkers[i].position.toJSON();
        }
        else if (i === routeMarkers.length - 1)
        {
            destination = routeMarkers[i].position.toJSON();
        }
        else
        {
            var location = new Object();
            location.location = routeMarkers[i].position.toJSON();
            waypoints.push(location);
        }
    }

    if (routeMarkers.length > 1)
    {
        this.displayRoute(origin, destination, directionsService, directionsDisplay, waypoints);

        polylines.push(directionsDisplay);

        this.removeRouteMarker();
    }
};

v3nityMap.prototype.drawPolylineCancel = function()
{

    for (var i = 0; i < polylines.length; i++)
    {
        polylines[i].setMap(null);
    }

    polylines = [];

    this.removeRouteMarker();
};


/*
 * geofence functions...
 */

v3nityMap.prototype.calculateArea = function(polygon)
{
    var polygonArea = new google.maps.Polygon({
        paths: polygon
    });

    var area = google.maps.geometry.spherical.computeArea(polygonArea.getPath());

    return area;
}



v3nityMap.prototype.addPoiLayer = function(id, locations, name ,mapId, poiColor)
{
   
    
        for (var i = 0; i < locations.length; i++)
    {
        var location = locations[i];

        var info = {
            latitude:location.lat ,
            longitude: location.lng,

        };

      

        var latlng = new google.maps.LatLng(info.latitude, info.longitude);
        
         var iconUrl = "http://maps.google.com/mapfiles/ms/icons/blue-dot.png";
        
        if (poiColor == 'red')
        {
            iconUrl = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
        }
        else if (poiColor == 'green')
        {
            iconUrl = "http://maps.google.com/mapfiles/ms/icons/green-dot.png";
        }
        else if (poiColor == 'blue')
        {
            iconUrl = "http://maps.google.com/mapfiles/ms/icons/blue-dot.png";
        }
    
//    var myLatlng = new google.maps.LatLng(location.lat, location.lng);
    var markerLayer = new google.maps.Marker({
        color: '#000',
        weight: 4,
        opacity: 1.0,
        icon: {
                url: iconUrl
            },
        fillColor: poiColor,
        fillOpacity: 0.5,
        editable: false,
        draggable: false,
        position:latlng ,
        name: name // self declared object...
    });



    markerLayer.setMap(this._map);

    existPoi.push(markerLayer);

    } };


v3nityMap.prototype.removePoiLayer = function(id, dispose, mapId)
{
  
  if (existPoi) {
      
      for(var i=0;i<existPoi.length;i++){
          existPoi[i].setMap(null);
      }
//    for (i in existPoi) {
//      existPoi[i].setMap(null);
//    }
    existPoi.length = 0;
  }

};

v3nityMap.prototype.getPoi = function(id, mapId)
{

    return existPoi[mapId][id];
};

v3nityMap.prototype.getPoiDrawCount = function()
{

    if (poi !== undefined)
    {
        return 1;
    }
    else
    {
        return 0;
    }
};


v3nityMap.prototype.addGeofenceLayer = function(id, polygon, geofence, onchange, onclick, mapId, geoFenceColor)
{
    var polygonLayer = new google.maps.Polygon({
        color: '#000',
        weight: 4,
        strokeColor: geoFenceColor,
        strokeWeight: 1.5,
        opacity: 1.0,
        fillColor: geoFenceColor,
        fillOpacity: 0.5,
        editable: false,
        draggable: false,
        paths: polygon,
        name: geofence // self declared object...
    });

    google.maps.event.addListener(polygonLayer, 'click', function()
    {
        onclick(id, geofence);
    });

    google.maps.event.addListener(polygonLayer.getPath(), 'set_at', function()
    {
        onchange(id);
    });

    google.maps.event.addListener(polygonLayer.getPath(), 'insert_at', function()
    {
        onchange(id);
    });

    this.attachGeofenceToolTip(polygonLayer);

    polygonLayer.setMap(this._map);

    geofences[mapId][id] = polygonLayer;

//    if (geofences[mapId][id] === undefined) {
//
//        var polygonLayer = new google.maps.Polygon({
//            color: '#000',
//            weight: 4,
//            opacity: 1.0,
//            fillColor: geoFenceColor,
//            fillOpacity: 0.5,
//            editable: false,
//            draggable: false,
//            paths: polygon,
//            name: geofence // self declared object...
//        });
//
//        google.maps.event.addListener(polygonLayer, 'click', function() {
//            onclick(id, geofence);
//        });
//
//        google.maps.event.addListener(polygonLayer.getPath(), 'set_at', function() {
//            onchange(id);
//        });
//
//        google.maps.event.addListener(polygonLayer.getPath(), 'insert_at', function() {
//            onchange(id);
//        });
//
//        this.attachGeofenceToolTip(polygonLayer);
//
//        polygonLayer.setMap(this._map);
//
//        geofences[mapId][id] = polygonLayer;
//    }
//    else {
//        console.log("asda" + id );
//        var polygonLayer = geofences[mapId][id];
//
//        polygonLayer.setMap(this._map);
//    }
};

v3nityMap.prototype.removeGeofenceLayer = function(id, dispose, mapId)
{
    if (geofences[mapId][id] !== undefined)
    {
        geofences[mapId][id].setMap(null);
    }

    if (dispose)
    {
        geofences[mapId][id] = undefined;
    }
};

v3nityMap.prototype.removeAllGeofenceLayer = function(mapId)
{ // dont think this is used, therefore, never change to include mapId (carter for split map)

    for (var key in geofences[mapId])
    {
        this.removeGeofenceLayer(key, false, mapId);
    }
};

v3nityMap.prototype.getGeofence = function(id, mapId)
{

    return geofences[mapId][id];
};

v3nityMap.prototype.getGeofenceDrawCount = function()
{

    if (geofence !== undefined)
    {
        return geofence.getPath().getLength();
    }
    else
    {
        return 0;
    }
};

v3nityMap.prototype.attachGeofenceToolTip = function(layer)
{

    google.maps.event.addListener(layer, 'mousemove', function(e)
    {

        this.setOptions({
            fillOpacity: 0.2
        });

        $('#map-tooltip').css({
            'left': mouse.x + 16,
            'top': mouse.y + 16,
            'display': 'block'
        }).html(layer.get('name'));
    });

    google.maps.event.addListener(layer, 'mouseout', function()
    {

        this.setOptions({
            fillOpacity: 0.4
        });

        $('#map-tooltip').css('display', 'none');
    });
};

v3nityMap.prototype.drawPolygonStart = function()
{

    if (drawingManager === undefined)
    {

        drawingManager = new google.maps.drawing.DrawingManager({
            drawingMode: google.maps.drawing.OverlayType.POLYGON,
            polygonOptions: {
                fillColor: '#FFC400',
                fillOpacity: 0.4,
                strokeWeight: 4,
                editable: true,
                draggable: true,
            } 
        });
    }

    if (drawingManager.getDrawingMode() === null)
    {
        drawingManager.setDrawingMode(google.maps.drawing.OverlayType.POLYGON);
    }

    if (geofence !== undefined)
    {
        geofence.setMap(null);
    }

    drawingManager.setMap(this._map);

    if (drawingComplete === undefined || drawingComplete === null)
    {

        drawingComplete = google.maps.event.addListener(drawingManager, 'polygoncomplete', function(polygon)
        {

            if (drawingManager.getDrawingMode() === null)   // if drawing is cancelled...
            {
                polygon.setMap(null);

                drawingManager.setMap(null);
            }
            else    // if drawing is completed...
            {
                geofence = polygon;

                drawingManager.setMap(null);

                drawingManager.setDrawingMode(null);
            }
        });
    }
};

v3nityMap.prototype.drawPolygonUndo = function()
{

};

v3nityMap.prototype.drawPolygonCancel = function()
{

    if (geofence !== undefined)
    {
        geofence.setMap(null);
    }

    if (drawingManager !== undefined)
    {

        drawingManager.setDrawingMode(null);
    }

    google.maps.event.removeListener(drawingComplete);

    drawingComplete = null;
};

v3nityMap.prototype.drawPolygonStop = function()
{

};


v3nityMap.prototype.drawMarkerStart = function()
{

    if (drawingManager === undefined)
    {

        drawingManager = new google.maps.drawing.DrawingManager({
            drawingMode: google.maps.drawing.OverlayType.Marker,
            markerOptions: {
               icon:"",
            } 
        });
    }

    if (drawingManager.getDrawingMode() === null)
    {
        drawingManager.setDrawingMode(google.maps.drawing.OverlayType.MARKER);
    }

    if (poi !== undefined)
    {
        poi.setMap(null);
    }

    drawingManager.setMap(this._map);

    if (drawingComplete === undefined || drawingComplete === null)
    {

        drawingComplete = google.maps.event.addListener(drawingManager, 'markercomplete', function(marker)
        {

            if (drawingManager.getDrawingMode() === null)   // if drawing is cancelled...
            {
                marker.setMap(null);

                drawingManager.setMap(null);
            }
            else    // if drawing is completed...
            {
                poi = marker;

                drawingManager.setMap(null);

                drawingManager.setDrawingMode(null);
            }
        });
    }
};

v3nityMap.prototype.drawMarkerCancel = function()
{

    if (poi !== undefined)
    {
        poi.setMap(null);
    }

    if (drawingManager !== undefined)
    {

        drawingManager.setDrawingMode(null);
    }

    google.maps.event.removeListener(drawingComplete);

    drawingComplete = null;
};

v3nityMap.prototype.drawMarkerStop = function()
{

};

v3nityMap.prototype.convertPositionToLatLngs = function(position)
{
    

    var latlngArray = [];

   
//        var coord = position.getAt(i).toUrlValue(6).split(',');

        var latlng = new Object();

        latlng.lat =position.lat();

        latlng.lng =position.lng();

        latlngArray.push(latlng);
    
    return latlngArray;
};

v3nityMap.prototype.getMarkerLatLngs = function()
{

       return this.convertPositionToLatLngs (poi.getPosition());

};

v3nityMap.prototype.convertPathToLatLngs = function(path)
{

    var latlngArray = [];

    for (var i = 0; i < path.getLength(); i++)
    {

        var coord = path.getAt(i).toUrlValue(6).split(',');

        var latlng = new Object();

        latlng.lat = coord[0];

        latlng.lng = coord[1];

        latlngArray.push(latlng);
    }

    return latlngArray;
};

v3nityMap.prototype.getPolygonLatLngs = function()
{

    return this.convertPathToLatLngs(geofence.getPath());
};

v3nityMap.prototype.setPolygonLatLngs = function(latlngs)
{

    var data = {
        color: '#000',
        weight: 4,
        strokeColor: "#000000",
        strokeWeight: 0,
        opacity: 1.0,
        fill: true,
        fillColor: '#FFC400',
        fillOpacity: 0.5
    };

    this._drawLayer.clearLayers();

    var polygon = new L.polygon(latlngs, data);

    this._drawLayer.addLayer(polygon);
};

v3nityMap.prototype.isDrawing = function()
{

    if (geofence !== undefined)
    {
        return (geofence.getPath().getLength() > 0);
    }
    else
    {
        return false;
    }
};


/*
 * implementation of history layer...
 */
HistoryLayer.prototype = new google.maps.OverlayView();

function HistoryLayer(locations, options)
{

    this.boundsChangedTimeout = null;

    this.startMarker = null;

    this.endMarker = null;

    this.locations = locations;

    this.setMap(options.map);

    this.callback = options.callback;

    this.markerLayer = $('<div />');

    this.selectedId = 0;

    var layer = this;

    this.onboundchanged = options.map.addListener('bounds_changed', function()
    {

        if (layer.boundsChangedTimeout !== null)
        {
            clearTimeout(layer.boundsChangedTimeout);

            layer.boundsChangedTimeout = null;
        }

        layer.boundsChangedTimeout = setTimeout(function()
        {
            layer.draw();
        }, 1000);

      });

    if (this.locations.length > 0)
    {

        var first = this.locations[0];

        var last = this.locations[this.locations.length - 1];

        this.startMarker = new ImageMarker(
            new google.maps.LatLng(first[0], first[1]), options.map, {
            src: 'img/marker-start-pin.png',
            width: 48,
            height: 48,
            offsetX: 0,
            offsetY: -24,
            title: 'Start'
        });

        this.endMarker = new ImageMarker(
            new google.maps.LatLng(last[0], last[1]), options.map, {
            src: 'img/marker-end-pin.png',
            width: 48,
            height: 48,
            offsetX: 0,
            offsetY: -24,
            title: 'End'
        });
    }

    var lineCoords = [];

    for (var i = 0; i < this.locations.length; i++)
    {

        lineCoords.push({lat: this.locations[i][0], lng: this.locations[i][1]});
    }

    this.linePath = new google.maps.Polyline({
            path: lineCoords,
            geodesic: true,
            strokeColor: '#000',
            strokeOpacity: 1.0,
            strokeWeight: 3
    });

    this.linePath.setMap(options.map);
}

HistoryLayer.prototype.onAdd = function()
{

    var $pane = $(this.getPanes().overlayImage);

    $pane.append(this.markerLayer);
};

HistoryLayer.prototype.select = function(id)
{

    this.selectedId = id;
};

HistoryLayer.prototype.draw = function()
{

    var fragment = document.createDocumentFragment();

    var projection = this.getProjection();

    var layer = this;

    var map = this.getMap();

    var bounds = map.getBounds();

    this.markerLayer.empty();

    for (var i = 0; i < this.locations.length; i++)
    {
        var location = this.locations[i];

        var info = {
            latitude: location[0],
            longitude: location[1],
            id: i,
            marker_id: (i + 1) + '',
            type: location[5],
            heading: location[2],
            speed: location[3],
            timestamp: location[4],
            custom: location[6],
            icons: location[7]
        };

        var label = location[8];

        var latlng = new google.maps.LatLng(info.latitude, info.longitude);

        if (!bounds.contains(latlng))
        {
            continue;
        }

        var div = document.createElement('div');

        div.setAttribute('id', 'history-marker-' + i);

        div.setAttribute('data-index', i);

        var speed = parseInt(info.speed);

        var deg = info.heading;

        var point = projection.fromLatLngToDivPixel(latlng);

        if (point)
        {

            /*
             * based on customizable size, otherwise default to 24x24...
             */
            if (info.icons.marker_width && info.icons.marker_height)
            {
                div.style.left = (point.x - (info.icons.marker_width / 2)) + 'px';
                div.style.top = (point.y - (info.icons.marker_height / 2)) + 'px';

                div.style.width = info.icons.marker_width + 'px';
                div.style.height = info.icons.marker_height + 'px';
            }
            else
            {
                div.style.left = (point.x - 12) + 'px';
                div.style.top = (point.y - 12) + 'px';
            }
        }

        if (info.custom)
        {
            div.className = 'map-icon-marker-custom';

            switch (info.type)
            {

                case 'ignitionOff':
                    div.style.backgroundImage = 'url("img/' + info.icons.marker_ignitionoff + '")';
                    break;

                case 'standingTimeLimit':
                    div.style.backgroundImage = 'url("img/' + info.icons.marker_standing + '")';
                    break;

                case 'idlingTimeLimit':
                    div.style.backgroundImage = 'url("img/' + info.icons.marker_idling + '")';
                    break;

                default:
                    if (speed === 0)
                    {
                        div.style.backgroundImage = 'url("img/' + info.icons.marker_stop + '")';
                    }
                    else
                    {
                        div.style.backgroundImage = 'url("img/' + info.icons.marker_moving + '")';
                    }
            }

            div.title = label + '\n' + info.timestamp;

            div.style.position = 'absolute';

            div.style.cursor = 'pointer';
        }
        else
        {
            switch (info.type)
            {

                case 'ignitionOff':
                    div.className = 'map-icon-marker small ignitionoff';
                    break;

                case 'standingTimeLimit':
                    div.className = 'map-icon-marker small standing';
                    break;

                case 'idlingTimeLimit':
                    div.className = 'map-icon-marker small idling';
                    break;

                default:
                    if (speed === 0)
                    {
                        div.className = 'map-icon-marker small stop';
                    }
                    else
                    {
                        div.className = 'map-icon-marker small moving';
                    }
            }

            if (i === this.selectedId)
            {
                div.className += ' selected';
            }

            div.title = label + '\n' + info.timestamp;

            div.style.position = 'absolute';
            div.style.cursor = 'pointer';

            div.style.webkitTransform = 'rotate(' + deg + 'deg)';
            div.style.mozTransform = 'rotate(' + deg + 'deg)';
            div.style.msTransform = 'rotate(' + deg + 'deg)';
            div.style.oTransform = 'rotate(' + deg + 'deg)';
            div.style.transform = 'rotate(' + deg + 'deg)';
        }

        var _callback = this.callback;

        google.maps.event.addDomListener(div, "click", function(event)
        {

            _callback(this.getAttribute('data-index'));
        });

        fragment.appendChild(div);
    }

    this.markerLayer.append(fragment);  
};

HistoryLayer.prototype.remove = function()
{

    google.maps.event.removeListener(this.onboundchanged);

    this.startMarker.setMap(null);

    this.endMarker.setMap(null);

    this.linePath.setMap(null);

    this.markerLayer.remove();  
};

HistoryLayer.prototype.toggleLine = function(on)
{

    if (on)
    {
        var map = this.getMap();

        this.linePath.setMap(map);
    }
    else
    {
        this.linePath.setMap(null);
    }
};


/*
 * implementation of last location layer...
 */
LastLocationLayer.prototype = new google.maps.OverlayView();

function LastLocationLayer(locations, options)
{

    this.boundsChangedTimeout = null;

    this.locations = locations;

    this.setMap(options.map);

    this.markerLayer = $('<div />');

    var layer = this;

    this.onboundchanged = options.map.addListener('bounds_changed', function()
    {

        if (layer.boundsChangedTimeout !== null)
        {
            clearTimeout(layer.boundsChangedTimeout);

            layer.boundsChangedTimeout = null;
        }

        layer.boundsChangedTimeout = setTimeout(function()
        {
            layer.draw();
        }, 1000);

      });
    if ($(document.body).find('div#data-label').length > 3)
    { // Technically, this is to allow the label to align center, right below the marker. IS THERE ANOTHER WAY?????
        $(document.body).find('div#data-label').remove();
    }
    this.divMeasure = document.createElement('div');

    this.divMeasure.style.visibility = 'hidden';

    this.divMeasure.setAttribute('id', 'data-label');

    document.body.appendChild(this.divMeasure);
}

LastLocationLayer.prototype.onAdd = function()
{

    var $pane = $(this.getPanes().overlayImage);

    $pane.append(this.markerLayer);

//    this.infowindow = new google.maps.InfoWindow({
//        pixelOffset: new google.maps.Size(0, -8)
//    });
};

LastLocationLayer.prototype.draw = function()
{

    var fragment = document.createDocumentFragment();

    var projection = this.getProjection();

    var layer = this;

    var map = this.getMap();

    if (!map)
    {
        return false;
    }
    var bounds = map.getBounds();

    var drawLabel = this.drawLabel(bounds);

    var markerHeight = 24;

    this.markerLayer.empty();

    if (this.infowindow)
    {
        this.infowindow.close();
    }
    for (var i = 0; i < this.locations.length; i++)
    {

        var location = this.locations[i];

        var info = {
            latitude: location[0],
            longitude: location[1],
            marker_id: location[6],
            type: location[5],
            heading: location[2],
            popupHtml: location[7],
            id: location[8],
            speed: location[3],
            limitWidth: location[9],
            labelColor: location[10],
            custom: location[11],
            icons: location[12],
            labelOn: location[13]
        };

        if (drawLabel)
        {
            drawLabel = info.labelOn;
        }

        var latlng = new google.maps.LatLng(info.latitude, info.longitude);

        if (!bounds.contains(latlng))
        {
            continue;
        }

        var div = document.createElement('div');

        div.setAttribute('data-index', i);

        div.setAttribute('id', 'marker-asset-' + info.id);

        var speed = parseInt(info.speed);

        var deg = info.heading;

        var point = projection.fromLatLngToDivPixel(latlng);

        if (point)
        {

            /*
             * based on customizable size, otherwise default to 24x24...
             */
            if (info.icons.marker_width && info.icons.marker_height)
            {
                markerHeight = info.icons.marker_height;

                div.style.left = (point.x - (info.icons.marker_width / 2)) + 'px';
                div.style.top = (point.y - (info.icons.marker_height / 2)) + 'px';

                div.style.width = info.icons.marker_width + 'px';
                div.style.height = info.icons.marker_height + 'px';
            }
            else
            {
                div.style.left = (point.x - ((iconSize.width / 2) + iconSize.offsetX)) + 'px';
                div.style.top = (point.y - ((iconSize.height / 2) + iconSize.offsetY)) + 'px';
            }

            if (info.icons.marker_z_index)
            {
                div.style.zIndex = info.icons.marker_z_index;
            }
        }

        if (info.custom)
        {
            div.className = 'map-icon-marker-custom';

            switch (info.type)
            {

                case 'ignitionOff':
                    div.style.backgroundImage = 'url("img/' + info.icons.marker_ignitionoff + '")';
                    break;

                case 'standingTimeLimit':
                    div.style.backgroundImage = 'url("img/' + info.icons.marker_standing + '")';
                    break;

                case 'idlingTimeLimit':
                    div.style.backgroundImage = 'url("img/' + info.icons.marker_idling + '")';
                    break;

                default:
                    if (speed === 0)
                    {
                        div.style.backgroundImage = 'url("img/' + info.icons.marker_stop + '")';
                    }
                    else
                    {
                        div.style.backgroundImage = 'url("img/' + info.icons.marker_moving + '")';
                    }
            }

            div.style.position = 'absolute';

            div.style.cursor = 'pointer';
        }
        else
        {
            switch (info.type)
            {
                case 'ignitionOff':
                case 'mobilise':
                    div.className = 'map-icon-marker small ignitionoff';
                    break;

                case 'standingTimeLimit':
                    div.className = 'map-icon-marker small standing';
                    break;

                case 'idlingTimeLimit':
                    div.className = 'map-icon-marker small idling';
                    break;
                case 'immobilise':
                    div.className = 'map-icon-marker small immobilise';
                    break;
                case '':

                    div.className = 'map-icon-marker small';

                    div.style.backgroundColor = info.labelColor;

                    break;
                default:
                    if (speed === 0)
                    {
                        div.className = 'map-icon-marker small stop';
                    }
                    else
                    {
                        div.className = 'map-icon-marker small moving';
                    }
            }

            div.style.position = 'absolute';
            div.style.cursor = 'pointer';

            div.style.webkitTransform = 'rotate(' + deg + 'deg)';
            div.style.mozTransform = 'rotate(' + deg + 'deg)';
            div.style.msTransform = 'rotate(' + deg + 'deg)';
            div.style.oTransform = 'rotate(' + deg + 'deg)';
            div.style.transform = 'rotate(' + deg + 'deg)';
        }

        if (typeof (info.marker_id) !== 'undefined')
        {

            div.dataset.marker_id = info.marker_id;
        }

        //var _infowindow = this.infowindow;

        var _mouseover = null;

        google.maps.event.addDomListener(div, "click", function(event)
        {

//            if (_infowindow) {
//                _infowindow.close();
//            }
            var _infowindow = new google.maps.InfoWindow({
                //pixelOffset: new google.maps.Size(0, -8)
            });

            var info = layer.locations[this.getAttribute('data-index')];

            _infowindow.open(this._map, layer);

            _infowindow.setPosition(new google.maps.LatLng(info[0], info[1]));

            _infowindow.setContent(info[7]);

            //sets origin's details for finding ETA
            resetOriginDetails(info[6],info[0], info[1]);

            directionsRenderer.setMap(null);

//            setTimeout(function()
//            {
//                _infowindow.close()
//            }, 5000);

            event.preventDefault();
        });

        google.maps.event.addDomListener(div, "mouseover", function(event)
        {

            var info = layer.locations[this.getAttribute('data-index')];

            var marker = document.getElementById('marker-asset-' + info[8]);

            var markerLabel = document.getElementById('marker-asset-label-' + info[8]);

            _mouseover = {id: info[8], zIndex: marker.style.zIndex};

            marker.style.zIndex = 999;

            if (markerLabel)
            {
                markerLabel.style.zIndex = 999;
            }
            event.preventDefault();
        });

        google.maps.event.addDomListener(div, "mouseout", function(event)
        {

            document.getElementById('marker-asset-' + _mouseover.id).style.zIndex = _mouseover.zIndex;

            if (document.getElementById('marker-asset-label-' + _mouseover.id))
            {
                document.getElementById('marker-asset-label-' + _mouseover.id).style.zIndex = _mouseover.zIndex;
            }

            _mouseover = null;

            event.preventDefault();
        });

        if (drawLabel && !info.icons.marker_hide_label)
        {
            var divLabel = document.createElement('div');

            divLabel.setAttribute('id', 'marker-asset-label-' + info.id);

            if (info.limitWidth === true)
            {
                this.divMeasure.className = divLabel.className = 'leaflet-marker-label';
            }
            else
            {
                this.divMeasure.className = divLabel.className = 'leaflet-marker-label auto-width';
            }

            if (info.labelColor !== undefined)
            {
                divLabel.style.backgroundColor = info.labelColor;

                // auto adjust font color if background is too dark or too bright...
                if (getBrightness(info.labelColor) > 128)
                {
                    divLabel.style.color = '#000';
                }
            }

            this.divMeasure.innerHTML = divLabel.innerHTML = info.marker_id;

            if (point)
            {
                divLabel.style.left = (point.x - (this.divMeasure.offsetWidth / 2)) + 'px';
                divLabel.style.top = (point.y + (markerHeight / 2) - 4) + 'px';
            }

            /*
             * just don't allow the labels to cover any of the markers...
             */
            if (info.icons.marker_z_index)
            {
                divLabel.style.zIndex = info.icons.marker_z_index - 1000;
            }
            else
            {
                divLabel.style.zIndex = -1000;
            }

            fragment.appendChild(divLabel);
        }

        fragment.appendChild(div);
    }

    this.markerLayer.append(fragment);  
};

LastLocationLayer.prototype.onRemove = function()
{
//    this.div_.parentNode.removeChild(this.div_);
//    this.div_ = null;
};

LastLocationLayer.prototype.remove = function()
{

    this.markerLayer.remove();  

    if (this.infowindow)
    {
        this.infowindow.close();
    }

    google.maps.event.removeListener(this.onboundchanged);
};

LastLocationLayer.prototype.removeMarker = function(id)
{

//    for (var i = 0; i < this.locations.length; i++ ){ // remove from the lastlocation layer itself
//        if(this.locations[i][8] == id){
//            this.locations.splice(i, 1);
//        }
//    }
    $('#marker-asset-' + id).remove();

    $('#marker-asset-label-' + id).remove();

    if (this.infowindow)
    {
        this.infowindow.close();
    }
};

LastLocationLayer.prototype.toggle = function(on)
{

    if (on)
    {
        this.markerLayer.css('visibility', 'visible');
    }
    else
    {
        this.markerLayer.css('visibility', 'hidden');

        if (this.infowindow)
        {
            this.infowindow.close();
        }
    }
};

LastLocationLayer.prototype.toggleLabel = function(on)
{

    if (on)
    {
        $('div[id^=marker-asset-label-]').css('visibility', 'visible');
    }
    else
    {
        $('div[id^=marker-asset-label-]').css('visibility', 'hidden');

        if (this.infowindow)
        {
            this.infowindow.close();
        }
    }
};

LastLocationLayer.prototype.drawLabel = function(bounds)
{

    var count = 0;

    for (var i = 0; i < this.locations.length; i++)
    {

        var location = this.locations[i];

        var latlng = new google.maps.LatLng(location[0], location[1]);

        if (bounds.contains(latlng))
        {
            count++;
        }
    }

    return count < 50;
};

LastLocationLayer.prototype.openMarkerDetails = function(lat, lng, popupText)
{
//        var _infowindow = this.infowindow;

    var _infowindow = new google.maps.InfoWindow({
    });

    _infowindow.open(this._map, this);

    _infowindow.setPosition(new google.maps.LatLng(lat, lng));

    _infowindow.setContent(popupText);

//    setTimeout(function()
//    {
//        _infowindow.close()
//    }, 5000);
}

/*
 *
 * implementation of image marker...
 */
ImageMarker.prototype = new google.maps.OverlayView();

function ImageMarker(latlng, map, args)
{

    this.latlng = latlng;

    this.args = args;

    this.setMap(map);
}

ImageMarker.prototype.onAdd = function()
{

    var div = this.div;

    if (!div)
    {

        div = this.div = document.createElement('div');

        div.style.position = 'absolute';
        div.style.cursor = 'pointer';
        div.style.display = 'block';
        div.style.zIndex = 999999;
        div.title = this.args.title;

        var panes = this.getPanes();

        panes.overlayImage.appendChild(div);

        div.innerHTML = '<img src="' + this.args.src + '" alt="start" height="' + this.args.height + '" width="' + this.args.width + '">';
    }
};

ImageMarker.prototype.draw = function()
{

    var div = this.div;

    var point = this.getProjection().fromLatLngToDivPixel(this.latlng);

    if (point)
    {

        div.style.left = (point.x - (div.offsetWidth / 2) + this.args.offsetX) + 'px';

        div.style.top = (point.y - (div.offsetHeight / 2) + this.args.offsetY) + 'px';
    }
};

ImageMarker.prototype.remove = function()
{

    if (this.div)
    {

        this.div.parentNode.removeChild(this.div);
        this.div = null;
    }
};

ImageMarker.prototype.getPosition = function()
{

    return this.latlng;
};


/*
 * address search functions...
 */
var AddressSearchBox = function(div, speed, callback, includeSG)
{

    var _this = {
        callback: callback,
        timer: null,
        searchText: null,
        list: null,
        enable: function()
        {

            var parent = $('#' + div);
            parent.addClass('search-box');
            var input = parent.children('input')[0];
            input = $(input);
            input.keyup(_this.inputCallback);
            _this.list = $('<ul/>', {
                class: 'search-result-box'
            });
            _this.list.insertAfter(input);
        },
        clear: function()
        {

            _this.list.empty();
        },
        inputCallback: function()
        {

            if (_this.timer !== null)
            {
                clearTimeout(_this.timer);
                _this.timer = null;
            }

            _this.searchText = this.value;
            if (_this.searchText.length > 3)
            {
                _this.timer = setTimeout(_this.timerCallback, speed);
            }
        },
        timerCallback: function()
        {

            _this.list.empty();
            if (includeSG)
            {
                $.ajax({
                    type: 'GET',
                    url: 'LocationServiceController?type=system&action=geocode',
                    data: {
                        address: _this.searchText
                    },
                    success: function(data)
                    {

                        if (data.result)
                        {
                            for (i = 0; i < data.locations.length; i++)
                            {

                                var location = data.locations[i];
                                var item = $('<li/>');
                                // must use mousedown instead of click otherwise the list will lost focus...
                                var address = $('<a/>', {
                                    'data-longitude': location.longitude,
                                    'data-latitude': location.latitude
                                }).on('mousedown', function()
                                {

                                    var elem = $(this);
                                    var parent = elem.parents('div');
                                    var input = parent.children('input')[0];
                                    input.value = elem.html();
                                    _this.callback(elem.html(), elem.attr('data-longitude'), elem.attr('data-latitude'));
                                });
                                address.html(location.formatted_address.toUpperCase());
                                item.append(address);
                                _this.list.prepend(item);
                            }
                        }
                    },
                    complete: function()
                    {

                    },
                    error: function()
                    {

                    },
                    async: true
                });
            }

            $.ajax({
                type: 'GET',
                url: 'googleapi?type=geocode&action=address',
                data: {
                    address: _this.searchText
                },
                success: function(data)
                {

                    for (i = 0; i < data.results.length; i++)
                    {

                        var result = data.results[i];
                        var item = $('<li/>');
                        // must use mousedown instead of click otherwise the list will lost focus...
                        var address = $('<a/>', {
                            'data-longitude': result.geometry.location.lng,
                            'data-latitude': result.geometry.location.lat
                        }).on('mousedown', function()
                        {

                            var elem = $(this);
                            var parent = elem.parents('div');
                            var input = parent.children('input')[0];
                            input.value = elem.html();
                            _this.callback(elem.html(), elem.attr('data-longitude'), elem.attr('data-latitude'));
                        });
                        address.html(result.formatted_address.toUpperCase());
                        item.append(address);
                        _this.list.append(item);
                    }

                },
                complete: function()
                {

                },
                error: function()
                {

                },
                async: true
            });
        }
    };
    return _this;
};

var AddressSearchBoxSingapore = function(div, speed, callback)
{

    var _this = {
        timerCallback: function()
        {

            $.ajax({
                type: 'GET',
                url: 'LocationServiceController?type=system&action=geocode',
                data: {
                    address: _this.searchText
                },
                success: function(data)
                {

                    if (data.result)
                    {
                        _this.list.empty();
                        for (i = 0; i < data.locations.length; i++)
                        {

                            var location = data.locations[i];
                            var item = $('<li/>');
                            // must use mousedown instead of click otherwise the list will lost focus...
                            var address = $('<a/>', {
                                'data-longitude': location.longitude,
                                'data-latitude': location.latitude
                            }).on('mousedown', function()
                            {

                                var elem = $(this);
                                var parent = elem.parents('div');
                                var input = parent.children('input')[0];
                                input.value = elem.html();
                                _this.callback(elem.html(), elem.attr('data-longitude'), elem.attr('data-latitude'));
                            });
                            address.html(location.formatted_address);
                            item.append(address);
                            _this.list.append(item);
                            address;
                        }
                    }
                },
                complete: function()
                {

                },
                error: function(data)
                {

                },
                async: true
            });
        }
    };
    _this = $.extend(new AddressSearchBox(div, speed, callback), _this);
    return _this;
};

v3nityMap.prototype.getETA = function(origLat, origLng, destLat, destLng, callback) {

    $.ajax({
        type: 'GET',
        url: 'googleapi?type=trip&action=eta',
        data: {
            origLat: origLat,
            origLng: origLng,
            destLat: destLat,
            destLng: destLng
        },
        success: function(data) {
            callback(data);
        },
        complete: function() {

        },
        error: function(data) {

        },
        async: true
    });
};

v3nityMap.prototype.initDirectionRenderer = function() {

    directionsService = new google.maps.DirectionsService();

    directionsRenderer = new google.maps.DirectionsRenderer();

};

v3nityMap.prototype.clearDirectionRenderer = function() {

    directionsRenderer.setMap(null);

};

v3nityMap.prototype.drawRoute = function(origLat, origLng, destLat, destLng) {

    directionsService = new google.maps.DirectionsService();

    directionsRenderer = new google.maps.DirectionsRenderer();

    directionsRenderer.setMap(this._map);

    var start = new google.maps.LatLng(origLat, origLng);

    var end = new google.maps.LatLng(destLat, destLng);

    var request = {
      origin: start,
      destination: end,
      travelMode: 'DRIVING'
    };

    directionsService.route(request, function(result, status) {
      if (status == 'OK') {
        directionsRenderer.setDirections(result);
      }
    });
};

v3nityMap.prototype.drawBrushDownPath = function(pathCoords, count, label) {
    
    var startMarker = new google.maps.Marker({
      map: this._map,
      position: {lat: pathCoords[0].lat, lng: pathCoords[0].lng}
    });
    
    brushMarkers.push(startMarker);
    
    var endMarker = new google.maps.Marker({
      map: this._map,
      position: {lat: pathCoords[pathCoords.length - 1].lat, lng: pathCoords[pathCoords.length - 1].lng}
    });
    
    brushMarkers.push(endMarker);
    
    var startJobinfowindow = new google.maps.InfoWindow();
    
    google.maps.event.addListener(endMarker, 'click', (function(marker, content, infowindow) { 
      return function(evt) {
        infowindow.setContent(content);
        infowindow.open(this._map, marker);
    }})(startMarker, label + "<br>Started Trip #" + count, startJobinfowindow));

    //google.maps.event.trigger(startMarker, 'click');
    
    
    var stopJobinfowindow = new google.maps.InfoWindow();
    
    google.maps.event.addListener(endMarker, 'click', (function(marker, content, infowindow) { 
      return function(evt) {
        infowindow.setContent(content);
        infowindow.open(this._map, marker);
    }})(endMarker, label + "<br>Stopped Trip #" + count, stopJobinfowindow));

    //google.maps.event.trigger(endMarker, 'click');
    
    var lineSymbol = {
        path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW
    };
      
    var assetPath = new google.maps.Polyline({
        path: pathCoords,
        geodesic: true,
        strokeColor: "#006400",
        strokeOpacity: 1.0,
        strokeWeight: 2,
        icons: [
          {
            icon: lineSymbol,
            repeat:'35px',
            offset: "100%",
          }
        ]
      });
      
    assetPath.setMap(this._map);
    
    assetPathArr.push(assetPath);
};

v3nityMap.prototype.drawBrushUpPath = function(pathCoords) {
    
    const lineSymbol = {
        path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW
    };
      
    var assetPath = new google.maps.Polyline({
        path: pathCoords,
        geodesic: true,
        strokeColor: "#FF0000",
        strokeOpacity: 1.0,
        strokeWeight: 2,
        icons: [
          {
            icon: lineSymbol,
            repeat:'35px',
            offset: "100%",
          }
        ]
      });
      
    assetPath.setMap(this._map);
    
    assetPathArr.push(assetPath);
};

v3nityMap.prototype.clearBrushPath = function() {
    
    for (var i = 0; i < assetPathArr.length; i++)
    {
        assetPathArr[i].setMap(null);
    }

    assetPathArr = [];
    
    for (var i = 0; i < brushMarkers.length; i++)
    {
        brushMarkers[i].setMap(null);
    }

    existSimpleMarker = {};
}