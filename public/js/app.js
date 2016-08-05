// Sidebar Toggle
(function() {
  var sidebarButton = document.getElementById('sidebar-button');
  var sidebar = document.getElementById('sidebar');
  var overlay = document.getElementById('app-overlay');

  sidebarButton.addEventListener('click', toggleSidebar);

  function toggleSidebar(e) {
    if (isSidebarOpen(sidebar.className)) {
      openSidebar();
      openOverlay();
      overlay.removeEventListener('click', toggleSidebar);
    } else {
      closeSidebar();
      closeOverlay();
      overlay.addEventListener('click', toggleSidebar);
    }
  }

  function isSidebarOpen(className) {
    return className
      .split(' ')
      .filter(function (c) {
        return c === 'open'
      })
      .length > 0;
  }

  function openSidebar() {
    openElement(sidebar);
  }

  function closeSidebar() {
    closeElement(sidebar);
  }

  function openOverlay() {
    openElement(overlay);
  }

  function closeOverlay() {
    closeElement(overlay);
  }

  function openElement(elm) {
    elm.className = elm.className
        .split(' ')
        .filter(function(c) {
          return c !== 'open'
        })
        .join(' ');
  }

  function closeElement(elm) {
    className = elm.className.split(' ');
    className.push('open');

    elm.className = className.join(' ');
  }
})();

//ChartJS
(function() {
  var charts = document.querySelectorAll('div[pollios-chart]');
  charts.forEach(createChart);

  function createChart(chart) {
    let data = createChartData(createDataset(extractChartAttr(chart)));
    let canvas = createCanvas(chart);

    Chart.Line(canvas, data);
  }

  function extractChartAttr(chart) {
    return {
      data: JSON.parse(chart.getAttribute('data')),
      labels: JSON.parse(chart.getAttribute('data')),
      color: chart.getAttribute('color')
    }
  }

  function createCanvas(elm) {
    let canvas = document.createElement('canvas');
    elm.appendChild(canvas);
    return canvas;
  }

  function createDataset(chartData) {
    return {
      labels: chartData.labels,
      datasets: [
          {
              lineTension: 0.1,
              fill: false,
              borderWidth: 2,
              borderColor: chartData.color,
              pointRadius: 0,
              data: chartData.data
          }
      ]
    }
  }

  function createChartData(dataset) {
    return {
      data: dataset,
      options: {
        title: {
          display: false
        },
        legend: {
          display: false
        },
        scales: {
          xAxes: [ {
            display: false
          } ],
          yAxes: [ {
            display: false
          } ]
        }
      }
    }
  }
})();