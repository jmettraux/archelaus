
lnf:
	bin/generate NW 55.70012 -1.93233 > var/public/lindisfarne.html
rhb:
	bin/generate NW 54.44860 -0.62332 > var/public/robin_hood_bay.html

# ospa | buskoyna
#      |
#      | olderoyna
#
ospa:
	bin/generate NW 61.22800 4.68197 > var/public/no_ospa.html
buskoyna:
	bin/generate NW 61.22410 4.85085 > var/public/no_buskoyna.html
olderoyna:
	bin/generate NW 61.13005 4.67880 > var/public/no_olderoyna.html


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

