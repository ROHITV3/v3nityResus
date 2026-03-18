<%@page import="v3nity.std.core.data.MetaData"%>
<%@page import="v3nity.std.core.data.Data"%>
<%@page import="v3nity.std.biz.data.plan.JobSchedule"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String[] monthName = {"January", "February",
                "March", "April", "May", "June", "July",
                "August", "September", "October", "November",
                "December"};
    
    Calendar cal = Calendar.getInstance();
    String month = monthName[cal.get(Calendar.MONTH)] + " " +cal.get(cal.YEAR);
    
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
        
    Locale locale = userProperties.getLocale();

    int customerId = userProperties.getInt("customer_id");
    int userId = userProperties.getUser().getId();
    
%>

<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <link href="css/job-schedule-calendar.css?v=${code}" rel="stylesheet">
        <title></title>
        <style>
            .label-container {
                padding-top: 10px;
            }
            
            .label-container label {
                cursor: auto;
            }
            
            .toolbar-section:before{
                width: 0px;
            }
            
            
            
        </style>
        
        <script type="text/javascript">

            var selectedMonth;
            var selectedToDate;
            
            var orangeCount = 3;
            var redCount = 5;
            
            $(document).ready(function()
            {
                $("#mthYr").AnyTime_picker({format: "%M %Z"});
                
                getCalendarMonth()
                getMonthlyData()
                
//                setTimeout(function()
//                {
//                    openSettingsDialog();
//                },100)
                
            });
            
            
            function dateDiff(first, second) {
                // Take the difference between the dates and divide by milliseconds per day.
                // Round to nearest whole number to deal with DST.
                return Math.round((second-first)/(1000*60*60*24));
            }
            
            function dispose()
            {                
                $("#mthYr").AnyTime_noPicker();
            }
            
            
            function getCalendarMonth()
            {
                $.ajax({
                    type: 'POST',
                    url: 'JobCalendarController?type=calendar&action=getcalendarmonth',
                    data: {
                        monthyear: $("#mthYr").val()
                    },
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function(data)
                    {
                        var dayArr = data.day_arr;
                        var dateArr = data.date_arr;
                        
                        var aItem;
                        
                        var html = '';
                        
                        for(var i = 0 ; i < dayArr.length ; i++)
                        {
                            aItem = dayArr[i];
                            if (aItem.is_sunday == 'true')
                            {
                                html += '<div class="dayDate sunday">' + aItem.day + '</div>'
                            }
                            else
                            {
                                html += '<div class="dayDate normalDay">' + aItem.day + '</div>'
                            }
                        }
                        
                        document.getElementById('dayNameContainer').innerHTML = html;
                        
                        html = '';
                        
                        for(var i = 0 ; i < dateArr.length ; i++)
                        {
                            aItem = dateArr[i];
                            html += '<div class="dayDate">' + aItem.date + '</div>'
                        }
                        
                        document.getElementById('dateContainer').innerHTML = html;
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        $('#button-save').prop("disabled", false);
                    },
                    async: true
                });
            }
            
            
            function getMonthlyData()
            {
                $.ajax({
                    type: 'POST',
                    url: 'JobCalendarController?type=calendar&action=getmonthlydata',
                    data: {
                        monthyear: $("#mthYr").val(),
                        userId: '<%=userId%>'
                    },
                    beforeSend: function()
                    {
                        $("#mthYr").prop("disabled", true);
                    },
                    success: function(data)
                    {
                        var allData = data.resource_arr;
                        
                        var aData;
                        var appts;
                        var name;
                        
                        var loopCovered = false;
                        var aAppt;
                        
                        var html = '';
                        
                        for(var i = 0 ; i < allData.length ; i++)
                        {
                            loopCovered = false;
                            
                            aData = allData[i];
                            name = aData.name;
                            appts = aData.appt_arr;
                            
                            html += '<div class="singleEntry">';
                                html += '<div class="aName">' + name + '</div>';
                                html += '<div class="allMarkers">';
                                
                            
                            for (var j = 1 ; j <= 31 ; j++  )
                            {
                                loopCovered = false;
                                
                                for (var k = 0 ; k < appts.length ; k++)
                                {
                                    aAppt = appts[k];
                                    
                                    if (parseInt(aAppt.job_date,10) == j)
                                    {
                                        var count = parseInt(aAppt.job_count,10);
                                        
                                        if (count > redCount)
                                        {
                                            html += '<div class="aMarker redBox">' + count + '</div>';
                                        }
                                        else if (count > orangeCount)
                                        {
                                            html += '<div class="aMarker orangeBox">' + count + '</div>';
                                        }
                                        else
                                        {
                                            html += '<div class="aMarker greenBox">' + count + '</div>';
                                        }
                                        
                                        loopCovered = true;
                                        break;
                                    }
                                }
                                
                                if (loopCovered == false)
                                {
                                    html += '<div class="aMarker"></div>';
                                }
                            }
                            
                                html += '</div>';
                            html += '</div>';
                        }
                        
                        document.getElementById('bottomContainer').innerHTML = html;
                        
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        $("#mthYr").prop("disabled", false);
                    },
                    async: true
                });
            }
            
            function openSettingsDialog()
            {
                $('#orangecount').val(orangeCount);
                $('#redcount').val(redCount);
                
                $('#settings-dialog').data('dialog').open();
            }
            
            function saveCount()
            {
                if (parseInt($('#orangecount').val(),10) >= parseInt($('#redcount').val(),10))
                {
                    dialog('Error', 'Count for Red has to be more than Orange', 'alert');
                    return;
                }
                
                orangeCount = $('#orangecount').val();
                redCount = $('#redcount').val();
                
                dialog('Success', 'Settings Updated', 'success');
                $('#settings-dialog').data('dialog').close();
                
                getMonthlyData();
            }
            
            
        </script>
        
        
    </head>
    <body>
        <h1 id="form-dialog-title" class="text-light"><%=userProperties.getLanguage("jobStaffWorkload")%></h1>
        
        <div data-role="dialog" id="settings-dialog" class="small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light" id="settings-dialog-title">Settings</h1>
                <div class="grid" style="height: 60%;">
                    <div class="row cells1">
                        <div class="cell">
                            <label>Show <span style="color: orange;">ORANGE</span> for more than 
                                <input type="number" id="orangecount" name="label" min="1" max="99" placeholder="" value="" style="font-size: 14px;"> daily jobs</label>
                        </div>
                    </div>
                    <div class="row cells1">
                        <div class="cell">
                            <label>Show <span style="color: maroon;">RED</span> for more than 
                                <input type="number" id="redcount" name="label" min="1" max="99" placeholder="" value="" style="font-size: 14px;"> daily jobs</label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-save type="button" class="button primary" onclick="saveCount()">Save</button>
                <button id=button-cancel type="button" class="button" onclick="$('#settings-dialog').data('dialog').close();">Cancel</button>
            </div>
        </div>
            
            
        <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <div class="row cells4">
                        <div class="cell">
                            <div class="input-control text" >
                                <input type="text" name="mthYr" id="mthYr" maxlength="10" size="10" placeholder="" 
                                        value="<%=month%>" onchange="getCalendarMonth(); getMonthlyData()" style="cursor: pointer">
                            </div>
                            <div class="add-box" onclick="openSettingsDialog()">
                                <div class="add-icon"></div>
                                <div class="single-add">Settings</div>
                            </div>
                            
                        </div>
                        
                        <div class="cell">
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
                            
                            
                            
        <div id="mainContainer">
            <div id="topContainer">
                <div id="topLeftBlank"></div>
                <div id="dayDateContainer">
                    <div id="dayNameContainer">
                        <div class="dayDate sunday">1</div>
                        <div class="dayDate normalDay">2</div>
                        <div class="dayDate">1</div>
                        <div class="dayDate">2</div>
                        <div class="dayDate">1</div>
                    </div>
                    <div id="dateContainer">
                        <div class="dayDate">31</div>
                        <div class="dayDate">29</div>
                        <div class="dayDate">1</div>
                        <div class="dayDate">2</div>
                        <div class="dayDate">1</div>
                    </div>
                </div>
            </div>
            
            <div id="bottomContainer">
<!--                <div class="singleEntry">
                    <div class="aName">NamNam et al and the friends they call</div>
                    <div class="allMarkers">
                        <div class="aMarker dayShift"></div>
                        <div class="aMarker"></div>
                        <div class="aMarker dayShift"></div>
                        <div class="aMarker nightShift"></div>
                        <div class="aMarker nightShift"></div>
                        <div class="aMarker restDay"></div>
                        <div class="aMarker restDay"></div>
                        
                    </div>
                </div>-->
            </div>
        </div>
    </body>
</html>