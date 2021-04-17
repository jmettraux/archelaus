
// pre.scad

hexd = 10;
hexr = hexd / 2;
sea_hex_ele = 2;
ele_factor = 1.1;

function hei(ele) = sea_hex_ele + 1 + ele * ele_factor / 10;

module hex(x, y, ele) {

  xx = (x * hexd) + ((y % 2 == 0) ? 0 : hexr);
  yy = -y * hexd;
  h = hei(ele);

  translate([ xx, yy, 0 ])
    rotate([ 0, 0, 90 ])
      cylinder(d=hexd * 1.3, h=h, $fn=6);
};

module shex(x, y) {

  xx = (x * hexd) + ((y % 2 == 0) ? 0 : hexr);
  yy = -y * hexd;
  h = sea_hex_ele;

  color("RoyalBlue", 1.0) {
    translate([ xx, yy, 0 ])
      rotate([ 0, 0, 90 ])
        cylinder(d=hexd * 1.3, h=h, $fn=6);
  }
};

// ...

