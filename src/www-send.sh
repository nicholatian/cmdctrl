#!/bin/sh

echo=/bin/echo; # avoid shell builtins
command -v gecho 2>&1 >/dev/null && echo=gecho; # for macOS
command -v stdbuf 2>&1 >/dev/null && echo="stdbuf -o0 ${echo}";
test=test;
command -v gtest 2>&1 >/dev/null && test=gtest;

${test} "$1" = '' && {
	${echo} 'Must provide at least one host to propagate to.';
	${echo} 'Exiting...';
	exit 127;
};

command -v rsync 2>&1 >/dev/null || {
	${echo} 'rsync is required to run this script. Exiting...';
	exit 127;
};

for arg in "$@"; do
	rsync -aze 'ssh -qi "/var/cache/httpsync/.ssh/httpsync"' \
		/var/cache/httpsync/public \
		"httpsync@$arg:/var/cache/httpsync/"
done
