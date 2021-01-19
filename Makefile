
lnf:
	bin/generate NW 55.70012 -1.93233 > var/public/lindisfarne.html
rhb:
	bin/generate NW 54.44860 -0.62332 > var/public/robin_hood_bay.html

fetche:
	bin/fetche NW 55.70012 -1.93233
fetchf:
	bin/fetchf NW 55.70012 -1.93233

d:
	scp var/public/robin_hood_bay.html shooto:/var/www/htdocs/weaver.skepti.ch/rhb.html

serve:
	ruby -run -ehttpd var/public/ -p7001
s: serve


.PHONY: serve d

