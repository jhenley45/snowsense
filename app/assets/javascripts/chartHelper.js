if (!snowSense) var snowSense = {};

(function() {

  function drawWindChart(data, stid) {

    var windSpeedData;
    var windCategories;
    var element = 'wind-chart-' + stid;

    windSpeedData     = data.map(function(datum) { return datum.wind_speed });
    windCategories    = data.map(function(datum) { return new Date(datum.date_time).toLocaleString("en-US") });
    windGustData      = data.map(function(datum) { return datum.wind_gusts });


    if (isNullDataSet(windSpeedData)) {
      addNoDataChart($('#' + element));
      return;
    }

    $('#' + element).removeClass('loading-icon');

    Highcharts.chart(element, {
        chart: {
            type: 'line'
        },
        title: {
            text: 'Recent Wind Speed'
        },
        subtitle: {
            text: 'Source: MesoWest'
        },
        xAxis: {
            categories: windCategories,
            labels: {
                rotation: 45
            },
            minTickInterval: 10
        },
        yAxis: {
            title: {
                text: 'Wind Speed (mph)'
            },
            plotLines: [{
              color: '#D91E18', // Color value
              dashStyle: 'solid', // Style of the plot line. Default to solid
              value: 21, // Value of where the line will appear
              width: 1, // Width of the line
              label: {
                text: 'Est. Transported Snow Speed', // Content of the label.
                align: 'left', // Positioning of the label.
              }
            }]
        },
        tooltip: {
            formatter: function() {
                return '' + this.series.name + ' on' + this.x + ' was <b>' + this.y + '</b> mph';
            }
        },
        plotOptions: {
            line: {

            }
        },
        series: [
          {
            name: 'Wind Speed (mph)',
            data: windSpeedData
          },
          {
            name: "Wind Gusts (mph)",
            data: windGustData,
            lineWidth: 0,
            marker: {
              enabled: true,
              radius: 2
            },
            tooltip: {
              valueDecimals: 2
            },
            states: {
              hover: {
                lineWidthPlus: 0
              }
            }
          }]
    });

  }

  function drawTempChart(data, stid) {

    var tempData;
    var tempCategories;

    tempData        = data.map(function(datum) { return datum.temperature });
    tempCategories  = data.map(function(datum) { return new Date(datum.date_time).toLocaleString("en-US") });

    var element = 'temperature-chart-' + stid;

    $('#' + element).removeClass('loading-icon');

    Highcharts.chart(element, {
        chart: {
            type: 'line'
        },
        title: {
            text: 'Recent Temperature'
        },
        subtitle: {
            text: 'Source: MesoWest'
        },
        xAxis: {
            categories: tempCategories,
            labels: {
                rotation: 45
            },
            minTickInterval: 10
        },
        yAxis: {
            title: {
                text: 'Temperature (°F)'
            },
            plotLines: [{
              color: '#D91E18', // Color value
              dashStyle: 'solid', // Style of the plot line. Default to solid
              value: 32, // Value of where the line will appear
              width: 1, // Width of the line
              label: {
                text: '32 °F', // Content of the label.
                align: 'left', // Positioning of the label.
              }
            }]
        },
        tooltip: {
            formatter: function() {
                return 'The temperature on' + this.x + ' was <b>' + this.y + '</b> degrees Farenheit';
            }
        },
        plotOptions: {
            line: {

            }
        },
        series: [{
            name: 'Temperature (°F)',
            data: tempData
        }]
    });

  }

  function removeAllSeries(chart) {
    var seriesLength = chart.series.length;
    for (var i = seriesLength -1; i > -1; i--) {
        chart.series[i].remove();
    };
  }


  // ---------- PRIVATE FUNCTIONS ----------

  function addNoDataChart($element) {
    var $message = $('<div class="no-chart-data">Station does not provide this data</div>');
    $element.append($message);
    $element.removeClass('loading-icon');
  };

  function isNullDataSet(data) {
    var isNull = true;
    data.some(function(datum) {
      if (datum !== null) isNull = false;
      return;
    });
    return isNull;
  }


  snowSense.chartHelper = {
    drawWindChart:          drawWindChart,
    drawTempChart:          drawTempChart,
    removeAllSeries:        removeAllSeries
  };

}());
