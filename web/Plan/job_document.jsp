<%-- 
    Document   : job_document
    Created on : Mar 3, 2020, 4:38:05 PM
    Author     : user
--%>

<%@page import="v3nity.std.biz.data.plan.JobFormTemplateDropDown"%>
<%@page import="v3nity.std.biz.data.common.UserProperties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    JobFormTemplateDropDown formTemplateDropDown = new JobFormTemplateDropDown(userProperties);

    try
    {
        formTemplateDropDown.setIdentifier("filter-form-template");

        formTemplateDropDown.loadData(userProperties);

    }
    catch (Exception e)
    {

    }
    finally
    {

    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
          <style>    
            #upload-file{

                background-color: #1bb4e2;;
            }
        </style>
         <link href="css/bootstrap.min.css" rel="stylesheet">
       <script type="text/javascript" src="js/bootstrap.min.js"></script>
        <script>

            var totalRecords = -1;

            var requireOverallCount = true;

            var customFilterQuery = [];

            var listForm;

            var listFields = [];

            var importFile;

            var fileName;

        $(document).ready(function ()
            {
                $("#copy-job-report-btn").click(function ()
                {
                    var table = $('#result-table').DataTable();

                    var data = table.rows('.selected').ids();

                    if (data.length > 0)
                    {
                        if (data.length > 1)
                        {
                            dialog('Warning', 'Please aware that you have selected more than one records', 'warning');
                        }

                        var id = data.join();

                        showCopy(id);
                    } else
                    {
                        dialog('No Record Selected', 'Please select a record to edit', 'alert');
                    }
                });

                $(".download-close").click(function ()
                {

                    document.querySelector('.download-pop-up').style.display = 'none';

                });

                $("button.delete-confirm-btn").click(function () {

                    var id = $("#btn-dlt-yes").data("id");

                    var choice = $(this).attr("val");

                    confirm_delete(choice, id);
                });

                $('#job-report-add-btn').click(function () {
                    open_add_form('ReportDocumentTemplate');
                });

                $('input[name="document_file_name"').css({'pointer-events': 'none'});


//                $('#input-file').on('change', handleFile);

            });

            function handleFile(e)
            {
                
                importFile = e.target.files[0];
                fileName = e.target.files[0].name;
            //
                 var form = $("#sampleUploadFrm")[0];


                var data = new FormData(form);
              
                var currentdate = new Date();

                var dateString = currentdate.getFullYear() + "" + ('0' + (currentdate.getMonth() + 1)).slice(-2) +('0' + currentdate.getDate()).slice(-2) +
                                    ('0' + currentdate.getHours()).slice(-2) +('0' + currentdate.getMinutes()).slice(-2) +('0'  + currentdate.getSeconds()).slice(-2);

                $('input[name="document_file_name"').val(dateString + "_" + fileName);

                $('input[name="document_file_name"').css({'pointer-events': 'none'});
            }

            function bs_input_file() {
                $(".input-file").before(
                        function () {
                            debugger;
                            if (!$(this).prev().hasClass('input-ghost')) {
                                
                                var element = $("<input type='file'  id='input-file' accept='.docx,.doc,.docm' class='input-ghost' style='visibility:hidden; height:0'>");
                                element.attr("name", $(this).attr("name"));
                                element.change(function () {
                                    element.next(element).find('input').val((element.val()).split('\\').pop());
                                });
                                element.on('change', handleFile);

                                $(this).find("button.btn-choose").click(function () {
                                    element.click();
                                });
                                $(this).find("button.btn-reset").click(function () {
                                    element.val(null);
                                    $(this).parents(".input-file").find('input').val('');
                                });
                                $(this).find('input').css("cursor", "pointer");
                                $(this).find('input').mousedown(function () {
                                    $(this).parents('.input-file').prev().click();
                                    return false;
                                });
                                return element;
                            }
                        }
                );
            }

            bs_input_file();

            $("#uploadBtn").on("click", function () {

                var filename = $('input[name="document_file_name"').val();
                var data = new FormData($('form')[0]);
                var infutdocx = $(".input-file").find('input').val();
                if (infutdocx != null && infutdocx != 'undefined' && infutdocx !== '') {

                    $.ajax({
                        type: "POST",
                        encType: "multipart/form-data",
                        url: "DocUploadController?filename=" + '' + encodeURIComponent(filename) + '',
                        cache: false,
                        processData: false,
                        contentType: false,
                        data: data,
                        success: function (data) {

                            dialog('Success', data.text, 'success');

                        },
                        error: function (data) {
                            alert("Couldn't upload file");
                        }

                    });
                } else {
                    alert("Please select docx file!");
                }
            });
            $("#choose").on("click", function () {

                $("#uploadBtn").css({'pointer-events': 'auto'});

                $("#uploadBtn").css({'background-color': '#337ab7'});
                $("#uploadBtn").css({'border-color': '#2e6da4'});
                $("#form-control").css({'pointer-events': 'auto'});
                var myspan = document.getElementById('uploadBtn');
                if (myspan.innerText) {
                    myspan.innerText = "Submit";
                } else
                if (myspan.textContent) {
                    myspan.textContent = "Submitted";
                }
            });
            
            
             $("#uploadBtn").on("click", function () {
                $("#uploadBtn").css({'pointer-events': 'none'});
                $("#uploadBtn").css({'background-color': 'grey'});
                $("#uploadBtn").css({'border-color': 'grey'});
                $("#form-control").css({'pointer-events': 'none'});

                var myspan = document.getElementById('uploadBtn');

                if (myspan.innerText) {
                    myspan.innerText = "Submitted";
                } else
                if (myspan.textContent) {
                    myspan.textContent = "Submit";
                }

            });




        </script>
    <body>
        <div class="container" style="float: left; position:absolute;">
                    <div class="" style="float: left;">
                        <form  id="sampleUploadFrm" method="POST"  enctype="multipart/form-data">
                            <h3>Import Doc</h3>
                            <div class="form-group" style="float: left; align-content: left; display:table">
                                <div class="input-group input-file"  name="file" id="fileId">

                                    <span class="input-group-btn">
                                        <button class="btn btn-default btn-choose" id="choose" type="button">Choose</button>
                                    </span> 
                                    <input type="text" id="form-control" class="form-control" style="left:30px;pointer-events:none;display:none"
                                           placeholder='Choose a file...'     /> 
                                    <span class="input-group-btn">
                                        <button type="button" class="btn btn-primary " id="uploadBtn" style="pointer-events:none;left:30">Submit</button>
                                    </span>
                                </div>
                            </div>
                        </form>
                    </div>  
                </div>
    </body>
</html>
