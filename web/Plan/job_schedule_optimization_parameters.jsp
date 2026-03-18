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

    ListData data = new JobScheduleOptimizationParameters();

    ListForm listForm = new ListForm();

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    Connection con = null;

    java.util.Date today = new java.util.Date();
    SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("dd/MM/yyyy");

    String todayStart = dateOnlyFormat.format(today) + " 00:00:00";
    String todayEnd = dateOnlyFormat.format(today) + " 23:59:59";

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <script type="text/javascript">

            var startTimeArr = [];
            var endTimeArr = [];
            var startTimeDivIdArr = [];
            var endTimeDivIdArr = [];
            var todayDate;

            $(document).ready(function()
            {                
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

                document.getElementById('optimization-parameters-div').style.display = "none";
                document.getElementById('button-hide-param').style.display = "none";
                document.getElementById('button-show-param').style.display = "inline-block";
            });

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
                $("#dateTimePicker-pref-start-" + id).val(todayDate + ' 00:00:00');
                $("#dateTimePicker-pref-end-" + id).val(todayDate + ' 23:59:59');

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
                appendHtml += '<input id="dateTimePicker-pref-start-' + nextId + '" name="dateTimePicker-pref-start-' + nextId + '"';
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

        </script>
    </head>


    <div style="margin-top: 20px; margin-bottom: 20px;">
        <h1 class="text-light"><%=userProperties.getLanguage("optimizationParameters")%></h1>
        <div id="button-show-param" class="button primary" onclick="showParam()">Show Parameters</div>
        <div id="button-hide-param" class="button primary" onclick="hideParam()">Hide Parameters</div>
        <div class="grid" id="optimization-parameters-div">
            <div class="row cells1">
                <h4 class="text-normal align-left">Preferred Timing</h4>
            </div>
            <div id="preferredTimes">
                <div class="row cells3 preferredTimeDiv" id="preferredTime-0">
                    <div class="cell">
                        <label>Start Time</label>
                        <div class="input-control text full-size" data-role="input">
                            <span class="mif-calendar prepend-icon"></span>
                            <input id="dateTimePicker-pref-start-0" name="dateTimePicker-pref-start-0"
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
                            <input id="dateTimePicker-pref-end-0" name="dateTimePicker-pref-end-0" val=""
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

            <input type="hidden" name="pref_start_arr" id="pref_start_arr">
            <input type="hidden" name="pref_end_arr" id="pref_end_arr">

            <div class="row cells1">
                <h4 class="text-normal align-left">Job Capacity</h4>
            </div>
                    
                    
            <%
                try
                {
                    con = userProperties.getConnection();

                    dataHandler.setConnection(con);

                    listForm.outputHtml(userProperties, data, dataHandler, out);
                    data.outputHtml(userProperties, out);
                }
                catch (Exception e)
                {
                    //System.out.println("job_schedule_optimization_parameters unable to establish connection");
                }
                finally
                {
                    userProperties.closeConnection(con);
                }
            %>

            <div data-role="dialog" id="location-dialog" class="large" data-close-button="true" data-background="bg-white">
                <div id ="container">
                    <div id="map-view" class="map-dialog full-size"></div>
                    <ul id="infoi" class="t-menu compact place-right">
                        <li><a href="#" onclick="map.zoomIn()" title="<%=userProperties.getLanguage("zoomIn")%>"><span class="icon mif-plus"></span></a></li>
                        <li><a href="#" onclick="map.zoomOut()" title="<%=userProperties.getLanguage("zoomOut")%>"><span class="icon mif-minus"></span></a></li>
                        <li><a href="#" onclick="map.zoomToDefault()" title="<%=userProperties.getLanguage("zoomDefault")%>"><span class="icon mif-target"></span></a></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>


</html>