/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

$('head').append('<script type=\"text/javascript\" src=\"js/Chart.js\"></script>');
$('head').append('<script type=\"text/javascript\" src=\"js/justgage.js\"></script>');
$('head').append('<script type=\"text/javascript\" src=\"js/raphael-2.1.4.min.js\"></script>');

var DashboardChart = function (id, options) {

    var o = {title: 'test', description: 'test', interval: 60000, timezone: 0, language: {}};

    options = $.extend(o, options);

    var _timer;

    var _this = {
        url: null, // to be defined in inherit class...
        type: null, // to be defined in inherit class...
        chart: null, // to be defined in inherit class...
        filter: '',
        filter2:'',
        getData: function () {

            $.ajax({
                type: 'POST',
                url: _this.url,
                data: {
                    action: 'get',
                    type: _this.type,
                    filter: _this.filter,
                    filter2: _this.filter2
                },
                beforeSend: function ()
                {
                    $('button[id$="-detail"]').prop("disabled", true);
                },
                success: function (data) {

                    if (data.expired !== undefined) {
                        $('#' + id + '-timestamp').html('session expired');

                        _timer = null;
                    } else {
                        _this.updateChart(_this.chart, data);

                        if (_this.chart !== null) {
                            if (_this.chart.update !== undefined) {
                                _this.chart.update();
                            }
                        }
                           
                        $('#' + id + '-timestamp').html(options.language.lastUpdated + ': ' + getCurrentTimestampByTimezone(options.timezone));
                    }
                },
                error: function () {

                },
                complete: function () {

                    $('button[id$="-detail"]').prop("disabled", false);

                    if (options.interval > 0) {
                        if (_timer !== null) {
                            _timer = setTimeout(_this.getData, options.interval);
                        }
                    } else {
                        clearTimeout(_timer);

                        _timer = null;
                    }
                },
                async: true
            });
        },
        getDetail: function () {

            $.ajax({
                type: 'POST',
                url: _this.url,
                data: {
                    action: 'chart',
                    type: _this.type + '_detail', // ends with the suffix...
                    filter: _this.filter,
                    filter2: _this.filter2
                },
                beforeSend: function () {
                    $('button[id$="-detail"]').prop("disabled", true);
                },
                success: function (data) {

                    if (data.expired !== undefined) {
                        $('#' + id + '-timestamp').html('session expired');
                    } else {
                        if (data.result === true) {
                            var content = _this.setDetail(data);

                            _this.showDetail(content);
                        }
                    }
                },
                complete: function () {

                    $('button[id$="-detail"]').prop("disabled", false);
                },
                async: true
            });
        },
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var canvas = $('<canvas/>', {id: id + '-result'});

            var legend = $('<div/>', {id: id + '-legend'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var detail = $('<button/>', {id: id + '-detail', class: 'button place-right', title: 'Show details'})

                    .html('<span class="mif-list"></span>')

                    .on('click', function (e) {

                        _this.getDetail();
                    });

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(detail);

            parent.append(title);

            parent.append(description);

            parent.append(canvas);

            parent.append(legend);

            parent.append(timestamp);

            // gets dom element of the canvas...
            canvas = $(canvas)[0];

            canvas.onclick = function (e) {

                _this.getDetail();
            };

            _this.createChart(canvas);

            $(legend).html(_this.chart.generateLegend());

            //_this.refresh();
        },
        createWithoutCanvas : function() {
             var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var filterDays = $('<h5/>', {id: id + '-description', class: 'text-light'});

            filterDays.html("<br>" + options.filterDays);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var canvas = $('<div/>', {id: id + '-result', style: 'height: 120px;'});

            var legend = $('<div/>', {id: id + '-legend'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var detail = $('<button/>', {id: id + '-detail', class: 'button place-right', title: 'Show details'})

                    .html('<span class="mif-list"></span>')

                    .on('click', function (e) {

                        _this.getDetail();
                    });

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            dialog.append(description);
            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(detail);

            parent.append(title);

            parent.append(filterDays);

            parent.append(canvas);

            parent.append(legend);

            parent.append(timestamp);

            _this.createChart(canvas);

        },
        createChart: function () {

            // to be defined in inherit class...
        },
        updateChart: function (chart, data) {

            // to be defined in inherit class...
        },
        setDetail: function (data) {

            // to be defined in inherit class...
        },
        setFilter: function (filter, filter2) {

            _this.filter = filter;
            _this.filter2 = filter2;
        },
        showDetail: function (html) {

            var dialog = $('#' + id + '-dialog');

            dialog.children('#' + id + '-dialog-content').html(html);

            dialog.data('dialog').open();
        },
        refresh: function () {

            if (_timer !== null) {
                clearTimeout(_timer);
            }

            // take 3 seconds to refresh... please ask kevin for the reason...
            _timer = setTimeout(_this.getData, 3000);
        },
        stopRefresh: function () {

            if (_timer !== null) {
                clearTimeout(_timer);
            }
        },
        dispose: function () {

            if (_timer !== null) {
                clearTimeout(_timer);

                _timer = null;
            }

            if (_this.chart !== null && _this.chart.destroy !== undefined) {
                _this.chart.destroy();
            }
        }
    };

    return _this;
};

//Status Dashboard
var GPSChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'gps',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var segments = [
                {
                    value: 0,
                    color: "#2193FF",
                    highlight: "#35A7FF",
                    label: "Valid"
                },
                {
                    value: 1,
                    color: "#8A8A8A",
                    highlight: "#9E9E9E",
                    label: "Invalid"
                }
            ];

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {
                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    datasets: [{
                            data: [0, 1],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            if (data.valid === 0 && data.invalid === 0) {
                data.invalid = 1;
            }

            chart.data.datasets[0].data[0] = data.valid;

            chart.data.datasets[0].data[1] = data.invalid;
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                if (data.records[i].status === 'valid') {
                    tr.append($('<td/>').css('background-color', '#2193FF').css('color', '#FFFFFF').html(data.records[i].status));
                } else {
                    tr.append($('<td/>').css('background-color', '#8A8A8A').css('color', '#FFFFFF').html(data.records[i].status));
                }

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var SpeedSummaryChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'speed',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["0-10", "10-20", "20-30", "30-40", "40-50", "50-60", "60-70", "70-80", "80-90", ">90"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    // forces step size to be 5 units
                                    stepSize: 5
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].speed));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var ConnectionStatusChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'connection',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var segments = [
                {
                    value: 0,
                    color: "#2193FF",
                    highlight: "#35A7FF",
                    label: "Updated"
                },
                {
                    value: 1,
                    color: "#8A8A8A",
                    highlight: "#9E9E9E",
                    label: "Outdated"
                }
            ];

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {
                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    datasets: [{
                            data: [0, 1],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            if (data.updated === 0 && data.outdated === 0) {
                data.outdated = 1;
            }

            chart.data.datasets[0].data[0] = data.updated;

            chart.data.datasets[0].data[1] = data.outdated;
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                if (data.records[i].status === 'updated') {
                    tr.append($('<td/>').css('background-color', '#2193FF').css('color', '#FFFFFF').html(data.records[i].status));
                } else {
                    tr.append($('<td/>').css('background-color', '#8A8A8A').css('color', '#FFFFFF').html(data.records[i].status));
                }

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var OutdatedConnectionSummaryChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'outdated_connection',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: [">1 Hour", ">12 Hours", ">1 Day", ">7 Days", ">30 Days", ">90 Days"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>';
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    // forces step size to be 5 units
                                    stepSize: 5
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].status));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var IgnitionStatusChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'ignition',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var segments = [
                {
                    value: 0,
                    color: "#2193FF",
                    highlight: "#35A7FF",
                    label: "Ignition on"
                },
                {
                    value: 1,
                    color: "#8A8A8A",
                    highlight: "#9E9E9E",
                    label: "Ignition off"
                }
            ];

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {
                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    datasets: [{
                            data: [0, 1],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            chart.data.datasets[0].data[0] = data.on;

            chart.data.datasets[0].data[1] = data.off + data.nil;

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                if (data.records[i].status === 'on') {
                    tr.append($('<td/>').css('background-color', '#2193FF').css('color', '#FFFFFF').html(data.records[i].status));
                } else {
                    tr.append($('<td/>').css('background-color', '#8A8A8A').css('color', '#FFFFFF').html(data.records[i].status));
                }

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var BinStatusChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'bin_status',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var segments = [
                {
                    value: 1,
                    color: "#70e15e",
                    highlight: "#70e15e",
                    label: "Bin Normal"
                },
                {
                    value: 0,
                    color: "#f6f912",
                    highlight: "#f00000",
                    label: "Bin Warning"
                },
                {
                    value: 0,
                    color: "#b42000",
                    highlight: "#f00000",
                    label: "Bin Full"
                }
            ];

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {
                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    datasets: [{
                            data: [segments[0].value],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color
                            ]
                        }],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label
                    ]
                },
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            chart.data.datasets[0].data[0] = data.normal;

            chart.data.datasets[0].data[1] = data.warning;

            chart.data.datasets[0].data[2] = data.full;

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                if (data.records[i].statusId === 114) {
                    tr.append($('<td/>').css('background-color', '#70e15e').css('color', '#FFFFFF').html(data.records[i].status));
                } else if (data.records[i].statusId === 115) {
                    tr.append($('<td/>').css('background-color', '#f6f912').css('color', '#FFFFFF').html(data.records[i].status));
                } else if (data.records[i].statusId === 116) {
                    tr.append($('<td/>').css('background-color', '#b42000').css('color', '#FFFFFF').html(data.records[i].status));
                } else {
                    tr.append($('<td/>').css('color', '#000000').html('-'));
                }

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FillCountMonthlyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fill_count_monthly',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(186, 146, 5,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    // forces step size to be 5 units
                                    stepSize: 10
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].value;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(Math.round(data.records[i].fill_count)));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var GeoFenceOccurenceChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'geofence',
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var table = $('<table/>', {id: id + '-summary-table', class: 'detail-table'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var detail = $('<button/>', {id: id + '-detail', class: 'button place-right', title: 'Show details'})

                    .html('<span class="mif-list"></span>')

                    .on('click', function (e) {

                        _this.getDetail();
                    });

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(detail);

            parent.append(title);

            parent.append(description);

            parent.append(table);

            parent.append(timestamp);

            //_this.refresh();
        },
        updateChart: function (chart, data) {

            var table = $('#' + id + '-summary-table');

            table.html("");

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            thead.append($('<th/>').html(data.columns[0]));

            thead.append($('<th/>').html(data.columns[1]));

            thead.append($('<th/>').html(data.columns[2]));

            thead.append($('<th/>').html(data.columns[3]));

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].geofence));

                tr.append($('<td/>').html(data.records[i].total));

                tr.append($('<td/>').html(data.records[i].on));

                tr.append($('<td/>').html(data.records[i].off));

                tbody.append(tr);
            }

            table.append(tbody);
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].geofence));

                tr.append($('<td/>').html(data.records[i].ignition));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var JobStatusChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'job_status',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var segments = [
                {
                    value: 1,
                    color: "#AE9A9A",
                    highlight: "#35A7FF",
                    label: options.language.unscheduled
                },
                {
                    value: 0,
                    color: "#6BAC61",
                    highlight: "#9E9E9E",
                    label: options.language.scheduled
                },
                {
                    value: 0,
                    color: "#15D0C1",
                    highlight: "#9E9E9E",
                    label: options.language.dispatched
                },
                {
                    value: 0,
                    color: "#FFBC00",
                    highlight: "#9E9E9E",
                    label: options.language.accepted
                },
                {
                    value: 0,
                    color: "#70E15E",
                    highlight: "#9E9E9E",
                    label: options.language.started
                },
                {
                    value: 0,
                    color: "#66A9FF",
                    highlight: "#9E9E9E",
                    label: options.language.ended
                },
                {
                    value: 0,
                    color: "#f472d0",
                    highlight: "#9E9E9E",
                    label: options.language.rejected
                },
                {
                    value: 0,
                    color: "#F00000",
                    highlight: "#9E9E9E",
                    label: options.language.cancelled
                },
                {
                    value: 0,
                    color: "#CBA2E4",
                    highlight: "#9E9E9E",
                    label: options.language.received
                },
                {
                    value: 0,
                    color: "#30ECEF",
                    highlight: "#9E9E9E",
                    label: options.language.uploading
                },
                {
                    value: 0,
                    color: "#FFFF69",
                    highlight: "#9E9E9E",
                    label: options.language.optimize
                }
            ];

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    datasets: [{
                            data: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color,
                                segments[5].color,
                                segments[6].color,
                                segments[7].color,
                                segments[8].color,
                                segments[9].color,
                                segments[10].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label,
                        segments[5].label,
                        segments[6].label,
                        segments[7].label,
                        segments[8].label,
                        segments[9].label,
                        segments[10].label
                    ]
                },
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    }
                }
            });

        },
        updateChart: function (chart, data) {
            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.summary.length; i++) {
                    chart.data.datasets[0].data[i] = data.summary[i].count;
                }
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].jobId));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html('<span class=\"job-status ' + data.records[i].status.toLowerCase() + '\">' + data.records[i].status + '</span>'));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};
//Utilization Dashboard
var BrakeUtilizationChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'brake_utilization',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var lineChartData = {
                labels: ["", "", "", "", "", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(186, 146, 5,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                    {
                        type: 'line',
                        data: lineChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }, }]
                            }
                        }
                    }
            );
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = result[i].value;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].utilization));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var BrakeUtilizationMonthlyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'brake_utilization_monthly',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(183, 5, 174,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0]
                    }
                ]
            };
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    // forces step size to be 5 units
                                    stepSize: 5
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = result[i].value;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].utilization));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var PTOUtilizationChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'pto_utilization',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var lineChartData = {
                labels: ["", "", "", "", "", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(186, 146, 5,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                    {
                        type: 'line',
                        data: lineChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = result[i].value;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].utilization));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var PTOUtilizationMonthlyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'pto_utilization_monthly',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(5, 41, 183,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0]
                    }
                ]
            };
            _this.chart = new Chart(ctx,
                    {
                        type: 'bar',
                        data: barChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );

        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = result[i].value;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].utilization));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FuelEfficiencyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fuel_efficiency',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var lineChartData = {
                labels: ["", "", "", "", "", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(186, 146, 5,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                    {
                        type: 'line',
                        data: lineChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );

        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = Math.round(result[i].value * 10) / 10;  // rounding up to 1 decimal place...
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].mileage));

                tr.append($('<td/>').html(data.records[i].fuel));

                tr.append($('<td/>').html(Math.round(data.records[i].fuelEfficiency * 10) / 10));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FuelEfficiencyMonthlyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fuel_efficiency_monthly',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(186, 146, 5,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                    {
                        type: 'bar',
                        data: barChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = Math.round(result[i].value * 10) / 10;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].mileage));

                tr.append($('<td/>').html(data.records[i].fuel));

                tr.append($('<td/>').html(Math.round(data.records[i].fuelEfficiency * 10) / 10));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FillLevelDailyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fill_level',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var lineChartData = {
                labels: ["", "", "", "", "", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(186, 146, 5,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                {
                    type: 'line',
                    data: lineChartData,
                    responsive: true,
                    options: {
                        responsive: true,
                        legendCallback: function (chart) {
                            return '<span></span>';
                        },
                        legend: {
                            display: false
                        },
                        scales: {
                            yAxes: [{ticks: {
                                        min: 0,
                                        // forces step size to be 5 units
                                        stepSize: 5
                                    }}]
                        }
                    }
                }
            );
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = Math.round(result[i].value * 10) / 10;  // rounding up to 1 decimal place...
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(Math.round(data.records[i].fill_level)));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FillLevelMonthlyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fill_level_monthly',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(183, 5, 174,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                    {
                        type: 'bar',
                        data: barChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );

        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = result[i].value;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].fill_level));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};
