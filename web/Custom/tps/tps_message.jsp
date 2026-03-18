<%@page import="org.json.simple.*"%>
<%@page import="v3nity.std.util.Utility"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.cust.biz.tps.data.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
        IListProperties listProperties = (IListProperties) request.getAttribute("properties");

 CompanyTreeView approveTreeview = new CompanyTreeView("company", listProperties);

    approveTreeview.setIdentifier("filter-company");
     approveTreeview.loadData(listProperties);
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>customized page on top of standard list page</title>
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
        </style>
        <script>
             var modal = document.getElementById("myModal");

         $(document).ready(function ()
            {
//                    getSelectOptions_company();
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
            });
    function closeDialog() {
       
        
        
            
            $("#message").val("");
                modal.style.display = "none"
            }
            function showmessagedialog() {

                modal.style.display = "block"
                $('.modal-content').css("width", "40%");
                  $('.modal-content').css("height", "56%");
                  $('.modal-content').css("margin-top", "5%");
//                          $('.modal-content').append("<a target=\"_blank\" href=\"Uploaded Documents\\INVOICE_FUSION\\" + tempObj.contract + "\\" + tempObj.filename + "\" download>" + tempObj.filename + "</a>");


                $('.modal-content').append("<BR/><BR/><BR/>");
            }
            
              function senddetails() {

//                $('#treatment_type').empty();
//                $('#treatment_type').append("<option value=''>--No Select--</option>");
                //    $('#centralinvoicenum').append("<option value='all'>--Select All--</option>");
                
                var sent_to_company= getTreeId('tree-view-filter-company', 'filter-company-id');
                   var message= $("#message").val();
                   if(sent_to_company==undefined || sent_to_company==null || sent_to_company==""){
                       alert("Select Company and try again");
                       return;
                   } if(message==undefined || message==null || message==""){
                       alert("Enter Message and try again");
                       return;
                   }
                $.ajax({
                    url: 'tps?type=message&action=senddetails',
                    type: 'POST',
                    data: {
                        //action: 'getSelectOptions_treatmentType',

                        sent_to_company: getTreeId('tree-view-filter-company', 'filter-company-id'),
                        message: message
                    },
                    success: function (data) {

//                       if (data.expired === undefined)
//                            {
                                if (data.result === true)
                                {
                                    dialog('Success', data.text, 'success');

                                    refreshPageLength_${namespace}();

                                    closeDialog();
                                } else
                                {
                                    dialog('Failed', data.text, 'alert');
                                }
//                            } else
//                            {
//                                closeDialog
//                            }
                    },
                    error: function (e) {
                    }
                });
            }

        </script>
    </head>
    <body>
       <!----> 
          <div class="toolbar" style="margin: 16px 0">
            <div class="toolbar-section">
                <button class="toolbar-button"  type="button" title="Broadcast Message" onclick="showmessagedialog()"><span style="width: 51px;" class="text-light text_large">&#9993</span></button>
            </div>
          </div>
        
   <div id="myModal" class="modal">

                <!-- Modal content -->
                <div class="modal-content">
                    <h1 class="text-light">Send Message<span id='list-sub-title'></span></h1>
<!--                    <div style="margin-top: 5%;;" class="cell">
                        <label>Company</label>
                        <div class="input-control text full-size">
                            <select style="width:64%;" id="sent_to_company" name="sent_to_company">
                                <select   type="text" id="message_company" placeholder="Company">
                                    
                                </select></div>
                    </div>-->
<div class="row cells2" >
    
 
    
                       <div class="cell"  style="margin-top: 5%; ">
                    <h4 class="text-light align-left">Select Company</h4>

                    <div  class="treeview-control"  style="height: 230px">
                        <%
                            approveTreeview.outputHTML(out, listProperties);
                        %>

                    </div>


                </div>
                       <div style="margin-top: -47%;
    margin-left: 47%;" class="cell">
                        <label>Message</label>
                        <div class="input-control text full-size">
                            <textarea type="text" id="message" name="message" maxlength="256" placeholder="Message" value=""></textarea>
                            <!--<textarea  type="textarea"  id="message_value" placeholder="Message"></textarea>-->
                        </div>
                    </div>
                        
                </div>
                        <!--</div>-->
                    <div class="form-dialog-control">
                        <button id="send_button" type="button" class="button danger" onclick="senddetails()">Send</button>
                        <button id="button-cancel" type="button" class="button" onclick="closeDialog()">Cancel</button>
                    </div>


                <span class="close"></span>

            </div>
        </div>
    </body>
</html>