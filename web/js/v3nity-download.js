/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

function csvDownload(_url, _prefix) {
    var url = _url;
    var prefix = _prefix;
    var overall_count, fetch, page, current, xhr, timestamp, options;
    var timer;

    $('body').append('<div data-role="dialog" id="download-dialog" class="padding20" data-close-button="true" data-background="bg-lightOlive" data-color="fg-white" data-overlay="true" data-overlay-color="op-dark"><h1 id=download-dialog-title>File Download</h1><div id="download-dialog-files" class="download-dialog-file-container"></div><p id=download-dialog-text></p></div>');

    interval = function() {

        page = Math.ceil(overall_count / fetch);

        if (current < page) {
            var filename = prefix + '[' + timestamp + '][' + current + '].CSV';

            options.totalRecords = overall_count;

            options.start = current * fetch;

            options.length = fetch;

            options.requireOverallCount = true;

            xhr = $.ajax({
                type: 'POST',
                url: url,
                data: options,
                dataType: 'text',
                beforeSend: function() {
                    $('#download-dialog-text').html('Downloading ' + (current + 1) + ' of ' + page);
                },
                success: function(data, status, xhr) {

                    var contentType = xhr.getResponseHeader("content-type");

                    overall_count = xhr.getResponseHeader("record-count");  // custom header...
                    
                    if (contentType.indexOf('csv') > -1) {
                        var encodedUri = encodeURI(data);

                        // test on chrome, firefox and edge. Look like an alright fix.
                        var csvFile = new Blob(["\uFEFF" + data], {type: 'text/csv;charset=UTF-8', encoding:"UTF-8"});
                        var csv = document.createElement('a');
                        csv.download = filename;
                        csv.href = window.URL.createObjectURL(csvFile);
                        csv.className = "command-button bg-lightOlive fg-white";
                        csv.setAttribute("id","v3nity-download-link");
                        csv.dataset.downloadurl = [contentType, csv.download, csv.href].join(':');
                        $(csv).append('<span class="icon mif-file-text"></span>File ' + (current + 1) + '<small>click or right-click to save file</small>');
                        //var fileRef = $('<a/>', {id: 'v3nity-download-link', href: encodedUri, download: filename});

                        //$('body').append(fileRef);

                        // auto prompt for file save... works on chrome, firefox, ie
                        //$('#v3nity-download-link')[0].click();

                        /*
                         *  DOES NOT WORK FOR MICROSOFT EDGE...
                         */

                        //$('#v3nity-download-link').remove();

                        if (getBrowser() === 'edge' || getBrowser() === 'ie') {
                            $('#download-dialog-files').append(csv);
                            //$('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="#" onclick="openDownload(\'' + encodedUri + '\', \'' + filename + '\');"><span class="icon mif-file-text"></span>File ' + (current + 1) + '<small>click to open file</small></a>');
                        }
                        else {
                            
                            // use this to substitute the click event but need to refine the user interface...
                             $('#download-dialog-files').append(csv);
                            //$('#download-dialog-files').append('<span class="icon mif-file-text"></span>File ' + (current + 1) + '<small>click or right-click to save file</small></a>');
                        }

                        current++;

                        timer = setTimeout(interval, 2000);
                    }

                    if (contentType.indexOf('json') > -1) {

                        data = JSON.parse(data);

                        if (data.expired === undefined) {
                            if (data.result === false) {
                                $('#download-dialog-files').append(data.text);
                            }
                        }
                        else {
                            $('#download-dialog-files').append('Session Expired! Please login again.');
                        }
                    }
                },
                error: function() {
                    clearTimeout(timer);

                    $('#download-dialog-text').html('Download Error');
                },
                complete: function() {

                },
                async: true
            });
        }
        else {
            clearTimeout(timer);

            if (overall_count === 0) {
                $('#download-dialog-text').html('No Records to Download');
            }
            else {
                $('#download-dialog-text').html('Download Completed');
            }
        }
    };

    onDialogClose = function(dialog) {
        clearTimeout(timer);

        if (xhr !== undefined)
            xhr.abort();

        //$('#download-dialog').remove();
    };

    this.startDownload = function(_fetch, _options) {

        overall_count = 1;

        fetch = _fetch;

        options = {format: 'csv', draw: 0, totalRecords: 0, start: 0, length: 0};

        if (_options !== undefined) {
            jQuery.extend(options, _options);
        }

        current = 0;

        timestamp = getRawTimestamp();

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {
            dialog.open();
        }

        timer = setTimeout(interval, 1000);
    };

    this.stopDownload = function() {
        clearTimeout(timer);
    };
}


