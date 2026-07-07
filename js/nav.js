(function () {
  function closeAllDropdowns() {
    document.querySelectorAll('.dropdown-menu.show').forEach(function (menu) {
      menu.classList.remove('show');
      var toggle = menu.previousElementSibling;
      if (toggle) toggle.setAttribute('aria-expanded', 'false');
    });
  }

  document.querySelectorAll('[data-toggle="dropdown"]').forEach(function (toggle) {
    toggle.addEventListener('click', function (e) {
      e.preventDefault();
      e.stopPropagation();
      var menu = toggle.nextElementSibling;
      if (!menu || !menu.classList.contains('dropdown-menu')) return;
      var isOpen = menu.classList.contains('show');
      closeAllDropdowns();
      if (!isOpen) {
        menu.classList.add('show');
        toggle.setAttribute('aria-expanded', 'true');
      }
    });
  });

  document.querySelectorAll('[data-toggle="collapse"]').forEach(function (toggle) {
    var target = document.querySelector(toggle.getAttribute('data-target'));
    if (!target) return;
    toggle.addEventListener('click', function (e) {
      e.stopPropagation();
      target.classList.toggle('show');
      toggle.setAttribute('aria-expanded', target.classList.contains('show'));
    });
  });

  document.addEventListener('click', closeAllDropdowns);
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeAllDropdowns();
  });
})();
