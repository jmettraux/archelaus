
// pre.scad

hexd = 10;
hexr = hexd / 2;

function hei(ele) = 1 + ele * 1.1 / 10;

module hex(x, y, ele) {

  xx = (x * hexd) + ((y % 2 == 0) ? 0 : hexr);
  yy = -y * hexd;

  translate([ xx, yy, 0 ])
    rotate([ 0, 0, 90 ])
      cylinder(d=hexd * 1.2, h=hei(ele), $fn=6);
};

// ...

