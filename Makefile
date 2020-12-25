
serve:
	ruby -run -ehttpd var/public/ -p7001
s: serve


.PHONY: serve

