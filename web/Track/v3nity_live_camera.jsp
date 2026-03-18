<%--
    Document   : v3nity_live_camera
    Created on : 1 Dec, 2021, 6:40:31 PM
    Author     : Kevin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>v3nity live camera</title>
        <script type='text/javascript' src='js/sldp-v2.18.1.min.js'></script>
        <style>

            #v3nity-camera-dialog {
                /*right: 0 !important;*/
                height: 380px !important;
                width: 660px !important;
                /*margin: 0;*/
                left: 100% !important;
                margin-left: -670px;
            }

            #v3nity-camera-container {
                width: 100%;
                height: 100%;
                overflow-y: auto;
                padding: 8px;
            }

        </style>
        <script>

            var sldpPlayer;

            function initPlayer(serial)
            {
                sldpPlayer = SLDP.init({
                    container: 'v3nity-camera-container',
                    stream_url: "ws://203.125.7.40:8081/live/" + serial,
                    height: 360,
                    width: 640,
                    autoplay: true
                });
            }

            function removePlayer()
            {
                if (sldpPlayer !== undefined)
                {
                    sldpPlayer.destroy();
                }
            }

            function openV3nityCameraDialog(serial)
            {
                switchMode(0);

                onV3nityCameraDialogClose();

                var dialog = $('#v3nity-camera-dialog').data('dialog');

                dialog.options.onDialogClose = onV3nityCameraDialogClose;

                dialog.open();

                initPlayer(serial);
            }

            function onV3nityCameraDialogClose()
            {
                removePlayer();
            }

        </script>
    </head>
    <body>
        <div data-role="dialog" id=v3nity-camera-dialog class="medium" data-close-button="true" data-background="bg-black">
            <div id=v3nity-camera-container>

            </div>
        </div>
    </body>
</html>