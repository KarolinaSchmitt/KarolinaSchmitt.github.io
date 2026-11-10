/* Karolina Schmitt — menu highlight and theme toggle (progressive enhancement) */
(function () {
  function initMenu() {
    // Scroll highlighting only applies on the home page; other pages mark their own current item in the HTML.
    if (!document.getElementById('home')) return;
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


/* Image gallery lightbox: opens the clicked image large on the same page, with the caption,
   a back arrow, previous/next arrows, and keyboard (Esc, left/right) and swipe support. */
(function () {
  var pt = (document.documentElement.lang || 'en').slice(0, 2) === 'pt';
  var T = pt
    ? { back: 'Voltar', prev: 'Imagem anterior', next: 'Próxima imagem', dialog: 'Visualizador de imagens', of: ' de ' }
    : { back: 'Back', prev: 'Previous image', next: 'Next image', dialog: 'Image viewer', of: ' of ' };
  var ARROW_L = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5l-7 7 7 7"/></svg>';
  var ARROW_R = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 5l7 7-7 7"/></svg>';
  var ARROW_BACK = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M19 12H5"/><path d="M11 6l-6 6 6 6"/></svg>';

  var box, imgEl, capEl, countEl, backBtn, prevBtn, nextBtn;
  var items = [], index = 0, opener = null, touchX = null;

  function build() {
    box = document.createElement('div');
    box.className = 'lb';
    box.hidden = true;
    box.setAttribute('role', 'dialog');
    box.setAttribute('aria-modal', 'true');
    box.setAttribute('aria-label', T.dialog);
    box.innerHTML =
      '<button type="button" class="lb-back">' + ARROW_BACK + '<span>' + T.back + '</span></button>' +
      '<span class="lb-count" aria-live="polite"></span>' +
      '<div class="lb-stage">' +
      '<button type="button" class="lb-nav lb-prev" aria-label="' + T.prev + '">' + ARROW_L + '</button>' +
      '<figure class="lb-fig"><img alt=""><figcaption></figcaption></figure>' +
      '<button type="button" class="lb-nav lb-next" aria-label="' + T.next + '">' + ARROW_R + '</button>' +
      '</div>';
    document.body.appendChild(box);
    imgEl = box.querySelector('img');
    capEl = box.querySelector('figcaption');
    countEl = box.querySelector('.lb-count');
    backBtn = box.querySelector('.lb-back');
    prevBtn = box.querySelector('.lb-prev');
    nextBtn = box.querySelector('.lb-next');
    backBtn.addEventListener('click', close);
    prevBtn.addEventListener('click', function () { go(-1); });
    nextBtn.addEventListener('click', function () { go(1); });
    box.addEventListener('click', function (e) {
      if (e.target === box) close();
    });
    box.addEventListener('touchstart', function (e) { touchX = e.touches[0].clientX; }, { passive: true });
    box.addEventListener('touchend', function (e) {
      if (touchX === null) return;
      var dx = e.changedTouches[0].clientX - touchX;
      touchX = null;
      if (Math.abs(dx) > 50) go(dx < 0 ? 1 : -1);
    });
  }

  function show() {
    var it = items[index];
    imgEl.src = it.src;
    imgEl.alt = it.alt;
    var fit = function () { box.classList.toggle('lb-tall', imgEl.naturalHeight > imgEl.naturalWidth); };
    imgEl.onload = fit;
    if (imgEl.complete && imgEl.naturalWidth) fit();
    capEl.textContent = '';
    if (it.caption) {
      var title = document.createElement(it.desc ? 'strong' : 'span');
      title.textContent = it.caption;
      capEl.appendChild(title);
    }
    if (it.desc) {
      var desc = document.createElement('span');
      desc.className = 'lb-desc';
      desc.textContent = it.desc;
      capEl.appendChild(desc);
    }
    capEl.hidden = !it.caption && !it.desc;
    countEl.textContent = items.length > 1 ? (index + 1) + T.of + items.length : '';
    box.classList.toggle('single', items.length < 2);
    // warm the neighbours so the arrows feel instant
    [index - 1, index + 1].forEach(function (i) {
      if (items[(i + items.length) % items.length]) new Image().src = items[(i + items.length) % items.length].src;
    });
  }

  function go(step) {
    if (items.length < 2) return;
    index = (index + step + items.length) % items.length;
    show();
  }

  function open(group, start, trigger) {
    if (!box) build();
    items = group;
    index = start;
    opener = trigger;
    show();
    box.hidden = false;
    document.body.classList.add('lb-open');
    backBtn.focus();
    document.addEventListener('keydown', onKey);
  }

  function close() {
    box.hidden = true;
    document.body.classList.remove('lb-open');
    document.removeEventListener('keydown', onKey);
    if (opener && opener.focus) opener.focus();
  }

  function onKey(e) {
    if (e.key === 'Escape') { e.preventDefault(); close(); }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); go(-1); }
    else if (e.key === 'ArrowRight') { e.preventDefault(); go(1); }
    else if (e.key === 'Tab') {
      var f = Array.prototype.filter.call(box.querySelectorAll('button'), function (b) { return b.offsetParent !== null; });
      if (!f.length) return;
      var first = f[0], last = f[f.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    }
  }

  function init() {
    var galleries = document.querySelectorAll('.shots');
    Array.prototype.forEach.call(galleries, function (gallery) {
      var links = Array.prototype.slice.call(gallery.querySelectorAll('a[data-lightbox]'));
      var group = links.map(function (a) {
        var fig = a.closest('figure');
        var cap = fig && fig.querySelector('figcaption');
        var im = a.querySelector('img');
        return { src: a.getAttribute('href'), alt: (im && im.alt) || '', caption: cap ? cap.textContent.trim() : '', desc: a.getAttribute('data-desc') || '' };
      });
      links.forEach(function (a, i) {
        a.addEventListener('click', function (e) {
          if (e.metaKey || e.ctrlKey || e.shiftKey || e.button === 1) return; // keep "open in new tab" working
          e.preventDefault();
          open(group, i, a);
        });
      });
    });
  }

  document.addEventListener('DOMContentLoaded', init);
})();
