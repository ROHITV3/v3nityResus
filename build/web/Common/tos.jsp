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
                    load('Custom/${custom}/tos.jsp');
                }
            });

        </script>
        
    </head>
    <body>
        <%
            // in case need to switch to language userProperties.getString("language").equalsIgnoreCase("")
            if (userProperties.getUser().getString("country").equalsIgnoreCase("VN")) { 

        %>
        <p class=MsoNormal><b><u><span lang=EN-GB><span style='text-decoration:none'></span></span></u></b></p>

        <p class=MsoNormal><b><u><span lang=EN-GB>HỆ THỐNG V3NITY (Phần mềm dưới dạng Ấn bản Dịch vụ) 
                        CÁC ĐIỀU KHOẢN DỊCH VỤ</span></u></b></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal><span lang=EN-GB>Các Điều khoản Dịch vụ này (“các Điều khoản”) điều chỉnh quyền truy cập và sử dụng của bạn đối với Hệ thống V3NITY (“Dịch vụ”) và bất kỳ thông tin, văn bản, đồ họa nào được tải lên, tải xuống hoặc xuất hiện trên các website, các trang của website, các tính năng tương tác, hoặc các ứng dụng của Dịch vụ, cho dù được truy cập qua máy tính, thiết bị di động hoặc công nghệ, cách thức hoặc phương tiện khác (gọi riêng là một "Website" và gọi chung là "các Website"). Việc truy cập và sử dụng Dịch vụ của bạn bị ràng buộc theo sự chấp nhận của bạn và sự chấp nhận các Điều khoản này. Bạn đồng ý bị ràng buộc bởi các Điều khoản này.</span></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>1.            Sử dụng Dịch vụ</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.1          Để truy cập Dịch vụ, bạn có thể đã được cấp một User ID và mật khẩu. Bạn chịu trách nhiệm bảo vệ mật khẩu mà bạn sử dụng để truy cập Dịch vụ và cho bất kỳ hành động hoặc hoạt động nào dưới mật khẩu của bạn. Nếu bạn biết được bất kỳ việc sử dụng trái phép nào đối với mật khẩu của mình, bạn đồng ý thông báo cho V3 và bất kỳ nhà cung cấp dịch vụ nào mà bạn có thể đã sử dụng để truy cập Dịch vụ.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.2          Bằng việc sử dụng Dịch vụ, bạn đồng ý rằng trong mọi trường hợp, V3 sẽ không chịu trách nhiệm pháp lý đối với bạn hoặc bất kỳ bên thứ ba nào hoặc việc không có khả năng sử dụng Dịch vụ, bất kỳ sự chậm trễ không chính xác, lỗi hoặc thiếu sót liên quan đến bất kỳ thông tin liên lạc hoặc sự truyền tải nào của toàn bộ hoặc một phần của chúng, hoặc bất kỳ thiệt hại nào phát sinh từ hoặc gây ra bởi hoặc cho các kết quả thu được từ việc sử dụng Dịch vụ của bạn. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.3          V3 bảo lưu quyền giới hạn, từ chối hoặc tạo các quyền ưu tiên khác nhau cho các khách hàng khác nhau hoặc thay đổi dịch vụ và/hoặc tất cả các tính năng của dịch vụ và/hoặc thay đổi, nâng cấp điều chỉnh, sửa đổi, giới hạn hoặc chấm dứt Dịch vụ vào bất kỳ lúc nào tạm thời hoặc vĩnh viễn mà không cần thông báo trước và vì bất kỳ lý do nào theo quyết định riêng của mình. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.4          Bạn thừa nhận rằng việc cung cấp dữ liệu lịch sử của tất cả các định tuyến được lưu trữ thông qua cơ sở dữ liệu tập trung được lưu trữ tại trung tâm điều hành mạng và dữ liệu lịch sử đó được lưu giữ trong máy chủ tập trung V3 trong thời gian 180 ngày. Trong khoảng thời gian đó, bạn có thể tải xuống dữ liệu dưới định dạng CSV hoặc Excel trong khoảng thời gian được xác định.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>2.            Giấy phép được Cấp cho Bạn</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>2.1          Phụ thuộc vào các Điều khoản này, V3 theo đây cấp cho bạn một giấy phép không độc quyền để sử dụng phần mềm như là một phần của Dịch vụ được cung cấp cho bạn cho mục đích cá nhân, phi thương mại và việc sử dụng hợp pháp của bạn, như được dự định thông qua chức năng được ủy quyền của Dịch vụ.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>3.            Độc quyền</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>3.1          Bạn xác nhận và đồng ý rằng V3 là chủ sở hữu duy nhất của tất cả các quyền đối với Dịch vụ. Tất cả các giấy tờ xác nhận quyền sở hữu, quyền sở hữu và quyền sở hữu trí tuệ trong Dịch vụ sẽ được giữ nguyên với V3. Tất cả các quyền không được tuyên bố khác trong tài liệu này hoặc bởi V3 theo đây đều được bảo lưu.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>3.2          Các Dịch vụ được bảo vệ bởi luật bản quyền, nhãn hiệu và các quyền sở hữu khác. Không có điều khoản nào cho phép bạn quyền sử dụng bất kỳ các nhãn hiệu, biểu trưng, các tên miền và các đặc điểm thương hiệu đặc biệt nào khác của V3.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>4.            Các trách nhiệm của bạn</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>4.1          Các quyền của bạn theo Giấy phép được nêu ở trên là tùy thuộc vào việc tuân thủ của bạn theo các điều sau:</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(a)          bạn sẽ không được khai thác thương mại bất kỳ thông tin nào nhận được hoặc truy cập thông qua Dịch vụ bao gồm nhưng không giới hạn ở việc sao chép ngoại trừ có văn bản đồng ý trước của V3;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(b)          bạn sẽ không được sử dụng bất kỳ thiết bị, phần mềm hoặc đoạn chương trình nào để can thiệp hoặc cố gắng can thiệp vào sự hoạt động đúng đắn của Dịch vụ;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(c)          bạn sẽ nhận được, cài đặt và duy trì các thiết bị và đường truyền thông phù hợp đó như có thể được quy định bởi V3 cho việc cung cấp Dịch vụ;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal align=left style='margin-top:0cm;margin-right:0cm;
           margin-bottom:10.0pt;margin-left:3.0cm;text-align:left;text-indent:-42.5pt;
           line-height:115%;text-autospace:ideograph-numeric ideograph-other'><span
                lang=EN-GB>(d)          bạn sẽ không được làm suy yếu hoặc cố gắng làm suy yếu an ninh hoặc tính toàn vẹn của hệ thống máy tính hoặc các mạng được sử dụng bởi V3 và/hoặc bất kỳ người dùng Dịch vụ nào và sẽ không cố gắng có được việc truy cập trái phép vào các hệ thống hoặc mạng máy tính đó;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(e)          bạn sẽ không được sử dụng Dịch vụ cho bất kỳ mục đích bất hợp pháp nào hoặc hỗ trợ cho bất kỳ mục đích hoặc hoạt động bất hợp pháp nào;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(f)          bạn đồng ý không tìm hiểu những công nghệ được sử dụng bởi 1 thiết bị, 1 đối tượng hoặc 1 hệ thống thông qua việc phân tích cấu trúc, các chức năng và hoạt động của nó, dịch ngược, tháo rời, thay đổi, nhân bản, tạo bản sao, tạo tác phẩm phái sinh, phân phối hoặc cung cấp cho người khác Dịch vụ, giao thức truyền tin hoặc bất kỳ thông tin nào có sẵn, có nguồn gốc hoặc được trích xuất liên quan đến Dịch vụ khác như được cho phép theo các điều khoản và điều kiện này;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(g)          đảm bảo và đồng ý rằng Khách hàng có tất cả các quyền, bao gồm tất cả bản quyền, hoặc đã có tất cả các giấy phép và giấy phép nhãn hiệu của bên thứ ba cần thiết liên quan đến việc sử dụng Dịch vụ;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(h)           bạn không được sử dụng Dịch vụ vì bất kỳ mục đích bất hợp pháp hoặc không phù hợp nào, bao gồm nhưng không giới hạn ở việc lừa đảo, đánh hơi, mạo danh, gian lận, giả mạo, xâm nhập điện tử, lấy dữ liệu điện toán mà không được phép và lây nhiễm hệ thống, bao gồm nhưng không giới hạn ở việc sử dụng vi-rút, sâu và chương trình độc hại ngụy trang gây thiệt hại trái phép hoặc truy cập có hại và/hoặc truy xuất thông tin;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(i)           bạn sẽ không can thiệp hoặc làm gián đoạn hoặc cố can thiệp hoặc làm gián đoạn hoạt động của Website (hoặc bất kỳ các phần nào của Website đó);</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(j)           bạn sẽ không cố ý truyền tải bất kỳ tài liệu nào chứa phần mềm quảng cáo, vi-rút, bom hẹn giờ, sâu, các ứng dụng phần mềm chạy các tác vụ tự động hóa trên mạng hoặc bất kỳ mã máy tính, tệp hoặc chương trình nào khác được thiết kế để làm gián đoạn, phá hủy hoặc giới hạn chức năng của bất kỳ phần mềm máy tính hoặc thiết bị phần cứng hoặc viễn thông nào;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(k)          bạn sẽ sử dụng Dịch vụ và Giấy phép tại mọi thời điểm tuân thủ theo Điều khoản và tất cả các Luật Áp dụng.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>5.            Các liên kết</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>5.1          Dịch vụ có thể chứa các liên kết đến các website hoặc tài nguyên của bên thứ ba. Bạn thừa nhận và đồng ý rằng chúng tôi không chịu trách nhiệm hoặc có nghĩa vụ về: (i) tính khả dụng hoặc tính chính xác của các website hoặc tài nguyên đó; hoặc (ii) nội dung, sản phẩm hoặc dịch vụ trên hoặc có sẵn từ các website hoặc tài nguyên đó hoặc nội dung, sản phẩm hoặc dịch vụ có sẵn từ các website hoặc tài nguyên đó. Bạn thừa nhận rằng trách nhiệm duy nhất cho và chịu mọi rủi ro phát sinh từ việc bạn sử dụng bất kỳ các website hoặc tài nguyên nào.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>6.            Bảo hành cho Thiết bị</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>6.1          Thời hạn bảo hành từ thiết bị sẽ là một năm kể từ ngày kích hoạt Dịch vụ. Các điều khoản và điều kiện thông thường bảo hành của thiết bị sẽ được áp dụng.  </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>7.            Khước từ các Bảo đảm</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>7.1          BẠN ĐỒNG Ý MỘT CÁCH RÕ RÀNG RẰNG BẠN SỬ DỤNG DỊCH VỤ ĐƯỢC CUNG CẤP "NGUYÊN TRẠNG" VÀ "SẴN CÓ" VÀ V3 THEO ĐÂY KHƯỚC TỪ MỘT CÁCH RÕ RÀNG BẤT KỲ VÀ MỌI BẢO ĐẢM, BIỂU THỊ HOẶC ĐƯỢC NGỤ Ý, BAO GỒM NHƯNG KHÔNG GIỚI HẠN Ở, BẤT KỲ CÁC BẢO ĐẢM NÀO VỀ ĐIỀU KIỆN, CHẤT LƯỢNG, ĐỘ BỀN, TÍNH NĂNG, SỰ CHÍNH XÁC, ĐỘ TIN CẬY, KHẢ NĂNG BÁN ĐƯỢC HOẶC SỰ PHÙ HỢP CHO MỘT MỤC ĐÍCH CỤ THỂ. Tất cả các bảo đảm, tuyên bố, điều kiện, cam kết và điều khoản này theo đây đều bị loại trừ. V3 không tuyên bố hoặc bảo đảm (i) về tính hợp lệ, chính xác, đúng đắn, độ tin cậy, chất lượng, tính ổn định, đầy đủ hoặc trạng thái hiện tại của kỹ thuật và bất kỳ thông tin nào khác được cung cấp qua dịch vụ; (ii) bất kỳ gián đoạn hoặc chấm dứt việc truyền tải đến hoặc từ Website; và/hoặc (iii) bất kỳ lỗi, vi-rút, chương trình độc hại ngụy trang hoặc các loại tương tự mà có thể được chuyển đến hoặc thông qua Dịch vụ hoặc Website bởi bất kỳ bên thứ ba nào. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>7.2          V3 bảo lưu thêm quyền giới thiệu các tính năng, chức năng mới và/hoặc các ứng dụng cho Dịch vụ mới hoặc các phiên bản Dịch vụ mới và tất cả các tính năng, chức năng, ứng dụng, nâng cấp điều chỉnh, sửa đổi mới sẽ được điều chỉnh bởi các điều khoản và điều kiện này, trừ khi được nêu khác đi bởi V3.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>8.            Giới hạn Trách nhiệm</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>8.1          Trong mọi trường hợp, V3 sẽ không chịu trách nhiệm về sự chậm trễ hoặc thất bại hoặc gián đoạn Dịch vụ mà trực tiếp hoặc gián tiếp do các hành vi của thiên nhiên, vũ lực hoặc nguyên nhân gây ra ngoài tầm kiểm soát hợp lý, bao gồm nhưng không giới hạn ở, các hư hỏng Internet, máy tính, viễn thông hoặc bất kỳ thiết bị nào khác hư hỏng, mất điện, đình công, tranh chấp lao động, nỗi dậy, bạo loạn, rối loạn dân sự, thiếu hụt lao động hoặc vật liệu, hỏa hoạn, lũ lụt, bão, nổ, thiên tai, chiến tranh, hành động của chính phủ, lệnh tòa án hoặc trọng tài trong nước hoặc nước ngoài hoặc việc không thực hiện được của các bên thứ ba.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>8.2          BẠN HIỂU RẰNG TRONG PHẠM VI CHO PHÉP THEO LUẬT ÁP DỤNG, TRONG BẤT CỨ TRƯỜNG HỢP NÀO V3 SẼ KHÔNG CHỊU TRÁCH NHIỆM CHO BẤT CỨ THIỆT HẠI ĐẶC BIỆT, TRỰC TIẾP, GIÁN TIẾP, DO TRỪNG PHẠT, NGẪU NHIÊN HOẶC DO HẬU QUẢ HOẶC BẤT CỨ THIỆT HẠI NÀO (BAO GỒM NHƯNG KHÔNG GIỚI HẠN Ở CÁC THIỆT HẠI VỀ MẤT MÁT LỢI NHUẬN HOẶC TIỀN TIẾT KIỆM, KINH DOANH GIÁN ĐOẠN, MẤT THÔNG TIN) CHO DÙ CÓ HAY KHÔNG ĐƯỢC TƯ VẤN VỀ KHẢ NĂNG CỦA THIỆT HẠI, BẤT KỂ HÌNH THỨC CỦA HÀNH ĐỘNG, DÙ CÓ TRONG HỢP ĐỒNG HAY KHÔNG, SƠ SUẤT, SAI LẦM HOẶC VIỆC KHÁC HOẶC BẤT CỨ THIỆT HẠI KHÁC NÀO PHÁT SINH TỪ: (i) VIỆC SỬ DỤNG CỦA BẠN (HOẶC VIỆC SỬ DỤNG CỦA BẤT CỨ AI SỬ DỤNG TÀI KHOẢN ĐĂNG KÝ CHO BẠN) ĐỐI VỚI DỊCH VỤ HOẶC BẤT KỲ PHẦN NÀO CỦA DỊCH VỤ; (ii) CHI PHÍ THU XẾP HÀNG HÓA VÀ DỊCH VỤ THAY THẾ PHÁT SINH TỪ BẤT KỲ HÀNG HÓA, BIỂU MẪU, DỮ LIỆU, THÔNG TIN HOẶC DỊCH VỤ ĐƯỢC MUA HOẶC CÓ ĐƯỢC HOẶC TIN NHẮN NHẬN ĐƯỢC HOẶC GIAO DỊCH ĐƯỢC GIAO KẾT HOẶC THÔNG QUA DỊCH VỤ; (iii) VIỆC TRUY CẬP KHÔNG ĐƯỢC PHÉP ĐẾN HOẶC THAY ĐỔI VIỆC TRUYỀN DẪN HOẶC DỮ LIỆU; (iv) CÁC TUYÊN BỐ HOẶC ĐIỀU KHIỂN CỦA BẤT KỲ BÊN THỨ BA NÀO VỀ DỊCH VỤ; HOẶC (v) BẤT KỲ VẤN ĐỀ KHÁC NÀO LIÊN QUAN ĐẾN DỊCH VỤ ĐƯỢC PHÁT SINH THEO BẤT KỲ CÁCH NÀO.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>8.3          Bạn phải chịu trách nhiệm giữ thiết bị trong tình trạng hoạt động tốt và phải chịu trách nhiệm về chi phí thay thế thiết bị trong trường hợp thiết bị bị hư hỏng do lạm dụng hoặc xử lý sai.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>9.            Chấm dứt</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.1          Bạn hiểu rằng V3 có thể, theo quyết định riêng của mình và vào bất cứ lúc nào tạm thời đình chỉ hoặc chấm dứt các quyền của bạn theo Giấy phép và/hoặc việc truy cập của bạn đến Dịch vụ theo cách khác nếu: (a) bạn đã vi phạm một điều khoản trọng yếu trong tài liệu này; (b) V3 không thể xác minh hoặc xác thực bất kỳ thông tin nào được cung cấp bởi Khách hàng; hoặc (c) V3 tin vào quyết định riêng của mình rằng hành động hoặc thiếu sót của bạn có thể gây ra trách nhiệm pháp lý đối với bản thân bạn, bất kỳ các người dùng nào khác, các nhà cung cấp dịch vụ bên thứ ba và/hoặc V3.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.2          Khi chấm dứt, tất cả các giấy phép, quyền và đặc quyền được cấp cho bạn sẽ chấm dứt.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.3          Bất kể bất kỳ điều khoản nào nêu trên, việc chấm dứt mối quan hệ ở đây sẽ không ảnh hưởng đến bất kỳ quyền hoặc trách nhiệm được tích lũy nào của một bên cũng như không ảnh hưởng đến việc có hiệu lực hoặc việc tiếp tục có hiệu lực của bất kỳ quy định nào trong tài liệu này mà được dự tính một cách rõ ràng hoặc ngụ ý có hiệu lực hoặc tiếp tục có hiệu lực vào hoặc sau khi chấm dứt.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.4          BẠN HIỂU VÀ ĐỒNG Ý RẰNG V3 CÓ THỂ THỰC HIỆN HÀNH ĐỘNG TRÊN MÀ KHÔNG CÓ BẤT KỲ THÔNG BÁO NÀO CHO BẠN, TRƯỚC HOẶC THEO CÁCH KHÁC, VÀ BẠN HIỂU VÀ ĐỒNG Ý RẰNG V3 HAY BẤT KỲ CÁC BÊN LIÊN KẾT NÀO CỦA V3 SẼ KHÔNG CÓ BẤT KỲ TRÁCH NHIỆM NÀO VỚI BẠN HOẶC BẤT KỲ NGƯỜI KHÁC NÀO DO VIỆC CHẤM DỨT VIỆC TRUY CẬP CỦA BẠN ( HOẶC BẤT KỲ NGƯỜI NÀO) ĐẾN WEBSITE HOẶC CÁC PHẦN CỦA TRONG ĐÓ.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>10.            Thông báo</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>10.1          Tất cả các thông báo hoặc yêu cầu đến hoặc theo V3 sẽ có hiệu lực nếu bằng văn bản và sẽ được xem là được thực hiện hợp lệ khi được gửi đến V3 theo cách sau:

Người nhận: 	(V3) V3 SMART TECHNOLOGIES PTE LTD

Địa chỉ: 	150 Kampong Ampat KA Center #05-07 Singapore 368324.

Điện thoại: 	+65 6488 4176/5 		Fax: 	+65 64875287.
</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>10.2          Tất cả thông báo hoặc yêu cầu đến bạn sẽ có hiệu lực nếu được gửi trực tiếp, gửi bằng chuyển phát qua đêm thương mại, thư được chứng nhận hoặc bằng fax hoặc thư điện tử đến địa chỉ và thông tin thư từ do bạn cung cấp (mà bạn có thể sửa đổi hoặc cập nhật vào từng thời điểm).</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>11.          Từ bỏ và Tính hiệu lực</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>11.1        Việc không thực hiện được của V3 để thực thi bất kỳ các quyền hoặc quy định nào của các Điều khoản này sẽ không được coi là từ bỏ quyền hoặc quy định đó. Trong trường hợp bất kỳ điều khoản nào trong các Điều khoản này được coi là không hợp lệ hoặc không thể thi hành, thì các điều khoản còn lại của các Điều khoản này sẽ vẫn duy trì hiệu lực đầy đủ.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>12.          Luật điều chỉnh và Giải quyết Tranh chấp</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>12.1        Các Điều khoản này sẽ được điều chỉnh trong tất cả các khía cạnh bởi pháp luật của của Singapore.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>
                
        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>12.2        Các Bên sẽ cố gắng giải quyết bất kỳ các tranh chấp nào phát sinh từ hoặc liên quan đến các Điều khoản này thông qua thương lượng và hòa giải.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>
                
        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>12.3        Bất kỳ tranh chấp nào phát sinh từ hoặc liên quan đến các Điều khoản này, bao gồm bất kỳ vấn đề nào về sự tồn tại, hiệu lực hoặc chấm dứt, sẽ được chuyển đến và cuối cùng được giải quyết bằng trọng tài do Trung tâm Trọng tài Quốc tế Singapore (“SIAC”) theo các Quy tắc Trọng tài của Trung tâm Trọng tài Quốc tế Singapore ("Quy tắc SIAC") hiện đang có hiệu lực, các quy tắc đó được coi là được cấu thành bằng cách tham chiếu trong khoản này. Địa điểm trọng tài sẽ là Singapore. Hội đồng Trọng tài sẽ gồm 03 trọng tài viên. Ngôn ngữ của trọng tài sẽ là tiếng Anh.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>13.          Điều khoản Chung</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.1        Các điều khoản và điều kiện trong Thỏa thuận và Ứng dụng cấu thành toàn bộ thỏa thuận và sự hiểu biết giữa bạn và V3 và điều chỉnh việc sử dụng Dịch vụ, thay thế bất kỳ thỏa thuận bằng văn bản hoặc bằng miệng nào liên quan đến cùng một vấn đề trong tài liệu này.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.2        Các tiêu đề chỉ nhằm mục đích tham khảo và không bao giờ xác định, giới hạn, hiểu hay mô tả phạm vi hoặc mức độ của phần đó.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.3        V3 có quyền chuyển nhượng nghĩa vụ và trách nhiệm của mình cho bất kỳ cá nhân hoặc tổ chức nào.</span></p>
                
        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.4        Không quy định nào trong các Điều khoản này được xem là thiết lập mối quan hệ giữa các Bên là một hợp danh hoặc hiệp hội. Không Bên nào phải chịu trách nhiệm đối với các hành động hoặc các sai sót của Bên còn lại. Không Bên nào là đại diện hoặc có bất kỳ quyền nào được ràng buộc Bên còn lại nào dưới bất kỳ hình thức nào ngoài các quy định đã được nêu rõ tại các Điều khoản này.</span></p>
                
                <!-- End of VN TOS --> 
                
        <%        } else {
        %>
        
        <!-- Start of EN TOS -->
        <p class=MsoNormal><b><u><span lang=EN-GB><span style='text-decoration:none'></span></span></u></b></p>

        <p class=MsoNormal><b><u><span lang=EN-GB>V3NITY SYSTEM (Software as a
                        Service Edition) TERMS OF SERVICE</span></u></b></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal><span lang=EN-GB>These Terms of Service (“Terms”) govern
                your access and use of V3Nity System (the “Service”) and any
                information, text, graphics uploaded, downloaded or appearing on the Service’s
                web sites, web pages, interactive features, or applications, whether accessed
                via computer, mobile device or other technology, manner or means (each a
                “Site”, and collectively “Sites”) Your access and use of the Service is
                conditioned on your acceptance and acceptance of these Terms. You agree to be
                bound by these Terms. </span></p>

        <p class=MsoNormal><span lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>1.            Use of Service</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.1          To access the Service, you may have been assigned a
                User ID and password. You are responsible for safeguarding the password that
                you use to access the Service and for any actions or activities under your
                password. If you become aware of any unauthorized use of your password, you
                agree to notify V3 and any service provider you may have used to access the
                Service.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.2          By using the Service, you agree that in no event shall
                V3 be liable to you or any third party or any inability to use the Service, any
                delays inaccuracies, errors or omissions with respect to any communications or
                transmission on delivery of all or any part thereof, or any damage arising from
                or occasioned by or for the results obtained from the your use of the Service. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.3          V3 reserves the right to limit, deny or create
                different priorities to different customers or to change the service and/or all
                of its features and /or to change, upgrade modify, alter, limit or terminate
                the Service at any time temporarily or permanently without prior notice and for
                any reason at its sole discretion. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>1.4          You acknowledge that provision of historical data of
                all the vehicles routes are stored through a centralized database hosted at the
                network operating centre and such historical data are kept in V3 centralised server
                for a period of 180 days. Within such period, you may download the data into CSV
                or Excel format within the defined period.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>2.            License Granted to You</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>2.1          Subject to these terms, V3 hereby grant you a
                non-exclusive licence to use the software as part of the Service provided to
                you for your personal, non-commercial, lawful use, as intended through the
                authorized functionality of the Service.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>3.            Proprietary rights</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>3.1          You acknowledge and agree that V3 is the sole owner of
                all the rights to the Service. All title, ownership and intellectual property
                rights in the Service shall remain with V3. All rights not otherwise claimed
                herein or by V3 are hereby reserved.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>3.2          The Services are protected by copyright, trademark, and
                other proprietary rights laws. Nothing in the terms gives you a right to use
                any of V3 trademarks, logo, domain names and other distinctive brand features.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>4.            Your Responsibilities</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>4.1          Your rights under the License set forth above are
                conditioned upon your compliance with the following:</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(a)          you shall not commercially exploit any information
                received or accessed through the Service including by but not limited to
                copying except with V3 prior written consent;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(b)          you shall not use any device, software or routine to
                interfere or attempt to interfere with the proper working of the Service;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(c)          you shall obtain, install and maintain such suitable
                equipment and communication lines as may be specified by V3 for the provision
                of the Service;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal align=left style='margin-top:0cm;margin-right:0cm;
           margin-bottom:10.0pt;margin-left:3.0cm;text-align:left;text-indent:-42.5pt;
           line-height:115%;text-autospace:ideograph-numeric ideograph-other'><span
                lang=EN-GB>(d)          you shall not undermine or attempt to undermine the
                security or integrity of the computer systems or networks used by V3 and/or any
                user of the Service and shall not attempt to gain unauthorized access to such
                computer systems or networks.</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(e)          you shall not use the Service for any illegal purposes
                or in support of any illegal purpose or activity;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(f)          you agree not to reverse engineers, decompile,
                disassemble, alter, duplicate, make copies, create derivative works from,
                distribute or provide others with the Service, its communication protocol or
                any information available on, derived or extracted in relation to the Service
                other than as allowed under these terms and conditions;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(g)          warrants and agrees that the Customer has all rights,
                including all copyrights, or has obtained all necessary third party copyright
                or trademark licenses and permissions in relation to the usage of the Service;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(h)           you shall not use the Service for any unlawful or
                inappropriate purposes, including without limitation, spoofing, sniffing,
                imposturing, fraud, forgery, electronic trespass, hacking and system contamination
                including without limitation, use of viruses, worms and Trojan Horses causing
                unauthorized damage or harmful access and/or retrieval of information.</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(i)           you will not interfere with or disrupt, or attempt to
                interfere with or disrupt, the operation of the Site (or any parts thereof)</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(j)           you will not knowingly transmit any material that
                contains adware, software viruses, timebombs, worms, bots or any other computer
                code, files or programmes designed to interrupt, destroy or limit the
                functionality of any computer software or hardware or telecommunications
                equipment;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:3.0cm;text-indent:-42.55pt'><span
                lang=EN-GB>(k)          you will use the Service and License at all times in
                compliance with the Terms and all Applicable Laws</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>5.            Links</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>5.1          The Service may contain links to third-party websites
                or resources. You acknowledge and agree that we are not responsible or liable
                for: (i) the availability or accuracy of such websites or resources; or (ii)
                the content, products, or services on or available from such subsites or
                resources or the content, products, or services available from such websites or
                resources. You acknowledge that the sole responsibility for and assume all risk
                arising from your use of any websites or resources.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>6.            Warranty for Equipment</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>6.1          Warranty period from equipment will be one year from
                the date of activation of the Service. The equipment’s warranty Normal terms
                and conditions shall apply.  </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>7.            Disclaimer of Warranties</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>7.1          YOU EXPRESSLY AGREE THAT YOUR USE OF THE SERVICE IS
                PROVIDED “AS IS” AND “AS AVAILABLE” AND V3 HEREBY EXPRESSLY DISCLAIMS ANY AND
                ALL WARRANTIES. EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES
                OF CONDITION, QUALITY, DURABILITY, PERFORMANCE, ACCURACY, RELIABILITY,
                MERCHANTABILIRY OR FITNESS FOR A PARTICULAR PURPOSE. All such warranties,
                representations, conditions, undertakings and terms are hereby excluded. V3
                makes no representations or warranties (i) about the validity, accuracy, correctness,
                reliability, quality, stability, completeness or current state of technical and
                any other information provided through the service; (ii) any interruption or
                cessation of transmission to or from the Site; and/or (iii) any bugs, viruses,
                Trojan horses, or the like which may be transmitted to or through the Service
                or Site by any third party. </span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>7.2          V3 further reserves the right to introduce new
                features, functionalities and .or applications to the new Service or to future
                versions of the Service and all new features, functionalities, applications,
                modifications upgrades and alterations shall be governed by these terms and
                conditions, unless otherwise stated by V3.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>8.            Limitation of Liability</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>8.1          Under no circumstances shall V3 be held liable for an
                delay or failure or disruption of the Service resulting directly or indirectly
                from acts of nature, forces or causes beyond its reasonable control, including
                without limitation, Internet failures, computer, telecommunications or any
                other equipment failures, electrical power failures, strikes, labour disputes,
                riots, insurrections, civil disturbances, shortages of labour or materials,
                fires, flood, storms, explosions, Acts of God, war, governmental actions,
                orders of domestic or foreign courts or tribunals or non-performance of third
                parties.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>8.2          YOU UNDERSTAND THAT TO THE EXTENT PERMITTED UNDER
                APPLICABLE LAWS, IN NO EVENT WILL V3 BE HELD LIABLE FOR ANY SPECIAL, DIRECT,
                INDIRECT, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
                WHATSOEVER (INCLUDING BUT NOT LIMITED TO DAMAGES FOR LOSS OF PROFITS OR
                SAVINGS, BUSINESS INTERRUPTION, LOSS OF INFORMATION) WHETHER OR NOT ADVISED OF
                THE POSSIBILITY OF DAMAGE, REGARDLESS OF THE FORM OF ACTION, WHETHER IN
                CONTRACT, NEGLIGENCE, TORT OR OTHERWISE OR ANY OTHER DAMAGES RESULTING FROM: (i)
                YOUR USE (OR USE OF ANYONE USING AN ACCOUNT REGISTERED TO YOU) OF THE SERVICE
                OR ANY PARTS THEREOF; (ii) THE COST OF PROCUREMENT OF SUBSTITIYUTE GOODS AND
                SERVICES RESULTING FROM ANY FOODS, SAMPLES, DATA, INFORMATION OR SERVICES PURCHASED
                OR OBTANED OR MESSAFES RECEIVED OR TEANSACTIONS ENTERED INTO OR THROUGH THE
                SERVICE; (iii) UNAUTHORIZED ACCCESS TO OR ALTERATION OF TRANSMISSIONS OR DATA; (iv)
                STATEMENTS OR CONDUCT OF ANY THIRD PARTY ON THE SERVICE; OR (v) ANY OTHER
                MATTER RELATING TO THE SERVICE HOWEVER ARISING.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>8.3          You shall be responsible to keep the equipment in good
                operating condition and shall be responsible for equipment replacement cost in
                the event the equipment is damaged by abuse or mishandling.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>9.            Termination</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.1          You understand that V3 may, in its sole discretion and
                at any time temporarily suspend or terminate your rights under the License and
                or otherwise your access to the Service if: (a) you have breached a material
                term herein; (b) V3 is unable to verify or authenticate any information
                provided by the Customer; or (c) V3 believes in its sole discretion that the
                your act or omission may cause legal liability on yourself, any other users,
                third party service providers and/or V3.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.2          Upon termination, all licenses, rights and privileges
                granted to you shall cease.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.3          Notwithstanding any of the above provisions,
                termination of the relationship herein shall not affect any accrued rights or
                liabilities of either party nor shall it affect the coming into force or the
                continuance in force of any provision contained herein which is expressly or by
                implication intended to come into or continue in force on or after such
                termination.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>9.4          YOU UNDERSTAND AGREE THAT V3 MAY TAKE THE ABOVE ACTION
                WITHOUT ANY NOTICE TO YOU, PRIOR OR OTHERWISE, AND YOU UNDERSTAND AND AGREE
                THAT NEITER V3 NOR ANY OF ITS AFFILIATES SHALL HAVE ANY LIABILITY TO YOU OR ANY
                OTHER PERSON FOR THE TERMINATION OF YOUR (OR ANYONE ELSE’S) ACCESS TO THE SITE
                OR PARTS THEREOF.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>10.            Notices</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>10.1          All notices or demands to or upon V3 shall be effective
                if in writing and shall be deemed to have been duly made when sent to V3 in the
                following manner : Attn: (V3) V3 SMART TECHNOLOGIES PTE LTD at 150 Kampong Ampat KA
                Centre #06-06A Singapore 368324.  Tel : +65 6488 4176/5  Fax : +65 64875287</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>10.2          All notices or demands to you shall be effective if
                either delivered personally, sent by commercial overnight courier, certified
                mail, or by facsimile or email to the addresses and correspondence information
                provided by you (as you may have amended or updated from time to time).</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>11.          Waiver and Severability</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>11.1        The failure of V3 to enforce any rights or provisions of
                these Terms shall not be deemed a waiver of such right or provision. In the
                event that any of these provisions of these Terms is held to be invalid or
                unenforceable, the remaining provisions of these Terms will remain in full
                force and effect.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>12.          Governing Law</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>12.1        These terms and conditions shall be governed in all
                respects by the non-exclusive jurisdiction of the Singapore and the Parties
                hereby irrevocably submit to the non-exclusive jurisdiction of the Singapore
                courts.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><b><span
                    lang=EN-GB>13.          General</span></b></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.1        These terms and conditions in the Agreement and the
                Application constitute the entire agreement and understanding between you and
                V3 and govern the use of the Service, superseding any prior written or oral
                agreements in relation to the same subject matter herein.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.2        Headings are for reference purposes only and in no way
                define, limit, construe or describe the scope or extent of such section.</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>&nbsp;</span></p>

        <p class=MsoNormal style='margin-left:42.55pt;text-indent:-42.55pt'><span
                lang=EN-GB>13.3        V3 shall have the right to assign their obligations and
                duties herein to any person or entity.</span></p>
                <%
                    }
                %>
    </body>
</html>
