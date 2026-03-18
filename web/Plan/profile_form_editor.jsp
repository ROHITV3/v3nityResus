<%@page import="java.sql.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@ page import="v3nity.std.biz.data.plan.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    JobFormTemplateDropDown formTemplateDropDown = new JobFormTemplateDropDown(userProperties);

    Connection con = null;

    String type = request.getParameter("type");

    try
    {
        con = userProperties.getConnection();

        formTemplateDropDown.setIdentifier("filter-form-template");

        formTemplateDropDown.loadData(userProperties);

    }
    catch (Exception e)
    {

    }
    finally
    {
        userProperties.closeConnection(con);
    }
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title></title>
        <script type="text/javascript">

            var form;

            $(document).ready(function()
            {
                var options = {
                    language: {
                        formEditor: '<%=userProperties.getLanguage("formEditor")%>',
                        formEditorAddField: '<%=userProperties.getLanguage("formEditorAddField")%>',
                        formEditorFormLayout: '<%=userProperties.getLanguage("formEditorFormLayout")%>',
                        formEditorFormSettings: '<%=userProperties.getLanguage("formEditorFormSettings")%>',
                        formEditorTitle: '<%=userProperties.getLanguage("formEditorTitle")%>',
                        formEditorLabel: '<%=userProperties.getLanguage("formEditorLabel")%>',
                        formEditorText: '<%=userProperties.getLanguage("formEditorText")%>',
                        formEditorId: '<%=userProperties.getLanguage("formEditorId")%>',
                        formEditorPlaceholder: '<%=userProperties.getLanguage("formEditorPlaceholder")%>',
                        formEditorCharacterLimit: '<%=userProperties.getLanguage("formEditorCharacterLimit")%>',
                        formEditorMinimum: '<%=userProperties.getLanguage("formEditorMinimum")%>',
                        formEditorMaximum: '<%=userProperties.getLanguage("formEditorMaximum")%>',
                        formEditorMandatory: '<%=userProperties.getLanguage("formEditorMandatory")%>',
                        formEditorEditable: '<%=userProperties.getLanguage("formEditorEditable")%>',
                        formEditorPreview: '<%=userProperties.getLanguage("formEditorPreview")%>',
                        formEditorItems: '<%=userProperties.getLanguage("formEditorItems")%>',
                        formEditorLines: '<%=userProperties.getLanguage("formEditorLines")%>',
                        formEditorBrowse: '<%=userProperties.getLanguage("formEditorBrowse")%>',
                        formEditorToolbarClearDefault: '<%=userProperties.getLanguage("formEditorToolbarClearDefault")%>',
                        formEditorToolbarDelete: '<%=userProperties.getLanguage("formEditorToolbarDelete")%>',
                        formEditorToolbarMoveUp: '<%=userProperties.getLanguage("formEditorToolbarMoveUp")%>',
                        formEditorToolbarMoveDown: '<%=userProperties.getLanguage("formEditorToolbarMoveDown")%>',
                        formEditorColumnize: '<%=userProperties.getLanguage("formEditorColumnize")%>',
                        formEditorGeotag: '<%=userProperties.getLanguage("formEditorGeotag")%>',
                        formEditorBackup: '<%=userProperties.getLanguage("formEditorBackup")%>',
                        formEditorImageDate: '<%=userProperties.getLanguage("formEditorImageDate")%>',
                        formEditorImageTime: '<%=userProperties.getLanguage("formEditorImageTime")%>',
                        formEditorHint: '<%=userProperties.getLanguage("formEditorHint")%>',
                        formEditorShow: '<%=userProperties.getLanguage("formEditorShow")%>',
                        formEditorAddCamera: '<%=userProperties.getLanguage("formEditorAddCamera")%>'
                    }
                };

                form = new Form('form-template', 'form-menu', options);

                listForm_<%=type%> = new ProfileListForm('<%=type%>-specific-filter', form);

                // bind event for template selection...
                $('#inputFormTemplateNameId').on('change', function()
                {
                    if (this.value !== '')
                    {
                        getForm(this.value);

                        $('#profile-title').html(this.options[this.selectedIndex].text);
                    }
                    else
                    {
                        form.setHtml('');

                        $('#profile-title').html('');
                    }
                });

            });

            function getForm(id)
            {
                $.ajax({
                    type: 'POST',
                    url: 'ListController?lib=v3nity.std.biz.data.plan&type=JobFormTemplate&action=data',
                    data: {
                        id: id
                    },
                    success: function(data)
                    {
                        if (data.expired === undefined)
                        {
                            var html = data.data[3].value;

                            form.setHtml(html);
                        }
                    },
                    error: function()
                    {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }

            function addField(field)
            {
                form.add(field);
            }

        </script>
    </head>
    <body>
        <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <label>Change Profile Template</label>
                    <div class="input-control select full-size">
                        <select name="inputFormTemplateName" id="inputFormTemplateNameId">
                            <option value="">- <%=userProperties.getLanguage("jobFormTemplate")%> -</option>
                            <% formTemplateDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <br>
        <h3 id="profile-title" class="text-light"></h3>
        <br>
        <div class="grid">
            <div class="row">
                <div class="cell">
                    <div id="form-template" class="form-sheet static"></div>
                </div>
            </div>
        </div>
        <input type="hidden" name="profile_title" id="formTemplateName">
        <input type="hidden" name="profile_data" id="formTemplateData">
    </body>
</html>