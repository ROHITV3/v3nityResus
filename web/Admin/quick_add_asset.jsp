<%-- 
    Document   : add_asset
    Created on : 8 Jan, 2021, 11:37:36 AM
    Author     : tsidd
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
          <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <style>
            #but{
                background: #59cde2;
                color: #ffffff;
                border-color: #59cde2;
                padding: 0 1rem;
                height: 2.125rem;
                text-align: center;
                vertical-align: middle;
                cursor: pointer;
                 display: inline-block;
                outline: none;
                font-size: .875rem;
                 line-height: 1;
                margin: .15625rem 0;
                position: relative;
                margin-right: 2px;
            }
        </style>
         
        <script type="text/javascript">
           
             var result = false;
            var skipcount = 0;
            $(document).ready(function () {
                var select = $('select');
                var options = new Option("--", 0);
                select.append(options);
                $.ajax({
                    type: 'GET',
                    url: 'QuickAddAssetController',
                    data: {
                        action: 'get',
                        type: 'load_creation'
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
                                    $("#Customer").append(options);
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
                                
                            }
                        } else
                        {

                        }
                    },
                    error: function (jqXHR)
                    {
//                        alert("Error!!" + jqXHR.status + jqXHR.responseText);
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            });
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
                    url: 'QuickAddAssetController',
                    data: {
                        action: 'post',
                        type: 'asset_creation_check',
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
//                        alert("Error!!" + jqXHR.status + jqXHR.responseText);
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            }
               function send(htmlString) 
            {
//                alert(htmlString);
                
                $.ajax({
                    type: 'POST',
                    url: 'QuickAddAssetController',
                    data: {
                        action: 'post',
                        type: 'asset_creation',
                        data: htmlString
                    },
                    success: function (data)
                    {
                        if (data)
                        {
                            debugger;
                            dialog('Success', 'Accounts created', 'success');
                            document.location.reload(true);
                        } else
                        {
                            dialog('Failed', 'Error creating account,' + data, 'alert');
                        }
                    },
                    error: function (jqXHR)
                    {
//                        alert("Error!!" + jqXHR.status + jqXHR.responseText);
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
         <h1 class="text-light">Quick Add Asset Page</h1>
        
             <div data-role = container id = "WizardContainer" style = "max-width: 50%;">
                 <div class = "grid">
                         <div id = "cellcol" class = "col cells6">
                             <div class = "cell">
                                    <h3 class = "text-light">Customer: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Customer" onchange="selection(this)" required>
                                        </select></div>
                                </div>
                             <div class = "cell">
                                    <h3 class = "text-light">Label Prefix: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Prefix" type="text" name="prefix" maxlength=10 placeholder="Prefix" required></div>
                               </div>
                              <div class = "cell">
                                    <h3 class = "text-light">Label / Staff Serial No: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="UnitId" type="text" name="UnitId" maxlength=10 placeholder="Label / Staff Serial No" required></div>
                               </div>
                             
                             <div class = "cell">
                                    <h3 class = "text-light">Asset Type: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Assettype"  onchange="selection(this)" required>
                                        </select></div>
                                </div>
                              
                                <div class = "cell">
                                    <h3 class = "text-light">Source: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><select id = "Source" onchange="selection(this)" required>
                                        </select></div>
                                </div>
                              <div class = "cell">
                                    <h3 class = "text-light">Device Unit Id: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="DeviceUnitId" type="text" name="DeviceUnitId" maxlength=10 placeholder="Device Unit Id" required></div>
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
                                
                                 <div class = "cell">
                                    <h3 class = "text-light">Time Zone: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="Prefix" type="text" name="Timezone" maxlength=10 placeholder="Time Zone" value="8.0" required></div>
                                </div>
                               
                             
                             <div class = "cell">
                                    <h3 class = "text-light">Staff Password: </h3><span style="color: red; font-weight: bold"> *</span>
                                    <div class="input-control text full-size"><input  id ="" type="text" name="Password" minlength=8  placeholder="Password" value = "password"required></div>
                                </div>
                             
                              
                             
                              
                             <div class = "cell">
                                 <button id="but" onclick="saveWizard()"> Finish and Go</button>
                             </div>
                         </div>
                 </div>
           
         </div>
    </body>
</html>
