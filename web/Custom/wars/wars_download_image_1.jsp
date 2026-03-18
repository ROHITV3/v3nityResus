<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.web.*"%>
<%@page import="v3nity.std.core.system.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.controller.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
    int jobId = Integer.parseInt(request.getParameter("jobId"));
    boolean versionRead = (boolean) request.getSession().getAttribute("versionRead");

%>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <meta name="referrer" content="no-referrer">
        <title>${title}</title>
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/anytime.5.1.0.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/metro-responsive.css" rel="stylesheet">
        <link href="css/metro-schemes.css" rel="stylesheet">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/select2.min.css" rel="stylesheet">
        <link href="css/responsive.dataTables.css" rel="stylesheet">
        <link href="css/slick.css" rel="stylesheet">
        <link href="css/v3nity-admin.css?v=${code}" rel="stylesheet">
        <link href="css/v3nity-form.css?v=${code}" rel="stylesheet">
        <link href="css/v3nity-import.css?v=${code}" rel="stylesheet">
        <link href="css/v3nity-map.css?v=${code}" rel="stylesheet">
        <link href="css/v3nity.css?v=${code}" rel="stylesheet">
        <%  if (!((String) request.getAttribute("custom")).isEmpty()) {
        %>
        <link href="Custom/${custom}/v3nity-custom.css?v=${code}" rel="stylesheet">
        <%
            }
        %>
        <style>

            /*      Temporary only, for v4 that still uses v3 UI   */

            .title-bar {
                background-color: #3B6DAB;
                color: #fff;
                margin: 0;
                padding: 4px 8px;
                height: 24px;
            }

            .title-bar .left-side {
                margin: 0;
                padding: 0;
                float: left;
            }

            .title-bar .right-side {
                margin: 0;
                padding: 0;
                float: right;
            }

            .title-bar h5 span {
                margin-right: 4px;
                top: -2px;
            }
            .main-header {
                font-weight:500;
                position: absolute;
            }
            .main-section {
                padding: 16px;
                padding-top: 85px;
                margin-bottom: 64px;
                width: 100%;
            }

            @media screen and (max-width: 480px) {
                .main-section {
                    padding: 8px;
                }
            }

        </style>

        <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?client=gme-v3teletech&v=3&libraries=drawing,geometry"></script>
        <script type="text/javascript" src="js/jquery-2.1.4.min.js"></script>
        <script type="text/javascript" src="js/jquery.dataTables.min.js"></script>
        <script type="text/javascript" src="js/anytime.5.1.0.js"></script>
        <script type="text/javascript" src="js/dataTables.buttons.min.js"></script>
        <script type="text/javascript" src="js/dataTables.responsive.min.js"></script>
        <script type="text/javascript" src="js/dataTables.select.min.js"></script>
        <script type="text/javascript" src="js/dataTables.cellEdit.js"></script>
        <script type="text/javascript" src="js/metro.js"></script>
        <script type="text/javascript" src="js/select2.min.js"></script>
        <script type="text/javascript" src="js/qrcode.min.js"></script>
        <script type="text/javascript" src="js/slick.js"></script>
        <script type="text/javascript" src="js/markerclusterer.js"></script>
        <script type="text/javascript" src="js/v3nity-chart.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-download.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-file.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-form.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-geocode.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-list.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-timetable.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-tools.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-treeview.js?v=${code}"></script>
        <script type="text/javascript" src="js/v3nity-google-map.js?v=${code}"></script>
        <script type="text/javascript" src="js/jszip.min.js"></script>
        <script type="text/javascript">
            
            function downloadIMG()
            {
                console.log(<%=jobId%>);
                openSuccessDialog();
                var img = new imgDownload('V3NITY_IMG');
                img.download(<%=jobId%>);       
            }
            
            function openSuccessDialog()
            {
                $('#success-dialog-message').html('Your booking has been submitted. Thank you');

                $('#download-dialog').data('dialog').open();
            }

        </script>
    </head>
    <body>
        <%@ include file="../../Common/dialog.jsp"%>
        <div class="padding20 dialog" id="download-dialog" data-role="dialog" data-close-button="true" data-overlay="true" data-overlay-click-close="true" data-overlay-color="op-dark">
            <p id="success-dialog-message"></p>
            <span class="dialog-close-button"></span>
        </div>
        <button onclick="downloadIMG()">Download Image</button>
    </body>
</html>