//Driver Safety Dashboard
var DriverSafetyChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'driver_safety',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var segments = [
                {
                    color: "#97d623",
                    highlight: "#9E9E9E",
                    label: "No Risk"
                },
                {
                    color: "#FFBC00",
                    highlight: "#FFBC00",
                    label: "Low Risk"
                },
                {
                    color: "#d62728",
                    highlight: "#d62728",
                    label: "High Risk"
                }
            ];

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {
                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {

                type: 'pie',
                data: {
                    datasets: [{
                            data: [1, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label
                    ]
                },
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0; i < result.length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                var riskHtml = '';

                for (var j = 0; j < data.records[i].risks.length; j++) {
                    riskHtml += '<span class="driver-behaviour-tag">' + _this.chart.data.labels[j] + ': ' + data.records[i].risks[j] + '%</span>';
                }

                tr.append($('<td/>').html(riskHtml));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var ManoeuvreSummaryChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'manoeuvre_summary',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["Braking", "Turning", "Turning Acc", "Turning Dec", "Wide Turning", "Wide Turning Acc", "Wide Turning Dec", "Acceleration", "Lane Change", "Over Taking", "Speed Bump"],
                datasets: [
                    {
                        backgroundColor: "rgba(151, 214, 35,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    },
                    {
                        backgroundColor: "rgba(255, 188, 0,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    },
                    {
                        backgroundColor: "rgba(214, 39, 40,0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            // make legend...
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            legendContainer.append($('<li/>').html('<span style="background-color:#97d623"></span>Normal'));

            legendContainer.append($('<li/>').html('<span style="background-color:#FFBC00"></span>Aggressive'));

            legendContainer.append($('<li/>').html('<span style="background-color:#d62728"></span>Dangerous'));

            _this.chart = new Chart(ctx,
                    {
                        type: 'bar',
                        data: barChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.normal.length; i < length; i++) {

                chart.data.datasets[0].data[i] = result.normal[i];
            }

            for (var i = 0, length = result.aggressive.length; i < length; i++) {

                chart.data.datasets[1].data[i] = result.aggressive[i];
            }

            for (var i = 0, length = result.dangerous.length; i < length; i++) {

                chart.data.datasets[2].data[i] = result.dangerous[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                var behaviourHtml = '';

                for (var j = 0; j < data.records[i].behaviours.length; j++) {
                    if (data.records[i].behaviours[j] <= 50) {
                        behaviourHtml += '<span class="driver-behaviour-tag good">' + _this.chart.data.labels[j] + ': ' + data.records[i].behaviours[j] + '%</span>';
                    } else if (data.records[i].behaviours[j] > 50 && data.records[i].behaviours[j] <= 75) {
                        behaviourHtml += '<span class="driver-behaviour-tag warning">' + _this.chart.data.labels[j] + ': ' + data.records[i].behaviours[j] + '%</span>';
                    } else if (data.records[i].behaviours[j] > 75) {
                        behaviourHtml += '<span class="driver-behaviour-tag critical">' + _this.chart.data.labels[j] + ': ' + data.records[i].behaviours[j] + '%</span>';
                    }
                }

                tr.append($('<td/>').html(behaviourHtml));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};
//Health Dashboard
var EngineTemperatureChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'engine_temperature',
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var canvas = $('<div/>', {id: id + '-result', style: 'height: 240px'});

            var legend = $('<div/>', {id: id + '-legend'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var detail = $('<button/>', {id: id + '-detail', class: 'button place-right', title: 'Show details'})

                    .html('<span class="mif-list"></span>')

                    .on('click', function (e) {

                        _this.getDetail();
                    });

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(detail);

            parent.append(title);

            parent.append(description);

            parent.append(canvas);

            parent.append(legend);

            parent.append(timestamp);

            _this.chart = new JustGage({
                id: id + '-result',
                value: 0,
                min: 0,
                max: 100,
                relativeGaugeSize: true
            });

            //_this.refresh();
        },
        updateChart: function (chart, data) {

            var result = data.data;

            chart.refresh(result);

            if (options.update !== undefined) {
                options.update(result);
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                if (data.records[i].overheatCount > data.overheatThreshold) {
                    tr = $('<tr/>').css('background-color', '#d62728').css('color', '#FFFFFF');
                } else {
                    tr = $('<tr/>');
                }

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].hourOfDay));

                tr.append($('<td/>').html(data.records[i].occurenceCount));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var EngineWearAndTearChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'engine_wear_and_tear',
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var canvas = $('<div/>', {id: id + '-result', style: 'height: 240px'});

            var legend = $('<div/>', {id: id + '-legend'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var detail = $('<button/>', {id: id + '-detail', class: 'button place-right', title: 'Show details'})

                    .html('<span class="mif-list"></span>')

                    .on('click', function (e) {

                        _this.getDetail();
                    });

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(detail);

            parent.append(title);

            parent.append(description);

            parent.append(canvas);

            parent.append(legend);

            parent.append(timestamp);

            _this.chart = new JustGage({
                id: id + '-result',
                value: 0,
                min: 0,
                max: 100,
                relativeGaugeSize: true
            });

            //_this.refresh();
        },
        updateChart: function (chart, data) {

            var result = data.data;

            chart.refresh(result);

            if (options.update !== undefined) {
                options.update(result);
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                if (data.records[i].stompCount > data.stompThreshold) {
                    tr = $('<tr/>').css('background-color', '#d62728').css('color', '#FFFFFF');
                } else {
                    tr = $('<tr/>');
                }

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].hourOfDay));

                tr.append($('<td/>').html(data.records[i].occurenceCount));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var OverallHealthChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'overall_health',
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var canvas = $('<div/>', {id: id + '-result', style: 'height: 240px'});

            var legend = $('<div/>', {id: id + '-legend'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(title);

            parent.append(description);

            parent.append(canvas);

            parent.append(legend);

            parent.append(timestamp);

            _this.chart = new JustGage({
                id: id + '-result',
                value: 0,
                min: 0,
                max: 100,
                relativeGaugeSize: true
            });

            // the chart update is handled explicitly...
            //_this.refresh();
        },
        updateChart: function (chart, data) {

            var result = data.data;

            if (isNaN(result)) {
                result = 0;
            }

            chart.refresh(result);

            $('#' + id + '-timestamp').html(options.language.lastUpdated + ': ' + getCurrentTimestampByTimezone(options.timezone));
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var BatteryHealthChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'battery_health',
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var canvas = $('<div/>', {id: id + '-result', style: 'height: 240px'});

            var legend = $('<div/>', {id: id + '-legend'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(title);

            parent.append(description);

            parent.append(canvas);

            parent.append(legend);

            parent.append(timestamp);

            _this.chart = new JustGage({
                id: id + '-result',
                value: 0,
                min: 0,
                max: 100,
                relativeGaugeSize: true
            });

            // the chart update is handled explicitly...
            //_this.refresh();
        },
        updateChart: function (chart, data) {

            var result = data.data;

            if (isNaN(result)) {
                result = 0;
            }

            chart.refresh(result);

            $('#' + id + '-timestamp').html(options.language.lastUpdated + ': ' + getCurrentTimestampByTimezone(options.timezone));
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var PTOSafetyViolationChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'pto_safety_violation',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["", "", "", "", "", "", "", "", "", ""],
                datasets: [
                    {
                        backgroundColor: "rgba(216, 49, 49, 0.5)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx,
                    {
                        type: 'bar',
                        data: barChartData,
                        responsive: true,
                        options: {
                            responsive: true,
                            legendCallback: function (chart) {
                                return '<span></span>';
                            },
                            legend: {
                                display: false
                            },
                            scales: {
                                yAxes: [{ticks: {
                                            min: 0,
                                            // forces step size to be 5 units
                                            stepSize: 5
                                        }}]
                            }
                        }
                    }
            );
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {

                chart.data.labels[i] = result[i].label;

                chart.data.datasets[0].data[i] = result[i].value;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].hourOfDay));

                tr.append($('<td/>').html(data.records[i].violationCount));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var JobProgressChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'job_progress_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabely = [options.language.formTemplate];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: options.language.started,
                        backgroundColor: "#70E15E",
                        data: [0]
                    },
                    {
                        label: options.language.ended,
                        backgroundColor: "#66A9FF",
                        data: [0]
                    },
                    {
                        label: options.language.pending,
                        backgroundColor: "#ff9999",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'horizontalBar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
                                stacked: true
                            }],
                        yAxes: [{
                                stacked: true
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0; i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 20);
                chart.data.datasets[0].data[i] = result[i].started;
                chart.data.datasets[1].data[i] = result[i].ended;
                chart.data.datasets[2].data[i] = result[i].pending;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].TemplateName));

                tr.append($('<td/>').html(data.records[i].Pending));

                tr.append($('<td/>').html(data.records[i].Ended));

                tr.append($('<td/>').html(data.records[i].Started));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var JobScheduleChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'job_schedule_deviation_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabel = [options.language.formTemplate];
            var BarChartData = {
                labels: datalabel,
                datasets: [
                    {
                        label: options.language.onTime,
                        backgroundColor: "#00b386",
                        data: [0]
                    },
                    {
                        label: ">5 " + options.language.mins,
                        backgroundColor: "#ffd633",
                        data: [0]
                    },
                    {
                        label: ">15 " + options.language.mins,
                        backgroundColor: "#ff9999",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    maxRotation: 90
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].onTime;
                chart.data.datasets[1].data[i] = result[i].late;
                chart.data.datasets[2].data[i] = result[i].veryLate;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].TemplateName));

                tr.append($('<td/>').html(data.records[i].onTime));

                tr.append($('<td/>').html(data.records[i].late));

                tr.append($('<td/>').html(data.records[i].veryLate));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var JobDurationChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'job_duration_deviation_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabel = [options.language.formTemplate];
            var BarChartData = {
                labels: datalabel,
                datasets: [
                    {
                        label: options.language.onTime,
                        backgroundColor: "#00b386",
                        data: [0]
                    },
                    {
                        label: "<30 " + options.language.mins,
                        backgroundColor: "#ffd633",
                        data: [0]
                    },
                    {
                        label: ">30 "+ options.language.mins,
                        backgroundColor: "#ff9999",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0
                                }, }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            var result = data.data;

            for (var i = 0; i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].onTime;
                chart.data.datasets[1].data[i] = result[i].late;
                chart.data.datasets[2].data[i] = result[i].veryLate;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].TemplateName));

                tr.append($('<td/>').html(data.records[i].onTime));

                tr.append($('<td/>').html(data.records[i].late));

                tr.append($('<td/>').html(data.records[i].veryLate));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var ProductivityTrendChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'productivity_trend_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabel = ["Month 1", "Month 2", "Month 3", "Month 4", "Month 5", "Month 6"];
            var MixChartData = {
                labels: datalabel,

                datasets: [
                    {
                        label: options.language.productivity,
                        type: 'line',
                        borderColor: "#e63900",
                        backgroundColor: "#e63900",
                        fill: false,
                        data: [0],
                        yAxisID: 'y-axis-2'
                    },
                    {
                        label: options.language.jobs,
                        type: 'bar',
                        backgroundColor: "#ffd633",
                        data: [0],
                        yAxisID: 'y-axis-1'
                    },
                    {
                        label: options.language.staffs,
                        type: 'bar',
                        backgroundColor: "#b4ebfd",
                        data: [0],
                        yAxisID: 'y-axis-1'
                    }
                ]
            };
            var legendContainer = $('<ul/>', {class: 'chart-legend'});


            for (var i = 0; i < MixChartData.datasets.length; i++) {
                var legendItem = $('<li/>');
                legendItem.html('<span style="background-color:' + MixChartData.datasets[i].backgroundColor + '"></span>' + MixChartData.datasets[i].label + '');
                legendContainer.append(legendItem);
            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: MixChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: true
                    },
                    scales: {
                        yAxes: [{
                                type: 'linear', // only linear but allow scale type registration. This allows extensions to exist solely for log scale for instance
                                display: true,
                                position: 'left',
                                id: 'y-axis-1',
                            }, {
                                type: 'linear', // only linear but allow scale type registration. This allows extensions to exist solely for log scale for instance
                                display: true,
                                position: 'right',
                                id: 'y-axis-2',
                                // grid line settings
                                gridLines: {
                                    drawOnChartArea: false, // only want the grid lines for one axis to show up
                                },
                            }],
                    },
                    responsive: true
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;

            for (var i = 0, length = result.length; i < length; i++) {
                chart.config.data.labels[i] = result[i].timestamp;
                chart.data.datasets[0].data[i] = result[i].productivity;
                chart.data.datasets[1].data[i] = result[i].jobs;
                chart.data.datasets[2].data[i] = result[i].staffs;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].Timestamp));

                tr.append($('<td/>').html(data.records[i].Jobs));

                tr.append($('<td/>').html(data.records[i].Staffs));

                tr.append($('<td/>').html(data.records[i].Productivity));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var FuelLevelChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fuel_level_chart',
        createChart: function (canvas) {
            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas2'});

            innerCanvas.append("<h4 class=\"text-light\"> Spike </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            var innerCanvas2 = $('<div/>', {style:'', class:'chartInnerCanvas2'});

            innerCanvas2.append("<h4 class=\"text-light\"> Drop </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            canvas.append(innerCanvas);
            canvas.append(innerCanvas2);

            //_this.refresh();
        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            var data2 = data.data[0].data2;

            $('#'+id + '-data1').text(data1);
            $('#'+id + '-data2').text(data2);
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].spike));

                tr.append($('<td/>').html(data.records[i].drop));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FuelConsumptionChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'fuel_consumption_chart',
        createChart: function (canvas) {

            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas3'});

            innerCanvas.append("<h4 class=\"text-light\" > Good </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            var innerCanvas2 = $('<div/>', {style:'', class:'chartInnerCanvas3'});

            innerCanvas2.append("<h4 class=\"text-light\"> Average </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data2\"> 0 </h1>");

            var innerCanvas3 = $('<div/>', {style:'', class:'chartInnerCanvas3'});

            innerCanvas3.append("<h4 class=\"text-light\"> Bad </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data3\"> 0 </h1>");

            canvas.append(innerCanvas);
            canvas.append(innerCanvas2);
            canvas.append(innerCanvas3);




            //_this.refresh();
        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            var data2 = data.data[0].data2;

            var data3 = data.data[0].data3;

            $('#'+id + '-data1').text(data1);
            $('#'+id + '-data2').text(data2);
            $('#'+id + '-data3').text(data3);
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].fuelConsumption));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var IdlingTimeLimitChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'idling_time_limit_chart',
        createChart: function (canvas) {

            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas2'});

            innerCanvas.append("<h4 class=\"text-light\"> > 15mins </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            var innerCanvas2 = $('<div/>', {style:'', class:'chartInnerCanvas2'});

            innerCanvas2.append("<h4 class=\"text-light\"> > 30mins </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            canvas.append(innerCanvas);
            canvas.append(innerCanvas2);



            //_this.refresh();
        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            var data2 = data.data[0].data2;

            $('#'+id + '-data1').text(data1);
            $('#'+id + '-data2').text(data2);
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].occurrences15));

                tr.append($('<td/>').html(data.records[i].occurrences30));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var EngineCheckChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'engine_check_chart',
        createChart: function (canvas) {


            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas2'});

            innerCanvas.append(" <h4> Warning </h4> \n\
                               <h1 id=\"" + id + "-data1\"> 0 </h1>");

            var innerCanvas2 = $('<div/>', {style:'', class:'chartInnerCanvas2'});

            innerCanvas2.append("<h4> Critical </h4> \n\
                               <h1 id=\"" + id + "-data2\"> 0 </h1>");


            canvas.append(innerCanvas);
            canvas.append(innerCanvas2);

        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            var data2 = data.data[0].data2;

            $('#'+id + '-data1').text(data1);
            $('#'+id + '-data2').text(data2);
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].occurrencesWarn));

                tr.append($('<td/>').html(data.records[i].occurrencesCrit));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var EngineTempChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'engine_temp_chart',
        createChart: function (canvas) {


            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas1'});

            innerCanvas.append("<h4 class=\"text-light\"> > 100°C </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");


            canvas.append(innerCanvas);

        },
        updateChart: function (chart, data) { // when refresh
            var data1 = data.data[0].data1;

            $('#'+id + '-data1').text(data1);

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].occurrences));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var EngineLoadChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'engine_load_chart',
        createChart: function (canvas) {

            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas1'});

            innerCanvas.append("<h4 class=\"text-light\"> No.of Pothole Hit </h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            canvas.append(innerCanvas);


            //_this.refresh();
        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            $('#'+id + '-data1').text(data1);

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].occurrences));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var ExhaustBrakeChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'exhaust_brake_chart',
        createChart: function (canvas) {

            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas1'});

            innerCanvas.append("<h4 class=\"text-light\"> Brake Activated</h4> \n\
                               <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");


            canvas.append(innerCanvas);


        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            $('#'+id + '-data1').text(data1);

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].occurrences));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var MileageServiceChart = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'mileage_service_chart',
        createChart: function (canvas) {

            var innerCanvas = $('<div/>', {style:'', class:'chartInnerCanvas1'});

            innerCanvas.append("<h4 class=\"text-light\"> No. of Vehicles </h4> \n\
                                <h1 class=\"text-light\" id=\"" + id + "-data1\"> 0 </h1>");

            canvas.append(innerCanvas);
        },
        updateChart: function (chart, data) { // when refresh

            var data1 = data.data[0].data1;

            $('#'+id + '-data1').text(data1);
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].servicing));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var ClusterGroupProgress = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'ChartController',
        type: 'cluster_location_group_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Completed (%)",
                    highlight: "#9E9E9E",
                    color: "#3366CC"
                },
                {
                    value : 0,
                    label: "Pending (%)",
                    highlight: "#35A7FF",
                    color: "#dc1111"
                }
            ];

            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].ended;
                    chart.data.datasets[0].data[1] = data.data[i].pending;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var ClusterGroupIndividualProgress = function (id, options) { // use FOR Vertical BAR GRAPH

    var _this = {
        url: 'ChartController',
        type: 'cluster_location_group_individual_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabely = ["Group"];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: "Completed (%)",
                        backgroundColor: "#3366CC",
                        data: [0]
                    },
                    {
                        label: "Pending (%)",
                        backgroundColor: "#dc1111",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
                                stacked: true
                            }],
                        yAxes: [{
                                stacked: true,
                                ticks : {
                                    min:0,
                                    max :100
                                }
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) {
                if (result[i].label.length >= 10) {
                    for (var j = 0; j < 10; j++) {
                        temp += result[i].label[j];
                    }
                    result[i].label = temp + "...";
                    temp = "";
                }
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].ended;
                chart.data.datasets[1].data[i] = result[i].pending;

            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};




