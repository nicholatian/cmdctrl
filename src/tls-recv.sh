#!/bin/sh

test=/bin/test;
command -v gtest 2>&1 >/dev/null && test=gtest;
cp=/bin/cp;
command -v gcp 2>&1 >/dev/null && cp=gcp;
rm=/bin/rm;
command -v grm 2>&1 >/dev/null && cp=grm;

${test} -d /var/cache/httpsync/letsencrypt || exit 0;

${cp} -a /var/cache/httpsync/letsencrypt /etc;
${rm} -rf /var/cache/httpsync/letsencrypt;
