<%@page import="v3nity.std.biz.data.common.*"%>
<%@ page import="v3nity.std.biz.data.plan.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
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
                        formEditorCollapsedItems: '<%=userProperties.getLanguage("formEditorCollapsedItems")%>',
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
                        formEditorCompute: '<%=userProperties.getLanguage("formEditorCompute")%>',
                        formEditorMaximumAdd: '<%=userProperties.getLanguage("formEditorMaximumAdd")%>',
                        formEditorShow: '<%=userProperties.getLanguage("formEditorShow")%>',
                        formEditorAddCamera: '<%=userProperties.getLanguage("formEditorAddCamera")%>',
                        formEditorRefresh: '<%=userProperties.getLanguage("formEditorRefresh")%>',
                        formEditorRemove: '<%=userProperties.getLanguage("formEditorRemove")%>',
                        formEditorShowAll: '<%=userProperties.getLanguage("formEditorShowAll")%>',
                        formEditorKeyword: '<%=userProperties.getLanguage("formEditorKeyword")%>',
                        formEditorCollapsedItems: '<%=userProperties.getLanguage("formEditorCollapsedItems")%>'
                    }
                };

                form = new Form('form-template', 'form-menu', options);

                listForm_JobFormTemplate = new JobFormTemplateListForm('specific-filter', form);
            });

            function addField(field)
            {
                form.add(field);
            }

        </script>
    </head>
    <body>
        <% request.setAttribute("user", userProperties);%>

        <jsp:include page="../Plan/form_editor.jsp"/>

        <input type="hidden" name="template_data" id="formTemplateData">
    </body>
</html>


