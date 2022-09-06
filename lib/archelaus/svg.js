
var clog = console.log;
var cerr = console.err;

function elt(start, sel) {
  if ( ! sel) { sel = start; start = null; }
  if ( ! start && typeof sel !== 'string') return sel;
  return (start || document).querySelector(sel); }
function elts(start, sel) {
  if ( ! sel) { sel = start; start = null; }
  if ( ! start && typeof sel !== 'string') return [ sel ];
  return Array.from((start || document).querySelectorAll(sel)); }
function on(start, sel, eventName, callback) {
  if (typeof eventName == 'function') {
    callback = eventName; eventName = sel; sel = start; start = null; }
  var es = elts(start, sel);
  es.forEach(function(e) { e.addEventListener(eventName, callback); });
  return es; }
function toggleHidden(start, sel) {
  var e = elt(start, sel);
  if ( ! e) return;
  if (e.className.match(/hidden/)) e.classList.remove('hidden');
  else e.classList.add('hidden'); }
    //
    // from https://github.com/jmettraux/h.js

function createSvgElement(parent, tagName, attributes, text) {

  if (typeof parent === 'string') {
    text = attributes; attributes = tagName; tagName = parent; parent = svg; }

  var e = document.createElementNS('http://www.w3.org/2000/svg', tagName);

  Object.keys(attributes).forEach(
    function(k) { e.setAttributeNS(null, k, attributes[k]); });

  if (text) e.appendChild(document.createTextNode(text));
  if (parent) parent.appendChild(e);

  return e;
}

var svg = elt('#svg-map');
var menu = elt('#menu');
var help = elt('#help');

svg._rulers = [];

var xyinc = 1000;
var zinc = 100;

function getViewBox() {

  var vb = svg.getAttribute('viewBox');
  var m = vb.match(/(.+) (.+) (.+) (.+)/);

  var x = parseFloat(m[1]); var y = parseFloat(m[2]);
  var w = parseFloat(m[3]); var h = parseFloat(m[4]);

  var ctos = w / svg.clientWidth;
  var rh = svg.clientHeight * ctos;

  return { x: x, y: y, w: w, h: h, ctos: ctos, rh: rh };
}

function setViewBox(x, y, w, h) {

  var b = getViewBox();
  if (x === null || y === null) { x = b.x; y = b.y; }
  if (w === undefined || h === undefined) { w = b.w; h = b.h; }

  if (w < 10) w = 10;
  if (h < 10) h = 10;
  w = Math.ceil(w);
  h = Math.ceil(h);

  svg.setAttribute('viewBox', '' + x + ' ' + y + ' ' + w + ' ' + h);

  svg.classList.remove('z100', 'z75', 'z50', 'z25', 'z0');
    //
  if (w > window._east) { svg.classList.add('z100'); }
  else if (w > window._east * 0.75) { svg.classList.add('z75'); }
  else if (w > window._east * 0.5) { svg.classList.add('z50'); }
  else if (w > window._east * 0.25) { svg.classList.add('z25'); }
  else { svg.classList.add('z0'); }
}

function findHex(x, y) { return elt(svg, '#h_' + x + '_' + y); }

