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
    
    String jobId = request.getParameter("i");
    
    String customerId = request.getParameter("c");

    Connection con = null;

    String lib = "v3nity.std.biz.data.plan";

    String type = "JobSchedule";

    ListData data = new JobSchedule();

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    List<MetaData> metaDataList = data.getMetaDataList();

    JobFormTemplateDropDown formTemplateDropDown = new JobFormTemplateDropDown(userProperties);

    int pageLength = data.getPageLength();

    Connection connection = null;

    try
    {
        dataHandler.setConnection(connection);

    }
    catch (Exception e)
    {

    }
    
    response.setHeader("X-Frame-Options", "SAMEORIGIN");
    
    response.setHeader("X-XSS-Protection", "1;mode=block");
	
    response.setHeader("X-Content-Type-Options", "nosniff");
    
    response.setHeader("Strict-Transport-Security", "max-age=864000; includeSubDomains");

    String cookieHeader = response.getHeader("Set-Cookie");

    if (cookieHeader == null)
    {
        response.setHeader("Set-Cookie", "path=" + request.getContextPath() + ";SameSite=Strict;HttpOnly");
    }
    else
    {
        response.setHeader("Set-Cookie", cookieHeader + ";SameSite=Strict;HttpOnly");
    }

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
        <script src="js/jquery-3.5.1.min.js"></script>
        <script src="js/metro.js"></script>
        <script type="text/javascript">

            var customFilterQuery = [];

            var listForm;
            
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
                    beforeSend: function()
                    {

                    },
                    success: function(data)
                    {
                        if (data.result)
                        {
                            var html = 'VIEW REPORT: ';
                            
                            html += '<a target="_blank" href="' + data.job.link + '">' + data.job.template + '</a>';
                            
                            document.getElementById('job-pdf').innerHTML = html;
                            
                            initCanvas();
                        }
                    },
                    error: function()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                    },
                    async: false
                });
            }

            function embedSignature(image)
            {
                if (image.length < 3100)
                {
                    alert('Please add signature');
                    return;
                }
                
                $.ajax({
                    type: 'POST',
                    url: 'JobSignoffController',
                    data: {
                        action: 'embedsignature',
                        img: image,
                        jobId: '<%=jobId%>'
                    },
                    beforeSend: function()
                    {

                    },
                    success: function(data)
                    {
                        if (data.result)
                        {
                            alert('Signed succesfully, thank you!');
                        }
                    },
                    error: function()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                    },
                    async: false
                });
            }
            
            
            
            function initCanvas()
            {
                    var canvasContainer = document.createElement('div');
            
                    canvasContainer.setAttribute('id', 'canvas-container');
                    

                    document.getElementById('main').appendChild(canvasContainer);

                    var canvas = document.createElement('canvas');

                    canvas.setAttribute('id', 'signature-canvas');
                    
                    canvas.setAttribute('style', 'border-width:1px; border-style:solid');

                    canvasContainer.appendChild(canvas);

                    var ctx = canvas.getContext('2d');

                    var sketch = document.getElementById('canvas-container');

                    var sketch_style = getComputedStyle(sketch);

                    canvas.width = 300;

                    canvas.height = 300;

                    var colourBtns = document.createElement('div');
                    colourBtns.setAttribute('class', 'pad-btn-container');
                    colourBtns.innerHTML = 'Colours : ';

                    var black = document.createElement('button');
                    black.setAttribute('class', 'button');
                    black.style.color = 'black';
                    black.innerHTML = 'Black';
                    black.addEventListener('click', function(){
                        ctx.strokeStyle = 'black';
                    }, false);

                    var blue = document.createElement('button');
                    blue.setAttribute('class', 'button');
                    blue.style.color = 'blue';
                    blue.innerHTML = 'Blue';
                    blue.addEventListener('click', function(){
                        ctx.strokeStyle = 'blue';
                    }, false);

                    var red = document.createElement('button');
                    red.setAttribute('class', 'button');
                    red.style.color = 'red';
                    red.innerHTML = 'Red';
                    red.addEventListener('click', function(){
                        ctx.strokeStyle = 'red';
                    }, false);

                    colourBtns.appendChild(black);

                    colourBtns.appendChild(blue);

                    colourBtns.appendChild(red);

                    canvasContainer.appendChild(colourBtns);

                    var brushBtns = document.createElement('div');
                    brushBtns.setAttribute('class', 'pad-btn-container');
                    brushBtns.innerHTML = 'Brush Size : ';

                    var small = document.createElement('button');
                    small.setAttribute('class', 'button');
                    small.innerHTML = 'Small';
                    small.addEventListener('click', function(){
                        ctx.lineWidth = 2;
                    }, false);

                    var medium = document.createElement('button');
                    medium.setAttribute('class', 'button');
                    medium.innerHTML = 'Medium';
                    medium.addEventListener('click', function(){
                        ctx.lineWidth = 5;
                    }, false);

                    var large = document.createElement('button');
                    large.setAttribute('class', 'button');
                    large.innerHTML = 'Large';
                    large.addEventListener('click', function(){
                        ctx.lineWidth = 10;
                    }, false);

                    var xLarge = document.createElement('button');
                    xLarge.setAttribute('class', 'button');
                    xLarge.innerHTML = 'X-Large';
                    xLarge.addEventListener('click', function(){
                        ctx.lineWidth = 20;
                    }, false);

                    brushBtns.appendChild(small);

                    brushBtns.appendChild(medium);

                    brushBtns.appendChild(large);

                    brushBtns.appendChild(xLarge);

                    canvasContainer.appendChild(brushBtns);

                    var actionBtns = document.createElement('div');
                    actionBtns.setAttribute('class', 'pad-btn-container');

                    var eraser = document.createElement('button');
                    eraser.setAttribute('class', 'button');
                    eraser.innerHTML = 'Eraser';
                    eraser.addEventListener('click', function(){
                        ctx.strokeStyle = '#ffffff';
                    }, false);

                    var saveSignature = document.createElement('button');
                    saveSignature.setAttribute('class', 'button primary');
                    saveSignature.innerHTML = 'Save';
                    saveSignature.addEventListener('click', function(){
                        var image = canvas.toDataURL("image/png");

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

                    var clear = document.createElement('button');
                    clear.setAttribute('class', 'button');
                    clear.innerHTML = 'Clear';
                    clear.addEventListener('click', function(){
                        ctx.clearRect(0, 0, canvas.width,canvas.height);
                    }, false);

                    var cancel = document.createElement('button');
                    cancel.setAttribute('class', 'button');
                    cancel.innerHTML = 'Cancel';
                    cancel.addEventListener('click', function(e){

                        $('body').css('overflow', 'auto');

                        var container = $('#canvas-container');

                        ctx.clearRect(0, 0, canvas.width,canvas.height);

                        container.hide();

                    }, false);

                    actionBtns.appendChild(clear);

                    actionBtns.appendChild(saveSignature);

                    canvasContainer.appendChild(actionBtns);

                    var mouse = {x: 0, y: 0};

                    canvas.addEventListener('mousemove', function(e) {
                        mouse.x = ( e.pageX - this.offsetLeft ) - 20;
                        mouse.y = ( e.pageY - this.offsetTop ) - 100;
                    }, false);

                    ctx.lineJoin = 'round';
                    ctx.lineCap = 'round';
                    ctx.strokeStyle = 'black';

                    canvas.addEventListener('mousedown', function(e) {
                        ctx.beginPath();
                        ctx.moveTo(mouse.x, mouse.y);
                        canvas.addEventListener('mousemove', onPaint, false);
                    }, false);

                    canvas.addEventListener('mouseup', function() {
                        canvas.removeEventListener('mousemove', onPaint, false);
                    }, false);

                    var onPaint = function() {
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
            
            $(document).ready(function()
            {
                getPdf();
            });
                    
            
            
            
            


        </script>
    </head>
    <body>
        <div id="main" style="margin-left: 20px;">
            <h1 class="text-light">Signoff</h1>
            
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
        
    </body>
</html>
