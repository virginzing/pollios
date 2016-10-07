const dropdowns = document.querySelectorAll('[dropdown]')
console.log(dropdowns)

dropdowns.forEach(function(dropdown) {
  console.log(dropdown)
  dropdown.addEventListener('click', handleOnClick)
})

function handleOnClick(event) {
  event.currentTarget.classList.toggle('dropdown-open')
}
