<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
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
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title></title>
        <script type="text/javascript">

            $(document).ready(function()
            {

                // bind event for template selection...
                $('select[name=template_id]').on('change', function()
                {

                    getForm(this.value);
                });

                $('select[name=inputFormTemplateName]').on('change', function()
                {

                    $.ajax({
                        type: 'POST',
                        url: 'JobReportController',
                        data: {
                            type: 'system',
                            action: 'template',
                            templateId: $("#inputFormTemplateNameId").val()
                        },
                        beforeSend: function()
                        {

                        },
                        success: function(data)
                        {

                            var reportTemplates = data.templates;

                            var html;

                            html += "<option value='0'>- <%=userProperties.getLanguage("jobReportTemplate")%> -</option>";

                            var selected = ' selected'; // use to default select first item...

                            for (var i = 0; i < reportTemplates.length; i++)
                            {

                                var template = reportTemplates[i];

                                html += "<option value='" + template.id + "' " + selected + ">" + template.name + "</option>";

                                selected = '';
                            }

                            document.getElementById('inputReportTemplateNameId').innerHTML = html;
                        },
                        error: function()
                        {
                            dialog('Error', 'System has encountered an error', 'alert');
                        },
                        complete: function()
                        {
                        },
                        async: true
                    });

                    getForm(this.value);
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
                            clearFields();

                            var index = 1;

                            /*
                             * add system fields...
                             */
                            addField('import-system-fields', 'sys-form-template', '<%=userProperties.getLanguage("jobFormTemplate")%>', index++, false);

                            addField('import-system-fields', 'sys-driver-id', '<%=userProperties.getLanguage("driver")%>&nbsp;<%=userProperties.getLanguage("name")%>', index++, false);

                            addField('import-system-fields', 'sys-driver-username', '<%=userProperties.getLanguage("driver")%>&nbsp;<%=userProperties.getLanguage("username")%>', index++, false);

                            addField('import-system-fields', 'sys-duration', '<%=userProperties.getLanguage("jobDuration")%>', index++, false);

                            addField('import-system-fields', 'sys-schedule-dt', '<%=userProperties.getLanguage("jobScheduleDT")%>', index++, false);

                            addField('import-system-fields', 'sys-ref-no', '<%=userProperties.getLanguage("reference")%>', index++, false);

                            addField('import-system-fields', 'sys-location', '<%=userProperties.getLanguage("location")%>', index++, false);

                            addField('import-system-fields', 'sys-postalcode', '<%=userProperties.getLanguage("postalCode")%>', index++, false);

                            addField('import-system-fields', 'sys-timepreferences', '<%=userProperties.getLanguage("timePreferences")%><span title="Format: dd/MM/yyyy hh:MM:ss-dd/MM/yyyy hh:MM:ss"><div class="mif-question" style="margin:10px"></div></span>', index++, false);

                            addField('import-system-fields', 'sys-capacity', '<%=userProperties.getLanguage("capacity")%><span title="Format: Uom;Capacity value"><div class="mif-question" style="margin:10px"></div></span>', index++, false);

                            addField('import-system-fields', 'sys-profileattribute', '<%=userProperties.getLanguage("profileAttribute")%><span title="Format: Profile attribute name, separated by ;"><div class="mif-question" style="margin:10px"></div></span>', index++, false);

                            addField('import-system-fields', 'sys-description', '<%=userProperties.getLanguage("description")%>', index++, false);

                            addField('import-system-fields', 'sys-job-cust-name', '<%=userProperties.getLanguage("jobCustomerName")%>', index++, false);
							
							 addField('import-system-fields', 'sys-job-long', '<%=userProperties.getLanguage("Longitude")%>', index++, false);
                               
                             addField('import-system-fields', 'sys-job-lat', '<%=userProperties.getLanguage("Latitude")%>', index++, false);
                            console.log("test");
                            /*
                             * add user fields...
                             */
                            $.each(data.data, function(i, field)
                            {

                                if (field.name === 'template_data')
                                {
                                    var form = $('<div/>').append(field.value);

                                    $(form).find('.form-field').each(function()
                                    {

                                        var name = $(this).children(':first-child').html();

                                        addField('import-user-fields', this.id, name, index++, false);
                                    });
                                }
                            });
                        }
//                        else
//                        {
//                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                        }
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

            function addField(containerId, id, name, index, active)
            {
                var container = $('#' + containerId);

                var inputField = $('<div/>', {class: 'import-field'});

                var inputLabel = $('<label/>');

                var inputCheckbox = $('<input/>', {type: 'checkbox', value: id, checked: active});

                inputLabel.append(inputCheckbox);

                inputLabel.append(name);

                var inputColumnIndex = $('<input/>', {type: 'text', value: index});

                inputField.append(inputColumnIndex);

                inputField.append(inputLabel);

                container.append(inputField);
            }

            function clearFields()
            {
                $('#import-system-fields').html('');

                $('#import-user-fields').html('');
            }


        </script>
    </head>
    <body>
        <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <label><%=userProperties.getLanguage("formTemplate")%> </label>
                    <span style="color: red; font-weight: bold"> *</span>
                    <div class="input-control select full-size">
                        <select name="inputFormTemplateName" id="inputFormTemplateNameId">
                            <option value="0">- <%=userProperties.getLanguage("jobFormTemplate")%> -</option>
                            <% formTemplateDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                </div>
                <div class="cell">
                    <label><%=userProperties.getLanguage("reportTemplate")%> </label>
                    <span style="color: red; font-weight: bold"> *</span>
                    <div class="input-control select full-size">
                        <select name="inputReportTemplateName" id="inputReportTemplateNameId">
                            <option value="0">- <%=userProperties.getLanguage("jobReportTemplate")%> -</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <br/>
        <h1 class="text-light"><%=userProperties.getLanguage("importEditor")%></h1>
        <% if (userProperties.getString("language").equals("en"))
            {%>
        <div class="help-tag">
            <h4>Instructions:</h4>
            <p>The first input indicates the index of the column in the import file which the system matches this data in the form template.</p>
            <p>The checkbox indicates whether or not the field should be excluded.</p>
            <p>There are 2 categories of fields. Once a form template is selected, the fields should appear in the respectively categories.</p>
            <p>The user fields are extracted from the form template and are optional. The system fields are compulsory.</p>
            <p>If the form template field is used, the system will create the job based on the exact template name specified in the import file.</p>
        </div>
        <% }%>
        <div class="help-tag">

              <p>For Autoscheduling, please import <b>Postal Code</b> and <b>Time Preferences</b>.</p>

        </div>
        <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <h3 class="text-light"><%=userProperties.getLanguage("systemFields")%></h3>
                    <div id="import-system-fields">

                    </div>
                </div>
                <div class="cell">
                    <h3 class="text-light"><%=userProperties.getLanguage("userFields")%></h3>
                    <div id="import-user-fields">

                    </div>
                </div>
            </div>
        </div>
        <input type="hidden" name="template_name" id="templateName">
        <input type="hidden" name="report" id="reportName">
        <input type="hidden" name="import_field" id="jobImportField">
    </body>
</html>