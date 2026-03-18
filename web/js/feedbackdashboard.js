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
        filter2: '',
        filter3: '',
        filter4: '',
        filter5: '',

        getData: function () {

	  $.ajax({
	      type: 'POST',
	      url: _this.url,
	      data: {
		action: 'get',
		type: _this.type,
		filter: _this.filter,
		filter2: _this.filter2,
		filter3: _this.filter3,
		filter4: _this.filter4,
		filter5: _this.filter5
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
		filter2: _this.filter2,
		filter3: _this.filter3,
		filter4: _this.filter4,
		filter5: _this.filter5
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
        createWithoutCanvas: function () {
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
        setFilter: function (filter, filter2, filter3, filter4, filter5) {

	  _this.filter = filter;
	  _this.filter2 = filter2;
	  _this.filter3 = filter3;
	  _this.filter4 = filter4;
	  _this.filter5 = filter5;

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



var feedBackDashboard = function (id, options) {

    var _this = {
        url: 'ChartController',
        type: 'feedbackdashboard',
        createChart: function (canvas) {

	  var ctx = canvas.getContext("2d");

	  var segments = [
	      {
		value: 1,
		color: "#eb9999",
		highlight: "#eb9999",
		label: "Assigned"
	      },
	      {
		value: 0,
		color: "#6BAC61",
		highlight: "#9E9E9E",
		label: "Closed"
	      },
	      {
		value: 0,
		color: "#15D0C1",
		highlight: "#4c4cff",
		label: "Ended"
	      },

	      {
		value: 0,
		color: "#999900",
		highlight: "#4c4cff",
		label: "Reopened"
	      },
	     
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
		        data: [1, 0, 0, 0],
		        backgroundColor: [
			  segments[0].color,
			  segments[1].color,
			  segments[2].color,
			  segments[3].color,
		        ]
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
	  console.log(JSON.stringify(data.summary))
	  
	  var assigned = false;
	  var Ended = false;
	  var Reopened = false;
	  var Closed = false;
	  for (var i = 0; i < data.summary.length; i++) {
	      if(data.summary[i].value=='assigned' || data.summary[i].value=='Assigned'){
		assigned=true;
                    chart.data.datasets[0].data[0] = data.summary[i].count;
	      }
	      else if(data.summary[i].value=='Ended' || data.summary[i].value=='Ended'){
		Ended=true;
                    chart.data.datasets[0].data[2] = data.summary[i].count;
	      }
	      else  if(data.summary[i].value=='Reopened' || data.summary[i].value=='Reopened'){
		Reopened=true;
                    chart.data.datasets[0].data[3] = data.summary[i].count;
	      }
	      else if(data.summary[i].value=='Closed' || data.summary[i].value=='closed'){
		Closed=true;
                    chart.data.datasets[0].data[1] = data.summary[i].count;
	      }
	      if(!assigned){
		 chart.data.datasets[0].data[0] = 0;
	      } if(!Closed){
		chart.data.datasets[0].data[1] = 0;
	      }
	       if(!Ended){
		 chart.data.datasets[0].data[2] = 0;
	      } if(!Reopened){
		chart.data.datasets[0].data[3] = 0;
	      }
              
	      //chart.data.datasets[0].data[i] = data.summary[i].count;
                }
                if(data.summary.length<1){
                    chart.data.datasets[0].data[0] = 1;
		chart.data.datasets[0].data[3] = 0;
		chart.data.datasets[0].data[1] = 0;
		chart.data.datasets[0].data[2] = 0;
                    
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

	      tr.append($('<td/>').html(data.records[i].customer));

	      tr.append($('<td/>').html(data.records[i].feedbackuser));
	      tr.append($('<td/>').html(data.records[i].timestamp));
	       tr.append($('<td/>').html(data.records[i].staffAssigned));

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


