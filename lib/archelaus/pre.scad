
// pre.scad

hexd = 10;
hexr = hexd / 2;
sea_hex_ele = 2;
ele_factor = 1.1;

function hei(ele) = sea_hex_ele + 1 + ele * ele_factor / 10;

module _hex(x, y, h) {
  xx = (x * hexd) + ((y % 2 == 0) ? 0 : hexr);
  yy = -y * hexd;
  translate([ xx, yy, 0 ])
    rotate([ 0, 0, 90 ])
      cylinder(d=hexd * 1.3, h=h, $fn=6);
};

module hex(x, y, ele) { _hex(x, y, hei(ele)); };
module shex(x, y) { _hex(x, y, sea_hex_ele); };

module sea(x0, y0, x1, y1) {
  color("RoyalBlue", 1.0) hull() {
    shex(x0, y0);
    shex(x0, y1);
    shex(x1, y1);
    shex(x1, y0);
  }
};

// ...

