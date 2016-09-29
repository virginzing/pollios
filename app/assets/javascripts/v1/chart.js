const Chart = require('./libs/chart')
const chartElement = document.getElementById('result')

if (chartElement) {
  setupChart()
}

function setupChart () {
  const ctx = chartElement.getContext('2d')
  const choicesData = JSON.parse(chartElement.getAttribute('data'))

  const backgroundColors = [
    '#e74c3c',
    '#3498db',
    '#f1c40f',
    '#1abc9c',
    '#9b59b6',
    '#e67e22',
    '#34495e',
    '#c0392b',
    '#2980b9',
    '#f39c12',
    '#27ae60',
    '#8e44ad',
    '#d35400'
  ]

  const data = {
    labels: choicesData.label,
    datasets: [{
      label: '# of Votes',
      data: choicesData.data,
      backgroundColor: backgroundColors,
      borderWidth: 0
    }]
  }

  const options = {
    responsive: true,
    legend: {
      position: 'bottom',
      labels: { fontSize: 16 }
    },
    showAllTooltips: true,
    tooltips: {
      callbacks: { label: handleToolTipsLabelCallback },
      bodyFontSize: 20
    }
  }

  const config = {
    type: 'pie',
    data: data,
    options: options
  }

  var piechart = new Chart(ctx, config)
}

function handleToolTipsLabelCallback (tooltipItem, data) {
  var dataset = data.datasets[tooltipItem.datasetIndex];
  var total = dataset.data.reduce(function(previousValue, currentValue, currentIndex, array) {
    return previousValue + currentValue;
  });
  var currentValue = dataset.data[tooltipItem.index];
  var precentage = Math.floor(((currentValue/total) * 100)+0.5);
  return precentage + "%";
}
