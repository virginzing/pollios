const dropdowns = document.querySelectorAll('[dropdown]')

dropdowns.forEach(function(dropdown) {
  dropdown.addEventListener('click', handleOnClick)
})

function handleOnClick(event) {
  event.currentTarget.classList.toggle('dropdown-open')
}
