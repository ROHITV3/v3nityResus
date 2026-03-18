<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    int userId = userProperties.getUser().getId();
%>
<html>
    <head>
        <meta charset="utf-8" />
        <title></title>
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/v3nity.css?v=${code}" rel="stylesheet">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <script src="js/metro.js"></script>
        <script type="text/javascript">
            $(document).ready(function ()
            {
                //initCanvas();
                getCreatorData();
            });
            function getCreatorData()
            {
                $.ajax({
                    type: 'POST',
                    url: 'QuotationCreatorSignatureTemplateController',
                    data: {
                        action: 'getSignature',
                        userId: '<%=userId%>'
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            $('input[name=creatorName]').val(data.name);
                            $('input[name=creatorDegsination]').val(data.designation);
                            initCanvas(data.signature);
                        } else {
                            initCanvas();
                        }
                    },
                    error: function ()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            }

            function addSignature(image)
            {
                if (image.length < 3100)
                {
                    alert('Please add signature');
                    return;
                }

                $.ajax({
                    type: 'POST',
                    url: 'QuotationCreatorSignatureTemplateController',
                    data: {
                        plan: 'plan',
                        action: 'insertSignature',
                        userId: '<%=userId%>',
                        img: image,
                        name: $('input[name=creatorName]').val(),
                        designation: $('input[name=creatorDegsination]').val()
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            alert('Signature Added');
                        }
                    },
                    error: function ()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            }


            var canvas;
            var ctx;
            var image;
            function initCanvas()
            {
                var canvasContainer = document.createElement('div');

                canvasContainer.setAttribute('id', 'canvas-container-test');

                document.getElementById('test').appendChild(canvasContainer);

                canvas = document.createElement('canvas');

                canvas.setAttribute('id', 'signature-canvas-test');

                canvas.setAttribute('style', 'border-width:1px; border-style:solid');

                canvasContainer.appendChild(canvas);

                ctx = canvas.getContext('2d');

                var sketch = document.getElementById('canvas-container-test');

                var sketch_style = getComputedStyle(sketch);

                canvas.width = 300;

                canvas.height = 200;

                var mouse = {x: 0, y: 0};

                canvas.addEventListener('mousemove', function (e) {
                    mouse.x = (e.pageX - this.offsetLeft) - 15;
                    mouse.y = (e.pageY - this.offsetTop) - 145;
                }, false);

                ctx.lineJoin = 'round';
                ctx.lineCap = 'round';
                ctx.strokeStyle = 'blue';

                canvas.addEventListener('mousedown', function (e) {
                    ctx.beginPath();
                    ctx.moveTo(mouse.x, mouse.y);
                    canvas.addEventListener('mousemove', onPaint, false);
                }, false);

                canvas.addEventListener('mouseup', function () {
                    canvas.removeEventListener('mousemove', onPaint, false);
                }, false);

                var onPaint = function () {
                    ctx.lineTo(mouse.x, mouse.y);
                    ctx.stroke();
                };



                // Set up touch events for mobile, etc
                canvas.addEventListener("touchstart", function (e) {
                    mouse = getTouchPos(canvas, e);
                    var touch = e.touches[0];
                    var mouseEvent = new MouseEvent("mousedown", {
                        clientX: touch.clientX,
                        clientY: touch.clientY
                    });
                    canvas.dispatchEvent(mouseEvent);
                }, false);
                canvas.addEventListener("touchend", function (e) {
                    var mouseEvent = new MouseEvent("mouseup", {});
                    canvas.dispatchEvent(mouseEvent);
                }, false);
                canvas.addEventListener("touchmove", function (e) {
                    var touch = e.touches[0];
                    var mouseEvent = new MouseEvent("mousemove", {
                        clientX: touch.clientX,
                        clientY: touch.clientY
                    });
                    canvas.dispatchEvent(mouseEvent);
                }, false);

                // Get the position of a touch relative to the canvas
                function getTouchPos(canvasDom, touchEvent) {
                    var rect = canvasDom.getBoundingClientRect();
                    return {
                        x: touchEvent.touches[0].clientX - rect.left,
                        y: touchEvent.touches[0].clientY - rect.top
                    };
                }

                // Prevent scrolling when touching the canvas
                document.body.addEventListener("touchstart", function (e) {
                    if (e.target == canvas) {
                        e.preventDefault();
                    }
                }, false);
                document.body.addEventListener("touchend", function (e) {
                    if (e.target == canvas) {
                        e.preventDefault();
                    }
                }, false);
                document.body.addEventListener("touchmove", function (e) {
                    if (e.target == canvas) {
                        e.preventDefault();
                    }
                }, false);
            }

            function initCanvas(imageBase64String)
            {
                var canvasContainer = document.createElement('div');

                canvasContainer.setAttribute('id', 'canvas-container-test');

                document.getElementById('test').appendChild(canvasContainer);

                canvas = document.createElement('canvas');

                canvas.setAttribute('id', 'signature-canvas-test');

                canvas.setAttribute('style', 'border-width:1px; border-style:solid');

                canvasContainer.appendChild(canvas);

                ctx = canvas.getContext('2d');

                var sketch = document.getElementById('canvas-container-test');

                var sketch_style = getComputedStyle(sketch);

                canvas.width = 300;

                canvas.height = 200;

                var mouse = {x: 0, y: 0};

                canvas.addEventListener('mousemove', function (e) {
                    mouse.x = (e.pageX - this.offsetLeft) - 15;
                    mouse.y = (e.pageY - this.offsetTop) - 145;
                }, false);

                ctx.lineJoin = 'round';
                ctx.lineCap = 'round';
                ctx.strokeStyle = 'blue';
                image = new Image();
                image.src = imageBase64String;
                image.onload = function () {
                    ctx.drawImage(image, 0, 0);
                };

                canvas.addEventListener('mousedown', function (e) {
                    ctx.beginPath();
                    ctx.moveTo(mouse.x, mouse.y);
                    canvas.addEventListener('mousemove', onPaint, false);
                }, false);

                canvas.addEventListener('mouseup', function () {
                    canvas.removeEventListener('mousemove', onPaint, false);
                }, false);

                var onPaint = function () {
                    ctx.lineTo(mouse.x, mouse.y);
                    ctx.stroke();
                };



                // Set up touch events for mobile, etc
                canvas.addEventListener("touchstart", function (e) {
                    mouse = getTouchPos(canvas, e);
                    var touch = e.touches[0];
                    var mouseEvent = new MouseEvent("mousedown", {
                        clientX: touch.clientX,
                        clientY: touch.clientY
                    });
                    canvas.dispatchEvent(mouseEvent);
                }, false);
                canvas.addEventListener("touchend", function (e) {
                    var mouseEvent = new MouseEvent("mouseup", {});
                    canvas.dispatchEvent(mouseEvent);
                }, false);
                canvas.addEventListener("touchmove", function (e) {
                    var touch = e.touches[0];
                    var mouseEvent = new MouseEvent("mousemove", {
                        clientX: touch.clientX,
                        clientY: touch.clientY
                    });
                    canvas.dispatchEvent(mouseEvent);
                }, false);

                // Get the position of a touch relative to the canvas
                function getTouchPos(canvasDom, touchEvent) {
                    var rect = canvasDom.getBoundingClientRect();
                    return {
                        x: touchEvent.touches[0].clientX - rect.left,
                        y: touchEvent.touches[0].clientY - rect.top
                    };
                }

                // Prevent scrolling when touching the canvas
                document.body.addEventListener("touchstart", function (e) {
                    if (e.target == canvas) {
                        e.preventDefault();
                    }
                }, false);
                document.body.addEventListener("touchend", function (e) {
                    if (e.target == canvas) {
                        e.preventDefault();
                    }
                }, false);
                document.body.addEventListener("touchmove", function (e) {
                    if (e.target == canvas) {
                        e.preventDefault();
                    }
                }, false);
            }

            function clearCanvas() {
                image = new Image();
                ctx.clearRect(0, 0, canvas.width, canvas.height);
            }

            function saveCanvas() {
                image = canvas.toDataURL("image/png");
                addSignature(image);
            }

            let imgInput = document.getElementById('imageLoader');
            imgInput.addEventListener('change', function (e) {
                if (e.target.files) {
                    let imageFile = e.target.files[0]; //here we get the image file
                    var reader = new FileReader();
                    reader.readAsDataURL(imageFile);
                    reader.onloadend = function (e) {
                        var myImage = new Image(); // Creates image object
                        myImage.src = e.target.result; // Assigns converted image to image object
                        myImage.onload = function (ev) {
                            var myCanvas = document.getElementById("signature-canvas-test"); // Creates a canvas object
                            var myContext = myCanvas.getContext("2d"); // Creates a contect object
                            myCanvas.width = 300; // Assigns image's width to canvas
                            myCanvas.height = 200; // Assigns image's height to canvas
                            //myContext.drawImage(myImage, 0, 0); // Draws the image on canvas
                            myContext.drawImage(myImage, 0, 0, 300, 200);
                            let imgData = myCanvas.toDataURL("image/jpeg", 0.75); // Assigns image base64 string in jpeg format to a variable
                        }
                    }
                }
            });

        </script>
    </head>
    <body>
        <div id="test">
            <h1 class="text-light">Quotation Signature</h1>
        </div>
        </br>
        <div>
            <input type="file" id="imageLoader" name="imageLoader"/>
        </div>
        <div>
            <button class="button primary" onclick="clearCanvas()">Clear</button>
        </div>
        </br>
        <div>
            <label>Name</label>
            </br>
            <div class="input-control">
                <input type="text" name="creatorName" maxlength="300" placeholder="" value=""  size="35">
            </div>
        </div>
        <div>
            <label>Designation</label>
            </br>
            <div class="input-control">
                <input type="text" name="creatorDegsination" maxlength="300" placeholder="" value="" size="35">
            </div>
        </div>
        </br>
        <div>
            <button class="button primary" onclick="saveCanvas()">Submit</button>
        </div>

    </body>  
</html>