function inspectionDetailsCsvDownload(_url, _prefix) {
    var url = _url;
    var prefix = _prefix;
    var overall_count, fetch, page, current, xhr, timestamp, options;
    var timer;

    $('body').append('<div data-role="dialog" id="download-dialog" class="padding20" data-close-button="true" data-background="bg-lightOlive" data-color="fg-white" data-overlay="true" data-overlay-color="op-dark"><h1 id=download-dialog-title>File Download</h1><div id="download-dialog-files" class="download-dialog-file-container"></div><p id=download-dialog-text></p></div>');

    interval = function() {

        page = Math.ceil(overall_count / fetch);

        if (current < page) {
            var filename = prefix + '[' + timestamp + '][' + current + '].CSV';

            options.totalRecords = overall_count;

            options.start = current * fetch;

            options.length = fetch;

            options.requireOverallCount = true;

            xhr = $.ajax({
                type: 'POST',
                url: url,
                data: options,
                dataType: 'text',
                beforeSend: function() {
                    $('#download-dialog-text').html('Downloading ' + (current + 1) + ' of ' + page);
                },
                success: function(data, status, xhr) {

                    var contentType = xhr.getResponseHeader("content-type");

                    overall_count = xhr.getResponseHeader("record-count");  // custom header...
                    
                    if (contentType.indexOf('csv') > -1) {
                        var encodedUri = encodeURI(data);

                        // test on chrome, firefox and edge. Look like an alright fix.
                        var csvFile = new Blob(["\uFEFF" + data], {type: 'text/csv;charset=UTF-8', encoding:"UTF-8"});
                        var csv = document.createElement('a');
                        csv.download = filename;
                        csv.href = window.URL.createObjectURL(csvFile);
                        csv.className = "command-button bg-lightOlive fg-white";
                        csv.setAttribute("id","v3nity-download-link");
                        csv.dataset.downloadurl = [contentType, csv.download, csv.href].join(':');
                        $(csv).append('<span class="icon mif-file-text"></span>File ' + (current + 1) + '<small>click or right-click to save file</small>');
                        //var fileRef = $('<a/>', {id: 'v3nity-download-link', href: encodedUri, download: filename});

                        //$('body').append(fileRef);

                        // auto prompt for file save... works on chrome, firefox, ie
                        //$('#v3nity-download-link')[0].click();

                        /*
                         *  DOES NOT WORK FOR MICROSOFT EDGE...
                         */

                        //$('#v3nity-download-link').remove();

                        if (getBrowser() === 'edge' || getBrowser() === 'ie') {
                            $('#download-dialog-files').append(csv);
                            //$('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="#" onclick="openDownload(\'' + encodedUri + '\', \'' + filename + '\');"><span class="icon mif-file-text"></span>File ' + (current + 1) + '<small>click to open file</small></a>');
                        }
                        else {
                            
                            // use this to substitute the click event but need to refine the user interface...
                             $('#download-dialog-files').append(csv);
                            //$('#download-dialog-files').append('<span class="icon mif-file-text"></span>File ' + (current + 1) + '<small>click or right-click to save file</small></a>');
                        }

                        current++;

                        timer = setTimeout(interval, 2000);
                    }

                    if (contentType.indexOf('json') > -1) {

                        data = JSON.parse(data);

                        if (data.expired === undefined) {
                            if (data.result === false) {
                                $('#download-dialog-files').append(data.text);
                            }
                        }
                        else {
                            $('#download-dialog-files').append('Session Expired! Please login again.');
                        }
                    }
                },
                error: function() {
                    clearTimeout(timer);

                    $('#download-dialog-text').html('Download Error');
                },
                complete: function() {

                },
                async: true
            });
        }
        else {
            clearTimeout(timer);

            if (overall_count === 0) {
                $('#download-dialog-text').html('No Records to Download');
            }
            else {
                $('#download-dialog-text').html('Download Completed');
            }
        }
    };

    onDialogClose = function(dialog) {
        clearTimeout(timer);

        if (xhr !== undefined)
            xhr.abort();

        //$('#download-dialog').remove();
    };

    this.startDownload = function(_fetch, _options) {

        overall_count = 1;

        fetch = _fetch;

        options = {format: 'csv', draw: 0, totalRecords: 0, start: 0, length: 0};

        if (_options !== undefined) {
            jQuery.extend(options, _options);
        }

        current = 0;

        timestamp = getRawTimestamp();

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {
            dialog.open();
        }

        timer = setTimeout(interval, 1000);
    };

    this.stopDownload = function() {
        clearTimeout(timer);
    };
}

