#!/bin/sh

test=test;
command -v gtest 2>&1 >/dev/null && test=gtest;
cp=/bin/cp;
command -v gcp 2>&1 >/dev/null && cp=gcp;
mv=/bin/mv;
command -v gmv 2>&1 >/dev/null && mv=gmv;
ln=/bin/ln;
command -v gln 2>&1 >/dev/null && ln=gln;
mkdir=/bin/mkdir;
command -v gmkdir 2>&1 >/dev/null && mkdir=gmkdir;
find=/usr/bin/find;
command -v gfind 2>&1 >/dev/null && find=gfind;

zero="$0";
zero="$(cd $(dirname "$zero")/.. && pwd)";

${test} -f /etc/nginx/nginx.conf && \
	${mv} /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak;
${cp} -a src/nginx.conf /etc/nginx/nginx.conf;
${cp} -a src/sslredir.conf /etc/nginx/ssl-redirect.conf;
${cp} -a src/sitebits.conf /etc/nginx/sitebits.conf;
${cp} -a src/lets-ssl.conf /etc/nginx/letsencrypt-ssl.conf;
${cp} -a src/dhparams.pem /etc/nginx/letsencrypt-dhparams.pem;
${mkdir} -p /etc/nginx/available;
${mkdir} -p /etc/nginx/enabled;

CDPATH= cd "$zero/src/websites" || exit 127;
sites="$(${find} -type f -name '*.conf')";

CDPATH= cd /etc/nginx/available || exit 127;
for site in $sites; do
	${cp} "$zero/src/websites/$site" ./;
done
CDPATH= cd ../enabled || exit 127;
for site in $sites; do
	${ln} -sf "../available/$site" "$site";
done

CDPATH= cd "$zero" || exit 127;
