
var clog = console.log;
var cerr = console.err;

function elt(start, sel) {
  if ( ! sel) { sel = start; start = null; }
  return (start || document).querySelector(sel); };
function elts(start, sel) {
  if ( ! sel) { sel = start; start = null; }
  return Array.from((start || document).querySelectorAll(sel)); }
    //
    // from https://github.com/jmettraux/h.js

var svg = elt('#svg-map');
var menu = elt('#menu');
var help = elt('#help');

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
};

function setViewBox(x, y, w, h) {

  var b = getViewBox();
  if (x === null || y === null) { x = b.x; y = b.y; }
  if (w === undefined || h === undefined) { w = b.w; h = b.h; }

  if (w < 10) w = 10;
  if (h < 10) h = 10;
  w = Math.ceil(w);
  h = Math.ceil(h);

  svg.setAttribute('viewBox', '' + x + ' ' + y + ' ' + w + ' ' + h);
};

function findHex(x, y) {

  var xy = '' + x + ',' + y;

  return elts(svg, 'use[href="#h"]')
    .find(function(h) {
      return h.getAttribute('data-ll').split(' ')[0] === xy; });
}

function kuEsc(ev) {

  if (help.style.display === 'block') {
    help.style.display = 'none';
  }
  else {
    var e = elt(svg, '.cursor');
    if (e) e.classList.remove('cursor');
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
};

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

function toggleHelp() {
  help.style.display = help.style.display === 'block' ? 'none' : 'block';
}

document.body.addEventListener('keyup', function(ev) {

  var c = ev.keyCode;
  var k = ev.key;

  if (c === 27) return kuEsc(ev);
  if (c === 72 || c === 74 || c === 75 || c === 76) return kuVi(ev);
  if (k === '?') return toggleHelp();
  if (k === 'c') return kuCenter(ev);
  if (c === 186) return kuColon(ev);

  var vb = getViewBox();

       if (c === 37) { vb.x = vb.x - (xyinc / 10); }
  else if (c === 39) { vb.x = vb.x + (xyinc / 10); }
  else if (c === 38) { vb.y = vb.y - (xyinc / 10); }
  else if (c === 40) { vb.y = vb.y + (xyinc / 10); }
  else if (c === 34) { vb.w = vb.w + zinc; vb.h = vb.w; }
  else if (c === 33) { vb.w = vb.w - zinc; vb.h = vb.w; }
  else { clog(ev); clog(c); return; }

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

var updateMenuText = function(ta) {

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

svg.addEventListener('mousemove', function(ev) {

  if ( ! elt(svg, '.cursor')) updateMenuText(ev.target);
});

var onDrag = function(ev) {

  var d0 = svg._mouse_down;
  var d1 = locate(ev);

  var b = d0.box;
  var r = d0.s.ctos;

  var dsx = (d1.cpoint.x - d0.cpoint.x) * r;
  var dsy = (d1.cpoint.y - d0.cpoint.y) * r;

  setViewBox(b.x - dsx, b.y - dsy, b.w, b.h);
};

var onClick = function(ev) {

  var ta = ev.target;
  if ( ! ta.matches('use[href="#h"]')) return;

  var pre = elt(svg, '.cursor');

  if (pre) pre.classList.remove('cursor');
  if (pre !== ta) ta.classList.add('cursor');

  updateMenuText(ta);
};

var down = function(ev) {
  svg._mouse_down = locate(ev);
};
var move = function(ev) {
  if ( ! svg._mouse_down) return;
  svg._mouse_moving = true;
  onDrag(ev);
};
var up = function(ev) {
  if ( ! svg._mouse_moving) onClick(ev);
  else onDrag(ev);
  svg._mouse_down = null;
  svg._mouse_moving = null;
};

svg.addEventListener('mousedown', down);
svg.addEventListener('mousemove', move);
svg.addEventListener('mouseup', up);
svg.addEventListener('touchstart', down);
  //
svg.addEventListener('touchmove', move);
svg.addEventListener('touchend', up);
svg.addEventListener('touchcancel', up);

svg.addEventListener('wheel', function(ev) {

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

var nav = elt('#menu .nav');

elt(nav, '.nw').addEventListener(
  'click',
  function(ev) {
    setViewBox(0, 0); });
elt(nav, '.ne').addEventListener(
  'click',
  function(ev) {
    var b = getViewBox();
    setViewBox(window._east - b.w, 0); });
elt(nav, '.sw').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    setViewBox(0, window._south - l.s.h); });
elt(nav, '.se').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    setViewBox(window._east - l.s.w, window._south - l.s.h); });
elt(nav, '.c').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    setViewBox((window._east - l.s.w) / 2, (window._south - l.s.h) / 2); });
elt(nav, '.zall').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    var r = l.c.w / l.c.h;
    var h = window._south * r + 250;
    setViewBox(-100, -100, h, h); });
elt(nav, '.z1km').addEventListener(
  'click',
  function(ev) {
    setViewBox(null, null, 2000, 2000); });

function arrClick(ev) {

  var ta = ev.target;
  var vb = getViewBox(); var x = vb.x; var y = vb.y;

  var a = Math.PI / 3 * 2;
  var fx = 500; var dx = Math.cos(a) * fx; var dy = Math.sin(a) * fx;

       if (ta.classList.contains('e')) { x = x + fx; }
  else if (ta.classList.contains('w')) { x = x - fx; }
  else if (ta.classList.contains('ne')) { x = x - dx; y = y - dy }
  else if (ta.classList.contains('se')) { x = x - dx; y = y + dy }
  else if (ta.classList.contains('nw')) { x = x + dx; y = y - dy }
  else if (ta.classList.contains('sw')) { x = x + dx; y = y + dy }

  setViewBox(x, y);
};

function zomClick(ev) {

  var ta = ev.target;
  var vb = getViewBox();
  var w = vb.w * (ta.classList.contains('plus') ? 0.9 : 1.1);
  setViewBox(vb.x, vb.y, w, w);
};

elts('#menu .col .arr').forEach(function(e) {
  e.addEventListener('click', arrClick);
});
elts('#menu .col .zoom').forEach(function(e) {
  e.addEventListener('click', zomClick);
});

function setNorthwest(ev) {

  var m = ev.newURL.match(/#(.+)/);
  if ( ! m) return;

  var es = m[1].split(/[,\/]/);

  var hex = findHex(es[0], es[1]);
  if ( ! hex) return;

  setViewBox(
    parseFloat(hex.getAttribute('x')) - 60,
    parseFloat(hex.getAttribute('y')) - 60,
    es[2], es[2]);
};

function getXy(hexe) {

  var xy = hexe.getAttribute('data-ll').split(' ')[0].split(',');
  return { x: parseInt(xy[0], 10), y: parseInt(xy[1], 10) };
};

window.onhashchange = setNorthwest;

//function onDocumentReady(f) {
//  if (document.readyState != 'loading') f();
//  else document.addEventListener('DOMContentLoaded', f);
//};
//onDocumentReady(
//  function() { setNorthwest({ newURL: window.location.hash }); });

setNorthwest({ newURL: window.location.hash });