// this is mainly used by ms-edge as the <a> download feature is not working...
function openDownload(encodedUri, filename) {

    var data = decodeURI(encodedUri);

    // note that the front 28 characters which is the data format string appended from the returned result has to be stripped off in this case...
    var blob = new window.Blob([data.substring(28)], {type: 'text/csv, charset=UTF-8'});

    window.navigator.msSaveOrOpenBlob(blob, filename);
}

function pdfDownload(_prefix) {

    var prefix = _prefix;
    var overall_count, fetch, page, current, xhr, timestamp, options;
    var timer;
    var zip;

    if (document.getElementById('download-dialog')) {
        $('body').append('<div data-role="dialog" id="download-dialog" class="padding20" data-close-button="true" data-background="bg-lightOlive" data-color="fg-white" data-overlay="true" data-overlay-color="op-dark"><h1 id=download-dialog-title>File Download</h1><div id="download-dialog-files" class="download-dialog-file-container"></div><p id=download-dialog-text></p></div>');
    }

    intervals = function() {
        page = Math.ceil(overall_count / fetch);

        if (current < page) {
            options.totalRecords = overall_count;

            options.start = current * fetch;

            options.length = fetch;

            options.requireOverallCount = true;

            xhr = $.ajax({
                type: 'POST',
                url: 'JobScheduleListController?lib=v3nity.std.biz.data.plan&type=JobSchedule&format=id&action=view',
                data: options,
                beforeSend: function() {
                    $('#download-dialog-text').html('Downloading ' + (current + 1) + ' of ' + page);
                },
                success: function(data) {

                    if (data.expired === undefined) {
                        for (var i = 0; i < data.data.length; i++) {
                            var geotagCheck = "E";
                            var jobId = data.data[i];

                            if ($("#input-geotag-pdf-" + jobId + "").length > 0) {
                                if ($("#input-geotag-pdf-" + jobId + "").is(":checked")) {
                                    geotagCheck = "Y";
                                }
                                else {
                                    geotagCheck = "N";
                                }
                            }
//                            console.log(geotagCheck)

                            overall_count = data.recordsTotal;

                            var xhr = new XMLHttpRequest();

                            xhr.open('POST', 'JobScheduleController?type=plan&action=pdf&id=' + jobId + "&geotagCheck=" + geotagCheck, true);

                            xhr.responseType = 'arraybuffer';

                            xhr.onload = function(e) {
                                if (this.status === 200) {
                                    var pdfData = this.response
                                    $.ajax({
                                        type: 'POST',
                                        url: 'JobScheduleController',
                                        data: {
                                            type: 'system',
                                            lib: 'plan',
                                            action: 'pdfname',
                                            id: '' + jobId
                                        },
                                        beforeSend: function() {

                                        },
                                        success: function(data) {
                                            var filename = data.filename + '.PDF';
                                            zip.file(filename, pdfData, {binary: true});
                                            intervals();
                                        },
                                        error: function() {

                                        },
                                        complete: function() {

                                        },
                                        async: true
                                    });

                                    // 21 Sep change filename
                                    // var filename = prefix + '[' + timestamp + '][' + jobId + '].PDF';

                                    /*
                                     var blob = new Blob([this.response], {type: "application/pdf"});

                                     var link = document.createElement('a');

                                     link.addEventListener("click", function(){alert('hi');}, false);

                                     link.href = window.URL.createObjectURL(blob);

                                     link.download = filename;

                                     link.click();
                                     */

                                    // 21 Sep change filename
                                    // zip.file(filename, this.response, {binary: true});
                                    // interval();
//                                    timer = setTimeout(interval, 1); //Calls a function or executes a code snippet after specified delay.
                                    //it was previously put at after current++ which can be reason some of the pdf did not come out as it haven finish loading the request and it continue with another.
                                }
                            };

                            xhr.send();
                        }

                        current++;
                    }
                    else {
                        $('#download-dialog-files').append('Session Expired! Please login again.');
                    }
                },
                error: function() {
                    clearTimeout(timer);

                    $('#download-dialog-text').html('Download Error');
                },
                complete: function() {

                },
                async: true
            });
        }
        else {
            clearTimeout(timer);

            if (overall_count === 0) {
                $('#download-dialog-text').html('No Records to Download');
            }
            else {
                zip.generateAsync({type: "blob"})
                        .then(function(blob) {
                            $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                        });

                $('#download-dialog-text').html('Download Completed');
            }
        }
    };

    onDialogClose = function(dialog) {
        clearTimeout(timer);

        if (xhr !== undefined)
            xhr.abort();

        //$('#download-dialog').remove();
    };

    this.startDownload = function(_fetch, _options) {

        overall_count = 1;

        fetch = _fetch;

        options = {format: 'csv', draw: 0, totalRecords: 0, start: 0, length: 0};

        if (_options !== undefined) {
            jQuery.extend(options, _options);
        }

        current = 0;

        timestamp = getRawTimestamp();

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {
            dialog.open();
        }

        timer = setTimeout(intervals, 1000);

        zip = new JSZip();
    };

    this.stopDownload = function() {

        clearTimeout(timer);
    };

    this.download = function(ids, geotagCheckArray) {

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {

            dialog.open();
        }

        var xhr = new XMLHttpRequest();

        xhr.open('POST', 'JobScheduleController?type=plan&action=pdf&id=' + ids + "&geotagCheck=" + geotagCheckArray, true);

        xhr.responseType = 'arraybuffer';

        zip = new JSZip();

        xhr.onload = function(e) {
            if (this.status === 200) {
                var timestamp = getRawTimestamp();

                var filename = prefix + '[' + timestamp + '].PDF';

                zip.file(filename, this.response, {binary: true});

                zip.generateAsync({type: "blob"})
                        .then(function(blob) {
                            $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                        });

                $('#download-dialog-text').html('Download Completed');
            }
        };

        xhr.send();

    };

}


