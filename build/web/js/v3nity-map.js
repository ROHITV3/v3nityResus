/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

$('head').append('<script type=\"text/javascript\" src=\"js/leaflet.js\"></script>');
$('head').append('<link rel="stylesheet" href="css/leaflet.css" type="text/css" />');

/*
 * v3nityMap
 */

function v3nityMap(id) {
    this._mapview = $('#' + id);

    this._map = L.map(id); // must be initialized in document.load ...

    this._baseLayers = [];

    this._drawLayer = new L.LayerGroup().addTo(this._map); //global layer to store drawElements

    this._mapview.append("<div id='guidetext' style='position:absolute;float:left;margin:-52px 0 0 -12px;padding:4px;white-space:nowrap;display:none;color:white;font-size:medium;background-color:rgba(0,0,0,0.8);'></div>"); //initialize guide text used for drawing

    this.dropMarkerLayer = this.createOverlay();
}

v3nityMap.getCountry = function(ip) {
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
        success: function(data) {
            return data;
        }
    });
};

v3nityMap.prototype.defaultOptions = function(options) {

    this.setDefaultView([[options.bounds[0], options.bounds[1]], [options.bounds[2], options.bounds[3]]]);

    // SLA Map Tiles...
    this.addBaseLayer('http://map.v3nity.com/v3_sg_tms/{z}/{x}/{y}.png', {minZoom: 11, maxZoom: 19, bounds: [[1.47098, 104.02095], [1.23784, 103.617264]]});

    // Google Map Tiles Types...
    // h = roads only
    // m = standard roadmap
    // p = terrain
    // r = somehow altered roadmap
    // s = satellite only
    // t = terrain only
    // y = hybrid
    this.addBaseLayer('http://mt{s}.google.com/vt/lyrs=m&z={z}&x={x}&y={y}', {minZoom: 1, maxZoom: 19, subdomains: '0123'});
    this.addBaseLayer('http://mt{s}.google.com/vt/lyrs=p&z={z}&x={x}&y={y}', {minZoom: 1, maxZoom: 19, subdomains: '0123'});
    this.addBaseLayer('http://mt{s}.google.com/vt/lyrs=s&z={z}&x={x}&y={y}', {minZoom: 1, maxZoom: 19, subdomains: '0123'});
    this.addBaseLayer('http://mt{s}.google.com/vt/lyrs=y&z={z}&x={x}&y={y}', {minZoom: 1, maxZoom: 19, subdomains: '0123'});
    this.addBaseLayer('http://mt{s}.google.com/vt/lyrs=h&z={z}&x={x}&y={y}', {minZoom: 1, maxZoom: 19, subdomains: '0123'});

    this.changeBaseLayer([1, 0]);
};

v3nityMap.prototype.remove = function() {
    this._map.remove();
};

v3nityMap.prototype.setDefaultView = function(bounds) {
    this._map.fitBounds([[bounds[0], bounds[1]], [bounds[2], bounds[3]]]);

    this._bounds = bounds;
};

v3nityMap.prototype.addBaseLayer = function(url, options) {
    if (options.subdomains === undefined) {
        options.subdomains = 'abc';
    }

    var layer = L.tileLayer(url, {minZoom: options.minZoom, maxZoom: options.maxZoom, _bounds: options.bounds, subdomains: options.subdomains, detectRetina: true, reuseTiles: true});

    this._baseLayers.push(layer);
};

v3nityMap.prototype.changeBaseLayer = function(indexes) {
    var layer;

    for (i = 0; i < this._baseLayers.length; i++) {
        layer = this._baseLayers[i];

        // only remove layer if it is current not shown...
        if (this._map.hasLayer(layer) && indexes.indexOf(i, 0) === -1) {
            this._map.removeLayer(layer);
        }
    }

    for (j = 0; j < indexes.length; j++) {
        layer = this._baseLayers[indexes[j]];

        if (!this._map.hasLayer(layer)) {
            this._map.addLayer(layer);
        }
    }
};

