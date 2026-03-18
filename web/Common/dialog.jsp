<%--
    Document   : dialog
    Created on : Sep 15, 2015, 12:49:09 AM
    Author     : kevin
--%>

<%@page import="java.text.SimpleDateFormat"%>
<div data-role="dialog" id="dialog-box-default" data-hide="3000" class="padding20" data-close-button="true" style="z-index: 1100 !important;">
    <h1></h1>
    <p></p>
</div>
<div data-role="dialog" id="dialog-box-info" data-hide="3000" class="padding20" data-close-button="true" data-type='info' style="z-index: 1100 !important;">
    <h1></h1>
    <p></p>
</div>
<div data-role="dialog" id="dialog-box-success" data-hide="3000" class="padding20" data-close-button="true" data-type='success' style="z-index: 1100 !important;">
    <h1></h1>
    <p></p>
</div>
<div data-role="dialog" id="dialog-box-alert" data-hide="3000" class="padding20" data-close-button="true" data-type='alert' style="z-index: 1100 !important;">
    <h1></h1>
    <p></p>
</div>
<div data-role="dialog" id="dialog-box-warning" data-hide="3000" class="padding20" data-close-button="true" data-type='warning' style="z-index: 1100 !important;">
    <h1></h1>
    <p></p>
</div>
<div data-role="dialog" id="dialog-box-confirmation" class="padding20" data-type="confirmation" data-width="110%" data-height="110%" style="z-index: 1100 !important;">
    <h1></h1>
    <p></p>
    <button class="button"></button>
    <button class="button"></button>
</div>
<div data-role="dialog" id="dialog-box-version" class="small" data-type="version"  data-background="bg-white"  data-overlay="true" data-overlay-color="op-dark" style="z-index: 1100; display: none;">
    <div class="form-dialog">
        <h1 class="dialog-version-title text-light">Product Updates</h1>
        <div class="form-dialog-content">
            <div id="dialog-box-version-number" class="dialog-version-number text-light"></div>
            <div id="dialog-box-version-content" class="dialog-version-content text-light"></div>
        </div>
    </div>
    <div class="form-dialog-control">
        <button class="button place-left"></button>
        <button class="button place-right primary" ></button>
    </div>
</div>
<div data-role="dialog" id="map-dialog" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark" style="padding: 8px; z-index: 1100 !important;">
    <div class="map-dialog">
        <img id="map-dialog-image" src="" alt="">
    </div>
</div>
<div data-role="dialog" id="qr-dialog" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark" style="padding: 8px; z-index: 1101 !important;">
    <div class="qr-dialog">
        <div id="qr-dialog-image"></div>
        <h5 id="qr-dialog-text" class="center-text"></h5>
    </div>
</div>

<script type="text/javascript">
    $(document).on('keyup', function (e)
    {

        if (e.keyCode === 27)   // escape key...
        {
            var dialogs = $("div[data-role='dialog']");

            for (var i = dialogs.length - 1; i >= 0; i--)
            {
                var dialog = $(dialogs[i]).data('dialog');

                if (dialog.element.data('opened') && dialog.options.closeButton)
                {
                    dialog.close();

                    break;
                }
            }
        }
    });

    function confirmationDialogClose(type)
    {
        var confirmationParent = $('#dialog-box-' + type);

        var confirmationDialog = confirmationParent.data('dialog');

        confirmationDialog.close();

    }

    function dialog(title, body, type, button, onclick)
    {
        var parent = $('#dialog-box-' + type);

        var dialog = parent.data('dialog');

        parent.find('h1').html(title);

        parent.find('p').html(body);

        if (button !== null)
        {
            parent.find('button').eq(0).html(button);

            parent.find('button').eq(1).html("Cancel");

            parent.find('button').eq(0).attr('onclick', onclick);

            parent.find('button').eq(1).attr('onclick', "confirmationDialogClose('" + type + "')");

        }

        if (!dialog.element.data('opened'))
        {
            dialog.open();
        }
    }

    function openVersionDialog(number, content, onaccept)
    {
        var parent = $('#dialog-box-version');

        var dialog = parent.data('dialog');

        $('#dialog-box-version-number').html(number);

        $('#dialog-box-version-content').html(content);

        parent.find('button').eq(1).html("Got It");

        parent.find('button').eq(0).html("Remind Me Later");

        parent.find('button').eq(1).attr('onclick', onaccept);

        parent.find('button').eq(0).attr('onclick', "confirmationDialogClose('version')");

        if (!dialog.element.data('opened'))
        {
            dialog.open();
        }
    }

    function showMap(lon, lat, type)
    {
        if (type === undefined)
        {
            type = 'roadmap';
        }

        var dialog = $('#map-dialog').data('dialog');

        $('#map-dialog-image').attr('src', '');

        $('#map-dialog-image').attr('src', 'googleapi?type=map&action=static&lat=' + lat + '&lon=' + lon + '&maptype=' + type + '&zoom=17&width=500&height=500');

        dialog.open();
    }

    function closeMap()
    {
        var dialog = $('#map-dialog').data('dialog');

        dialog.close();
    }

    function showQR(code, text)
    {
        var dialog = $('#qr-dialog').data('dialog');

        $('#qr-dialog-image').html('');

        var qrcode = new QRCode('qr-dialog-image');

        qrcode.makeCode(code);

        $('#qr-dialog-text').html(text);

        dialog.open();
    }

    function closeQR()
    {
        var dialog = $('#map-dialog').data('dialog');

        dialog.close();
    }

</script>