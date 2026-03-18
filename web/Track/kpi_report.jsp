<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.*"%>
<%@page import="v3nity.std.core.data.*"%>
<%@page import="v3nity.std.core.data.list.*"%>
<%@page import="v3nity.std.biz.data.common.*"%>
<%@page import="v3nity.std.biz.data.track.*"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%    
    UserProperties userProperties = (UserProperties) request.getAttribute("properties");

    AssetTreeView assetTreeView = new AssetTreeView(userProperties);

    assetTreeView.setIdentifier("filter-asset");

    assetTreeView.loadData(userProperties);

    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy");

    java.util.Date today = new java.util.Date();

    String inputStartDate = dateTimeFormatter.format(today) + " 00:00:00";

    String inputEndDate = dateTimeFormatter.format(today) + " 23:59:59";
%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <link href="css/metricsgraphics.css" rel="stylesheet">

        <style type="text/css">

            .circle{
                width: 50%;
            }
            .circleA {width: 10px;
                      height: 10px;
                      border-radius: 50%;
                      font-size: 10px;
                      color: #fff;
                      line-height: 10px;
                      text-align: center;
                      background: #008000;
            }

            .circleB {
                width: 30px;
                height: 10px;
                border-radius: 50%;
                font-size: 10px;
                color: #fff;
                line-height: 10px;
                text-align: center;
                background:  #493D26;
            }

            .circleC {
                width: 30px;
                height: 10px;
                border-radius: 50%;
                font-size: 10px;
                color: #fff;
                line-height: 10px;
                text-align: center;
                background: #728C00;
            }

            .circleD {
                width: 30px;
                height: 10px;
                border-radius: 50%;
                font-size: 10px;
                color: #fff;
                line-height: 10px;
                text-align: center;
                background:  #FFFF00;
            }
            .circleE {
                width: 30px;
                height: 10px;
                border-radius: 50%;
                font-size: 10px;
                color: #fff;
                line-height: 10px;
                text-align: center;
                background: #E799A3;
            }
            .circleF {
                width: 30px;
                height: 10px;
                border-radius: 50%;
                font-size: 10px;
                color: #fff;
                line-height: 10px;
                text-align: center;
                background: #F88017;
            }
            .circleG {
                width: 30px;
                height: 10px;
                border-radius: 50%;
                font-size: 10px;
                color: #fff;
                line-height: 10px;
                text-align: center;
                background: #FF0000;
            }
            .solid
            {
                width: 90%;
                height:700px;
            }

            /*.solid {border-style: solid;}*/
            font.hidden{
                visibility: hidden;
            }
            #table1
            {
                background-color: #D3D3D3;
                border-collapse: collapse;
                margin-left:30px;
                width: 95%;
            }
            .tt
            {
                border: none;
            }
            #val
            {
                background-color:#FFFFFF;
            }
            #tdt
            {
                width: 50px;
                height: 10px;
            }
            .table2
            {

                margin-left:30px;
                height: 390px;
                table-layout: fixed;
            }
            #tdt1
            {

                height: 40px;
            }
            #t1
            {
                margin-left:60px;
                margin-right: 20px;
            }
            .table2 td + td { border-left:1px solid #5B5858; }
            .table2 td {
                padding: 4px;
            }


        </style>
        <title>${title}</title>
        <script src="js/d3.min.js"></script>
        <script src="js/metricsgraphics.min.js"></script>
        <script type="text/javascript" >

            var s = "";
            var asset1 = [];
            $(document).ready(function()
            {

                $("#solid").hide();
                $("#getChart").click(function()
                {
                    s = "";
                    asset1 = [];
                    $.each($("input[name='invid']:checked"), function()
                    {
                        asset1.push($(this).val());
                        s += ($(this).val());

                    });

                    if (asset1.length > 1)
                    {
                        dialog('Error', 'Only 1 Asset can be selected at one time', 'alert');

                    }
                    else if (asset1.length < 1)
                    {
                        dialog('Error', 'Please select 1 Asset', 'alert');
                    }
                    else
                    {

                        getKPI(s);

                    }

                });
//                $("#historyFromDate").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
//                $("#historyToDate").AnyTime_picker({format: "%d/%m/%Y %H:%i:%s"});
            });



            function getKPI(s)
            {

                var startDate = document.getElementById("historyFromDate").value;
                var endDate = document.getElementById("historyToDate").value;

                $.ajax({
                    url: 'KPIReportController?type=post',
                    data: {
                        action: 'get',
                        assetName: s,
                        startDate: startDate,
                        endDate: endDate

                    },
                    success: function(data)
                    {
                        updateResult(data);
                        $("#solid").show();

                    },
                    error: function()
                    {
                        dialog('Error', 'Error Occured', 'alert');
                    }
                });
            }

            function updateResult(data)
            {
                var frmDate = data.fromDt;
                var toDate = data.toDt;
                var assetName = data.Asset.fontcolor("#486192");
                var totalMiles = data.totalMiles.fontsize(6);
                var totalEngineRun = data.totalEngineRun.fontsize(6);
                var totalGallons = data.totalGallons.fontsize(6);
                var avgMPG = data.avgMPG.fontsize(6);
                var totalRating = data.TotalRating;
                var accel = data.Accel;
                var cruiseControl = data.cruise;
                var engineIdle = data.Engine;
                var greenBand = data.GreenBand;
                var HarshBreaking = data.harshbreaking;
                var overRevving = data.OverRevving;
                var overSpeed = data.OverSpeed;
                var fuelEconomy = data.FuelEconomy;
                var value1 = data.value1.fontsize(2);
                var value2 = data.value2.fontsize(2);
                var value3 = data.value3.fontsize(2);
                var value4 = data.value4.fontsize(2);
                var value5 = data.value5.fontsize(2);
                var value6 = data.value6.fontsize(2);
                var value7 = data.value7.fontsize(2);
                var value8 = data.value8.fontsize(2);

                var date = "\xa0\xa0\Date :" + " " + frmDate + " " + "- " + toDate;
                document.getElementById("para1").innerHTML = date.fontcolor("#486192").bold();

                var avgValue = document.getElementById("table1").rows[2].cells;
                var ttlMile = document.getElementById("table1").rows[2].cells;
                ttlMile[1].innerHTML = totalMiles.bold();

                var ttlEngRun = document.getElementById("table1").rows[2].cells;
                ttlEngRun[2].innerHTML = totalEngineRun.bold();

                var ttlGallon = document.getElementById("table1").rows[2].cells;
                ttlGallon[3].innerHTML = totalGallons.bold();

                var avgMP = document.getElementById("table1").rows[2].cells;
                avgMP[4].innerHTML = avgMPG.bold();

                var a = document.getElementById("aa1").rows[13].cells;
                a[3].innerHTML = value1;
                var b = document.getElementById("aa1").rows[13].cells;
                a[5].innerHTML = value2;
                var a = document.getElementById("aa1").rows[13].cells;
                a[7].innerHTML = value3;
                var a = document.getElementById("aa1").rows[13].cells;
                a[9].innerHTML = value4;
                var a = document.getElementById("aa1").rows[13].cells;
                a[11].innerHTML = value5;
                var a = document.getElementById("aa1").rows[13].cells;
                a[13].innerHTML = value6;
                var a = document.getElementById("aa1").rows[13].cells;
                a[15].innerHTML = value7;
                var a = document.getElementById("aa1").rows[13].cells;
                a[17].innerHTML = value8;

                if (totalRating == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[1].setAttribute('class', 'circleA');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(8);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();
                }
                else if (totalRating == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;

                    x[1].setAttribute('class', 'circleB');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(9);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();
                }
                else if (totalRating == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[1].setAttribute('class', 'circleC');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(9);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();

                }
                else if (totalRating == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[1].setAttribute('class', 'circleD');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(9);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();

                }
                else if (totalRating == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[1].setAttribute('class', 'circleE');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(9);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();

                }
                else if (totalRating == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[1].setAttribute('class', 'circleF');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(9);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();

                }
                else if (totalRating == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[1].setAttribute('class', 'circleG');
                    x[1].innerHTML = totalRating.fontsize(3).bold();
                    var result = totalRating.fontsize(9);
                    avgValue[0].innerHTML = result.fontcolor("#493D26").bold();
                }


                if (accel == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[3].setAttribute('class', 'circleA');
                    x[3].innerHTML = accel.fontsize(3).bold();

                }
                else if (accel == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;

                    x[3].setAttribute('class', 'circleB');
                    x[3].innerHTML = accel.fontsize(3).bold();

                }
                else if (accel == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[3].setAttribute('class', 'circleC');
                    x[3].innerHTML = accel.fontsize(3).bold();

                }
                else if (accel == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[3].setAttribute('class', 'circleD');
                    x[3].innerHTML = accel.fontsize(3).bold();

                }
                else if (accel == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[3].setAttribute('class', 'circleE');
                    x[3].innerHTML = accel.fontsize(3).bold();

                }
                else if (accel == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[3].setAttribute('class', 'circleF');
                    x[3].innerHTML = accel.fontsize(3).bold();

                }
                else if (accel == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[3].setAttribute('class', 'circleG');
                    x[3].innerHTML = accel.fontsize(3).bold();
                }

                if (cruiseControl == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[5].setAttribute('class', 'circleA');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();

                }
                else if (cruiseControl == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[5].setAttribute('class', 'circleB');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();

                }
                else if (cruiseControl == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[5].setAttribute('class', 'circleC');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();

                }
                else if (cruiseControl == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[5].setAttribute('class', 'circleD');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();

                }
                else if (cruiseControl == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[5].setAttribute('class', 'circleE');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();

                }
                else if (cruiseControl == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[5].setAttribute('class', 'circleF');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();

                }
                else if (cruiseControl == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[5].setAttribute('class', 'circleG');
                    x[5].innerHTML = cruiseControl.fontsize(3).bold();
                }


                if (engineIdle == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[7].setAttribute('class', 'circleA');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();

                }
                else if (engineIdle == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[7].setAttribute('class', 'circleB');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();

                }
                else if (engineIdle == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[7].setAttribute('class', 'circleC');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();

                }
                else if (engineIdle == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[7].setAttribute('class', 'circleD');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();

                }
                else if (engineIdle == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[7].setAttribute('class', 'circleE');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();

                }
                else if (engineIdle == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[7].setAttribute('class', 'circleF');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();

                }
                else if (engineIdle == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[7].setAttribute('class', 'circleG');
                    x[7].innerHTML = engineIdle.fontsize(3).bold();
                }

                if (greenBand == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[9].setAttribute('class', 'circleA');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }
                else if (greenBand == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[9].setAttribute('class', 'circleB');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }
                else if (greenBand == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[9].setAttribute('class', 'circleC');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }
                else if (greenBand == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[9].setAttribute('class', 'circleD');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }
                else if (greenBand == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[9].setAttribute('class', 'circleE');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }
                else if (greenBand == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[9].setAttribute('class', 'circleF');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }
                else if (greenBand == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[9].setAttribute('class', 'circleG');
                    x[9].innerHTML = greenBand.fontsize(3).bold();

                }

                if (HarshBreaking == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[11].setAttribute('class', 'circleA');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }
                else if (HarshBreaking == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[11].setAttribute('class', 'circleB');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }
                else if (HarshBreaking == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[11].setAttribute('class', 'circleC');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }
                else if (HarshBreaking == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[11].setAttribute('class', 'circleD');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }
                else if (HarshBreaking == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[11].setAttribute('class', 'circleE');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }
                else if (HarshBreaking == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[11].setAttribute('class', 'circleF');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }
                else if (HarshBreaking == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[11].setAttribute('class', 'circleG');
                    x[11].innerHTML = HarshBreaking.fontsize(3).bold();

                }

                if (overRevving == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[13].setAttribute('class', 'circleA');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }
                else if (overRevving == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[13].setAttribute('class', 'circleB');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }
                else if (overRevving == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[13].setAttribute('class', 'circleC');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }
                else if (overRevving == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[13].setAttribute('class', 'circleD');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }
                else if (overRevving == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[13].setAttribute('class', 'circleE');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }
                else if (overRevving == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[13].setAttribute('class', 'circleF');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }
                else if (overRevving == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[13].setAttribute('class', 'circleG');
                    x[13].innerHTML = overRevving.fontsize(3).bold();

                }

                if (overSpeed == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[15].setAttribute('class', 'circleA');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();

                }
                else if (overSpeed == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[15].setAttribute('class', 'circleB');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();

                }
                else if (overSpeed == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[15].setAttribute('class', 'circleC');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();

                }
                else if (overSpeed == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[15].setAttribute('class', 'circleD');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();

                }
                else if (overSpeed == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[15].setAttribute('class', 'circleE');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();

                }
                else if (overSpeed == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[15].setAttribute('class', 'circleF');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();

                }
                else if (overSpeed == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[15].setAttribute('class', 'circleG');
                    x[15].innerHTML = overSpeed.fontsize(3).bold();
                }

                if (fuelEconomy == 'A')
                {
                    var x = document.getElementById("aa1").rows[1].cells;
                    x[17].setAttribute('class', 'circleA');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();

                }
                else if (fuelEconomy == 'B')
                {
                    var x = document.getElementById("aa1").rows[2].cells;
                    x[17].setAttribute('class', 'circleB');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();

                }
                else if (fuelEconomy == 'C')
                {
                    var x = document.getElementById("aa1").rows[3].cells;
                    x[17].setAttribute('class', 'circleC');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();

                }
                else if (fuelEconomy == 'D')
                {
                    var x = document.getElementById("aa1").rows[4].cells;
                    x[17].setAttribute('class', 'circleD');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();
                }
                else if (fuelEconomy == 'E')
                {
                    var x = document.getElementById("aa1").rows[5].cells;
                    x[17].setAttribute('class', 'circleE');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();

                }
                else if (fuelEconomy == 'F')
                {
                    var x = document.getElementById("aa1").rows[6].cells;
                    x[17].setAttribute('class', 'circleF');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();

                }
                else if (fuelEconomy == 'G')
                {
                    var x = document.getElementById("aa1").rows[7].cells;
                    x[17].setAttribute('class', 'circleG');
                    x[17].innerHTML = fuelEconomy.fontsize(3).bold();
                }

            }

        </script>
    </head>
    <body>
        <div>
            <h1 class="text-light"><%=userProperties.getLanguage("kpiReport")%></h1>
        </div>
        <div class="toolbar">
            <div class="toolbar-section">
                <button class="toolbar-button" id="getChart" name="getChart"><span class="mif-search"></span></button>
            </div>
            <div class="toolbar-section">
                <!--  <button class="toolbar-button" id="reset" name="reset" value="" onclick="resetDate()"><span class="mif-undo"></span></button> -->
            </div>
        </div>
        <div class="grid">
            <div class="row cells6">
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("asset")%></h4>
                    <div id="chartFrame" class="treeview-control">
                        <%-- <% assetTreeView.outputHTML(out);%> --%>
                        
                        <%
                            int id = userProperties.getUser().getId();
                            List<String> assetList = new ArrayList<>();
                            String query = "select c_asset.label from c_user inner join c_asset on c_user.customer_id= c_asset.customer_id where c_asset.asset_type_id=1 AND c_user.id=" + id;
                            Connection connection = null;
                            DataHandler dataHandler = new DataHandler();
                            try
                            {
                                connection = userProperties.getConnection();

                                dataHandler.setConnection(connection);

                                PreparedStatement stmt = null;
                                ResultSet rs = null;
                                stmt = connection.prepareStatement(query);
                                rs = stmt.executeQuery();
                                while (rs.next())
                                {
                                    String name = rs.getString("label");
                                    assetList.add(name);
                                }
                            
                            }
                            catch (Exception e)
                            {
                                e.printStackTrace();
                            }
                            finally
                            {
                                dataHandler.closeConnection();
                            }
                            //System.out.println(assetList);
                            for (int i = 0; i < assetList.size(); i++)
                            {
                        %>
                        <input type="checkbox" class="invid" name="invid" value="<%= assetList.get(i)%>">&nbsp;<%= assetList.get(i)%><br>
                        <%
                            }
                        %>
                    </div>
                </div>
                <div class="cell">
                    <h4 class="text-light align-left"><%=userProperties.getLanguage("dateRange")%></h4>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="historyFromDate" type="text" placeholder="<%=userProperties.getLanguage("selectStartDate")%>" value="<%=inputStartDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                    <div class="input-control text" data-role="input">
                        <span class="mif-calendar prepend-icon"></span>
                        <input id="historyToDate" type="text" placeholder="<%=userProperties.getLanguage("selectEndDate")%>" value="<%=inputEndDate%>" autocomplete="on">
                        <button class="button helper-button clear"><span class="mif-cross"></span></button>
                    </div>
                </div>
                <div class="cell colspan4">


                    <!----- Table  FOR KPI--->

                    <div class="solid" id="solid">
                        <p id="par">  </p>
                        <br><p id="para"> </p>
                        <br>
                        <p id="para1"> </p>
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <table id="table1" >
                            <tr id="tt">
                                <td id="tt" colspan="4" style="text-align:center;"> <br><font size="5">&nbsp;&nbsp;&nbsp;&nbsp; Total Rating &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font> </td>
                                <td id="tt" style="text-align:center;"> <br><font size="5">Total KM &nbsp;&nbsp;</font></td>
                                <td id="tt" style="text-align:center;"> <br><font size="5">Total Engine Run &nbsp;&nbsp;</font></td>
                                <td id="tt" style="text-align:center;"> <br><font size="5">Total Litres &nbsp;&nbsp;</font></td>
                                <td id="tt" style="text-align:center;"> <br><font size="5">AVG KPL &nbsp;&nbsp;</font></td>
                            </tr>
                            <tr > <td colspan="8" style="color:#D3D3D3;">&nbsp;&nbsp;&nbsp;. </td></tr>
                            <tr id="tt">
                                <td id="tt" colspan="4" style="text-align:center;"> </td>
                                <td id="tt" style="text-align:center;">             </td>
                                <td id="tt" style="text-align:center;">             </td>
                                <td id="tt" style="text-align:center;">             </td>
                                <td id="tt" style="text-align:center;">             </td>
                            </tr>
                            <tr > <td colspan="8" style="color:#D3D3D3;">&nbsp;&nbsp;&nbsp;. </td></tr>
                        </table>
                        <br>
                        <table id="aa1" class="table2"  >
                            <tr>
                                <td> <font class="hidden" style="color:#D3D3D3;">aaa</font> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Total Rating<font class="hidden" style="color:#D3D3D3;">..</font> </td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Accel >95%<font class="hidden" style="color:#D3D3D3;">aa.</font></td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Cruise Control<font class="hidden" style="color:#D3D3D3;">a</font> </td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Engine Idle<font class="hidden" style="color:#D3D3D3;">aaaa</font></td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Safe Turning<font class="hidden" style="color:#D3D3D3;">a.</font></td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Harsh Braking</td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Over Revving<font class="hidden" style="color:#D3D3D3;">..</font></td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Over Speed<font class="hidden" style="color:#D3D3D3;">a..</font></td>
                                <td> </td>
                                <td id="tdt1" style="background-color: #D3D3D3; text-align:left;"><br>Fuel Economy<font class="hidden" style="color:#D3D3D3;"></font></td>
                            </tr>

                            <tr id="tdt1">
                                <td class="circleA"><font size="5"> A </font> </td>
                                <td id="tdt1" style=" text-align:center;"></td>
                                <td> </td>
                                <td id="tdt1" class="rw2col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw2col9" style="text-align:center;"> </td>
                            </tr>

                            <tr id="tdt1">
                                <td id="tdt1" class="circleB"><font size="5"> B </font> </td>
                                <td id="tdt1" style=" text-align:center;">   </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw3col9" style="text-align:center;"> </td>
                            </tr>

                            <tr id="tdt1">
                                <td id="tdt1" class="circleC" > <font size="5"> C </font></td>
                                <td id="tdt1" style=" text-align:center;">    </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw4col9" style="text-align:center;"> </td>
                            </tr>

                            <tr id="tdt1"  >
                                <td id="tdt1" class="circleD"> <font size="5"> D </font> </td>
                                <td id="tdt1" style=" text-align:center;">    </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw5col9" style="text-align:center;"> </td>
                            </tr>
                            <tr id="tdt1">
                                <td class="circleE"> <font size="5"> E </font> </td>
                                <td id="tdt1"  style=" text-align:center;">    </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw6col9" style="text-align:center;"> </td>
                            </tr>
                            <tr id="tdt1" >
                                <td class="circleF"> <font size="5"> F </font></td>
                                <td id="tdt1" style=" text-align:center;">    </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw7col9" style="text-align:center;"> </td>
                            </tr>
                            <tr id="tdt1"  >
                                <td class="circleG"> <font size="5"> G </font> </td>
                                <td id="tdt1"  style=" text-align:center;">    </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col2" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col3" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col4" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col5" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col6" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col7" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col8" style="text-align:center;"> </td>
                                <td> </td>
                                <td id="tdt1" class="rw8col9" style="text-align:center;"> </td>
                            </tr>
                            <tr id="val"> <td colspan="17"> </td></tr>
                            <tr id="val"> <td colspan="17"> </td></tr>
                            <tr id="val"> <td colspan="17"> </td></tr><tr id="val"> <td colspan="17"> </td></tr><tr id="val"> <td colspan="9"> </td></tr>
                            <tr id="val"  >
                                <td><font class="hidden" style="color:#D3D3D3;">aaa</font> </td>
                                <td ><h5>VALUES</h5></td>
                                <td> </td><td id="tdt" class="valcol1" style="background-color: #D3D3D3;text-align:center;">   </td>
                                <td> </td><td id="tdt"  class="valcol2" style="background-color: #D3D3D3;text-align:center;">  </td>
                                <td> </td><td id="tdt"  class="valcol3" style="background-color: #D3D3D3;text-align:center;">  </td>
                                <td> </td><td id="tdt"  class="valcol4" style="background-color: #D3D3D3;text-align:center;">   </td>
                                <td> </td><td id="tdt"  class="valcol5" style="background-color: #D3D3D3;text-align:center;">    </td>
                                <td> </td><td id="tdt"  class="valcol6" style="background-color: #D3D3D3;text-align:center;">    </td>
                                <td> </td><td id="tdt"  class="valcol7" style="background-color: #D3D3D3;text-align:center;">   </td>
                                <td> </td><td id="tdt"  class="valcol8" style="background-color: #D3D3D3;text-align:center;">   </td>
                            </tr>
                        </table>
                    </div>

                </div>
            </div>
        </div>
    </body>
</html>