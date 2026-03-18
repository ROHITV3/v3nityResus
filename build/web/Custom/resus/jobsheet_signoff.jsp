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
    String jobId = request.getParameter("id");

    String customerId = request.getParameter("custId");

    response.setHeader("X-Frame-Options", "SAMEORIGIN");

    response.setHeader("X-XSS-Protection", "1;mode=block");

    response.setHeader("X-Content-Type-Options", "nosniff");

    response.setHeader("Strict-Transport-Security", "max-age=864000; includeSubDomains");

    String cookieHeader = response.getHeader("Set-Cookie");

    if (cookieHeader == null) {
        response.setHeader("Set-Cookie", "path=" + request.getContextPath() + ";SameSite=Strict;HttpOnly");
    } else {
        response.setHeader("Set-Cookie", cookieHeader + ";SameSite=Strict;HttpOnly");
    }
%>
<html>
    <head>
        <style>
            html, body {
                height: 100%;
                overflow: hidden;
            }

            #main{
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
                overflow: auto;
            }
        </style>
        <meta charset="utf-8" />
        <title></title>
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/v3nity.css?v=${code}" rel="stylesheet">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <script src="js/jquery-3.6.1.min.js"></script>
        <script src="js/metro.js"></script>
        <script type="text/javascript">

            var customFilterQuery = [];

            var listForm;

            function test() {
                console.log('Test call');
            }

            function getPdf()
            {
                $.ajax({
                    type: 'POST',
                    url: 'JobSignoffController',
                    data: {
                        action: 'getjob',
                        jobId: '<%=jobId%>',
                        customerId: '<%=customerId%>'
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            var html = 'VIEW REPORT: ';

                            html += '<a target="_blank" href="' + data.job.link + '">' + data.job.template + '</a>';

                            document.getElementById('job-pdf').innerHTML = html;

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

            function getJobsheetPdf()
            {
                console.log("getQuotationPdf");
                $.ajax({
                    type: 'POST',
                    url: 'ResusJobsheetCustomerSignoffController',
                    data: {
                        action: 'getJobsheet',
                        id: '<%=jobId%>',
                        customerId: '1'
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            var html = 'VIEW JOB SHEET : ';
                            html += '<a target="_blank" href="' + data.job.link + '">' + data.job.template + '</a>';
                            document.getElementById('job-pdf').innerHTML = html;
                            console.log('data.status:' + data.status)
                            if (data.status) {
                                initCanvas();
                            }
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

            function embedSignature(image)
            {
                //console.log($('input[name=custName]').val());
                //console.log($('input[name=emailAddress]').val());
                //console.log(<%=jobId%>);

                if (image.length < 3100)
                {
                    alert('Please add signature');
                    return;
                }

                let confirmAction = confirm("Are you sure to accept this job sheet?");
                if (confirmAction) {
                    $.ajax({
                        type: 'POST',
                        url: 'ResusJobsheetCustomerSignoffController',
                        data: {
                            action: 'acceptJobsheet',
                            jobId: '<%=jobId%>',
                            img: image,
                            name: $('input[name=custName]').val(),
                            email: $('input[name=emailAddress]').val(),
                            companyName: $('input[name=companyName]').val()
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            if (data.result)
                            {
                                if (data.insert) {
                                    alert('Signed succesfully, thank you!');
                                } else {
                                    alert('Job Sheet is already approved');
                                }
                                location.reload();
                            }
                            location.reload();
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
            }


            function rejectJobsheet()
            {

                if ($('input[name=emailAddress]').val().trim().length === 0) {
                    alert('Please key in your email');
                    return;
                }

                if ($('textarea[name=remarks]').val().trim().length === 0) {
                    alert('Please input remarks');
                    return;
                }

                let confirmAction = confirm("Are you sure to reject this job sheet?");
                if (confirmAction) {
                    $.ajax({
                        type: 'POST',
                        url: 'ResusJobsheetCustomerSignoffController',
                        data: {
                            action: 'rejectJobsheet',
                            jobId: '<%=jobId%>',
                            name: $('input[name=custName]').val(),
                            email: $('input[name=emailAddress]').val(),
                            remarks: $('textarea[name=remarks]').val()
                        },
                        beforeSend: function ()
                        {

                        },
                        success: function (data)
                        {
                            if (data.result)
                            {
                                if (data.insert) {
                                    alert('Job Sheet is rejected!');
                                } else {
                                    alert('Job Sheet is already approved');
                                }
                                location.reload();
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
                } else {

                }
            }

            function initCanvas()
            {
                var canvasContainer = document.createElement('div');

                canvasContainer.setAttribute('id', 'canvas-container');


                document.getElementById('main').appendChild(canvasContainer);

                var headerDiv = document.createElement('div');
                var headerSpace = document.createElement('br');

                var newFieldHeader = document.createElement('h2');
                newFieldHeader.setAttribute('class', 'text-light');
                newFieldHeader.setAttribute('id', 'test');
                newFieldHeader.textContent = "Acknowledged by";
                //newFieldHeader.value("Test");
//                newFieldHeader.setAttribute('size', 35);
//                newFieldHeader.setAttribute('placeholder', 'Name');

                headerDiv.appendChild(newFieldHeader);
                //headerDiv.appendChild(headerSpace);
                canvasContainer.appendChild(headerDiv);

                var headerDiv2 = document.createElement('div');
                var headerSpace2 = document.createElement('br');

                headerDiv2.appendChild(headerSpace2);
                canvasContainer.appendChild(headerDiv2);

                var canvas = document.createElement('canvas');

                canvas.setAttribute('id', 'signature-canvas');

                canvas.setAttribute('style', 'border-width:1px; border-style:solid');

                canvasContainer.appendChild(canvas);

                var ctx = canvas.getContext('2d');

                var sketch = document.getElementById('canvas-container');

                var sketch_style = getComputedStyle(sketch);

                canvas.width = 300;

                canvas.height = 200;

                var space1 = document.createElement('br');

                var actionClearBtns = document.createElement('div');
                actionClearBtns.setAttribute('class', 'pad-btn-container');

                var clear = document.createElement('button');
                clear.setAttribute('class', 'button');
                clear.innerHTML = 'Clear';
                clear.addEventListener('click', function () {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                }, false);

                var uploadSignature = document.createElement('button');
                uploadSignature.setAttribute('class', 'button');
                uploadSignature.innerHTML = 'Upload';
                uploadSignature.setAttribute('style', 'margin-left: 120px;')
                uploadSignature.addEventListener('click', function () {
                    $('#uploadSignature').click();
                }, false);

                actionClearBtns.appendChild(space1);
                actionClearBtns.appendChild(clear);
                actionClearBtns.appendChild(uploadSignature);

                canvasContainer.appendChild(actionClearBtns);

                var testDiv = document.createElement('div');
                var space2 = document.createElement('br');

                var newField = document.createElement('input');
                newField.setAttribute('type', 'text');
                newField.setAttribute('name', 'custName');
                newField.setAttribute('class', 'custNameClass');
                newField.setAttribute('size', 35);
                newField.setAttribute('placeholder', 'Name');

                testDiv.appendChild(space2);
                testDiv.appendChild(newField);
                canvasContainer.appendChild(testDiv);

                var testDiv2 = document.createElement('div');
                var space3 = document.createElement('br');

                var newField2 = document.createElement('input');
                newField2.setAttribute('type', 'text');
                newField2.setAttribute('name', 'emailAddress');
                newField2.setAttribute('class', 'emailAddressClass');
                newField2.setAttribute('size', 35);
                newField2.setAttribute('placeholder', 'Email Address');

                testDiv2.appendChild(space3);
                testDiv2.appendChild(newField2);
                canvasContainer.appendChild(testDiv2);

                var remakrsDiv = document.createElement('div');
                var remarkssSpace = document.createElement('br');

                var remarksField = document.createElement('textarea');
                remarksField.setAttribute('type', 'text');
                remarksField.setAttribute('name', 'remarks');
                remarksField.setAttribute('class', 'remarksClass');
                remarksField.setAttribute('cols', 30);
                remarksField.setAttribute('rows', 4);
                remarksField.setAttribute('placeholder', 'Remarks');

                remakrsDiv.appendChild(remarkssSpace);
                remakrsDiv.appendChild(remarksField);
                canvasContainer.appendChild(remakrsDiv);

                var space5 = document.createElement('br');
                var actionBtns = document.createElement('div');
                actionBtns.setAttribute('class', 'pad-btn-container');

                var clear = document.createElement('button');
                clear.setAttribute('class', 'button');
                clear.innerHTML = 'Reject';
                clear.addEventListener('click', function () {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                }, false);

                var reject = document.createElement('button');
                reject.setAttribute('class', 'button');
                reject.setAttribute('style', 'margin-left: 120px;')
                reject.innerHTML = 'Reject';
                reject.addEventListener('click', function () {
                    rejectJobsheet();
                }, false);

                var saveSignature = document.createElement('button');
                saveSignature.setAttribute('class', 'button primary');
                saveSignature.innerHTML = 'Signoff';
                saveSignature.addEventListener('click', function () {
                    var image = canvas.toDataURL("image/png");
                    //var custName = document.getElementsByName("custName").value;
                    //var emailAddress = document.getElementsByName("emailAddress").value;
                    //console.log(custName);
                    //console.log(emailAddress);
//                        console.log(image)
//                        $(imgDiv).children().eq(0).attr('src', image);

                    embedSignature(image);

                    /*
                     $('body').css('overflow', 'auto');
                     
                     var container = $('#canvas-container');
                     
                     container.hide();
                     
                     ctx.clearRect(0, 0, canvas.width,canvas.height);
                     */

                }, false);

                actionBtns.appendChild(space5);
                // actionBtns.appendChild(clear);
                actionBtns.appendChild(saveSignature);
                actionBtns.appendChild(reject);

                canvasContainer.appendChild(actionBtns);

                var mouse = {x: 0, y: 0};

                canvas.addEventListener('mousemove', function (e) {
                    mouse.x = (e.pageX - this.offsetLeft) - 20;
                    mouse.y = (e.pageY - this.offsetTop) - 100;
                }, false);

                ctx.lineJoin = 'round';
                ctx.lineCap = 'round';
                ctx.strokeStyle = 'black';

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

                let imgInput = document.getElementById('uploadSignature');
                imgInput.addEventListener('change', function (e) {
                    if (e.target.files) {
                        let imageFile = e.target.files[0]; //here we get the image file
                        var reader = new FileReader();
                        reader.readAsDataURL(imageFile);
                        reader.onloadend = function (e) {
                            var myImage = new Image(); // Creates image object
                            myImage.src = e.target.result; // Assigns converted image to image object
                            myImage.onload = function (ev) {
                                var myCanvas = document.getElementById("signature-canvas"); // Creates a canvas object
                                var myContext = myCanvas.getContext("2d"); // Creates a contect object
                                myCanvas.width = 300; // Assigns image's width to canvas
                                myCanvas.height = 200; // Assigns image's height to canvas
                                myContext.drawImage(myImage, 0, 0, 300, 200);
                                let imgData = myCanvas.toDataURL("image/jpeg", 0.75); // Assigns image base64 string in jpeg format to a variable
                            }
                        }
                    }
                });
            }

            $(document).ready(function ()
            {
                getJobsheetPdf();
            });







        </script>
    </head>
    <body>
        <div id="main" style="margin-left: 20px;">
            <h1 class="text-light">Job Sheet Signature</h1>

            <div id="job-pdf" style="margin-bottom: 20px;">
                <!--                <a target="_blank" href="http://localhost:8080/v3nity4/PublicController?key=twcc&type=plan&action=pdf&id=112554">PDF Report</a>-->
            </div>
            <!--            <div id="canvas-container">
                            <canvas id="signature-canvas" width="400" height="400"></canvas>
                            <div class="pad-btn-container">
                                Colours : 
                                <button class="button" style="color: black;">Black</button>
                                <button class="button" style="color: blue;">Blue</button>
                                <button class="button" style="color: red;">Red</button>
                            </div>
                            <div class="pad-btn-container">
                                Brush Size : 
                                <button class="button">Small</button>
                                <button class="button">Medium</button>
                                <button class="button">Large</button>
                                <button class="button">X-Large</button>
                            </div>
                            <div class="pad-btn-container" style="text-align: center;">
                                <button class="button">Eraser</button>
                                <button class="button primary">Save</button>
                                <button class="button">Clear</button>
                                <button class="button">Cancel</button>
                            </div>
                        </div>-->

        </div>
        <input type="file" id="uploadSignature" hidden/>
    </body>
</html>
