#!/usr/bin/env
#

PREFIX  ?= /usr/local
SCRIPTS := \
	src/tls-send.sh \
	src/tls-recv.sh \
	src/www-send.sh \
	src/www-recv.sh

.PHONY:

all: install

install:
	install -m755 -o root -g root $(SCRIPTS) $(PREFIX)/bin
