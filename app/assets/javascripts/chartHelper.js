if (!snowSense) var snowSense = {};

(function() {

  var windDirectionImages = {
    "N": 'url(/assets/N1.png)',
    "NNE": 'url(/assets/NNE1.png)',
    "NE": 'url(/assets/NE1.png)',
    "ENE": 'url(/assets/ENE1.png)',
    "E": 'url(/assets/E1.png)',
    "ESE": 'url(/assets/ESE1.png)',
    "SE": 'url(/assets/SE1.png)',
    "SSE": 'url(/assets/SSE1.png)',
    "S": 'url(/assets/S1.png)',
    "SSW": 'url(/assets/SSW1.png)',
    "SW": 'url(/assets/SW1.png)',
    "WSW": 'url(/assets/WSW1.png)',
    "W": 'url(/assets/W1.png)',
    "WNW": 'url(/assets/WNW1.png)',
    "NW": 'url(/assets/NW1.png)',
    "NNW": 'url(/assets/NNW1.png)'
  };

  function initializeEmptyWindChart($element) {

    var chart = $element.highcharts({
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
          categories: [],
          labels: {
              rotation: 45
          },
          minTickInterval: 20
      },
      yAxis: {
          title: {
              text: 'Wind Speed (mph)'
          },
          plotLines: [{
            // color: '#D91E18', // Color value
            // dashStyle: 'solid', // Style of the plot line. Default to solid
            // value: 21, // Value of where the line will appear
            // width: 1, // Width of the line
            // label: {
            //   //text: 'Est. Transported Snow Speed', // Content of the label.
            //   align: 'left', // Positioning of the label.
            // },
            // zIndex: 5
          }]
      },
      tooltip: {
          formatter: function() {
            if (this.point.direction) {
              return 'Prevailing Wind: <b>' + this.point.direction + '</b>';
            } else {
              return '' + this.series.name + ' on' + this.x + ' was <b>' + this.y + '</b> mph';
            }

          }
      },
      series: []
    });

    return chart.highcharts();
  };

  function initializeEmptyTemperatureChart($element) {

    var chart = $element.highcharts({
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
          categories: [],
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
      series: []
    });

    return chart.highcharts();
  };

  function drawWindChart(data, stid) {

    var windSpeedData;
    var windCategories;
    var windGustData;
    var element = 'wind-chart-' + stid;

    windSpeedData     = data.map(function(datum) { return datum.wind_speed });
    windCategories    = data.map(function(datum) { return new Date(datum.date_time).toLocaleString("en-US") });
    windGustData      = data.map(function(datum) { return datum.wind_gusts });

    var windDirectionData = createWindDirectionData(data);

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
            minTickInterval: 20
        },
        yAxis: {
            title: {
                text: 'Wind Speed (mph)'
            },
            plotLines: [{
              // color: '#D91E18', // Color value
              // dashStyle: 'solid', // Style of the plot line. Default to solid
              // value: 21, // Value of where the line will appear
              // width: 1, // Width of the line
              // label: {
              //   //text: 'Est. Transported Snow Speed', // Content of the label.
              //   align: 'left', // Positioning of the label.
              // },
              // zIndex: 5
            }]
        },
        tooltip: {
            formatter: function() {
              if (this.point.direction) {
                return 'Prevailing Wind: <b>' + this.point.direction + '</b>';
              } else {
                return '' + this.series.name + ' on' + this.x + ' was <b>' + this.y + '</b> mph';
              }

            }
        },
        plotOptions: {
            line: {

            }
        },
        series: [
          createWindSpeedSeries(windSpeedData),
          createWindGustSeries(windGustData),
          createWindDirectionSeries(windDirectionData)
         ]
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
            type: 'line',
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
            id: 'temperature',
            name: 'Temperature (°F)',
            data: tempData
        },
        {
            name: '',
            type: 'scatter',
            marker: {
              enabled: false
            },
            data: [32]
         }]
    });

  }

  function removeAllSeries(chart) {
    var seriesLength = chart.series.length;
    for (var i = seriesLength -1; i > -1; i--) {
        chart.series[i].remove();
    };
  }

  function addWindGustSeries(chart, data) {
    var windGustSeries = createWindGustSeries(data);
    chart.addSeries(windGustSeries);
  }

  function addWindSpeedSeries(chart, data) {
    var windSpeedData = createWindSpeedSeries(data);
    chart.addSeries(windSpeedData);
  }

  function addWindDirectionSeries(chart, data) {
    var windDirectionData = createWindDirectionData(data);
    var windDirectionSeries = createWindDirectionSeries(windDirectionData);
    chart.addSeries(windDirectionSeries);
  }


  // ---------- PRIVATE FUNCTIONS ----------

  function addNoDataChart($element) {
    var chartBlock   = $element.closest('.chart-block');
    chartBlock.empty();
  };

  // TODO change this so that it checks to see if ALL data is null, not just one piece.
  function isNullDataSet(data) {
    var isNull = true;
    data.some(function(datum) {
      if (datum !== null) isNull = false;
      return;
    });
    return isNull;
  }

  function createWindGustSeries(data) {
    return {
      id: 'windGust',
      name: "Wind Gusts (mph)",
      data: data,
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
    }
  }

  function createWindSpeedSeries(data) {
    return {
      id: 'windSpeed',
      name: 'Wind Speed (mph)',
      data: data
    }
  }

  function createWindDirectionSeries(data) {
    return {
      id: 'windDirection',
      name: 'Wind Direction',
      data: data,
      turboThreshold: 0
    }
  }

  function createWindDirectionData(data) {
    var windGustData              = data.map(function(datum) { return datum.wind_gusts });
    var chartMax                  = Math.max.apply(null, windGustData);
    var windDirectionSeriesValue  = chartMax + 5;
    var windData                  = [];
    var dataGroupSize             = Math.round(windGustData.length / 10);
    var startIndex                = 0;
    var endIndex                  = dataGroupSize;

    var createNullDataSet = function(length) {
      var half = Math.round(length / 2);
      if (half > length / 2) half = half - 1;
      var array = [];

      for (j = 0; j < half; j ++) {
        array.push(null);
      }
      return array;
    };

    var getPrevailingWindDirection = function(group) {
      var windCounts              = {};
      var prevailingWind          = "W";
      var maxWindDirectionCount   = 0;

      group.forEach(function(object) {
        if (windCounts[object.wind_directions]) windCounts[object.wind_directions] += 1;
        else windCounts[object.wind_directions] = 1;
      });

      $.each(windCounts, function(key, value) {
        if (value > maxWindDirectionCount) {
          maxWindDirectionCount = value;
          prevailingWind = key;
        }
      });

      return prevailingWind;
    };

    for (i = 0; i < 10; i++) {
      if (i > 0) startIndex += dataGroupSize;
      if (i > 0) startIndex += 1;
      endIndex = startIndex + dataGroupSize;

      if (i === 9) endIndex = data.length - 1;

      var currentGroup = data.slice(startIndex, endIndex);
      var direction = getPrevailingWindDirection(currentGroup);
      var direction = { y: windDirectionSeriesValue, direction: direction,  marker: { symbol: windDirectionImages[direction], width: '2em', height: '1em' } };//'SSW';

      var nullDataSet = createNullDataSet(dataGroupSize);
      var thisDataSet = [];
      thisDataSet = thisDataSet.concat(nullDataSet);
      thisDataSet.push(direction);
      thisDataSet = thisDataSet.concat(nullDataSet);

      if (thisDataSet.length > dataGroupSize) thisDataSet.pop();
      windData = windData.concat(thisDataSet);
    }

    return windData;
  }


  snowSense.chartHelper = {
    initializeEmptyTemperatureChart:  initializeEmptyTemperatureChart,
    initializeEmptyWindChart:         initializeEmptyWindChart,
    drawWindChart:                    drawWindChart,
    drawTempChart:                    drawTempChart,
    removeAllSeries:                  removeAllSeries,
    addWindGustSeries:                addWindGustSeries,
    addWindSpeedSeries:               addWindSpeedSeries,
    addWindDirectionSeries:           addWindDirectionSeries
  };

}());
