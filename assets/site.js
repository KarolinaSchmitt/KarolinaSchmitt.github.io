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
    function atBottom() {
      var d = document.documentElement;
      return window.innerHeight + window.pageYOffset >= d.scrollHeight - 2;
    }
    function paint() {
      var current = null;
      items.forEach(function (it) { if (it.on) current = it; });
      if (atBottom()) current = items[items.length - 1];
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
    window.addEventListener('scroll', paint, { passive: true });
  }

  function initTheme() {
    var root = document.documentElement;
    var btn = document.getElementById('theme-toggle');
    // The saved choice is applied by the inline script in <head> (no flash).
    if (!btn) return;
    function isDark() {
      return root.dataset.theme
        ? root.dataset.theme === 'dark'
        : !!(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    }
    function sync() { btn.setAttribute('aria-pressed', isDark() ? 'true' : 'false'); }
    sync();
    btn.addEventListener('click', function () {
      var next = isDark() ? 'light' : 'dark';
      root.dataset.theme = next;
      try { localStorage.setItem('theme', next); } catch (e) {}
      sync();
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initMenu();
    initTheme();
  });
})();