v3nityMap.prototype.createOverlay = function() {
    var layer = new L.LayerGroup().addTo(this._map);

    return layer;
};

v3nityMap.prototype.clearOverlay = function(layer) {
    if (this._map.hasLayer(layer)) {
        layer.clearLayers();
    }
};

v3nityMap.prototype.hideOverlay = function(layer) {
    if (this._map.hasLayer(layer)) {
        this._map.removeLayer(layer);
    }
};

v3nityMap.prototype.showOverlay = function(layer) {
    if (!this._map.hasLayer(layer)) {
        this._map.addLayer(layer);
    }
};

v3nityMap.prototype.createHistoryLayer = function(options) {
    var layer = new L.HistoryPoints(options).addTo(this._map);

    return layer;
};

v3nityMap.prototype.createPolygon = function(latlngs) {
    var data = {
        color: '#000',
        weight: 4,
        opacity: 1.0,
        fill: true,
        fillColor: '#000',
        fillOpacity: 0.5
    };

    var polygon = new L.polygon(latlngs, data);

    return polygon;
};

v3nityMap.prototype.createIcon = function(data) {
    if (data.iconanchor === undefined)
        data.iconanchor = [data.iconsize[0] / 2, data.iconsize[1]]; //default bottom center

    if (data.shadow === undefined)
        data.shadow === false; //default no shadow

    if (data.shadow)
        shadowarray = [];
    else
        shadowarray = [0, 0];

    var CustomPin = L.Icon.Default.extend({
        options: {
            iconUrl: data.iconurl,
            iconSize: [data.iconsize[0], data.iconsize[1]],
            iconAnchor: [data.iconanchor[0], data.iconanchor[1]],
            shadowSize: shadowarray
        }
    });

    var customPin = new CustomPin();

    return customPin;
};

v3nityMap.prototype.createMarkerIcon = function(data) {

    var icon = L.divIcon(data);

    return icon;
};

v3nityMap.prototype.createMarker = function(data) {

    if (data.icon === undefined) {
        data.icon = new L.Icon.Default(); //use default if undefined
    }
    if (data.popup === undefined) {
        data.popup = '';
    }
    if (data.popupoffset === undefined) {
        data.popupoffset = [0, -32];
    }
    var marker = new L.Asset([data.latlng[0], data.latlng[1]], {riseOnHover: true, icon: data.icon, title: data.title, label: data.label, angle: data.angle});

    if (data.popup !== undefined) {
        marker.bindPopup(data.popup, {offset: data.popupoffset});
    }

    return marker;
};

v3nityMap.prototype.removeMarker = function(marker, layer) {
    layer.removeLayer(marker);
};

v3nityMap.prototype.addMarker = function(marker, layer) {
    layer.addLayer(marker);
};

v3nityMap.prototype.zoomTo = function(lat, lng, zoom) {
    if (zoom === undefined) {
        this._map.panTo([lat, lng]);
    }
    else {
        if (lat !== undefined || lng !== undefined) { //if lat,lng is defined
            this._map.setView([lat, lng], zoom); //Set view
        }
        else { //else zoom only
            this._map.setZoom(zoom);
        }
    }
};

v3nityMap.prototype.zoomToPolygon = function(polygon) {
    this._map.fitBounds(polygon.getBounds());
};

v3nityMap.prototype.zoomToDefault = function() {
    this._map.fitBounds([[this._bounds[0], this._bounds[1]], [this._bounds[2], this._bounds[3]]]);
};

v3nityMap.prototype.zoomIn = function() {
    this._map.zoomIn();
};

v3nityMap.prototype.zoomOut = function() {
    this._map.zoomOut();
};

v3nityMap.prototype.zoomWorld = function() {
    this._map.fitWorld();
};

v3nityMap.prototype.zoomBound = function(minLat, minLng, maxLat, maxLng, paddingTopLeft) {
    if (paddingTopLeft === undefined) {
        paddingTopLeft = [0, 0];
    }

    if (minLat !== undefined && maxLng !== undefined && maxLat !== undefined && minLng !== undefined) {
        this._map.fitBounds([[minLat, minLng], [maxLat, maxLng]], {paddingTopLeft: paddingTopLeft});
    }
};

