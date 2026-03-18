<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    IListProperties listProperties = (IListProperties) request.getAttribute("properties");
    
    String fileFormats = ".jpg, .jpeg, .png, .gif, .mp4, .pdf, .doc, .docx, .csv, .xls, .xlsx, .ppt, .pptx";
    
    if (listProperties.getCustomerAttribute("AcceptedFileFormats") != null)
    {
        fileFormats = listProperties.getCustomerAttribute("AcceptedFileFormats");
    }
    
    int maxFileSize = 7000000;
    
    if (listProperties.getCustomerAttribute("MaxFileSize") != null)
    {
        maxFileSize = Integer.parseInt(listProperties.getCustomerAttribute("MaxFileSize"));
    }
    
    int maxFiles = 5;
    
    if (listProperties.getCustomerAttribute("MaxFileNo") != null)
    {
        maxFiles = Integer.parseInt(listProperties.getCustomerAttribute("MaxFileNo"));
    }

    ListData data = (ListData) request.getAttribute("data");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
        <style>
            .dialog.tiny 
            {
                width: 700px !important;
                height: 150px !important;
                top: 45% !important;
                left: 50% !important;
                margin-left: -350px;
            }
            
            .dialog.small 
            {
                height: 50% !important;
                top: 25% !important;
            }
            
            .dialog.medium
            {
                height: 80% !important;
                top: 10% !important;
                width: 50% !important;
                min-width: 700px;
                margin-left: -350px;
                left: 50% !important;
            }
            
            .form-dialog-control-add {
                position: absolute;
                padding: 16px;
                bottom: 0;
                left: 0;
                right: 0;
                text-align: right;
            }
            
            .upload-dialog-control
            {
                position: absolute;
                padding: 25px;
                bottom: 0;
                left: 0;
                right: 0;
                text-align: right;
            }
            
            th, td 
            {
                 border-bottom: 1px solid #ddd;
                 padding-top: 15px;
                 padding-bottom: 15px;
            }
            
            tr:first-child td 
            {
                border-top: 1px solid #ddd;
            }
            
            #upload-text-box 
            {
                background: #f8f8f8;
                border-radius: 20px;
                border: none;
                margin-right: 20px;
                padding: 4px;
                padding-left: 25px;
                box-shadow: 0 4px 6px -5px hsl(0, 0%, 65%), inset 0px 4px 6px -5px hsl(0, 0%, 65%);
            }

            #upload-text-box:hover
            {
                background: #e4e4e4;
            }
            
            .file-dialog-control {
                position: absolute;
                padding: 16px;
                bottom: 0;
                left: 0;
                right: 0;
                display: block;
                text-align: right;
            }

            .upload-content {
                border: none;
                position: fixed;
                width: 95% !important;
                height: 95% !important;
                top: 2.5% !important;
                bottom: 2.5% !important;
                left: 2.5% !important;
                right: 2.5% !important;
                object-fit: contain;
            }

            .dialog.large.preview .dialog-close-button {
                background-color: transparent;
                color: #ffffff;
                font-size: 3rem;
                top: 0;
                right: 1.7rem;
            }

            .dialog.large.preview .dialog-close-button:hover {
                background-color: transparent;
                color: #2a8dd4;
            }

            .dialog.large.preview .dialog-close-button:hover:after {
                border-color: transparent;
            }

            .dialog.large.preview .dialog-close-button:active {
                background-color: transparent;
            }

            .dialog.large.preview .dialog-close-button:after {
                border-color: transparent;
            }
            
            /*
            -----------------OCR STYLES---------------------------------
            */
            
            .upload-content-ocr {
                border: 1px solid #dadada;
                width: 100% !important;
                height: 100% !important;
                object-fit: contain;
            }
            
            #log > div {
                color: #313131;
                border-top: 1px solid #dadada;
                padding: 9px;
                display: flex;
            }
            #log > div:first-child {
                border: 0;
            }
            .status {
                    min-width: 250px;
            }
            #log {
                border: 1px solid #dadada;
                padding: 10px;
                margin-top: 20px;
                min-height: 100px;
            }
            progress {
                display: block;
                width: 100%;
                transition: opacity 0.5s linear;
            }
            progress[value="1"] {
                opacity: 0.5;
            }
            
        </style>
        <script type="text/javascript" src="js/v3nity-ocr.js"></script>
        <script type="text/javascript">
            
            var orderId;
            var file;
            var name;
            var totalFiles;
            
            function showUpload_${namespace}(id) {

                if (getData_${namespace}(id))
                {
                    var dialog = $('#${namespace}-file-dialog').data('dialog');
                    orderId = id;

                    $.ajax({
                        url: "ListController?lib=${lib}&type=${type}&action=retrieveFile",
                        type: "POST",
                        data: {folder : "${namespace}_" + orderId},
                        success: function (data) {
                            if (data.result)
                            {
                                var files = data.files;
                                if (files.length > 0)
                                {
                                    totalFiles = files.length;
                                    var html = "<table style=\"width: 100%\">";
                                    for (var i = 0; i < files.length; i ++)
                                    {
                                        var name = files[i].name;
                                        var nameOnly = name.split(".")[0];
                                        var extension = name.split(".")[1];
                                        html += "<tr>";
                                            html += "<td>";
                                                html += "<a href=\"javascript:previewFile_${namespace}(\'" + nameOnly + "\', \'" + extension + "\');\">";
                                                html += "<div id=\"upload-text-box\"><span class=\"text-light\">" + files[i].name + "</span></div>";
                                                html += "</a>";
                                            html += "</td>";
//                                            html += "<td style=\"width:50px\">";
//                                                html += "<button class=\"button cycle-button\" type=\"button\" title=\"OCR\" onclick=\"ocr_${namespace}(\'" + nameOnly + "\', \'" + extension + "\')\"><span class=\"mif-spell-check\"></span></button>";
//                                            html += "</td>";
                                            html += "<td style=\"width:50px\">"; 
                                                html += "<a href=\"PDF\\" +"${namespace}_" + orderId + "\\" + name + "\" download>";
                                                html += "<button class=\"button cycle-button\" type=\"button\" title=\"<%=listProperties.getLanguage("download")%>\"><span class=\"mif-file-download\"></span></button>";
                                                html += "</a>";
                                            html += "</td>";
                                            html += "<td style=\"width:50px\">";
                                                html += "<button class=\"button cycle-button\" type=\"button\" title=\"<%=listProperties.getLanguage("delete")%>\" onclick=\"deleteFile_${namespace}(\'" + nameOnly + "\', \'" + extension + "\')\"><span class=\"mif-cross\"></span></button>";
                                            html += "</td>";
                                        html += "</tr>";
                                    }
                                    html += "</table>";
                                    $('#${namespace}-previous-upload').html(html);
                                }
                                else
                                {
                                    $('#${namespace}-previous-upload').html("<h4 class=\"text-light\"><%=listProperties.getLanguage("noUpload")%></h4>");
                                }
                            }
                            else
                            {
                                $('#${namespace}-previous-upload').html("<h4 class=\"text-light\"><%=listProperties.getLanguage("noUpload")%></h4>");
                            }
                        }
                    });

                    dialog.options.onDialogClose = dialogClose;
                    dialog.open();
                }
            }
            
            function ocrResults(ocrArr)
            {
                console.log("OCR results: ");
                
                for (var i = 0; i < ocrArr.length; i++)
                {
                    console.log("line " + i + ": " + ocrArr[i].text + "Accuracy " + ocrArr[i].accuracy);
                }
            }
            
            function ocr_${namespace}(name, extension)
            {
                var dialog = $('#${namespace}-ocr-dialog').data('dialog');
                
                var namespace = "${namespace}";
                
                var directory = "PDF\\" + namespace + "_" + orderId + "\\" + name + "." + extension;

                var html = "<object class=\"upload-content-ocr\" data=\"" + directory + "\"></object>";
                
                $('#preview-upload-content-ocr').html(html);
                
                //this hardcoded path will not make it...
                var filePath = 'http://localhost:8080/v3nity4/' + directory;
                
                toBase64(filePath, function(dataUrl) {

                        var v3nityOCR = new OCR();
                        
                        var options = new Object();
                        options.binThreshold = null;
                        options.accThreshold = 50;
                    
                        v3nityOCR.convertImgToText(dataUrl, options);
                    }
                );
        
                dialog.open();
            }
            
        function toBase64(url, callback) 
        {
            var xhr = new XMLHttpRequest();
            xhr.onload = function() {
                var reader = new FileReader();
                reader.onloadend = function() {
                    callback(reader.result);
                };
                reader.readAsDataURL(xhr.response);
            };

            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }
            
            function previewFile_${namespace}(name, extension)
            {
                var dialog = $('#preview-dialog').data('dialog');
                var namespace = "${namespace}";
                var directory = "PDF\\" + namespace + "_" + orderId + "\\" + name + "." + extension;
                var type = "";
                switch (extension)
                {
                    case "gif":
                    case "jpg":
                    case "jpeg":
                    case "png":
                        type = "image/" + extension;
                        break;
                    case "mp4":
                        type = "video/mp4";
                        break;
                    case "pdf":
                        type = "application/pdf";
                        break;
                    case "doc":
                    case "docx":
                        type = "application/msword";
                        break;
                    case "csv":
                    case "xls":
                    case "xlsx":
                        type = "application/vnd.ms-excel";
                        break;
                    case "ppt":
                    case "pptx":
                        type = "application/vnd.ms-powerpoint";
                        break;
                }
//                var html = "<object class=\"upload-content\" data=\"" + directory + "\" type=\"" + type + "\"></object>";
                var html = "<object class=\"upload-content\" data=\"" + directory + "\"></object>";
                $('#preview-upload-content').html(html);

                dialog.open();
            }
            
            function deleteFile_${namespace}(name, extension)
            {
                $.ajax({
                    url: "ListController?lib=${lib}&type=${type}&action=deleteFile",
                    type: "POST",
                    data: {
                        folder : "${namespace}_" + orderId,
                        fileName : name + "." + extension
                    },
                    success: function (data) {
                        if (data.result){
                            dialog('Success', 'File deleted', 'success');
                            showUpload_${namespace}(orderId);
                        } else {
                            dialog('Failed', 'Fail to delete file', 'alert');
                        }
                    },
                    error: function() {
                        dialog('Error', 'System has encountered an error', 'alert');
                    }
                });
            }
            
            function doUpload_${namespace}()
            {
                $('#${namespace}-file-dialog').data('dialog').close();
                var dialog = $('#${namespace}-upload-dialog').data('dialog');
                dialog.options.onDialogClose = clearUploadCache;
                dialog.open();
            }
            
            function selectFile_${namespace}() 
            {
                //Prevent upload of files with weird names
                file = document.getElementById("input-file");
                name = file.value.split("\\")[2];
                var nameStr = name.split(".")[0];
                var pdfStr = name.split(".")[1];
                if (!(/^[a-z0-9]+$/i.test(nameStr)))
                {
                    dialog('Invalid File Name', 'File Name contains Space or Special Characters', 'alert');
                }
                else
                {
                    readFile_${namespace}();
                }
            }
       
            function readFile_${namespace}() 
            {
                if (file === null) {
                    dialog('File Error', 'No file Attached', 'alert');
                } else {
                    var fileInput = file.files[0];
                    var reader = new FileLineStreamer();
                    reader.read(fileInput);
                }
            }

            function fileData(data) 
            {
                var base64result = data.split(',')[1];
                var folderName = "${namespace}_" + orderId;
                var JSONText = {};
                    JSONText.file64 = base64result;
                    JSONText.name = name;
                    JSONText.folder = folderName;
                    JSONText = JSON.stringify(JSONText);
                    document.getElementById('input-data').value = JSONText;
            }
            
            function upload_${namespace}() 
            {
                if (file === null) {
                    dialog('File Error', 'No file Attached', 'alert');
                }
                else if ($('#input-data').val().length > <%=maxFileSize%>) {
                    dialog('File too large', 'File size exceeds max size allowed', 'alert');
                }
                else if (totalFiles >= <%=maxFiles%>) {
                    dialog('Too many files', 'Total files uploaded exceeds max allowed', 'alert');
                }
                else {
                    $.ajax({
                        url: "ListController?lib=${lib}&type=${type}&action=uploadFile",
                        type: "POST",
                        data: $('#input-data').val(),
                        contentType: "application/json",
                        dataType: "json",
                        cache: false,
                        beforeSend: function () {

                            $('#upload-button-save').prop("disabled", true);

                            showUploadingDialog();
                        },
                        success: function (data) {
                            if (data.result === false)
                            {
                                dialog('Failed', 'Fail to upload file', 'alert');
                            } else {
                                dialog('Success', 'File uploaded successfully', 'success');
                            }
                        },
                        error: function() {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        timeout : 120000, //2mins timeout
                        complete: function(){
                            $('#upload-button-save').prop("disabled", false);
                            clearUploadingDialog();
                        }
                    });
                }
            }
            
            function showUploadingDialog() {
                document.getElementById('input-control').style.display = "none";
                document.getElementById('upload-gif').removeAttribute("hidden");
                document.getElementById('upload-button-save').style.backgroundColor = "#a2a2a2";
                document.getElementById('upload-button-save').style.borderColor = "#f8f8f8";
                document.getElementById('uploading-text').style.display = "inline-block";
                document.getElementById('uploading-text').innerHTML = 'Uploading.';

                uploadingIntervalVar = setInterval(function() {
                    var uploadingText = document.getElementById('uploading-text').innerHTML;
                    if (uploadingText == 'Uploading......') {
                        uploadingText = 'Uploading.';
                    }
                    document.getElementById('uploading-text').innerHTML = uploadingText + '.';
                }, 500);
            }
            
            function clearUploadingDialog() {
                $('#${namespace}-upload-dialog').data('dialog').close();
                document.getElementById('input-control').style.display = "";
                document.getElementById('upload-gif').setAttribute("hidden", true);
                document.getElementById('upload-button-save').style.backgroundColor = "";
                document.getElementById('upload-button-save').style.borderColor = "";
                document.getElementById('uploading-text').style.display = "";
                document.getElementById('uploading-text').innerHTML = "";
//                document.getElementsById('input-file').value = "";
                clearInterval(uploadingIntervalVar);
            }
            
            function closeDialog_${namespace}()
            {
                $('#${namespace}-file-dialog').data('dialog').close();
            }
            
            
            function clearUploadCache()
            {
                name = null;
                file = null;
                totalFiles = null;
//                showUpload_${namespace}(orderId);
            }
                     
        </script>
    </head>
    <body>
 
        <div data-role="dialog" id=${namespace}-file-dialog class = "small" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog-content" style="margin:0px; padding: 25px; height: 85%">
                <h2 class="text-light"><%=listProperties.getLanguage("viewUploads")%></h2>
                <div class="grid" style="margin-top: 25px">
                    <div id=${namespace}-previous-upload><h2 class="text-light"><%=listProperties.getLanguage("noUpload")%></h2></div>
                </div>
            </div>
            <div class="file-dialog-control">
                <button id="upload-button" type="button" class="button primary" onclick="doUpload_${namespace}()"><%=listProperties.getLanguage("fileUpload")%></button>
                <button id="${namespace}-button-cancel" type="button" class="button" onclick="closeDialog_${namespace}()"><%=listProperties.getLanguage("cancel")%></button>
            </div>
        </div>     
          
        <div data-role="dialog" id=${namespace}-upload-dialog class ="tiny" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div class="form-dialog-content" style="margin:0px; padding: 25px">
                <h2 class="text-light" style="margin-top:0"><%=listProperties.getLanguage("fileUpload")%></h2>
            </div>
            <input id="input-data" name="inputData" type="hidden"/>
            <div class="upload-dialog-control">
                <div class="input-control file" id="input-control" data-role="input" style="width:87%">
                    <input id="input-file" type="file" accept="<%=fileFormats%>" value="" onchange="selectFile_${namespace}()">
                    <button class="button"><span class="mif-folder"></span></button>
                </div>
                <img hidden id="upload-gif" src="img/uploading.gif" alt="Uploader" style="width:25px; height:25px; margin: 5px"/>
                <span id="uploading-text" style=" display: none; width:100px; color: #ababab; text-align: left"></span>
                <button id="upload-button-save" type="button" class="button primary" onclick="upload_${namespace}()"><%=listProperties.getLanguage("upload")%></button>
            </div>
        </div>     
            
            
        <div data-role="dialog" id="preview-dialog" class = "large preview" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">
            <div id="preview-upload-content"></div>
        </div>
            
        <div data-role="dialog" id=${namespace}-ocr-dialog class = "medium" data-close-button="true" data-background="bg-white" data-overlay="true" data-overlay-color="op-dark">    
            <div class="form-dialog-content" style="margin:0px; padding: 25px;">
                <h2 class="text-light">Optical Character Recognition</h2>
                <br>
                <input hidden type="file" id="file-ocr"> 
            <h4 class="text-light">Original Image: </h4>
            <canvas id="canvas"></canvas>
            <h4 class="text-light">Filtered Image: </h4>
            <canvas id="filtered"></canvas>
            <h4 class="text-light">Status: </h4>
            <div id="log"></div>
            </div>
        </div>
            
    </body>
</html>
