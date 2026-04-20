#!/bin/sh

echo=/bin/echo; # avoid shell builtins
command -v gecho 2>&1 >/dev/null && echo=gecho; # for macOS
command -v stdbuf 2>&1 >/dev/null && echo="stdbuf -o0 ${echo}";
test=/bin/test;
command -v gtest 2>&1 >/dev/null && test=gtest;

${test} "$1" = '' && {
	${echo} '$1 must be the hostname of the destination server to';
	${echo} 'push to. Exiting...';
	exit 127;
};

command -v rsync 2>&1 >/dev/null || {
	${echo} 'rsync is required to run this script. Exiting...';
	exit 127;
};

rsync -aze 'ssh -qi "$HOME/.ssh/httpsync"' /etc/letsencrypt \
	"httpsync@$1:/var/cache/httpsync/"