function setNorthwest(ev) {

  var m = ev.newURL.match(/#(.+)/);

  if ( ! m) return setViewBox(null, null);

  var es = m[1].split(/[,\/]/);

  //var hex = findHex(es[0], es[1]);
  //if ( ! hex) return;
    //
  //var rx = parseFloat(hex.getAttribute('x')) / es[0];
  //var ry = parseFloat(hex.getAttribute('y')) / es[1];
  //clog('x', es[0], '-->', parseFloat(hex.getAttribute('x')), rx);
  //clog('y', es[1], '-->', parseFloat(hex.getAttribute('y')), ry);
    //
  //setViewBox(
  //  parseFloat(hex.getAttribute('x')) - 60,
  //  parseFloat(hex.getAttribute('y')) - 60,
  //  es[2], es[2]);

  setViewBox(
    parseFloat(es[0]) * 100,
    parseFloat(es[1]) * 86.60254037844386,
    es[2], es[2]);
}

setNorthwest({ newURL: window.location.hash });

function kuEsc(ev) {

  if (help.style.display === 'block') {
    help.style.display = 'none';
  }
  else {
    var e = elt(svg, '.cursor');
    if (e) e.classList.remove('cursor');
    svg._rulers = [];
  }
}

function kuViCursor(ev, e) {

  var p = getXy(e);

  var c = ev.keyCode;
       if (c === 72) { p.x = p.x - 1; }
  else if (c === 76) { p.x = p.x + 1; }
  else if (c === 75) { p.y = p.y - 1; }
  else if (c === 74) { p.y = p.y + 1; }

  if (p.x < 0) p.x = 0; else if (p.x >= window._max_x) p.x = window._max_x - 1;
  if (p.y < 0) p.y = 0; else if (p.y >= window._max_y) p.x = window._max_y - 1;

  var e1 = findHex(p.x, p.y); if ( ! e1) return;

  e.classList.remove('cursor');
  e1.classList.add('cursor');

  updateMenuText(e1);

  if (svg._followCursor) kuCenter(ev);
}

function kuViFree(ev) {

  var vb = getViewBox();
  var c = ev.keyCode;
       if (c === 72) { vb.x = vb.x - xyinc; }
  else if (c === 74) { vb.y = vb.y + xyinc; }
  else if (c === 75) { vb.y = vb.y - xyinc; }
  else if (c === 76) { vb.x = vb.x + xyinc; }
  setViewBox(vb.x, vb.y, vb.w, vb.h);
}

function kuVi(ev) {

  var e = elt(svg, '.cursor');
  if (e) kuViCursor(ev, e); else kuViFree(ev);
}

function kuCenter(ev) {

  var e = elt(svg, '.cursor'); if ( ! e) return;

  var vb = getViewBox();
  var x = parseFloat(e.getAttribute('x'));
  var y = parseFloat(e.getAttribute('y'));

  vb.x = x - vb.w / 2; vb.y = y - vb.rh / 2;

  setViewBox(vb.x, vb.y, vb.w, vb.h);
}

function kuColon(ev) {

  var vb = getViewBox();
  var e = elt(svg, '.cursor');

  if (ev.key === ':' && vb.w < 20000) {
    vb.w = vb.w * 2; vb.h = vb.h * 2; vb.rh = vb.rh * 2; }
  else if (ev.key !== ':' && vb.w > 200) {
    vb.w = vb.w / 2; vb.h = vb.h / 2; vb.rh = vb.rh / 2; }

  if (e) {
    var x = parseFloat(e.getAttribute('x'));
    var y = parseFloat(e.getAttribute('y'));
    vb.x = x - vb.w / 2; vb.y = y - vb.rh / 2;
  }

  setViewBox(vb.x, vb.y, vb.w, vb.h);
}

function kuZed(ev) {
  var l = svg._rulers.splice(-1)[0];
  if (l) l.ruler.remove();
}

function kuClear() {
  svg._rulers.forEach(function(l) { l.ruler.remove(); });
  svg._rulers = [];
}
function kuShiftClear() {
  kuClear();
  elts(svg, 'g.ruler').forEach(function(e) { e.remove(); });
  elts(svg, 'g.cursor').forEach(function(e) { e.remove(); });
}

function kuToggleHelp() {
  help.style.display = help.style.display === 'block' ? 'none' : 'block';
}
function kuToggleMenu() {
  menu.style.display = menu.style.display === 'flex' ? 'none' : 'flex';
}

function makeStyleToggler(id, style) {
  return function() {
    var e = elt('#' + id); if (e) { e.remove(); return; }
    e = document.createElement('style'); e.id = id; e.innerHTML = style;
    document.body.appendChild(e);
  };
}
var kuToggleSea = makeStyleToggler(
  'seaoff',
  'use[href="#h"].s { stroke: white; }');
var kuToggleAlt = makeStyleToggler(
  'altoff',
  'use[href="#sea"]   { stroke: grey; } ' +
  'use[href="#ssea"]  { stroke: grey; } ' +
  'use[href="#sswa"]  { stroke: grey; } ' +
  'use[href="#swa"]   { stroke: grey; } ' +
  'use[href="#snwa"]  { stroke: grey; } ' +
  'use[href="#snea"]  { stroke: grey; } ' +
  'use[href="#seb"]   { stroke: grey; } ' +
  'use[href="#sseb"]  { stroke: grey; } ' +
  'use[href="#sswb"]  { stroke: grey; } ' +
  'use[href="#swb"]   { stroke: grey; } ' +
  'use[href="#snwb"]  { stroke: grey; } ' +
  'use[href="#sneb"]  { stroke: grey; } ' +
  'use[href="#sec"]   { stroke: grey; } ' +
  'use[href="#ssec"]  { stroke: grey; } ' +
  'use[href="#sswc"]  { stroke: grey; } ' +
  'use[href="#swc"]   { stroke: grey; } ' +
  'use[href="#snwc"]  { stroke: grey; } ' +
  'use[href="#snec"]  { stroke: grey; } ' +
  'use[href="#h"]:not(.s)  { stroke: grey; }');
var kuToggleSlope = makeStyleToggler(
  'slopeoff',
  'path.slope { stroke: none; } ' +
  'use[href="#h"].g { stroke: lightgrey; } ' +
  'use[href="#h"].s { stroke: none; } ');


on(document.body, 'keyup', function(ev) {

  var c = ev.keyCode;
  var k = ev.key;
//clog(c, k);

  if (c === 27) return kuEsc(ev);
  if (c === 72 || c === 74 || c === 75 || c === 76) return kuVi(ev);
  if (k === ':' || k === ';') return kuColon(ev);
  if (k === '?') return kuToggleHelp();
  if (k === 'q') return kuToggleMenu();
  if (k === 'c') return kuCenter(ev);
  if (k === 'z') return kuZed(ev);
  if (k === 'X') return kuShiftClear();
  if (k === 'x') return kuClear();

  if (k === 's') return kuToggleSea();
  if (k === 'a') return kuToggleAlt();
  if (k === 'w') return kuToggleSlope();

  var vb = getViewBox();

       if (c === 37) { vb.x = vb.x - (xyinc / 10); }
  else if (c === 39) { vb.x = vb.x + (xyinc / 10); }
  else if (c === 38) { vb.y = vb.y - (xyinc / 10); }
  else if (c === 40) { vb.y = vb.y + (xyinc / 10); }
  else if (c === 34 || k === '[') { vb.w = vb.w + zinc; vb.h = vb.w; }
  else if (c === 33 || k === ']') { vb.w = vb.w - zinc; vb.h = vb.w; }
  else if (k === 'C') { svg._followCursor = ! svg._followCursor; }
  else { clog(ev); clog(c, k); return; }

  setViewBox(vb.x, vb.y, vb.w, vb.h);
});

var lastTouch = null;

function locate(ev) {

  var vb = getViewBox();

  var s = { w: vb.w, h: vb.rh, ctos: vb.ctos };

  var c = { w: svg.clientWidth, h: svg.clientHeight };

  if (ev.touches && ev.touches.length > 0) lastTouch = ev.touches[0];
  var cx = ev.clientX || lastTouch.clientX;
  var cy = ev.clientY || lastTouch.clientY;

  var pt = svg.createSVGPoint(); pt.x = cx; pt.y = cy;
  var xy = pt.matrixTransform(svg.getScreenCTM().inverse());
  pt = { x: cx, y: cy };

  return { box: vb, c: c, s: s, cpoint: pt, spoint: xy };
}

function updateMenuText(ta) {

  var h = window._hexes[ta.id];
  var t = ta.getAttribute('data-t') || null;

  var x = '0.0', y = '0.0'; try {
    x = parseFloat(ta.getAttribute('x')).toFixed(1);
    y = parseFloat(ta.getAttribute('y')).toFixed(1); } catch(err) {}

  if (h) {

    var wi = parseInt(svg.getAttribute('viewBox').split(' ')[2]);

    elt(menu, '.xy').textContent =
      '' + h.x + '/' + h.y + ' ' + x + 'm/' + y + 'm wi' + wi + 'm';
    elt(menu, '.latlon').textContent =
      h.lat + ' ' + h.lon;
    elt(menu, '.elevation').textContent =
      (h.ele === 's') ? 'sea' : ('ele ' + h.ele + 'm');
  }
  var te = elt(menu, '.text')
  te.style.opacity = 0; if (t) { te.textContent = t; te.style.opacity = 1; }
}

on(svg, 'mousemove', function(ev) {

  if ( ! elt(svg, '.cursor')) updateMenuText(ev.target);
});

function onDrag(ev) {

  var d0 = svg._mouse_down;
  var d1 = locate(ev);

  var b = d0.box;
  var r = d0.s.ctos;

  var dsx = (d1.cpoint.x - d0.cpoint.x) * r;
  var dsy = (d1.cpoint.y - d0.cpoint.y) * r;

  setViewBox(b.x - dsx, b.y - dsy, b.w, b.h);
}

function onClick(ev) {

  var ta = ev.target;
  if ( ! ta.matches('use[href="#h"]')) return;

//  var pre = elt(svg, '.cursor');
//  if (pre) pre.classList.remove('cursor');
//  if (pre !== ta) ta.classList.add('cursor');
//  updateMenuText(ta);

  var pre = elt(svg, '.cursor');
  var l = svg._rulers.slice(-1)[0] || { end: pre, sum: 0, ruler: null };

  if (l.end) {

    var b = getViewBox();

    var x0 = parseFloat(l.end.getAttribute('x'));
    var y0 = parseFloat(l.end.getAttribute('y'));
    var x1 = parseFloat(ta.getAttribute('x'));
    var y1 = parseFloat(ta.getAttribute('y'));

    var pa0 = 'M ' + x0 + ' ' + y0 + ' L ' + x1 + ' ' + y1;

    var dx = x1 - x0; var dy = y1 - y0;
    var m = Math.round(Math.sqrt(dx * dx + dy * dy));
    var ra = Math.atan2(dy, dx);
    var da = ra * 180 / Math.PI;

    var i = Date.now();

    var g = createSvgElement(svg, 'g', { class: 'ruler', id: 'g' + i });
    var g1 = createSvgElement(g, 'g', {});

    createSvgElement(
      g1, 'path', { d: 'M ' + x0 + ' ' + y0 + ' L ' + (x0 + m) + ' ' + y0 });

    var d = '';
    for (var dh = 0; dh <= m; dh = dh + 100) {
      if (dh === 0) continue;
      d = d + ' M ' + (x0 + dh) + ' ' + y0 + ' v -15 v 30';
    }
    createSvgElement(g1, 'path', { d: d });

    g1.setAttribute('transform', 'rotate(' + da + ' ' + x0 + ' ' + y0 +')');

    var t = '' + m + 'm';// + da + 'd';
    var ts = '' + ((l.sum + m) / 1000).toFixed(1) + 'km';
    var tx = dx < 0 ? -50 : 15; var ty = dy < 0 ? -10 : 15;
//clog('x', dx, dy, 't', tx, ty);
    createSvgElement(g, 'text', { x: x1 + tx, y: y1 + ty }, t);
    createSvgElement(g, 'text', { x: x1 + tx, y: y1 + ty + 15 }, ts);

    svg._rulers.push({ end: ta, sum: l.sum + m, ruler: g });
  }
  else if (pre !== ta) {
    ta.classList.add('cursor');
  }
}

function down(ev) {
  svg._mouse_down = locate(ev);
}
function move(ev) {
  if ( ! svg._mouse_down) return;
  svg._mouse_moving = true;
  onDrag(ev);
}
function up(ev) {
  if ( ! svg._mouse_moving) onClick(ev);
  else onDrag(ev);
  svg._mouse_down = null;
  svg._mouse_moving = null;
}

on(svg, 'mousedown', down);
on(svg, 'mousemove', move);
on(svg, 'mouseup', up);
on(svg, 'touchstart', down);
  //
on(svg, 'touchmove', move);
on(svg, 'touchend', up);
on(svg, 'touchcancel', up);

on(svg, 'wheel', function(ev) {

  var l0 = locate(ev);
  var b = l0.box;
  //var d = ev.wheelDelta < 0 ? zinc : -zinc;
  var d = - ev.wheelDelta;

  setViewBox(b.x, b.y, b.w + d, b.h + d);

  var l1 = locate(ev);
  var dsx = (l1.spoint.x - l0.spoint.x);
  var dsy = (l1.spoint.y - l0.spoint.y);
//clog(dsx, dsy);
  var b = l1.box;

  setViewBox(b.x - dsx, b.y - dsy, b.w, b.h);
});

function zall(ev) {
  var l = locate(ev);
  var r = l.c.w / l.c.h;
  var h = window._south * r + 250;
  setViewBox(-100, -100, h, h);
}

var mnu = elt('#menu');
var nav = elt(mnu, '.nav');

on(nav, '.nw', 'click', function(ev) {
  setViewBox(0, 0); });
on(nav, '.ne', 'click', function(ev) {
  var b = getViewBox();
  setViewBox(window._east - b.w, 0); });
on(nav, '.sw', 'click', function(ev) {
  var l = locate(ev);
  setViewBox(0, window._south - l.s.h); });
on(nav, '.se', 'click', function(ev) {
  var l = locate(ev);
  setViewBox(window._east - l.s.w, window._south - l.s.h); });
on(nav, '.c', 'click', function(ev) {
  var l = locate(ev);
  setViewBox((window._east - l.s.w) / 2, (window._south - l.s.h) / 2); });
on(nav, '.zall', 'click',
  zall);
on(nav, '.z1km', 'click', function(ev) {
  setViewBox(null, null, 2000, 2000); });

on(mnu, '.latlon', 'click', function(ev) {
  toggleHidden(mnu, '.latlon');
  toggleHidden(mnu, '.latlon-input');
  var ie = elt(mnu, '.latlon-input input');
  ie.value = '';
  ie.focus();
  ev.stopPropagation(); });
on(mnu, '.latlon-input', 'keydown', function(ev) {
  if (ev.code !== 'Enter') return;
  var ss = ev.target.value.split(/[ ,]+/);
  var lat = parseFloat(ss[0]);
  var lon = parseFloat(ss[1]);
  clog([ lat, lon ]);
  var smallest = { d: 9 * 10**9, id: '#nada', v: {} };
  Object.entries(window._hexes)
    .map(function(id_v) {
      var la = lat - id_v[1].lat;
      var lo = lon - id_v[1].lon;
      var c = Math.sqrt(la * la + lo * lo);
      if (c < smallest.d) smallest = { d: c, id: id_v[0], v: id_v[1] };
    })
  var hex = elt('#' + smallest.id);
  hex.classList.add('cursor');
  updateMenuText(hex);
  toggleHidden(mnu, '.latlon');
  toggleHidden(mnu, '.latlon-input');
});

function arrClick(ev) {

  var ta = ev.target;
  var vb = getViewBox(); var x = vb.x; var y = vb.y;

  var a = Math.PI / 3 * 2;
  var fx = 500; var dx = Math.cos(a) * fx; var dy = Math.sin(a) * fx;

       if (ta.classList.contains('e'))  { x = x + fx; }
  else if (ta.classList.contains('w'))  { x = x - fx; }
  else if (ta.classList.contains('ne')) { x = x - dx; y = y - dy }
  else if (ta.classList.contains('se')) { x = x - dx; y = y + dy }
  else if (ta.classList.contains('nw')) { x = x + dx; y = y - dy }
  else if (ta.classList.contains('sw')) { x = x + dx; y = y + dy }

  setViewBox(x, y);
}

function zomClick(ev) {

  var ta = ev.target;
  var vb = getViewBox();
  var w = vb.w * (ta.classList.contains('plus') ? 0.9 : 1.1);
  setViewBox(vb.x, vb.y, w, w);
}

on('#menu .col .arr', 'click', arrClick);
on('#menu .col .zoom', 'click', zomClick);

function getXy(hexe) {

  return window._hexes[hexe.id];
}

window.onhashchange = setNorthwest;

//onDocumentReady(
//  function() { setNorthwest({ newURL: window.location.hash }); });
function onDocumentReady(f) {
  if (document.readyState != 'loading') f();
  else document.addEventListener('DOMContentLoaded', f);
}
onDocumentReady(
  function() {
    zall({ clientX: 1, clientY: 1 });
  });

