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
})()