v3nityMap.prototype.drawPolygonStart = function() {
    if (this._mapview.css('cursor') !== 'crosshair') {
        var polygon;

        var layers = this._drawLayer.getLayers();

        if (layers.length > 0) {
            polygon = layers[0];
        }
        else {
            var data = {
                color: '#000',
                weight: 4,
                opacity: 1.0,
                fill: true,
                fillColor: '#FFC400',
                fillOpacity: 0.3
            };

            polygon = new L.polygon([], data);
        }

        var guideline = new L.polyline([], {//initialize guide lines used for drawing
            color: '#000',
            weight: 4,
            opacity: 1.0,
            dashArray: "10, 10",
            clickable: false
        });

        var guidetext = $("#guidetext");

        this._drawLayer.clearLayers();

        this._drawLayer.addLayer(polygon);

        this._drawLayer.addLayer(guideline);

        this._mapview.css('cursor', 'crosshair'); //change mouse cursor to crosshair

        this._mapview.on('mousemove', function(e) { //bind #guidetext to mouse
            guidetext.css({left: e.pageX, top: e.pageY, display: 'initial'});
        });

        var points = polygon.getLatLngs();

        guidetext.html("Click to start drawing shape");

        this._map.on('click', function(e) {
            guidetext.html("Click to continue drawing shape");

            polygon.addLatLng(e.latlng, true);
        });

        this._map.on('mousemove', function(e) {
            if (points.length > 0) {
                var last = points[points.length - 1];

                var first = points[0];

                guideline.setLatLngs([last, e.latlng, first]);
            }
        });
    }
};

v3nityMap.prototype.drawPolylineStart = function() {

    if (this._mapview.css('cursor') !== 'crosshair') {
        var polyline;

        var layers = this._drawLayer.getLayers();

        if (layers.length > 0) {
            polyline = layers[0];
        }
        else {
            var data = {
                color: '#000',
                weight: 4,
                opacity: 1.0
            };

            polyline = new L.polyline([], data);
        }

        var guideline = new L.polyline([], {//initialize guide lines used for drawing
            color: '#000',
            weight: 4,
            opacity: 1.0,
            dashArray: "10, 10",
            clickable: false
        });

        var guidetext = $("#guidetext");

        this._drawLayer.clearLayers();

        this._drawLayer.addLayer(polyline);

        // this._drawLayer.addLayer(guideline);

        this._mapview.css('cursor', 'crosshair'); //change mouse cursor to crosshair

        this._mapview.on('mousemove', function(e) { //bind #guidetext to mouse
            guidetext.css({left: e.pageX, top: e.pageY, display: 'initial'});
        });

        var points = polyline.getLatLngs();

        guidetext.html("Click to start drawing shape");

        this._map.on('click', function(e) {
            guidetext.html("Click to continue drawing shape");

            polyline.addLatLng(e.latlng, true);
        });

        this._map.on('mousemove', function(e) {
            if (points.length > 0) {
                var last = points[points.length - 1];

                var first = points[0];

                guideline.setLatLngs([last, e.latlng, first]);
            }
        });
    }
};



v3nityMap.prototype.drawPolygonUndo = function() {
    var layers = this._drawLayer.getLayers();

    var polygon = layers[0];

    var guideline = layers[1];

    var points = polygon.getLatLngs();

    if (points.length > 1) {
        points.pop();   // remove last point...

        polygon.redraw();

        if (points.length > 0) {
            var gl = guideline.getLatLngs();

            guideline.setLatLngs([points[points.length - 1], gl[1], gl[2]]);
        }
        else {
            guideline.setLatLngs([gl[1], gl[2]]);
        }
    }
    else {
        this.drawPolygonCancel();
    }
};

v3nityMap.prototype.drawPolygonCancel = function() {
    this.drawPolygonStop();

    this._drawLayer.clearLayers();
};