var ClusterLocationTrackingChart = function (id, options) { // this is the hor bar at the btm
    var _this = {
        url: 'ChartController',
        type: 'cluster_location_chart',
         createChart: function (canvas) {
            $(canvas).css('height', '2000px');
            var ctx = canvas.getContext("2d");
            var datalabely = ["Group - Cluster"];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: "Completed",
                        backgroundColor: "#3366CC",
                        data: [0]
                    },
                    {
                        label: "Pending",
                        backgroundColor: "#dc1111",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'horizontalBar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            title: function(t, d) {
                               return d.labels[t[0].index]; // not sure what this does but copied to make the mouseover hover and y - axis label different https://stackoverflow.com/questions/44355320/chartjs-set-different-hover-text-than-x-axis-description
                            }
                        }
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
                                stacked: true,
                                ticks : {
                                    min:0.0,
                                    max :45
                                }
                            }],
                        yAxes: [{
                                stacked: true,
                                ticks: {
                                    callback:function(t)
                                    {
                                        if(t.length > 1)
                                        {
                                            return t[0];
                                        }
                                        return t;
                                    }
                                }
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) { // when refresh

            var result = data.records;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) {
                if (result[i].cluster.length >= 10) {
                    for (var j = 0; j < 15; j++) {
                        temp += result[i].cluster[j];
                    }
                    result[i].label = temp + "...";
                    temp = "";
                }
                var labels = result[i].group + " - " + result[i].cluster;

                if(result[i].blockDate != "")
                {
                    labels += "\n";
                    if(result[i].blockDate.indexOf(',') > -1) // check if it is more than one line of reason
                    {
                        var blockDate = result[i].blockDate.split(',');
                        for(var x = 0; x < blockDate.length; x++)
                        {
                            if(x > 0)
                            {
                                labels += "\n";
                            }
                            labels += blockDate[x];
                        }
                    }
                    else
                    {
                        labels += result[i].blockDate;
                    }
                }

                chart.config.data.labels[i] = labels.split(/\n/) ;
                chart.data.datasets[0].data[i] = result[i].completed;
                chart.data.datasets[1].data[i] = result[i].totalblock - result[i].completed;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {

                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].group));

                tr.append($('<td/>').html(data.records[i].assetLabel));

                tr.append($('<td/>').html(data.records[i].cluster));

                tr.append($('<td/>').html(data.records[i].location));

                tr.append($('<td/>').html(data.records[i].completion));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var EngineAnalytics = function (id, options) { // This is just some demo for CnC

    var _this = {
        url: 'ChartController',
        type: 'engine_analytics',
        create: function () {

            var parent = $('#' + id);

            var title = $('<h3/>', {id: id + '-title', class: 'text-light'});

            title.html(options.title);

            var description = $('<h5/>', {id: id + '-description', class: 'text-light'});

            description.html(options.description);

            var table = $('<table/>', {id: id + '-summary-table', class: 'detail-table'});

            var timestamp = $('<h6/>', {id: id + '-timestamp', class: 'text-light'});

            var detail = $('<button/>', {id: id + '-detail', class: 'button place-right', title: 'Show details'})

                    .html('<span class="mif-list"></span>')

                    .on('click', function (e) {

                        $('tr.hiddenRow').each(function() {

                            _this.getDetailsWithID($(this).prev().attr("id"));
                        });

                    });

            var dialog = $('<div/>', {id: id + '-dialog',
                attr: {
                    'data-role': 'dialog',
                    'data-close-button': true,
                    'data-background': 'bg-white',
                    'data-overlay': false
                }});

            // this can be improve by using one single pop up dialog for all charts...
            dialog.append($('<div/>', {id: id + '-dialog-content', class: 'dashboard-detail-dialog'}));

            parent.append(dialog);

            parent.append(detail);

            parent.append(title);

            parent.append(description);

            parent.append(table);

            parent.append(timestamp);


            //_this.refresh();
        },
        updateChart: function (chart, data) { //update the chart

            var table = $('#' + id + '-summary-table');

            table.html("");

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            thead.append($('<th/>').html(data.columns[0]));

            thead.append($('<th/>').html(data.columns[1]));

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length-1; i++)
            {
                tr = $('<tr/>').attr("id", data.records[i].assetId).on('click', function (e) {
                    _this.getDetailsWithID($(this).attr("id"));
                });

                tr.append($('<td/>').append(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].status));

                var tr2 = $('<tr/>').attr("id", data.records[i].assetId + "-second").append('<td colspan="2"/>').attr('class','hiddenRow');

                tbody.append(tr);
                tbody.append(tr2);
            }

            table.append(tbody);
        },
        getDetailsWithID: function(identify) {
            $.ajax({
                type: 'POST',
                url: _this.url,
                data: {
                    action: 'chart',
                    type: _this.type + '_detail', // ends with the suffix...
                    filter: identify,
                },
                success: function (data) {

                    if (data.expired !== undefined) {
                        $('#' + id + '-timestamp').html('session expired');
                    } else {
                        if (data.result === true) {
                            var content = _this.setDetail(data, identify);

                            //_this.showDetail(content);
                        }
                    }
                },
                async: true
            });

        },
        removeDetails: function(assetId){
            var c = confirm("Confirm Acknowledge Fault(s)?");

            if (c)
            {
                $('tr[id=' + assetId +']').remove();
                $('tr[id=' + assetId +'-second]').remove();
            }
        },
        setDetail: function (data, assetId) { // this is the behind details when click on the 3 strips and also when you click on the row

            var parent = $('#' + id);

            var firstTr = $('tr[id=' + assetId +']').find('span').last();
            var secondTr = $('tr[id=' + assetId +'-second]');

            var date1 = new Date();
            var date2 = new Date();

            date1.setHours(Math.floor((Math.random() *24) + 1 ) * -1);
            date2.setHours(Math.floor((Math.random() *24) + 1 ) * -1);

            secondTr.toggleClass('hiddenRow');

            var secondTrTd = secondTr.children().first();
            var status;

            if ($(firstTr).hasClass('optimize')) {status = 1} else {status=2} // critcial = 2, warning = 1
            $(secondTrTd).empty();

            if (status == 1) // next time must pull from a table
            {
                secondTrTd.append('<ul style="float:left; width:90%" >' +
                               '<li> DTC : P2503 "Charing System Voltage Low" @ ' + getDate(date1) + '</li></ul>');
            }
            else
            {
                secondTrTd.append('<ul style="float:left; width:90%">' +
                                '<li> DTC : B1363 "Ignition Start Circuit Failure" @ ' + getDate(date1) +'</li>'+
                                '<li> Vehicle Overdue for Servicing  </li></ul>');
            }
            secondTrTd.append($('<button />').addClass('button place-right').attr('id',assetId).append('<span class="mif-bin"></span>').on('click', function(){
                 _this.removeDetails($(this).attr("id"));
            }));

            //* below is utilites
            function getDate(date) {
                return two(date.getDate()) + "/"
                                + two(date.getMonth() + 1) + "/"
                                + two(date.getFullYear()) + " "
                                + two(date.getHours()) + ":"
                                + two(date.getMinutes()) + ":"
                                + two(date.getSeconds());;
            }
            function two(num) {
                var num = ("0" + num).slice(-2);
                return num;
            }
            // where i found fault code https://www.yourmechanic.com/advice/results/?query=trouble%20code
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var EstablishmentInspectionChart = function (id, options) {

    var _this = {
        url: 'SFADashboardController',
        type: 'establishment_inspection',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["SFA 1", "SFA 2", "SFA 3", "SFA 4"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.7)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }
            
            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;

            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};
                        
var EstablishmentComplianceChart = function (id, options) { // use FOR Vertical BAR GRAPH

    var _this = {
        url: 'SFADashboardController',
        type: 'establishment_compliance',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabely = ["SFA 1", "SFA 2", "SFA 3", "SFA 4"];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: "Compliant",
                        backgroundColor: "rgba(103,177,17, 0.7)",
                        data: [0]
                    },
                    {
                        label: "Non-Compliant",
                        backgroundColor: "rgba(177, 17, 23, 0.7)",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
//                                stacked: true
                            }],
                        yAxes: [{
//                                stacked: true,
                                ticks : {
                                    min:0
                                }
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) {
                if (result[i].label.length >= 10) {
                    for (var j = 0; j < 10; j++) {
                        temp += result[i].label[j];
                    }
                    result[i].label = temp + "...";
                    temp = "";
                }
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].compliant;
                chart.data.datasets[1].data[i] = result[i].noncompliant;

            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var EstablishmentComplianceIssueChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFADashboardController',
        type: 'establishment_compliance_issue',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Takeaway",
                    highlight: "#9E9E9E",
                    color: "rgba(17, 177, 171,0.7)"
                },
                {
                    value : 0,
                    label: "Marking",
                    highlight: "#35A7FF",
                    color: "rgba(177, 171, 17, 0.7)"
                },
                {
                    value : 0,
                    label: "Safe Distance",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 103, 0.7)"
                },
                {
                    value : 0,
                    label: "Mask Wear",
                    highlight: "#0000AA",
                    color: "rgba(17, 71, 177, 0.7)"
                },
                {
                    value : 0,
                    label: "SafeEntry",
                    highlight: "#AA0000",
                    color: "rgba(20, 115, 28, 0.7)"
                },
                {
                    value : 0,
                    label: "Group > 2 (P3HA)",
                    highlight: "#AA0000",
                    color: "rgba(217, 73, 20, 0.7)"
                }
                
                
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color,
                                segments[5].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label,
                        segments[5].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].takeaway;
                    chart.data.datasets[0].data[1] = data.data[i].marking;
                    chart.data.datasets[0].data[2] = data.data[i].distance;
                    chart.data.datasets[0].data[3] = data.data[i].mask;
                    chart.data.datasets[0].data[4] = data.data[i].safeentry;
                    chart.data.datasets[0].data[5] = data.data[i].groupsoffive;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var DiningInspectionChart = function (id, options) {

    var _this = {
        url: 'SFADashboardController',
        type: 'dining_inspection',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["SFA 1", "SFA 2", "SFA 3", "SFA 4"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.7)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }
            
            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;

            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};
                        
