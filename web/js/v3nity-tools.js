/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

function isInteger(n)
{
    return !isNaN(parseInt(n)) && isFinite(n);
}

function getCurrentTimestampByTimezone(timezone)
{
    var date = new Date();

    var utcDate = new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds(), date.getUTCMilliseconds());
    
    date = new Date(utcDate);

    var hours = Math.abs(timezone);

    var mins = 60 * (timezone - Math.floor(hours));

    if (timezone < 0)
    {

        hours *= -1;
        mins *= -1;
    }

    date.setHours(utcDate.getHours() + hours, utcDate.getMinutes() + mins);

    var timestamp = leftPad(date.getDate(), '00') + "/"
        + leftPad((date.getMonth() + 1), '00') + "/"
        + date.getFullYear() + " "
        + leftPad(date.getHours(), '00') + ":"
        + leftPad(date.getMinutes(), '00') + ":"
        + leftPad(date.getSeconds(), '00');
        
    return timestamp;
}

function getCurrentTimestamp()
{
    var date = new Date();

    var timestamp = leftPad(date.getDate(), '00') + "/"
        + leftPad((date.getMonth() + 1), '00') + "/"
        + date.getFullYear() + " "
        + leftPad(date.getHours(), '00') + ":"
        + leftPad(date.getMinutes(), '00') + ":"
        + leftPad(date.getSeconds(), '00');

    return timestamp;
}

function getRawTimestamp()
{
    var date = new Date();

    var timestamp =
        date.getFullYear() + '-' +
        leftPad((date.getMonth() + 1), '00') + '-' +
        leftPad(date.getDate(), '00') + ' ' +
        leftPad(date.getHours(), '00') +
        leftPad(date.getMinutes(), '00') +
        leftPad(date.getSeconds(), '00');

    return timestamp;
}

function leftPad(str, padding)
{
    return (padding + str).slice(-(padding.length));
}

function isMaxlength(obj)
{
    var mlength = obj.getAttribute ? parseInt(obj.getAttribute("maxlength")) : "";

    if (obj.getAttribute && obj.value.length > mlength)
    {
        obj.value = obj.value.substring(0, mlength);
    }
}

function loadJsCssFile(filename, filetype)
{
    if (filetype === "js")
    { //if filename is a external JavaScript file
        var fileref = document.createElement('script');
        fileref.setAttribute("type", "text/javascript");
        fileref.setAttribute("src", filename);
    }
    else if (filetype === "css")
    { //if filename is an external CSS file
        var fileref = document.createElement("link");
        fileref.setAttribute("rel", "stylesheet");
        fileref.setAttribute("type", "text/css");
        fileref.setAttribute("href", filename);
    }
    if (typeof fileref !== "undefined")
        document.getElementsByTagName("head")[0].appendChild(fileref);
}

