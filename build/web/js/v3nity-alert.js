/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

var WebAlert = function(options) {

    var _timer;
    
    var o = {interval: 20000, timezone: 0, sound: true};

    options = $.extend(o, options);

    var _this = {
        url: 'WebAlertController?type=system&action=getalert',
        getData: function() {

            $.ajax({
                type: 'POST',
                url: _this.url,
                data: {
                    type: _this.type,
                    filter: _this.filter
                },
                success: function(data) {

                    if (data.expired !== undefined) {

                    }
                    else {
                        for (var i = 0; i < data.alerts.length; i++) {

                            // alert sound...
                            document.getElementById('alert-sound').play();

                            // use metro ui...
                            $.Notify({
                                caption: 'Alert',
                                content: data.alerts[i].message,
                                icon: "<span class='mif-notification'></span>",
                                style: {background: '#338fc1', color: '#fff'},
                                timeout: 30000
                            });
                        }
                    }
                },
                error: function() {

                },
                complete: function() {

                    _timer = setTimeout(_this.getData, options.interval);
                },
                async: true
            });
        },
        dispose: function() {

            clearTimeout(_timer);
        },
        start: function() {

            _timer = setTimeout(_this.getData, 10000);
        }
    };

    /*
     * creates the audio element...
     */
//    if (options.sound === true)
//    {
//        var audioTag = document.createElement("audio");
//
//        audioTag.id = 'alert-sound';
//
//        audioTag.innerHTML = '<source src="snd/notification.mp3">';
//
//        document.body.appendChild(audioTag);
//
//    }

    if (options.sound === true)
    {
        var audioTag;
        $.ajax(
        {
            type: 'POST',
            url: 'WebAlertController?type=system&action=getNotificationSound', 
            data: {


            },
            beforeSend: function () {
            },
            success: function (data) 
            {  

                audioTag = document.createElement("audio");

                audioTag.id = 'alert-sound';

                if(data.alerts[0].notificationSound!=null)
                {
                   audioTag.innerHTML = '<source src="snd/'+data.alerts[0].notificationSound+'">'; 

                }

                else
                {
                   audioTag.innerHTML =  '<source src="snd/notification.mp3">';
                }

                document.body.appendChild(audioTag);
            },
            error: function () {
                dialog('Error', 'System has encountered an error', 'alert');
            },
            complete: function () {

            },
            async: true
        });
    }

    return _this;
};

var WebTraffic = function(options) {

    var _timer;

    var o = {interval: 300000, timezone: 0};

    options = $.extend(o, options);

    var $marquee = $('#traffic-feed');

    var _this = {
        url: 'WebAlertController?type=system&action=gettraffic',
        getData: function() {

            $.ajax({
                type: 'POST',
                url: _this.url,
                data: {
                    type: _this.type,
                    filter: _this.filter
                },
                success: function(data) {

                    if (data.expired !== undefined) {

                    }
                    else {
                        $marquee.marquee('destroy');

                        $marquee.html('');

                        _this.callbackRefresh();

                        for (var i = 0; i < data.alerts.length; i++) {
                            // use metro ui...
//                            $.Notify({
//                                caption: data.alerts[i].incident_type,
//                                content: data.alerts[i].description,
//                                icon: "<span class='mif-traffic-cone'></span>",
//                                style: {background: '#ffab4d', color: '#fff'},
//                                timeout: 30000
//                            });

                            var line = $('<span/>');

                            line.html(data.alerts[i].description);

                            $marquee.append(line);

                            _this.callbackTraffic(data.alerts[i]);
                        }

                        $marquee.bind('finished', _this.start);

                        $marquee.marquee({
                            //speed in milliseconds of the marquee
                            duration: 45000,
                            //gap in pixels between the tickers
                            gap: 32,
                            //time in milliseconds before the marquee will start animating
                            delayBeforeStart: 0,
                            //'left' or 'right'
                            direction: 'left',
                            //true or false - should the marquee be duplicated to show an effect of continues flow
                            duplicated: false
                        });

                        if (data.alerts.length === 0) {
                            _timer = setTimeout(_this.getData, 15000);
                        }
                    }
                },
                error: function() {

                },
                complete: function() {

                    //_timer = setTimeout(_this.getData, options.interval);
                },
                async: true
            });
        },
        dispose: function() {

            clearTimeout(_timer);

            $marquee.unbind('finished');
        },
        start: function() {

            _timer = setTimeout(_this.getData, 3000);
        },
        callbackRefresh: function()
        {

        },
        callbackTraffic: function(e)
        {
            return e;
        }
    };



    return _this;
};
