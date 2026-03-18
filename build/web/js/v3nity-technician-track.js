/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

function v3nityLive(_url, _refreshCallback, _errorCallback, _refreshElapsed) {
    var url = _url;
    var refreshCallback = _refreshCallback;
    var errorCallback = _errorCallback;
    var refreshElapsed = _refreshElapsed;
    var count = 0;
    var maxCount = 5;
    var liveTimer;
    var intervalRefresh;

    var interval = function() {
        var assets = refreshElapsed();

        // ajax call needs to be in comma separated asset id...
        if (assets.length > 0) {

            var assetIdStr = assets.join(',');

            count++;

            $.ajax({
                type: 'POST',
                url: url,
                data: {
                    type: 'system',
                    action: 'last',
                    driverIdStr: assetIdStr
                },
                success: function(data) {
                    refreshCallback(data);
                },
                complete: function() {
                    count--;

                   // liveTimer = setTimeout(interval, intervalRefresh);
                },
                async: true
            });
        }
    };

    this.refresh = function(assets) {
        // ajax call needs to be in comma separated asset id...
        if (assets.length > 0 && count <= maxCount) {

            var assetIdStr = assets.join(',');

            count++;

            $.ajax({
                type: 'POST',
                url: url,
                data: {
                    type: 'system',
                    action: 'last',
                    driverIdStr: assetIdStr
                },
                success: function(data) {
                    refreshCallback(data);
                },
                error: function() {
                    errorCallback();
                },
                complete: function() {
                    count--;
                },
                async: (count < maxCount)    // the last count is synchronous, prevents user from calling more...haha!!!
            });
        }
    };

    this.startRefresh = function(_interval) {
        if (liveTimer === undefined) {
            liveTimer = setInterval(interval, _interval);

            intervalRefresh = _interval;
        }
    };

    this.stopRefresh = function() {

        clearTimeout(liveTimer);

        liveTimer = undefined;
    };

    this.changeInterval = function(_interval) {

        intervalRefresh = _interval;
    };
}

function v3nityHistory(_url, _loadedCallback, _playbackElapsed) {
    var url = _url;
    var loadedCallback = _loadedCallback;
    var playbackElapsed = _playbackElapsed;
    var index = 0;
    var records = [];

    interval = function() {
        if (index >= records.length) {
            index = 0;
        }

        playbackElapsed(records[index], index);

        index++;
    };

    this.loadHistory = function(assetId, fromDate, toDate) {
        // ajax only allows 1 asset id...
        $.ajax({
            type: 'POST',
            url: url,
            data: {
                type: 'system',
                action: 'history',
                assetIdStr: assetId,
                fromDate: fromDate,
                toDate: toDate
            },
            success: function(data) {

                var feature;

                // you will expect only one asset...
                for (var asset in data.data) {
                    records = data.data[asset];
                }

                if (data.features.length > 0) {
                    feature = data.features[0];

                    for (var asset in feature) {
                        feature = feature[asset];
                    }
                }

                loadedCallback(records, feature);
            },
            complete: function() {

            },
            async: false
        });
    };

    this.getRecord = function(_index) {
        return records[_index];
    };

    this.getLastIndex = function() {
        return records.length - 1;
    };

    this.startPlayback = function(_start, _interval) {
        index = _start;
        this.historyTimer = setInterval(interval, _interval);
    };

    this.stopPlayback = function() {
        clearInterval(this.historyTimer);
    };
}

function v3nityGetGeoFence(callback, geoFenceId) {
    $.ajax({
        type: 'POST',
        url: 'MapController',
        data: {
            type: 'system',
            action: 'geofence',
            geoFenceIdStr: geoFenceId
        },
        success: function(data) {

            callback(data);
        },
        complete: function() {

        },
        async: false
    });
}


function v3nityGetRoute(callback, routeId) {
    $.ajax({
        type: 'POST',
        url: 'MapController',
        data: {
            type: 'system',
            action: 'route',
            routeIdStr: routeId
        },
        success: function(data) {

            callback(data);
        },
        complete: function() {

        },
        async: false
    });
}
