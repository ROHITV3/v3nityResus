<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.web.*"%>
<%@page import="v3nity.std.core.system.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.controller.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

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
        <link rel="stylesheet" href="css/jsuites.css" type="text/css" />
        <link rel="stylesheet" href="css/jspreadsheet.css" type="text/css" />
        
        <%  if (!((String) request.getAttribute("custom")).isEmpty())
            {
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
        <script type="text/javascript" src="js/jexcel.js"></script>
        <script type="text/javascript" src="js/jsuites.js"></script> 
        <script type="text/javascript">

            var sessionTimeout;
            var sessionTimeoutChecker;

            $(document).ready(function()
            {
//                load('list?lib=v3nity.std.biz.data.plan&type=JobReportTemplate');
//                load('JourneySummaryPSAController');
//                load('list?lib=v3nity.std.biz.report&type=TFSSensorDataExclusion');
//                load('list?lib=v3nity.std.biz.report&type=SmartToiletAlertAssignment');
//                load('list?lib=v3nity.std.biz.data.plan&type=JobFormTemplate');
//load('CustomerContractController?lib=v3nity.std.biz.data.plan&type=ContractCustomer');
//                load('list?lib=v3nity.std.biz.report&type=TFSBadRatingDetail');
//                load('RamkyChartController');
//                load('list?lib=v3nity.std.biz.report&type=TFSSensorDataExclusion');
//                load('ramky_job_vehicle_checklist?lib=v3nity.cust.biz.data&type=RamkyJobVehicleChecklist');
//    load('list?lib=v3nity.cust.biz.data&type=HygieneServiceReport');
//                if ('${defaultPage}' !== 'none')
//                {
//                    load('${defaultPage}');
//                }
//                    
//                load('list?lib=v3nity.std.biz.report&type=HistoryDbTracker');
//                load('list?lib=v3nity.std.biz.data.plan&type=OptSchedule')
//                
//                
//                
                load('AutoSchedulingController')
                //load('ramky_route?lib=v3nity.cust.biz.data&type=RamkyRoute');
               // load('RamkyJobVehicleChecklistController')
//                load('TrackHistoryController?lib=v3nity.std.biz.report&type=History');
                

                resetSessionTimeout(); // fire a ajax call to get the sessionTimeout time (20 minutes from now)

                sessionTimeoutChecker = setInterval(function()
                {
                    checkSessionTimeout();

                }, 150000); // 2.5 minutes checking in seconds

                if (<%=!versionRead%>)
                {
                    showVersionDialog();
                }
            });

            $(document).ajaxComplete(function(event, xhr, settings)
            {
                if (xhr.getResponseHeader('timeout') !== undefined)
                {
                    sessionTimeout = parseInt(xhr.getResponseHeader('timeout'));
                }
            });

            function secondsToHms(d)
            {
                d = Number(d);

                var h = Math.floor(d / 3600);
                var m = Math.floor(d % 3600 / 60);
                var s = Math.floor(d % 3600 % 60);

                var hDisplay = h > 0 ? h + (h === 1 ? " hour, " : " hours, ") : "";
                var mDisplay = m > 0 ? m + (m === 1 ? " minute" : " minutes") : "1 minute";
                var sDisplay = s > 0 ? s + (s === 1 ? " second" : " seconds") : "";

                return mDisplay;
            }

            function checkSessionTimeout()
            {
                var date = new Date();

                var currentTime = date.getTime();

                var sessionTimeLeft = Math.trunc((sessionTimeout - currentTime) / 1000); // check how much time left until session timeout

                if (sessionTimeLeft <= 300 && sessionTimeLeft > 0)
                {
                    // 5 minutes before time out...
                    dialog("Session Timeout", "Your session will expire in " + secondsToHms(sessionTimeLeft) + ". Do you want to stay signed in?", "confirmation", "Yes, Keep me signed in", "userClicked('comfirmation')");
                }

                if (sessionTimeLeft < 0)
                {
                    clearInterval(sessionTimeoutChecker);

                    confirmationDialogClose('confirmation');

                    $('#main').load('ExpiredController', {custom: '${custom}'});
                }
            }

            function showVersionDialog()
            {
                $.ajax({
                    type: 'POST',
                    url: 'VersionLogController',
                    data: {
                        type: 'system',
                        action: 'get'
                    },
                    success: function(data)
                    {
                        if (data.result === true)
                        {
                            var version = data.version;
                            var versionLog = "<ul class=\"version-log-list\">";

                            for (var i = 0; i < data.versionLog.length; i++)
                            {
                                versionLog += "<li>" + data.versionLog[i].text + "</li>";
                            }
                            versionLog += "</ul>";

                            openVersionDialog("Version " + version, versionLog, "userClickedVersion()");
                        }
                    },
                    error: function()
                    {
                        alert("Error,Session not extended");
                    },
                    complete: function()
                    {
                    },
                    async: false
                });
            }

            function resetSessionTimeout()
            {
                $.ajax({
                    type: 'POST',
                    url: 'MenuController',
                    data: {
                        type: 'system',
                        action: 'reset'
                    },
                    success: function(data)
                    {
                        if (data.result === true)
                        {

                        }
                        else
                        {
                            clearInterval(sessionTimeoutChecker);

                            confirmationDialogClose('confirmation');
                        }
                    },
                    error: function()
                    {
                        alert("Error,Session not extended");
                    },
                    complete: function()
                    {
                    },
                    async: false
                });
            }

            function userClicked() // JX: try to combine the userclickedVersion and userclick together but end up it doesnt work for one of it. so split it up
            {
                resetSessionTimeout();

                confirmationDialogClose('confirmation');
            }

            function userClickedVersion()
            {
                versionLogRead();

                confirmationDialogClose('version');
            }

            function versionLogRead() // After user click "Got It" from the version log
            {
                $.ajax({
                    type: 'POST',
                    url: 'VersionLogController',
                    data: {
                        type: 'system',
                        action: 'set'
                    },
                    success: function(data)
                    {
                        if (data.result)
                        {

                        }
                        else
                        {
                            confirmationDialogClose('version');
                        }
                    },
                    error: function()
                    {
                        alert("Error,Session not extended");
                    },
                    complete: function()
                    {
                    },
                    async: false
                });
            }

            // Using jquery .load() as ajax call
            function load(source)
            {
                // whenever reload, we need to close any overlay dialog...
                $('[data-role="dialog"]').each(function(index, elem)
                {
                    var dialog = $(elem).data('dialog');

                    dialog.close();
                });

                // dispose resources...
                if (typeof dispose !== 'undefined')
                {
                    dispose();

                    dispose = undefined;
                }
                
                if (source === 'list?lib=v3nity.std.biz.data.track&type=Location')
                {
                    source = 'location?lib=v3nity.std.biz.data.track&type=Location';
                }
                
                $.ajax({
                    type: 'POST',
                    url: source,
                    data: {
                        custom: '${custom}'
                    },
                    beforeSend: function()
                    {
                        preloader(true);
                    },
                    success: function(page)
                    {
                        $('#main').html(page);
                    },
                    error: function()
                    {
                        dialog('Loading Error', 'Sorry, please try again few minutes later', 'alert');
                    },
                    complete: function()
                    {
                        preloader(false);
                    },
                    async: true
                });

            }

            function logout()
            {
                $.ajax({
                    type: 'POST',
                    url: 'LoginController',
                    data: {
                        type: 'system',
                        action: 'logout'
                    },
                    success: function()
                    {

                    },
                    error: function()
                    {

                    },
                    complete: function()
                    {
                        window.location = 'login?custom=${custom}';
                    },
                    async: false
                });
            }

        </script>
    </head>
    <body>
        <div id="header" class="main-header">
            <div class="title-bar">
                <h5 class="text-light left-side">V3NITY ${version}</h5>
                <h5 class="text-light right-side"><span class="mif-user icon fg-white"></span><%=userProperties.getUser().getString("username")%></h5>
            </div>
            <div class="app-bar v3nity" data-role="appbar">
                <ul class="app-bar-menu">
                    <%
                        ApplicationMenu menu = (ApplicationMenu) request.getServletContext().getAttribute("system-menu");

                        MenuData root = menu.getRootMenu();

                        MenuController.ProcessMenuItem(out, userProperties, root);
                    %>
                </ul>
                <div class="app-bar-pullbutton automatic"></div>
                <ul class="app-bar-menu place-right">
                    <li>
                        <a href="#" class="dropdown-toggle"><%=userProperties.getLanguage("about")%></a>
                        <ul class="d-menu" data-role="dropdown">
                            <li><a href="#" onclick="load('TosController');"><%=userProperties.getLanguage("termsOfService")%></a></li>
                            <li><a href="#" onclick="load('PrivacyController');"><%=userProperties.getLanguage("privacyPolicy")%></a></li>
                            <li><a href="#" onclick="load('SupportController');"><%=userProperties.getLanguage("support")%></a></li>
                            <li><a href="#" onclick="load('AboutController');"><%=userProperties.getLanguage("v3nity")%></a></li>
                        </ul>
                    </li>
                    <li><a href="#" onclick="load('MyAccountController')"><%=userProperties.getLanguage("myAccount")%></a></li>
                    <li><a href="#" onclick="logout()"><span style="padding-top: 18px" class="mif-switch icon fg-white"></span></a></li>
                </ul>
            </div>
        </div>
        <div id="main" class="main-section">

        </div>
        <%@ include file="../Common/preloader.jsp"%>
        <%@ include file="../Common/dialog.jsp"%>
    </body>
</html>
