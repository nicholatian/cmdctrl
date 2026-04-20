#!/usr/bin/env
#

PREFIX  ?= /usr/local
SCRIPTS := \
	src/tls-send.sh \
	src/tls-recv.sh \
	src/www-send.sh \
	src/www-recv.sh
SITES   := \
	src/websites/mt.xion.irc.conf

.PHONY:

all: install

install:
	install -m755 $(SCRIPTS) $(PREFIX)/bin
	test -f /etc/nginx/nginx.conf && \
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
	cp -a src/nginx.conf /etc/nginx/nginx.conf
	cp -a src/sslredir.conf /etc/nginx/ssl-redirect.conf
	cp -a src/sitebits.conf /etc/nginx/sitebits.conf
	cp -a src/lets-ssl.conf /etc/nginx/letsencrypt-ssl.conf
	cp -a src/dhparams.pem /etc/nginx/letsencrypt-dhparams.pem
	mkdir -p /etc/nginx/available
	mkdir -p /etc/nginx/enabled
