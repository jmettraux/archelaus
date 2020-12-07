
t0:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distance(30.19, 71.51, 31.33, 74.21)"
t1:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distance(50.1, -5.0, 58.3, -3.0)"
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_bearing(50.1, -5.0, 58.3, -3.0)"
t2:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_grid(52.204, 0.142, 100, 10, 2)"

