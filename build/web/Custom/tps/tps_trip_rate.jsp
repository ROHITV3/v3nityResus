<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");

    ListData data = (ListData) request.getAttribute("data");

    MetaData metaDataSubType = (MetaData) request.getAttribute("metaDataSubType");

    boolean add = (boolean) request.getAttribute("add");

    boolean update = (boolean) request.getAttribute("update");

    boolean delete = (boolean) request.getAttribute("delete");

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <!--<title>${title}</title>-->
        <script type="text/javascript" src="Custom/tps/tps_trip_calculator.js"></script>
        <style>
            .modal {
                display: none;
                position: fixed;
                z-index: 20;
                padding-top: 100px;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                overflow: auto;
                background-color: rgb(0,0,0);
                background-color: rgba(0,0,0,0.4);
            }


            .modal-content {
                background-color: #fefefe;
                margin: auto;
                padding: 20px;
                border: 1px solid #888;
                width: 75%;
                height:75%;
                overflow-y: auto;
            }

            .close {
                color: #aaaaaa;
                float: right;
                font-size: 28px;
                font-weight: bold;
                top: -302px;
                left: -605px;
            }

            .close:hover,
            .close:focus {
                color: #000;
                text-decoration: none;
                cursor: pointer;
            }


            .loader_div{

                background-image: url('img/uploading.gif');
            }





        </style>
      
        <script type="text/javascript">
            var modal = document.getElementById("myModal");
         

            $(document).ready(function ()
            {
                // Get the <span> element that closes the modal
                var span = document.getElementsByClassName("close")[0];



// When the user clicks on <span> (x), close the modal
                span.onclick = function () {
                    modal.style.display = "none";
                }

// When the user clicks anywhere outside of the modal, close it
                window.onclick = function (event) {
                    if (event.target === modal) {
                        modal.style.display = "none";
                    }
                }
             

           

                //     every ajax call, turn off the draw event otherwise,
                //     all rows will be selected from the table upon selecting buttons within the table.
                //     there is something wrong with the datatable with server side processing.
              
            });

         

            $("input[id^=dateTimePicker]").change(function ()
            {

                $('#${namespace}-email-button').prop("disabled", false);
            });

     

            function dispose()
            {
                // whenever reload, we need to release resource for id with the datetimepicker prefix...
                $('[id^="dateTimePicker"]').each(function (index, elem)
                {
                    $(elem).AnyTime_noPicker();
                });

                // we need to dispose the callback function otherwise other jsp will get affected...
                 tripMap=null;
                ondatasuccess = null;
            }

 






