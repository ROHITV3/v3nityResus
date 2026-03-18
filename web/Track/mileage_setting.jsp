<%-- 
    Document   : mileage_setting.jsp
    Created on : Oct 9, 2019, 3:08:16 PM
    Author     : Rohit
--%>

<%@page import="v3nity.std.core.data.list.DataTreeView"%>
<%@page import="v3nity.std.core.data.list.ListMetaData"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="v3nity.std.core.data.Data"%>
<%@page import="java.util.Map.*"%>
<%@page import="v3nity.std.core.web.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.system.*"%>
<%@page import="v3nity.std.core.system.LanguageProperties"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    DataTreeView assetDropDown = new AssetDropDown(userProperties);

    DriverDropDown driverDropDown = new DriverDropDown(userProperties);

    Data aUser = userProperties.getUser();
    int userId = aUser.getId();

    if (!userProperties.getDataCache().isDataTreeViewCached(assetDropDown)) {
        assetDropDown.loadData(userProperties);

        userProperties.getDataCache().cacheDataTreeView(assetDropDown);
    } else {
        assetDropDown = userProperties.getDataCache().getDataTreeViewCache(assetDropDown);
    }

    assetDropDown.setIdentifier("asset");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
    </head>
    <style>

        .input-control.text .button, .input-control.select .button, .input-control.file .button, .input-control.password .button, .input-control.number .button, .input-control.email .button, .input-control.tel .button {
            top:unset;
            right: unset;
        }
    </style>

    <script>

        // Restricts input for the given textbox to the given inputFilter.
        function setInputFilter(textbox, inputFilter) {
            ["input", "keydown", "keyup", "mousedown", "mouseup", "select", "contextmenu", "drop"].forEach(function (event) {
                textbox.addEventListener(event, function () {
                    if (inputFilter(this.value)) {
                        this.oldValue = this.value;
                        this.oldSelectionStart = this.selectionStart;
                        this.oldSelectionEnd = this.selectionEnd;
                    } else if (this.hasOwnProperty("oldValue")) {
                        this.value = this.oldValue;
                        this.setSelectionRange(this.oldSelectionStart, this.oldSelectionEnd);
                    }
                });
            });
        }
        setInputFilter(document.getElementById("uintTextBox"), function (value) {
            return /^\d*$/.test(value);
        });


        $("#button-upload").click(function () {

            var milValue = document.getElementById("uintTextBox").value;
            var e = document.getElementById("deviceId1");
            var asIds = e.options[e.selectedIndex].value;
            
            if(milValue==0 || asIds==0)
            {
              dialog('Error', 'Please Enter The Value', 'alert'); 
            }
            
            else{

            $.ajax({
                type: 'POST',
                url: 'MileageSettingController?type=system&action=mileage',
                data: {
                    mileage: milValue,
                    assetId: asIds

                },
                beforeSend: function ()
                {
                    $('#button-save').prop("disabled", true);
                },
                success: function (data)
                {
                    if (data.expired === undefined)
                    {
                        if (data.result === true)
                        {
                            dialog('Success', data.text, 'success');


                        } else
                        {
                            dialog('Failed', data.text, 'alert');
                        }
                    }
                },
                error: function ()
                {
                    dialog('Error', 'System has encountered an error', 'alert');
                },
                complete: function ()
                {
                    $('#button-save').prop("disabled", false);
                },
                async: true
            });
        }

        });

    </script>
    <body>
        <div>
            <h1 class="text-light">Mileage Setting</h1>
            <br><br><br><br>

            <h4 class="text-light"><%=userProperties.getLanguage("asset")%></h4>
            <div class="input-control select">
                <select id="deviceId1" name="deviceId1">
                    <option value = "">Select Asset</option>
                    <% assetDropDown.outputHTML(out, userProperties);%>
                </select>
                <br><br><br><br>
                <h4 class="text-light">Set Mileage</h4>
                <input id="uintTextBox">
                <br><br><br><br>
                <button id="button-upload" type="button" class="button primary" >Update</button>
            </div>
        </div>
    </body>
</html>
