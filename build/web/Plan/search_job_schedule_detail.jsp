<%-- 
    Document   : search_job_schedule_detail
    Created on : 20 Oct, 2020, 12:25:31 PM
    Author     : tsidd
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <style>
            #jobId{
                    width: 320.687px;
                    height: 35px;
                    border: 1px #d9d9d9 solid;
                    padding: .3125rem;
                  } 
                  
            #but{
                   height: 35px;
                   width: 100px;
                   margin-left: 30px;
                   background-color: #437DC6;
                   color: rgb(255, 255, 255);
                      
                  }
                  
           
            
        </style>
        <script type="text/javascript">
            function DetailRetrieve()
            {
                var id= document.getElementById('jobId').value;
               
                var detailId;
                
                
                $.ajax(
                {
                    
                    type: 'POST',
                   url: 'SearchJobScheduleDetailController?lib=${lib}&type=${type}&action=getJobDetail',
                    data: {
                        
                        detailId: id
                    },
                    beforeSend: function () {
                    },
                    success: function (data) 
                    {  
                        
                         $("#descriptionId").val('');
                         
                       
                        document.getElementById('descriptionId').innerText =data.detail;
                    },
                    error: function () {
                        dialog('Error', 'System has encountered an error', 'alert');
                    },
                    complete: function () {
                        
                    },
                    async: true
                });
            }
          
        </script>
    </head>
    <body>
        <h1>Retrieve Job Detail</h1><br><br>
        <h4>Job Id</h4>
        <input type="text" id="jobId" >
        <button onclick="DetailRetrieve()" id="but">Retrieve</button>
        <br>
        <div id="detailDiv">
            <h4 id="descriptionId" class="descriptionClass"></h4>
            
        </div>
            
        
    </body>
</html>
