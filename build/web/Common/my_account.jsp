<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    Connection con = null;

    ListData data = (ListData) userProperties.getUser();

    ListDataHandler dataHandler = new ListDataHandler(new ListServices());

    ListMetaData metaData = null;

    List<MetaData> metaDataList = data.getMetaDataList();

    ListForm listForm = new ListForm();

    int metaListSize = metaDataList.size();

    String fieldName = "";

    for (int i = 0; i < metaListSize; i++)
    {
        metaData = (ListMetaData) metaDataList.get(i);

        fieldName = metaData.getFieldName();

        // disable these fields following old v3nity concept...
        if (fieldName.equals("customer_id") || fieldName.equals("role_id") || fieldName.equals("active"))
        {
            metaData.setModifiable(false);
        }

        if (fieldName.equals("username"))
        {
            /*
             * not suppose to change the username...
             */
            metaData.setReadonly(true);

            /*
             * set field to non-unique otherwise the account cannot be saved if there are duplicated username...
             */
            metaData.setUnique(false);
        }
    }
%>

<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title></title>
        <style>
            .userOtp
            {
                height: 2.125rem;
                min-width: 1.875 rem;
            }
        </style>
        <script type="text/javascript">
            
            $(document).ready(function()
            {
                getTwoFa();
                
//                $.ajax({
//                    type: 'POST',
//                    url: 'MyAccountController?type=system&action=getTwoFa',
//                    data: {
//                        
//                    },
//                    beforeSend: function()
//                    {
//                        $('#button-save').prop("disabled", true);
//                    },
//                    success: function(data)
//                    {
//                        if(data.result == true)
//                        {
//                            
//                        }
//                        else if(data.result==false)
//                        {
//                            var firstDisplay= document.getElementById("authentication-setup");
//                            firstDisplay.style.display="block";
//                        }
//                        
//                    },
//                    error: function()
//                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
//                    },
//                    complete: function()
//                    {
//                        $('#button-save').prop("disabled", false);
//                    },
//                    async: true
//                });
               
            });

            function save()
            {
                $.ajax({
                    type: 'POST',
                    url: 'MyAccountController?type=system&action=save',
                    data: $('#form-dialog-data').serialize(),
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function(data)
                    {
                        if (data.expired === undefined)
                        {
                            if (data.result === true)
                            {
                                dialog('Success', data.text, 'success');
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
            
            
            function disableOtp()
            {
                var answer = window.confirm("Are you sure you want to disable 2FA?");
                
                if (answer) 
                {
                    dialog('Success', '2FA has been disabled', 'success');
                    
                    $.ajax({
                        type: 'POST',
                        url: 'MyAccountController?type=system&action=disableOtp',
                        data: $('#form-dialog-data').serialize(),
                        beforeSend: function()
                        {
                            
                        },
                        success: function(data)
                        {
                            getTwoFa();
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                            
                        },
                        async: true
                    });
                }
                 
            }
            
            
            function initiateSetup()
            {
                 $.ajax({
                    type: 'POST',
                    url: 'MyAccountController?type=system&action=initiateSetup',
                    data: $('#form-dialog-data').serialize(),
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function(data)
                    {
                        document.getElementById('qrImg').innerHTML =data.qrDetail;
                        var displayVarify= document.getElementById("varify-otp");
                        var displayAuth=document.getElementById("authentication-setup");
                        displayVarify.style.display="block";
                        displayAuth.style.display="none";
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
            
            
            function getTwoFa()
            {
                $.ajax({
                    type: 'POST',
                    url: 'MyAccountController?type=system&action=getTwoFa',
                    data: $('#form-dialog-data').serialize(),
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function(data)
                    {
                        if (data.has_2fa)
                        {
                            document.getElementById('qrImg').innerHTML = data.qrDetail;
                            var displayVarify= document.getElementById("varify-otp");
                            var displayAuth=document.getElementById("authentication-setup");
                            displayVarify.style.display="block";
                            displayAuth.style.display="none";

                            document.getElementById("before-compare").style.display="none";
                            document.getElementById("is-registered").style.display="block";
                        }
                        else
                        {
                            document.getElementById("authentication-setup").style.display="block";
                            document.getElementById("varify-otp").style.display="none";
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
            
            
            
            function verifyOTP()
            {
                var input= document.getElementById('userOtp').value;
                
                $.ajax({
                    type: 'POST',
                    url: 'MyAccountController?type=system&action=verifyCode',
                     data: {
                        
                        userInput: input
                    },
                    beforeSend: function()
                    {
                        $('#button-save').prop("disabled", true);
                    },
                    success: function(data)
                    {
                        if(data.otp=="correct")
                        {
                            var displayBeforeOtp= document.getElementById("before-compare");
                            var displayAfterOtp=document.getElementById("after-compare");
                         
                            displayBeforeOtp.style.display="none";
                            displayAfterOtp.style.display="block";
                        }
                        else
                        {
                            dialog('Error', 'Wrong OTP', 'alert');
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
            
            function openPDF()
            {
                window.open("https://www.v3nity.com/V3Nity4/Doc/V3Nity-2FA-Setup.pdf");
            }
        </script>
    </head>
    <body>
        <h1 id="form-dialog-title" class="text-light"><%=userProperties.getLanguage("myAccount")%></h1>
        <h3 id="form-dialog-customer-name" class="text-light"><%=userProperties.getUser().getString("customer")%></h3>
        <div style="max-width: 700px; margin: 32px 0">
            <form id="form-dialog-data" method="post" action="list.jsp" autocomplete="off">
                <div class="grid">
                    <%
                        try
                        {
                            con = userProperties.getDatabasePool().getConnection();

                            dataHandler.setConnection(con);

                            listForm.outputHtml(userProperties, data, dataHandler, out);
                        }
                        catch (Exception e)
                        {

                        }
                        finally
                        {
                            userProperties.closeConnection(con);
                        }
                    %>
                </div>
            </form>
        </div>
        <div style="max-width: 700px; text-align: right">
            <button id="button-save" class="button primary" onclick="save()"><%=userProperties.getLanguage("save")%></button>
        </div><br><br><br>
         
        <div id="authentication-setup" style="width: 700px; display: none; background: #cde6f7; padding: 10px; padding-bottom: 30px; padding-left: 20px;">
            <h2>Two-Factor Authentication (2FA)</h2><br>
            <p>You do not have 2FA for your account. Authenticator mobile app is required for this purpose.<br>
                Please follow <a href="#" onclick="openPDF()"> this instruction</a> for app download and prepare for registration.<br><br>
                Once you are ready, <a href="#" onclick="initiateSetup()">click here</a> to generate your unique QR code.
            </p>
        </div>
        
        <div id="varify-otp" style="width: 700px;  float: left; display: none; background: #cde6f7; padding: 10px; padding-bottom: 30px; padding-left: 20px;">
            <h2 >Two-Factor Authentication (2FA)</h2><br>
            <div style="width: 10%; float: left">
                <div class="qrImg" id="qrImg"></div>
            </div>
            <div class="before-compare" id="before-compare" style="width: 90%; float: left">
                <p>Click on the icon and register the QR Code using the Authenticator mobile app.</p>
                <p>Enter the OTP shown in app, and click Submit.</p>
                
                <div class="input-control text">
                    <input type="text" id="userOtp" name="userOtp" maxlength="6" placeholder="OTP" value="">
                </div>

                <button class="button primary" onclick="verifyOTP()">Submit</button>
                
            </div>
            <div class="after-compare" id="after-compare" style="width: 90%; float: left; display: none">
                <p><b>Registration Successful</b></p>
                <p>From now on, use the Authenticator mobile app to get your OTP during login.</p>
            </div>
            
            <div class="after-compare" id="is-registered" style="width: 90%; float: left; display: none">
                <p><b>2FA Enabled</b></p>
                <p>Click on the Icon and Register the QR Code using the Authenticator mobile app for your 2FA.</p>
                <p>Please follow <a href="#" onclick="openPDF()"> this instruction</a> for more information.</p> <br/>
                <p><a href="#" onclick="disableOtp()">Click here</a> to disable 2FA.</p>
            </div>
        </div>
        
        
       
    </body>
</html>