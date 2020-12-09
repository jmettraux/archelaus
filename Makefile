
t0:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distance(30.19, 71.51, 31.33, 74.21)"
t1:
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_distance(50.1, -5.0, 58.3, -3.0)"
	ruby -Ilib -rarchelaus -e "p Archelaus.compute_bearing(50.1, -5.0, 58.3, -3.0)"

tg:
	ruby -Ilib -rpp -rarchelaus -e "pp Archelaus.compute_grid(52.204, 0.142, 100, 10, 5)"

th:
	ruby -Ilib -rarchelaus -e "p Archelaus.http_get('https://reqbin.com/echo/get/json', { s: 'archelaus', t: 'test' })"

tl:
	ruby -Ilib -rarchelaus -e "grid = Archelaus.compute_grid(54.4005, -0.4822, 100, 6, 6); Archelaus.get_elevations(grid)"