v3nityMap.prototype.drawPolygonStop = function() {
    var layers = this._drawLayer.getLayers();

    var guideline = layers[1];  // this is the guideline layer...

    if (guideline !== undefined) {
        var guidelineLatLngs = guideline.getLatLngs();

        guidelineLatLngs.length = 0;

        guideline.redraw();

        $("#guidetext").hide();
    }

    this._mapview.css('cursor', 'auto');

    this._mapview.off('mousemove');

    this._map.off('click');

    this._map.off('mousemove');
};

v3nityMap.prototype.getPolygonLatLngs = function() {
    var layers = this._drawLayer.getLayers();

    return layers[0].getLatLngs();
};

v3nityMap.prototype.drawRoute = function(locations) {
    var pointList = [];
    for (i = 0; i < locations.length; i++) {
        pointList.push(new L.latLng(locations[i].lat, locations[i].lng));
    }

    var data = {
        color: '#000',
        weight: 4,
        opacity: 1.0
    };

    for (i = 0; i < pointList.length - 1; i++) {
        var points = [pointList[i], pointList[i + 1]];
        var polyline = new L.polyline(points, data);

        this._drawLayer.addLayer(polyline);
    }
};

v3nityMap.prototype.getPolylineLatLngs = function() {
    var layers = this._drawLayer.getLayers();
    return layers[0].getLatLngs();
};


v3nityMap.prototype.setPolygonLatLngs = function(latlngs) {
    var data = {
        color: '#000',
        weight: 4,
        opacity: 1.0,
        fill: true,
        fillColor: '#FFC400',
        fillOpacity: 0.5
    };

    this._drawLayer.clearLayers();

    var polygon = new L.polygon(latlngs, data);

    this._drawLayer.addLayer(polygon);
};

v3nityMap.prototype.isDrawing = function() {
    var layers = this._drawLayer.getLayers();

    return (layers.length > 0);
};

v3nityMap.prototype.getDrawCount = function() {
    var layers = this._drawLayer.getLayers();

    if (layers.length > 0) {
        return layers[0].getLatLngs().length;
    }
    else {
        return 0;
    }
};

v3nityMap.prototype.convertSerialCoordinatesToLatLng = function(points) {

    var array = [];

    for (i = 0; i < points.length; i += 2) {
        array.push(new L.latLng(points[i], points[i + 1]));
    }

    return array;
};

v3nityMap.prototype.enableDropMarker = function(callback, icon) {

    var thisMap = this;

    thisMap._map.on('click', function(e) {

        thisMap.clearOverlay(thisMap.dropMarkerLayer);

        var coords = e.latlng;

        reverseGeocode(coords.lat + ',' + coords.lng, function(location) {

            thisMap.dropMarker = thisMap.createMarker({
                latlng: [coords.lat, coords.lng],
                icon: icon,
                popup: '<h5>' + location + '</h5><h6>[' + (Math.round(coords.lng * 100000) / 100000) + ',' + (Math.round(coords.lat * 100000) / 100000) + ']</h6>',
                popupoffset: [0, -54]
            });

            thisMap.addMarker(thisMap.dropMarker, thisMap.dropMarkerLayer);

            callback(coords.lat, coords.lng, location);
        });
    });
};

v3nityMap.prototype.disableDropMarker = function() {

    this.clearOverlay(this.dropMarkerLayer);

    this._map.off('click');

};



v3nityMap.prototype.nokiaSearchAddress = function(query, callback) {
    $.ajax({
        type: 'GET',
        url: 'https://geocoder.api.here.com/6.2/geocode.json',
        data: {
            app_id: '5DM6u9WMrdPb1l6CZXXS',
            app_code: '9a-2j80gPNU2ABsOKGXFmA',
            searchtext: query,
            gen: '8'
        },
        success: function(data) {
            var results = [];

            for (j = 0; j < data.Response.View.length; j++) {
                for (i = 0; i < data.Response.View[j].Result.length; i++) {
                    var result = data.Response.View[j].Result[i];

                    results.push({
                        longitude: result.Location.DisplayPosition.Longitude,
                        latitude: result.Location.DisplayPosition.Latitude,
                        label: result.Location.Address.Label,
                        country: result.Location.Address.Country,
                        county: result.Location.Address.County,
                        city: result.Location.Address.City,
                        district: result.Location.Address.District,
                        street: result.Location.Address.Street
                    });
                }
            }

            data = {
                result: results
            };

            callback(data);
        },
        async: true
    });
};

