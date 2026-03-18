/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

var H2G_map = function(id)
{
    var _map = L.map(id, {maxBounds: L.latLngBounds(L.latLng(1.478402764994278, 104.02552444933936), L.latLng(1.2024470782903032, 103.57851826005933))}).setView([1.359431, 103.813248], 11);

    var layers = {
        polyline_list: [],
        a_marker: null,
        b_marker: null,
        poi_list: []
    };

    var a_icon = L.icon({
        iconUrl: 'mapprint/img/A.png',
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -24]
    });

    var b_icon = L.icon({
        iconUrl: 'mapprint/img/B.png',
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -24]
    });

    var bus_icon = L.icon({
        iconUrl: 'images/bus.jpg',
        iconSize: [25, 25],
        iconAnchor: [12, 12]
    });

    var mrt_icon = L.icon({
        iconUrl: 'images/mrt_text.jpg',
        iconSize: [25, 40],
        iconAnchor: [12, 12]
    });

    var lrt_icon = L.icon({
        iconUrl: 'images/lrt_text.jpg',
        iconSize: [25, 40],
        iconAnchor: [12, 12]
    });

    var timeout_refresh = null;

    var _this = {
        draw_line: function(coords, color, clear_old)
        {
            /* coords parameter sample:
             * 103.88370767387,1.334616907337@103.88496,1.332686667
             */
            if (coords !== '-' && coords !== '')    // don't know why we have this...
            {
                var list = coords.split('@');

                var latlngs = [];

                for (var i = 0; i < list.length; i++)
                {
                    if (list[i] !== '')
                    {
                        var coord = list[i].split(',');

                        var latlng = L.latLng(coord[1], coord[0]);

                        latlngs.push(latlng);
                    }
                }

                var polyline = L.polyline(latlngs, {color: '#' + color.substring(2, 8), weight: 6, opacity: 1.0}).addTo(_map);

                layers.polyline_list.push(polyline);
            }
        },
        remove_line: function()
        {
            for (var i = 0; i < layers.polyline_list.length; i++)
            {
                _map.removeLayer(layers.polyline_list[i]);
            }

            layers.polyline_list.length = [];
        },
        add_marker: function(a_coord, b_coord, a_text, b_text)
        {
            if (a_coord !== null)
            {
                a_coord = a_coord.split(',');

                var a_latlng = L.latLng(a_coord[0], a_coord[1]);

                layers.a_marker = L.marker(a_latlng, {icon: a_icon}).addTo(_map);

                layers.a_marker.bindPopup(a_text);
            }

            if (b_coord !== null)
            {
                b_coord = b_coord.split(',');

                var b_latlng = L.latLng(b_coord[0], b_coord[1]);

                layers.b_marker = L.marker(b_latlng, {icon: b_icon}).addTo(_map);

                layers.b_marker.bindPopup(b_text);
            }
        },
        remove_marker: function()
        {
            if (layers.a_marker !== null)
            {
                _map.removeLayer(layers.a_marker);
            }

            if (layers.b_marker !== null)
            {
                _map.removeLayer(layers.b_marker);
            }
        },
        zoom_map_to: function(lon, lat, zoom)
        {
            var latlng = L.latLng(lat, lon);

            _map.setView(latlng, zoom);
        },
        add_poi_marker: function(data)
        {
            var latlng = L.latLng(data.latitude, data.longitude);

            if (data.type === 'BUS')
            {
                var marker = L.marker(latlng, {icon: bus_icon, riseOnHover: true}).addTo(_map);

                var services = data.services.split(',');

                for (var i = 0; i < services.length; i++)
                {
                    var service = services[i];

                    if (service.length > 0)
                    {
                        services[i] = '<a href="https://map.v3nity.com/NPTJP/busservice.php?service=' + service + '&stat=1" target="_blank">' + service + '</a>';
                    }
                }

                services = services.join(' ');

                marker.bindPopup('<div class="poi-field-value"><span>Bus Stop Code:</span><span>' + data.code + '</span></div><div class="poi-field-value"><span>Bus Stop Name:</span><span>' + data.name + '</span></div></div><div class="poi-field-value"><span>Service:</span><span>' + services + '</span></div>');

                layers.poi_list.push(marker);
            }
            else if (data.type === 'MRT')
            {
                var marker = L.marker(latlng, {icon: mrt_icon, riseOnHover: true}).addTo(_map);

                marker.bindPopup('<div class="poi-field-value"><span>' + data.name + '</span><span>(' + data.code + ')</span></div><div class="poi-field-value"><span>Address:</span><span>' + data.address + '</span></div>');

                layers.poi_list.push(marker);
            }
            else if (data.type === 'LRT')
            {
                var marker = L.marker(latlng, {icon: lrt_icon, riseOnHover: true}).addTo(_map);

                marker.bindPopup('<div class="poi-field-value"><span>' + data.name + '</span><span>(' + data.code + ')</span></div><div class="poi-field-value"><span>Address:</span><span>' + data.address + '</span></div>');

                layers.poi_list.push(marker);
            }
        },
        clear_poi: function()
        {
            for (var i = 0; i < layers.poi_list.length; i++)
            {
                _map.removeLayer(layers.poi_list[i]);
            }

            layers.poi_list.length = [];
        },
        refresh_busstop: function(northeast, southwest)
        {
            $.ajax({
                type: 'GET',
                dataType: 'xml',
                url: 'https://map.v3nity.com/PTWebService/getstop_v2.php',
                data: {
                    topX: northeast.lng, // north east longitude
                    topY: northeast.lat, // north east latitude
                    bottomX: southwest.lng, // south west longitude
                    bottomY: southwest.lat      // south west latitude
                },
                success: function(xml)
                {
                    _this.clear_poi();

                    $(xml).find('Results').each(function()
                    {
                        var data = {
                            type: $(this).find('Type').text(),
                            code: $(this).find('Code').text(),
                            name: $(this).find('Name').text(),
                            longitude: $(this).find('Longitude').text(),
                            latitude: $(this).find('Latitude').text(),
                            services: $(this).find('Services').text(),
                            address: $(this).find('Address').text()
                        };

                        _this.add_poi_marker(data);

                    });
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

    _map.on('moveend', function(e)
    {
        if (_map.getZoom() > 15)
        {
            if (timeout_refresh !== null)
            {
                clearTimeout(timeout_refresh);
            }

            timeout_refresh = setTimeout(function()
            {
                _this.refresh_busstop(_map.getBounds().getNorthEast(), _map.getBounds().getSouthWest());
            }, 1500);
        }
        else
        {
            _this.clear_poi();
        }

        document.getElementById("map-context-menu").style.display = 'none';
    });

    _map.on('contextmenu', function(e)
    {
        var menu = document.getElementById("map-context-menu");

        menu.style.display = 'block';

        menu.style.left = e.containerPoint.x + "px";

        menu.style.top = e.containerPoint.y + "px";

        menu.setAttribute('data-longitude', e.latlng.lng);

        menu.setAttribute('data-latitude', e.latlng.lat);

        var outside_menu_click_event = document.addEventListener('click', function(event)
        {
            var isClickInsideElement = menu.contains(event.target);

            if (!isClickInsideElement)
            {
                menu.style.display = 'none';

                document.removeEventListener('click', outside_menu_click_event);
            }
        });
    });

    L.tileLayer('https://map.v3nity.com/v3_sg_tms/{z}/{x}/{y}.png', {minZoom: 11, maxZoom: 20, bounds: [[1.47098, 104.02095], [1.23784, 103.617264]]}).addTo(_map);

    return _this;
};
