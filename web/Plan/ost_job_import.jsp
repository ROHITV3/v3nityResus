<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    JobImportTemplateTreeView importTreeView = new JobImportTemplateTreeView(userProperties);

    try
    {
        importTreeView.setIdentifier("filter-import");

        importTreeView.loadData(userProperties);
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
        <title></title>
        <script type="text/javascript">

            var successCount = 0;

            $(document).ready(function()
            {
                $('#input-file').on('change', handleFile);
            });

            function getSelectedId()
            {
                var id = getTreeId('tree-view-filter-import', 'filter-import-id');

                return id;
            }

            function select()
            {
                if (getSelectedId() !== '')
                {
                    $('#input-file').click();
                }
                else
                {
                    dialog('No Template Selected', 'Please select an import template', 'alert');
                }
            }

            function handleFile(e)
            {
                var index = 0;

                var file = e.target.files[0];   // only get first file...

                var reader = new FileLineStreamer();    // this is a custom filereader that reads line by line on demand without holding everything in the memory...

                var hasHeader = $('#input-header').prop('checked');

                var bypassHeader = false;

                successCount = 0;

                var importId = parseInt(getSelectedId());

                $('#output').html('');

                reader.open(file, function(lines, err)
                {
                    if (err !== null)
                    {

                        $('#output').append('<p class="output-error">' + err + '</p>');

                        return;
                    }
                    if (lines === null)
                    {

                        if (hasHeader)
                        {
                            index -= 1;
                        }

                        $('#output').append('<p class="output-info">' + index + ' lines are processed</p>');

                        $('#output').append('<p class="output-info">' + successCount + ' lines are imported successfully</p>');

                        return;
                    }

                    var data = {
                        importId: importId, // the import id...
                        lineIndex: index, // the starting index of the first line per batch and we use this as line number during import...
                        lineCount: 0, // the total lines per batch...
                        lines: []
                    };

                    // output every line
                    lines.forEach(function(line)
                    {

                        if (hasHeader && !bypassHeader)
                        {
                            // bypass header line...
                            bypassHeader = true;
                        }
                        else
                        {
                            data.lines.push(Base64.encode(line));

                            data.lineCount++;
                        }

                        index++;
                    });

                    document.getElementById('input-data').value = JSON.stringify(data);

                    upload();

                    reader.getNextBatch();
                });

                if (file)
                {
                    reader.getNextBatch();
                }
                else
                {
                    dialog('File Error', 'System cannot read file', 'alert');
                }
            }

            function upload()
            {
                $.ajax({
                    type: 'POST',
                    url: 'OSTJobImportController?type=system&action=upload',
                    data: $('#form-input').serialize(),
                    beforeSend: function()
                    {
                        $('#button-upload').prop("disabled", true);
                    },
                    success: function(data)
                    {

                        if (data.expired === undefined)
                        {
                            successCount += data.successCount;

                            var output = $('#output');

                            if (data.result === false)
                            {
                                output.append('<p class="output-error">' + data.text + '</p>');
                            }

                            for (var i = 0; i < data.errors.length; i++)
                            {
                                output.append('<p class="output-error">' + data.errors[i] + '</p>');
                            }
                        }
//                        else
//                        {
//                            $('#main').load('Common/expired.jsp', {custom: '${custom}'});
//                        }
                    },
                    error: function()
                    {

                        $('#output').append('<p class="output-error">System has encountered an error</p>');
                    },
                    complete: function()
                    {
                        $('#button-upload').prop("disabled", false);

                        $('#input-file').val('');   // reset the input file value so that can allow upload the same file again...
                    },
                    async: false
                });
            }

        </script>

    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("ostjobimport")%></h1>
        </div>
        <div class="help-tag" >
            
            <h4><%=userProperties.getLanguage("instructions")%>:</h4>
            <p><%=userProperties.getLanguage("jobImportInstructions1")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructions2")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructions3")%></p>
            <p><%=userProperties.getLanguage("jobImportInstructions4")%></p>
        </div>
        <div class="section">
            <h4 class="text-light align-left"><%=userProperties.getLanguage("selectImportTemplate")%></h4>
            <div class="treeview-control" style="height:auto">
                <% importTreeView.outputHTML(out, userProperties);%>
            </div>
        </div>
        <div class="section">
            <h4 class="text-light align-left"><%=userProperties.getLanguage("options")%></h4>
            <label class="input-control checkbox">
                <input id="input-header" type="checkbox" checked>
                <span class="check"></span>
                <span class="caption"><%=userProperties.getLanguage("fileContainsHeader")%></span>
            </label>
        </div>
        <div class="section">
            <h4 class="text-light align-left"><%=userProperties.getLanguage("selectFile")%></h4>
            <button id="button-upload" type="button" class="button primary" onclick="select()"><%=userProperties.getLanguage("formEditorBrowse")%></button>
        </div>
        <div id="output" class="section">

        </div>
        <input id="input-file" type="file" style="display: none" accept=".csv"/>
        <form id="form-input" method="post">
            <input id="input-data" name="inputData" type="hidden"/>
        </form>

    </body>
</html>