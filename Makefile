
x:
	#@#bin/map NW 61.15005 4.65980 > ~/Downloads/no_olderoyna_nw.html
	#@bin/map NW 61.15005 4.65980 > var/public/no_olderoyna_nw.html
	#bin/map NW 61.09014 4.67187 > var/public/no_ytroygrend.html
	#@bin/genscad NW 61.15005 4.65980
	#bin/genscad NW 61.09473 4.63584 > out.scad
	bin/genscad NW 61.09014 4.67187 > out.scad

lnf:
	bin/generate NW 55.70012 -1.93233 > var/public/lindisfarne.html
rhb:
	bin/generate NW 54.44860 -0.62332 > var/public/robin_hood_bay.html

# ospa      | buskoyna
#           |
# olderoyna |
#
ospa:
	bin/generate NW 61.22800 4.68197 > var/public/no_ospa.html
buskoyna:
	bin/generate NW 61.22410 4.85085 > var/public/no_buskoyna.html
olderoyna:
	bin/generate NW 61.13005 4.67880 > var/public/no_olderoyna.html
olderoyna_north:
	bin/map NW 61.15005 4.67880 > var/public/no_olderoyna_north.html
olderoyna_nw:
	bin/map NW 61.15005 4.65980 > var/public/no_olderoyna_nw.html


fetche:
	bin/fetche NW 55.70012 -1.93233
fetchf:
	bin/fetchf NW 55.70012 -1.93233

liste:
	ruby -Ilib -r make -e "Make.liste"

d:
	scp var/public/robin_hood_bay.html shooto:/var/www/htdocs/weaver.skepti.ch/rhb.html

serve:
	ruby -run -ehttpd var/public/ -p7001
s: serve


.PHONY: serve d

