/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

    $('head').append('<script data-main=\"js/v3nity-ocr.js\" src=\"js/require.min.js\"></script>');

    require.config({
        paths: {
            tesseract: 'OCR/ocr-tesseract'
        }
    });

    var Tesseract;

    requirejs(['tesseract'], function(){
        
        var rootPath = window.location.protocol + "//" + window.location.host + "/";
        if (window.location.hostname === "localhost")
        {
            var path = window.location.pathname;
            if (path.indexOf("/") === 0)
            {
                path = path.substring(1);
            }
            path = path.split("/", 1);
            if (path !== "")
            {
                rootPath = rootPath + path + "/";
            }
        }

        Tesseract = require('tesseract');
        
        window.Tesseract = Tesseract.create({
            workerPath: rootPath + 'js/OCR/ocr-worker.js',
            langPath: rootPath + 'js/OCR/ocr-lang.js-',
            corePath: rootPath + 'js/OCR/ocr-core.js'
        });

    });
 
    /*
     * Input Parameters:
     * imgData: base64 of an image
     * options:
     * binThreshold: threshold used for binarisation filter 
     *            (default will be automatically calculated) 
     *            (null to skip filter)
     * accThreshold: min accuracy of each sentence for it to be considered a result 
     *            (default is 70)
     * minX, minY: top left corner of bounding box 
     *            (default is 0,0)
     * maxX, maxY: bottom right corner of bounding box 
     *            (default is max image size)
     * 
     * 
     * Output:
     * Create function ocrResults(data)
     * data: the result array with each element containing:
     *      .text - the ocr text string
     *      .accuracy - the confidence value of the string
     */
    
    var OCR = function()
    {
                    
        var RED_INTENCITY_COEF = 0.2126;
        var GREEN_INTENCITY_COEF = 0.7152;
        var BLUE_INTENCITY_COEF = 0.0722;
        
        var _this = {
            
            convertImgToText: function(imgData, options)
            {
                var binThreshold = options.binThreshold;
                var accThreshold = options.accThreshold;
                var minX = options.minX;
                var minY = options.minY;
                var maxX = options.maxX;
                var maxY = options.maxY;
                
                if (typeof accThreshold === "undefined"){
                    accThreshold = 70;
                }

                var img = new Image();

        //        var canvas = document.createElement('canvas');
                var canvas = document.getElementById('canvas');

                var ctx = canvas.getContext('2d');

                if (typeof minX !== "undefined" ||
                    typeof minY !== "undefined" ||
                    typeof maxX !== "undefined" ||
                    typeof maxY !== "undefined"){

                    /*
                     * drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
                     * sx, sy: source image top left corner
                     * sWidth, sHeight: source image width and height
                     * dx, dy: canvas image top left corner position
                     * dWidth, dHeight: image on canvas width and height (scaled)
                     */
                    var width = maxX-minX;

                    var height = maxY-minY;

                    canvas.height = height;

                    canvas.width = width;

                    img.onload = function() {

                        //ctx here should be of type CanvasRenderingContext2D
                        ctx.drawImage(img, minX, minY, width, height, 0, 0, width, height);

                         if (typeof binThreshold === "undefined"){

                            var histogram = _this.hist(ctx, width, height);

                            var threshold = _this.thres(histogram, width*height);

                            var filCtx = _this.binarize(threshold, ctx, width, height);
                            
                            _this.recognizeFile(filCtx, accThreshold);

                        } else if (binThreshold === null){

                            _this.recognizeFile(ctx, accThreshold);

                        } else {

                            var filCtx = _this.binarize(binThreshold, ctx, width, height);
                            
                            _this.recognizeFile(filCtx, accThreshold);
                        }
                    };
                    
                } else {

                img.onload = function() {

                        var width = img.naturalWidth;

                        var height = img.naturalHeight;

                        canvas.height = height;

                        canvas.width = width;

                        //ctx here should be of type CanvasRenderingContext2D
                        ctx.drawImage(img, 0, 0, width, height);

                        if (typeof binThreshold === "undefined"){

                            var histogram = _this.hist(ctx, width, height);

                            var threshold = _this.thres(histogram, width*height);

                            var filCtx = _this.binarize(threshold, ctx, width, height);

                            _this.recognizeFile(filCtx, accThreshold);

                        } else if (binThreshold === null){

                            _this.recognizeFile(ctx, accThreshold);

                        } else {

                            var filCtx = _this.binarize(binThreshold, ctx, width, height);

                            _this.recognizeFile(filCtx, accThreshold);
                        }
                    };
                }
                img.src = imgData;
                
            },
            hist: function(context, w, h)
            {
               /*
                * Get the image histogram based on brightness of each pixel
                */
               var imageData = context.getImageData(0, 0, w, h);
               var data = imageData.data;
               var brightness;
               var brightness256Val;
               var histArray = Array.apply(null, new Array(256)).map(Number.prototype.valueOf,0);

               for (var i = 0; i < data.length; i += 4) {
                   brightness = RED_INTENCITY_COEF * data[i] + GREEN_INTENCITY_COEF * data[i + 1] + BLUE_INTENCITY_COEF * data[i + 2];
                   brightness256Val = Math.floor(brightness);
                   histArray[brightness256Val] += 1;
               }

               return histArray;
            },
            thres: function(histogram, total)
            {
                /*
                 * Automatically determine the threshold based on an average of the histogram
                 */
                var sum = 0;
                for (var i = 1; i < 256; ++i)
                    sum += i * histogram[i];
                var sumB = 0;
                var wB = 0;
                var wF = 0;
                var mB;
                var mF;
                var max = 0.0;
                var between = 0.0;
                var threshold1 = 0.0;
                var threshold2 = 0.0;
                for (var i = 0; i < 256; ++i) {
                    wB += histogram[i];
                    if (wB == 0)
                        continue;
                    wF = total - wB;
                    if (wF == 0)
                        break;
                    sumB += i * histogram[i];
                    mB = sumB / wB;
                    mF = (sum - sumB) / wF;
                    between = wB * wF * Math.pow(mB - mF, 2);
                    if ( between >= max ) {
                        threshold1 = i;
                        if ( between > max ) {
                            threshold2 = i;
                        }
                        max = between;            
                    }
                }
                console.log("automatic threshold: " + ( threshold1 + threshold2 ) / 2.0);
                return ( threshold1 + threshold2 ) / 2.0;
            },
            binarize: function(threshold, context, w, h)
            {
               /*
                * If pixel brightness > threshold, assign 0
                * If pixel brightness < threshold, assign 1
                */
               var imageData = context.getImageData(0, 0, w, h);
               var data = imageData.data;
               var val;

               for(var i = 0; i < data.length; i += 4) {
                   var brightness = RED_INTENCITY_COEF * data[i] + GREEN_INTENCITY_COEF * data[i + 1] + BLUE_INTENCITY_COEF * data[i + 2];
                   val = ((brightness > threshold) ? 255 : 0);
                   data[i] = val;
                   data[i + 1] = val;
                   data[i + 2] = val;
               }

               /*
                * Display filtered image
                */
               var c = document.getElementById('filtered');
               c.width = w;
               c.height = h;
               var filCtx = c.getContext('2d');
               filCtx.putImageData(imageData, 0, 0);

               return filCtx;
            },
            progressUpdate: function(packet)
            {
                var log = document.getElementById('log');

                if(log.firstChild && log.firstChild.status === packet.status)
                {
                    if('progress' in packet)
                    {
                        var progress = log.firstChild.querySelector('progress');

                        progress.value = packet.progress;
                    }
                }
                else
                {
                    var line = document.createElement('div');

                    line.status = packet.status;

                    var status = document.createElement('div');

                    status.className = 'status';

                    status.appendChild(document.createTextNode(packet.status));

                    line.appendChild(status);

                    if('progress' in packet)
                    {
                        var progress = document.createElement('progress');

                        progress.value = packet.progress;

                        progress.max = 1;

                        line.appendChild(progress);
                    }
                    if(packet.status === 'done')
                    {
                        var pre = document.createElement('pre');

                        pre.appendChild(document.createTextNode(packet.data.text));

                        line.innerHTML = '';

                        line.appendChild(pre);
                    }
                    log.insertBefore(line, log.firstChild);
                }
            },
            recognizeFile: function(file, accThreshold)
            {
                var ocrArr = [];
        
                Tesseract.recognize(file, {
                    
                    //set default language english
                    lang: 'eng'
                })

                .progress(function(packet)
                {
                    if (packet.status === 'recognizing text')
                    {
                        _this.progressUpdate(packet);
                    }
                })

                .then(function(data)
                {
                    _this.progressUpdate({ status: 'done', data: data });

                    for (var i = 0; i < data.lines.length; i++)
                    {
                        if (data.lines[i].confidence >= accThreshold)
                        {
                            var obj = new Object();

                            obj.text = data.lines[i].text;

                            obj.accuracy = data.lines[i].confidence;

                            ocrArr.push(obj);
                        }
                    }

                    return ocrResults(ocrArr);
                });
            }
        };
        
        return _this;
    };