//            function influencerChanged()
//            {
//                if (this.value === '')
//                {
//                    return;
//                }
//
//                var metadataIndex = $(this).attr('data-influenced-metadata-index');
//
//                $.ajax({
//                    type: 'POST',
//                    url: 'TpsTripRateController?lib=${lib}&type=${type}&action=influence',
//                    data: {
//                        index: metadataIndex,
//                        foreign: this.value
//                    },
//                    beforeSend: function ()
//                    {
//
//                    },
//                    success: function (data)
//                    {
//                        if (data.expired === undefined)
//                        {
//                            if (data.result === true)
//                            {
//                                var element = $('select[name="' + data.identifier + '"');
//
//                                element.html('');
//
//                                for (var i = 0; i < data.options.length; i++)
//                                {
//                                    var option = data.options[i];
//
//                                    element.append('<option value=' + option.id + '>' + option.value + '</option>');
//                                }
//                            } else
//                            {
//                                dialog('Failed', data.text, 'alert');
//                            }
//                        }
//                    },
//                    error: function ()
//                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
//                    },
//                    complete: function ()
//                    {
//
//                    },
//                    async: false
//                });
//            }
            function closeDialog() {
                modal.style.display = "none"
            }


       
            var submit_id = "";
            var from_site = "";
            var location_site = "";
            var to_site = "";
            var material_site = "";
            
            var from_site_id = "";
            var location_site_id = "";
            var to_site_id = "";
            var material_site_id = "";
            
            function calculatetriprate(id) {
                submit_id = id;
//                modal.style.display = "block"
                $('.modal-content').css("width", "95%");
                $('.modal-content').css("height", "109%");
                $('.modal-content').css("margin-top", "-5%");
                var table = $('#${namespace}-result-table').DataTable();

                var rowSelector = "" + id;

                var row = table.row('#'+id);
                var row_data = row.data();

                from_site = row_data[3];
                location_site = row_data[5];
                to_site = row_data[7];
                material_site = row_data[9];

                setTimeout(function () {
                    openTripMap(from_site, location_site, to_site, material_site, callBackTripMap)
                }, 100);
                
//                getmateraldetails(from_site,location_site,to_site,material_site);
                getmateraldetails3(id);
//                $('.modal-content').append("<BR/><BR/><BR/>");
            }
            
                        function getmateraldetails3(id){
                    $.ajax({
                    type: 'POST',
                    url: 'tps?type=triprate&action=' + 'getdetails3' + '&rowId=' + id,
//                 
                    beforeSend: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                       
//                  console.log(data);
                        var jsondata = data.material_site;
                        console.log(jsondata);

                        material_site_id = jsondata;
                        var jsondata = data.from_site;
                        console.log(jsondata);
                        from_site_id = jsondata;
                        var jsondata = data.location_site;
                        console.log(jsondata);
                        location_site_id = jsondata;
                        var jsondata = data.to_site;
                        console.log(jsondata);
                        to_site_id = jsondata;
                           
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", false);
                    },
                    async: true
                });
                
            }
            
            function getmateraldetails(from_site1,location_site1,to_site1,material_site1){
                    $.ajax({
                    type: 'POST',
                    url: 'tps?type=triprate&action=' + 'getdetails' + '&from_site=' + from_site1+ '&location_site=' + location_site1+ '&to_site=' + to_site1
                    + '&material_site=' + material_site1,
//                 
                    beforeSend: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                       
//                  console.log(data);
                        var jsondata = data.material_site;
                        console.log(jsondata);

                        material_site_id = jsondata;
                        var jsondata = data.from_site;
                        console.log(jsondata);
                        from_site_id = jsondata;
                        var jsondata = data.location_site;
                        console.log(jsondata);
                        location_site_id = jsondata;
                        var jsondata = data.to_site;
                        console.log(jsondata);
                        to_site_id = jsondata;
                           
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", false);
                    },
                    async: true
                });
                
            }
             function duplicatetriprate(id) {
                 var c = confirm("Are you sure you want to duplicate selected record?");

                    if (c === true)
                    {
              $.ajax({
                    type: 'POST',
                    url: 'TpsTripRateRequestAndApprovalController?lib=${lib}&type=TpsTripRate&action=' + 'duplicaterecord' + '&id=' + id,
//                    data: {trip_rate_id: submit_id,
//                        loading_site_id: fromSiteTd,
//                        loading_site_location_id: locationTd,
//                        unloading_site_id: toSiteTd,
//                        material_type_id:materialTd,
//                        travel_distance: distance,
//                        travel_time: duration,
//                        hook_rate: hookRate,
//                        waiting_time_rate: waitingRate,
//                        trip_rate: tripRate,
//                        total_rate: totalRate},
                    beforeSend: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
closeTripMap();
                                refreshDataTable_${namespace}();
//
//                                closeForm_${namespace}();
                            } else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        } else
                        {
                            closeForm_${namespace}();
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", false);
                    },
                    async: true
                });
                }
            }
            

     function submitTpsRequestandApproval() {
          var fromSiteTd = $("#fromSiteTd").children().val();
//                var locationTd = $("#locationTd").children().val();
//                var toSiteTd = $("#toSiteTd").children().val();
//                var materialTd = $("#materialTd").children().val();
                var distance = $("#travelDistanceTd").children().val();
                var duration = $("#travelTimeTd").children().val();
                var hookRate = $("#hookTd").children().val();
                var waitingRate = $("#waitingTimeTd").children().val();
                var tripRate = $("#tripRateTd").children().val();
                var totalRate = $("#totalRateTd").text();
            console.log("Adding row 1: "+distance+"  "+duration+" "+hookRate+" "+waitingRate+"  "+tripRate+"  "+totalRate)
//                var fromSiteTd = $("select[name='loading_site_id'] option:contains('" + from_site + "')").val();
                                var fromSiteTd =from_site_id;

                $("select[name='loading_site_id']").val(fromSiteTd).change();
//                var locationTd = $("select[name='loading_site_location_id'] option:contains('" + location_site + "')").val();
//                var toSiteTd = $("select[name='unloading_site_id'] option:contains('" + to_site + "')").val();
//                var materialTd = $("select[name='material_type_id'] option:contains('" + material_site + "')").val();
                    var locationTd =location_site_id;
                var toSiteTd =  to_site_id  ;
                var materialTd =  material_site_id;
 console.log(locationTd)
 if(tripRate != "" && tripRate != undefined){
                $.ajax({
                    type: 'POST',
                    url: 'TpsTripRateRequestAndApprovalController?lib=${lib}&type=TpsTripRateRequestAndApproval&action=' + 'add' + '&id=' + submit_id,
                    data: {trip_rate_id: submit_id,
                        loading_site_id: fromSiteTd,
                        loading_site_location_id: locationTd,
                        unloading_site_id: toSiteTd,
                        material_type_id:materialTd,
                        travel_distance: distance,
                        travel_time: duration,
                        hook_rate: hookRate,
                        waiting_time_rate: waitingRate,
                        trip_rate: tripRate,
                        total_rate: totalRate},
                    beforeSend: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
closeTripMap();
//                                refreshPageLength_${namespace}();
//
//                                closeForm_${namespace}();
                            } else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        } else
                        {
                            closeForm_${namespace}();
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", false);
                    },
                    async: true
                });
            }else{
            alert("Calculate distance once")
            }