function sfaPdfDownload(_prefix) {

    var prefix = _prefix;
    var overall_count, fetch, page, current, xhr, timestamp, options;
    var timer;
    var zip;

    if (document.getElementById('download-dialog')) {
        $('body').append('<div data-role="dialog" id="download-dialog" class="padding20" data-close-button="true" data-background="bg-lightOlive" data-color="fg-white" data-overlay="true" data-overlay-color="op-dark"><h1 id=download-dialog-title>File Download</h1><div id="download-dialog-files" class="download-dialog-file-container"></div><p id=download-dialog-text></p></div>');
    }

    intervals = function() {
        page = Math.ceil(overall_count / fetch);

        if (current < page) {
            options.totalRecords = overall_count;

            options.start = current * fetch;

            options.length = fetch;

            options.requireOverallCount = true;

            xhr = $.ajax({
                type: 'POST',
                url: 'SFAListController?lib=v3nity.cust.biz.data&type=SFAJobSchedule&format=id&action=view',
                data: options,
                beforeSend: function() {
                    $('#download-dialog-text').html('Downloading ' + (current + 1) + ' of ' + page);
                },
                success: function(data) {

                    if (data.expired === undefined) {
                        for (var i = 0; i < data.data.length; i++) {
                            var geotagCheck = "E";
                            var jobId = data.data[i];

                            if ($("#input-geotag-pdf-" + jobId + "").length > 0) {
                                if ($("#input-geotag-pdf-" + jobId + "").is(":checked")) {
                                    geotagCheck = "Y";
                                }
                                else {
                                    geotagCheck = "N";
                                }
                            }
//                            console.log(geotagCheck)

                            overall_count = data.recordsTotal;

                            var xhr = new XMLHttpRequest();

                            xhr.open('POST', 'SFAJobScheduleController?type=plan&action=pdf&id=' + jobId + "&geotagCheck=" + geotagCheck, true);

                            xhr.responseType = 'arraybuffer';

                            xhr.onload = function(e) {
                                if (this.status === 200) {
                                    var pdfData = this.response
                                    $.ajax({
                                        type: 'POST',
                                        url: 'SFAJobScheduleController',
                                        data: {
                                            type: 'system',
                                            lib: 'plan',
                                            action: 'pdfname',
                                            id: '' + jobId
                                        },
                                        beforeSend: function() {

                                        },
                                        success: function(data) {
                                            var filename = data.filename + '.PDF';
                                            zip.file(filename, pdfData, {binary: true});
                                            intervals();
                                        },
                                        error: function() {

                                        },
                                        complete: function() {

                                        },
                                        async: true
                                    });

                                    // 21 Sep change filename
                                    // var filename = prefix + '[' + timestamp + '][' + jobId + '].PDF';

                                    /*
                                     var blob = new Blob([this.response], {type: "application/pdf"});

                                     var link = document.createElement('a');

                                     link.addEventListener("click", function(){alert('hi');}, false);

                                     link.href = window.URL.createObjectURL(blob);

                                     link.download = filename;

                                     link.click();
                                     */

                                    // 21 Sep change filename
                                    // zip.file(filename, this.response, {binary: true});
                                    // interval();
//                                    timer = setTimeout(interval, 1); //Calls a function or executes a code snippet after specified delay.
                                    //it was previously put at after current++ which can be reason some of the pdf did not come out as it haven finish loading the request and it continue with another.
                                }
                            };

                            xhr.send();
                        }

                        current++;
                    }
                    else {
                        $('#download-dialog-files').append('Session Expired! Please login again.');
                    }
                },
                error: function() {
                    clearTimeout(timer);

                    $('#download-dialog-text').html('Download Error');
                },
                complete: function() {

                },
                async: true
            });
        }
        else {
            clearTimeout(timer);

            if (overall_count === 0) {
                $('#download-dialog-text').html('No Records to Download');
            }
            else {
                zip.generateAsync({type: "blob"})
                        .then(function(blob) {
                            $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                        });

                $('#download-dialog-text').html('Download Completed');
            }
        }
    };

    onDialogClose = function(dialog) {
        clearTimeout(timer);

        if (xhr !== undefined)
            xhr.abort();

        //$('#download-dialog').remove();
    };

    this.startDownload = function(_fetch, _options) {

        overall_count = 1;

        fetch = _fetch;

        options = {format: 'csv', draw: 0, totalRecords: 0, start: 0, length: 0};

        if (_options !== undefined) {
            jQuery.extend(options, _options);
        }

        current = 0;

        timestamp = getRawTimestamp();

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {
            dialog.open();
        }

        timer = setTimeout(intervals, 1000);

        zip = new JSZip();
    };

    this.stopDownload = function() {

        clearTimeout(timer);
    };

    this.download = function(ids, geotagCheckArray) {

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {

            dialog.open();
        }

        var xhr = new XMLHttpRequest();

        xhr.open('POST', 'JobScheduleController?type=plan&action=pdf&id=' + ids + "&geotagCheck=" + geotagCheckArray, true);

        xhr.responseType = 'arraybuffer';

        zip = new JSZip();

        xhr.onload = function(e) {
            if (this.status === 200) {
                var timestamp = getRawTimestamp();

                var filename = prefix + '[' + timestamp + '].PDF';

                zip.file(filename, this.response, {binary: true});

                zip.generateAsync({type: "blob"})
                        .then(function(blob) {
                            $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                        });

                $('#download-dialog-text').html('Download Completed');
            }
        };

        xhr.send();

    };

}

