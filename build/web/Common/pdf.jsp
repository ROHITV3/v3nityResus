<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title></title>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <style>
            .pdf-content {
                border: none;
                position: fixed;
                padding-top: 74px;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
            }
        </style>
    </head>
    <body>
        <object class="pdf-content" data="${filename}" type="application/pdf">
            <p>This browser does not support PDF.</p>
        </object>
    </body>
</html>
