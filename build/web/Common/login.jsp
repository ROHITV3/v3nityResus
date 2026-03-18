<%@page import="v3nity.cust.biz.resus.data.ResusClassLoader"%>
<%@page import="java.util.Map.*"%>
<%@page import="v3nity.std.core.web.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.system.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Map<String, LanguageProperties> languageTypes = new HashMap<>();

    Object key = request.getAttribute("languageTypeKey");

    Object[] keyArr = ((Set) key).toArray();

    Object value = request.getAttribute("languageProperties");

    Object[] valueArr = ((Collection) value).toArray();

    for (int i = 0; i < keyArr.length; i++)
    {
        languageTypes.put((String) keyArr[i], (LanguageProperties) valueArr[i]);
    }

    ResusClassLoader loader = new ResusClassLoader();

    System.out.println(loader.getStartWork());
%>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title>${title}</title>
        <link rel="icon" type="image/png" href="img/v3-icon.png">
        <link href="css/metro.css" rel="stylesheet">
        <link href="css/metro-icons.css" rel="stylesheet">
        <link href="css/v3nity.css?v=${code}" rel="stylesheet">
        <link href="css/v3nity-admin.css?v=${code}" rel="stylesheet">
        <%            if (!((String) request.getAttribute("custom")).isEmpty())
            {
        %>
        <link href="Custom/${custom}/v3nity-custom.css?v=${code}" rel="stylesheet">
        <%
            }
        %>
        <script src="js/jquery-2.1.4.min.js"></script>
        <script src="js/metro.js"></script>
        <script src="js/v3nity-cookie.js?v=${code}"></script>
        <script type="text/javascript">

            var languageMap = {
                error: 'Error',
                errorSystem: 'System has encountered an error',
                invalidLogin: 'Invalid Login'
            };

            $(document).ready(function()
            {
                var language = getCookie('language');

                if (language !== "")
                {
                    $('#option-language').val(language).change();
                }

                $('#txtUsername, #txtPassword').on('keypress', function(e)
                {
                    if (e.keyCode === 13)
                        document.getElementById("form-login").submit();
                });

                $('#txtUsername').focus();

//                $('#txtUsername').val('hladmin');
//                $('#txtPassword').val('password');
//                login();

            });

            function login()
            {
                var uid = $('#txtUsername').val();

                var pwd = $('#txtPassword').val();

                if (uid === "")
                {
                    $('#txtUsername').focus();
                }
                else if (pwd === "")
                {
                    $('#txtPassword').focus();
                }
                else
                {
                    var language = $('#option-language').val();

                    if ('${custom}'.includes("<")
                        || '${custom}'.includes(">"))
                    {
                        dialog(languageMap.error, 'Unable to login, please check your URL.', 'alert');
                        return;
                    }

                    $.ajax({
                        type: 'POST',
                        url: 'LoginController?type=system&action=login&custom=${custom}'
                            + '&language=' + language
                            + '&deviceId=${deviceId}'
                            + '&deviceOs=${deviceOs}',
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        data: JSON.stringify(
                            {
                                "username": uid,
                                "password": pwd
                            }
                        ),
//                        data: {
//                            custom: '${custom}',
//                            type: 'system',
//                            action: 'login',
//                            username: uid,
//                            password: pwd,
//                            language: language,
//                            deviceId: '${deviceId}',
//                            deviceOs: '${deviceOs}'
//                        },
                        beforeSend: function()
                        {
                            $('#button-login').prop("disabled", true);
                        },
                        success: function(data)
                        {
                            if (data.result === true)
                            {
                                setCookie('language', language, 7);

                                window.location = 'menu?custom=${custom}';
                            }
                            else
                            {
                                dialog(languageMap.error, data.text, 'alert');

                                $('#txtPassword').val('');
                            }
                        },
                        error: function()
                        {
                            dialog(languageMap.error, languageMap.errorSystem, 'alert');
                        },
                        complete: function()
                        {
                            $('#button-login').prop("disabled", false);
                        },
                        async: false
                    });
                }
            }

            function changeLanguage(value)
            {
                $.ajax({
                    type: 'POST',
                    url: 'LanguageController',
                    data: {
                        type: 'system',
                        action: 'query',
                        language: value,
                        values: 'username,password,login,error,errorSystem,invalidLogin'
                    },
                    success: function(data)
                    {
                        if (data.result === true)
                        {
                            languageMap = data.language;

                            $('#label-username').html(data.language.username);

                            $('#label-password').html(data.language.password);

                            $('#button-login').html(data.language.login);
                        }
                        else
                        {
                            dialog(languageMap.error, data.text, 'alert');
                        }
                    },
                    error: function()
                    {
                        dialog(languageMap.error, languageMap.errorSystem, 'alert');
                    },
                    async: false
                });
            }

        </script>
    </head>
    <body class="cover-image">
        <div class="center-panel">
            <div class="center-text">
                <img class="v3nity-logo" src="img/v3nity-logo.png" alt="v3nity">
                <div class="v3nity-logo-custom"></div>
                <h3 class="v3nity-app-name text-light">${appName}</h3>
                <h5 class="v3nity-app-version text-light v3-fg-darkGray">${appVersion}</h5>
                <h6 class="v3nity-app-company text-light v3-fg-darkGray">${appCompany}</h6>
            </div>
            <iframe src="blank.html" id="login-page" name="login-page" style="display:none"></iframe>
            <form id="form-login" action="blank.html" target="login-page">
                <label id="label-username">Username</label>
                <div class="input-control text full-size">
                    <span class="mif-user prepend-icon"></span>
                    <input id="txtUsername" name="username" type="text">
                </div>
                <label id="label-password">Password</label>
                <div class="input-control password full-size">
                    <span class="mif-lock prepend-icon"></span>
                    <input id="txtPassword" name="password" type="password">
                    <button class="button helper-button reveal" type="button"><span class="mif-looks"></span></button>
                </div>
                <div class="center-text">
                    <button id="button-login" class="button primary" type="submit" onclick="login()">Login</button>
                </div>
            </form>
        </div>
        <div class="input-control select language-selection">
            <span class="mif-earth prepend-icon"></span>
            <select id="option-language" onchange="changeLanguage(this.value)" style="padding-left: 32px">
                <%
                    if (languageTypes != null)
                    {
                        for (Iterator<LanguageProperties> iterator = languageTypes.values().iterator(); iterator.hasNext();)
                        {
                            LanguageProperties language = iterator.next();

                            if (language.getEnabled())
                            {
                                if (language.getCode().equals("en"))
                                {
                                    out.write("<option value=\"" + language.getCode() + "\" selected>" + language.getName() + "</option>");
                                }
                                else
                                {
                                    out.write("<option value=\"" + language.getCode() + "\">" + language.getName() + "</option>");
                                }
                            }
                        }
                    }
                %>
            </select>
        </div>
        <%@ include file="../Common/dialog.jsp"%>
    </body>
</html>