function imgDownload(_prefix) {

    var prefix = _prefix;
    var overall_count, fetch, page, current, xhr, timestamp, options;
    var timer;
    var zip;

    if (document.getElementById('download-dialog')) {
        $('body').append('<div data-role="dialog" id="download-dialog" class="padding20" data-close-button="true" data-background="bg-lightOlive" data-color="fg-white" data-overlay="true" data-overlay-color="op-dark"><h1 id=download-dialog-title>File Download</h1><div id="download-dialog-files" class="download-dialog-file-container"></div><p id=download-dialog-text></p></div>');
    }

    onDialogClose = function(dialog) {
        clearTimeout(timer);

        if (xhr !== undefined)
            xhr.abort();

        //$('#download-dialog').remove();
    };

    this.download = function(id) {

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {

            dialog.open();
        }

        $.ajax({
            type: 'POST',
            url: 'JobScheduleController',
            data: {
                type: 'system',
                action: 'image',
                jobId: id
            },
            success: function(data) {
                imagePath = data.imagepath;
                imageNamePrefix = data.imagenameprefix;
                var loopImage = 0;
                var imageCount = 0;

                var timestamp = getRawTimestamp();

                if (imagePath != undefined) {
                    var zip = new JSZip();
                    for (var loopImage = 0; loopImage < imagePath.length; loopImage++) {
                        imageCount = loopImage + 1;
                        zip.file("picture_" + imageCount + "_" + imageNamePrefix[loopImage] + ".png", "\"" + imagePath[loopImage] + "\"", {base64: true});
                    }
                    zip.generateAsync({type: "blob"})
                            .then(function(blob) {
                                $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                            });

                    $('#download-dialog-text').html('Download Completed');
                }
                else {
                    $('#download-dialog-text').html('There are no pictures to be downloaded');
                }

            },
            error: function() {
                dialog('Error', 'System has encountered an error', 'alert');
            },
            complete: function() {

            },
            async: false
        });
    };

}

