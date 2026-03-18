<%@page import="v3nity.std.biz.data.common.UserProperties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
%>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title></title>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <script type="text/javascript">

            $(document).ready(function()
            {
                if ('${custom}')
                {
                    load('Custom/${custom}/privacy.jsp');
                }
            });

        </script>
    </head>
    <body>
        <%
            if (userProperties.getUser().getString("country").equalsIgnoreCase("VN")) {
        %>    
        <p class=MsoNormal><b><u><span lang=EN-GB><span style='text-decoration:none'></span></span></u></b></p>

        <p class=MsoNormal><b><u><span lang=EN-GB>HỆ THỐNG V3NITY (Phần mềm dưới dạng Ấn bản Dịch vụ) CHÍNH SÁCH RIÊNG TƯ</span></u></b></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal><span lang=EN-GB>Chính sách Riêng tư của chúng tôi giải thích những dữ liệu cá nhân nào mà bạn có thể gửi cho Hệ thống V3NITY và cách các dữ liệu cá nhân này được Hệ thống V3NITY sử dụng. </span></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>Hệ thống V3NITY không tích cực thu thập bất kỳ dữ liệu cá nhân nào. Bạn sẽ chỉ cần gửi địa chỉ email và/hoặc số liên lạc của bạn tới Hệ thống V3NITY nếu bạn muốn Hệ thống V3NITY cảnh báo bạn khi có sự kiện phát sinh. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>Dữ liệu cá nhân của bạn chỉ được sử dụng để cảnh báo bạn khi các sự kiện phát sinh và không được chia sẽ với bất kỳ các bên thứ ba nào. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>Bạn có thể thay đổi hoặc xóa dữ liệu cá nhân của bạn tại bất kỳ thời điểm nào.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>Chúng tôi có quyền thay đổi Chính sách Riêng tư này vào từng thời điểm. </span></p>
        <% 
            } 
            else 
            {
        %>
        <p class=MsoNormal><b><u><span lang=EN-GB><span style='text-decoration:none'></span></span></u></b></p>

        <p class=MsoNormal><b><u><span lang=EN-GB>V3NITY SYSTEM (Software as a
                        Service Edition) PRIVACY POLICY</span></u></b></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal><span lang=EN-GB>Our Privacy Policy explains what personal data you may submit to V3Nity system and how these personal data are used by V3Nity system. </span></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>V3Nity system does not actively collect any personal data.  You will only need to submit your email address and&#47;or contact number to V3Nity system if you want V3Nity system to alert you when events occur. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>Your personal data is only used to alert you when events occur and is not shared with 3rd parties. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>You can change or delete your personal data at any time.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>We may change this privacy policy from time to time.</span></p>
        <% 
            }
        %>
    </body>
</html>
