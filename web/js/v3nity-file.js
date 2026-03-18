/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

function FileLineStreamer() {

    var loopholeReader = new FileReader();
    var chunkReader = new FileReader();
    var delimiter = "\n".charCodeAt(0);

    var expectedChunkSize = 15000000; // Slice size to read
    var loopholeSize = 200;         // Slice size to search for line end

    var file = null;
    var fileSize;
    var loopholeStart;
    var loopholeEnd;
    var chunkStart;
    var chunkEnd;
    var lines;
    var thisForClosure = this;
    var handler;

    // Reading of loophole ended
    loopholeReader.onloadend = function (evt) {
        // Read error
        if (evt.target.readyState !== FileReader.DONE) {
            handler(null, new Error("Not able to read loophole (start: )"));
            return;
        }
        var view = new DataView(evt.target.result);

        var realLoopholeSize = loopholeEnd - loopholeStart;

        for (var i = realLoopholeSize - 1; i >= 0; i--) {
            if (view.getInt8(i) === delimiter) {
                chunkEnd = loopholeStart + i + 1;
                var blob = file.slice(chunkStart, chunkEnd);
                chunkReader.readAsText(blob);
                return;
            }
        }

        // No delimiter found, looking in the next loophole
        loopholeStart = loopholeEnd;
        loopholeEnd = Math.min(loopholeStart + loopholeSize, fileSize);
        thisForClosure.getNextBatch();
    };

    // Reading of chunk ended
    chunkReader.onloadend = function (evt) {
        // Read error
        if (evt.target.readyState !== FileReader.DONE) {
            handler(null, new Error("Not able to read loophole"));
            return;
        }

        lines = evt.target.result.split(/\r?\n/);
        // Remove last new line in the end of chunk
        if (lines.length > 0 && lines[lines.length - 1] === "") {
            lines.pop();
        }

        chunkStart = chunkEnd;
        chunkEnd = Math.min(chunkStart + expectedChunkSize, fileSize);
        loopholeStart = Math.min(chunkEnd, fileSize);
        loopholeEnd = Math.min(loopholeStart + loopholeSize, fileSize);

        thisForClosure.getNextBatch();
    };

    this.getProgress = function () {
        if (file === null)
            return 0;
        if (chunkStart === fileSize)
            return 100;
        return Math.round(100 * (chunkStart / fileSize));
    };

    // Public: open file for reading
    this.open = function (fileToOpen, linesProcessed) {
        file = fileToOpen;
        fileSize = file.size;
        loopholeStart = Math.min(expectedChunkSize, fileSize);
        loopholeEnd = Math.min(loopholeStart + loopholeSize, fileSize);
        chunkStart = 0;
        chunkEnd = 0;
        lines = null;
        handler = linesProcessed;
    };

    this.read = function (file) {
        var fileReader = new FileReader();
        fileReader.readAsDataURL(file);
        fileReader.onloadend = function (event) {
            fileData(fileReader.result);
        };
    };

    // Public: start getting new line async
    this.getNextBatch = function () {
        // File wasn't open
        if (file === null) {
            handler(null, new Error("You must open a file first"));
            return;
        }
        // Some lines available
        if (lines !== null) {
            var linesForClosure = lines;
            setTimeout(function () {
                handler(linesForClosure, null)
            }, 0);
            lines = null;
            return;
        }
        // End of File
        if (chunkStart === fileSize) {
            handler(null, null);
            return;
        }
        // File part bigger than expectedChunkSize is left
        if (loopholeStart < fileSize) {
            var blob = file.slice(loopholeStart, loopholeEnd);
            loopholeReader.readAsArrayBuffer(blob);
        }
        // All file can be read at once
        else {
            chunkEnd = fileSize;
            var blob = file.slice(chunkStart, fileSize);
            chunkReader.readAsText(blob);
        }
    };
}
;