v3nityMap.prototype.searchAddress = function(query, callback, domainUrl) {

    $.ajax({
        type: 'GET',
        url: 'https://maps.googleapis.com/maps/api/geocode/json',
        data: {
            address: query
                    //address: query,
                    //v: 3.22,
                    //client: (domainUrl.toLowerCase().indexOf('localhost') > -1) ? '' : 'gme-v3teletech'
        },
        success: function(data) {

            var results = [];

            for (i = 0; i < data.results.length; i++) {

                var result = data.results[i];

                results.push({
                    longitude: result.geometry.location.lng,
                    latitude: result.geometry.location.lat,
                    label: result.formatted_address,
                    country: '',
                    county: '',
                    city: '',
                    district: '',
                    street: ''
                });
            }

            data = {
                result: results
            };

            callback(data);
        },
        complete: function() {

        },
        error: function(data) {

        },
        async: true
    });
};

/*
 * L.RotatedMarker
 */
L.RotatedMarker = L.Marker.extend({
    options: {
        angle: 0
    },
    statics: {
        TRANSFORM_ORIGIN: L.DomUtil.testProp(
                ['transformOrigin', 'WebkitTransformOrigin', 'OTransformOrigin', 'MozTransformOrigin', 'msTransformOrigin'])
    },
    _initIcon: function() {
        L.Marker.prototype._initIcon.call(this);

        this._icon.style[L.RotatedMarker.TRANSFORM_ORIGIN] = '50% 50%';
    },
    _setPos: function(pos) {
        L.Marker.prototype._setPos.call(this, pos);

        if (L.DomUtil.TRANSFORM) {
            // use the CSS transform rule if available
            this._icon.style[L.DomUtil.TRANSFORM] += ' rotate(' + this.options.angle + 'deg)';
        }
        else if (L.Browser.ie) {
            // fallback for IE6, IE7, IE8
            var rad = this.options.angle * (Math.PI / 180),
                    costheta = Math.cos(rad),
                    sintheta = Math.sin(rad);
            this._icon.style.filter += ' progid:DXImageTransform.Microsoft.Matrix(sizingMethod=\'auto expand\', M11=' +
                    costheta + ', M12=' + (-sintheta) + ', M21=' + sintheta + ', M22=' + costheta + ')';
        }
    },
    setAngle: function(ang) {
        this.options.angle = ang;
    }
});


/*
 * L.Asset
 */
