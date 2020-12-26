
d:
	scp var/public/robin_hood_bay.html shooto:/var/www/htdocs/weaver.skepti.ch/rhb.html

serve:
	ruby -run -ehttpd var/public/ -p7001
s: serve


.PHONY: serve d

