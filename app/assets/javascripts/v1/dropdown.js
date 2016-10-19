(function() {
    if (typeof NodeList.prototype.forEach === "undefined") {
        NodeList.prototype.forEach = Array.prototype.forEach;
    }

    if (typeof HTMLCollection.prototype.forEach === "undefined") {
        HTMLCollection.prototype.forEach = Array.prototype.forEach;
    }
})();

const dropdowns = document.querySelectorAll('[dropdown]')

dropdowns.forEach(function(dropdown) {
  dropdown.addEventListener('click', handleOnClick)
})

function handleOnClick(event) {
  console.log(event)
  event.currentTarget.classList.toggle('dropdown-open')
}
