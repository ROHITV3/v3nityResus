<%--
    Document   : preloader
    Created on : 10 Oct, 2018, 10:52:14 PM
    Author     : Kevin
--%>

<div id="page-preloader" class="page-preloader-overlay" style="display: none">
    <div class="page-preloader"></div>
</div>
<script type="text/javascript">

    function preloader(on)
    {
        var preloader = document.getElementById("page-preloader");

        if (on)
        {
            preloader.style.display = "block";
        }
        else
        {
            preloader.style.display = "none";
        }
    }

</script>