L.Asset = L.Marker.extend({
    includes: L.Mixin.Events,
    options: {
        label: '',
        angle: 0
    },
    statics: {
        TRANSFORM_ORIGIN: L.DomUtil.testProp(
                ['transformOrigin', 'WebkitTransformOrigin', 'OTransformOrigin', 'MozTransformOrigin', 'msTransformOrigin'])
    },
    initialize: function(latlng, options) {
        L.Marker.prototype.initialize.call(this, latlng, options);
    },
    onRemove: function(map) {
        if (this.dragging) {
            this.dragging.disable();
        }

        this._removeIcon();
        this._removeLabel();
        this._removeShadow();

        this.fire('remove');

        map.off({
            'viewreset': this.update,
            'zoomanim': this._animateZoom
        }, this);

        this._map = null;
    },
    toggleLabel: function(enable) {
        if (this._label) {
            if (enable) {
                this._map._panes.markerPane.appendChild(this._label);
            }
            else {
                this._map._panes.markerPane.removeChild(this._label);
            }
        }
    },
    // something wrong with the function...
    setAngle: function(ang) {
        this.options.angle = ang;
    },
    _initIcon: function() {
        var options = this.options,
                map = this._map,
                animation = (map.options.zoomAnimation && map.options.markerZoomAnimation),
                classToAdd = animation ? 'leaflet-zoom-animated' : 'leaflet-zoom-hide';

        var icon = options.icon.createIcon(this._icon),
                addIcon = false;

        // if we're not reusing the icon, remove the old one and init new one
        if (icon !== this._icon) {
            if (this._icon) {
                this._removeIcon();
                this._removeLabel();
            }
            addIcon = true;

            if (options.title) {
                icon.title = options.title;
            }

            if (options.alt) {
                icon.alt = options.alt;
            }
        }

        L.DomUtil.addClass(icon, classToAdd);

        if (options.keyboard) {
            icon.tabIndex = '0';
        }

        this._icon = icon;

        this._initInteraction();

        if (options.riseOnHover) {
            L.DomEvent
                    .on(icon, 'mouseover', this._bringToFront, this)
                    .on(icon, 'mouseout', this._resetZIndex, this);
        }

//        var newShadow = options.icon.createShadow(this._shadow),
//                addShadow = false;
        var newShadow = null;
        addShadow = false;

        if (newShadow !== this._shadow) {
            this._removeShadow();
            addShadow = true;
        }

        if (newShadow) {
            L.DomUtil.addClass(newShadow, classToAdd);
        }
        this._shadow = newShadow;


        if (options.opacity < 1) {
            this._updateOpacity();
        }


        var panes = this._map._panes;

        if (addIcon) {
            panes.markerPane.appendChild(this._icon);

            this._label = this._initLabel();

            if (this.options.label !== undefined) {
                panes.markerPane.appendChild(this._label);
            }

        }

        if (newShadow && addShadow) {
            panes.shadowPane.appendChild(this._shadow);
        }

        this._icon.style[L.RotatedMarker.TRANSFORM_ORIGIN] = '50% 50%';
    },
    _initLabel: function() {
        var label = document.createElement('div');

        var classToAdd = (this._map.options.zoomAnimation && this._map.options.markerZoomAnimation) ? 'leaflet-zoom-animated' : 'leaflet-zoom-hide';

        if (this.options.label) {
            label.innerHTML = this.options.label;
            label.className = 'leaflet-marker-label ' + classToAdd;
        }

        if (this.options.labelPosition) {
            label.style.marginLeft = this.options.labelPosition;
        }

        if (this.options.labelWidth) {
            label.style.width = this.options.labelWidth;
        }

        if (this.options.labelColor) {
            label.style.color = this.options.labelColor;
        }

        if (this.options.labelFill) {
            label.style.backgroundColor = this.options.labelFill;
        }

        if (this.options.labelShadow) {
            label.style.boxShadow = this.options.labelShadow;
        }

        return label;
    },
    _removeLabel: function() {
        if (this.options.label !== undefined && this._label) {
            this._map._panes.markerPane.removeChild(this._label);
        }
        this._label = null;
    },
    _updateZIndex: function(offset) {
        this._icon.style.zIndex = this._zIndex + offset;

        if (this.options.label !== undefined && this._label) {
            this._label.style.zIndex = this._zIndex + offset;
        }
    },
    _setPos: function(pos) {
        L.DomUtil.setPosition(this._icon, pos);

        if (this.options.label !== undefined && this._label) {
            L.DomUtil.setPosition(this._label, pos);
        }
        if (this._shadow) {
            L.DomUtil.setPosition(this._shadow, pos);
        }

        if (L.DomUtil.TRANSFORM) {
            // use the CSS transform rule if available
            this._icon.style[L.DomUtil.TRANSFORM] += ' rotate(' + this.options.angle + 'deg)';
        }
        else if (L.Browser.ie) {
            // fallback for IE6, IE7, IE8
            var rad = this.options.angle * (Math.PI / 180),
                    costheta = Math.cos(rad),
                    sintheta = Math.sin(rad);
            this._icon.style.filter += ' progid:DXImageTransform.Microsoft.Matrix(sizingMethod=\'auto expand\', M11=' +
                    costheta + ', M12=' + (-sintheta) + ', M21=' + sintheta + ', M22=' + costheta + ')';
        }

        this._zIndex = pos.y + this.options.zIndexOffset;

        this._resetZIndex();
    }
});

