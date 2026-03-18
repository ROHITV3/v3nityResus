<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String quotationId = request.getParameter("id");

    String customerId = request.getParameter("custId");

    response.setHeader("X-Frame-Options", "SAMEORIGIN");

    response.setHeader("X-XSS-Protection", "1;mode=block");

    response.setHeader("X-Content-Type-Options", "nosniff");

    response.setHeader("Strict-Transport-Security", "max-age=864000; includeSubDomains");

    String cookieHeader = response.getHeader("Set-Cookie");

    if (cookieHeader == null) {
        response.setHeader("Set-Cookie", "path=" + request.getContextPath() + ";SameSite=Strict;HttpOnly");
    } else {
        response.setHeader("Set-Cookie", cookieHeader + ";SameSite=Strict;HttpOnly");
    }
%>
<html>
    <head>
        <style>
            html, body {
                height: 100%;
                overflow: hidden;
            }

            #main{
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                right: 0;
                overflow: auto;
            }
        </style>
        <meta charset="utf-8" />
        <title></title>
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/v3nity.css?v=${code}" rel="stylesheet">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <script src="js/jquery-3.6.1.min.js"></script>
        <script src="js/metro.js"></script>
        <script type="text/javascript">

            var customFilterQuery = [];

            var listForm;

            function getQuotationPdf()
            {
                console.log("getQuotationPdf");
                $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationBDApproveController',
                    data: {
                        action: 'getQuotation',
                        id: '<%=quotationId%>',
                        customerId: '1'
                    },
                    beforeSend: function ()
                    {

                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            var html = 'VIEW QUOTATION : ';
                            html += '<a target="_blank" href="' + data.job.link + '">' + data.job.template + '</a>';
                            document.getElementById('job-pdf').innerHTML = html;
                            console.log('data.status:' + data.status)
                            if (data.status) {
                                initCanvas();
                            }

                        }
                    },
                    error: function ()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                    },
                    async: false
                });
            }

            function bdApproveQuotation()
            {
                $('#approveQuotation').prop("disabled", true);
                $('#rejectQuotation').prop("disabled", true);
                let confirmAction = confirm("Are you sure to authorise this quotation?");
                if (confirmAction) {
                    $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationBDApproveController',
                    data: {
                        action: 'authoriseQuotation',
                        jobId: '<%=quotationId%>'
                    },
                    beforeSend: function ()
                    {
                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            if (data.insert) {
                                alert('Quotation approved, sent to customer!');
                            } else {
                                alert('Quotation is already approved');
                            }
                            location.reload();
                        }
                    },
                    error: function ()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#approveQuotation').prop("disabled", false);
                        $('#rejectQuotation').prop("disabled", false);
                    },
                    async: false
                });
                } else {
                    $('#approveQuotation').prop("disabled", false);
                    $('#rejectQuotation').prop("disabled", false);
                }

                
            }

            function rejectQuotation()
            {
                if ($('textarea[name=remarks]').val().trim().length === 0) {
                    alert('Please input remarks');
                    return;
                }

                let confirmAction = confirm("Are you sure to reject this quotation?");
                if (confirmAction) {
                    $.ajax({
                    type: 'POST',
                    url: 'ResusQuotationBDApproveController',
                    data: {
                        action: 'rejectQuotation',
                        jobId: '<%=quotationId%>',
                        remarks: $('textarea[name=remarks]').val()
                    },
                    beforeSend: function ()
                    {
                        $('#approveQuotation').prop("disabled", true);
                        $('#rejectQuotation').prop("disabled", true);
                    },
                    success: function (data)
                    {
                        if (data.result)
                        {
                            if (data.insert) {
                                alert('Quotation rejected, thank you!');
                            } else {
                                alert('Quotation is already rejected');
                            }
                            location.reload();
                        }
                    },
                    error: function ()
                    {
//                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function ()
                    {
                        $('#approveQuotation').prop("disabled", false);
                        $('#rejectQuotation').prop("disabled", false);
                    },
                    async: false
                });
                } else {
                    
                }
            }

            function initCanvas()
            {
                var canvasContainer = document.createElement('div');

                canvasContainer.setAttribute('id', 'canvas-container');


                document.getElementById('main').appendChild(canvasContainer);

                var remakrsDiv = document.createElement('div');
                var remarkssSpace = document.createElement('br');

                var remarksField = document.createElement('textarea');
                remarksField.setAttribute('type', 'text');
                remarksField.setAttribute('name', 'remarks');
                remarksField.setAttribute('class', 'remarksClass');
                remarksField.setAttribute('cols', 30);
                remarksField.setAttribute('rows', 4);
                remarksField.setAttribute('placeholder', 'Remarks');

                remakrsDiv.appendChild(remarkssSpace);
                remakrsDiv.appendChild(remarksField);
                canvasContainer.appendChild(remakrsDiv);

                var space4 = document.createElement('br');
                var actionBtns = document.createElement('div');
                actionBtns.setAttribute('class', 'pad-btn-container');

                var reject = document.createElement('button');
                reject.setAttribute('class', 'button');
                reject.setAttribute('id', 'rejectQuotation');
                reject.setAttribute('style', 'margin-left: 120px;')
                reject.innerHTML = 'Reject';
                reject.addEventListener('click', function () {
                    rejectQuotation();
                }, false);


                var approveQuotation = document.createElement('button');
                approveQuotation.setAttribute('class', 'button primary');
                approveQuotation.setAttribute('id', 'approveQuotation');
                approveQuotation.innerHTML = 'Approve';
                approveQuotation.addEventListener('click', function () {
                    bdApproveQuotation();
                }, false);

                actionBtns.appendChild(space4);
                actionBtns.appendChild(approveQuotation);
                actionBtns.appendChild(reject);

                canvasContainer.appendChild(actionBtns);
            }

            $(document).ready(function ()
            {
                getQuotationPdf();
                //initCanvas();
            });







        </script>
    </head>
    <body>
        <div id="main" style="margin-left: 20px;">
            <h1 class="text-light">Authorise Quotation</h1>

            <div id="job-pdf" style="margin-bottom: 20px;">
                <!--                <a target="_blank" href="http://localhost:8080/v3nity4/PublicController?key=twcc&type=plan&action=pdf&id=112554">PDF Report</a>-->
            </div>
        </div>

    </body>
</html>
