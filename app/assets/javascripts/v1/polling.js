const change = require('chance')

const counterElement = document.getElementById('counter')

if (counterElement) {
  const isPollClosed = counterElement.getAttribute('close')
  const needFetch = isPollClosed === 'false'

  if (needFetch) {
    run()
  }
}

function run() {
  const timeout = chance.integer({ min: 500, max: 5000 });

  setTimeout(function () {
    fetchVoteCount()
  }, timeout)
}

function fetchVoteCount () {
  const groupPublicID = counterElement.getAttribute('group')
  const pollingURL = counterElement.getAttribute('polling')

  fetch(pollingURL)
    .then(function (response) {
      return response.json()
    })
    .then(function (json) {
      counterElement.innerHTML = json.vote_all.toLocaleString()
      run()
    })
}
