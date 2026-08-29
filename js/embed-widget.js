(function () {
  var FEED_URL = 'https://edebiyatyarismalari.com/yarismalar.json';
  var STYLE_ID = 'edyw-embed-style';

  var scriptEl = document.currentScript;
  if (!scriptEl) return;

  var count = parseInt(scriptEl.getAttribute('data-count'), 10);
  if (!count || count < 1) count = 5;
  var tip = (scriptEl.getAttribute('data-tip') || '').trim();
  var baslik = scriptEl.getAttribute('data-baslik') || '';

  var container = document.createElement('div');
  container.className = 'edyw-widget';
  scriptEl.parentNode.insertBefore(container, scriptEl.nextSibling);

  injectStyle();

  fetch(FEED_URL)
    .then(function (res) {
      if (!res.ok) throw new Error('network');
      return res.json();
    })
    .then(function (items) {
      render(Array.isArray(items) ? items : []);
    })
    .catch(function () {
      container.remove();
    });

  function render(items) {
    if (tip) {
      var needle = tip.toLocaleLowerCase('tr');
      items = items.filter(function (item) {
        return Array.isArray(item.tags) && item.tags.some(function (t) {
          return String(t).toLocaleLowerCase('tr') === needle;
        });
      });
    }

    items = items.slice(0, count);

    if (!items.length) {
      container.remove();
      return;
    }

    var html = '';

    if (baslik) {
      html += '<h3 class="edyw-widget__title">' + escapeHtml(baslik) + '</h3>';
    }

    html += '<ul class="edyw-widget__list">';
    items.forEach(function (item) {
      html += '<li class="edyw-widget__item">';
      html += '<a href="' + escapeHtml(item.url || '#') + '" rel="nofollow sponsored noopener" target="_blank">' + escapeHtml(item.title || '') + '</a>';
      if (item.dateHuman) {
        html += '<span class="edyw-widget__date">Son başvuru: ' + escapeHtml(item.dateHuman) + '</span>';
      }
      if (item.totalPrize) {
        html += '<span class="edyw-widget__prize">Ödül: ' + escapeHtml(item.totalPrize) + '</span>';
      }
      html += '</li>';
    });
    html += '</ul>';

    html += '<p class="edyw-widget__credit">Kaynak: <a href="https://edebiyatyarismalari.com" rel="nofollow sponsored noopener" target="_blank">edebiyatyarismalari.com</a></p>';

    container.innerHTML = html;
  }

  function escapeHtml(str) {
    return String(str).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function injectStyle() {
    if (document.getElementById(STYLE_ID)) return;
    var style = document.createElement('style');
    style.id = STYLE_ID;
    style.textContent =
      '.edyw-widget{font-family:inherit;margin:1em 0}' +
      '.edyw-widget__title{margin:0 0 .5em}' +
      '.edyw-widget__list{list-style:none;margin:0;padding:0}' +
      '.edyw-widget__item{padding:.5em 0;border-bottom:1px solid rgba(0,0,0,.1)}' +
      '.edyw-widget__item:last-child{border-bottom:none}' +
      '.edyw-widget__date{display:block;font-size:.85em;opacity:.75}' +
      '.edyw-widget__prize{display:block;font-size:.85em;font-weight:600}' +
      '.edyw-widget__credit{margin-top:.75em;font-size:.8em;opacity:.7}';
    document.head.appendChild(style);
  }
})();
