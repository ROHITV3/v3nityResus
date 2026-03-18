<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
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
                        formEditorReplaceImage: '<%=userProperties.getLanguage("formEditorReplaceImage")%>',
                        formEditorDeleteImage: '<%=userProperties.getLanguage("formEditorDeleteImage")%>',
                        formEditorAddImage: '<%=userProperties.getLanguage("formEditorAddImage")%>',
                        formEditorMaximumAdd: '<%=userProperties.getLanguage("formEditorMaximumAdd")%>',
                        formEditorCompute: '<%=userProperties.getLanguage("formEditorCompute")%>',
                        formEditorShow: '<%=userProperties.getLanguage("formEditorShow")%>',
                        formEditorAddCamera: '<%=userProperties.getLanguage("formEditorAddCamera")%>',
                        formEditorRefresh: '<%=userProperties.getLanguage("formEditorRefresh")%>',
                        formEditorRemove: '<%=userProperties.getLanguage("formEditorRemove")%>',
                        formEditorShowAll: '<%=userProperties.getLanguage("formEditorShowAll")%>',
                        formEditorKeyword: '<%=userProperties.getLanguage("formEditorKeyword")%>',
                        formEditorCollapsedItems: '<%=userProperties.getLanguage("formEditorCollapsedItems")%>'
                    }
                };

                // Call V3nity-form.js
                form = new Form('form-template', 'form-menu', options);

                listForm = new JobScheduleListForm('specific-filter', form);

                if (!addTemplate)
                {
                    $('#form-toolbar').css({'pointer-events': 'none', 'opacity': 0.5});
                }

                if (!editTemplate)
                {
                    $('#form-menu').css({'pointer-events': 'none', 'opacity': 0.5});
                }

                if (!deleteTemplate)
                {
                    form.menu.noDelete = true;
                }

                if (!viewTemplate)
                {
                    $('#form-template').css({'pointer-events': 'none', 'opacity': 0.5});
                }
            });

            function addField(field)
            {
                form.add(field);
            }

        </script>
    </head>

    <% request.setAttribute("properties", userProperties);%>

    <jsp:include page="../Plan/form_editor.jsp"/>

    <input type="hidden" name="template_name" id="formTemplateName">

    <input type="hidden" name="report" id="reportTemplateName">

    <input type="hidden" name="report_data" id="reportTemplateData">
    
    <input type="hidden" name="doc_file_name" id="docFileName">

    <input type="hidden" name="details" id="formTemplateDetails">

    <input type="hidden" name="preview" id="formTemplatePreview">

</html>