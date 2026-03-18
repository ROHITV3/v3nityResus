<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    Connection con = null;

    ListData data = (ListData) userProperties.getUser();

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());
    
%>

<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title></title>
        <style>
            .label-container {
                padding-top: 10px;
            }
            
            .label-container label {
                cursor: auto;
            }
        </style>
        <script type="text/javascript">
            
            var emailAttributes = [ 'EmailHost', 'EmailEncryption', 'EmailPort', 'EmailSender', 
                                    'EmailAuthenticate', 'EmailUsername', 'EmailPassword', 'EmailDefault'];
            
            $(document).ready(function() {
                
                disableFields();
                
                view();
                
                $('select#host').change(function() {
                    
                    var val = $(this).val();
                    
                    if (val === '1') {
                        
                        googleSettings();
                        
                        disableFields();
                    }
                    else if (val === '2') {
                        
                        yahooSettings();
                        
                        disableFields();
                    }
                    else if (val === '3') {
                        
                        hotmailSettings();
                        
                        disableFields();
                    }
                    else if (val === '4') {
                        
                        clearSettings();
                        
                        enableFields();
                    }
                    
                    toggleAuthentication();
                });
                
                $('select#EmailAuthenticate').change(function() {
                    toggleAuthentication();
                });
                
                $('input[name=default_email]').on('change', function(){
                    if($(this).is(':checked')){
                        setDefaults();
                    }
                    else {
                        clearDefaults();
                    }
                });
                
            });
            
            function googleSettings() {
                
                $('input[name="EmailHost"]').val('smtp.gmail.com');
                        
                $('select#EmailEncryption').val('TLS');

                $('input[name="EmailPort"]').val('587');
                
                $('select#EmailAuthenticate').val('yes');
            }
            
            function yahooSettings() {
                
                $('input[name="EmailHost"]').val('smtp.mail.yahoo.com');
                        
                $('select#EmailEncryption').val('TLS');

                $('input[name="EmailPort"]').val('587');
                
                $('select#EmailAuthenticate').val('yes');
            }
            
            function hotmailSettings() {
                
                $('input[name="EmailHost"]').val('smtp.live.com');
                        
                $('select#EmailEncryption').val('TLS');

                $('input[name="EmailPort"]').val('587');
                
                $('select#EmailAuthenticate').val('yes');
            }
            
            function clearSettings() {
                
                $('input[name="EmailHost"]').val('');
                
                $('select#EmailEncryption').val('');

                $('input[name="EmailPort"]').val('');
                
                $('select#EmailAuthenticate').val('');
                
                $('input[name="EmailSender"]').val('');
                
                $('input[name="EmailUsername"]').val('');
                
                $('input[name="EmailPassword"]').val('');
                
            }
            
            function enableFields() {
                
                $('input[name="EmailHost"]').prop('disabled', false);
                        
                $('select#EmailEncryption').prop('disabled', false);
                
                $('input[name="EmailPort"]').prop('disabled', false);

                $('select#EmailAuthenticate').prop('disabled', false);
                
                $('input[name="EmailUsername"]').prop('disabled', false);
         
                $('input[name="EmailPassword"]').prop('disabled', false);
            }
            
            function disableFields() {
                
                $('input[name="EmailHost"]').prop('disabled', true);
                        
                $('select#EmailEncryption').prop('disabled', true);
                
                $('input[name="EmailPort"]').prop('disabled', true);

                $('select#EmailAuthenticate').prop('disabled', true);
            }
            
            function toggleAuthentication() {
                
                   var val = $('select#EmailAuthenticate').val(); 
                   
                    if(val === 'no') {
                        
                        $('input[name="EmailUsername"]').val('');
                        
                        $('input[name="EmailPassword"]').val('');
                        
                        $('input[name="EmailUsername"]').prop('disabled', true);
         
                        $('input[name="EmailPassword"]').prop('disabled', true);
                        
                    } else {
                        
                        $('input[name="EmailUsername"]').prop('disabled', false);
         
                        $('input[name="EmailPassword"]').prop('disabled', false);
                    }
            }
            
            function view() {
                
                $.ajax({
                    type: 'POST',
                    url: 'EmailSettingsController?type=system&action=view',
                    success: function(data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
//                                dialog('Success', data.text, 'success');

                                  populateFields(data);
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                            }
                        }
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
            
            function populateFields(d) {
                
                var data = d.data;
                
                for (var key in data) {
                    
                    if (data.hasOwnProperty(key)) {

                        if (emailAttributes.includes(key)) {
                            
                            $('#' + key).val(data[key]);

                            checkAttributes(key, data[key]);
                        }
                    }
                }
                
                toggleAuthentication();
            }
            
            function checkAttributes(k, v) {
                
                if (k === 'EmailHost') {
                                
                    if (v === 'smtp.gmail.com') {

                        $('#host').val('1');

                        disableFields();

                    } else if (v === 'smtp.mail.yahoo.com') {

                        $('#host').val('2');

                        disableFields();

                    } else if (v === 'smtp.live.com') {

                        $('#host').val('3');

                        disableFields();

                    } else {
                        
                        $('#host').val('4');
                        
                        enableFields();
                    }
                                
                }
                else if(k === 'EmailDefault') {
                    
                    if(v === 'yes') {
                        
                        $('input[name=default_email]').click().change();
                    }
                }
            }
            
            function save(action) {
                
                var formData = $('#form-dialog-data').find(':disabled').removeAttr('disabled');
                
                var serializedFormData = $('#form-dialog-data').serialize();
                
                formData.prop('disabled', true);
                
                var to = $('input[name="receiver-email"]').val();
                
                var isDefaultEmail = $('input[name="EmailDefault"]').val();
                
                $.ajax({
                    type: 'POST',
                    url: 'EmailSettingsController?type=system&action=' + action ,
                    data: serializedFormData + '&attributes=' + emailAttributes + '&EmailReceiver=' + to + '&EmailDefault=' + isDefaultEmail,
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                        $('#button-send-email').prop("disabled", true);
                    },
                    success: function(data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
                                
                                if (action === 'sendEmail') {
                                    
                                    $('#status').text(data.status);
                                    
                                    $('#status').css('color', '#28922b');
                                }
                            }
                            else
                            {
                                dialog('Failed', data.text, 'alert');
                                
                                if (action === 'sendEmail') {
                                    
                                    $('#status').text(data.status);
                                    
                                    $('#status').css('color', '#ce281e');
                                }
                            }
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {
                        $('#button-save').prop("disabled", false);
                        $('#button-send-email').prop("disabled", false);
                    },
                    async: true
                });
            }
            
            function reset() {
                
                clearSettings();
               
                $('#host').val('');
            }
            
            function setDefaults() {
                $('#host').val(1).change().prop("disabled", true);
                
                setTimeout(function(){
                    $('input[name="EmailSender"]').val('V3smarttechnologies@gmail.com').prop("disabled", true);
                
                    $('input[name="EmailUsername"]').val('V3smarttechnologies@gmail.com').prop("disabled", true);

                    $('input[name="EmailPassword"]').val('Password@12').prop("disabled", true);
                }, 50);
                
                $('button#button-reset').css({'background' : '#EBEBE4', 'border-color' : '#EBEBE4'}).prop("disabled", true);
                
                $('input[name="EmailUsername"]').attr('type', 'password');
                
                $('input[name="EmailPassword"]').attr('type', 'password');
                
                $('input[name="EmailDefault"]').val('yes');
            }
            
            function clearDefaults() {
                $('#host').prop("disabled", false);
                        
                $('input[name="EmailSender"]').val('').prop("disabled", false);
                
                $('input[name="EmailUsername"]').val('').prop("disabled", false);
                
                $('input[name="EmailPassword"]').val('').prop("disabled", false);
                
                $('button#button-reset').css({'background' : '#2086bf', 'border-color' : '#2086bf'}).prop("disabled", false);
                
                $('input[name="EmailUsername"]').attr('type', 'text');
                
                $('input[name="EmailPassword"]').attr('type', 'text');
                
                $('input[name="EmailDefault"]').val('');
            }
            

        </script>
    </head>
    <body>
        <h1 id="form-dialog-title" class="text-light"><%=userProperties.getLanguage("emailSettings")%></h1>
        <div style="max-width: 700px; margin: 32px 0">
            <form id="form-dialog-data" method="post" action="list.jsp" autocomplete="off">
                <div class="grid">
                    <div class="row">
                        <div class="cell">
                            <label class="input-control checkbox">
                                <input type="checkbox" name="default_email">
                                <input type="text" id="EmailDefault" name="EmailDefault" hidden>
                                <span class="check"></span>
                                <span class="caption">Use V3 Email (sender will be V3 Smart Technologies)</span>
                            </label>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label>Email Host</label>
                        </div>
                        <div class="cell">
                            <div class="input-control select full-size">
                                <select name="host" id="host">
                                    <option value="">- Select Host -</option>
                                    <option value="1">Google</option>
                                    <option value="2">Yahoo</option>
                                    <option value="3">Hotmail/Outlook</option>
                                    <option value="4">Others</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailHost")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control text full-size">
                                <input type="text" name="EmailHost" id="EmailHost" maxlength="50" placeholder="Email Host" value="">
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailEncryption")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control select full-size">
                                <select name="EmailEncryption" id="EmailEncryption">
                                    <option value="">- Select Encryption -</option>
                                    <option value="No Encryption">No Encryption</option>
                                    <option value="TLS">TLS</option>
                                    <option value="SSL">SSL</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailPort")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control text full-size">
                                <input type="text" name="EmailPort" id="EmailPort" maxlength="50" placeholder="Email Port" value="">
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailAuthenticate")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control select full-size">
                                <select name="EmailAuthenticate" id="EmailAuthenticate">
                                    <option value="">- Authentication -</option>
                                    <option value="yes">Yes</option>
                                    <option value="no">No</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailSender")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control text full-size">
                                <input type="text" name="EmailSender" id="EmailSender" maxlength="50" placeholder="Sender" value="">
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailUsername")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control text full-size">
                                <input type="text" name="EmailUsername" id="EmailUsername" maxlength="50" placeholder="Username" value="">
                            </div>
                        </div>
                    </div>
                    <div class="row cells2">
                        <div class="cell label-container">
                            <label><%=userProperties.getLanguage("emailPassword")%></label>
                        </div>
                        <div class="cell">
                            <div class="input-control text full-size">
                                <input type="text" name="EmailPassword" id="EmailPassword" maxlength="50" placeholder="Password" value="">
                            </div>
                        </div>
                    </div>
                    <input type="hidden" id="read_version_dt" name="read_version_dt" value="22/07/2019 22:12:07">
                </div>
            </form>
        </div>
        <div style="max-width: 700px; text-align: right">
            <button id="button-reset" class="button primary" style="margin-right: 20px" onclick="reset()"><%=userProperties.getLanguage("reset")%></button>
            <button id="button-save" class="button primary" onclick="save('save')"><%=userProperties.getLanguage("save")%></button>
        </div>
        <h1 id="form-dialog-title" class="text-light">Send Test Email</h1>
        <div style="max-width: 700px; margin: 32px 0">
            <div class="grid">
                <div class="row cells2">
                    <div class="cell">
                        <div class="input-control text full-size">
                            <input type="text" name="receiver-email" maxlength="50" placeholder="Enter Email Address" value="">
                        </div>
                    </div>
                    <div class="cell">
                        <button id="button-send-email" class="button primary" onclick="save('sendEmail')">Send</button>
                    </div>
                </div>
                <div class="cell label-container status">
                    <label id="status"></label>
                </div>
            </div>
        </div>
    </body>
</html>