<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.cust.biz.data.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    ListData data = (ListData) request.getAttribute("data");

    String lib = "v3nity.std.biz.data.plan";

    String type = "JobAutoschedulingList";

    data.onInstanceCreated(listProperties);
    
    int customerId = listProperties.getUser().getInt("customer_id");

    CountryDataHandler countryDataHandler = new CountryDataHandler();

    Data country = null;

    int pageLength = data.getPageLength();
    
    try
    { 
        Connection con = listProperties.getDatabasePool().getConnection();

        String countryCode = listProperties.getUser().getString("country").toUpperCase();

        countryDataHandler.setConnection(con);

        country = countryDataHandler.get(countryCode);
    }
    catch (Exception e)
    {
    }
    finally
    {
        countryDataHandler.closeConnection();
    }
%> 
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
        <link href="css/v3nity-timetable.css?v=${code}" rel="stylesheet">
        <style>
            #button-run-optimization
            {
                background-color: #d46e15; 
                color:#fff; 
                font-weight: bold;
            }
            #dialog-header
            {
                width: 100%; 
                background: #3b6dab; 
                color: #fff; 
                float: left;
            }
            .form-dialog-content.optimize
            {
                margin-top: 75px; 
                margin-left: 0; 
                margin-right: 0;
            }
            #dates-container
            {
               background: #437dc6; 
            }
            #job-summary
            {
                float: left;
                height: 300px;
            }
            #summary
            {
                padding-left: 15px; 
                max-height: 550px;
                overflow-y: scroll;
                border: 1px solid #eeeeee;
            }
            #summary::-webkit-scrollbar 
            {
                width: 0px; 
                background: transparent;
            }
            #summary-content
            {
                margin:5px;
            }
            .panel
            {
               padding-top: 10px; 
            }
            .panel .heading
            {
                background: #437dc6; 
                text-align: center; 
                height: 35px
            }
            .singleDate
            {
                float: left;
                background: #437DC6;
                color: #fff;
                width: fit-content;
                padding: 10px;
            }
            .unassigned
            {
                background: #bc1a1d;
            }

            .dateSelected
            {
                background: #000;
                font-weight: bold;
            }
            
            .staffSelected
            {
                color: #ffffff;
                font-weight: bold;
            }
            .timetable
            {
                max-height: 800px; 
                overflow-y: scroll; 
                border: 1px solid #eeeeee; 
                margin-left: 15px;
            }
            .timetable::-webkit-scrollbar 
            {
                width: 0px; 
                background: transparent;
            }
            .timetable aside li:hover
            {
                background-color: #437DC6;
                position: static;
                font-weight: bold;
            }            
            .timetable aside li.staffSelected
            {
                background-color: #437DC6;
                font-weight: bold;
            }
            .timetable aside a
            {
                color: #383838;
            }
            #collapsible-table
            {
                width:100%; 
                background: #3598db; 
                color: #fff; 
                border-top: solid 2px #fff;
            }
            th
            {
                color: #52677a;
                font-weight: bold;
                text-align: left;
            }
            .job-status
            {
                min-width: 0px;
                border-radius: 5px;
            }
            .job-status.selected 
            {
                background-color: #ffa128 !important;
                color: #fff !important;
            }
            .job-status:hover 
            {
                background-color: #ffa128 !important;
            }
            #resource-map
            {
                height: 540px;
            }
            #schedule-alert
            {
                width: auto;
                height: auto;
                padding: 0 50px 25px 50px;
            }
            .slider {
                -webkit-appearance: none;
                width: 100%;
                height: 15px;
                border-radius: 5px;   
                background: #d3d3d3;
                outline: none;
                opacity: 0.7;
                -webkit-transition: .2s;
                transition: opacity .2s;
            }

            .slider::-webkit-slider-thumb {
                -webkit-appearance: none;
                appearance: none;
                width: 25px;
                height: 25px;
                border-radius: 50%; 
                background: #d46e15;
                cursor: pointer;
            }

            .slider::-moz-range-thumb {
                width: 25px;
                height: 25px;
                border-radius: 50%;
                background: #d46e15;
                cursor: pointer;
                
            }
            .container {
              position: relative;
              padding-left: 35px;
              margin-bottom: 12px;
              cursor: pointer;
              -webkit-user-select: none;
              -moz-user-select: none;
              -ms-user-select: none;
              user-select: none;
            }

            .container input {
              position: absolute;
              opacity: 0;
            }

            .checkmark {
              position: absolute;
              top: 0;
              left: 0;
              height: 25px;
              width: 25px;
              background-color: #eee;
              border-radius: 50%;
            }

            .container:hover input ~ .checkmark {
              background-color: #ccc;
            }

            .container input:checked ~ .checkmark {
              background-color: #d46e15;
            }

            .checkmark:after {
              content: "";
              position: absolute;
              display: none;
            }

            .container input:checked ~ .checkmark:after {
              display: block;
            }
            .dialog.small 
            {
                height: 50% !important;
                top: 35% !important;
            }
            #inner-containter {
                
                 overflow: hidden;
            }
            
            .grid-container {
                display: grid;
                grid-template-columns: auto auto auto auto;
                padding: 10px;
                overflow-y: scroll;
                max-height:600px;
                position: relative;
              }
              .grid-item {
                background-color: rgba(255, 255, 255, 0.8);
                padding: 20px;
                font-size: 13px;
                text-align: left;
              }
        </style>
        <script type="text/javascript" src="js/jszip.min.js"></script>
        <script type="text/javascript" src="js/v3nity-timetable.js"></script>
        <script type="text/javascript">

        var isOptimizing = false;
        var stringentLevel = 5;
        var optimizationLevel = 2;
        var optimizationEngine = 1;
        var optimizeDistance = false;
        var optimizeSkillset = false;
        var resourceMap;
        var engineArr;
        var resourceArr; 
        var resourceopt;
            
    function showOptimizationTimetable()
    {
        isOptimizing = true;
        
        var resourceOptimize='';
        
       for(var i=0;i<resourceArr.length;i++){
           
           if(i>0){
               
               resourceOptimize+=',';
           }
           
           resourceOptimize+=resourceArr[i];
       }
       
        $.ajax({
            type: 'POST',
            url: 'JobAutoschedulingController?lib=<%=lib%>&type=JobScheduleOptimizationResult&format=json&action=optimize',
            data:
            {
                optimize : isOptimizing,
                stringentLevel : stringentLevel,
                optimizationLevel : optimizationLevel,
                optimizeDistance : optimizeDistance,
                optimizeSkillset : optimizeSkillset,
                optimizationEngine : optimizationEngine,
                optimizationResource: resourceOptimize
            },
            beforeSend: function () {

                $('#button-run-optimization').prop("disabled", true);
            },
            success: function (data) {

                if (data.result) {

                    timetableDialogData = data.timetable_data;
                   
                  } else {
                    dialog('Error', 'There are no jobs to optimize.', 'alert');
                }
            },
            error: function () {
                dialog('Error', 'System has encountered an error', 'alert');
            },
            complete: function () {

                $('#searching-dialog').data('dialog').close();
                
                document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: 0s';

                clearInterval(searchingIntervalVar);

                showTimetableDialog();

                $('#button-run-optimization').prop("disabled", false);
            },
            async: true
        });
        
    }


    /*
     *--------------------------------ADDITIONAL FUNCTIONS HERE----------------------------
     */
            
             function initMap() {
                map = new v3nityMap('map-view');

                map.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
            }
            
            
            function initResourceMap()
            {   
                resourceMap = new v3nityMap('resource-map');
                
                resourceMap.defaultOptions({bounds: [<%=country.getFloat("min_latitude")%>, <%=country.getFloat("min_longitude")%>, <%=country.getFloat("max_latitude")%>, <%=country.getFloat("max_longitude")%>]});
            }
            
            
            $("#removeOptimizeButton").click(function()
            {
                var table = $('#${namespace}-result-table').DataTable();

                var data = table.rows('.selected').ids();

                if (data.length > 0)
                {
                    var c = confirm("Are you sure you want to remove this job(s) from auto-schedule?");

                    if (c)
                    {
                        var ids = data.join();

                        $.ajax({
                            type: 'POST',
                            url:  'JobAutoschedulingController?lib=${lib}&type=${type}&action=removeFromOpt',
                            data: {
                                id : ids
                            },
                            success: function(data) {

                                var result = data.result;

                                if (result === true) {

                                    dialog('Success', data.text, 'success');

                                    refreshPageLength_${namespace}();

                                }
                                else {

                                    dialog('Failed', data.text, 'alert');
                                }
                            },
                            error: function() {
                                dialog('Error', 'System has encountered an error', 'alert');
                            },
                            async: true
                        });
                    }
                }
                else
                {
                    dialog('No Record Selected', 'Please select a record to delete', 'alert');
                }
            });
            
    /*
     *--------------------------------OPTIMIZATION FUNCTIONS HERE----------------------------
     */

        function scheduleOptResult() {

            $.ajax({
                type: 'POST',
                url: 'JobAutoschedulingController?lib=<%=lib%>&type=JobScheduleOptimizationResult&format=json&action=scheduleOptResult',
                data: {
                },
                beforeSend: function() {
                    $('#button-save').prop("disabled", true);
                },
                success: function(data) {

                    if (data.success && data.unassigned === "" && !data.warehouse) {
                        dialog('Success', 'All jobs have been scheduled', 'success');
                    }
                    else if (data.success && data.unassigned === "" && data.warehouse) {
                        dialog('Success', 'All jobs have been scheduled. \nPlease note return trips to warehouse will not be scheduled.', 'success');
                    }
                    else if (data.success && data.unassigned !== "") {
                        //create a permanent alert dialog
                        $('#schedule-alert').data('dialog').open();

                        html  = 'Unable to schedule job(s) ' + data.unassigned + '.</br></br>';
                        html += 'The rest of the jobs are scheduled.';
                        document.getElementById('schedule-alert-info').innerHTML = html;
                    }
                    else {
                        dialog('Error', 'Unable to schedule jobs', 'alert');
                    }
     
                    refreshPageLength_${namespace}();
                    
                },
                error: function() {
                    dialog('Error', 'System has encountered an error', 'alert');
                },
                complete: function() {
                    $('#button-save').prop("disabled", false);
                },
                async: false
            });

            closeTimetableDialog();
        }

            var searchingDialog;
            var searchingIntervalVar;
            var minutes;
            var seconds;
            var counter;
            var SELECTED_DATE;
            var SELECTED_RESOURCE_ID;
            
            function showOptimizationOptions()
            {
               $('#optimization-option-dialog').data('dialog').open();
               
               $('#optimization_engine0').prop('checked', true);
               
               selectOptimizationEngine();
            }

            function changeIterations(val)
            {
                var value = parseInt(val);
                
                var description='';
                
                if (value < 2)
                {
                    description = 'Less Balanced';
                }
                else if (value > 3)
                {
                    description = 'More Balanced';
                }
                else
                {
                    description = 'Balanced';
                }
                    
                document.getElementById('optimization_label').innerHTML = description;
            }
            
            function closeOptimizationOptions()
            {
                document.getElementById("optimization_level").value = 2;
                document.getElementById('optimization_label').innerHTML = 'Balanced';
                
                $('#optimization-option-dialog').data('dialog').close();
            }
            
            function runOptimization() 
            {
                optimizationLevel = $("#optimization_level").val();
                
                if (engineArr.length > 1)
                {
                    for (var i = 0; i < engineArr.length; i ++)
                    {
                        if($("#optimization_engine" + i).is(':checked'))
                        {
                            optimizationEngine = $("#optimization_engine" + i).val();
                        }
                
                    }
                }
                else if (engineArr.length === 1)
                {
                    optimizationEngine = engineValue;
                }
                else
                {
                    optimizationEngine = 1;
                }
                
                 if($("#optimize_distance").is(':checked'))
                {
                    optimizeDistance = true;
                }
                if($("#optimize_skillset").is(':checked'))
                {
                    optimizeDistance = false;
                    optimizeSkillset = true;
                }
                
                resourceArr=[]; 
                $('input[name="resource"]:checked').each(function() {
                    resourceArr.push(this.value);
                });
//console.log(resourceArr);
                
                
                
                if(resourceArr.length>0){
                    
                    closeOptimizationOptions();
                
                $.ajax({
                    type: 'POST',
                    url: 'JobAutoschedulingController?lib=<%=lib%>&type=JobSchedule&format=json&action=startOptCheck',
                    data: '',
                    beforeSend: function() {
                        $('#button-run-optimization').prop("disabled", true);
                    },
                    success: function(data) {

                        if (data.result) {
                            isOptimizing = true;

                            showOptimizingDialog();
                            
                            showOptimizationTimetable();
                        }
                        else {
                            dialog('Error', 'There are no jobs to optimize', 'alert');
                        }
                    },
                    error: function() {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function() {
                        $('#button-run-optimization').prop("disabled", false);
                    },
                    async: true
                });
                
                }
                else{
                          dialog('No Resource Selected', 'Please select a resource', 'alert');
                }
                
            }


            function cancelOptimization() {
                isOptimizing = false;
                document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: 0s';
                clearInterval(searchingIntervalVar);
                $('#searching-dialog').data('dialog').close();
            }

            function showOptimizingDialog() {
                document.getElementById('searching-dialog-text').innerHTML = 'Optimizing...';
                searchingDialog = $('#searching-dialog').data('dialog');
                searchingDialog.open();
                minutes = 0;
                seconds = 0;
                counter = 0;

                searchingIntervalVar = setInterval(function() {
                    var searchingText = document.getElementById('searching-dialog-text').innerHTML;
                    if (searchingText == 'Optimizing.......') {
                        searchingText = 'Optimizing..';
                    }
                    document.getElementById('searching-dialog-text').innerHTML = searchingText + '.';
                    counter++;
                    if (counter == 2) {
                        counter = 0;
                        seconds = seconds + 1;

                        if (seconds == 60) {
                            minutes = minutes + 1;
                            seconds = 0;
                        }

                        if (minutes == 0) {
                            document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: ' + seconds + 's';
                        }
                        else {
                            document.getElementById('time-elapsed').innerHTML = 'Time Elapsed: ' + minutes + 'm ' + seconds + 's';
                        }
                    }
                }, 500);
            }
    
            function showTimetableDialog()
            {
                $('#optimization-result-timetable-dialog').data('dialog').open();
               
                initResourceMap();
                
                populateOptDates();
            }
            
            function closeTimetableDialog()
            {
                $('#optimization-result-timetable-dialog').data('dialog').close();
                
                timetableDialogData = null;
                
                if (resourceMap !== null) {
                    resourceMap.remove();
                }
            }
  
            function changeSelectedDate(date)
            {
                $(".singleDate").each(function() {
                    $(this).removeClass('dateSelected');
                });
                
                $('#date_'+date).addClass('dateSelected');
                
                SELECTED_DATE = date;
                
                populateOptTimetable(date, null, null);
                document.getElementById('summary').style.display = "block";
            }
            
            
            function changeSelectedResource(driverId, populate)
            {
                $(".timetable-side-label").each(function() {
                    $(this).removeClass('staffSelected');
                    $(this).parent().parent().parent().removeClass('staffSelected');
                });
                
                
                $('#driver_label_'+driverId).addClass('staffSelected');
                $('#driver_label_'+driverId).parent().parent().parent().addClass('staffSelected');
               
                $('#summary_resource_name').html($('#driver_label_'+driverId).find('h4').html());

                SELECTED_RESOURCE_ID = driverId;
                
                var date= SELECTED_DATE;
                
                if (populate)
                {
                    populateJobDetails();
                }
            }
            
            
            
            function reloadResourceMap(jobsData)
            {
                if (resourceMap === null)
                {
                    resourceMap = new v3nityMap('resource-map');
                }
                
                resourceMap.removeAllSimpleMarker();
                
                var minLat, maxLat, minLng, maxLng;
                
                for (var i = 0; i < jobsData.length; i++) 
                {
                    var job = jobsData[i];
                    
                    if (parseFloat(job.lat, 10) <= 0.0 && parseFloat(job.lon, 10) <= 0.0)
                    {
                        continue;
                    }
                    
                    if (minLat === undefined && maxLng === undefined && maxLat === undefined && minLng === undefined) 
                    {
                        minLat = job.lat;
                        maxLat = job.lat;
                        minLng = job.lon;
                        maxLng = job.lon;
                    }
                    else 
                    {
                        minLat = Math.min(minLat, job.lat);
                        maxLat = Math.max(maxLat, job.lat);
                        minLng = Math.min(minLng, job.lon);
                        maxLng = Math.max(maxLng, job.lon);
                    }
                    
                    var popupHTML = '<div class="map-marker-popup text-light">' +
                            '<p>' + job.start + ' - ' + job.end + '</p>' +
                            '<p>' + job.location + '</p>' +
                            '</div>';

                    resourceMap.addNumberedMarker(job.lat, job.lon, popupHTML, 'green', (i+1), job.location);
                }
                    
                resourceMap.zoomBound(minLat, minLng, maxLat, maxLng);
            }
            
         
            function zoomResourceMap(driverId, jobIndex)
            {
                var driverData;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if(timetableDialogData[i].date == SELECTED_DATE)
                    {
                        driverData = timetableDialogData[i].drivers;
                        break;
                    }
                }
                
                if (driverData.length > 0)
                {
                    for (var i = 0; i < driverData.length; i++) 
                    {
                        var jobs = driverData[i].jobs;
                        var aDriverId = driverData[i].driver_id;
                        
                        if (aDriverId != driverId) continue;
                        
                        if (aDriverId != SELECTED_RESOURCE_ID)
                        {
                            changeSelectedResource(aDriverId, true)
                        }
                        
                        var lat = jobs[jobIndex].lat;
                        var lon = jobs[jobIndex].lon;
                        
                        resourceMap.zoomBound(lat, lon, lat, lon);
                        
                        break;
                    }
                }
            }
            
            function changeSummaryContent(driverId, jobIndex)
            {
                 var driverData;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if(timetableDialogData[i].date == SELECTED_DATE)
                    {
                        driverData = timetableDialogData[i].drivers;
                        break;
                    }
                }
                
                var html = '';
                
                if (driverData.length > 0)
                {
                    for (var i = 0; i < driverData.length; i++) 
                    {
                        var jobs = driverData[i].jobs;
                        var aDriverId = driverData[i].driver_id;
                        
                        if (aDriverId != driverId) continue;
                        
                        if (aDriverId != SELECTED_RESOURCE_ID)
                        {
                            changeSelectedResource(aDriverId, true);
                        }
                        
                    html += '<div class="row cells1">';
                    html += '<div class="cell">';
                    html += '<table class="dataTable striped border bordered hovered no-footer dtr-inline">';
                    html += '<tr><th>Job Id</th><td>' + jobs[jobIndex].jobId + '</td></tr>';
                    html += '<tr><th>Scheduled Time</th><td>' + jobs[jobIndex].start + ' - ' + jobs[jobIndex].end + '</td></tr>';
                    if(jobs[jobIndex].description !== null)
                    {
                        html += '<tr><th>Description</th><td>' + jobs[jobIndex].description + '</td></tr>';
                    }
                    if(jobs[jobIndex].reference !== "")
                    {
                        html += '<tr><th>Reference</th><td>' + jobs[jobIndex].reference + '</td></tr>';
                    }
                    if (jobs[jobIndex].location !== null)
                    {
                        html += '<tr><th>Location</th><td>' + jobs[jobIndex].location + '</td></tr>';
                    }
                    if ((jobs[jobIndex].capacity !== null) || (typeof jobs[jobIndex].capacity !== 'undefined') || (typeof jobs[jobIndex].capacity !== 'null'))
                    {
                        html += '<tr><th>Capacity</th><td>' + jobs[jobIndex].capacity + '</td></tr>';
                    }
                    html += '<tr><th>Duration (Mins)</th><td>' + jobs[jobIndex].duration + '</td></tr>';
                    html += '</table></div>';
                    html += '</div>';
                    
                    document.getElementById('summary_total_distance').innerHTML = jobs[jobIndex].distance;
                    document.getElementById('summary_total_time').innerHTML = jobs[jobIndex].time;  
                }
                
                document.getElementById('summary-content').innerHTML = html;   
            }
        }
            
            
            function populateJobDetails()
            {
                var jobsData;
                var totalDistance;
                var totalTime;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if (timetableDialogData[i].date == SELECTED_DATE)
                    {
                        for (var j = 0 ; j < timetableDialogData[i].drivers.length ; j++)
                        {
                            if (timetableDialogData[i].drivers[j].driver_id == SELECTED_RESOURCE_ID)
                            {
                                totalDistance = timetableDialogData[i].drivers[j].total_distance;
                                totalTime = timetableDialogData[i].drivers[j].total_time;
                                jobsData = timetableDialogData[i].drivers[j].jobs;
                                break;
                            }
                        }
                        break;
                    }
                }
                
                var html = '';
                
                for (var i = 0 ; i < jobsData.length ; i++)
                {
                    var job = jobsData[i];
                    
                    if (i > 0)
                    {
                        html += '<div class="row cells1" style="background: #ddd;"';
                            if (parseFloat(job.distance, 10) > 0.0)
                            {
                                html += '<div class="cell"><center> ' + job.distance + ', ' + job.time + '</center></div>';
                            }
                            else
                            {
                                html += '<div class="cell"><center> 0 Km, ' + job.time + '</center></div>';
                            }
                        html += '</div>';
                    }
                    
                    html += '<div class="row cells1">';
                        html += '<div class="cell">';
                            html += '<h5>' + '[' + (i+1) + '] ' + job.start + ' - ' + job.end + '</h5>';
                            if (job.location == null)
                            {
                                html += '<p><i>---location not specified--</i></p>';
                            }
                            else
                            {
                                html += '<p>' + job.location + '</p></br>';
                            }
                        html += '</div>';
                    html += '</div>';
                }
                
                document.getElementById('summary_total_distance').innerHTML = totalDistance;
                document.getElementById('summary_total_time').innerHTML = totalTime;
                document.getElementById('summary-content').innerHTML = html;

                reloadResourceMap(jobsData);
            }
            
            
            function populateOptDates()
            {
                var html = "";
                var unassignedData = null;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    html += '<a href="#">';
                    
                    html += '<div class="singleDate" id="date_' + timetableDialogData[i].date 
                            + '" onclick="changeSelectedDate(\'' + timetableDialogData[i].date + '\')">' + timetableDialogData[i].date_formatted + '</div>';
                        
                    html += '</a>';
                    
                    if (typeof timetableDialogData[i].unassigned !== 'undefined')
                    { 
                        unassignedData = timetableDialogData[i].unassigned;

                        html += '<a href="#">';

                        html += '<div class="singleDate unassigned" id="date_' + timetableDialogData[i].date + '_unassigned"'
                                + 'onclick="showUnassignedJobs(\''+ timetableDialogData[i].date + '\')">' + timetableDialogData[i].date_formatted + ' Unassigned Jobs</div>';

                        html += '</a>';
                    }
                }
                
                document.getElementById('dates-container').innerHTML = html;
                
                changeSelectedDate(timetableDialogData[0].date);
            }
            
            
            
            function populateOptTimetable(selectedDate, driverIndex, jobIndex)
            {
                var driverData;
                
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if(timetableDialogData[i].date === selectedDate)
                    {
                        driverData = timetableDialogData[i].drivers;
                        break;
                    }
                }
                
                if (driverData.length > 0)
                {
                    var timetable = new Timetable();

                    timetable.setScope(8, 20);

                    var drivers = [], htmls = [], html;

                    for (var i = 0; i < driverData.length; i++) 
                    {
                        drivers.push(driverData[i].driver_id);

                        html = '<a href="#"><div class="timetable-side-label"'
                                    + 'id="driver_label_' + driverData[i].driver_id + '" '
                                    + 'onclick="clickSideBar(\'' + driverData[i].driver_id + '\');"><div>'
                                    + '<h4 class="text-bold">' + driverData[i].resource_name + '</h4>'
                                    + '<h6>Jobs: ' + driverData[i].jobs.length + '</h6>'
                                    + '</div></div></a>';
                        htmls.push(html);
                    }
                    
                    timetable.addLocations(drivers, htmls);
                    
                    for (var i = 0; i < driverData.length; i++) 
                    {
                        var jobs = driverData[i].jobs;
                        var driverId = driverData[i].driver_id;
                        
                        for (var j = 0 ; j < jobs.length ; j++)
                        {
                            var job = jobs[j];
                            
                            var startTime = job.start.split(':');
                            var endTime = job.end.split(':');

                            if(driverId===driverIndex && j===jobIndex)
                            {
                                timetable.addEvent
                                   (
                                       job.location,
                                       driverId,
                                       new Date(1970, 0, 1, startTime[0], startTime[1]),
                                       new Date(1970, 0, 1, endTime[0], endTime[1]),
                                       '#',
                                       'job-status selected',
                                       (function(driverId, jobIndex) {
                                           return function() {

                                           };
                                       })(driverId, j)
                                   );
                            }
                            else
                            {
                                timetable.addEvent
                                (
                                    job.location,
                                    driverId,
                                    new Date(1970, 0, 1, startTime[0], startTime[1]),
                                    new Date(1970, 0, 1, endTime[0], endTime[1]),
                                    '#',
                                    'job-status ' + job.status,
                                    (function(driverId, jobIndex) {
                                        return function() {
                                            zoomResourceMap(driverId, jobIndex);
                                            changeSummaryContent(driverId, jobIndex);
                                            populateOptTimetable(selectedDate, driverId, jobIndex);
                                            changeSelectedResource(driverId, false);
                                        };
                                    })(driverId, j)
                                );
                            }
                        }
                    }
                    
                    var renderer = new Timetable.Renderer(timetable);

                    renderer.draw('#opt-timetable');

                    $('#opt-timetable').show();
                    
                    if (driverIndex === null & jobIndex === null)
                    {
                        changeSelectedResource(driverData[0].driver_id, true);
                    }
                }
            }
           
           function clickSideBar(driverId)
           {
               populateOptTimetable(SELECTED_DATE, null, null);
               changeSelectedResource(driverId, true);
           }
            
   
           function showUnassignedJobs(date)
           {
               $(".singleDate").each(function() {
                    $(this).removeClass('dateSelected');
                });
                
                $("#date_"+date+"_unassigned").addClass('dateSelected');
               
               var unassignedData = null;
               
                for (var i = 0 ; i < timetableDialogData.length; i++)
                {
                    if (timetableDialogData[i].date === date)
                    {
                        unassignedData = timetableDialogData[i].unassigned;
                    }
                }
        
                var html = '';
                html += '<div class="help-tag" style="margin: 10px"><p>Note: Unassigned jobs will not be scheduled.</p></div>';
                html += '<div class="unassigned-table" style="margin: 20px">';
                html += '<h2 class="text-light">' + unassignedData.length + ' Unassigned Job(s)</h2>' ;
                html += '<table class="dataTable striped border bordered hovered no-footer dtr-inline">';
                    html += '<thead>';
                        html += '<tr>';
                            html += '<th class="sortable-column">Index</th>';
                            html += '<th class="sortable-column">Job Id</th>';
                            html += '<th class="sortable-column">Description</th>';
                            html += '<th class="sortable-column">Location</th>';
                            html += '<th class="sortable-column">Time Preferences</th>';
                            html += '<th class="sortable-column">Capacity</th>';
                            html += '<th class="sortable-column">Duration(Mins)</th>';
                        html += '</tr>';
                    html += '</thead><tbody>';
                
                var ind = 1;
                for (var i = 0 ; i < unassignedData.length ; i++)
                {
                    var job = unassignedData[i];
                    
                        html += '<tr>';
                            html += '<td>' + ind + "</td>";
                            html += '<td>' + job.jobId + "</td>";
                            html += '<td>' + job.description + "</td>";
                            html += '<td>' + job.location + "</td>";
                            html += '<td>' + job.timePrefStart + " - " + job.timePrefEnd + "</td>";
                            html += '<td>' + job.capacity + "</td>";
                            html += '<td>' + job.duration + "</td>";
                        html += '</tr>';
                        ind ++;

                }
                html += '</tbody></table></div>';
                
                reloadResourceMap(unassignedData);
                document.getElementById('opt-timetable').innerHTML = html;
                document.getElementById('summary').style.display = "none";
        }

        var engineValue;

        function selectOptimizationEngine()
        {
            $.ajax({
                   type: 'POST',
                   url: 'JobAutoschedulingController',
                   data: {
                       type: 'system',
                       action: 'getOptEngine'
                   },
                   success: function(data) {
   
                        engineArr = data.engine;
                        resourceopt = data.resource;
                       
                        
                   },

                   error: function() {
                       //dialog('Error', 'System has encountered an error', 'alert');
                   },
                   complete: function() {

                   },
                   async: false
               });
               
            var html = '';
           // var res = ["Resource 1","Resource 2","Resource 3","Resource 4"]
                //,"Resource 1","Resource 2","Resource 3","Resource 4","Resource 1","Resource 2","Resource 3","Resource 4","Resource 1","Resource 2","Resource 3","Resource 4","Resource 1","Resource 2","Resource 3","Resource 4","Resource 1","Resource 2","Resource 3","Resource 4","Resource 1","Resource 2","Resource 3","Resource 4"];
            if (engineArr.length > 1)
            {
                html +='<div class="row cells2" style="margin-top:50px;">';
                html +='<label class="text-bold">Optimization Engine</label>';
                html +='<div class="help-tag"><p>Select the optimization engine to use.</p></div>';
                html +='<div class="input-control radio big-check" style="margin-top:30px;">';
                
                for(var i = 0; i < engineArr.length; i++)
                {
                    var engineId = engineArr[i].id;
                    var engineName = engineArr[i].name;

                    html += '<label class="container" style="margin-right: 20px">';
                    html += '<input type="radio" name="optimization_engine" id="optimization_engine' + i + '" value="' + engineId + '"/>';
                    html += '<span class="checkmark"></span>&nbsp;' + engineName;
                    html += '</label>';
                }    
                html += '</div>';

                
            }
            else if (engineArr.length === 1)
            {
                engineValue = engineArr[0].id;
            }
            
            if(resourceopt.length>0){
            html+='<div id="inner-containter"><label class="text-bold"><br>Resource</label>';
                html +='<div class="grid-container">'
               
                for(var i = 0; i < resourceopt.length; i++)
                {
                    var driverId=resourceopt[i].id;
                    var resourceName = resourceopt[i].name;
                    
                    html += '<div class="grid-item">';
                    html += '<label class="input-control checkbox">';
                    html += '<input id="resource"'+i+'" name="resource" value="'+driverId+'" type="checkbox" checked="checked">';
                    html += '<span class="check"></span>';
                    html += ' <span class="caption">'+resourceName+'</span>';
                    html += '</label></div>';
               // html += '<div class="grid-item"><input type="checkbox" name="resource" id="resource'+i+'" value="'+driverId+'" checked="checked">&nbsp;'+resourceName+'</div>';
              
                }
                html +='</div></div>';
                html += '</div>';
                
            }else{
                
                 html += '</div>';
                }
            
            document.getElementById('optimization_table_check').innerHTML = html;
            
        }
            
            
        </script>   
    </head>
    <body>
        <div class="toolbar-section">
            
            <button class="toolbar-button" type="button" id=removeOptimizeButton name="removeOptimizeButton" title="<%=listProperties.getLanguage("removeFromAutoSchedule")%>"><span class="mif-cross"></span></button>
    
            <button type="button" class="button"  style="background-color: #d46e15; color:#fff; font-weight: bold;" onclick="showOptimizationOptions()" title= "Autoschedule Jobs" > Auto-schedule Jobs </button>
        
        </div>
    <!--this is the div to exit the toolbar section -- DO NOT REMOVE-->    
    </div>
    <!--this is the div to exit the toolbar section -- DO NOT REMOVE-->
    
        <div class="help-tag">
            <h4>Instructions:</h4>
            <p>To add jobs for auto-scheduling, select jobs in <b>Plan - Job Schedule</b> page. </p>
            <p>Click the  <span class="mif-target"></span> button to set for auto-schedule. </p>
            <p>Jobs set to auto-schedule listed below: </p>
        </div>
    
        <div data-role='dialog' id="optimization-option-dialog" class="medium" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light">Optimization Options</h1>
                <div class="form-dialog-content" style="margin-top: 110px;">

                    <div class="row cells1">
                        <div class="cell">
                            <label class="text-bold">Workload balancing</label>
                            <div class="slidecontainer" style= "margin-top: 50px;">
                                <input type="range" id="optimization_level" min="1" max="4" value="2" class="slider" oninput="changeIterations(this.value)">
                                <span id="optimization_label">Balanced</span>
                            </div>
                        </div>
                    </div>
                   
                    <div id="optimization_table_check"></div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button id=button-run-optimization button type="button" class="button" onclick="runOptimization()"><%=listProperties.getLanguage("runOptimization")%></button>
                <button id=button-cancel-options type="button" class="button" onclick="closeOptimizationOptions()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>
                
        <div data-role="dialog" id="searching-dialog" class="tiny" data-close-button="false" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog">
                <h1 class="text-light" id="searching-dialog-text"></h1>
                <p id="time-elapsed">Time Elapsed: 0s</p>
                <img src="img/loader.gif" alt="Loader" style="width:128px; height:128px; margin: 80px">
            </div>
        </div>
            
        <div data-role="dialog" id="optimization-result-timetable-dialog" class="large" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog" style="padding:0">
                <div id="dialog-header">
                    <h1 class="text-light" style="margin-left:16px; padding-bottom: 0">Optimization Result</h1>
                </div>
   
                <div class="form-dialog-content optimize">
                    <div class="grid condensed" style="margin-top: 0">
                    
                     <div class="row cells" id="dates-container"></div>
                     
                        <div class="row cells12" style="margin-top: 10px">
                            <div class="cell colspan10">
                                <div id="opt-timetable" class="timetable"></div>
                            </div>

                            <div class="cell colspan2" id="summary">

                                <div class="panel collapsible collapsed" data-role="panel">
                                    <div class="heading">
                                        <span class="title" id="summary_resource_name"></span>
                                    </div>

                                    <div class="content" style="padding: 0">
                                        <table id="collapsible-table">
                                            <tr>
                                                <th style="color: #fff; padding: 5px; width: 50%;">DISTANCE</th>
                                                <th style="color: #fff; padding: 5px; width: 50%; border-left: solid 2px #fff;">TRAVEL TIME</th>
                                            </tr>
                                            <tr>
                                                <td ><h4 id="summary_total_distance" style="text-align:center; margin-bottom: 0"></h4></td>
                                                <td style="border-left: solid 2px #fff;"><h4 id="summary_total_time" style="text-align:center; margin-bottom: 0"></h4></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            
                            <div id="summary-content"></div>
                        </div>
                    </div>

                        <div class="row cells5" style="padding-top: 15px"> 
                            <div id="resource-map"> </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="form-dialog-control">
                <button type="button" class="button primary" onclick="scheduleOptResult()"><%=listProperties.getLanguage("schedule")%></button>
                <button type="button" class="button" onclick="closeTimetableDialog()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>
      
        <div data-role="dialog" id="location-dialog" class="large" data-close-button="true" data-background="bg-white">
            <div id ="container">
                <div id="map-view" class="map-dialog full-size"></div>
                <ul id="infoi" class="t-menu compact place-right">
                    <li><a href="#" onclick="map.zoomIn()" title="<%=listProperties.getLanguage("zoomIn")%>"><span class="icon mif-plus"></span></a></li>
                    <li><a href="#" onclick="map.zoomOut()" title="<%=listProperties.getLanguage("zoomOut")%>"><span class="icon mif-minus"></span></a></li>
                    <li><a href="#" onclick="map.zoomToDefault()" title="<%=listProperties.getLanguage("zoomDefault")%>"><span class="icon mif-target"></span></a></li>
                </ul>
            </div>
        </div>
                
        <div data-role="dialog" id="schedule-alert" class="dialog warning" data-close-button="true" data-type="warning">
            <h1>Error</h1>
            <div id ="schedule-alert-info"></div>
        </div>
    </body>
</html>
