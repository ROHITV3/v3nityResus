<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%    
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    JobImportTemplateTreeView importTreeView = new JobImportTemplateTreeView(userProperties);

    importTreeView.setIdentifier("filter-import");

    importTreeView.loadData(userProperties);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title></title>
        <script type="text/javascript">

            var successCount = 0;
            var VALUE_DAILY = 1;
            var VALUE_MONTHLY = 2;

            $(document).ready(function()
            {
                $('#input-file').on('change', handleFile);

                changeGrid();
            });

            function getSelectedId()
            {
                var id = getTreeId('tree-view-filter-import', 'filter-import-id');

                return id;
            }

            function getSelectedRecurringType()
            {
                var e = document.getElementById("recurring-type");
                var value = e.options[e.selectedIndex].value;

                return value;
            }

            function select()
            {
                var recurringType = parseInt(getSelectedRecurringType());

                if (recurringType == VALUE_DAILY)
                {
                    if (($('#daily-grid').serialize()).length < 2)
                    {
                        dialog('Unable to Continue', 'Please select day(s)', 'alert');
                        return;
                    }
                }
                else
                {
                    if (($('#monthly-grid-months').serialize()).length < 2)
                    {
                        dialog('Unable to Continue', 'Please select month(s)', 'alert');
                        return;
                    }
                    if (($('#monthly-grid-dates').serialize()).length < 2)
                    {
                        dialog('Unable to Continue', 'Please select date(s)', 'alert');
                        return;
                    }
                }

                $('#input-file').click();
            }

            function handleFile(e)
            {
                var index = 0;

                var file = e.target.files[0];   // only get first file...

                var reader = new FileLineStreamer();    // this is a custom filereader that reads line by line on demand without holding everything in the memory...

                var hasHeader = true;

                var bypassHeader = false;

                successCount = 0;

                var recurringType = parseInt(getSelectedRecurringType());
                var recurringData;

                if (recurringType == VALUE_DAILY)
                {
                    recurringData = $('#daily-grid').serialize();
                }
                else
                {
                    recurringData = $('#monthly-grid-months').serialize() + '&' + $('#monthly-grid-dates').serialize();
                }

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

                        $('#output').append('<p class="output-info">' + successCount + ' lines imported successfully</p>');

                        return;
                    }

                    var data = {
                        recurringType: recurringType,
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
                var recurringType = parseInt(getSelectedRecurringType());
                var recurringData;

                if (recurringType == VALUE_DAILY)
                {
                    recurringData = $('#daily-grid').serialize();
                }
                else
                {
                    recurringData = $('#monthly-grid-months').serialize() + '&' + $('#monthly-grid-dates').serialize();
                }

//                console.log('recurringData: ' + recurringData);

                $.ajax({
                    type: 'POST',
                    url: 'RecurringJobImportController?type=system&action=upload',
                    data: $('#form-input').serialize() + '&' + recurringData,
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


            function changeGrid()
            {
                var e = document.getElementById("recurring-type");
                var value = e.options[e.selectedIndex].value;

                if (value == VALUE_DAILY)
                {
                    document.getElementById('daily-grid').style.display = "block";
                    //document.getElementById('button-hide-param').style.display = "inline-block";
                    document.getElementById('monthly-grid-months').style.display = "none";
                    document.getElementById('monthly-grid-dates').style.display = "none";
                }
                else
                {
                    document.getElementById('daily-grid').style.display = "none";
                    //document.getElementById('button-hide-param').style.display = "inline-block";
                    document.getElementById('monthly-grid-months').style.display = "block";
                    document.getElementById('monthly-grid-dates').style.display = "block";
                }
            }

            function TriggerRecurring()
            {
                $.ajax({
                    type: 'POST',
                    url: 'RecurringJobImportController?type=system&action=dorecur',
                    data: 'abcde',
                    beforeSend: function()
                    {

                    },
                    success: function(data)
                    {

                    },
                    error: function()
                    {

                    },
                    complete: function()
                    {

                    },
                    async: false
                });
            }

        </script>

    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("importRecurringJob")%></h1>
        </div>
        <div class="help-tag">
            <h4>Instructions:</h4>
            <p>Importing file only supports CSV format (comma-separated).</p>
            <p>CSV should have only 5 columns: (1) Template Name, (2) Assigned Staff (optional), (3) Start Time, (4) Duration in Minutes, and (5) Starting From.</p>
        </div>
        <div class="toolbar">
            <button class="toolbar-button" onclick="TriggerRecurring()" style="width: fit-content; padding-left: 10px; padding-right: 10px; display: none">Trigger Recurring</button>
        </div>
        <div class="grid">
            <div class="row cells4">
                <div class="cell">
                    <div class="input-control select full-size">
                        <select name = "recurring-type" id="recurring-type" onchange="changeGrid()">
                            <option value = "1">DAILY</option>
                            <option value = "2">MONTHLY</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <form id="daily-grid" name="daily-grid" class="grid">
            <h4>Select Days</h4>
            <div class="row cells4">
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="mon" name="mon" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Monday</span>
                    </label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="tue" name="tue" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Tuesday</span>
                    </label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="wed" name="wed" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Wednesday</span>
                    </label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="thu" name="thu" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Thursday</span>
                    </label>
                </div>
            </div>
            <div class="row cells4">
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="fri" name="fri" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Friday</span>
                    </label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="sat" name="sat" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Saturday</span>
                    </label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox">
                        <input id="sun" name="sun" type="checkbox">
                        <span class="check"></span>
                        <span class="caption">Sunday</span>
                    </label>
                </div>
                <div class="cell"></div>
            </div>
        </form>

        <form id="monthly-grid-months" class="grid" style="display:none">
            <h4>Select Months</h4>
            <div class="row cells4">
                <div class="cell">
                    <label class="input-control checkbox"><input id="jan" name="jan" type="checkbox">
                        <span class="check"></span><span class="caption">January</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="feb" name="feb" type="checkbox">
                        <span class="check"></span><span class="caption">February</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="mar" name="mar" type="checkbox">
                        <span class="check"></span><span class="caption">March</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="apr" name="apr" type="checkbox">
                        <span class="check"></span><span class="caption">April</span></label>
                </div>
            </div>
            <div class="row cells4">
                <div class="cell">
                    <label class="input-control checkbox"><input id="may" name="may" type="checkbox">
                        <span class="check"></span><span class="caption">May</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="jun" name="jun" type="checkbox">
                        <span class="check"></span><span class="caption">June</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="jul" name="jul" type="checkbox">
                        <span class="check"></span><span class="caption">July</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="aug" name="aug" type="checkbox">
                        <span class="check"></span><span class="caption">August</span></label>
                </div>
            </div>
            <div class="row cells4">
                <div class="cell">
                    <label class="input-control checkbox"><input id="sep" name="sep" type="checkbox">
                        <span class="check"></span><span class="caption">September</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="oct" name="oct" type="checkbox">
                        <span class="check"></span><span class="caption">October</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="nov" name="nov" type="checkbox">
                        <span class="check"></span><span class="caption">November</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="dec" name="dec" type="checkbox">
                        <span class="check"></span><span class="caption">December</span></label>
                </div>
            </div>
        </form>

        <form id="monthly-grid-dates" class="grid" style="display:none">
            <h4>Select Dates</h4>
            <div class="row cells6">
                <div class="cell">
                    <label class="input-control checkbox"><input id="1" name="1" type="checkbox">
                        <span class="check"></span><span class="caption">1</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="2" name="2" type="checkbox">
                        <span class="check"></span><span class="caption">2</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="3" name="3" type="checkbox">
                        <span class="check"></span><span class="caption">3</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="4" name="4" type="checkbox">
                        <span class="check"></span><span class="caption">4</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="5" name="5" type="checkbox">
                        <span class="check"></span><span class="caption">5</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="6" name="6" type="checkbox">
                        <span class="check"></span><span class="caption">6</span></label>
                </div>
            </div>
            <div class="row cells6">
                <div class="cell">
                    <label class="input-control checkbox"><input id="7" name="7" type="checkbox">
                        <span class="check"></span><span class="caption">7</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="8" name="8" type="checkbox">
                        <span class="check"></span><span class="caption">8</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="9" name="9" type="checkbox">
                        <span class="check"></span><span class="caption">9</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="10" name="10" type="checkbox">
                        <span class="check"></span><span class="caption">10</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="11" name="11" type="checkbox">
                        <span class="check"></span><span class="caption">11</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="12" name="12" type="checkbox">
                        <span class="check"></span><span class="caption">12</span></label>
                </div>
            </div>
            <div class="row cells6">
                <div class="cell">
                    <label class="input-control checkbox"><input id="13" name="13" type="checkbox">
                        <span class="check"></span><span class="caption">13</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="14" name="14" type="checkbox">
                        <span class="check"></span><span class="caption">14</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="15" name="15" type="checkbox">
                        <span class="check"></span><span class="caption">15</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="16" name="16" type="checkbox">
                        <span class="check"></span><span class="caption">16</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="17" name="17" type="checkbox">
                        <span class="check"></span><span class="caption">17</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="18" name="18" type="checkbox">
                        <span class="check"></span><span class="caption">18</span></label>
                </div>
            </div>
            <div class="row cells6">
                <div class="cell">
                    <label class="input-control checkbox"><input id="19" name="19" type="checkbox">
                        <span class="check"></span><span class="caption">19</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="20" name="20" type="checkbox">
                        <span class="check"></span><span class="caption">20</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="21" name="21" type="checkbox">
                        <span class="check"></span><span class="caption">21</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="22" name="22" type="checkbox">
                        <span class="check"></span><span class="caption">22</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="23" name="23" type="checkbox">
                        <span class="check"></span><span class="caption">23</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="24" name="24" type="checkbox">
                        <span class="check"></span><span class="caption">24</span></label>
                </div>
            </div>
            <div class="row cells6">
                <div class="cell">
                    <label class="input-control checkbox"><input id="25" name="25" type="checkbox">
                        <span class="check"></span><span class="caption">25</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="26" name="26" type="checkbox">
                        <span class="check"></span><span class="caption">26</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="27" name="27" type="checkbox">
                        <span class="check"></span><span class="caption">27</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="28" name="28" type="checkbox">
                        <span class="check"></span><span class="caption">28</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="29" name="29" type="checkbox">
                        <span class="check"></span><span class="caption">29</span></label>
                </div>
                <div class="cell">
                    <label class="input-control checkbox"><input id="30" name="30" type="checkbox">
                        <span class="check"></span><span class="caption">30</span></label>
                </div>
            </div>
            <div class="row cells6">
                <div class="cell">
                    <label class="input-control checkbox"><input id="31" name="31" type="checkbox">
                        <span class="check"></span><span class="caption">31</span></label>
                </div>
            </div>
        </form>
        <div class="section" style="display: none">
            <h4 class="text-light align-left">Select Import Template</h4>
            <div class="treeview-control" style="height:auto">
                <% importTreeView.outputHTML(out, userProperties);%>
            </div>
        </div>
        <div class="section" style="display: none">
            <h4 class="text-light align-left">Options</h4>
            <label class="input-control checkbox">
                <input id="input-header" type="checkbox" checked>
                <span class="check"></span>
                <span class="caption">File contains header</span>
            </label>
        </div>
        <div class="section">
            <h4 class="text-light align-left">Select File</h4>
            <button id="button-upload" type="button" class="button primary" onclick="select()">Browse</button>
        </div>
        <div id="output" class="section"></div>
        <input id="input-file" type="file" style="display: none" accept=".csv"/>
        <form id="form-input" method="post">
            <input id="input-data" name="inputData" type="hidden"/>
        </form>

    </body>
</html>