//                
//               
            }

            function callBackTripMap(distance, duration, hookRate, waitingRate, tripRate, totalRate) {
                console.log("Adding row 2: "+distance+"  "+duration+" "+hookRate+" "+waitingRate+"  "+tripRate+"  "+totalRate)
       var fromSiteTd =from_site;
       $("select[name='loading_site_id']").val(fromSiteTd).change();
                 var locationTd =location_site;
                var toSiteTd =  to_site  ;
                var materialTd =  material_site;
 console.log(locationTd)
 if(tripRate != "" && tripRate != undefined){
                $.ajax({
                    type: 'POST',
                    url: 'TpsTripRateRequestAndApprovalController?lib=${lib}&type=TpsTripRateRequestAndApproval&action=' + 'add' + '&id=' + submit_id,
                    data: {trip_rate_id: submit_id,
                        loading_site_id: fromSiteTd,
                        loading_site_location_id: locationTd,
                        unloading_site_id: toSiteTd,
                        material_type_id:materialTd,
                        travel_distance: distance,
                        travel_time: duration,
                        hook_rate: hookRate,
                        waiting_time_rate: waitingRate,
                        trip_rate: tripRate,
                        total_rate: totalRate},
                    beforeSend: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');

//                                refreshPageLength_${namespace}();
//
//                                closeForm_${namespace}();
                            } else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        } else
                        {
                            closeForm_${namespace}();
                        }
                    },
                    error: function ()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#${namespace}-button-save').prop("disabled", false);
                    },
                    async: true
                });
            }else{
            alert("Calculate distance once")
            }
            }

          

        </script>
    </head>
    <body>
    
        <div>
            <!--<h1 class="text-light"><%=listProperties.getLanguage(data.getDisplayName())%><span id='list-sub-title'></span></h1>-->
            <div data-role="dialog" id="trip-map-dialog" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark" style="padding: 8px;z-index: 1101 !important;" class="dialog bg-white" data-master="true">

                <div id="trip-map" style="width: 100%; height: 100%"></div>

                <div id="submit-btn" onclick="submitTpsRequestandApproval()">SUBMIT</div>

                <div id="trip-data-container"></div>

            </div>
            <div id="myModal" class="modal">

                <!-- Modal content -->
                <div class="modal-content">






                    <!--                    <h1 class="text-light">Send Message<span id='list-sub-title'></span></h1>
                                        <div style="margin-top: 5%;;" class="cell">
                                            <label>Company</label>
                                            <div class="input-control text full-size"><select  style="width:64%;" type="text" id="message_company" placeholder="Company"></select></div>
                                        </div>
                                        <div style="margin-top: 5%;;" class="cell">
                                            <label>Message</label>
                                            <div class="input-control text full-size"><textarea  type="textarea"  id="message_value" placeholder="Message"></textarea></div>
                                        </div>
                                        <div class="form-dialog-control">
                                            <button id="send_button" type="button" class="button danger" onclick="">Send</button>
                                            <button id="button-cancel" type="button" class="button" onclick="closeDialog()">Cancel</button>
                                        </div>-->


                </div>
                <span class="close"></span>

            </div>
        </div>
     
        
    
      
     

      
    </body>
</html>
