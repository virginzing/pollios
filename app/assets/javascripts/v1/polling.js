const change = require('chance')
const url = 'http://codeapp-polliosdev.herokuapp.com/m/qsncc/polling'

const counterElement = document.getElementById('counter')

if (counterElement) {
  run()
}

function run() {
  const timeout = chance.integer({ min: 500, max: 5000 });

  setTimeout(function () {
    fetchVoteCount()
  }, timeout)
}

function fetchVoteCount () {
  fetch(url)
    .then(function (response) {
      return response.json()
    })
    .then(function (json) {
      counterElement.innerHTML = json.vote_all
      run()
    })
}
