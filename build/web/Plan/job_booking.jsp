<%--
    Document   : job_booking
    Created on : 4 Apr, 2019, 3:43:18 PM
    Author     : Kevin
--%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="v3nity.std.core.data.Data"%>
<%@page import="java.util.Map.*"%>
<%@page import="v3nity.std.core.web.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.system.*"%>
<%@page import="v3nity.std.core.system.LanguageProperties"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Map<String, LanguageProperties> languageTypes = new HashMap<>();

    Object key = request.getAttribute("languageTypeKey");

    Object[] keyArr = ((Set) key).toArray();

    Object value = request.getAttribute("languageProperties");

    Object[] valueArr = ((Collection) value).toArray();

    for (int i = 0; i < keyArr.length; i++) {
        languageTypes.put((String) keyArr[i], (LanguageProperties) valueArr[i]);
    }

%>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <title></title>
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/metro-responsive.css" rel="stylesheet">
        <link href="css/metro-schemes.css" rel="stylesheet">
        <link href="css/metro.css" rel="stylesheet">
        <script type="text/javascript" src="js/jquery-2.1.4.min.js"></script>
        <script type="text/javascript" src="js/metro.js"></script>
        <script>

            var languageMap;
            var descriptions = [];
            var numArray = [];
            var serviceArray = [];
            var serviceTextArray = [];
            var disableOffDate = [];
            var text = {};
            var dateString;

            $(document).ready(function()
            {
               

            $('#option-language').val('${defaultLanguage}').change();

                    disable(true);

                    hideError();
            });


            function disable(val)
            {
                $('#service').attr('disabled', val);

                $('#service').css('pointer-events', val ? 'none' : 'auto');

                $('#date').attr('disabled', val);

                $('#date-control').css('pointer-events', val ? 'none' : 'auto');

                $('#time').attr('disabled', val);

                $('#time').css('pointer-events', val ? 'none' : 'auto');

                $('#number').attr('disabled', val);

                $('#number').css('pointer-events', val ? 'none' : 'auto');

                $('#add').attr('disabled', val);

                $('#add').css('pointer-events', val ? 'none' : 'auto');

                $('#sub').attr('disabled', val);

                $('#sub').css('pointer-events', val ? 'none' : 'auto');

                $('#list').attr('disabled', val);

                $('#list').css('pointer-events', val ? 'none' : 'auto');
            }

            function clear()
            {
                //$('#service').html('<option value="0">' + languageMap.service + '</option>');

                $('#time').html('<option value="0">' + languageMap.time + '</option>');

                $('#date').val('');
                
                $('#list').text('');
            }

            function refresh(option)
            {
                enableAdd();
                checkOff();
                $("#date-control").datepicker("destroy");
                $('#description').html(option.getAttribute('data-desc'));
                $('#service').html('<option value="" disabled>' + languageMap.service + '</option>');
                if (option.value > 0)
                {
                    $.ajax({
                    type: 'POST',
                            url: 'JobBookingController',
                            data: {
                            action: 'service',
                                    type: 'get',
                                    id: option.value
                            },
                            beforeSend: function()
                            {

                            },
                            success: function(result)
                            {
                                disable(false);

                                clear();

                                var services = result.services;                              
                                
                                for (var i = 0; i < services.length; i++)
                                {                                                                    
                                    text[ "" + services[i].id ] = "" + services[i].service;
                                    
                                    var options = new Option(services[i].service, services[i].id);

                                    $('#service').append(options);                                 
                                    
                                }  
                            },
                            error: function()
                            {

                            },
                            complete: function()
                            {

                            },
                            async: false
                    });
                }
                else
                {
                    clear();
                    disable(true);
                }
            }

            function getTime(date)
            {
                $('#time').html('<option value="0">' + languageMap.time + '</option>');
                var selectedDate = date.replace(/-/g, '');
                $.ajax({
                    type: 'POST',
                    url: 'JobBookingController',
                    data: {
                    action: 'timeSlot',
                    type: 'get',
                    id: $('#location option:selected').val(),
                    date: selectedDate
                    },
                    beforeSend: function()
                    {

                    },
                    success: function(result)
                    {
                        disable(false);
                        var times = result.times;
                        for (var i = 0; i < times.length; i++)
                        {
                            var options = new Option(times[i].time, times[i].time);

                            $('#time').append(options);
                        }
                    },
                    error: function()
                    {

                    },
                    complete: function()
                    {

                    },
                    async: false
                    });
            }


            function validate()
            {
                if ($('#name').val() === '')
                {
                    showError(languageMap.pleaseFillIn + ' <b>' + languageMap.name + '</b>');

                    return false;
                }

                if ($('#phone').val() === '')
                {
                    showError(languageMap.pleaseFillIn + ' <b>' + languageMap.phone + '</b>');

                    return false;
                }

                if ($('#email').val() === '')
                {
                    showError(languageMap.pleaseFillIn + ' <b>' + languageMap.email + '</b>');

                    return false;
                }

                if ($('#location').val() === '0')
                {
                    showError(languageMap.pleaseFillIn + ' <b>' + languageMap.location + '</b>');

                    return false;
                }

                if ($('#service').val() === '')
                {
                    showError(languageMap.pleaseFillIn + ' <b>' + languageMap.service + '</b>');

                    return false;
                }

                if ($('#date').val() === '')
                {
                    showError(languageMap.pleaseFillIn + ' <b>' + languageMap.date + '</b>');

                    return false;
                }
                if ($('#list').text() === '')
                {
                    showError("Please Select Service");
                    return false;
                }

                if ($('#time').val() === '0')
                {
                    showError(languageMap.pleaseFillIn + ' ' + languageMap.time + '</b>');

                    return false;
                }

                return true;
            }

            function book()
            {
                if (validate())
                {
                    var date = $('#date').val().replace(/-/g, '');
                    var time = $('#time').val().replace(/:/g, '');
                    var dateTime = date + time + '00';

                    $.ajax({
                    type: 'POST',
                    url: 'JobBookingController',
                    data: {
                    action: 'create',
                    type: 'set',
                    name: $('#name').val(),
                    phone: $('#phone').val(),
                    email: $('#email').val(),
                    bookingDT: dateTime,
                    locationId: $('#location option:selected').val(),
                    remarks: $('#remarks').val(),
                    list: $('#list').text()
                    },
                    beforeSend: function()
                    {

                    },
                    success: function(data)
                    {
                        if (data.result)
                        {
                            console.log(data.result);
                            openSuccessDialog();
                            //dialog('Success', 'Booking Success', 'success');
                            
                            reset();
                        }
                        else
                        {
                            dialog('Error', data.text, 'alert');
                        }
                    },
                    error: function()
                    {

                    },
                    complete: function()
                    {
                    },
                    async: false
                    });
                }
            }

            function changeLanguage(value)
            {
                $.ajax({
                type: 'POST',
                url: 'LanguageController',
                data: {
                type: 'system',
                        action: 'query',
                        language: value,
                        values: 'name,phone,email,location,service,date,time,remarks,book,add,delete,pleaseFillIn'
                },
                success: function(data)
                {
                    if (data.result === true)
                    {
                        languageMap = data.language;

                        $('#name').attr('placeholder', data.language.name);

                        $('#phone').attr('placeholder', data.language.phone);

                        $('#email').attr('placeholder', data.language.email);

                        $('#date').attr('placeholder', data.language.date);

                        $('#remarks').attr('placeholder', data.language.remarks);

                        $('#location option').eq(0).html(data.language.location);

                        $('#service option').eq(0).html(data.language.service);

                        $('#time option').eq(0).html(data.language.time);

                        $('#button-save').html(data.language.book);

                        $('#insert').html(data.language.add);

                        $('#remove').html(data.language.delete);
                    }
                    else
                    {

                    }
                },
                error: function()
                {

                },
                async: false
            });
            }

            function reset()
            {
                hideError();

                $('#booking-form')[0].reset();

                $('#description').html('');
                
                $('#list').html('');
                
                $('#service').html('');
            }

            function showError(error)
            {
                $('#error').show();

                $('#error').html(error);
            }

            function hideError()
            {
                $('#error').hide();
            }

            function openSuccessDialog()
            {
                $('#success-dialog-message').html('Your booking has been submitted. Thank you');

                $('#success-dialog').data('dialog').open();
            }

            function isToday(date)
            {
                var today = new Date();
                var month = today.getMonth() + 1;
                var day = today.getDate();
                var year = today.getFullYear();

                var parts = date.split('-');

                var result = false;

                try
                {
                    result = (parseInt(parts[0]) === day && parseInt(parts[1]) === month && parseInt(parts[2]) === year);
                }
                catch (err)
                {

                }

                return result;
            }

            function disablePastTime(date)
            {
                var today = new Date();

                var select = document.getElementById("time");
                getTime(date);
                if (isToday(date))
                {
                    var hour = today.getHours();
                    var minute = today.getMinutes();
                    var totalMinutes = (hour * 60) + minute;

                    for (i = 1; i < select.options.length; i++)
                    {
                        var parts = select.options[i].value.split(':');

                        select.options[i].disabled = (((parseInt(parts[0]) * 60) + parseInt(parts[1])) < totalMinutes);
                    }
                }
                else
                {
                    for (i = 1; i < select.options.length; i++)
                    {
                        select.options[i].disabled = false;
                    }
                }
            }

            function limitTime(date)
            {
                $('#time option').eq(0).prop('selected', true);

                disablePastTime(date);
            }
          
            function increaseValue()
            {
                var value = parseInt(document.getElementById('number').value, 10);
                value = isNaN(value) ? 0 : value;
                value++;
                document.getElementById('number').value = value;
            }

            function decreaseValue()
            {
                var value = parseInt(document.getElementById('number').value, 10);
                value = isNaN(value) ? 0 : value;
                value < 1 ? value = 1 : '';
                if (value == '1')
                {   
                }
                else
                {
                    value--;
                }
                    document.getElementById('number').value = value;
            }
            
            function insertVal()
            {
                var service = $('#service option:selected').text();
                var serviceId = $('#service option:selected').val();
                var value = $('#number').val();
                var x = document.getElementById("list");
                var option = document.createElement("option");
                option.text = service+ " - " + value + " . ";
                option.id =  serviceId;
                x.add(option);
                numArray.push(value);
                serviceArray.push(serviceId);
                serviceTextArray.push(service);
                serviceTextArray.push(service);
                disableService();
                $("#service option:selected").remove();
            }
            		
            function deleteEntry()
            {
                var myList = document.getElementById('list');               
                var i;
                for (i = myList.length - 1; i>=0; i--) 
                {
                    if (myList.options[i].selected) 
                    {
                        var index = numArray.indexOf(numArray[i]);

                        if (index > -1) {
                           numArray.splice(index, 1);
                        }
                        var index = serviceArray.indexOf(serviceArray[i]);

                        if (index > -1) {
                            serviceArray.splice(index, 1);
                        }                           
                        var listId = myList.options[i].id;

                        $('#service').append($('<option>', {
                        value: listId ,
                        text: text[listId]
                        }));
                        myList.remove(i);
                    } 
                }                 
            }          
            function disableService()
            { 
                $("#service option:selected").attr('disabled','disabled');        
            }
            function disableAdd()
            {
                $('#insert').attr('disabled', 'disabled');
            }
            
            function checkOff()
            {
                dateString = "";
               
                $.ajax({
                    type: 'POST',
                    url: 'JobBookingController',
                    data: {
                    action: 'getOff',
                    type: 'get',
                    id: $('#location option:selected').val()
                    },
                    beforeSend: function()
                    {

                    },
                    success: function(result)
                    {
                        var dates = result.dates;
                        disableOffDate = [];
                        disableOffDate.push(dates);
                        disabledArray = JSON.stringify(disableOffDate);
     
                        for(var i = 0; i<disableOffDate[0].length; i ++)
                        {
                            if(i != disableOffDate[0].length - 1)
                            {
                                dateString += disableOffDate[0][i].date += ",";
                            }
                            else
                            {
                                dateString += disableOffDate[0][i].date;
                            } 
                        } 
                        $("#date-control").datepicker({
                            minDate: new Date(Date.now() - 86400000),
                            exclude: dateString

                        });
                    },
                    error: function()
                    {

                    },
                    complete: function()
                    {
                        
                    },
                    async: false
                });     

            }
            
            function enableAdd()
            {
                document.getElementById("insert").disabled = false;
            }
        </script>
        <style type="text/css">

            .page {
                position: fixed;
                padding: 0 !important;
                margin: 0;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                border: none;
            }

            .center-panel {
                border: 1px solid #eeeeee;
                position: fixed;
                background-color: #ffffff;
                top: 10%;
                left: 50%;
                height: auto;
                width: 600px;
                margin-top: -50px;
                margin-left: -300px;
                padding: 16px;
            }

            .page-title {
                text-align: center;
                font-weight: 100;
                font-size: 32px;
            }

            .cover-image {
                background-image: url("img/custom/${id}.png");
                background-repeat: no-repeat;
                background-position: center;
                background-size: cover;
                padding: 8px;
                width: 100%;
            }

            .language-selection {
                float: right !important;
            }

            .mandatory-symbol {
                position: absolute;
                right: 8px;
                top: 8px;
                color: red;
            }

            @media screen and (max-width: 600px) {
                .cover-image {
                    background-image: none;
                }

                .center-panel {
                    box-shadow: none;
                    border: none;
                    margin: 32px 0;
                    height: 100%;
                    width: 100%;
                    top: 0;
                    left: 0;
                    overflow-y: auto;
                }

                .language-selection {
                    float: none !important;
                    width: 100%;
                }
            }

            #error {
                border: 1px solid #d33d1b;
                background-color: #f18972;
                color: #fff;
                padding: 8px;
                margin: 8px 0;
            }

            input::-webkit-inner-spin-button,
            input::-webkit-outer-spin-button{
                -webkit-appearance:none;
            }
            input[type="number"]{
                -moz-appearance:textfield;
            }

            #List {
            overflow: scroll;
            overflow-y: auto;
            overflow-x: auto;
            max-width:450px;
            max-height:100px;

            border: 2px solid #ddd;
            min-width: 450px;
            min-height: 100px;
            padding: 2px;
            }

            #number
            {
                width: 120px;
            }
            span.active
            {
                background-color: #ddd;
            }
             #list{
                width:450px;
                height:100px;
            }

        </style>
    </head>
    <body class="cover-image">
        <section class="page">
            <div class="center-panel">
                <div class="page-title">${page}</div>
                <div id="error"></div>
                <form id="booking-form" action="javascript:void(0);">
                    <div class="grid">
                        <div class="row cells2">
                            <div class="cell">
                                <div class="input-control text full-size">
                                    <span class="mif-user prepend-icon"></span>
                                    <input id="name" name="name" type="text" placeholder="Name" maxlength="50" autofocus>
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div> 
                            <div class="cell">
                                <div class="input-control text full-size">
                                    <span class="mif-phone prepend-icon"></span>
                                    <input id ="phone" type="text" name="phone" placeholder="Phone" maxlength="20">
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="cell">
                                <div class="input-control text full-size">
                                    <span class="mif-envelop prepend-icon"></span>
                                    <input id="email" name="email" type="text" placeholder="Email" maxlength="100">
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="cell">
                                <div class="input-control select full-size">
                                    <select id="location" class="drop-down-selection" onchange="refresh(this.options[this.selectedIndex])">
                                        <option value="0" data-desc="">location</option>
                                        <%  List<Data> locationList = (List<Data>) request.getAttribute("locations");

                                            for (Data data : locationList) {
                                                out.println(String.format("<option value=\"%d\" data-desc=\"%s\">%s</option>", data.getId(), data.getString("description"), data.getString("location")));
                                            }
                                        %>
                                    </select>
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="cell">
                                <div id="description"></div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="cell colspan2 ">
                                <div class="input-control select full-size">
                                    <select id="service" class="drop-down-selection">
                                        <option>Service</option>
                                    </select>
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div>
                        </div>
                        <div class="row cells3">
                            <div class="cell colspan2">
                                <div class="input-control cell" style="text-align: center">
                                    <button type="button" id="sub" onclick="decreaseValue()">-</button>
                                    <input type="number" id="number" value="1"/>
                                    <button type="button" id="add" onclick="increaseValue()">+</button>
                                </div>
                            </div>    
                            <div class="cell">
                                <div class="input-control cell">
                                    <button id="insert" onclick="insertVal()">Add</button>
                                </div>
                            </div>
                        </div>
                        <div class="row cells3">
                            <div class="cell colspan2">
                                    <select id="list" multiple></select>
                            </div>
                            <div class ="cell" style="text-align: right">
                                <button id="remove" onclick="deleteEntry()">Delete</button>
                                <br />
                            </div>
                        </div>                   
                        <div class="row cells2">
                            <div class="cell">
                                <div id="date-control" class="input-control text full-size" data-format="dd-mm-yyyy">
                                    <input id ="date" type="text" placeholder="Date" onchange="limitTime(this.value)">
                                    <button class="button"><span class="mif-calendar"></span></button>
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div> 
                            <div class="cell">
                                <div class="input-control select full-size">
                                    <select id="time" class="drop-down-selection">
                                        <option value="0">Time</option>
                                    </select>
                                    <span class="mandatory-symbol">*</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="cell">
                                <div class="input-control textarea full-size">
                                    <textarea id="remarks" placeholder="Remarks" maxlength="200"></textarea>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="cell">
                                <div style="text-align: center">
                                    <button id="button-save" class="button primary" onclick="book()">Book</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </section>
        <div class="input-control select language-selection">
            <span class="mif-earth prepend-icon"></span>
            <select id="option-language" onchange="changeLanguage(this.value)" style="padding-left: 32px">
                <%  if (languageTypes != null) {
                        for (Iterator<LanguageProperties> iterator = languageTypes.values().iterator(); iterator.hasNext();) {
                            LanguageProperties language = iterator.next();

                            if (language.getEnabled()) {
                                if (language.getCode().equals("en")) {
                                    out.write("<option value=\"" + language.getCode() + "\" selected>" + language.getName() + "</option>");
                                } else {
                                    out.write("<option value=\"" + language.getCode() + "\">" + language.getName() + "</option>");
                                }
                            }
                        }
                    }
                %>
            </select>
        </div>
        <div class="padding20 dialog" id="success-dialog" data-role="dialog" data-close-button="true" data-overlay="true" data-overlay-click-close="true" data-overlay-color="op-dark">
            <p id="success-dialog-message"></p>
            <span class="dialog-close-button"></span>
        </div>
        <%@ include file="../Common/dialog.jsp"%>
    </body>
</html>
