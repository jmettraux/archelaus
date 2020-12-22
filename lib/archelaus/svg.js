
var clog = console.log;

var svg = document.getElementById('svg-map');
var menu = document.getElementById('menu');
var help = document.getElementById('help');

var xyinc = 1000;
var zinc = 100;

function getViewBox() {

  var vb = svg.getAttribute('viewBox');
  var m = vb.match(/(.+) (.+) (.+) (.+)/);

  return {
    x: parseFloat(m[1]), y: parseFloat(m[2]),
    w: parseFloat(m[3]), h: parseFloat(m[4]) }
};

function setViewBox(x, y, w, h) {

  var b = getViewBox();
  if (x === null || y === null) { x = b.x; y = b.y; }
  if (w === undefined || h === undefined) { w = b.w; h = b.h; }

  if (w < 10) w = 10;
  if (h < 10) h = 10;

  svg.setAttribute('viewBox', '' + x + ' ' + y + ' ' + w + ' ' + h);
};

document.body.addEventListener('keyup', function(ev) {

  var vb = getViewBox();

  var c = ev.keyCode;
  var k = ev.key;
       if (c === 72) { vb.x = vb.x - xyinc; }
  else if (c === 74) { vb.y = vb.y + xyinc; }
  else if (c === 75) { vb.y = vb.y - xyinc; }
  else if (c === 76) { vb.x = vb.x + xyinc; }
  else if (c === 37) { vb.x = vb.x - (xyinc / 10); }
  else if (c === 39) { vb.x = vb.x + (xyinc / 10); }
  else if (c === 38) { vb.y = vb.y - (xyinc / 10); }
  else if (c === 40) { vb.y = vb.y + (xyinc / 10); }
  else if ((c === 186 && k === ':') || c === 34) {
    vb.w = vb.w + zinc; vb.h = vb.h + zinc; }
  else if (c === 186 || c === 33) {
    vb.w = vb.w - zinc; vb.h = vb.h - zinc; }
  else if (k === '?') {
    help.style.display = help.style.display === 'block' ? 'none' : 'block'; }
  else {
    clog(ev);
    clog(c); return; }

  setViewBox(vb.x, vb.y, vb.w, vb.h);
});

function locate(ev) {

  var vb = getViewBox();

  var c = { w: svg.clientWidth, h: svg.clientHeight };

  var ctos = vb.w / c.w;
  var s = { w: vb.w, h: c.h * ctos, ctos: ctos };

  var pt = svg.createSVGPoint(); pt.x = ev.clientX; pt.y = ev.clientY;
  var xy = pt.matrixTransform(svg.getScreenCTM().inverse());
  pt = { x: pt.x, y: pt.y };

  return { box: vb, c: c, s: s, cpoint: pt, spoint: xy };
}

svg.addEventListener('mousemove', function(ev) {

  var ta = ev.target;
  var es = ta.getAttribute('data-ll'); es = es && es.split(' ');
  var t = ta.getAttribute('data-t') || null;
  var x = '0.0'; var y = '0.0';

  try {
    x = parseFloat(ta.getAttribute('x')).toFixed(1);
    y = parseFloat(ta.getAttribute('y')).toFixed(1);
  } catch(err) {}

  if (es) {
    menu.querySelector('.xy').textContent =
      es[0].replace(/,/, '/') + ' ' + x + 'm/' + y + 'm wi' +
      svg.getAttribute('viewBox').split(' ')[2] + 'm';
    menu.querySelector('.latlon').textContent =
      es[1] + ' ' + es[2];
    menu.querySelector('.elevation').textContent =
      (es[3] === 's') ? 'sea' : ('ele ' + es[3] + 'm');
  }
  var te = menu.querySelector('.text')
  te.style.opacity = 0; if (t) { te.textContent = t; te.style.opacity = 1; }
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

  clog('c', ev);
};

svg.addEventListener('mousedown', function(ev) {
  svg._mouse_down = locate(ev);
});
svg.addEventListener('mousemove', function(ev) {
  if ( ! svg._mouse_down) return;
  svg._mouse_moving = true;
  onDrag(ev);
});
svg.addEventListener('mouseup', function(ev) {
  if ( ! svg._mouse_moving) onClick(ev);
  else onDrag(ev);
  svg._mouse_down = null;
  svg._mouse_moving = null;
});

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

document.querySelector('#menu .nav .nw').addEventListener(
  'click',
  function(ev) {
    setViewBox(0, 0); });
document.querySelector('#menu .nav .ne').addEventListener(
  'click',
  function(ev) {
    var b = getViewBox();
    setViewBox(window._east - b.w, 0); });
document.querySelector('#menu .nav .sw').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    setViewBox(0, window._south - l.s.h); });
document.querySelector('#menu .nav .se').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    setViewBox(window._east - l.s.w, window._south - l.s.h); });
document.querySelector('#menu .nav .c').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    setViewBox((window._east - l.s.w) / 2, (window._south - l.s.h) / 2); });
document.querySelector('#menu .nav .zall').addEventListener(
  'click',
  function(ev) {
    var l = locate(ev);
    var r = l.c.w / l.c.h;
    var h = window._south * r + 250;
    setViewBox(-100, -100, h, h); });
document.querySelector('#menu .nav .z1km').addEventListener(
  'click',
  function(ev) {
    setViewBox(null, null, 2000, 2000); });

//clog('e', window._east, 'w', window._south);

function setNorthwest(ev) {

  var m = ev.newURL.match(/#(.+)/);
  if ( ! m) return;

  var es = m[1].split(/[,\/]/);
  var xy = es[0] + ',' + es[1];

  var hex =
    Array.from(svg.querySelectorAll('use[href="#h"]'))
      .find(function(h) {
        return h.getAttribute('data-ll').split(' ')[0] === xy; });
  if ( ! hex) return;

  setViewBox(
    parseFloat(hex.getAttribute('x')) - 60,
    parseFloat(hex.getAttribute('y')) - 60,
    es[2], es[2]);
};

window.onhashchange = setNorthwest;

//function onDocumentReady(f) {
//  if (document.readyState != 'loading') f();
//  else document.addEventListener('DOMContentLoaded', f);
//};
//onDocumentReady(
//  function() { setNorthwest({ newURL: window.location.hash }); });

setNorthwest({ newURL: window.location.hash });

