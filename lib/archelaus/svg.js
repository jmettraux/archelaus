
var clog = console.log;

var svg = document.getElementById('svg-map');
var inc = 1000;

function getViewBox() {

  var vb = svg.getAttribute('viewBox');
  var m = vb.match(/(.+) (.+) (.+) (.+)/);

  return {
    x: parseFloat(m[1]), y: parseFloat(m[2]),
    w: parseFloat(m[3]), h: parseFloat(m[4]) }
};

document.body.addEventListener('keyup', function(ev) {

  var vb = getViewBox();

  var c = ev.keyCode;
       if (c === 72) { vb.x = vb.x - inc; }
  else if (c === 74) { vb.y = vb.y + inc; }
  else if (c === 75) { vb.y = vb.y - inc; }
  else if (c === 76) { vb.x = vb.x + inc; }
  else if (c === 78 || c === 34) { vb.w = vb.w + inc; vb.h = vb.h + inc; }
  else if (c === 77 || c === 33) { vb.w = vb.w - inc; vb.h = vb.h - inc; }
  else if (c === 37) { vb.x = vb.x - (inc / 10); }
  else if (c === 39) { vb.x = vb.x + (inc / 10); }
  else if (c === 38) { vb.y = vb.y - (inc / 10); }
  else if (c === 40) { vb.y = vb.y + (inc / 10); }
  else { clog(c); return; }

  svg.setAttribute(
    'viewBox',
    '' + vb.x + ' ' + vb.y + ' ' + vb.w + ' ' + vb.h);
});

function locate(ev) {

  var vb = getViewBox();

  var c = { w: svg.clientWidth, h: svg.clientHeight };
  var s = { w: vb.w, h: c.h * vb.w / c.w };

  var pt = svg.createSVGPoint(); pt.x = ev.clientX; pt.y = ev.clientY;
  var xy = pt.matrixTransform(svg.getScreenCTM().inverse());
  pt = { x: pt.x, y: pt.y, rx: pt.x / c.w, ry: pt.y / c.h };

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

//var dstart = null;
svg.addEventListener('dragstart', function(ev) {
  //dstart = locate(ev);
  clog('ds', locate(ev));
});
svg.addEventListener('drag', function(ev) {
  clog('d');
  //clog('d', dstart, locate(ev));
});
svg.addEventListener('dragend', function(ev) {
  //clog('de');
  //clog('de', dstart, locate(ev));
  clog('de', locate(ev));
});

