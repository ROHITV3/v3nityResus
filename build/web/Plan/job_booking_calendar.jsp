<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="java.util.Calendar"%>
<%@page import="v3nity.std.biz.data.common.UserProperties"%>
<%@page import="java.sql.Connection"%>
<%@page import="v3nity.std.biz.data.common.DriverDropDown"%>
<%@page import="v3nity.std.core.data.DataHandler"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%  UserProperties userProperties = (UserProperties) request.getAttribute("properties");
    
    Connection connection = null;
    
    DataHandler dataHandler = new DataHandler();

    DriverDropDown driverDropDown = new DriverDropDown(userProperties);

    try 
    {
        connection = userProperties.getConnection();
        
        dataHandler.setConnection(connection);

        driverDropDown.setIdentifier("dropdown-driver");

        driverDropDown.loadData(userProperties);

    }  
    catch (Exception e)
    {

    }
    finally
    {
        userProperties.closeConnection(connection);
    }
    String[] monthName = {"January", "February",
                "March", "April", "May", "June", "July",
                "August", "September", "October", "November",
                "December"};
    
    Calendar cal = Calendar.getInstance();
    String month = monthName[cal.get(Calendar.MONTH)] + " " +cal.get(cal.YEAR);       
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="css/monthly.css" rel="stylesheet">
        <script type="text/javascript" ></script>
        <script type="text/javascript" src="js/monthly.js" ></script>
        <script>
            $(document).ready(function () {
                $("#month_year").AnyTime_picker({format: "%M %Y"});
            });

            $("#showCalendar").click(function ()
            {
                if($("#month_year").val() != "" && $('#driverId').val() != "")
                {
                    $('#mycalendar').empty();

                    $.ajax({
                        type: 'POST',
                        url: 'JobBookingCalendarController',
                        data: {
                            driverId: $('#driverId').val(),
                            action: 'getCalendar',
                            monthyear: $('#month_year').val()
                        },
                        success: function (data) {
                            $('#mycalendar').monthly({
                                mode: 'event',
                                jsonUrl: data,
                                dataType: 'json',
                                startMth: getMonthFromString(""+$("#month_year").val().slice(0, -5)),
                                startYr: $("#month_year").val().slice(-4)
                            });
                        },
                        complete: function () {

                        },
                        async: false
                    });
                }
                else
                {
                    dialog('No Staff Selected', 'Select a Staff to Search', 'alert');
                }
            });
            
            function getMonthFromString(mon)
            {
                var d = Date.parse(mon + "1, 2012");
                if(!isNaN(d))
                {
                   return new Date(d).getMonth() + 1;
                }
                return -1;
            }

            function dispose() 
            {
                $("#month_year").AnyTime_noPicker();
            }

            function reset() 
            {
               $("#month_year").val('<%=month%>');              
            }
            
            function printContent(el)
            {
                window.print(); 
            }
        </script>
    </head>
    <body>
        <%@ include file="../Common/dialog.jsp"%>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("jobBookingCalendar")%></h1>
        </div>
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="showCalendar" title="Search" name="showCalendar"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="reset" title="Reset" name="reset" value="" onclick="reset()"><span class="mif-undo"></span></button>
            </div>
            <div class="toolbar-section">
                <button class="toolbar-button" id="print" title="Print" name="print" value="" onclick="printContent('mycalendar');"><span class="mif-print"></span></button>
            </div>
        </div>
            <input type="hidden" name="filterChanged" id="filterChanged">
            <br/>
            <div class="grid">
                <div class="row cells4">
                    <div class="cell">
                        <h4 class="text-light align-left"><%=userProperties.getLanguage("driver")%></h4>
                        <div class="input-control select">
                        <select id="driverId" name="driverId">
                            <option value = "">Select Staff</option>
                            <% driverDropDown.outputHTML(out, userProperties);%>
                        </select>
                        </div>
                    </div>
                    <div class="cell">
                        <h4 class="text-light align-left">Select Month Year</h4>
                        <div class="input-control text" data-role="input">
                            <span class="mif-calendar prepend-icon"></span>
                            <input id="month_year" type="text" placeholder="Select Month Year" value="<%=month%>" autocomplete="on">
                            <button class="button helper-button clear"><span class="mif-cross"></span></button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="cell">
                    <div style="width:100%; max-width:800px; display:inline-block;">
                        <div id="mycalendar" class="monthly" style="border: thin solid gainsboro"></div>
                    </div>
                </div>
            </div>
    </body>
</html>