function escapeTags(str)
{
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function resizeImage(url, width, height, quality, callback)
{

    var sourceImage = document.createElement("img");

    sourceImage.onload = function()
    {

        // create a canvas with the desired dimensions...
        var canvas = document.createElement("canvas");

        var scale;

        if (sourceImage.width > sourceImage.height) // it means landscape...
        {
            scale = width / sourceImage.width;
        }
        else
        {
            scale = height / sourceImage.height;
        }

        if (scale > 1.0)    // only scale if bigger than specified size...
        {
            scale = 1.0;
        }

        canvas.width = sourceImage.width * scale;

        canvas.height = sourceImage.height * scale;

        var context = canvas.getContext("2d");

        context.fillStyle = '#fff';

        context.fillRect(0, 0, canvas.width, canvas.height);

        // scale and draw the source image to the canvas...
        context.drawImage(sourceImage, 0, 0, canvas.width, canvas.height);

        // convert the canvas to a data URL in PNG format...
        callback(canvas.toDataURL('image/jpeg', quality));

        // remove the element...
        sourceImage.remove();
    };

    sourceImage.src = url;
}


function resizeImageCamera(url, quality, callback)
{

    var sourceImage = document.createElement("img");

    sourceImage.onload = function()
    {

        // create a canvas with the desired dimensions...
        var canvas = document.createElement("canvas");
        var maxWidth, maxHeight;

        // resize image to be 400 x 300 or 300 x 400 depending if the uploaded image is landscape or portrait at the start
        if (sourceImage.width > sourceImage.height)
        { // check landscape
            maxWidth = 400;
            maxHeight = 300;
            if (sourceImage.width > maxWidth)
            {
                canvas.height *= maxWidth / sourceImage.width;
                sourceImage.width = maxWidth;
            }
        }
        else
        {
            maxHeight = 400;
            maxWidth = 300;
            if (sourceImage.height > maxHeight)
            {
                canvas.width *= maxHeight / sourceImage.height;
                sourceImage.height = maxHeight;
            }
        }

        canvas.width = maxWidth;

        canvas.height = maxHeight;

        var context = canvas.getContext("2d");

        context.fillStyle = '#fff';

        context.fillRect(0, 0, canvas.width, canvas.height);

        // scale and draw the source image to the canvas...
        context.drawImage(sourceImage, 0, 0, canvas.width, canvas.height);

        // convert the canvas to a data URL in PNG format...
        callback(canvas.toDataURL('image/jpeg', quality));

        // remove the element...
        sourceImage.remove();
    };

    sourceImage.src = url;
}

function resizeImageCameraOld(url, quality, callback)
{
    var sourceImage = document.createElement("img");

    sourceImage.onload = function()
    {

        // create a canvas with the desired dimensions...
        var canvas = document.createElement("canvas");

        canvas.width = sourceImage.width;

        canvas.height = sourceImage.height;

        var context = canvas.getContext("2d");

        context.fillStyle = '#fff';

        context.fillRect(0, 0, canvas.width, canvas.height);

        // scale and draw the source image to the canvas...
        context.drawImage(sourceImage, 0, 0, canvas.width, canvas.height);

        // convert the canvas to a data URL in PNG format...
        callback(canvas.toDataURL('image/jpeg', quality));

        // remove the element...
        sourceImage.remove();
    };

    sourceImage.src = url;
}

function validateNumberEventListener(event)
{

    var key = window.event ? event.keyCode : event.which;

    if (event.keyCode === 8 || event.keyCode === 46 || event.keyCode === 37 || event.keyCode === 39)
    {
        return true;
    }
    else if (key < 48 || key > 57)
    {
        return false;
    }
    else
        return true;
}

var Base64 = {
// private property
    _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
// public method for encoding
    encode: function(input)
    {
        var output = "";
        var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
        var i = 0;

        input = Base64._utf8_encode(input);

        while (i < input.length)
        {

            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);

            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;

            if (isNaN(chr2))
            {
                enc3 = enc4 = 64;
            }
            else if (isNaN(chr3))
            {
                enc4 = 64;
            }

            output = output +
                Base64._keyStr.charAt(enc1) + Base64._keyStr.charAt(enc2) +
                Base64._keyStr.charAt(enc3) + Base64._keyStr.charAt(enc4);

        }

        return output;
    },
// public method for decoding
    decode: function(input)
    {
        var output = "";
        var chr1, chr2, chr3;
        var enc1, enc2, enc3, enc4;
        var i = 0;

        input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

        while (i < input.length)
        {

            enc1 = Base64._keyStr.indexOf(input.charAt(i++));
            enc2 = Base64._keyStr.indexOf(input.charAt(i++));
            enc3 = Base64._keyStr.indexOf(input.charAt(i++));
            enc4 = Base64._keyStr.indexOf(input.charAt(i++));

            chr1 = (enc1 << 2) | (enc2 >> 4);
            chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
            chr3 = ((enc3 & 3) << 6) | enc4;

            output = output + String.fromCharCode(chr1);

            if (enc3 != 64)
            {
                output = output + String.fromCharCode(chr2);
            }
            if (enc4 != 64)
            {
                output = output + String.fromCharCode(chr3);
            }

        }

        output = Base64._utf8_decode(output);

        return output;

    },
// private method for UTF-8 encoding
    _utf8_encode: function(string)
    {
        string = string.replace(/\r\n/g, "\n");
        var utftext = "";

        for (var n = 0; n < string.length; n++)
        {

            var c = string.charCodeAt(n);

            if (c < 128)
            {
                utftext += String.fromCharCode(c);
            }
            else if ((c > 127) && (c < 2048))
            {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else
            {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }

        }

        return utftext;
    },
// private method for UTF-8 decoding
    _utf8_decode: function(utftext)
    {
        var string = "";
        var i = 0;
        var c = c1 = c2 = 0;

        while (i < utftext.length)
        {

            c = utftext.charCodeAt(i);

            if (c < 128)
            {
                string += String.fromCharCode(c);
                i++;
            }
            else if ((c > 191) && (c < 224))
            {
                c2 = utftext.charCodeAt(i + 1);
                string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                i += 2;
            }
            else
            {
                c2 = utftext.charCodeAt(i + 1);
                c3 = utftext.charCodeAt(i + 2);
                string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                i += 3;
            }

        }
        return string;
    }
};

function getBrowser()
{

    if (!!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0)
    {
        return 'opera';
    }
    else if (typeof InstallTrigger !== 'undefined')
    {
        return 'firefox';
    }
    else if (Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0)
    {
        return 'safari';
    }
    else if (/*@cc_on!@*/false || !!document.documentMode)
    {
        return 'ie';
    }
    else if (!(/*@cc_on!@*/false || !!document.documentMode) && !!window.StyleMedia)
    {
        return 'edge';
    }
    else if (!!window.chrome && !!window.chrome.webstore)
    {
        return 'chrome';
    }
//    else if ((isChrome || isOpera) && !!window.CSS)
    else if ((!!window.chrome || !!window.opera ) && !!window.CSS)
    {
        return 'blink';
    }
}

function getMousePosition(el)
{
    var xPosition = 0;
    var yPosition = 0;

    while (el)
    {
        if (el.tagName === "BODY")
        {
            // deal with browser quirks with body/window/document and page scroll
            var xScrollPos = el.scrollLeft || document.documentElement.scrollLeft;
            var yScrollPos = el.scrollTop || document.documentElement.scrollTop;

            xPosition += (el.offsetLeft - xScrollPos + el.clientLeft);
            yPosition += (el.offsetTop - yScrollPos + el.clientTop);
        }
        else
        {
            xPosition += (el.offsetLeft - el.scrollLeft + el.clientLeft);
            yPosition += (el.offsetTop - el.scrollTop + el.clientTop);
        }

        el = el.offsetParent;
    }

    return {
        x: xPosition,
        y: yPosition
    };
}

function removeArrayDuplicates(arr)
{
    var seen = {};
    var arr2 = [];
    for (var i = 0; i < arr.length; i++)
    {
        if (!(arr[i] in seen))
        {
            arr2.push(arr[i]);
            seen[arr[i]] = true;
        }
    }
    return arr2;

}

function getBrightness(hexCode)
{
    // strip off any leading #
    hexCode = hexCode.replace('#', '');

    var c_r = parseInt(hexCode.substr(0, 2), 16);
    var c_g = parseInt(hexCode.substr(2, 2), 16);
    var c_b = parseInt(hexCode.substr(4, 2), 16);

    // returns brightness value from 0 to 255
    return ((c_r * 299) + (c_g * 587) + (c_b * 114)) / 1000;
}

function validatePasswordStrength(passwordElemId, indicatorElemId)
{

    var strength = document.getElementById(indicatorElemId);

    var strongRegex = new RegExp("^(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*\\W).*$", "g");
    var mediumRegex = new RegExp("^(?=.{7,})(((?=.*[A-Z])(?=.*[a-z]))|((?=.*[A-Z])(?=.*[0-9]))|((?=.*[a-z])(?=.*[0-9]))).*$", "g");
    var enoughRegex = new RegExp("(?=.{6,}).*", "g");

    var pwd = document.getElementById(passwordElemId);

    if (enoughRegex.test(pwd.value) === false)
    {
        strength.innerHTML = '<span class="password-strength very-weak">Strength: More Characters</span>';
    }
    else if (strongRegex.test(pwd.value))
    {
        strength.innerHTML = '<span class="password-strength strong">Strength: Strong</span>';
    }
    else if (mediumRegex.test(pwd.value))
    {
        strength.innerHTML = '<span class="password-strength medium">Strength: Medium</span>';
    }
    else
    {
        strength.innerHTML = '<span class="password-strength weak">Strength: Weak</span>';
    }
}

function searchSelectOption(inputElem, selectElemId)
{
    var filter, sel, opt;

    filter = inputElem.value.toUpperCase();

    sel = document.getElementById(selectElemId);

    opt = sel.getElementsByTagName("option");

    for (var i = 0; i < opt.length; i++)
    {
        if (opt[i].innerHTML.toUpperCase().indexOf(filter) > -1)
        {
            opt[i].style.display = "";
        }
        else
        {
            opt[i].style.display = "none";
        }
    }
}

function ellipsisText(text, length)
{
    if (text.length > length)
        return text.substring(0, length) + '...';
    else
        return text;
}