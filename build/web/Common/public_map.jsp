<%--
    Document   : public_map
    Created on : Jul 20, 2016, 8:28:03 AM
    Author     : kevin
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String id = request.getParameter("id");

    if (id == null)
    {
        id = "";
    }
%>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <title></title>
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/metro-responsive.css" rel="stylesheet">
        <link href="css/metro-schemes.css" rel="stylesheet">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/v3nity-map.css?v=${code}" rel="stylesheet">
        <link href="css/v3nity.css?v=${code}" rel="stylesheet">
        <script type="text/javascript" src="js/jquery-2.1.4.min.js"></script>
        <script type="text/javascript" src="js/metro.js"></script>
        <script type="text/javascript" src="js/v3nity-map.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-track.js?v=${code}"></script>
        <script>

            var map, _live, assetLayer, locationLayer, mapPadding, locationSearch;
            var markers = [], locations = [];
            var defaultZoom = 19;
            var firstZoom = false;

            function initMap()
            {
                map = new v3nityMap('map-view');

                map.defaultOptions({bounds: [0, -180, 0, 180]});

                locationSearch = new AddressSearchBox('locationSearch', 1500, locationCallback, false);

                locationSearch.enable();

                assetLayer = map.createOverlay();

                locationLayer = map.createOverlay();

                markerLocation = map.createIcon({
                    iconurl: 'img/marker-location-pin.png',
                    iconsize: [48, 48],
                    iconanchor: [24, 48]
                });

                var iconOptions = {size: [24, 24], anchor: [12, 12]};

                /*
                 * map markers using div + css...
                 */
                markerMoving = map.createMarkerIcon({
                    className: 'map-icon-marker moving',
                    iconSize: iconOptions.size,
                    iconAnchor: iconOptions.anchor
                });

                markerStop = map.createMarkerIcon({
                    className: 'map-icon-marker stop',
                    iconSize: iconOptions.size,
                    iconAnchor: iconOptions.anchor
                });

                markerIdling = map.createMarkerIcon({
                    className: 'map-icon-marker idling',
                    iconSize: iconOptions.size,
                    iconAnchor: iconOptions.anchor
                });

                markerStanding = map.createMarkerIcon({
                    className: 'map-icon-marker standing',
                    iconSize: iconOptions.size,
                    iconAnchor: iconOptions.anchor
                });

                markerIgnitionOff = map.createMarkerIcon({
                    className: 'map-icon-marker ignitionoff',
                    iconSize: iconOptions.size,
                    iconAnchor: iconOptions.anchor
                });
            }

            function locationCallback(address, lon, lat)
            {
                map.clearOverlay(locationLayer);

                var newMarker = map.createMarker({
                    latlng: [lat, lon],
                    icon: markerLocation,
                    popup: address,
                    popupoffset: [0, -54]
                });

                map.addMarker(newMarker, locationLayer);

                // we do this explicitly for better performance than calling zoomToFit...
                map.zoomTo(lat, lon, 18);
            }

            $(document).ready(function()
            {

                _live = new v3nityLive('PublicController?type=track&action=last&key=${id}', refreshCallback, errorCallback, refreshElapsed);

                _live.startRefresh(60000);

                _live.refresh([0]);

                // initially close it...
                toggleLiveMenu();

                // initially close it...
                toggleSearchMenu();

                initMap();

            });

            function dispose()
            {

                $('#search-tree-asset').off();

                $('#search-tree-address').off();

                _live.stopRefresh();

                map.remove();
            }

            function refreshCallback(json)
            {
                var fleet = $('#fleet').html('');

                if (json.result === false)
                {
                    $('#result-text').html(json.text);
                }

                for (var i = 0; i < json.data.length; i++)
                {

                    var data = json.data[i];

                    var asset = $('<li/>', {class: 'fleet-asset'});

                    var button = $('<button/>', {onclick: 'zoomToMarker(' + data.id + ')'});

                    button.append(data.label);

                    asset.append(button);

                    fleet.append(asset);

                    var marker = markers[data.id];
                    var markerIcon;
                    var markerHTML;

                    switch (data.event)
                    {
                        case 'ignition off':
                            markerIcon = markerIgnitionOff;
                            markerHTML = '<div class="map-icon-marker small nohover ignitionoff"></div>';
                            break;

                        case 'standing time limit':
                            markerIcon = markerStanding;
                            markerHTML = '<div class="map-icon-marker small nohover standing"></div>';
                            break;

                        case 'idling  time limit':
                            markerIcon = markerIdling;
                            markerHTML = '<div class="map-icon-marker small nohover idling"></div>';
                            break;

                        default:
                            if (data.speed === 0)
                            {
                                markerIcon = markerStop;
                                markerHTML = '<div class="map-icon-marker small nohover stop"></div>';
                            }
                            else
                            {
                                markerIcon = markerMoving;
                                markerHTML = '<div class="map-icon-marker small nohover moving"></div>';
                            }
                    }

                    var popupHTML = '<div class="uppercase">' +
                        '<h4>' + data.label + '</h4>' +
                        '<div class="text-light">Last Reported: ' + data.timestamp + '</div>' +
                        '<div>GPS Status: ' + data.validity + '</div>' +
                        '<div>Event Status: ' + data.event + '</div>' +
                        '<div>Speed: ' + data.speed + ' km/h&emsp;' + '</div>' +
                        '<div>Heading: ' + data.heading + '</div>' +
                        '</div>';

                    if (typeof marker === 'undefined')
                    {
                        var newMarker = map.createMarker({
                            latlng: [data.latitude, data.longitude],
                            label: data.label,
                            icon: markerIcon,
                            popup: popupHTML,
                            angle: data.headingValue
                        });

                        markers[data.id] = newMarker;

                        map.addMarker(newMarker, assetLayer);
                    }
                    else
                    {
                        marker.setLatLng([data.latitude, data.longitude]);

                        marker.setAngle(data.headingValue);

                        marker.setIcon(markerIcon);

                        marker.getPopup().setContent(popupHTML);    // not sure whether to call popup.update()...

                        marker.update();
                    }
                }

                if (!firstZoom)
                {
                    assetLayer.zoomToFit();

                    firstZoom = true;
                }
            }

            function errorCallback()
            {

            }

            function refreshElapsed()
            {

                return [0];
            }

            function zoomToMarker(id)
            {
                var marker = markers[id];

                var pos = marker.getLatLng();

                map.zoomTo(pos.lat, pos.lng, defaultZoom);
            }

            function zoomToLocation(lat, lng, id)
            {
                map.zoomTo(lat, lng, defaultZoom);

                locations[id].openPopup();
            }

            function searchAddressCallback(data)
            {
                var minLat, minLng, maxLat, maxLng;

                var resultTable = document.getElementById('results-address');

                var html = '<ul class="address-block">';

                map.clearOverlay(locationLayer);

                locations.length = 0;

                for (i = 0; i < data.result.length; i++)
                {

                    var result = data.result[i];

                    var label = result.label.split(',');

                    html += '<li><a onclick="zoomToLocation(' + result.latitude + ', ' + result.longitude + ', ' + i + ');"><blockquote>';

                    for (j = 0; j < label.length; j++)
                    {
                        html += '<p>' + label[j] + '<p>';
                    }

                    html += '</blockquote></a></li>';

                    var newMarker = map.createMarker({
                        latlng: [result.latitude, result.longitude],
                        icon: markerLocation,
                        popup: result.label,
                        popupoffset: [0, -54]
                    });

                    map.addMarker(newMarker, locationLayer);

                    locations.push(newMarker);

                    // we do this explicitly for better performance than calling zoomToFit...
                    if (minLat === undefined && maxLng === undefined && maxLat === undefined && minLng === undefined)
                    {
                        minLat = result.latitude;
                        maxLat = result.latitude;
                        minLng = result.longitude;
                        maxLng = result.longitude;
                    }
                    else
                    {
                        minLat = Math.min(minLat, result.latitude);
                        maxLat = Math.max(maxLat, result.latitude);
                        minLng = Math.min(minLng, result.longitude);
                        maxLng = Math.max(maxLng, result.longitude);
                    }
                }

                // we do this explicitly for better performance than calling zoomToFit...
                map.zoomBound(minLat, minLng, maxLat, maxLng);

                html += '</ul>';

                resultTable.innerHTML = html;
            }

            function searchAddress(elementId)
            {
                var searchText = document.getElementById(elementId).value;

                map.searchAddress(searchText, searchAddressCallback);
            }

            function toggleLiveMenu()
            {
                var charm = $("#charmLive");
                if (charm.data('hidden') === undefined)
                {
                    charm.data('hidden', true);
                    charm.css('left', -320);
                    return;
                }
                if (!charm.data('hidden'))
                {
                    charm.animate({
                        left: -320
                    }, 100);
                    charm.data('hidden', true);

                    mapPadding = [0, 0];
                }
                else
                {
                    charm.animate({
                        left: 0
                    }, 100);
                    charm.data('hidden', false);

                    mapPadding = [320, 0];
                }
            }

            function toggleSearchMenu()
            {
                var charm = $("#charmSearch");
                if (charm.data('hidden') === undefined)
                {
                    charm.data('hidden', true);
                    charm.css('left', -320);
                    return;
                }
                if (!charm.data('hidden'))
                {
                    charm.animate({
                        left: -320
                    }, 100);
                    charm.data('hidden', true);

                    mapPadding = [0, 0];
                }
                else
                {
                    charm.animate({
                        left: 0
                    }, 100);
                    charm.data('hidden', false);

                    mapPadding = [320, 0];
                }
            }

        </script>
        <style type="text/css">

            .header {
                display: none !important;
            }

            .body {
                padding: 0;
                margin: 0;
            }

            .footer {
                background-color: rgba(255, 255, 255, 0.4);
                color: #437DC6;
                display: block;
                height: auto;
                width: 100%;
                padding: 4px;
                font-size: small;
                position: fixed;
                bottom: 0;
                text-align: center;
            }

            ul.fleet {
                margin: 0;
                padding: 0;
                width: 100%;
            }

            li.fleet-asset {
                display: block;
                padding: 4px;
                width: 100%;
            }

            li.fleet-asset button {
                background-color: #fff;
                color: #151515;
                border: none;
                font-size: 14px;
                font-weight: 100;
                outline: none;
                padding: 8px;
                text-align: left;
                width: 100%;
            }

            li.fleet-asset button:hover {
                color: #437DC6;
            }

            .error-text {
                color: #D90000;
                font-weight: bold;
            }

        </style>
    </head>
    <body>
        <section>
            <div class="charm left-side padding10 v3-bg-blue" id="charmLive" style="width: 320px; height: auto">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleLiveMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light">Fleet</h1>
                <div class="content padding10 bg-white" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto;">
                    <div id="result-text" class="error-text"></div>
                    <ul id="fleet" class="fleet">

                    </ul>
                </div>
            </div>
            <div class="charm left-side padding10 v3-bg-blue fg-white" id="charmSearch" style="width: 320px">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleSearchMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light">Search</h1>
                <div class="content padding10 bg-white" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto;">
                    <div id="locationSearch" class="input-control text full-size" data-role="input">
                        <input id="locationText" type="text" size="50" placeholder="Search">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div id="matches-address"></div>
                    <div id="results-address" class="content" style="color: #fff; position: absolute; top: 0; bottom: 0; margin: 168px 0 8px 0; width: 300px; overflow-y: auto"></div>
                </div>
            </div>
        </section>
        <section class="full-screen">
            <div id="map-view" class="full-screen"></div>
            <ul class="t-menu compact" style="position: fixed; top: 48px; left: 8px;">
                <li><a href="http://www.v3nity.com/v3nity4/index.jsp" title="Home"><span class="icon mif-home"></span></a></li>
                <li><a href="#" onclick="toggleLiveMenu()" title="Last Location"><span class="icon mif-satellite"></span></a></li>
                <!--<li><a href="#" onclick="toggleSearchMenu()" title="Search"><span class="icon mif-search"></span></a></li>-->
                <li><a href="#" title="Change Map" class="dropdown-toggle"><span class="icon mif-map"></span></a>
                    <ul class="t-menu horizontal compact" data-role="dropdown">
                        <li><a href="#" onclick="map.changeBaseLayer([1, 0])"><h6>Normal</h6></a></li>
                        <li><a href="#" onclick="map.changeBaseLayer([2])"><h6>Terrain</h6></a></li>
                        <li><a href="#" onclick="map.changeBaseLayer([3])"><h6>Satellite</h6></a></li>
                        <li><a href="#" onclick="map.changeBaseLayer([4])"><h6>Hybrid</h6></a></li>
                        <li><a href="#" onclick="map.changeBaseLayer([5])"><h6>Road</h6></a></li>
                    </ul>
                </li>
            </ul>
            <ul class="t-menu compact" style="position: fixed; top: 48px; right: 8px;">
                <li><a href="#" onclick="map.zoomIn()" title="Zoom In"><span class="icon mif-plus"></span></a></li>
                <li><a href="#" onclick="map.zoomOut()" title="Zoom Out"><span class="icon mif-minus"></span></a></li>
                <li><a href="#" onclick="assetLayer.zoomToFit()" title="Zoom Default"><span class="icon mif-target"></span></a></li>
            </ul>
            <div class="legend-dialog" style="position: fixed; top: 172px; right: 8px;">
                <h5 class="text-light">Legend</h5>
                <div><div class="map-icon-marker small nohover moving"></div><span class="text-small"> Moving</span></div>
                <div><div class="map-icon-marker small nohover stop"></div><span class="text-small"> Stop</span></div>
                <div><div class="map-icon-marker small nohover ignitionoff"></div><span class="text-small"> Ignition Off</span></div>
                <div><div class="map-icon-marker small nohover standing"></div><span class="text-small"> Standing</span></div>
                <div><div class="map-icon-marker small nohover idling"></div><span class="text-small"> Idling</span></div>
            </div>
        </section>
        <div id="footer" class="footer">
            <span>&copy; V3 Smart Technologies Pte. Ltd.</span>
            <span>Map Data SLA, GOOGLE</span>
        </div>
    </body>
</html>

