(function () {
  var sidebarMenu = document.getElementById("sidebar-menu");
  var closeBtn = document.getElementById("sidebar-close");
  var openBtn = document.getElementById("sidebar-open");
  openBtn.onclick = function (e) {
    if (sidebarMenu.classList.contains("dismiss")) {
      sidebarMenu.classList.remove("dismiss");
      sidebarMenu.classList.remove("hide");
      sidebarMenu.classList.add("selected");
    }
    e.preventDefault();
  };
  closeBtn.onclick = function (e) {
    if (sidebarMenu.classList.contains("selected")) {
      sidebarMenu.classList.remove("selected");
      sidebarMenu.classList.add("dismiss");
    }
    e.preventDefault();
  };
})();
