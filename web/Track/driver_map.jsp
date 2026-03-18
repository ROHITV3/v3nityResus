<%@page import="java.nio.file.Files"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.io.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    DataTreeView assetTreeView = new DriverTreeView(userProperties);

    DataTreeView geoFenceTreeView = new GeoFenceTreeView(userProperties);

    DataTreeView routeDeviationTreeView = new RouteDeviationTreeView(userProperties);

    List<Data> overlays = null;

    ListForm listForm = new ListForm();

    Data country = null;
    
    //
    // get data from cache...
    //
    if (!userProperties.getDataCache().isDataTreeViewCached(assetTreeView))
    {
        assetTreeView.loadData(userProperties);

        userProperties.getDataCache().cacheDataTreeView(assetTreeView);
    }
    else
    {
        assetTreeView = userProperties.getDataCache().getDataTreeViewCache(assetTreeView);
    }

    assetTreeView.setIdentifier("driver");

    //
    // get data from cache...
    //
    if (!userProperties.getDataCache().isDataTreeViewCached(geoFenceTreeView))
    {
        geoFenceTreeView.loadData(userProperties);

        userProperties.getDataCache().cacheDataTreeView(geoFenceTreeView);
    }
    else
    {
        geoFenceTreeView = userProperties.getDataCache().getDataTreeViewCache(geoFenceTreeView);
    }

    geoFenceTreeView.setIdentifier("geofence");

    //
    // get data from cache...
    //
    if (!userProperties.getDataCache().isDataTreeViewCached(routeDeviationTreeView))
    {
        routeDeviationTreeView.loadData(userProperties);

        userProperties.getDataCache().cacheDataTreeView(routeDeviationTreeView);
    }
    else
    {
        routeDeviationTreeView = userProperties.getDataCache().getDataTreeViewCache(routeDeviationTreeView);
    }

    routeDeviationTreeView.setIdentifier("route");

    String countryCode = userProperties.getString("country").toUpperCase();

    Connection connection = userProperties.getConnection();

    CountryDataHandler countryDataHandler = new CountryDataHandler();

    countryDataHandler.setConnection(connection);

    country = countryDataHandler.get(countryCode);

    /*
     * gets overlay map layers...
     */
    OverlayMapDataHandler overlayMapDataHandler = new OverlayMapDataHandler();

    overlayMapDataHandler.setConnection(connection);

    overlays = overlayMapDataHandler.get(userProperties.getInt("customer_id"));

    userProperties.closeConnection(connection);

    /*
     * other stuffs...
     *
     */
    Locale locale = userProperties.getLocale();

    String domainURL = userProperties.getSystemProperties().getDomainURL();

    java.util.Date today = new java.util.Date();

    String inputStartDate = new SimpleDateFormat("dd/MM/yyyy HH:").format(today) + "00:00";

    String inputEndDate = new SimpleDateFormat("dd/MM/yyyy").format(today) + " 23:59:59";

    String menu = request.getParameter("menu");

    /*
     * gets map refresh rate...
     */
    String mapRefresh = userProperties.getCustomerAttribute("MapRefresh");

    if (mapRefresh == null)
    {
        mapRefresh = "10000";
    }

    String trafficScrollerBar = userProperties.getCustomerAttribute("TrafficScrollerBar");

    if (trafficScrollerBar == null)
    {
        trafficScrollerBar = "1"; // 0 = false, 1 = true;
    }

    /*
     * gets default auto zoom...
     */
    String defaultAutoZoom = userProperties.getCustomerAttribute("DefaultAutoZoom");

    if (defaultAutoZoom == null)
    {
        defaultAutoZoom = "1";
    }

    /*
     * gets map clustering maximum zoom level...
     */
    String clusterMaxZoomOption = userProperties.getCustomerAttribute("ClusterMaxZoom");

    if (clusterMaxZoomOption == null)
    {
        clusterMaxZoomOption = "15";
    }

    /*
     * gets map legend display...
     */
    String legendOption = userProperties.getCustomerAttribute("ShowMapLegend");

    if (legendOption == null)
    {
        legendOption = "111111";
    }
    
   
    String legend = userProperties.getCustomerAttribute("CustomizeLegend");
    
    boolean hasCustomizedLegend = false;
    
    if (legend != null)
    {               
        hasCustomizedLegend = (legend.equals("1") || legend.equals("yes"));
    }
    

    /*
     * gets map layer display...
     */
    String layerOption = userProperties.getCustomerAttribute("ShowMapLayer");

    if (layerOption == null)
    {
        layerOption = "1111";
    }

    int defaultLayer = 1;

    for (char option : layerOption.toCharArray())
    {
        if (option == '1')
        {
            break;
        }

        defaultLayer++;
    }

    /*
     * gets geofence access rights...
     */
    int operations = userProperties.getOperations((new GeoFence()).getResourceId());

    boolean canViewGeofence = userProperties.canAccess(operations, Operation.VIEW);

    boolean canAddGeofence = userProperties.canAccess(operations, Operation.ADD);

    boolean canUpdateGeofence = userProperties.canAccess(operations, Operation.UPDATE);

    boolean canDeleteGeofence = userProperties.canAccess(operations, Operation.DELETE);

    /*
     * gets route access rights...
     */
    operations = userProperties.getOperations((new Route()).getResourceId());

    boolean canViewRoute = userProperties.canAccess(operations, Operation.VIEW);

    boolean canAddRoute = userProperties.canAccess(operations, Operation.ADD);

    boolean canUpdateRoute = userProperties.canAccess(operations, Operation.UPDATE);

    boolean canDeleteRoute = userProperties.canAccess(operations, Operation.DELETE);
    
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>${title}</title>
        <script type="text/javascript" src="js/v3nity-alert.js"></script>
        <script type="text/javascript" src="js/v3nity-technician-track.js"></script>
        <script type="text/javascript" src="js/jquery.marquee.min.js"></script>
        <script>

            var map, _live, _history, assetLayer, locationLayer, historyLayer, geoFenceLayer, autoRefresh, autoZoom, historyAssetId, historyAssetLabel, mapPadding, webAlert, webTraffic, trafficNews, locationSearch, enableTraffic, enableHistoryLabel;
            var markers = [], locations = [], geoFences = [], polylines = [], checkedAsset = [];
            var checkedAsset1 = [], checkedAsset2 = [], checkedAsset3 = [], checkedAsset0 = [];
            var defaultZoom = 18;
            var edit = false;
            var countGeofenceLoading = false;
            var clickedGeofence = {id: 0, name: ''};
            var intervalRefresh = <%=mapRefresh%>;
            var geoFenceAreaArray = [];

            function initMap()
            {
                map = new v3nityMap('map-view', {clusterMaxZoom: <%=clusterMaxZoomOption%>});

                map.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});

                locationSearch = new AddressSearchBox('locationSearch', 1500, locationCallback, <%=(locale.getCountry().equals("SG"))%>);

                locationSearch.enable();

            <%
                if (overlays != null)
                {
                    for (int i = 0; i < overlays.size(); i++)
                    {
                        Data overlay = overlays.get(i);

            %>
                var option = {url: '<%=overlay.getString("overlay_url")%>', minZoom: <%=overlay.getInt("min_zoom_level")%>, maxZoom: <%=overlay.getInt("max_zoom_level")%>};

                map.addOverlayLayer(option);
            <%
                    }
                }
            %>

                splitMap(1, true);
            }

            function locationCallback(address, lng, lat)
            {
                map.removeAllSimpleMarker();

                map.addSimpleMarker(lat, lng, address);

                map.zoomTo(lat, lng, defaultZoom);
            }

            $(document).ready(function()
            {
                webAlert = new WebAlert();

                webAlert.start();

            <% if (trafficScrollerBar.equals("1"))
                { %>

                document.getElementById('checkboxTrafficNews').checked = true;

                trafficNews = true;

                onWebTraffic();

            <% }%>
                // preset the auto refresh option...
                autoRefresh = document.getElementById('checkboxAutoRefresh').checked;

            <% if (defaultAutoZoom.equals("0"))
                {%>
                document.getElementById('checkboxAutoZoom').checked = false;
            <% }%>


                // preset the auto zoom option...
                autoZoom = document.getElementById('checkboxAutoZoom').checked;

                enableTraffic = document.getElementById('checkboxTraffic').checked;

                enableHistoryLabel = document.getElementById('checkboxHistoryLabel').checked;

                _live = new v3nityLive('DriverMapController', refreshCallback, errorCallback, refreshElapsed);

                _history = new v3nityHistory('MapController', historyLoadedCallback, playbackElapsed);

                // initially close it...
                toggleLiveMenu();

                // initially close it...
                toggleHistoryMenu(false);

                // initially close it...
                toggleSearchMenu();

                // initially close it...
                toggleMapSettingsMenu();

                // initially close it...
                toggleJobMenu();

            <% if (menu == null || !(menu != null && menu.equals("geofence")))
                {%>
                // initially close it...
                toggleGeoFenceMenu();

                toggleRouteDeviationMenu();
            <% }%>

                $("#dateTimePicker-history-start-date").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#dateTimePicker-history-end-date").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                $("#dateTimePicker-camera-history-record-date").AnyTime_picker({format: "%Y-%m-%d_%H:%i:%s"}); // 2018-11-21_10:00:00

                $('#playback-slider').slick({
                    infinite: false,
                    swipeToSlide: true,
                    autoplaySpeed: 3000,
                    arrows: false,
                    focusOnSelect: true,
                    centerMode: true,
                    variableWidth: true});    // if false, initialize until siao!!!

                $('#playback-slider').on('afterChange', onPlayback);

                $('#search-tree-geofence').on('keypress', function(e)
                {
                    if (e.keyCode === 13)
                        searchTree('search-tree-geofence', 'tree-view-geofence');
                });

                $('#search-tree-asset').on('keypress', function(e)
                {
                    if (e.keyCode === 13)
                        searchTree('search-tree-asset', 'tree-view-asset');
                });

                $('#search-address').on('keypress', function(e)
                {
                    if (e.keyCode === 13)
                        searchAddress('search-address');
                });

                initMap();
                
                
            });

            function dispose()
            {
                webAlert.dispose();

                if (webTraffic !== null)
                {
                    webTraffic.dispose();
                }

                $("#dateTimePicker-history-start-date").AnyTime_noPicker();

                $("#dateTimePicker-history-end-date").AnyTime_noPicker();

                $("#dateTimePicker-camera-history-record-date").AnyTime_noPicker();

                $('#playback-slider').off();

                $('#search-tree-geofence').off();

                $('#search-tree-asset').off();

                $('#search-tree-address').off();

                _live.stopRefresh();

                _history.stopPlayback();

                map.remove();
            }

            function switchMode(mode)
            {
                switch (mode)
                {

                    case 0:     // live tracking...

                        // resume auto zoom option...
                        autoZoom = document.getElementById('checkboxAutoZoom').checked;

                        // resume auto refresh option...
                        autoRefresh = document.getElementById('checkboxAutoRefresh').checked;

                        map.removeAllSimpleMarker();

                        map.removeHistoryLayer();

                        map.toggleLastLocationLayer(true);

                        if (checkNumberOfMap() === 4)
                        {
                            map3.removeAllSimpleMarker();
                            map3.removeHistoryLayer();
                            map3.toggleLastLocationLayer(true);

                            map2.removeAllSimpleMarker();
                            map2.removeHistoryLayer();
                            map2.toggleLastLocationLayer(true);

                            map1.removeAllSimpleMarker();
                            map1.removeHistoryLayer();
                            map1.toggleLastLocationLayer(true);
                        }
                        else if (checkNumberOfMap() === 2)
                        {
                            map1.removeAllSimpleMarker();
                            map1.removeHistoryLayer();
                            map1.toggleLastLocationLayer(true);
                        }

                        toggleHistoryMenu(false);

                        if (autoRefresh)
                        {
                            _live.startRefresh(intervalRefresh);
                        }


                        break;

                    case 1:     // history tracking...

                        // temporary disable auto zoom...
                        autoZoom = false;

                        // temporary disable auto refresh...
                        autoRefresh = false;

                        map.removeAllSimpleMarker();

                        map.toggleLastLocationLayer(false);

                        toggleHistoryMenu(true);

                        _live.stopRefresh();

                        break;

                    case 2:     // search address...

                        // temporary disable auto zoom...
                        autoZoom = false;

                        // temporary disable auto refresh...
                        autoRefresh = false;

                        //map.removeHistoryLayer();     // some customers feedback that they require the history during address search...

                        map.removeAllSimpleMarker();

                        map.toggleLastLocationLayer(false);

                        toggleHistoryMenu(false);

                        //_live.stopRefresh();

                        break;

                    case 3:     // geo fence...

                        // temporary disable auto zoom...
                        autoZoom = false;

                        // temporary disable auto refresh...
                        autoRefresh = false;

                        map.removeHistoryLayer();

                        map.removeAllSimpleMarker();

                        map.toggleLastLocationLayer(false);

                        if (checkNumberOfMap() === 4)
                        {
                            map1.removeHistoryLayer();
                            map1.removeAllSimpleMarker();
                            map1.toggleLastLocationLayer(false);

                            map2.removeHistoryLayer();
                            map2.removeAllSimpleMarker();
                            map2.toggleLastLocationLayer(false);

                            map3.removeHistoryLayer();
                            map3.removeAllSimpleMarker();
                            map3.toggleLastLocationLayer(false);
                        }
                        else if (checkNumberOfMap() === 2)
                        {
                            map1.removeHistoryLayer();
                            map1.removeAllSimpleMarker();
                            map1.toggleLastLocationLayer(false);
                        }

                        toggleHistoryMenu(false);

                        //_live.stopRefresh();

                        break;

                    case 4:     // search job...

                        // temporary disable auto zoom...
                        autoZoom = false;

                        // temporary disable auto refresh...
                        autoRefresh = false;

                        map.removeHistoryLayer();

                        map.removeAllSimpleMarker();

                        map.toggleLastLocationLayer(false);

                        toggleHistoryMenu(false);

                        //_live.stopRefresh();

                        break;
                }
            }

            function historyPlayPrevious()
            {
                $('#playback-slider').slick('slickPrev');
            }

            function historyPlayNext()
            {
                $('#playback-slider').slick('slickNext');
            }

            function historyPlay()
            {
                $('#playback-slider').slick('slickPlay');
            }

            function historyPlayFirst()
            {
                $('#playback-slider').slick('slickGoTo', 0, false);
            }

            function historyPlayLast()
            {
                var lastIndex = _history.getLastIndex();

                $('#playback-slider').slick('slickGoTo', lastIndex, false);
            }

            function historyPause()
            {
                $('#playback-slider').slick('slickPause');
            }

            function historyStop()
            {
                historyPause();

                $('#playback-slider').slick('slickGoTo', 0, false);
            }

            function onPlayback(event, slick, currentSlide)
            {
                var record = _history.getRecord(currentSlide);

                map.zoomTo(record.latitude, record.longitude, map.getCurrentZoomLevel());

                map.selectHistoryLayer(currentSlide);
            }

            // not in use... we are using the slick for playback...
            function playbackElapsed(record, index)
            {
                map.zoomTo(record.latitude, record.longitude, map.getCurrentZoomLevel());

                $('#playback-slider').slick('slickGoTo', index, true);
            }

            function historyView(id, label)
            {
                historyAssetId = id;
                
                historyAssetLabel = label;

                document.getElementById('history-title').innerHTML = label;

                switchMode(1);

                map.removeHistoryLayer();

                historySearch();
            }

            function historySearch()
            {

                var startDate = document.getElementById('dateTimePicker-history-start-date').value;

                var endDate = document.getElementById('dateTimePicker-history-end-date').value;

                if (startDate !== '' && endDate !== '')
                {

                    var startDateParts = startDate.split(' ');
                    var startDateOnly = startDateParts[0].split('/');
                    var startTimeOnly = startDateParts[1].split(':');
                    var startDateObj = new Date(startDateOnly[2], startDateOnly[1] - 1, startDateOnly[0],
                        startTimeOnly[0], startTimeOnly[1], startTimeOnly[2]);

                    var endDateParts = endDate.split(' ');
                    var endDateOnly = endDateParts[0].split('/');
                    var endTimeOnly = endDateParts[1].split(':');
                    var endDateObj = new Date(endDateOnly[2], endDateOnly[1] - 1, endDateOnly[0],
                        endTimeOnly[0], endTimeOnly[1], endTimeOnly[2]);

                    var hoursDiff = Math.floor((endDateObj - startDateObj) / 1000 / 60 / 60);

                    if (hoursDiff >= 24)
                    {
                        dialog('Time Limit', 'Date Range is Limited to 24 hours', 'default');
                    }
                    else
                    {
                        _history.loadHistory(historyAssetId, startDate, endDate);
                    }
                }
            }

            function historyLoadedCallback(records, feature)
            {

                map.removeHistoryLayer();

                var playbackSlider = document.getElementById('playback-slider');

                playbackSlider.innerHTML = "";

                if (records.length === 0)
                {

                    var startDate = document.getElementById('dateTimePicker-history-start-date').value;

                    var endDate = document.getElementById('dateTimePicker-history-end-date').value;

                    dialog('<%=userProperties.getLanguage("noHistoryRecord")%>', startDate + ' - ' + endDate, 'default');
                }

                var geoLocation = new Array();

                for (i = 0; i < records.length; i++)
                {

                    var record = records[i];
                    var imgHTML;
                    var speed = parseInt(record.speed);
                    var lat = parseFloat(record.latitude);
                    var lon = parseFloat(record.longitude);
                    var heading = parseInt(record.headingValue);
                    var timestamp = record.timestamp;
                    var event = record.event;

                    if (feature.custom)
                    {
                        switch (event)
                        {
                            case 'ignitionOff':

                                imgHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'../img/' + feature.icons.marker_ignitionoff + '\')"></div>';

                                break;

                            case 'standingTimeLimit':

                                imgHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'../img/' + feature.icons.marker_standing + '\')"></div>';

                                break;

                            case 'idlingTimeLimit':

                                imgHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'../img/' + feature.icons.marker_idling + '\')"></div>';

                                break;

                            default:

                                if (speed === 0)
                                {

                                    imgHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'../img/' + feature.icons.marker_stop + '\')"></div>';
                                }
                                else
                                {

                                    imgHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'../img/' + feature.icons.marker_moving + '\')"></div>';
                                }
                        }
                    }
                    else
                    {
                        switch (event)
                        {
                            case 'ignitionOff':

                                imgHTML = '<div class="map-icon-marker small nohover ignitionoff"></div>';

                                break;

                            case 'standingTimeLimit':

                                imgHTML = '<div class="map-icon-marker small nohover standing"></div>';

                                break;

                            case 'idlingTimeLimit':

                                imgHTML = '<div class="map-icon-marker small nohover idling"></div>';

                                break;

                            case 'immobilise':

                                imgHTML = '<div class="map-icon-marker small nohover immobilise"></div>';

                                break;


                            default:

                                if (speed === 0)
                                {

                                    imgHTML = '<div class="map-icon-marker small nohover ignitionoff"></div>';
                                }
                                else
                                {

                                    imgHTML = '<div class="map-icon-marker small nohover moving"></div>';
                                }
                        }
                    }

                    var locationInfo = [lat, lon, heading, speed, timestamp, event, feature.custom, feature.icons, historyAssetLabel];

                    geoLocation.push(locationInfo);

                    var recordItem = document.createElement('div');

                    recordItem.className = 'slide-quote text-small uppercase';

                    recordItem.innerHTML =
                        imgHTML +
                        '<p>' + record.timestamp + '<br>' + record.gps_validity + '&emsp;' + speed + 'km/h&emsp;' + record.heading +
                        '<br>' + (i + 1) + '</p>';

                    playbackSlider.appendChild(recordItem);

                }

                if (geoLocation.length > 0)
                {

                    map.addHistoryLayer(geoLocation, enableHistoryLabel, onclickedHistoryCallback);

                    map.zoomToMarkers(geoLocation);
                }

                $('#playback-slider').css("visibility", ((records.length > 0) ? "visible" : "hidden"));

                $('#playback-slider').slick('redo');    // kevin created this to redo the slider...

                historyStop();
            }

            function onclickedHistoryCallback(id)
            {
                $('#playback-slider').slick('slickGoTo', id, false);
            }

            function playbackSpeedChanged(value, slider)
            {

                // have to pause the playback as really not sure if continuously changing the speed can cause side-effect...
                historyPause();

                // modify the speed, take note of the multiplication because if the slick cannot handle high value...
                $('#playback-slider').slick('slickSetOption', 'autoplaySpeed', (value * 100), true);
            }

            function errorCallback()
            {
                $('[id^=driver-detail]').html('<span class="fg-red">Try again</span>');
            }

            function refreshCallback(result)
            {
                setTimeout(function()
                {
                    $('#tree-view-driver').find(':checkbox').removeAttr('disabled');
                }, 2000);

                var geoLocation = new Array();

                if (checkNumberOfMap() === 4)
                {
                    var geoLocation1 = new Array();
                    var geoLocation2 = new Array();
                    var geoLocation3 = new Array();
                    var geoLocation0 = new Array();
                }
                else if (checkNumberOfMap() === 2)
                {
                    var geoLocation1 = new Array();
                    var geoLocation0 = new Array();
                }
     
     
    
                for (var i = 0; i < result.data.length; i++)
                {
                    var data = result.data[i];

                    var markerHTML;

                    var status = parseInt(data.status);

                    var eventName, event;

                    if (data.custom)
                    {
                        switch (data.event)
                        {
                            

                            default:
                                if (status === 0)
                                {

                                    markerHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'img/' + data.icons.marker_idling + '\')"></div>';

                                    eventName = 'idle';
                                }
                                else
                                {
                                    markerHTML = '<div class="map-icon-marker-custom small" style="background-image: url(\'img/' + data.icons.marker_stop + '\')"></div>';

                                    eventName = 'busy';
                                }
                        }
                    }
                    else
                    {
                        switch (data.event)
                        {

                            default:

                                if (status === 0)
                                {
                                    markerHTML = '<div class="map-icon-marker small nohover idling"></div>';

                                    event = eventName = 'idle';
                                }
                                else
                                {
                                    markerHTML = '<div class="map-icon-marker small nohover stop"></div>';

                                    event = eventName = 'busy';
                                }
                        }
                    }

                    var newLabel = data.label.replace('\'', '\\\'');

                    // check for multiple asset id in different groups...
                    $('[id^=driver-detail-' + data.id + '-]').each(function()
                    {
                        var details = $(this);

                        // apply the group colour only for the first selected asset in that group...
                        if (data.labelColor === undefined & details.attr('data-checked') === 'true')
                        {
                            data.labelColor = details.attr('data-group-color');
                        }

                        /*
                         * remember the event so that we can colour the asset label in the geofence count dialog...
                         */
                        details.attr('data-event', event);
                        
                        var voltageBreakLine = '';
                        if((data.mainPowerVoltage != 0 && data.mainPowerVoltage != 'null') || (data.fuelLevel != 0 && data.fuelLevel != 'null'))
                        {
                            voltageBreakLine = '<br>';
                        }
                        
                        details.html('<blockquote class="text-small uppercase">' +
                            markerHTML + '&emsp;' +
                            data.timestamp + '<br>' +
                            data.validity + '&emsp;' +
                            data.speed + 'km/h&emsp;' +
                            data.temperature + '&#176;C&emsp;' +
                            data.sectemperature + '&#176;C<br>' +
                            ((data.mainPowerVoltage != 0 && data.mainPowerVoltage != 'null') ? data.mainPowerVoltage + 'V&emsp;' : '') +
                            ((data.fuelLevel != 0 && data.fuelLevel != 'null') ? data.fuelLevel + '% Full&emsp;' : '') + voltageBreakLine +
                            ((data.rfid) ? data.rfid + '<br>' : '') +
                            ((data.road) ? data.road + '<br>' : '') +
                            data.rfid + '<br>' +
                            data.road + '<br>' +
                            '<button class="button mini-button" onclick="zoomToMarker(' + data.id + ')" title="<%=userProperties.getLanguage("zoomToLocation")%>"><span class="mif-zoom-in"></span></button>&emsp;' +
                            '<button class="button mini-button" onclick="historyView(' + data.id + ', \'' + newLabel + '\')" title="<%=userProperties.getLanguage("trackHistory")%>"><span class="mif-history"></span></button>&emsp;' +
                            ((data.immobiliser === true) ? '<button class="button mini-button" onclick="immobilise(' + data.id + ')" title="<%=userProperties.getLanguage("immobilise")%>"><span class="mif-lock"></span></button>&emsp;' : '') +
                            ((data.immobiliser === true) ? '<button class="button mini-button" onclick="mobilise(' + data.id + ')" title="<%=userProperties.getLanguage("mobilise")%>"><span class="mif-unlock"></span></button>' : '') +
                            ((data.camera === true) ? '<br>Camera Live<br>' : '') +
                            ((data.camera === true) ? '<button class="button mini-button" onclick="openCameraDialog(\'' + data.camera_all + '\')">ALL</button>&emsp;' : '') +
                            ((data.camera === true) ? '<button class="button mini-button" onclick="openCameraDialog(\'' + data.camera_cam1 + '\')">1</button>&emsp;' : '') +
                            ((data.camera === true) ? '<button class="button mini-button" onclick="openCameraDialog(\'' + data.camera_cam2 + '\')">2</button>&emsp;' : '') +
                            ((data.camera === true) ? '<button class="button mini-button" onclick="openCameraDialog(\'' + data.camera_cam3 + '\')">3</button>&emsp;' : '') +
                            ((data.camera === true) ? '<button class="button mini-button" onclick="openCameraDialog(\'' + data.camera_cam4 + '\')">4</button>&emsp;' : '') +
                            ((data.camera === true) ? '<br>Camera History<br>' : '') +
                            ((data.camera === true) ? '<button class="button mini-button" onclick="openCameraHistoryDialog(\'' + data.camera_id + '\')"><span class="mif-history"></span></button>&emsp;' : '') +
                            '</blockquote>');
                    });

                    var popupHTML = '<div class="uppercase">' +
                        '<h4>' + data.driver + ' ' + ((data.model !== null && data.model !== 'null' && data.model !== "") ? '(' + data.model + ')' : '') + '</h4>' +
                        ((data.label !== null && data.label !== 'null') ? data.label + '<br>' : '') +
                        data.timestamp + '<br>' +
                        eventName + '<br>' +
                        data.rfid + '<br>' +
                        'HEADING ' + data.heading + '<br>' +
                        data.validity + '&emsp;' +
                        data.speed + 'km/h&emsp;' +
                        data.temperature + '&#176;C&emsp;' +
                        data.sectemperature + '&#176;C<br>' +
                        data.road + '<br>' +
                        (Math.round(data.longitude * 100000) / 100000) + ', ' + (Math.round(data.latitude * 100000) / 100000) + '<br>' +
                        '<button class="button mini-button" onclick="zoomToMarker(' + data.id + ')" title="<%=userProperties.getLanguage("zoomToLocation")%>"><span class="mif-zoom-in"></span></button>&emsp;' +
                        '<button class="button mini-button" onclick="historyView(' + data.id + ', \'' + newLabel + '\')" title="<%=userProperties.getLanguage("trackHistory")%>"><span class="mif-history"></span></button>&emsp;' +
                        ((data.immobiliser === true) ? '<button class="button mini-button" onclick="immobilise(' + data.id + ')" title="<%=userProperties.getLanguage("immobilise")%>"><span class="mif-lock"></span></button>&emsp;' : '') +
                        ((data.immobiliser === true) ? '<button class="button mini-button" onclick="mobilise(' + data.id + ')" title="<%=userProperties.getLanguage("mobilise")%>"><span class="mif-unlock"></span></button>' : '') +
                        '</div>';

                    markers[data.id] = {'lat': data.latitude, 'lng': data.longitude, 'label': data.driver, 'popup': popupHTML};

                    var limitWidth = $('#checkboxLimitLabelSize').prop('checked');

                    var labelOn = $('#checkboxToggleLabel').prop('checked');

                    var locationInfo = [data.latitude, data.longitude, data.headingValue, data.status, data.timestamp, data.event, data.driver, popupHTML, data.id, limitWidth, data.labelColor, data.custom, data.icons, labelOn];
                    if (checkNumberOfMap() === 4)
                    {
                        loopArray(checkedAsset1, geoLocation1, data.id, locationInfo); // check if the array have this asset ticked
                        loopArray(checkedAsset2, geoLocation2, data.id, locationInfo);
                        loopArray(checkedAsset3, geoLocation3, data.id, locationInfo);
                        loopArray(checkedAsset0, geoLocation0, data.id, locationInfo);
                    }
                    else if (checkNumberOfMap() === 2)
                    {
                        loopArray(checkedAsset1, geoLocation1, data.id, locationInfo);
                        loopArray(checkedAsset0, geoLocation0, data.id, locationInfo);
                    }
                    else
                    {
                        geoLocation.push(locationInfo);
                    }
                }

                if (checkNumberOfMap() === 4)
                {

                    $(document.body).find('div#data-label').remove(); // this is for marker label of the map

                    map1.removeLastLocationLayer();
                    map2.removeLastLocationLayer();
                    map3.removeLastLocationLayer();
                    map.removeLastLocationLayer();

                    addGeoLocationLayer(geoLocation1, map1);
                    addGeoLocationLayer(geoLocation2, map2);
                    addGeoLocationLayer(geoLocation3, map3);
                    addGeoLocationLayer(geoLocation0, map);

                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.removeLastLocationLayer();
                    map.removeLastLocationLayer();

                    addGeoLocationLayer(geoLocation1, map1);
                    addGeoLocationLayer(geoLocation0, map);

                }
                else
                {
                    // when no selected Map
                    map.removeLastLocationLayer();
                    addGeoLocationLayer(geoLocation, map);

                    if ($('#dialog-geofence-count').css('display') !== 'none')
                    {
                        geofenceOnClick(clickedGeofence.id, clickedGeofence.name);
                    }
                }



                function loopArray(array, geolocationArray, resultId, locationInfo)
                {

                    for (var i = 0; i < array.length; i++)
                    {
                        var splitStr = array[i].split("-");

                        if (splitStr[2] == resultId)
                        {
                            geolocationArray.push(locationInfo);
                        }
                    }
                }

                function addGeoLocationLayer(geo, maps)
                {
                    if (geo.length > 0)
                    {
                        maps.removeLastLocationLayer();
                        if (geo.length > 0)
                        {
                            maps.addLastLocationLayer(geo);

                        }
                        if (autoZoom)
                        {
                            if (geo.length === 1)
                            {
                                maps.zoomTo(geo[0][0], geo[0][1], defaultZoom);
                            }
                            else
                            {
                                maps.zoomToMarkers(geo);
                            }
                        }
                    }
                }
            }

            function getAssetEvent(id)
            {
                var assets = $('[id^=driver-detail-' + id + '-]');

                var event = '';

                if (assets.length > 0)
                {
                    event = $(assets[0]).attr('data-event');
                }

                return event;
            }

            function immobilise(assetId)
            {
                $.ajax({
                    type: 'POST',
                    url: 'MapController',
                    data: {
                        type: 'system',
                        action: 'immobilise',
                        assetId: assetId
                    },
                    beforeSend: function()
                    {
                    },
                    success: function(data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
                        else
                        {
                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                    },
                    async: true
                });

            }

            function mobilise(assetId)
            {

                $.ajax({
                    type: 'POST',
                    url: 'MapController',
                    data: {
                        type: 'system',
                        action: 'mobilise',
                        assetId: assetId
                    },
                    beforeSend: function()
                    {
                    },
                    success: function(data)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {

                                dialog('Success', data.text, 'success');

                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
                        else
                        {
                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                    },
                    async: true
                });

            }
            function splitArray(array)
            { // now storing asset-details-id-sequence instead of just assetId
                var splitedArray = [];
                for (var i = 0; i < array.length; i++)
                {
                    var splited = array[i].split("-");
                    splitedArray.push(splited[2]);
                }
                return splitedArray;
            }


            function refreshElapsed()
            {
                

                // checkedAsset is for all map, 0-3 is for 1st to 4th map from top left to right and btm left to right
                var combinedArray = [];
                combinedArray = checkedAsset.slice(); //wont delete from checkedAsset

                if (checkNumberOfMap() !== undefined)
                { // mean that it is splited into 4 maps, as long as split into four will call this else will used checkedAsset
                    for (var i = 0; i < checkedAsset1.length; i++)
                    {
                        if (combinedArray.indexOf(checkedAsset1[i]) < 0)
                        {
                            combinedArray.push(checkedAsset1[i]);

                        }
                    }
                    for (var i = 0; i < checkedAsset2.length; i++)
                    {
                        if (combinedArray.indexOf(checkedAsset2[i]) < 0)
                        {
                            combinedArray.push(checkedAsset2[i]);

                        }
                    }
                    for (var i = 0; i < checkedAsset3.length; i++)
                    {
                        if (combinedArray.indexOf(checkedAsset3[i]) < 0)
                        {
                            combinedArray.push(checkedAsset3[i]);

                        }
                    }
                    for (var i = 0; i < checkedAsset0.length; i++)
                    {
                        if (combinedArray.indexOf(checkedAsset0[i]) < 0)
                        {
                            combinedArray.push(checkedAsset0[i]);

                        }
                    }

                }


//                var assets = $('#tree-view-asset').find('[data-name=asset]').find('[type="checkbox"]:checked');
//
//                var assetArray = new Array(assets.length);
//
//                for (i = 0; i < assets.length; i++)
//                {
//                    var asset = $(assets[i]).parents('li');
//
//                    assetArray[i] = asset.data('asset-id');
//                }

                return splitArray(combinedArray);
            }

            function toggleAutoRefresh()
            {
                autoRefresh = !autoRefresh;

                if (autoRefresh)
                {
                    _live.startRefresh(intervalRefresh);
                }
                else
                {
                    _live.stopRefresh();
                }
            }

            function toggleAddTraffic()
            {
                enableTraffic = !enableTraffic;

                if (enableTraffic)
                {
                    map.setTraffic(true);
                }
                else
                {
                    map.setTraffic(false);
                }
            }

            function toggleTrafficNews()
            {
                trafficNews = !trafficNews;

                if (trafficNews)
                {
                    onWebTraffic();
                    $('.map-marquee').css('display', 'inline-block');
                }
                else
                {
                    if (webTraffic !== null)
                    {
                        webTraffic.dispose();
                    }
                    $('.map-marquee').css('display', 'none');
                }
            }


            function toggleEnableHistoryLabel()
            {
                enableHistoryLabel = !enableHistoryLabel;

                map.toggleHistoryLine(enableHistoryLabel);
            }

            function toggleAutoZoom()
            {
                autoZoom = !autoZoom;
            }

            function toggleLabelSize()
            {
                var $marker = $('.leaflet-marker-label');

                if ($marker.hasClass('auto-width'))
                {
                    $marker.removeClass('auto-width');
                }
                else
                {
                    $marker.addClass('auto-width');
                }
            }

            function toggleLabel()
            {

                var on = document.getElementById('checkboxToggleLabel').checked;

                map.toggleLastLocationLayerLabel(on);
                if (checkNumberOfMap() === 4)
                {
                    map1.toggleLastLocationLayerLabel(on);
                    map2.toggleLastLocationLayerLabel(on);
                    map3.toggleLastLocationLayerLabel(on);
                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.toggleLastLocationLayerLabel(on);
                }
            }

            function toggleAssetDetail(assetId, element, checked)
            {
                var elementId = $(element).attr("id");

                element.setAttribute('data-checked', checked);

                if (checked)
                {
                    element.style.display = 'block';

                    if (!element.innerHTML)
                    {
                        element.innerHTML = '<span class="mif-spinner3 mif-ani-spin"></span>';
                    }

                    var marker = markers[assetId];

                    if (typeof marker !== 'undefined')
                    {
                        //zoomToMarker(assetId);
                    }
                    if ($("section.full-screen").children().hasClass("selected") && checkNumberOfMap() !== undefined)
                    { // if one of the map is selected
                        $("section.full-screen").find("div.selected").each(function()
                        {
                            switch ($(this).attr("id"))
                            {
                                case "mapOutDiv":
                                    addToArray(checkedAsset0);
                                    break;
                                case "map1OutDiv":
                                    addToArray(checkedAsset1);
                                    break;
                                case "map2OutDiv":
                                    addToArray(checkedAsset2);
                                    break;
                                case "map3OutDiv":
                                    addToArray(checkedAsset3);
                                    break;
                            }
                        });
                    }
                    else
                    {
                        addToArray(checkedAsset);
                        if (checkNumberOfMap() === 4)
                        {
                            addToArray(checkedAsset0);
                            addToArray(checkedAsset1);
                            addToArray(checkedAsset2);
                            addToArray(checkedAsset3);
                        }
                        else if (checkNumberOfMap() === 2)
                        {
                            addToArray(checkedAsset0);
                            addToArray(checkedAsset1);
                        }
                    }
                }
                else
                {

                    element.style.display = 'none';

                    var marker = markers[assetId];

                    if (typeof marker !== 'undefined')
                    {
                        if ($("section.full-screen").children().hasClass("selected") && checkNumberOfMap() !== undefined)
                        {
                            $("section.full-screen").find("div.selected").each(function()
                            {
                                switch ($(this).attr("id"))
                                {
                                    case "mapOutDiv":
                                        removeFromArray(checkedAsset0, map);
                                        break;
                                    case "map1OutDiv":
                                        removeFromArray(checkedAsset1, map1);
                                        break;
                                    case "map2OutDiv":
                                        removeFromArray(checkedAsset2, map2);
                                        break;
                                    case "map3OutDiv":
                                        removeFromArray(checkedAsset3, map3);
                                        break;
                                }
                            });

                        }
                        else
                        { // when no selected map

                            removeFromArray(checkedAsset, map);
                            removeFromArray(checkedAsset0, map);

                            if (checkNumberOfMap() === 4)
                            {

                                removeFromArray(checkedAsset1, map1);
                                removeFromArray(checkedAsset2, map2);
                                removeFromArray(checkedAsset3, map3);
                                map1.removeLastLocationMarker(assetId);
                                map2.removeLastLocationMarker(assetId);
                                map3.removeLastLocationMarker(assetId);

                            }
                            else if (checkNumberOfMap() === 2)
                            {
                                removeFromArray(checkedAsset1, map1);
//                                map1.removeLastLocationMarker(assetId);
                            }
                        }
                    }
                }

                function addToArray(array)
                {

                    if (jQuery.inArray(elementId, array) === -1)
                    { // this check if the assetId is already in checkedAsset variable.
                        array.push(elementId);
                    }
                }
                function removeFromArray(array, map)
                {
                    map.removeLastLocationMarker(assetId);
                    var i = array.indexOf(elementId);

                    if (i > -1)
                    {
                        array.splice(i, 1);
                    }
                }
            }

            function onAssetTreeViewClicked(treeview, parent, children, checked)
            {
                // if checkbox is the asset itself...
                if (!parent.hasClass('node'))
                {
                    var assetId = parent.data('driver-id');

                    var detail = parent.children('[id^=driver-detail-' + assetId + '-]')[0];

                    toggleAssetDetail(assetId, detail, checked);
                }

                // if checkbox has children assets, get all the assets...
                for (i = 0; i < children.length; i++)
                {

                    var child = $(children[i]);

                    var assetId = child.data('driver-id');

                    var detail = child.children('[id^=driver-detail-' + assetId + '-]')[0];

                    toggleAssetDetail(assetId, detail, checked);
                }

                // only refresh when assets are checked...
                if (checked)
                {
                    map.removeHistoryLayer();
                    if (checkNumberOfMap() === 4)
                    {
                        map1.removeHistoryLayer();
                        map2.removeHistoryLayer();
                        map3.removeHistoryLayer();
                    }
                    else if (checkNumberOfMap() === 2)
                    {
                        map1.removeHistoryLayer();
                    }
                    else
                    {
                        _live.refresh(splitArray(checkedAsset));
                    }
                }
                else
                {
                    setTimeout(function()
                    {
                        $('#tree-view-driver').find(':checkbox').removeAttr('disabled')
                    }, 2000);
                }
            }

            function onGeoFenceTreeViewClicked(treeview, parent, children, checked)
            {
                var geoFenceArray = [];

                if (map.isDrawing())
                {
                    cancelDraw();
                }
                if (checkNumberOfMap() === 4)
                {
                    if (map1.isDrawing())
                    {
                        map1.drawPolygonCancel();
                    }
                    if (map2.isDrawing())
                    {
                        map2.drawPolygonCancel();
                    }
                    if (map3.isDrawing())
                    {
                        map3.drawPolygonCancel();
                    }
                }
                else if (checkNumberOfMap() === 2)
                {
                    if (map1.isDrawing())
                    {
                        map1.drawPolygonCancel();
                    }
                }

                // if checkbox is the geoFence itself...
                if (!parent.hasClass('node'))
                {
                    var geoFenceId = parent.data('geofence-id');

                    var detail = parent.children('[id^=geofence-detail-' + geoFenceId + ']')[0];

                    toggleGeoFenceDetail(geoFenceId, detail, checked);

                    geoFenceArray.push(geoFenceId);
                    if (!checked && $('#geofence-detail-' + geoFenceId).css("display") === 'none')
                    {
                        geoFences[geoFenceId] = undefined;

                        map.removeGeofenceLayer(geoFenceId, true, 0);

                        mapRemoveGeoFenceLayer(geoFenceId);
                    }
                }

                // if checkbox has children geoFences, get all the geoFences...
                for (i = 0; i < children.length; i++)
                {
                    var child = $(children[i]);

                    var geoFenceId = child.data('geofence-id');

                    var detail = child.children('[id^=geofence-detail-' + geoFenceId + ']')[0];

                    toggleGeoFenceDetail(geoFenceId, detail, checked);

                    geoFenceArray.push(geoFenceId);

                    if (!checked && $('#geofence-detail-' + geoFenceId).css("display") === 'none') //mean not checked, so it will go to remove
                    {
                        geoFences[geoFenceId] = undefined; // how to empty

                        map.removeGeofenceLayer(geoFenceId, true, 0);

                        mapRemoveGeoFenceLayer(geoFenceId);
                    }
                }

                // only refresh when geoFences are checked...
                if (checked)
                {
                    var geoFenceId = geoFenceArray.join(',');

                    v3nityGetGeoFence(geoFenceCallback, geoFenceId);
                }

                function mapRemoveGeoFenceLayer(geoFenceId)
                {

                    if (checkNumberOfMap() === 4)
                    {

                        map1.removeGeofenceLayer(geoFenceId, true, 1);

                        map2.removeGeofenceLayer(geoFenceId, true, 2);

                        map3.removeGeofenceLayer(geoFenceId, true, 3);
                    }
                    else if (checkNumberOfMap() === 2)
                    {

                        map1.removeGeofenceLayer(geoFenceId, true, 1);
                    }
                }
            }

            function onRouteTreeViewClicked(treeview, parent, children, checked)
            {

                var routeArray = [];

                if (map.isDrawing())
                {
                    cancelDraw();
                }

                // if checkbox is the geoFence itself...
                if (!parent.hasClass('node'))
                {

                    var routeId = parent.data('route-id');

                    var detail = parent.children('[id^=route-detail-' + routeId + ']')[0];

                    toggleRouteDetail(routeId, detail, checked);

                    routeArray.push(routeId);

                }

                // if checkbox has children geoFences, get all the geoFences...
                for (i = 0; i < children.length; i++)
                {
                    var child = $(children[i]);

                    var routeId = child.data('route-id');

                    var detail = child.children('[id^=route-detail-' + routeId + ']')[0];

                    toggleRouteDetail(routeId, detail, checked);

                    routeArray.push(routeId);

                }

                // only refresh when geoFences are checked...
                if (checked)
                {

                    var routeId = routeArray.join(',');

                    v3nityGetRoute(routeCallback, routeId);
                }
            }

            function onTreeviewCheckboxClicked(treeview, parent, children, checked)
            {

                if (treeview === 'tree-view-driver')
                {
                    onAssetTreeViewClicked(treeview, parent, children, checked);

                    var numberOfCheckboxClicked = parent.length + children.length;

                    if (checkNumberOfMap() > 0 && (numberOfCheckboxClicked) > 5)
                    {
                        $('#tree-view-driver').find(':checkbox').attr('disabled', 'disabled');
                    }
                }
                else if (treeview === 'tree-view-geofence')
                {
                    onGeoFenceTreeViewClicked(treeview, parent, children, checked);
                }
                else if (treeview === 'tree-view-route')
                {
                    onRouteTreeViewClicked(treeview, parent, children, checked);
                }
                else
                {
                    return;
                }
            }

            function zoomToMarker(id)
            {
                switchMode(0);

                var marker = markers[id];

                var lat = marker.lat;

                var lng = marker.lng;


                if ($("section.full-screen").children().hasClass("selected") && checkNumberOfMap() !== undefined)  // if one of the map is selected
                {
                    $("section.full-screen").find("div.selected").each(function()
                    {
                        switch ($(this).attr("id"))
                        {
                            case "mapOutDiv":
                                checkMapArrayHaveAsset(checkedAsset0, id, map);
                                break;
                            case "map1OutDiv":
                                checkMapArrayHaveAsset(checkedAsset1, id, map1);
                                break;
                            case "map2OutDiv":
                                checkMapArrayHaveAsset(checkedAsset2, id, map2);
                                break;
                            case "map3OutDiv":
                                checkMapArrayHaveAsset(checkedAsset3, id, map3);
                                break;
                        }
                    });
                }
                else if (checkNumberOfMap() == 4)
                { // must check if each map have the same asset
                    checkMapArrayHaveAsset(checkedAsset0, id, map);
                    checkMapArrayHaveAsset(checkedAsset1, id, map1);
                    checkMapArrayHaveAsset(checkedAsset2, id, map2);
                    checkMapArrayHaveAsset(checkedAsset3, id, map3);
//                    map1.zoomTo(lat, lng, defaultZoom);
//                    map2.zoomTo(lat, lng, defaultZoom);
//                    map3.zoomTo(lat, lng, defaultZoom);
//                    setTimeout(function() { // when zoomed, popup the text in 3seconds
//                        map1.openMarkerDetails(lat,lng, marker['popup']);
//                        map2.openMarkerDetails(lat,lng, marker['popup']);
//                        map3.openMarkerDetails(lat,lng, marker['popup']);
//                    }, 1500);
                }
                else if (checkNumberOfMap() == 2)
                {
                    checkMapArrayHaveAsset(checkedAsset0, id, map);
                    checkMapArrayHaveAsset(checkedAsset1, id, map1);
//                    map1.zoomTo(lat, lng, defaultZoom);
//                    setTimeout(function() {
//                        map1.openMarkerDetails(lat,lng, marker['popup']);
//                    }, 1500);
                }
                else
                {

                    map.zoomTo(lat, lng, defaultZoom);
                    setTimeout(function()
                    { // for now, just put like this. autorefresh will kill the popup.
                        map.openMarkerDetails(lat, lng, marker['popup']);
                    }, 500);
                }

                function checkMapArrayHaveAsset(array, id, map)
                {  // going through additional check to see if the map have the checked asset

                    var n;
                    for (var i = 0; i < array.length; i++)
                    {
                        n = array[i].search(id);
                        if (n > 0)
                        {
                            break;
                        }
                    }

                    if (n > 0)
                    { // if have result, then zoom to marker
                        map.zoomTo(lat, lng, defaultZoom);
                        setTimeout(function()
                        {
                            map.openMarkerDetails(lat, lng, marker['popup']);
                        }, 500);

                    }

                }
            }

            function zoomToLocation(lat, lng, id)
            {
                map.zoomTo(lat, lng, map.getCurrentZoomLevel());

                locations[id].openPopup();
            }

            function searchAddressCallback(data)
            {
                var minLat, minLng, maxLat, maxLng;

                //document.getElementById('matches-address').innerHTML = data.result.length + ' found';

                var resultTable = document.getElementById('results-address');

                var html = '<ul class="address-block">';

                map.clearOverlay(locationLayer);

                locations.length = 0;

                for (i = 0; i < data.result.length; i++)
                {

                    var result = data.result[i];

                    var label = result.driver.split(',');

                    html += '<li><a onclick="zoomToLocation(' + result.latitude + ', ' + result.longitude + ', ' + i + ');"><blockquote>';

                    for (j = 0; j < label.length; j++)
                    {
                        html += '<p>' + label[j] + '<p>';
                    }

                    html += '</blockquote></a></li>';

                    var newMarker = map.createMarker({
                        latlng: [result.latitude, result.longitude],
                        icon: markerLocation,
                        popup: result.driver,
                        popupoffset: [0, -54]
                    });

                    //map.addMarker(newMarker, locationLayer);

                    //locations.push(newMarker);

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

                map.searchAddress(searchText, searchAddressCallback, '<%=domainURL%>');
            }

            function checkAssetTreeview(assetArray)
            {
                //Remove all check in the assetTreeView
                $('#tree-view-driver').find('[data-name=driver]').find('[type="checkbox"]:checked').each(function()
                {
                    $(this).prop('checked', false);
                    $(this).parents('li').children('div').attr('data-checked', false);
                    $(this).parents('li').children('div').css('display', 'none');

                    //$(this).parents('li').parents('li').children('div').attr('data-checked', false);
                    $(this).parents('li').parents('li').find('[type="checkbox"]:checked').prop('checked', false);

                    //$(this).parents('li').parents('li').parents('li').children('div').attr('data-checked', false);
                    $(this).parents('li').parents('li').parents('li').find('[type="checkbox"]:checked').prop('checked', false);
                });

                //input the asset from selected map to assetTreeView
                for (var i = 0; i < assetArray.length; i++)
                {
                    var asset = $('#tree-view-driver').find('#' + assetArray[i]);
                    asset.attr('data-checked', true).css('display', 'block');
                    asset.parent().find('[type="checkbox"]').prop('checked', true);

                    asset.parent().parent().parent().find('[name="driver-type"][type="checkbox"]').prop('checked', true);

                    asset.parents('li').parents('li').find('[name="driver-group"][type="checkbox"]').prop('checked', true);
                }
            }

            function toggleLiveMenu(hide)
            {
                if (checkNumberOfMap() != undefined)
                { //activite only when map is splited, to refresh the assetTreeView
                    if ($("section.full-screen").children().hasClass("selected"))
                    {
                        $("section.full-screen").find("div.selected").each(function()
                        {
                            switch ($(this).attr("id"))
                            {
                                case "mapOutDiv":
                                    checkAssetTreeview(checkedAsset0);
                                    break;
                                case "map1OutDiv":
                                    checkAssetTreeview(checkedAsset1);
                                    break;
                                case "map2OutDiv":
                                    checkAssetTreeview(checkedAsset2);
                                    break;
                                case "map3OutDiv":
                                    checkAssetTreeview(checkedAsset3);
                                    break;
                            }
                        });
                    }
                    else
                    {
                        checkAssetTreeview(checkedAsset);
                        // need to check if there are other map
                    }
                }
                var charm = $("#charmLive");
                if (charm.data('hidden') === undefined)
                {
                    charm.data('hidden', true);
                    charm.css('left', -320);
                    return;
                }
                if (!charm.data('hidden')) // when closing , will go this
                {
                    charm.animate({
                        left: -320
                    }, 100);
                    charm.data('hidden', true);

                    mapPadding = [0, 0];
                }
                else
                {
                    if (typeof hide != undefined && !hide)
                    {
                        charm.animate({
                            left: 0
                        }, 100);
                        charm.data('hidden', false);

                        mapPadding = [320, 0];

                        switchMode(0);
                    }
                }
            }

            function toggleHistoryMenu(show)
            {
                var charm = $("#charmHistory");
                if (charm.data('hidden') === undefined)
                {
                    charm.data('hidden', true);
                    charm.css('bottom', -140);
                    return;
                }
                if (!show)
                {
                    charm.animate({
                        bottom: -140
                    }, 100);
                    charm.data('hidden', true);

                    historyPause();
                }
                else
                {
                    charm.animate({
                        bottom: 0
                    }, 100);
                    charm.data('hidden', false);
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

                    switchMode(2);
                }
            }

            function toggleJobMenu()
            {
                var charm = $("#charmJob");
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

                    switchMode(4);
                }
            }

            function toggleMapSettingsMenu()
            {
                var charm = $("#charmMapSettings");
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

            function toggleRouteDeviationMenu()
            {
                var charm = $("#charmRoute");
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

                    switchMode(3);
                }
            }

            function toggleGeoFenceMenu()
            {
                var charm = $("#charmGeoFence");
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

                    switchMode(3);
                }
            }

            function toggleGeoFenceDetail(id, element, checked)
            {

                if (checked)
                {
                    element.style.display = 'block';
                }
                else
                {
                    element.style.display = 'none'; // this part will fire first, this is to remove the left side part.

                    map.removeGeofenceLayer(id, false, 0);

                    if (checkNumberOfMap() === 4)
                    {
                        map1.removeGeofenceLayer(id, false, 1);
                        map2.removeGeofenceLayer(id, false, 2);
                        map3.removeGeofenceLayer(id, false, 3);
                    }
                    else if (checkNumberOfMap() === 2)
                    {
                        map1.removeGeofenceLayer(id, false, 1);
                    }
                }
            }


            function toggleRouteDetail(id, element, checked)
            {
                if (checked)
                {
                    element.style.display = 'block';
                }
                else
                {
                    element.style.display = 'none';
                    map.removepolylineLayer(id);
                }
            }

            function zoomToPolygon(id)
            {
                var polygon = geoFences[id];
                map.zoomToPolygon(polygon);
                if (checkNumberOfMap() === 4)
                {
                    map1.zoomToPolygon(polygon);
                    map2.zoomToPolygon(polygon);
                    map3.zoomToPolygon(polygon);
                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.zoomToPolygon(polygon);
                }
            }

            function startDraw()
            {
                if ('${custom}' == 'lite')
                {
                    if ($('#tree-view-geofence').find('[data-name="geofence-name"]').length >= 3)
                    {
                        dialog('Maximum Limit', 'You have reached the maximum limit of 3 Geo Fence', 'alert');
                        return false;
                    }
                }
                map.drawPolygonStart();
            }

            function startDrawPolyline()
            {
                map.drawPolylineStart();
            }

            function stopDrawPolyline()
            {
                map.drawPolylineStop();
            }

            function cancelDrawPolyline()
            {
                map.drawPolylineCancel();

                map.location_list = '';
            }

            function stopDraw()
            {
                map.drawPolygonStop();
            }

            function cancelDraw()
            {
                map.drawPolygonCancel();

                edit = false;
            }

            function geoFenceCallback(result)
            {
                for (var i = 0; i < result.data.length; i++)
                {
                    var geofence = result.data[i];

                    var id = geofence.id;

                    var polygon = geoFences[id];

                    if (polygon === undefined)
                    {
                        var latlngs = map.convertSerialCoordinatesToLatLng(geofence.points);

                        geoFences[id] = latlngs;

                        var details = $('[id^=geofence-detail-' + id + ']');

                        var customerId = details.data('customer-id');

                        details.html('<blockquote class="text-small uppercase">' +
                            '<h6>Speed Limit: ' + geofence.speedLimit + '</h6>' +
                            '<button class="button mini-button" onclick="zoomToPolygon(' + id + ')" title="Zoom"><span class="mif-zoom-in"></span></button>&emsp;' +
            <%=(canDeleteGeofence ? "'<button class=\"button mini-button\" onclick=\"deleteGeoFence(' + id + ')\" title=\"Delete\"><span class=\"mif-bin\"></span></button>&emsp;'" : "''")%> +
            <%=(canUpdateGeofence ? "'<button class=\"button mini-button\" onclick=\"editGeoFence(' + id + ',' + customerId + ', \\'' + geofence.name + '\\', ' + geofence.speedLimit + ', \\'' + geofence.geoFenceColor + '\\')\" id=\"geofence-edit-' + id + '\" style=\"display: inline\" data-mode=\"edit\"><span class=\"mif-pencil\"></span></button>&emsp;'" : "''")%> +
                            '</blockquote>'
                            );
                    }
                    var polygonArea = map.calculateArea(latlngs);
                    geoFences[id]['property'] = [polygonArea, id, latlngs, geofence.name, geofence.geoFenceColor];
                }

                function mySortFunction(a, b)
                {
                    return parseInt(b["property"][0]) - parseInt(a["property"][0]);
                }

                var sortingArray = geoFences.slice(); //copy to a new array as aftering sorting the id will be 0, 1,2,3,4 and not according to geofenceID
                sortingArray.sort(mySortFunction);
                map.removeAllGeofenceLayer(0);
                if (checkNumberOfMap() === 4)
                {
                    map.removeAllGeofenceLayer(1);
                    map.removeAllGeofenceLayer(2);
                    map.removeAllGeofenceLayer(3);
                }
                else if (checkNumberOfMap === 2)
                {
                    map.removeAllGeofenceLayer(1);
                }

                for (var key in sortingArray)
                {
                    if (typeof sortingArray[key] != 'undefined' && typeof sortingArray[key]["property"] !== 'undefined')
                    {
                        var geoInfo = sortingArray[key]["property"];
                        map.addGeofenceLayer(geoInfo[1], geoInfo[2], geoInfo[3], geofenceOnChange, geofenceOnClick, 0, geoInfo[4]);
                        if (checkNumberOfMap() === 4)
                        { // so here, call another function to determine area
                            map1.addGeofenceLayer(geoInfo[1], geoInfo[2], geoInfo[3], geofenceOnChange, geofenceOnClick, 1, geoInfo[4]);
                            map2.addGeofenceLayer(geoInfo[1], geoInfo[2], geoInfo[3], geofenceOnChange, geofenceOnClick, 2, geoInfo[4]);
                            map3.addGeofenceLayer(geoInfo[1], geoInfo[2], geoInfo[3], geofenceOnChange, geofenceOnClick, 3, geoInfo[4]);
                        }
                        else if (checkNumberOfMap() === 2)
                        {
                            map1.addGeofenceLayer(geoInfo[1], geoInfo[2], geoInfo[3], geofenceOnChange, geofenceOnClick, 1, geoInfo[4]);
                        }
                    }
                }
            }

            function geofenceOnChange(id)
            {
                $('#geofence-edit-' + id).html('<span class="mif-floppy-disk"></span>');

                $('#geofence-edit-' + id).attr('data-mode', 'save');
            }

            function geofenceOnClick(id, name)
            {
                if (!countGeofenceLoading)
                {
                    clickedGeofence = {'id': id, 'name': name};

                    $.ajax({
                        type: 'POST',
                        url: 'MapController',
                        data: {
                            'lib': 'track',
                            'type': 'GeoFence',
                            'action': 'assetGeofence',
                            'id': id,
                            'name': name,
                            'assets': getTreeId('tree-view-asset', 'asset-id')
                        },
                        beforeSend: function()
                        {
                            countGeofenceLoading = true;
                        },
                        success: function(data)
                        {
                            if (data.expired === undefined)
                            {
                                if (data.result === true)
                                {
                                    var assets = data.data;

                                    var content = $('#dialog-geofence-content');

                                    content.html('');

                                    var off = 0;

                                    for (var i = 0; i < assets.length; i++)
                                    {
                                        var event = getAssetEvent(assets[i].id);

                                        content.append('<li class="event-' + event + ' opacity">' + assets[i].label + '</li>');

                                        if (event === 'ignitionoff' || event === 'standing')
                                        {
                                            off++;
                                        }
                                    }

                                    var on = data.total - off;

                                    $('#dialog-geofence-name').html(data.name);

                                    $('#dialog-geofence-total').html('<span class="data-field title">on</span>' + on + '<br><span class="data-field title">off</span>' + off);

                                    $('#dialog-geofence-count').show();
                                }
                                else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
                            }
                            else
                            {
                                $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                            }
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            countGeofenceLoading = false;
                        },
                        async: false
                    });
                }
            }

            function routeCallback(result)
            {
                for (var i = 0; i < result.data.length; i++)
                {
                    var route = result.data[i];

                    var id = route.id;

                    var polyline = polylines[id];

                    if (polyline === undefined)
                    {
                        var locations = [];

                        for (var j = 0; j < route.points.length - 1; j = j + 2)
                        {
                            var lat = route.points[j];
                            var lng = route.points[j + 1];

                            var location = [];
                            location.lat = lat;
                            location.lng = lng;
                            location.id = id;
                            locations.push(location);
                        }

                        map.modifyPolylineStart(locations);

                        var details = $('[id^=route-detail-' + id + ']');

                        details.html(
                            '<blockquote class="text-small uppercase">' +
            <%=(canDeleteRoute ? "'<button class=\"button mini-button\" onclick=\"deleteRoute(' + id + ')\" title=\"Delete\"><span class=\"mif-bin\"></span></button>&emsp;'" : "0")%> +
                            '</blockquote>'
                            );

                    }
                }
            }

            function addGeoFenceToTreeView(customerId, geoFenceId, geoFenceName) // if no initial geofence, then there wont be the group name(node) which will cause UI error when adding it.
            {
                var tree = $("#tree-view-geofence").data("treeview");

                var node = tree.element.find('li[data-geofence-customer-id="' + customerId + '"]');

                // open your big eyes to see carefully!!! the values are strictly taken from the GeoFenceTreeView class...
                tree.addLeaf(node, geoFenceName, {
                    mode: 'checkbox',
                    name: 'geofence-name',
                    'geofence-id': geoFenceId,
                    checked: false
                });

                $('li[data-geofence-id="' + geoFenceId + '"]').append('<div id=\"geofence-detail-' + geoFenceId + '\" data-customer-id=\"' + customerId + '\" style=\"margin-left: 0px;\"></div>');

            }

            function addRouteToTreeView(customerId, routeId, routeName)
            {
                var tree = $("#tree-view-route").data("treeview");

                var node = tree.element.find('li[data-route-customer-id="' + customerId + '"]');

                tree.addLeaf(node, routeName, {
                    mode: 'checkbox',
                    name: 'route-name',
                    'route-id': routeId,
                    checked: false
                });

                $('li[data-route-id="' + routeId + '"]').append('<div id=\"route-detail-' + routeId + '\" data-customer-id=\"' + customerId + '\" style=\"margin-left: 0px;\"></div>');

            }

            function updateGeoFenceToTreeView(geoFenceId, geoFenceName, geoFenceColor)
            {
                var tree = $("#tree-view-geofence").data("treeview");

                var node = tree.element.find('li[data-geofence-id="' + geoFenceId + '"]');

                var leaf = $(node).children('span.leaf');

                $(node).find('[type="checkbox"]').click();

                leaf.html("<span class=\"color-code-node\" style=\"background-color:" + geoFenceColor + ";\"></span> " + geoFenceName + " ");
            }

            function updateRouteToTreeView(routeId, routeName)
            {
                var tree = $("#tree-view-route").data("treeview");

                var node = tree.element.find('li[data-route-id="' + routeId + '"]');

                var leaf = $(node).children('span.leaf');

                $(node).find('[type="checkbox"]').click();

                leaf.html(routeName);
            }

            function removeGeoFenceFromTreeView(geoFenceId)
            {
                $('li[data-geofence-id="' + geoFenceId + '"]').remove();
            }

            function removeRouteFromTreeView(routeId)
            {
                $('li[data-route-id="' + routeId + '"]').remove();
            }

            function registerGeoFencePoints(latlngs)
            {
                var points = latlngs;

                var strPoints = "";

                for (i = 0; i < points.length; i++)
                {
                    if (i > 0)
                    {
                        strPoints += ',';
                    }

                    var point = points[i];	// gets the point object in L.latlng...

                    strPoints += point.lng + ',' + point.lat;
                }

                $('#geoFencePoints').val(strPoints);
            }

            function showAdd()
            {

                var drawCount = map.getGeofenceDrawCount();

                if (drawCount > 2)
                {
                    var formDialog = $('#form-dialog').data('dialog');

                    if (edit)
                    {
                        $('#form-dialog-title').html('<%=userProperties.getLanguage("edit")%> ' + '<%=userProperties.getLanguage("geoFence")%>');

                        $('#button-save').data('action', 'edit');
                    }
                    else
                    {
                        $('#form-dialog-title').html('<%=userProperties.getLanguage("add")%> ' + '<%=userProperties.getLanguage("geoFence")%>');

                        $('#button-save').data('action', 'add');

                        clearForm();
                    }

                    formDialog.open();
                }
                else
                {
                    dialog('Insufficient Points', 'Please add 3 or more points', 'alert');
                }
            }

            function showEdit(geofence)
            {

                var drawCount = geofence.getPath().getLength();

                if (drawCount > 2)
                {
                    var formDialog = $('#form-dialog').data('dialog');

                    $('#form-dialog-title').html('<%=userProperties.getLanguage("edit")%> ' + '<%=userProperties.getLanguage("geoFence")%>');

                    $('#button-save').data('action', 'edit');

                    formDialog.open();
                }
                else
                {
                    dialog('Insufficient Points', 'Please add 3 or more points', 'alert');
                }

                edit = true;
            }

            function showAddRoute()
            {

                if (map.getRouteDrawCount() > 0)
                {
                    var formDialog = $('#form-dialog-polyline').data('dialog');

                    $('#polylinePoints').val(map.location_list);

                    $('#waypoints').val(map.getwaypoints());

                    if (edit)
                    {
                        $('#form-dialog-title-polyline').html('<%=userProperties.getLanguage("edit")%> ' + '<%=userProperties.getLanguage("route")%>');

                        $('#button-save').data('action', 'edit');
                    }
                    else
                    {
                        $('#form-dialog-title-polyline').html('<%=userProperties.getLanguage("add")%> ' + '<%=userProperties.getLanguage("route")%>');

                        $('#button-save').data('action', 'add');

                        clearForm();
                    }

                    formDialog.open();
                }
                else
                {
                    dialog('Insufficient Points', 'Please draw more points', 'alert');
                }
            }

            function clearForm()
            {
                document.getElementById('form-dialog-data').reset();
            }

            function closeForm()
            {
                var dialog = $('#form-dialog').data('dialog');

                dialog.close();

                dialog = $('#form-dialog-polyline').data('dialog');

                dialog.close();

                clearForm();
            }

            function saveForm()
            {

                var action = $('#button-save').data('action');

                var id = $('#button-save').data('id');

                if (id === undefined)
                {
                    id = 0;
                }

                // this is important to set the points into the input tag...
                if (!edit)
                {
                    registerGeoFencePoints(map.getPolygonLatLngs());
                }

                $.ajax({
                    type: 'POST',
                    url: 'ListController?lib=v3nity.std.biz.data.track&type=GeoFence&action=' + action + '&id=' + id,
                    data: $('#form-dialog-data').serialize(),
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function(data)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');

                                if (edit)
                                {
                                    updateGeoFenceToTreeView(data.dataId, data["[geo_fence]"], data["[geo_fence_color]"]);
                                }
                                else
                                {
                                    addGeoFenceToTreeView(data["[customer_id]"], data.dataId, data["[geo_fence]"]);
                                }

                                geoFences[id] = undefined;

                                closeForm();

                                cancelDraw();   // this will also reset the edit flag...
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
                        else
                        {
                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        $('#button-save').prop("disabled", false);
                    },
                    async: true
                });
            }

            function saveFormRoute()
            {

                var action = $('#button-save').data('action');

                var id = $('#button-save').data('id');

                if (id === undefined)
                {
                    id = 0;
                }

                $.ajax({
                    type: 'POST',
                    url: 'ListController?lib=v3nity.std.biz.data.track&type=Route&action=' + action + '&id=' + id,
                    data: $('#form-dialog-data-polyline').serialize(),
                    beforeSend: function()
                    {

                    },
                    success: function(data)
                    {

                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');

                                if (edit)
                                {
                                    updateRouteToTreeView(data.dataId, data["[route]"]);
                                }
                                else
                                {
                                    addRouteToTreeView(data["[customer_id]"], data.dataId, data["[route]"]);
                                }

                                polylines[id] = undefined;

                                closeFormPolyline();

                                cancelDrawPolyline();
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
                        else
                        {
                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: true
                });
            }

            function closeFormPolyline()
            {
                var dialog = $('#form-dialog-polyline').data('dialog');

                dialog.close();

                clearFormPolyline();
            }

            function clearFormPolyline()
            {
                document.getElementById('form-dialog-data-polyline').reset();
            }

            function deleteRoute(id)
            {
                if (id !== '')
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'ListController?lib=v3nity.std.biz.data.track&type=Route&action=delete',
                            data: {
                                id: id
                            },
                            beforeSend: function()
                            {

                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        // the returned id may contained multiple ids...
                                        var ids = data.dataId.split(',');

                                        for (i = 0; i < ids.length; i++)
                                        {
                                            var id = ids[i];

                                            removeRouteFromTreeView(id);

                                            var polygon = geoFences[id];

                                            if (polygon !== undefined)
                                            {
                                                geoFenceLayer.removeLayer(polygon);
                                            }

                                            map.removepolylineLayer(id);
                                        }

                                        closeForm();
                                    }
                                    else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
                                else
                                {
                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                }
                            },
                            error: function()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function()
                            {

                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Route', 'Please select Route to delete', 'alert');
                }
            }

            function deleteGeoFence(id)
            {
                if (id.toString().indexOf(",") != -1)
                {
                    dialog('Error', 'You can only delete one geofence at a time.', 'alert');
                    return false;
                }
                if (id !== '')
                {
                    var c = confirm("Are you sure you want to delete?");

                    if (c === true)
                    {
                        $.ajax({
                            type: 'POST',
                            url: 'ListController?lib=v3nity.std.biz.data.track&type=GeoFence&action=delete',
                            data: {
                                id: id
                            },
                            beforeSend: function()
                            {
                                $('#button-save').prop("disabled", true);
                            },
                            success: function(data)
                            {

                                if (data.expired === undefined)
                                {
                                    if (data.result === true)
                                    {

                                        dialog('Success', data.text, 'success');

                                        // the returned id may contained multiple ids...
                                        var ids = data.dataId.split(',');

                                        for (i = 0; i < ids.length; i++)
                                        {
                                            var id = ids[i];

                                            removeGeoFenceFromTreeView(id);

                                            map.removeGeofenceLayer(id, false, 0);

                                        }

                                        closeForm();
                                    }
                                    else
                                    {
                                        dialog('Failed', data.text, 'alert');
                                    }
                                }
                                else
                                {
                                    $('#main').load('Common/expired.jsp', {custom: '${custom}'});
                                }
                            },
                            error: function()
                            {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            complete: function()
                            {
                                $('#button-save').prop("disabled", false);
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Geo Fence', 'Please select Geo Fence to delete', 'alert');
                }
            }

            function editGeoFence(id, customerId, name, speedLimit, geoFenceColor)
            {
                var geofence = map.getGeofence(id, 0);

                if ($('#geofence-edit-' + id).attr('data-mode') === 'edit')
                {
                    if (geofence !== undefined)
                    {
                        $('#geofence-edit-' + id).attr('data-mode', 'cancel');

                        $('#geofence-edit-' + id).html('<span class="mif-cancel"></span>');

                        geofence.set('editable', true);

                        geofence.set('draggable', true);

                        geofence.set('fillColor', '#ffde3d');
                    }
                }
                else if ($('#geofence-edit-' + id).attr('data-mode') === 'cancel')
                {
                    if (geofence !== undefined)
                    {
                        $('#geofence-edit-' + id).attr('data-mode', 'edit');

                        $('#geofence-edit-' + id).html('<span class="mif-pencil"></span>');

                        geofence.set('editable', false);

                        geofence.set('draggable', false);

                        geofence.set('fillColor', '#000');
                    }
                }
                else
                {
                    if (geofence !== undefined)
                    {
                        registerGeoFencePoints(map.convertPathToLatLngs(geofence.getPath()));

                        $('select[name=customer_id]').val(customerId);
                        $('input[name=geo_fence]').val(name);
                        $('input[name=geo_fence_speed_limit]').val(speedLimit);
                        $('input[name=geo_fence_color]').val(geoFenceColor);
                        $('#button-save').data('id', id);
                    }

                    showEdit(geofence);
                }
            }
            function addInputBox(i, max)
            {
                for (i; i < max; i++)
                {
                    var mapName;
                    if (i === 0)
                    {
                        mapName = '#mapOutDiv';
                    }
                    else
                    {
                        mapName = '#map' + i + 'OutDiv';
                    }
                    if (!$(mapName).children().last().hasClass("mapInputBox"))
                    {
                        var inputDiv = $('<div />', {
                            class: 'mapInputBox',
                        });
                        var inputText = $('<input />', {
                            type: 'text',
                            class: 'mapInput'
                        });
                        var inputBtn = $('<input/>', {
                            type: 'button',
                            id: 'mapInputButton',
                            value: '>',
                            onclick: 'hideMapInputBox(this)'
                        });
                        inputDiv.append(inputText);
                        inputDiv.append(inputBtn);
                        $(mapName).append(inputDiv);
                    }
                }
            }
            function hideMapInputBox(thisId)
            {
                if ($(thisId).val() == "<")
                {
                    $(thisId).css('opacity', '0.5');
                    $(thisId).val('>');
                    $(thisId).siblings().css('visibility', 'hidden');
                }
                else
                {
                    $(thisId).css('opacity', '1');
                    $(thisId).val('<');
                    $(thisId).siblings().css('visibility', 'visible');
                }

            }

            function splitMap(numberOfSplit, withInputBox)
            {
                var halfScreenMap = $('#mapOutDiv').hasClass('half-screen');
                var quarterScreenMap = $('#mapOutDiv').hasClass('quarter-screen'); // check if map is split into how many pieces
                var checkIfHaveHeader = $('#mapOutDiv').children().last().hasClass('mapInputBox'); // check if there are header in the Map
                var fullMap = $('#mapOutDiv'); // first Map
                if (numberOfSplit == 1)
                { //attempting to split into 1 screen
                    fullMap.attr('class', 'full-screen');
                    $('#map1OutDiv').remove();
                    $('#map2OutDiv').remove();
                    $('#map3OutDiv').remove();
                    initiateSplitMap(1, withInputBox);
                }
                else if (numberOfSplit == 2)
                { // attempting to split into 2 screen
                    if (halfScreenMap)
                    { // already at 2 screen
                        // must do additional check
                        if (checkIfHaveHeader === withInputBox)
                        { // withInputBox come from user input, if user click with header and checkifhaveheader is true. both true = dialog message.
                            dialog('Failed', 'Map had been split.', 'alert');
                        }
                        else
                        {
                            if (withInputBox)
                            {
                                addInputBox(0, 2);
                            }
                        }
                    }
                    else if (quarterScreenMap)
                    { // 4 screen change to 2 screen
                        fullMap.attr('class', 'half-screen');
                        $('#map1OutDiv').attr('class', 'half-screen');
                        $('#map2OutDiv').remove();
                        $('#map3OutDiv').remove();
                        delete map2;
                        delete map3;
                        map.recentralize();
                        map1.recentralize();
                    }
                    else
                    { // 1 screen change to 2 screen
                        fullMap.attr('class', 'half-screen');
                        var mapView = $('<div/>', {
                            id: 'map1-view',
                            onclick: 'toggleMapClass(this)',
                        });
                        var divT = $('<div/>', {
                            id: 'map1OutDiv',
                            class: 'half-screen',
                        });
                        divT.append(mapView);
                        divT.insertAfter('#mapOutDiv');
                        initiateSplitMap(2, withInputBox);
                    }

                }
                else if (numberOfSplit == 4)
                { // attempting to split into 4 screen
                    if (quarterScreenMap)
                    { // already at 4 screen
                        if (checkIfHaveHeader === withInputBox)
                        {
                            dialog('Failed', 'Map had been split.', 'alert');
                        }
                        else
                        {
                            if (withInputBox)
                            {
                                addInputBox(0, 4);
                            }
                        }
                    }
                    else if (halfScreenMap)
                    { // 2 screen change to 4 screen
                        fullMap.attr('class', 'quarter-screen');
                        $('#map1OutDiv').attr('class', 'quarter-screen');
                        map1.recentralize();
                        createMap(2);
                    }
                    else
                    { // 1 screen change to 4 screen
                        fullMap.attr('class', 'quarter-screen');
                        createMap(1);
                    }
                    function createMap(numberOfMap)
                    {
                        var previousMap = '#map1OutDiv';
                        if (numberOfMap == 1)
                        {
                            previousMap = '#mapOutDiv';
                        }
                        for (var i = numberOfMap; i < numberOfSplit; i++)
                        {
                            var divT = $('<div/>', {
                                id: 'map' + i + 'OutDiv',
                                class: 'quarter-screen',
                            });
                            var mapView = $('<div/>', {
                                id: 'map' + i + '-view',
                                onclick: 'toggleMapClass(this)',
                            });
                            divT.append(mapView);
                            divT.insertAfter(previousMap);
                            previousMap = '#map' + i + 'OutDiv';
                        }
                        if (numberOfMap == 1)
                        { //InitiateSplitMap(4) only initiate map2 and map3. map1 always need to be initiate by initiateSplitMap(2)
                            initiateSplitMap(2, withInputBox);
                        }
                        initiateSplitMap(4, withInputBox);
                    }
                }
                if (!withInputBox)
                { // when user choose without the InputBox, the system will check and remove the inputbox.
                    $('.full-screen').find('.mapInputBox').each(function()
                    {
                        $(this).remove();
                    });
                }
            }

            function initiateSplitMap(numberOfSplit, withInputBox)
            {
                if (numberOfSplit == 1)
                {
                    delete map1;
                    delete map2;
                    delete map3;
                    if (withInputBox)
                    {
                        addInputBox(0, 1);
                    }
                }
                else if (numberOfSplit == 2)
                {

                    map1 = new v3nityMap('map1-view', {clusterMaxZoom: <%=clusterMaxZoomOption%>});
                    map1.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
                    initOverlayMap(2);
                    addInputBox(0, 2);

                }
                else if (numberOfSplit == 4)
                {

                    map2 = new v3nityMap('map2-view', {clusterMaxZoom: <%=clusterMaxZoomOption%>});
                    map2.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});

                    map3 = new v3nityMap('map3-view', {clusterMaxZoom: <%=clusterMaxZoomOption%>});
                    map3.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
                    initOverlayMap(4);
                    addInputBox(2, 4);
                }
                map.recentralize(); // as when the map split screen, the diminesion of the map is smaller and but central remain the same. this function help to shift the central.

                function initOverlayMap(mapNumber)
                { // this is to input the overlay to all 3 map.

            <%
                if (overlays != null)
                {
                    for (int i = 0; i < overlays.size(); i++)
                    {
                        Data overlay = overlays.get(i);

            %>
                    var option = {url: '<%=overlay.getString("overlay_url")%>', minZoom: <%=overlay.getInt("min_zoom_level")%>, maxZoom: <%=overlay.getInt("max_zoom_level")%>};
                    if (mapNumber === 4)
                    {
                        map2.addOverlayLayer(option);
                        map3.addOverlayLayer(option);
                    }
                    else
                    {
                        map1.addOverlayLayer(option);
                    }

            <%
                    }
                }
            %>
                }

            }

            function checkNumberOfMap()
            {
                if (typeof map3 !== 'undefined')
                {
                    return 4;
                }
                else if (typeof map1 !== 'undefined')
                {
                    return 2;
                }
            }

            function zoomIn()
            {
                map.zoomIn();
                if (checkNumberOfMap() === 4)
                {
                    map1.zoomIn();
                    map2.zoomIn();
                    map3.zoomIn();
                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.zoomIn();
                }
            }
            function zoomOut()
            {
                map.zoomOut();
                if (checkNumberOfMap() === 4)
                {
                    map1.zoomOut();
                    map2.zoomOut();
                    map3.zoomOut();
                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.zoomOut();
                }
            }
            function zoomDefault()
            {
                map.zoomToDefault();
                if (checkNumberOfMap() === 4)
                {
                    map1.zoomToDefault();
                    map2.zoomToDefault();
                    map3.zoomToDefault();
                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.zoomToDefault();
                }
            }
            function changeBaseLayer(mapId)
            {
                map.changeBaseLayer(mapId)
                if (checkNumberOfMap() === 4)
                {
                    map1.changeBaseLayer(mapId)
                    map2.changeBaseLayer(mapId)
                    map3.changeBaseLayer(mapId)

                }
                else if (checkNumberOfMap() === 2)
                {
                    map1.changeBaseLayer(mapId)
                }
            }

            function onWebTraffic()
            {
                webTraffic = new WebTraffic();

            <% if (locale.getCountry().equals("SG"))
                {%>
                webTraffic.start();
            <% }%>
            }


            function toggleMapClass(thisId)
            {
                // disable as my method of doing 4 ajax refresh is causing huge lag
                if (checkNumberOfMap() !== undefined)
                {
                    $(thisId).parent().siblings().removeClass("selected");
                    $(thisId).parent().toggleClass("selected");
                    toggleLiveMenu(true);
                }
            }

            function openCameraDialog(url)
            {
                var dialog = $('#camera-dialog').data('dialog');

                dialog.options.onDialogClose = onCameraDialogClose;

                $('#camera-dialog-object').attr('src', url);

                dialog.open();
            }

            function onCameraDialogClose()
            {
                $('#camera-dialog-object').attr('src', '');
            }

            function openCameraHistoryDialog(id)
            {
                var dialog = $('#camera-history-dialog').data('dialog');

                $('#camera-history-dialog').attr('data-camera-id', id);

                dialog.open();
            }

            function requestCameraHistory()
            {
                var id = $('#camera-history-dialog').attr('data-camera-id');

                $.ajax({
                    type: 'GET',
                    url: 'https://videoserver1.tvg.cc:3001/api/jobs/newJob',
                    data: {
                        command: 'newRequest',
                        gatewayUID: id,
                        camera: 'cam1',
                        recordTime: document.getElementById('dateTimePicker-camera-history-record-date').value,
                        offset: -15,
                        duration: 20,
                        requestCode: 'jobs',
                        jobDescription: 'TestEvent'
                    },
                    beforeSend: function()
                    {
                    },
                    success: function(data)
                    {

                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                    },
                    async: false
                });
            }
            
            
            function loadHomePage()
            {
//                if ('${defaultPage}' !== 'none')
//                {
//                    load('${defaultPage}');
//                }
//                else
//                {
                    load('DashboardController');
//                }
            }
            
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
                div.style.left = (point.x - 8) + 'px';
                div.style.top = (point.y - 10) + 'px';
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

                default:
                    if (speed === 0)
                    {
                        div.style.backgroundImage = 'url("img/' + info.icons.marker_idling + '")';
                    }
                    else
                    {
                        div.style.backgroundImage = 'url("img/' + info.icons.marker_stop + '")';
                    }
            }

            div.style.position = 'absolute';

            div.style.cursor = 'pointer';
        }
        else
        {
            switch (info.type)
            {

               
                default:
                    if (speed === 0)
                    {
                        div.className = 'map-icon-marker small idling';
                    }
                    else
                    {
                        div.className = 'map-icon-marker small stop';
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

            setTimeout(function()
            {
                _infowindow.close()
            }, 5000);

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

        </script>
        <style type="text/css">

            .main-header {
                display: none !important;
            }

            .body {
                padding: 0;
                margin: 0;
            }

            .footer {
                display: none !important;
            }

        </style>
    </head>
    <body>
        <section>
            <div class="charm bottom-side padding0 fg-black" id="charmHistory" style="width: 100%; height: 140px; background-color: rgba(255, 255, 255, 0.0)">
                <div id="playback-slider"></div>
                <div id="playback-slider-control">
                    <div id="history-title" style="display: inline-block"></div>&emsp;
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-start-date" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="${inputStartDate}" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <span> - </span>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="dateTimePicker-history-end-date" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="${inputEndDate}" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <button class="button" onclick="historySearch()"><span class="mif-search"></span></button>&emsp;
                    <button class="button cycle-button" title="<%=userProperties.getLanguage("firstRecord")%>" onclick="historyPlayFirst()"><span class="mif-first"></span></button>
                    <button class="button cycle-button" title="<%=userProperties.getLanguage("previousRecord")%>" onclick="historyPlayPrevious()"><span class="mif-previous"></span></button>
                    <button class="button cycle-button" title="<%=userProperties.getLanguage("playback")%>" onclick="historyPlay()"><span class="mif-play"></span></button>
                    <button class="button cycle-button" title="<%=userProperties.getLanguage("pause")%>" onclick="historyPause()"><span class="mif-pause"></span></button>
                    <button class="button cycle-button" title="<%=userProperties.getLanguage("nextRecord")%>" onclick="historyPlayNext()"><span class="mif-next"></span></button>
                    <button class="button cycle-button" title="<%=userProperties.getLanguage("lastRecord")%>" onclick="historyPlayLast()"><span class="mif-last"></span></button>
                </div>
            </div>
            <div class="charm left-side padding10 v3-bg-blue" id="charmLive" style="width: 320px; height: auto;">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleLiveMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light"><%=userProperties.getLanguage("lastLocation")%></h1>
                <div class="content padding10 bg-white" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%;">
                    
                    
                    <% assetTreeView.outputHTML(out, userProperties);%>
                </div>
            </div>
            <div class="charm left-side padding10 v3-bg-darkerGray shadow" id="charmMapSettings" style="width: 320px">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleMapSettingsMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light"><%=userProperties.getLanguage("settings")%></h1>
                <div class="content padding10 v3-bg-darkerGray" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto">
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("traffic")%></span>
                        <label class="switch place-right">
                            <input id="checkboxTraffic" type="checkbox" onchange="toggleAddTraffic()">
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("trafficHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("historyLabel")%></span>
                        <label class="switch place-right">
                            <input id="checkboxHistoryLabel" type="checkbox" onchange="toggleEnableHistoryLabel()" checked>
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("historyLabelHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("autoRefresh")%></span>
                        <label class="switch place-right">
                            <input id="checkboxAutoRefresh" type="checkbox" onchange="toggleAutoRefresh()" checked>
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("autoRefreshHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("autoZoom")%></span>
                        <label class="switch place-right">
                            <input id="checkboxAutoZoom" type="checkbox" onchange="toggleAutoZoom()" checked>
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("autoZoomHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("trafficNews")%></span>
                        <label class="switch place-right">
                            <input id="checkboxTrafficNews" type="checkbox" onchange="toggleTrafficNews()" checked>
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("trafficNewsHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("toggleLabel")%></span>
                        <label class="switch place-right">
                            <input id="checkboxToggleLabel" type="checkbox" onchange="toggleLabel()" checked>
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("toggleLabelHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("limitLabelSize")%></span>
                        <label class="switch place-right">
                            <input id="checkboxLimitLabelSize" type="checkbox" onchange="toggleLabelSize()">
                            <span class="check"></span>
                        </label>
                        <h6 class="text-light"><%=userProperties.getLanguage("limitLabelSizeHint")%></h6>
                    </div>
                    <div class="setting-block">
                        <span class="sub-header"><%=userProperties.getLanguage("playbackSpeed")%></span>
                        <h6 class="text-light"><%=userProperties.getLanguage("playbackSpeedHint")%></h6>
                        <span class="caption text-small place-left"><%=userProperties.getLanguage("slow")%></span>
                        <span class="caption text-small place-right"><%=userProperties.getLanguage("fast")%></span>
                        <br>
                        <div class="slider large"
                             data-on-change="playbackSpeedChanged"
                             data-role="slider"
                             data-max-value="10"
                             data-min-value="100"
                             data-accuracy="10"
                             data-position="30"
                             data-color="v3-bg-darkGray"
                             data-marker-color="bg-white"
                             data-complete-color="v3-bg-blue">
                        </div>
                    </div>
                </div>
            </div>
            <div class="charm left-side padding10 v3-bg-blue fg-white" id="charmSearch" style="width: 320px">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleSearchMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light"><%=userProperties.getLanguage("search")%></h1>
                <div class="content padding10 bg-white" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto;">
                    <div id="locationSearch" class="input-control text full-size" data-role="input">
                        <input id="locationText" type="text" size="50" placeholder="<%=userProperties.getLanguage("search")%>">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div id="matches-address"></div>
                    <div id="results-address" class="content" style="color: #fff; position: absolute; top: 0; bottom: 0; margin: 168px 0 8px 0; width: 300px; overflow-y: auto"></div>
                </div>
            </div>
            <div class="charm left-side padding10 v3-bg-blue" id="charmGeoFence" style="width: 320px">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleGeoFenceMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light"><%=userProperties.getLanguage("geoFence")%></h1>
                <div class="content padding10 bg-white fg-black" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto">
                    <div id="geofence-search">
                        <h4 class="text-light"><%=userProperties.getLanguage("tols")%></h4>
                        <div class="toolbar">
                            <div class="toolbar-section">
                                <%
                                    if (canAddGeofence)
                                    {
                                %>
                                <button class="toolbar-button" id="tool-button-start" name="start" value="" title="<%=userProperties.getLanguage("start")%>" onclick="startDraw()"><span class="mif-pencil"></span></button>
                                <button class="toolbar-button" id="tool-button-cancel" name="cancel" value="" title="<%=userProperties.getLanguage("cancel")%>" onclick="cancelDraw()"><span class="mif-cancel"></span></button>
                                <button class="toolbar-button" id="tool-button-save" name="save" value="" title="<%=userProperties.getLanguage("save")%>" onclick="showAdd()"><span class="mif-floppy-disk"></span></button>
                                    <%
                                        }

                                        if (canDeleteGeofence)
                                        {
                                    %>
                                <button class="toolbar-button" id="tool-button-delete" name="delete" value="" title="<%=userProperties.getLanguage("delete")%>" onclick="deleteGeoFence(getTreeId('tree-view-geofence', 'geofence-id'))"><span class="mif-bin"></span></button>
                                    <%
                                        }
                                    %>

                            </div>
                        </div>
                        <br>
                        <h4 class="text-light"><%=userProperties.getLanguage("manage")%></h4>
                        <% geoFenceTreeView.outputHTML(out, userProperties);%>
                    </div>
                </div>
            </div>
            <div class="charm left-side padding10 v3-bg-blue" id="charmRoute" style="width: 320px">
                <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleRouteDeviationMenu()"><span class="mif-cross"></span></button>
                <h1 class="text-light"><%=userProperties.getLanguage("route")%></h1>
                <div class="content padding10 bg-white fg-black" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto">
                    <div id="geofence-search">
                        <h4 class="text-light"><%=userProperties.getLanguage("tools")%></h4>
                        <div class="toolbar">
                            <div class="toolbar-section">
                                <%
                                    if (canAddRoute)
                                    {
                                %>
                                <button class="toolbar-button" id="tool-button-start" name="start" value="" title="<%=userProperties.getLanguage("start")%>" onclick="startDrawPolyline()"><span class="mif-pencil"></span></button>
                                <button class="toolbar-button" id="tool-button-stop" name="stop" value="" title="<%=userProperties.getLanguage("stop")%>" onclick="stopDrawPolyline()"><span class="mif-checkmark"></span></button>
                                <button class="toolbar-button" id="tool-button-cancel" name="cancel" value="" title="<%=userProperties.getLanguage("cancel")%>" onclick="cancelDrawPolyline()"><span class="mif-cancel"></span></button>
                                <button class="toolbar-button" id="tool-button-save" name="save" value="" title="<%=userProperties.getLanguage("save")%>" onclick="showAddRoute()"><span class="mif-floppy-disk"></span></button>
                                    <%
                                        }

                                        if (canDeleteRoute)
                                        {
                                    %>
                                <button class="toolbar-button" id="tool-button-delete" name="delete" value="" title="<%=userProperties.getLanguage("delete")%>" onclick="deleteRoute(getTreeId('tree-view-route', 'route-id'))"><span class="mif-bin"></span></button>
                                    <%
                                        }
                                    %>
                            </div>
                        </div>
                        <br>
                        <h4 class="text-light"><%=userProperties.getLanguage("manage")%></h4>
                        <% routeDeviationTreeView.outputHTML(out, userProperties);%>
                    </div>
                </div>
            </div>
        </section>
        <div class="charm left-side padding10 v3-bg-blue" id="charmJob" style="width: 320px">
            <button class="square-button bg-transparent fg-white no-border place-right small-button" onclick="toggleJobMenu()"><span class="mif-cross"></span></button>
            <h1 class="text-light"><%=userProperties.getLanguage("job")%></h1>
            <div class="content padding10 bg-white fg-black" style="position: absolute; top: 0; bottom: 0; left: 0px; margin: 84px 0 0 0; width: 100%; overflow-y: auto">
                <div id="geofence-search">
                    <h4 class="text-light"><%=userProperties.getLanguage("tools")%></h4>
                    <div class="toolbar">
                        <div class="toolbar-section">
                            <button class="toolbar-button" id="tool-button-search-job" name="search-job" value="" title="<%=userProperties.getLanguage("search")%>" onclick="searchJob()"><span class="mif-search"></span></button>
                        </div>
                    </div>
                    <br>
                    <h4 class="text-light"><%=userProperties.getLanguage("filter")%></h4>

                    <div id="job-list"></div>
                </div>
            </div>
        </div>
        <section class="full-screen" style="background-color:black;">
            <div id="mapOutDiv" class="full-screen">
                <div id="map-view" class="full-screen" onclick="toggleMapClass(this)"></div>
            </div>
            <div id="map-tooltip" class="map-tooltip"></div>
            <ul class="t-menu compact" style="position: fixed; top: 48px; left: 8px;">
                <li><a href="#" onclick="loadHomePage()" title="<%=userProperties.getLanguage("home")%>"><span class="icon mif-home"></span></a></li>
                <li><a href="#" onclick="toggleLiveMenu()" title="<%=userProperties.getLanguage("lastLocation")%>"><span class="icon mif-satellite"></span></a></li>
                <!--<li><a href="#" onclick="toggleJobMenu()" title="<%=userProperties.getLanguage("job")%>"><span class="icon mif-suitcase"></span></a></li>-->
                <%
                    if (canViewGeofence)
                    {
                %>
                <li><a href="#" onclick="toggleGeoFenceMenu()" title="<%=userProperties.getLanguage("geoFence")%>"><span class="icon mif-layers"></span></a></li>
                        <%
                            }

                            if (canViewRoute)
                            {
                        %>
                <li><a href="#" onclick="toggleRouteDeviationMenu()" title="<%=userProperties.getLanguage("route")%>"><span class="icon mif-looks"></span></a></li>
                        <%
                            }
                        %>
                <li><a href="#" onclick="toggleSearchMenu()" title="<%=userProperties.getLanguage("search")%>"><span class="icon mif-search"></span></a></li>
                <li><a href="#" onclick="toggleMapSettingsMenu()" title="<%=userProperties.getLanguage("mapSettings")%>"><span class="icon mif-cog"></span></a></li>
                <li><a href="#" title="<%=userProperties.getLanguage("changeMap")%>" class="dropdown-toggle"><span class="icon mif-map"></span></a>
                    <ul class="t-menu horizontal compact" data-role="dropdown">
                        <%
                            if (layerOption.charAt(0) == '1')
                            {
                        %>
                        <li><a href="#" onclick="changeBaseLayer(1)"><h6><%=userProperties.getLanguage("normal")%></h6></a></li>
                                    <%
                                        }

                                        if (layerOption.charAt(1) == '1')
                                        {
                                    %>
                        <li><a href="#" onclick="changeBaseLayer(2)"><h6><%=userProperties.getLanguage("terrain")%></h6></a></li>
                                    <%
                                        }

                                        if (layerOption.charAt(2) == '1')
                                        {
                                    %>
                        <li><a href="#" onclick="changeBaseLayer(3)"><h6><%=userProperties.getLanguage("satellite")%></h6></a></li>
                                    <%
                                        }

                                        if (layerOption.charAt(3) == '1')
                                        {
                                    %>
                        <li><a href="#" onclick="changeBaseLayer(4)"><h6><%=userProperties.getLanguage("hybrid")%></h6></a></li>
                                    <%
                                        }
                                    %>
                    </ul>
                </li>
                <li><a href="#" title="<%=userProperties.getLanguage("splitMap")%>" class="dropdown-toggle"><span class="icon mif-map2"></span></a>
                    <!--                    <ul class="t-menu compact horizontal" data-role="dropdown" >
                                            <li ><a href="#" onclick="splitMap(1,true)" style="width:54px; text-align:center;"  ><h6>header</h6></a></li>
                                            <li><a href="#" onclick="splitMap(2, true)" style="width:54px; text-align:center;"><h6>header</h6></a></li>
                                            <li ><a href="#" onclick="splitMap(4, true)" style="width:54px; text-align:center;"><h6>header</h6></a></li>
                                        </ul>-->
                    <ul class="t-menu  compact horizontal" data-role="dropdown">
                        <li ><a href="#" onclick="splitMap(1, true)" style="width:54px; text-align:center;" ><h6>1 : 1</h6></a></li>
                        <li><a href="#" onclick="splitMap(2, true)" style="width:54px; text-align:center;"><h6>1 : 2</h6></a></li>
                        <li ><a href="#" onclick="splitMap(4, true)" style="width:54px; text-align:center;"><h6>2 : 2</h6></a></li>
                    </ul>
                </li>
            </ul>
            <script>
                map.changeBaseLayer(<%=defaultLayer%>);
            </script>
            <ul class="t-menu compact" style="position: fixed; top: 48px; right: 8px;">
                <li><a href="#" onclick="zoomIn();" title="<%=userProperties.getLanguage("zoomIn")%>"><span class="icon mif-plus"></span></a></li>
                <li><a href="#" onclick="zoomOut()" title="<%=userProperties.getLanguage("zoomOut")%>"><span class="icon mif-minus"></span></a></li>
                <li><a href="#" onclick="zoomDefault()" title="<%=userProperties.getLanguage("zoomDefault")%>"><span class="icon mif-target"></span></a></li>
            </ul>
            <%
                if (!legendOption.equals("000000"))
                {

            %>
<!--            10Sept-->
            <div class="legend-dialog" style="position: fixed; top: 412px; right: 8px;">
                <h5 class="text-light"><%=userProperties.getLanguage("legend")%></h5>
                <%
                    if (legendOption.charAt(0) == '1')
                    {
                %>
                <div><div class="map-icon-marker small nohover stop"></div><span class="text-small">busy</span></div>
                        <%
                            }

                            if (legendOption.charAt(1) == '1')
                            {
                        %>
                <div><div class="map-icon-marker small nohover idling"></div><span class="text-small">idle</span></div>
                        <%
                            }

                            if (legendOption.charAt(2) == '1')
                            {
                        %>
             
                        <%
                            }
                        %>
                        <%
                            }
                        %>
            </div>
             <%
                if (hasCustomizedLegend)
                {
                    int id = userProperties.getUser().getInt("customer_id");
                
                    String legendPath = userProperties.getSystemProperties().getAbsolutePath() + "\\Track\\custom\\legend_" + id + ".html";

                    File file = new File(legendPath);
                    
                    if (file.exists())
                    {
                        String legendUrl = "../Track/custom/legend_" + id + ".html";
            %>
             <div class="legend-dialog" style="position: fixed; top: 600px; right: 8px;">
                <h5 class="text-light"><%=userProperties.getLanguage("legend")%></h5>
                <jsp:include page="<%=legendUrl%>"/>
             </div>
             <%
                    }
                }
            %>

            <div id="dialog-geofence-count" class="geofence-dialog" style="position: fixed; top: 48px; right: 52px; display: none;">
                <table class="data-field-table">
                    <tr>
                        <td colspan="2">
                            <div class="data-field-cell"><span class="data-field title">Geofence</span><span class="data-field value" id="dialog-geofence-name"></span></div>
                        </td>
                        <td>
                            <div class="data-field-cell colspan2"><span class="data-field value" id="dialog-geofence-total"></span></div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <ul id="dialog-geofence-content" class="geofence-dialog-asset">

                            </ul>
                        </td>
                    </tr>
                </table>
                <button type="button" class="geofence-dialog-close-button" onclick="$('#dialog-geofence-count').hide();">x</button>
            </div>
        </section>
        <section>
            <div data-role="dialog" id="form-dialog" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
                <div class="form-dialog">
                    <h1 id="form-dialog-title" class="text-light"></h1>
                    <div class="form-dialog-content">
                        <form id="form-dialog-data" method="post" action="list.jsp" autocomplete="off">
                            <input type="hidden" name="geoFencePoints" id="geoFencePoints">
                            <div class="grid">
                                <%
                                    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

                                    try
                                    {
                                        dataHandler.setConnection(userProperties.getConnection());

                                        listForm.outputHtml(userProperties, new GeoFence(), dataHandler, out);
                                %>
                            </div>
                        </form>
                    </div>
                    <div class="form-dialog-control">
                        <button id="button-save" type="button" class="button primary" onclick="saveForm()"><%=userProperties.getLanguage("save")%></button>
                        <button id="button-cancel" type="button" class="button" onclick="closeForm()"><%=userProperties.getLanguage("cancel")%></button>
                    </div>
                </div>
            </div>
        </section>
        <section>
            <div data-role="dialog" id="form-dialog-polyline" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
                <div class="form-dialog">
                    <h1 id="form-dialog-title-polyline" class="text-light"></h1>
                    <div class="form-dialog-content">
                        <form id="form-dialog-data-polyline" method="post" action="list.jsp" autocomplete="off">
                            <input type="hidden" name="polylinePoints" id="polylinePoints">
                            <input type="hidden" name="waypoints" id="waypoints">
                            <div class="grid">
                                <%
                                        listForm.outputHtml(userProperties, new Route(), dataHandler, out);
                                    }
                                    catch (Exception e)
                                    {
                                        e.printStackTrace();
                                    }
                                    finally
                                    {
                                        dataHandler.closeConnection();
                                    }
                                %>
                            </div>
                        </form>
                    </div>
                    <div class="form-dialog-control">
                        <button id="button-save" type="button" class="button primary" onclick="saveFormRoute()"><%=userProperties.getLanguage("save")%></button>
                        <button id="button-cancel" type="button" class="button" onclick="closeForm()"><%=userProperties.getLanguage("cancel")%></button>
                    </div>
                </div>
            </div>
        </section>
        <% if (trafficScrollerBar.equals("1"))
            { %>
        <section class="map-marquee">
            <div id="traffic-feed" class="traffic-feed"></div>
        </section>
        <% }%>
        <section class="map-footer">
            <span>&#169; V3 Smart Technologies Pte. Ltd. Map Data SLA, GOOGLE</span>
        </section>
        <div data-role="dialog" id=camera-dialog class="medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <iframe id="camera-dialog-object" src="" style="width: 100%; height: 100%"></iframe>
        </div>
        <div data-role="dialog" id=camera-history-dialog class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="input-control text" data-role="input">
                <span class="mif-calendar prepend-icon"></span>
                <input id="dateTimePicker-camera-history-record-date" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="${inputStartDate}" autocomplete="on">
                <button class="button helper-button clear"><span class="mif-cross"></span></button>
            </div>
            <button class="button" onclick="requestCameraHistory()"><span class="mif-zoom-in"></span></button>
        </div>
    </body>
</html>