#!/bin/sh

test=test;
command -v gtest 2>&1 >/dev/null && test=gtest;
cp=/bin/cp;
command -v gcp 2>&1 >/dev/null && cp=gcp;
rm=/bin/rm;
command -v grm 2>&1 >/dev/null && cp=grm;

${test} -d /var/cache/httpsync/public || exit 0;

${cp} -a /var/cache/httpsync/public /var/lib/nginx/;
${rm} -rf /var/cache/httpsync/public;
chown nginx:nginx /var/lib/nginx/public;
chmod 750 /var/lib/nginx/public;

service nginx restart;