/*
 * L.LayerGroup include function...
 */
L.LayerGroup.include({
    zoomToFit: function() {
        var minLat, minLng, maxLat, maxLng;

        for (var i in this._layers) {
            var latlng = this._layers[i].getLatLng();

            if (minLat === undefined && maxLng === undefined && maxLat === undefined && minLng === undefined) {
                minLat = latlng.lat;
                maxLat = latlng.lat;
                minLng = latlng.lng;
                maxLng = latlng.lng;
            }
            else {
                minLat = Math.min(minLat, latlng.lat);
                maxLat = Math.max(maxLat, latlng.lat);
                minLng = Math.min(minLng, latlng.lng);
                maxLng = Math.max(maxLng, latlng.lng);
            }
        }

        if (minLat !== undefined && maxLng !== undefined && maxLat !== undefined && minLng !== undefined) {
            this._map.fitBounds([[minLat, minLng], [maxLat, maxLng]]);
        }
    }
});

/*
 * L.HistoryLine
 */
L.HistoryLine = L.Polyline.extend({
    addPoint: function(latlng) {
        this._latlngs.push(L.latLng(latlng));
    },
    clearPoints: function() {
        this._latlngs.length = 0;
        this.redraw();
    },
    setPartial: function(start, end) {
        this.start = start;
        this.end = end;

        this.redraw();
    },
    setPartialMode: function(state) {
        this.partial = state;

        this.redraw();
    },
    _clipPoints: function() {
        if (this.start === undefined) {
            this.start = 0;
        }

        if (this.end === undefined) {
            this.end = this._originalPoints.length - 1;
        }

        // this is the crucial part where we slice the array of points to draw...
        var points = (this.partial) ? this._originalPoints.slice(this.start, this.end + 1) : this._originalPoints;

        var len = points.length, i, k, segment;

        if (this.options.noClip) {
            this._parts = [points];
            return;
        }

        this._parts = [];

        var parts = this._parts,
                vp = this._map._pathViewport,
                lu = L.LineUtil;

        for (i = 0, k = 0; i < len - 1; i++) {
            segment = lu.clipSegment(points[i], points[i + 1], vp, i);
            if (!segment) {
                continue;
            }

            parts[k] = parts[k] || [];
            parts[k].push(segment[0]);

            // if segment goes out of screen, or it's the last one, it's the end of the line part
            if ((segment[1] !== points[i + 1]) || (i === len - 2)) {
                parts[k].push(segment[1]);
                k++;
            }
        }
    },
    _updatePath: function() {
        if (!this._map) {
            return;
        }

        this._clipPoints();

        //this._simplifyPoints();

        L.Path.prototype._updatePath.call(this);
    }
});

/*
 * L.HistoryPoints
 */
L.HistoryPoints = L.LayerGroup.extend({
    initialize: function(options) {
        L.LayerGroup.prototype.initialize.call(this);

        this.hPolyline = new L.HistoryLine([], options);

        this.addLayer(this.hPolyline);
    },
    addPoint: function(lat, lng, heading, icon, title, label, redraw) {
        var marker = new L.Asset([lat, lng], {angle: heading, riseOnHover: true, icon: icon, title: title, label: label, labelColor: '#fff', labelFill: '#000', labelWidth: 'auto', labelPosition: '0', labelShadow: 'none'});

        this.addLayer(marker);

        //this.hPolyline.addPoint([lat, lng]);
    },
    redraw: function() {
        this.hPolyline.redraw();
    },
    clear: function() {
        this.clearLayers();

        this.hPolyline.clearPoints();

        this.addLayer(this.hPolyline);
    },
    enablePartial: function() {
        this.hPolyline.setPartialMode(true);
    },
    disablePartial: function() {
        this.hPolyline.setPartialMode(false);
    },
    setPartial: function(start, end) {
        this.hPolyline.setPartial(start, end);
    }
});

