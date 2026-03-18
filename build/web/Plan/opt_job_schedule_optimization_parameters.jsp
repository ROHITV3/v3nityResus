<%-- 
    Document   : opt_job_schedule_optimization_parameters
    Created on : Jul 1, 2021, 1:59:37 PM
    Author     : Shubham
--%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="java.sql.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
    Connection con = null;
    //new
    Locale locale = userProperties.getLocale();
    //Data country = null;

    //String countryCode = userProperties.getString("country").toUpperCase();

    
    OptJobLocationDropDown jobLocationDropDown = new OptJobLocationDropDown(userProperties);
    
    try
    {
        con = userProperties.getConnection();

        jobLocationDropDown.loadData(userProperties);

    }
    catch (Exception e)
    {

    }
    finally
    {
        userProperties.closeConnection(con);
    }

    java.util.Date today = new java.util.Date();
    SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("dd/MM/yyyy");

    String todayStart = dateOnlyFormat.format(today) + " 08:00:00";
    String todayEnd = dateOnlyFormat.format(today) + " 17:00:00";

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <style>
            /*new*/
            .prop-arrow{
                position: absolute;
                left: 0;
                width: 8px;
                height: 8px;
                border-left: 7px solid transparent;
                border-top: 7px solid transparent;
                border-bottom: 7px #222222 solid;
                transform: rotate(-45deg); 
            }
            span.prop-arrow.active{
                left: 4px;
                border-bottom: 7px #eeeeee solid;
                transform: rotate(0deg); 
            }

            .prop-accordion:hover {
                background-color: #ccc;
            }
            .prop-accordion.active{
                background-color: #333333;
                color: #ffffff;
            }
            .prop-accordion {
                margin-top: 10px;
                background-color: #eee;
                color: #444;
                cursor: pointer;
                padding: 14px 18px 14px 18px;
                width: 100%;
                border: none;
                text-align: left;
                outline: none;
                font-size: 14px;
                transition: 0.4s;
            }

            div.prop-panel {
                display: none;
            }

            div.prop-panel.active {
                display: block !important;
            }

            .location{
                width: 30% !important;
                height: 34% !important;
                top: 20% !important;
                bottom: 10% !important;
                max-width: 700px;
                margin-left: -350px;
                left: 55% !important;
            }
            label.input-control.checkbox{
                margin-left: 20px;   
            }

            /*new*/
        </style>
        <script type="text/javascript">

            var startTimeArr = [];
            var endTimeArr = [];
            var startTimeDivIdArr = [];
            var endTimeDivIdArr = [];
            var todayDate;
            var map, markerLocation, locationLayer, jobLayer, mapPadding;//new

            $(document).ready(function ()
            {
                //new
                var acc = document.getElementsByClassName("prop-accordion");
//                var acc = document.getElementById("accordionId");
                var panel = document.getElementsByClassName('prop-panel');
                var arrows = document.getElementsByClassName('prop-arrow');

                for (var i = 0; i < acc.length; i++) {
                    acc[i].onclick = function () {
                        var setClasses = !this.classList.contains('active');
                        setClass(acc, 'active', 'remove');
                        setClass(panel, 'active', 'remove');
                        setClass(arrows, 'active', 'remove');

                        if (setClasses) {
                            this.classList.toggle("active");
                            this.nextElementSibling.classList.toggle("active");
                            this.childNodes[0].classList.toggle("active");
                        }
                    }
                };
                map = null;

                locationSearch = new AddressSearchBox('locationSearch', 1500, locationCallback, <%=(locale.getCountry().equals("SG"))%>);

                locationSearch.enable();
                //end new
                var today = new Date();
                var dd = today.getDate();
                if (dd < 10)
                {
                    dd = '0' + dd;
                }
                var mm = today.getMonth() + 1;
                if (mm < 10)
                {
                    mm = '0' + mm;
                }
                var yyyy = today.getFullYear();
                todayDate = dd + '/' + mm + '/' + yyyy;

                initDatePicker(0);
                
            });
            
            
            function dispose()
            {
                $(".schedule-time").AnyTime_noPicker();
                $("#recur-start-time").AnyTime_noPicker();
                $("#timetable-date").AnyTime_noPicker();
                $(".starting-from").AnyTime_noPicker();
                $(".ending-on").AnyTime_noPicker();
                $("#reschedule-date").AnyTime_noPicker();

                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function(index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });
            }

            function showParam()
            {
                document.getElementById('optimization-parameters-div').style.display = "block";
                document.getElementById('button-hide-param').style.display = "inline-block";
                document.getElementById('button-show-param').style.display = "none";
            }

            function hideParam()
            {
                document.getElementById('optimization-parameters-div').style.display = "none";
                document.getElementById('button-hide-param').style.display = "none";
                document.getElementById('button-show-param').style.display = "inline-block";
            }

            function initDatePicker(id)
            {
                $("#dateTimePicker-pref-start-" + id).val(todayDate + ' 08:00:00');
                $("#dateTimePicker-pref-end-" + id).val(todayDate + ' 17:00:00');

                startTimeDivIdArr[parseInt(id, 10)] = 'dateTimePicker-pref-start-' + id;
                endTimeDivIdArr[parseInt(id, 10)] = 'dateTimePicker-pref-end-' + id;

                startTimeArr[parseInt(id, 10)] = $("#dateTimePicker-pref-start-" + id).val();
                endTimeArr[parseInt(id, 10)] = $("#dateTimePicker-pref-end-" + id).val();

                $('#pref_end_arr').val(endTimeArr);
                $('#pref_start_arr').val(startTimeArr);
            }

            function deleteTime(id)
            {
                $("#dateTimePicker-pref-start-" + id).AnyTime_noPicker();
                $("#dateTimePicker-pref-end-" + id).AnyTime_noPicker();

                var element = document.getElementById('preferredTime-' + id);
                element.parentNode.removeChild(element);

                startTimeDivIdArr[parseInt(id, 10)] = '';
                endTimeDivIdArr[parseInt(id, 10)] = '';

                startTimeArr[parseInt(id, 10)] = '';
                endTimeArr[parseInt(id, 10)] = '';

                $('#pref_end_arr').val(endTimeArr);
                $('#pref_start_arr').val(startTimeArr);
            }

            
            function createNewTime()
            {
                var divId;
                var nextId;

                divId = document.getElementsByClassName('preferredTimeDiv')[$('.preferredTimeDiv').length - 1].id;
                nextId = divId[divId.length - 1];
                nextId = parseInt(nextId, 10) + 1;
                

                var appendHtml = '';
                appendHtml += '<div class="row cells3 preferredTimeDiv" id="preferredTime-' + nextId + '">';
                appendHtml += '<div class="cell">';
                appendHtml += '<label>Start Time</label>';
                appendHtml += '<div class="input-control text full-size" data-role="input">';
                appendHtml += '<span class="mif-calendar prepend-icon"></span>';
                appendHtml += '<input id="dateTimePicker-pref-start-' + nextId + '"';
                appendHtml += ' type="text" placeholder="Specify Start Time" onchange="changeDate(this.id)">';
                appendHtml += '<button class="button helper-button clear" tabindex="-1" type="button" onclick="clearDate(\'dateTimePicker-pref-start-' + nextId + '\')">';
                appendHtml += '<span class="mif-cross"></span>';
                appendHtml += '</button>';
                appendHtml += '</div>';
                appendHtml += '</div>';

                appendHtml += '<div class="cell">';
                appendHtml += '<label>End Time</label>';
                appendHtml += '<div class="input-control text full-size" data-role="input">';
                appendHtml += '<span class="mif-calendar prepend-icon"></span>';
                appendHtml += '<input id="dateTimePicker-pref-end-' + nextId + '" name="dateTimePicker-pref-end-' + nextId + '"';
                appendHtml += ' type="text" placeholder="Specify End Time" onchange="changeDate(this.id)">';
                appendHtml += '<button class="button helper-button clear" tabindex="-1" type="button" onclick="clearDate(\'dateTimePicker-pref-end-' + nextId + '\')">';
                appendHtml += '<span class="mif-cross"></span>';
                appendHtml += '</button>';
                appendHtml += '</div>';
                appendHtml += '</div>';

                appendHtml += '<div class="cell">';
                appendHtml += '<div style="margin-top: 20px" type="button" class="button" onclick="deleteTime(\'' + nextId + '\')">Delete</div>';
                appendHtml += '</div>';
                appendHtml += '</div>';

                $('#preferredTimes').append(appendHtml);

                $("#dateTimePicker-pref-start-" + nextId).AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
                $("#dateTimePicker-pref-end-" + nextId).AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});

                initDatePicker(nextId);
            }

            function changeDate(div)
            {
                for (var i = 0; i < startTimeDivIdArr.length; i++)
                {
                    if (startTimeDivIdArr[i] == div)
                    {
                        startTimeArr[i] = $('#' + div).val();
                    }
                }

                for (var i = 0; i < endTimeDivIdArr.length; i++)
                {
                    if (endTimeDivIdArr[i] == div)
                    {
                        endTimeArr[i] = $('#' + div).val();
                    }
                }

                $('#pref_end_arr').val(endTimeArr);
                $('#pref_start_arr').val(startTimeArr);
            }

            function clearDate(div)
            {
                for (var i = 0; i < startTimeDivIdArr.length; i++)
                {
                    if (startTimeDivIdArr[i] == div)
                    {
                        startTimeArr[i] = '';
                    }
                }

                for (var i = 0; i < endTimeDivIdArr.length; i++)
                {
                    if (endTimeDivIdArr[i] == div)
                    {
                        endTimeArr[i] = '';
                    }
                }

                $('#pref_end_arr').val(endTimeArr);
                $('#pref_start_arr').val(startTimeArr);
            }

            function showAddFrom()
            {
                $('.dialog-overlay').attr('style', 'z-index: 1071 !important');

                $('#user_id').val(<%= userProperties.getId()%>);
                var dialog = $('#add-location-dialog').data('dialog');

                dialog.open();
            }
            function closeLocForm()
            {
                $('.dialog-overlay').attr('style', 'z-index: 1070 !important');
                $('#locationName').val('');
                $('#locationText').val('');
                $('#add-location-dialog').data('dialog').close();

                // clearForm();
            }
            
            
                
        </script>
    </head>


    <div style="margin-top: 20px; margin-bottom: 20px;">
        <div class="grid" id="optimization-parameters-div">
            <!--new-->
            <div class="row cells3">
                <div class="cell">
                    <label><%=userProperties.getLanguage("from")%></label>
                    <span class="" onclick="showAddFrom();" style="float: right;color:#437DC6; text-decoration:underline; cursor: pointer">Add New</span>
                    <div class="input-control select full-size">
                        <select id="inputFromName">
                            <option value="0">- <%=userProperties.getLanguage("from")%> -</option>
                            <%
                                jobLocationDropDown.outputHTML(out, userProperties);
                            %>
                        </select>
                    </div>
                </div>
                        
                <div class="cell">
                    <label><%=userProperties.getLanguage("to")%></label>
                    <span class="" onclick="showAddFrom();" style="float: right;color:#437DC6; text-decoration:underline; cursor: pointer">Add New</span>
                    <div class="input-control select full-size">
                        <select id="inputToName">
                            <option value="0">- <%=userProperties.getLanguage("to")%> -</option>
                            <%
                                jobLocationDropDown.outputHTML(out, userProperties);
                            %>
                        </select>
                    </div>
                </div>
            </div>
                        
            <div class="row cells3">
                <div class="cell">
                    <label>Quantity</label>
                    <div class="input-control text full-size">
                        <input type="text" id="optQuantity" maxlength="50" placeholder="Quantity" value="0"></div>
                </div>
                <div class="cell">
                    <label>Duration(Minutes)</label>
                    <div class="input-control text full-size">
                        <input type="text" id="optDuration" maxlength="50" placeholder="Duration" value="0"></div>
                </div>
            </div>
            <!--new end-->
            <div class="row cells1">
                <h4 class="text-normal align-left">Preferred Timing</h4>
            </div>
            <div id="preferredTimes">
                <div class="row cells3 preferredTimeDiv" id="preferredTime-0">
                    <div class="cell">
                        <label>Start Time</label>
                        <div class="input-control text full-size" data-role="input">
                            <span class="mif-calendar prepend-icon"></span>
                            <input id="dateTimePicker-pref-start-0" name=""
                                   type="text" placeholder="Specify Start Time" onchange="changeDate(this.id)" value="<%=todayStart%>">
                            <button class="button helper-button clear" tabindex="-1" type="button" onclick="clearDate('dateTimePicker-pref-start-0')">
                                <span class="mif-cross"></span>
                            </button>
                        </div>
                        <script>$("#dateTimePicker-pref-start-0").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});</script>
                    </div>
                    <div class="cell">
                        <label>End Time</label>
                        <div class="input-control text full-size" data-role="input">
                            <span class="mif-calendar prepend-icon"></span>
                            <input id="dateTimePicker-pref-end-0" name="" val=""
                                   type="text" placeholder="Specify End Time" onchange="changeDate(this.id)" value="<%=todayEnd%>">
                            <button class="button helper-button clear" tabindex="-1" type="button" onclick="clearDate('dateTimePicker-pref-end-0')">
                                <span class="mif-cross"></span>
                            </button>
                        </div>
                        <script>
                            $("#dateTimePicker-pref-end-0").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
                        </script>
                    </div>
                    <div class="cell"></div>
                </div>
            </div>
            <div class="row cells1">
                <div style="margin-top: 20px" class="button" onclick="createNewTime()">Add Time Slot</div>
            </div>

            <input type="hidden" id="pref_start_arr">
            <input type="hidden" id="pref_end_arr">
            <!-- new -->
            <h4 class="text-normal align-left">Required Properties</h4>
            <%
                OptJobScheduleOptimization.getPropertyHtml(out, userProperties);
            %>
        </div>
    </div>
</html>
