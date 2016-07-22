(function() {
  const sidebarButton = document.getElementById('sidebar-button');
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('app-overlay');

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
      .filter((c) => c === 'open')
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
        .filter((c) => c !== 'open')
        .join(' ');
  }

  function closeElement(elm) {
    className = elm.className.split(' ');
    className.push('open');

    elm.className = className.join(' ');
  }
})()