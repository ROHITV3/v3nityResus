<%@page import="v3nity.std.biz.data.common.*"%>
<%
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");
%>
<div>
    <h1 class="text-light"><%=userProperties.getLanguage("formEditor")%></h1>
    <div class="grid">
        <div class="row cells2">
            <div class="cell">
                <h3 class="text-light" id="form-toolbar-title"><%=userProperties.getLanguage("formEditorAddField")%></h3>
                <div id="form-toolbar">
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Label());">
                        <span class="title"><%=userProperties.getLanguage("label")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new SingleLine());">
                        <span class="title"><%=userProperties.getLanguage("singleLine")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new MultiLine());">
                        <span class="title"><%=userProperties.getLanguage("multiLine")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Radiobuttons());">
                        <span class="title"><%=userProperties.getLanguage("radioButtons")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Checkboxes());">
                        <span class="title"><%=userProperties.getLanguage("checkboxes")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Selection());">
                        <span class="title"><%=userProperties.getLanguage("selection")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Beacon());">
                        <span class="title"><%=userProperties.getLanguage("beacon")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new StaticImage());">   <!-- Formerly called "Image". Name is changed because of conflicting with google map-->
                        <span class="title"><%=userProperties.getLanguage("reportImg")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Gallery());">
                        <span class="title"><%=userProperties.getLanguage("gallery")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Camera());">
                        <span class="title"><%=userProperties.getLanguage("camera")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new CameraLibrary());">
                        <span class="title"><%=userProperties.getLanguage("cameraLibrary")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Signature());">
                        <span class="title"><%=userProperties.getLanguage("signature")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Barcode());">
                        <span class="title"><%=userProperties.getLanguage("barcode")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Ratings());">
                        <span class="title"><%=userProperties.getLanguage("ratings")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Collapser());">
                        <span class="title"><%=userProperties.getLanguage("collapser")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new RatingsSummary());">
                        <span class="title"><%=userProperties.getLanguage("ratingsSummary")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Email());">
                        <span class="title"><%=userProperties.getLanguage("email")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new EmailMultiple());">
                        <span class="title"><%=userProperties.getLanguage("emailMultiple")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new EmailSelection());">
                        <span class="title"><%=userProperties.getLanguage("emailSelection")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new Drawing());">
                        <span class="title"><%=userProperties.getLanguage("drawing")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new NumberKeypad());">
                        <span class="title"><%=userProperties.getLanguage("numberKeypad")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new DatePicker());">
                        <span class="title"><%=userProperties.getLanguage("date")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new TimePicker());">
                        <span class="title"><%=userProperties.getLanguage("time")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new DateTimePicker());">
                        <span class="title"><%=userProperties.getLanguage("dateTime")%></span>
                    </button>
<!--                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new IconCheckbox());">
                        <span class="title">Icon CheckBox</span>
                    </button> -->
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new AddCamera());">
                        <span class="title"><%=userProperties.getLanguage("dynamicCamera")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new EmbeddedURL());">
                        <span class="title"><%=userProperties.getLanguage("embedURL")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new OTPField());">
                        <span class="title"><%=userProperties.getLanguage("otp")%></span>
                    </button>
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new NumberRange());">
                        <span class="title"><%=userProperties.getLanguage("numberRange")%></span>
                    </button>
                    
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new UploadVideo());">
                        <span class="title"><%=userProperties.getLanguage("uploadVideo")%></span>
                    </button>
                    
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new ImageDrawing());">   
                        <span class="title"><%=userProperties.getLanguage("ImageDrawing")%></span>
                    </button>
                    
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new CaptureGeotag());">
                        <span class="title"><%=userProperties.getLanguage("captureGeotag")%></span>
                    </button>
                    
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new TimeCapture());">
                        <span class="title"><%=userProperties.getLanguage("timeCapture")%></span>
                    </button>
                    
                    <button type="button" class="shortcut-button bg-white bg-active-grayLighter fg-black" onclick="addField(new File());">
                        <span class="title"><%=userProperties.getLanguage("file")%></span>
                    </button>
                </div>
                <br>
                <h3 class="text-light"><%=userProperties.getLanguage("formEditorFieldSettings")%></h3>
                <div id="form-menu" class="form-menu"></div>
            </div>
            <div class="cell">
                <h3 class="text-light"><%=userProperties.getLanguage("formEditorFormLayout")%></h3>
                <div id="form-template" class="form-sheet" start-lon="0.0" start-lat="0.0" end-lon="0.0" end-lat="0.0" ></div>
            </div>
        </div>
    </div>
</div>
