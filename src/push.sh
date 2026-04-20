#!/bin/sh

echo=/bin/echo; # avoid shell builtins
command -v gecho 2>&1 >/dev/null && echo=gecho; # for macOS
command -v stdbuf 2>&1 >/dev/null && echo="stdbuf -o0 ${echo}";
echop="${echo} -n";
echod="${echo} done.";
rm=rm;
command -v grm 2>&1 >/dev/null && rm=grm;

test "$1" = '' && {
	${echo} '$1 must be the hostname of the destination server to';
	${echo} 'push to. Exiting...';
	exit 127;
};

for _record in $(cat etc/publish.csv); do
	IFS=',' read -r src dst <<< "${_record}";
	${echop} "Uploading $src to $dst... ";
	dstdir="$(dirname "$dst")";
	ssh -q "httpsync@$1" -- \
		mkdir -p "/var/cache/httpsync/public/$dstdir";
	rsync -ze 'ssh -q' -lptgoD "$src" \
		"httpsync@$1:/var/cache/httpsync/public/$dst";
	${echod};
done
