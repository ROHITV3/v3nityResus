<%--
    Document   : account_creation_wizard.jsp
    Created on : Jul 10, 2018, 11:25:12 AM
    Author     : siongteck
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <script type="text/javascript">
            var result = false;
            var skipcount = 0;
            $(document).ready(function () {
                var select = $('select');
                var options = new Option("--", 0);
                select.append(options);
                $.ajax({
                    type: 'GET',
                    url: 'AccountCreationController',
                    data: {
                        action: 'get',
                        type: 'load_creation_wizard'
                    },
                    success: function (data)
                    {
                        if (data)
                        {
                            var records = data.records;
                            for (var i = 0; i < records.length; i++) {
                                if ((records[i].customer_id !== undefined) && (records[i].customer !== undefined))
                                {
                                    var customerid = records[i].customer_id;
                                    var customername = records[i].customer;
                                    var options = new Option(customername, customerid);
                                    $("#Parentcustomer").append(options);
                                }
                                if ((records[i].asset_type_id !== undefined) && (records[i].asset_type !== undefined))
                                {
                                    var assettypeid = records[i].asset_type_id;
                                    var assettypename = records[i].asset_type;
                                    var options = new Option(assettypename, assettypeid);
                                    $("#Assettype").append(options);
                                }
                                if ((records[i].source_id !== undefined) && (records[i].source !== undefined))
                                {
                                    var sourceid = records[i].source_id;
                                    var sourcename = records[i].source;
                                    var options = new Option(sourcename, sourceid);
                                    $("#Source").append(options);
                                }
                                if ((records[i].device_type_id !== undefined) && (records[i].device_type !== undefined))
                                {
                                    var devicetypeid = records[i].device_type_id;
                                    var devicetypename = records[i].device_type;
                                    var options = new Option(devicetypename, devicetypeid);
                                    $("#Devicetype").append(options);
                                }
                                if ((records[i].device_status_id !== undefined) && (records[i].device_status !== undefined))
                                {
                                    var devicestatusid = records[i].device_status_id;
                                    var devicestatusname = records[i].device_status;
                                    var options = new Option(devicestatusname, devicestatusid);
                                    $("#Devicestatus").append(options);
                                }
                                if ((records[i].role_id !== undefined) && (records[i].role !== undefined))
                                {
                                    var roleid = records[i].role_id;
                                    var rolename = records[i].role;
                                    var options = new Option(rolename, roleid);
                                    $("#Role").append(options);
                                }
                            }
                        } else
                        {

                        }
                    },
                    error: function (jqXHR)
                    {
                        alert("Error!!" + jqXHR.status + jqXHR.responseText);
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            });
            $(function () {
                $('#wizard').wizard({
                    buttons: {//show or hide buttons
                        cancel: {
                            show: true,
                            title: "Reset",
                            cls: "danger",
                            group: "left"
                        },
                        help: {
                            show: true,
                            title: "Skip",
                            cls: "info",
                            group: "left"
                        },
                        prior: {
                            show: true,
                            title: "Previous page",
                            group: "left",
                            cls: "info"
                        },
                        next: {
                            show: true,
                            title: "Next page",
                            group: "left",
                            cls: "info"
                        },
                        finish: {
                            show: true,
                            title: "Finish step and Go!",
                            group: "left",
                            cls: "danger"
                        }
                    }
                });
                $('.btn-help').prop('disabled', true);
            });

            function Exit()
            {
                load('${"AccountCreationController"}');
            }

            function skip()
            {
                skipcount++;
                var wizard = $('#wizard');
                wizard.wizard('next');
                $("#Page3").empty();
            }

            function next(page) {
                if (page === 5) {
                    loadSummary();
                }
                if (page === 2) {
                    $('.btn-help').prop('disabled', false);
                } else {
                    $('.btn-help').prop('disabled', true);
                }
                var wizard = $('#wizard');
                result = checkmandatory(page, wizard);
                if (result) {
                    wizard.wizard('next');
                }
            }

            function prev(page) {
                if (page === 4) {
                    $('.btn-help').prop('disabled', false);
                } else {
                    $('.btn-help').prop('disabled', true);
                }
                var wizard = $('#wizard');
                wizard.wizard('prior');
            }
            function checkmandatory(page, result) {
                result = false;
                var wizard = $('#wizard');
                var steps = wizard.find('.step');
                var index = page - 1;
                var count = 0;
                //check all input tag
                var inputtag = steps[index].getElementsByTagName("input");
                var selecttag = steps[index].getElementsByTagName("select");
                for (var i = 0; i < selecttag.length; i++) {
                    if (selecttag[i].hasAttribute('required')) {
                        selecttag[i].style.backgroundColor = "inherit";
                        if (selecttag[i].value === "0") {
                            count++;
                            selecttag[i].style.backgroundColor = "tomato";
                        }
                    }
                }
                for (var i = 0; i < inputtag.length; i++) {
                    if (inputtag[i].hasAttribute('required')) {
                        inputtag[i].style.borderColor = "inherit";
                        if (inputtag[i].value === "") {
                            count++;
                            inputtag[i].style.borderColor = "tomato";
                        } else if (inputtag[i].value.length > inputtag[i].maxlength) {
                            dialog('Error', 'Text length is more than designated text length', 'alert');
                            inputtag[i].style.borderColor = "tomato";
                            return result = false;
                        } else if ((inputtag[i].id === "Password")&&(count == 0)) {
                            return result = true;
                        }
                    }
                }
                if (count > 0) {
                    dialog('Error', 'Please fill in mandatory fields', 'alert');
                    return result = false;
                } else {
                    return result = true;
                }
            }

            function loadSummary() {
                var cell = $("#WizardContainer").find(".cell");
                var htmlString = "";
                cell.each(function () {
                    var label = $(this).find("h3");
                    if (label.text() !== undefined) {
                        htmlString += label.text().bold();
                    }
                    var input = $(this).find("input");
                    if (input.val() !== undefined) {
                        htmlString += input.val();
                    }
                    var option = $(this).find("select");
                    if (option.attr('text') !== undefined) {
                        htmlString += option.attr('text');
                    }
                    htmlString += "\n\n";
                });
                $("#Page6").empty();
                $("#Page6").append(htmlString);
            }

            function selection(selectObject) {
                selectObject.style.backgroundColor = "inherit";
                var value = selectObject.value;
                var index = selectObject.selectedIndex;
                var text = selectObject[index].text;
                selectObject.setAttribute("value", value);
                selectObject.setAttribute("text", text);
            }

            function saveWizard() {
                var cell = $("#WizardContainer").find(".cell");
                var length = cell.length;
                var htmlString = "";
                cell.each(function (index) {
                    var option = $(this).find("select");
                    if (option.val() !== undefined) {
                        htmlString += option.val();
                    }
                    var input = $(this).find("input");
                    if (input.val() !== undefined) {
                        htmlString += input.val();
                    }
                    if (index !== (length - 1)) {
                        htmlString += ",";
                    }
                });
                
                //send(htmlString);
                checkDuplicates(htmlString);
            }
            
            function checkDuplicates(htmlString)
            {
                $.ajax({
                    type: 'POST',
                    url: 'AccountCreationController',
                    data: {
                        action: 'post',
                        type: 'account_creation_check',
                        data: htmlString
                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            send(htmlString);
                        } 
                        else
                        {
                            dialog('Failed', data.text, 'alert');
                        }
                    },
                    error: function (jqXHR)
                    {
                        alert("Error!!" + jqXHR.status + jqXHR.responseText);
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            }

            function send(htmlString) {
                $.ajax({
                    type: 'POST',
                    url: 'AccountCreationController',
                    data: {
                        action: 'post',
                        type: 'account_creation_wizard',
                        data: htmlString
                    },
                    success: function (data)
                    {
                        if (data)
                        {
                            dialog('Success', 'Accounts created', 'success');
                            document.location.reload(true);
                        } else
                        {
                            dialog('Failed', 'Error creating account,' + data, 'alert');
                        }
                    },
                    error: function (jqXHR)
                    {
                        alert("Error!!" + jqXHR.status + jqXHR.responseText);
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            }

        </script>
    </head>
    <body>
        <h1 class="text-light">Account Creation Wizard</h1>
        <div data-role = container id = "WizardContainer" style = "max-width: 50%;">
            <div id = "wizard" class="wizard" data-role="wizard" data-button-cancel = false  data-stepper-type="cycle"data-on-next = "next" data-on-prior = "prev" data-start-page = 1  data-stepper-clickable = false  data-on-help = "skip" data-on-finish = "saveWizard"data-on-cancel = "Exit">
                <div class="steps" >
                    <div class="step" id = "Page1">
                        <div class = "grid">
                            <div id = "cellcol" class = "col cells6">
                                <div class = "cell">
                                    <h2 class="text-light">Customer Information</h2>
                                    <h3 class = "text-light">Parent Customer: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Parentcustomer" onchange="selection(this)" required>
                                        </select></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Customer Name : </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Customer" type="text" name="customer" maxlength=50  placeholder="Customer"  required></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="step" id = "Page2">
                        <div class = "grid">
                            <h2 class="text-light">Asset Information</h2>
                            <div id = "cellcol" class = "col cells7">
                                <div class = "cell">
                                    <h3 class = "text-light">Label Prefix: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Prefix" type="text" name="prefix" maxlength=10 placeholder="Prefix" required></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Asset Type: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Assettype"  onchange="selection(this)" required>
                                        </select></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Time Zone: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Prefix" type="text" name="Timezone" maxlength=10 placeholder="Time Zone" value="8.0" required></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Source: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Source" onchange="selection(this)" required>
                                        </select></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Device-type: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Devicetype"onchange="selection(this)" required>
                                        </select></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Device Status: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Devicestatus"  onchange="selection(this)" required>
                                        </select></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="step" id = "Page3">
                        <div class = "grid">
                            <h2 class="text-light">Staff Credentials</h2>
                            <div id = "cellcol" class = "col cells2">
                                <div class = "cell">
                                    <h3 class = "text-light">Staff Password: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="" type="text" name="Password" minlength=8  placeholder="Password" value = "password"required></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="step" id = "Page4">
                        <div class = "grid">
                            <h2 class="text-light">User Credentials</h2>
                            <div id = "cellcol" class = "col cells5">
                                <div class = "cell">
                                    <h3 class = "text-light">Role: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Role" onchange="selection(this)" required>
                                        </select></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Time Zone: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Prefix" type="text" name="Timezone" maxlength=10 placeholder="Timezone" value="8.0" required></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Language: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Prefix" type="text" name="Language" maxlength=10 placeholder="Language" value="EN" required></div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">User Password: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Password" type="text" name="Password" minlength=8  placeholder="Password" value = "password" required></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="step" id = "Page5">
                        <div class = "grid">
                            <div id = "cellcol" class = "col cells5">
                                <div class = "cell">
                                    <h3 class = "text-light">Total Assets: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input id="value1" value="1" disabled="true"></div>
                                    <div id ="slider" class="slider" data-role="slider" data-position = 1 data-min-value = 1 data-max-value = 100 value = "1" data-target="#value1" data-accuracy = 1 data-animate = true>
                                    </div>
                                </div>
                                <div class = "cell">
                                    <h3 class = "text-light">Total Portal User: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input id="value2" value="1" disabled="true"></div>
                                    <div id ="slider" class="slider" data-role="slider" data-position = 1 data-min-value = 1 data-max-value = 100 value = "1" data-target="#value2" data-accuracy = 1 data-animate = true>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="step" id = "Page6" style = "font-size: large; white-space: pre-wrap;">
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
