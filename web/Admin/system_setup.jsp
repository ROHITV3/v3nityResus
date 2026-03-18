<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title></title>
        <script type="text/javascript">

            function reset(button, type)
            {
                $.ajax({
                    type: 'POST',
                    url: 'SystemSetupController',
                    data: {
                        type: type,
                        action: 'reset'
                    },
                    beforeSend: function()
                    {
                        $(button).prop("disabled", true);
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
                        $(button).prop("disabled", false);
                    }
                });
            }

            function preprocess(button, action)
            {
                $.ajax({
                    type: 'POST',
                    url: 'SystemSetupController',
                    data: {
                        type: 'preprocess',
                        action: action
                    },
                    beforeSend: function()
                    {
                        $(button).prop("disabled", true);
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
                        $(button).prop("disabled", false);
                    }
                });
            }

        </script>
        <style>

            section {
                background-color: #fff;
                margin: 16px 0;
            }

        </style>
    </head>
    <body>
        <h1 class="text-light">System Setup</h1>
        <section>
            <h4 class="text-light">Reset the language mapping list.</h4>
            <button id="button-reset-language" class="button primary" onclick="reset(this, 'language')">Reset Language</button>
        </section>
        <section>
            <h4 class="text-light">Reset the menu items in the main menu.</h4>
            <button id="button-reset-menu" class="button primary" onclick="reset(this, 'menu')">Reset Menu</button>
        </section>
        <section>
            <h4 class="text-light">Run GC</h4>
            <button id="button-reset-menu" class="button primary" onclick="reset(this, 'gc')">Run GC</button>
        </section>
        <section>
            <h4 class="text-light">Preprocess History Journey</h4>
            <button id="button-reset-menu" class="button primary" onclick="preprocess(this, 'journey')">Process</button>
        </section>
    </body>
</html>
