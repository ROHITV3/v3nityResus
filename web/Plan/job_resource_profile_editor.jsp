<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.plan.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
    
    JobResourceProfileGroupDropDown profileGroupDropDown = new JobResourceProfileGroupDropDown(userProperties);

    profileGroupDropDown.setIdentifier("filter-profile-group");
    
    profileGroupDropDown.loadData(userProperties);
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <title></title>
        <script type="text/javascript">
            
        $(document).ready(function()
        {

            $('select[name=inputProfileGroup]').on('change', function()
            {

                $.ajax({
                    type: 'POST',
                    url: 'JobResourceProfileController',
                    data: {
                        type: 'system',
                        action: 'data',
                        profileGroupId: $("#inputProfileGroupId").val()
                    },
                    beforeSend: function()
                    {
                        
                    },
                    success: function(data)
                    {

                        var profileAttributes = data.attributes;

                        var html;

                        html = "<option value='0'>- <%=userProperties.getLanguage("profileAttribute")%> -</option>";

                        var selected = ' selected'; // use to default select first item...

                        for (var i = 0; i < profileAttributes.length; i++)
                        {

                            var attribute = profileAttributes[i];

                            html += "<option value='" + attribute.id + "' " + selected + ">" + attribute.name + "</option>";
                            
                            selected = '';
                        }

                        document.getElementById('inputProfileAttributeId').innerHTML = html;
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
            });
        });
        
        var original_showEdit = showEdit_JobResourceProfile;
        showEdit_JobResourceProfile = function(id)
        {
            $.ajax({
               url: "JobResourceProfileController?lib=v3nity.std.biz.controller&type=JobResourceProfile&action=getProfile",
               type: "POST",
               data: {id : id},
               success: function (data) {
                    if (data.result)
                    {
                        var attrGroupId = data.attrGroupId;
                        var attrId = data.attrId;
                        var profileAttributes = data.attributes;
              
                        if (typeof attrGroupId !== 'undefined')
                        {
                            var groupOption = document.getElementById('inputProfileGroupId');
                            groupOption.value = attrGroupId;    

                            if (typeof profileAttributes !== 'undefined')
                            {
                                var html;
                                html = "<option value='0'>- <%=userProperties.getLanguage("profileAttribute")%> -</option>";
                                var selected = ' selected';
                                for (var i = 0; i < profileAttributes.length; i++)
                                {
                                    var attribute = profileAttributes[i];
                                    
                                    html += "<option value='" + attribute.id + "' " + selected + ">" + attribute.name + "</option>";
                                    selected = '';
                                }
                                document.getElementById('inputProfileAttributeId').innerHTML = html;
                            }
          
                            var attrOption = document.getElementById('inputProfileAttributeId');
                            attrOption.value = attrId;
                        }
                    }
                    else
                    {
                        dialog('Failed', 'Failed to obtain Resource information', 'alert');
                    }
                }
            });

            return original_showEdit(id);
        };
            
        function clearFields()
        {
            document.getElementById('inputProfileAttributeId').innerhtml = "- <%=userProperties.getLanguage("profileAttribute")%> -";
        }
        
        </script>
    </head>
    <body>
         <div class="grid">
            <div class="row cells2">
                <div class="cell">
                    <label>Profile Group </label>
                    <span style="color: red; font-weight: bold"> *</span>
                    <div class="input-control select full-size">
                        <select name="inputProfileGroup" id="inputProfileGroupId">
                            <option value="0">- <%=userProperties.getLanguage("profileGroup")%> -</option>
                             <% profileGroupDropDown.outputHTML(out, userProperties);%>
                        </select>
                    </div>
                </div>

                <div class="cell">
                    <label>Profile Attribute </label>
                    <span style="color: red; font-weight: bold"> *</span>
                    <div class="input-control select full-size">
                        <select name="inputProfileAttribute" id="inputProfileAttributeId">
                            <option value="0">- <%=userProperties.getLanguage("profileAttribute")%> -</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <input type="hidden" name="profile_attribute_id" id="ProfileAttribute">
        
    </body>
</html>
