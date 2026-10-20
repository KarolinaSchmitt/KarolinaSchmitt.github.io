/* Karolina Schmitt — menu highlight and theme toggle (progressive enhancement) */
(function () {
  function initMenu() {
    if (!('IntersectionObserver' in window)) return;
    var links = Array.prototype.slice.call(document.querySelectorAll('.menu a[href*="#"]'));
    var items = [];
    links.forEach(function (a) {
      var id = a.getAttribute('href').split('#')[1];
      var el = id && document.getElementById(id);
      if (el) items.push({ a: a, el: el, on: false });
    });
    if (!items.length) return;
    function paint() {
      var current = null;
      items.forEach(function (it) { if (it.on) current = it; });
      items.forEach(function (it) {
        if (it === current) it.a.setAttribute('aria-current', 'true');
        else it.a.removeAttribute('aria-current');
      });
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        items.forEach(function (it) { if (it.el === e.target) it.on = e.isIntersecting; });
      });
      paint();
    }, { rootMargin: '-35% 0px -55% 0px' });
    items.forEach(function (it) { io.observe(it.el); });
  }

  function initTheme() {
    var root = document.documentElement;
    var btn = document.getElementById('theme-toggle');
    try {
      var saved = localStorage.getItem('theme');
      if (saved === 'light' || saved === 'dark') root.dataset.theme = saved;
    } catch (e) {}
    if (!btn) return;
    btn.addEventListener('click', function () {
      var dark = root.dataset.theme
        ? root.dataset.theme === 'dark'
        : window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      var next = dark ? 'light' : 'dark';
      root.dataset.theme = next;
      try { localStorage.setItem('theme', next); } catch (e) {}
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initMenu();
    initTheme();
  });
})();
