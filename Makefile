
t0:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distance(30.19, 71.51, 31.33, 74.21)"
t1:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distance(50.1, -5.0, 58.3, -3.0)"
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_bearing(50.1, -5.0, 58.3, -3.0)"

th:
	ruby -Ilib -rarchelaus -e "p Archelaus.http_get('https://reqbin.com/echo/get/json', { s: 'archelaus', t: 'test' })"

tl:
	ruby -Ilib -rpp -rarchelaus -e "grid = Archelaus.compute_grid(54.4005, -0.4822, 100, 6, 6); pp Archelaus.get_elevations(grid)"

ta:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distances(54.4005, -0.4822, 54.3966, -0.4737)"
to:
	ruby -Ilib -rarchelaus -e "Archelaus.get_elements([ 54.4005, -0.4822 ], [ 54.3966, -0.4737 ])"

