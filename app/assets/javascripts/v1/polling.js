const change = require('chance')
const url = 'http://localhost:3000/qsncc/polling'

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
  const groupPublicID = counterElement.getAttribute('group')
  const pollingURL = url + '?group_public_id=' + String(groupPublicID)

  fetch(pollingURL)
    .then(function (response) {
      return response.json()
    })
    .then(function (json) {
      counterElement.innerHTML = json.vote_all.toLocaleString()
      run()
    })
}