function imagePDFDownload(_prefix, type, controller) {

    var prefix = _prefix;
    var overall_count, fetch, page, current, xhr, timestamp, options;
    var timer;
    var zip;

    if (document.getElementById('download-dialog')) {
        $('body').append('<div data-role="dialog" id="download-dialog" class="padding20" data-close-button="true" data-background="bg-lightOlive" data-color="fg-white" data-overlay="true" data-overlay-color="op-dark"><h1 id=download-dialog-title>File Download</h1><div id="download-dialog-files" class="download-dialog-file-container"></div><p id=download-dialog-text></p></div>');
    }

    intervals = function() {
        page = Math.ceil(overall_count / fetch);

        if (current < page) {
            options.totalRecords = overall_count;

            options.start = current * fetch;

            options.length = fetch;

            options.requireOverallCount = true;

            xhr = $.ajax({
                type: 'POST',
                url: 'RamkyJobListController?lib=v3nity.cust.biz.data&type=' + type + '&format=id&action=view',
                data: options,
                beforeSend: function() {
                    $('#download-dialog-text').html('Downloading ' + (current + 1) + ' of ' + page);
                },
                success: function(data) {

                    if (data.expired === undefined) {
                        for (var i = 0; i < data.data.length; i++) {
//                            var geotagCheck = "E";
                            var jobId = data.data[i];

//                            if ($("#input-geotag-pdf-" + jobId + "").length > 0) {
//                                if ($("#input-geotag-pdf-" + jobId + "").is(":checked")) {
//                                    geotagCheck = "Y";
//                                }
//                                else {
//                                    geotagCheck = "N";
//                                }
//                            }
//                            console.log(geotagCheck)

                            overall_count = data.recordsTotal;

                            var xhr = new XMLHttpRequest();

                            xhr.open('POST', controller + '?type=plan&action=imagepdf&id=' + jobId, true);

                            xhr.responseType = 'arraybuffer';

                            xhr.onload = function(e) {
                                if (this.status === 200) {
                                    var pdfData = this.response
                                    $.ajax({
                                        type: 'POST',
                                        url: controller,
                                        data: {
                                            type: 'system',
                                            lib: 'plan',
                                            action: 'pdfname',
                                            id: '' + jobId
                                        },
                                        beforeSend: function() {

                                        },
                                        success: function(data) {
                                            var filename = data.filename + '.PDF';
                                            zip.file(filename, pdfData, {binary: true});
                                            intervals();
                                        },
                                        error: function() {

                                        },
                                        complete: function() {

                                        },
                                        async: true
                                    });

                                    // 21 Sep change filename
                                    // var filename = prefix + '[' + timestamp + '][' + jobId + '].PDF';

                                    /*
                                     var blob = new Blob([this.response], {type: "application/pdf"});

                                     var link = document.createElement('a');

                                     link.addEventListener("click", function(){alert('hi');}, false);

                                     link.href = window.URL.createObjectURL(blob);

                                     link.download = filename;

                                     link.click();
                                     */

                                    // 21 Sep change filename
                                    // zip.file(filename, this.response, {binary: true});
                                    // interval();
//                                    timer = setTimeout(interval, 1); //Calls a function or executes a code snippet after specified delay.
                                    //it was previously put at after current++ which can be reason some of the pdf did not come out as it haven finish loading the request and it continue with another.
                                }
                            };

                            xhr.send();
                        }

                        current++;
                    }
                    else {
                        $('#download-dialog-files').append('Session Expired! Please login again.');
                    }
                },
                error: function() {
                    clearTimeout(timer);

                    $('#download-dialog-text').html('Download Error');
                },
                complete: function() {

                },
                async: true
            });
        }
        else {
            clearTimeout(timer);

            if (overall_count === 0) {
                $('#download-dialog-text').html('No Records to Download');
            }
            else {
                zip.generateAsync({type: "blob"})
                        .then(function(blob) {
                            $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                        });

                $('#download-dialog-text').html('Download Completed');
            }
        }
    };

    onDialogClose = function(dialog) {
        clearTimeout(timer);

        if (xhr !== undefined)
            xhr.abort();

        //$('#download-dialog').remove();
    };

    this.startDownload = function(_fetch, _options) {

        overall_count = 1;

        fetch = _fetch;

        options = {format: 'csv', draw: 0, totalRecords: 0, start: 0, length: 0};

        if (_options !== undefined) {
            jQuery.extend(options, _options);
        }

        current = 0;

        timestamp = getRawTimestamp();

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {
            dialog.open();
        }

        timer = setTimeout(intervals, 1000);

        zip = new JSZip();
    };

    this.stopDownload = function() {

        clearTimeout(timer);
    };

    this.download = function(ids) {

        var parent = $('#download-dialog');

        var dialog = parent.data('dialog');

        // overwrite the dialogclose function in the metro.js
        dialog.options.onDialogClose = onDialogClose;

        $('#download-dialog-text').html('Please wait...');

        $('#download-dialog-files').html('');

        if (!dialog.element.data('opened')) {

            dialog.open();
        }

        var xhr = new XMLHttpRequest();

        xhr.open('POST', controller + '?type=plan&action=pdf&id=' + ids , true);

        xhr.responseType = 'arraybuffer';

        zip = new JSZip();

        xhr.onload = function(e) {
            if (this.status === 200) {
                var timestamp = getRawTimestamp();

                var filename = prefix + '[' + timestamp + '].PDF';

                zip.file(filename, this.response, {binary: true});

                zip.generateAsync({type: "blob"})
                        .then(function(blob) {
                            $('#download-dialog-files').append('<a id="v3nity-download-link" class="command-button bg-lightOlive fg-white" href="' + window.URL.createObjectURL(blob) + '" download="' + prefix + '[' + timestamp + ']' + '.ZIP' + '"><span class="icon mif-file-text"></span>File<small>click or right-click to save file</small></a>');
                        });

                $('#download-dialog-text').html('Download Completed');
            }
        };

        xhr.send();

    };

}