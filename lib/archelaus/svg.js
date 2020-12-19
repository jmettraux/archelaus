
var clog = console.log;

var svg = document.getElementById('svg-map');
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

  svg.setAttribute('viewBox', '' + x + ' ' + y + ' ' + w + ' ' + h);
};

document.body.addEventListener('keyup', function(ev) {

  var vb = getViewBox();

  var c = ev.keyCode;
       if (c === 72) { vb.x = vb.x - xyinc; }
  else if (c === 74) { vb.y = vb.y + xyinc; }
  else if (c === 75) { vb.y = vb.y - xyinc; }
  else if (c === 76) { vb.x = vb.x + xyinc; }
  else if (c === 78 || c === 34) { vb.w = vb.w + zinc; vb.h = vb.h + zinc; }
  else if (c === 77 || c === 33) { vb.w = vb.w - zinc; vb.h = vb.h - zinc; }
  else if (c === 37) { vb.x = vb.x - (xyinc / 10); }
  else if (c === 39) { vb.x = vb.x + (xyinc / 10); }
  else if (c === 38) { vb.y = vb.y - (xyinc / 10); }
  else if (c === 40) { vb.y = vb.y + (xyinc / 10); }
  else { clog(c); return; }

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

//svg.addEventListener('click', function(ev) {
//
//  var l = locate(ev);
//clog('c', l);
//
//  //l.box.x = l.spoint.x - l.s.w / 2;
//  //l.box.y = l.spoint.y - l.s.h / 2;
//
//  //svg.setAttribute(
//  //  'viewBox',
//  //  '' + l.box.x + ' ' + l.box.y + ' ' + l.box.w + ' ' + l.box.h);
//});

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

var wheelTimer = null;
var wheelStart = null;
  //
svg.addEventListener('wheel', function(ev) {
  wheelStart = wheelStart || locate(ev);
  var b = getViewBox();
  var d = ev.wheelDelta < 0 ? zinc : -zinc;
  //clog('pre', locate(ev));
  setViewBox(b.x, b.y, b.w + d, b.h + d);
  window.clearTimeout(wheelTimer);
  wheelTimer = window.setTimeout(
    function() {
      var l1 = locate(ev);
      var l0 = wheelStart; wheelStart = null;
//clog('>', l0, l1);
      var dsx = (l1.spoint.x - l0.spoint.x);
      var dsy = (l1.spoint.y - l0.spoint.y);
//clog(dsx, dsy);
      var b = l1.box;
      setViewBox(b.x - dsx, b.y - dsy, b.w, b.h);
    },
    280);
});

//svg.addEventListener('resize', function(ev) {
//  clog(ev);
//});
  // no worky :-( svg2...