var AddressSearchBox = function(div, speed, callback, includeSG) {

    var _this = {
        callback: callback,
        timer: null,
        searchText: null,
        list: null,
        enable: function() {

            var parent = $('#' + div);

            parent.addClass('search-box');

            var input = parent.children('input')[0];

            input = $(input);

            input.keyup(_this.inputCallback);

            _this.list = $('<ul/>', {class: 'search-result-box'});

            _this.list.insertAfter(input);
        },
        clear: function() {

            _this.list.empty();
        },
        inputCallback: function() {

            if (_this.timer !== null) {
                clearTimeout(_this.timer);

                _this.timer = null;
            }

            _this.searchText = this.value;

            if (_this.searchText.length > 3) {
                _this.timer = setTimeout(_this.timerCallback, speed);
            }
        },
        timerCallback: function() {

            _this.list.empty();

            if (includeSG) {
                $.ajax({
                    type: 'GET',
                    url: 'LocationServiceController?type=system&action=geocode',
                    data: {
                        address: _this.searchText
                    },
                    success: function(data) {

                        if (data.result) {
                            for (i = 0; i < data.locations.length; i++) {

                                var location = data.locations[i];

                                var item = $('<li/>');

                                // must use mousedown instead of click otherwise the list will lost focus...
                                var address = $('<a/>', {'data-longitude': location.longitude, 'data-latitude': location.latitude}).on('mousedown', function() {

                                    var elem = $(this);

                                    var parent = elem.parents('div');

                                    var input = parent.children('input')[0];

                                    input.value = elem.html();

                                    _this.callback(elem.html(), elem.attr('data-longitude'), elem.attr('data-latitude'));
                                });

                                address.html(location.formatted_address);

                                item.append(address);

                                _this.list.prepend(item);
                            }
                        }
                    },
                    complete: function() {

                    },
                    error: function() {

                    },
                    async: true
                });
            }

            $.ajax({
                type: 'GET',
                url: 'https://maps.googleapis.com/maps/api/geocode/json',
                data: {
                    address: _this.searchText
                },
                success: function(data) {

                    for (i = 0; i < data.results.length; i++) {

                        var result = data.results[i];

                        var item = $('<li/>');

                        // must use mousedown instead of click otherwise the list will lost focus...
                        var address = $('<a/>', {'data-longitude': result.geometry.location.lng, 'data-latitude': result.geometry.location.lat}).on('mousedown', function() {

                            var elem = $(this);

                            var parent = elem.parents('div');

                            var input = parent.children('input')[0];

                            input.value = elem.html();

                            _this.callback(elem.html(), elem.attr('data-longitude'), elem.attr('data-latitude'));
                        });

                        address.html(result.formatted_address);

                        item.append(address);

                        _this.list.append(item);
                    }

                },
                complete: function() {

                },
                error: function() {

                },
                async: true
            });

        }
    };

    return _this;
};

var AddressSearchBoxSingapore = function(div, speed, callback) {

    var _this = {
        timerCallback: function() {

            $.ajax({
                type: 'GET',
                url: 'LocationServiceController?type=system&action=geocode',
                data: {
                    address: _this.searchText
                },
                success: function(data) {

                    if (data.result) {
                        _this.list.empty();

                        for (i = 0; i < data.locations.length; i++) {

                            var location = data.locations[i];

                            var item = $('<li/>');

                            // must use mousedown instead of click otherwise the list will lost focus...
                            var address = $('<a/>', {'data-longitude': location.longitude, 'data-latitude': location.latitude}).on('mousedown', function() {

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
                complete: function() {

                },
                error: function(data) {

                },
                async: true
            });
        }
    };

    _this = $.extend(new AddressSearchBox(div, speed, callback), _this);

    return _this;
};
