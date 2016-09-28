const Chart = require('chart.js')
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

  new Chart(ctx, {
    type: 'pie',
    data: {
      labels: choicesData.label,
      datasets: [{
        label: '# of Votes',
        data: choicesData.data,
        backgroundColor: backgroundColors,
        borderWidth: 0
      }]
    }
  })
}
