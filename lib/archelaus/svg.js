
var clog = console.log;

var svg = document.getElementById('svg-map');
var inc = 1000;

function getViewBox() {

  var vb = svg.getAttribute('viewBox');
  var m = vb.match(/(-?[0-9]+) (-?[0-9]+) (-?[0-9]+) (-?[0-9]+)/);

  return {
    x: parseInt(m[1], 10), y: parseInt(m[2], 10),
    w: parseInt(m[3], 10), h: parseInt(m[4], 10) }
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

//svg.addEventListener('click', function(ev) {
//
//  var pt = svg.createSVGPoint(); pt.x = ev.clientX; pt.y = ev.clientY;
//  var xy =  pt.matrixTransform(svg.getScreenCTM().inverse());
//
//  //clog(ev.clientX, ev.clientY);
//  //clog(xy.x, xy.y);
//
//  //var vb = getViewBox();
//  //
//  //vb.x = (xy.x - vb.w / 2).toFixed(0);
//  //vb.y = (xy.y - vb.h / 2).toFixed(0);
//  //
//  //svg.setAttribute(
//  //  'viewBox',
//  //  '' + vb.x + ' ' + vb.y + ' ' + vb.w + ' ' + vb.h);
//});

var dstart = null;

function locate(ev) {
  var pt = svg.createSVGPoint(); pt.x = ev.clientX; pt.y = ev.clientY;
  var xy =  pt.matrixTransform(svg.getScreenCTM().inverse());
  return [ pt, xy ];
}

document.body.addEventListener('dragstart', function(ev) {
  dstart = locate(ev);
});
document.body.addEventListener('drag', function(ev) {
  clog('d', dstart, locate(ev));
});
document.body.addEventListener('dragend', function(ev) {
  clog('de', dstart, locate(ev));
});