var DiningComplianceChart = function (id, options) { // use FOR Vertical BAR GRAPH

    var _this = {
        url: 'SFADashboardController',
        type: 'dining_compliance',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var datalabely = ["SFA 1", "SFA 2", "SFA 3", "SFA 4"];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: "Compliant",
                        backgroundColor: "rgba(103,177,17, 0.7)",
                        data: [0]
                    },
                    {
                        label: "Non-Compliant",
                        backgroundColor: "rgba(177, 17, 23, 0.7)",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
//                                stacked: true
                            }],
                        yAxes: [{
//                                stacked: true,
                                ticks : {
                                    min:0
                                }
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) {
                if (result[i].label.length >= 10) {
                    for (var j = 0; j < 10; j++) {
                        temp += result[i].label[j];
                    }
                    result[i].label = temp + "...";
                    temp = "";
                }
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].compliant;
                chart.data.datasets[1].data[i] = result[i].noncompliant;

            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DiningCrowdChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFADashboardController',
        type: 'dining_crowd',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "< 20 ",
                    highlight: "#9E9E9E",
                    color: "rgba(17, 177, 171,0.7)"
                },
                {
                    value : 0,
                    label: "20 - 50 ",
                    highlight: "#35A7FF",
                    color: "rgba(177, 171, 17, 0.7)"
                },
                {
                    value : 0,
                    label: "50 - 100 ",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 103, 0.7)"
                },
                {
                    value : 0,
                    label: "> 100 ",
                    highlight: "#0000AA",
                    color: "rgba(17, 71, 177, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                            segments[3].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].less_than_20;
                    chart.data.datasets[0].data[1] = data.data[i].between_20_50;
                    chart.data.datasets[0].data[2] = data.data[i].between_50_100;
                    chart.data.datasets[0].data[3] = data.data[i].more_than_100;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var EstablishmentReactionChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFADashboardController',
        type: 'establishment_reaction',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Supportive",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "Neutral",
                    highlight: "#35A7FF",
                    color: "rgba(177, 171, 17, 0.7)"
                },
                {
                    value : 0,
                    label: "Defensive",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                },
                {
                    value : 0,
                    label: "Hostile",
                    highlight: "#0000AA",
                    color: "rgba(0, 0, 0, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                            segments[3].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].supportive;
                    chart.data.datasets[0].data[1] = data.data[i].neutral;
                    chart.data.datasets[0].data[2] = data.data[i].defensive;
                    chart.data.datasets[0].data[3] = data.data[i].hostile;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var DiningReactionChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFADashboardController',
        type: 'dining_reaction',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Supportive",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "Neutral",
                    highlight: "#35A7FF",
                    color: "rgba(177, 171, 17, 0.7)"
                },
                {
                    value : 0,
                    label: "Defensive",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                },
                {
                    value : 0,
                    label: "Hostile",
                    highlight: "#0000AA",
                    color: "rgba(0, 0, 0, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                            segments[3].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].supportive;
                    chart.data.datasets[0].data[1] = data.data[i].neutral;
                    chart.data.datasets[0].data[2] = data.data[i].defensive;
                    chart.data.datasets[0].data[3] = data.data[i].hostile;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var AdvisoryChart = function (id, options) {

    var _this = {
        url: 'SFADashboardController',
        type: 'inspection_advisory',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["SFA 1", "SFA 2", "SFA 3", "SFA 4"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.7)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;

            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FineChart = function (id, options) {

    var _this = {
        url: 'SFADashboardController',
        type: 'inspection_fine',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["SFA 1", "SFA 2", "SFA 3", "SFA 4"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.7)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    precision: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;

            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var RatingFeedbackChart = function (id, options) {

    var _this = {
        url: 'TFSChartController',
        type: 'rating_feedback_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
//            var datalabel = [options.language.rating];
            var BarChartData = {
//                labels: datalabel,
                datasets: [
                    {
                        label: "Rating",
                        backgroundColor: "#59cde2",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            overallDetail();
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].rating));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var ReasonFeedbackChart = function (id, options) {

    var _this = {
        url: 'TFSChartController',
        type: 'reason_feedback_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
//            var datalabel = [options.language.reason];
            var BarChartData = {
//                labels: datalabel,
                datasets: [
                    {
                        label: "Reason",
                        backgroundColor: "#00b386",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].reason));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var BadRatingBuildupChart = function (id, options) {

    var _this = {
        url: 'TFSChartController',
        type: 'bad_rating_buildup_chart',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
//            var datalabel = [options.language.rating];
            var BarChartData = {
//                labels: [options.language.badRating, options.language.safeZone],
                datasets: [
                    {
                        label: options.language.badRating,
                        backgroundColor: "#ce352c",
                        data: [0]
                    },
                    {
                        label: options.language.safeZone,
                        backgroundColor: "#eeeeee",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{
                                stacked: true,
                                ticks: {
                                    min: 0,
                                    max: 100,
                                    callback: function(value) {
                                        return value + "%"
                                    },
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{
                                stacked: true,
                                ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            var result = data.data;
            debugger;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].badRating;
                chart.data.datasets[1].data[i] = result[i].safeZone;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].badRating));
                
                tr.append($('<td/>').html(data.records[i].safeZone));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DailyIncidentCount = function (id, options) { 
    var _this = {
        url: 'OFDailyChartController',
        type: 'daily_incident_pie',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Call-In",
                    highlight: "#79e60c",
                    color: "#79e60c"
                },
                {
                    value : 0,
                    label: "On Patrol",
                    highlight: "#2fbdea",
                    color: "#2fbdea"
                },
                {
                    value : 0,
                    label: "One Motoring",
                    highlight: "#d04141",
                    color: "#d04141"
                },
                {
                    value : 0,
                    label: "Report Appointment",
                    highlight: "#f38813",
                    color: "#f38813"
                },
                {
                    value : 0,
                    label: "Second Rider",
                    highlight: "#e6e60c",
                    color: "#e6e60c"
                }               
                
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

//                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {  
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        labels: {
                            fontColor: 'white' //set your desired color
                         }
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) 
        {
             var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DailyResponseTiming = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'OFDailyChartController',
        type: 'daily_response_pie',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "<=15min",
                    highlight: "#197f34",
                    color: "#197f34"
                },
                {
                    value : 0,
                    label: "15min - 20min",
                    highlight: "#79e60c",
                    color: "#79e60c"
                },
                {
                    value : 0,
                    label: "20ming - 30min",
                    highlight: "#e6e60c",
                    color: "#e6e60c"
                },
                {
                    value : 0,
                    label: ">30min",
                    highlight: "#f38813",
                    color: "#f38813"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

//                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        labels: {
                            fontColor: 'white' //set your desired color
                         }
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

                var result = data.data;
                
                if(result.length >4)
                {
                    result.length= 4;
                }
                
                for (var i = 0, length = result.length; i < length; i++) 
                {
                    chart.data.datasets[0].data[i] = result[i];
                }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DailyHandlingCount = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'OFDailyChartController',
        type: 'daily_handling_pie',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "< 30min",
                    highlight: "#197f34",
                    color: "#197f34"
                },
                {
                    value : 0,
                    label: "30min - 1hr",
                    highlight: "#79e60c",
                    color: "#79e60c"
                },
                {
                    value : 0,
                    label: "1hr - 2hr",
                    highlight: "#e6e60c",
                    color: "#e6e60c"
                },
                {
                    value : 0,
                    label: ">2 hrs",
                    highlight: "#f38813",
                    color:"#f38813"
                }              
                
            ];
            
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

//                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        labels: {
                            fontColor: 'white' //set your desired color
                         }
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
           // alert(JSON.stringify(data));
           
           if(result.length >4 )
           {
               result.length =4;
           }
           
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) 
            {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DailyIncidentBar = function (id, options) {

    var _this = {
        url: 'OFDailyChartController',
        type: 'daily_incident_bar',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["Call-In", "On Patrol", "One Motoring", "Report Appointment", "Second Rider"],
                datasets: [
                    {
                        backgroundColor: ["#79e60c", "#2fbdea", "#d04141", "#f38813", "#e6e60c"],
                        data: [0,0,0,0,0]
                    }
                ]
            };
            
            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < barChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + barChartData.datasets[i].backgroundColor + '"></span>');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                       display: false,
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    precision: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
//                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var DailyHandlingBar = function (id, options) {

    var _this = {
        url: 'OFDailyChartController',
        type: 'daily_handling_bar',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["< 30min", "30min - 1hr", "1hr - 2hr", "> 2hrs", "Total"],
                datasets: [
                    {
                        backgroundColor: ["#197f34", "#79e60c", "#e6e60c", "#f38813", "#c3ce3a"],
                        data: [0,0,0,0,0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display:false,
                    },
                    scales: {
                        yAxes: []
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].speed));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DailyResponseBar = function (id, options) {

    var _this = {
        url: 'OFDailyChartController',
        type: 'daily_response_bar',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["<= 15min", "15 - 20min", "20 - 30min", "> 30min","Total"],
                datasets: [
                    {
                        backgroundColor: ["#197f34", "#79e60c", "#e6e60c", "#f38813", "#c3ce3a"],
                        data: [0,0,0,0,0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                       display:false,
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    // forces step size to be 5 units
                                    stepSize: 5
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].speed));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var MonthlyIncidentCount = function (id, options) { 
    var _this = {
        url: 'OFMonthlyChartController',
        type: 'monthly_incident_pie',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Call-In",
                    highlight: "#79e60c",
                    color: "#79e60c"
                },
                {
                    value : 0,
                    label: "On Patrol",
                    highlight: "#2fbdea",
                    color:  "#2fbdea"
                },
                {
                    value : 0,
                    label: "One Motoring",
                    highlight: "#d04141",
                    color: "#d04141"
                },
                {
                    value : 0,
                    label: "Report Appointment",
                    highlight: "#f38813",
                    color: "#f38813"
                },
                {
                    value : 0,
                    label: "Second Rider",
                    highlight: "#e6e60c",
                    color:  "#e6e60c"
                }
                
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

//                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        labels: {
                            fontColor: 'white' //set your desired color
                         }
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                
                chart.data.datasets[0].data[i] = result[i].count;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var MonthlyResponseTiming = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'OFMonthlyChartController',
        type: 'monthly_response_pie',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "<=15min",
                    highlight: "#197f34",
                    color: "#197f34"
                },
                {
                    value : 0,
                    label: "15min - 20min",
                    highlight: "#79e60c",
                    color:  "#79e60c"
                },
                {
                    value : 0,
                    label: "20ming - 30min",
                    highlight: "#e6e60c",
                    color:  "#e6e60c"
                },
                {
                    value : 0,
                    label: ">30min",
                    highlight: "#f38813",
                    color:  "#f38813"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

//                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                         labels: {
                            fontColor: 'white' //set your desired color
                         }
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

           var result = data.data;
           
           if(result.length>4)
           {
               result.length=4;
           }
            for (var i = 0, length = result.length; i < length; i++) 
            {               
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var MonthlyHandlingCount = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'OFMonthlyChartController',
        type: 'monthly_handling_pie',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "< 30min",
                    highlight: "#197f34",
                    color: "#197f34"
                },
                {
                    value : 0,
                    label: "30min - 1hr",
                    highlight: "#79e60c",
                    color: "#79e60c"
                },
                {
                    value : 0,
                    label: "1hr - 2hr",
                    highlight: "#e6e60c",
                    color:  "#e6e60c"
                },
                {
                    value : 0,
                    label: ">2 hrs",
                    highlight: "#f38813",
                    color: "#f38813"
                },   
                {
                    value : 0,
                    label: "Total",
                    highlight: "#c3ce3a",
                    color: "#c3ce3a"
                }
            ];
            
            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

//                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color,
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label,
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        labels: {
                            fontColor: 'white' //set your desired color
                         }
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            
            if(result.length >5)
            {
                result.length=5;
            }
            
            for (var i = 0, length = result.length; i < length; i++) 
            {               
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var MonthlyIncidentBar = function (id, options) {

    var _this = {
        url: 'OFMonthlyChartController',
        type: 'monthly_incident_bar',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["Call-In", "On Patrol", "One Motoring", "Report Appointment", "Second Rider"],
                datasets: [
                    {
                         backgroundColor: ["#79e60c", "#2fbdea", "#d04141", "#f38813", "#e6e60c"],
                        data: [0,0,0,0,0]
                    }
                ]
            };
            
            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < barChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + barChartData.datasets[i].backgroundColor + '"></span>' + barChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                       display: false,
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    precision: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {
//                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var MonthlyHandlingBar = function (id, options) {

    var _this = {
        url: 'OFMonthlyChartController',
        type: 'monthly_handling_bar',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["<30min", "30min - 1hr", "1hr - 2hr", "> 2hrs", "Total"],
                datasets: [
                    {
                        backgroundColor: ["#197f34", "#79e60c", "#e6e60c", "#f38813", "#c3ce3a"],
                        data: [0,0,0,0,0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false,
                    },
                    scales: {
                        yAxes: []
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) 
            {               
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].speed));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var MonthlyResponseBar = function (id, options) {

    var _this = {
        url: 'OFMonthlyChartController',
        type: 'monthly_response_bar',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["<=15min", "15 - 20min", "20 - 30min", "> 30min", "Total"],
                datasets: [
                    {
                       backgroundColor: ["#197f34", "#79e60c", "#e6e60c", "#f38813", "#c3ce3a"],
                        data: [0,0,0,0,0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                       display: false,
                    },
                    scales: {
                        yAxes: []
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].timestamp));

                tr.append($('<td/>').html(data.records[i].speed));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

 

var ShPresentChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAStreetHawkingDashboardController',
        type: 'sh_present',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Y",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "N",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].yes;
                    chart.data.datasets[0].data[1] = data.data[i].no;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var ShTypeChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAStreetHawkingDashboardController',
        type: 'sh_type',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Routine",
                    highlight: "#9E9E9E",
                    color: "rgba(17, 177, 171,0.7)"
                },
                {
                    value : 0,
                    label: "Feedback",
                    highlight: "#35A7FF",
                    color: "rgba(177, 171, 17, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].routine;
                    chart.data.datasets[0].data[1] = data.data[i].feedback;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var ShShtypeChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAStreetHawkingDashboardController',
        type: 'sh_shtype',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Licensed",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "Illegal",
                    highlight: "#0000AA",
                    color: "rgba(0, 0, 0, 0.7)"
                },
                {
                    value : 0,
                    label: "Extension",
                    highlight: "#35A7FF",
                    color: "rgba(171, 17, 177,0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].licensed;
                    chart.data.datasets[0].data[1] = data.data[i].illegal;
                    chart.data.datasets[0].data[2] = data.data[i].extension;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var ShGoodsTradeChart = function (id, options) {

    var _this = {
        url: 'SFAStreetHawkingDashboardController',
        type: 'sh_goods_trade',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");

            var barChartData = {
                labels: ["Fruit", "Chestnut", "Cooked Food", "Produce"
                            , "Ice Cream", "Tissue", "Apparels"
                            , "Electrical", "Party", "Others (Food)", "Others (Non-Food)"],
                datasets: [
                    {
                        backgroundColor: "rgba(22,129,222,0.7)",
                        borderColor: "rgba(255,255,255,1)",
                        fill: true,
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    }
                ]
            };

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: barChartData,
                options: {
                    responsive: true,
                    legendCallback: function (chart) {
                        return '<span></span>'
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0
                                }}]
                    }
                }
            });

        },
        updateChart: function (chart, data) {

            var result = data.data;
            for (var i = 0, length = result.length; i < length; i++) {
                chart.data.datasets[0].data[i] = result[i];
            }
            
            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) 
            {
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].count;
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };

    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var ShSmmChart = function (id, options) { // use FOR Vertical BAR GRAPH

    var _this = {
        url: 'SFAStreetHawkingDashboardController',
        type: 'sh_smm',
        createChart: function (canvas) {
            var ctx = canvas.getContext("2d");
            var datalabely = ["Mask", "Queue"];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: "Yes",
                        backgroundColor: "rgba(103,177,17, 0.7)",
                        data: [0]
                    },
                    {
                        label: "No",
                        backgroundColor: "rgba(177, 17, 23, 0.7)",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
//                                stacked: true
                            }],
                        yAxes: [{
//                                stacked: true,
                                ticks : {
                                    min:0
                                }
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) {
                if (result[i].label.length >= 10) {
                    for (var j = 0; j < 10; j++) {
                        temp += result[i].label[j];
                    }
                    result[i].label = temp + "...";
                    temp = "";
                }
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].compliant;
                chart.data.datasets[1].data[i] = result[i].noncompliant;

            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var ShOutcomeChart = function (id, options) { // use FOR Vertical BAR GRAPH

    var _this = {
        url: 'SFAStreetHawkingDashboardController',
        type: 'sh_outcome',
        createChart: function (canvas) {
            var ctx = canvas.getContext("2d");
            var datalabely = ["Advisory", "WW", "Enforcement", "Seize"];

            var horizontalBarChartData = {
                labels: datalabely,
                datasets: [
                    {
                        label: "Yes",
                        backgroundColor: "rgba(177, 17, 23, 0.7)",
                        data: [0]
                    },
                    {
                        label: "No",
                        backgroundColor: "rgba(103,177,17, 0.7)",
                        data: [0]
                    },
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < horizontalBarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + horizontalBarChartData.datasets[i].backgroundColor + '"></span>' + horizontalBarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }

            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: horizontalBarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    responsive: true,
                    scales: {
                        xAxes: [{
//                                stacked: true
                            }],
                        yAxes: [{
//                                stacked: true,
                                ticks : {
                                    min:0
                                }
                            }]
                    }
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";
            for (var i = 0, length = result.length; i < length; i++) {
                if (result[i].label.length >= 10) {
                    for (var j = 0; j < 10; j++) {
                        temp += result[i].label[j];
                    }
                    result[i].label = temp + "...";
                    temp = "";
                }
                chart.config.data.labels[i] = result[i].label;
                chart.data.datasets[0].data[i] = result[i].yes;
                chart.data.datasets[1].data[i] = result[i].no;

            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var SafeentryChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAFarmsDashboardController',
        type: 'safeentry',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Yes",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "No",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].yes;
                    chart.data.datasets[0].data[1] = data.data[i].no;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var SafeentryFunctionalChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAFarmsDashboardController',
        type: 'safeentry_functional',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Yes",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "No",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].yes;
                    chart.data.datasets[0].data[1] = data.data[i].no;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var FarmsMaskChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAFarmsDashboardController',
        type: 'farms_mask',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Yes",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "No",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].yes;
                    chart.data.datasets[0].data[1] = data.data[i].no;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};


var FarmsDistancingChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAFarmsDashboardController',
        type: 'farms_distancing',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Yes",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "No",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].yes;
                    chart.data.datasets[0].data[1] = data.data[i].no;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var FarmsScreeningChart = function (id, options) { // this is the pie chart, overall
    var _this = {
        url: 'SFAFarmsDashboardController',
        type: 'farms_screening',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Yes",
                    highlight: "#9E9E9E",
                    color: "rgba(103,177,17, 0.7)"
                },
                {
                    value : 0,
                    label: "No",
                    highlight: "#00AA00",
                    color: "rgba(177, 17, 23, 0.7)"
                }
            ];
            


            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color
                            ]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < data.data.length; i++) {
                    chart.data.datasets[0].data[0] = data.data[i].yes;
                    chart.data.datasets[0].data[1] = data.data[i].no;
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].ended));

                tr.append($('<td/>').html(data.records[i].pending));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};



var HourlyUsageChart = function (id, options) {

    var _this = {
        url: 'TFSSensorReportController',
        type: 'hourly_usage',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
//            var datalabel = [options.language.rating];
            var BarChartData = {
//                labels: datalabel,
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#4473c4",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'line',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            /*
             * title refresh 
             */
            var assetLabel = $('#tree-view-filter-asset li[data-filter-asset-id="' + _this.filter + '"] span.leaf').text();
            
            var dateArr = _this.filter2.split('/');
            
            var date = new Date(dateArr[1] + '/' + dateArr[0] + '/' + dateArr[2]);
            
            var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
            
            var formattedTitle =  assetLabel + ' (' + date.getDate() + ' ' + months[date.getMonth()] + ' ' + date.getFullYear() + ')';
            
            $('#' + id + '-title').text(formattedTitle);
            
            /*
             * chart data refresh
             */
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var DailyUsageChart = function (id, options) {

    var _this = {
        url: 'TFSSensorReportController',
        type: 'daily_usage',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var BarChartData = {
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#ffc73a",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            /*
             * title refresh 
             */
            var assetLabel = $('#tree-view-filter-asset li[data-filter-asset-id="' + _this.filter + '"] span.leaf').text();
            
            var date = new Date(_this.filter2);
            
            var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
            
            var formattedTitle =  assetLabel + ' (' + months[date.getMonth()] + ' ' + date.getFullYear() + ')';
            
            $('#' + id + '-title').text(formattedTitle);
            
            /*
             * chart data refresh
             */
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var MonthlyUsageChart = function (id, options) {

    var _this = {
        url: 'TFSSensorReportController',
        type: 'monthly_usage',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var BarChartData = {
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#f48440",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            /*
             * title refresh 
             */
            var assetLabel = $('#tree-view-filter-asset li[data-filter-asset-id="' + _this.filter + '"] span.leaf').text();
            
            var formattedTitle =  assetLabel + ' (' + _this.filter2 + ')';
            
            $('#' + id + '-title').text(formattedTitle);
            
            /*
             * chart data refresh
             */
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var TopHighestUsageChart = function (id, options) {

    var _this = {
        url: 'TFSSensorReportController',
        type: 'top_highest_usage',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var BarChartData = {
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#c00000",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            /*
             * title refresh 
             */
            var top = 'Top ' + _this.filter + ' Highest Usage';
            
            var date = new Date(_this.filter2);
            
            var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
            
            var formattedTitle =  top + ' (' + months[date.getMonth()] + ' ' + date.getFullYear() + ')';
            
            $('#' + id + '-title').text(formattedTitle);
            
            /*
             * chart data refresh
             */
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var TopLowestUsageChart = function (id, options) {

    var _this = {
        url: 'TFSSensorReportController',
        type: 'top_lowest_usage',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var BarChartData = {
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#92d050",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            /*
             * title refresh 
             */
            var top = 'Top ' + _this.filter + ' Lowest Usage';
            
            var date = new Date(_this.filter2);
            
            var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
            
            var formattedTitle =  top + ' (' + months[date.getMonth()] + ' ' + date.getFullYear() + ')';
            
            $('#' + id + '-title').text(formattedTitle);
            
            /*
             * chart data refresh
             */
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].label, 10);
                chart.data.datasets[0].data[i] = result[i].total;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var AirQualityLevelByPercentage = function (id, options) {
    var _this = {
        url: 'TFSSensorReportController',
        type: 'air_quality_level',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Excellent (%)",
                    color: "#fff7ed"
                },
                {
                    value : 0,
                    label: "Good (%)",
                    color: "#ffe0b5"
                },
                {
                    value : 0,
                    label: "Moderate (%)",
                    color: "#ffd284"
                },
                {
                    value : 0,
                    label: "Poor (%)",
                    color: "#ffbf00"
                },
                {
                    value : 0,
                    label: "Very Poor (%)",
                    color: "#e2aa00"
                },
                {
                    value : 0,
                    label: "Intolerable (%)",
                    color: "#c09000"
                }
            ];

            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color,
                                segments[5].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label,
                        segments[5].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true
                }
            });
        },
        updateChart: function (chart, data) {
            
            chart.data.datasets[0].data = [];

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < result.length; i++) {
                    chart.data.datasets[0].data[i] = result[i].total.toFixed(2);
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total.toFixed(2)));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var TopHighestUsageHalfMonthChart = function (id, options) {

    var _this = {
        
        url: 'TFSChartController',
        type: 'top_highest_by_halfmonth',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
//            var datalabel = [options.language.rating];
            var BarChartData = {
//                labels: datalabel,
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#c00000",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            airQualityDetail();
            
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].asset, 10);
                chart.data.datasets[0].data[i] = result[i].count;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var TopLowestUsageHalfMonthChart = function (id, options) {

    var _this = {
        
        url: 'TFSChartController',
        type: 'top_lowest_by_halfmonth',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
//            var datalabel = [options.language.rating];
            var BarChartData = {
//                labels: datalabel,
                datasets: [
                    {
                        label: options.language.peopleCount,
                        backgroundColor: "#92d050",
                        data: [0]
                    }
                ]
            };

            var legendContainer = $('<ul/>', {class: 'chart-legend'});

            for (var i = 0; i < BarChartData.datasets.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + BarChartData.datasets[i].backgroundColor + '"></span>' + BarChartData.datasets[i].label + '');

                legendContainer.append(legendItem);

            }
            _this.chart = new Chart(ctx, {
                type: 'bar',
                data: BarChartData,
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },

                    tooltips: {
                        mode: 'index',
                        intersect: false
                    },
                    scales: {
                        yAxes: [{ticks: {
                                    min: 0,
                                    callback: function(value) {if (value % 1 === 0) {return value;}},
                                    maxRotation: 90
                                }
                            }],
                        xAxes: [{ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }]
                    },
                    responsive: true,
                }
            });
        },
        updateChart: function (chart, data) {
            
            chart.config.data.labels = [];
            
            chart.data.datasets[0].data = [];
            
            var result = data.data;
            for (var i = 0;i < result.length; i++) {
                chart.config.data.labels[i] = ellipsisText(result[i].asset, 10);
                chart.data.datasets[0].data[i] = result[i].count;
            }
        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].asset));

                tr.append($('<td/>').html(data.records[i].count));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};

var AirQualityLevelOneHourChart = function (id, options) {
    var _this = {
        url: 'TFSChartController',
        type: 'air_quality_level_one_hour',
        createChart: function (canvas) {

            var ctx = canvas.getContext("2d");
            var segments = [
                {
                    value : 0,
                    label: "Excellent (%)",
                    color: "#fff7ed"
                },
                {
                    value : 0,
                    label: "Good (%)",
                    color: "#ffe0b5"
                },
                {
                    value : 0,
                    label: "Moderate (%)",
                    color: "#ffd284"
                },
                {
                    value : 0,
                    label: "Poor (%)",
                    color: "#ffbf00"
                },
                {
                    value : 0,
                    label: "Very Poor (%)",
                    color: "#e2aa00"
                },
                {
                    value : 0,
                    label: "Intolerable (%)",
                    color: "#c09000"
                }
            ];

            var legendContainer = $('<ul/>', {class: 'pie-legend'});

            for (var i = 0; i < segments.length; i++) {

                var legendItem = $('<li/>');

                legendItem.html('<span style="background-color:' + segments[i].color + '"></span>' + segments[i].label + '');

                legendContainer.append(legendItem);
            }

            _this.chart = new Chart(ctx, {
                type: 'pie',
                data:  {
                    datasets: [{
                            data: [0, 0, 0, 0, 0, 0],
                            backgroundColor: [
                                segments[0].color,
                                segments[1].color,
                                segments[2].color,
                                segments[3].color,
                                segments[4].color,
                                segments[5].color]
                        }
                    ],
                    labels: [
                        segments[0].label,
                        segments[1].label,
                        segments[2].label,
                        segments[3].label,
                        segments[4].label,
                        segments[5].label
                    ]
                },
                options: {
                    legendCallback: function (chart) {
                        return $(legendContainer)[0].outerHTML;
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        mode: 'index',
                        intersect: false,
                    },
                    showTooltips: true,
                    responsive: true
                }
            });
        },
        updateChart: function (chart, data) {
            
            chart.data.datasets[0].data = [];

            var result = data.data;
            var temp = "";

            if (data.total === 0) {
                chart.data.datasets[0].data[0] = 1;
            } else {
                for (var i = 0; i < result.length; i++) {
                    chart.data.datasets[0].data[i] = result[i].total.toFixed(2);
                }
            }

        },
        setDetail: function (data) {

            var table = $('<table/>', {id: id + '-table'});

            var thead = $('<thead/>');

            var tr = $('<tr/>');

            for (var i = 0; i < data.columns.length; i++) {
                tr.append($('<th/>').html(data.columns[i]));

                thead.append(tr);
            }

            table.append(thead);

            var tbody = $('<tbody/>');

            for (var i = 0; i < data.records.length; i++) {
                tr = $('<tr/>');

                tr.append($('<td/>').html(data.records[i].label));

                tr.append($('<td/>').html(data.records[i].total.toFixed(2)));

                tbody.append(tr);
            }

            table.append(tbody);

            return table;
        }
    };
    _this = $.extend(new DashboardChart(id, options), _this);

    return _this;
};