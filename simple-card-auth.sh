#!/bin/sh

die() {
	echo Error.
	exit 1
}

CHAL_FILE=chal.tmp
CERT_FILE=cert.tmp
PUB_KEY_FILE=pub_key.tmp
SIG_FILE=sig.tmp

set -x

pkcs15-tool -w --read-certificate 4 -o $CERT_FILE || die
openssl x509 -pubkey -noout -in $CERT_FILE -out $PUB_KEY_FILE || die

./msecret -i entropy.bin -k test -l 32 --format-bin -o $CHAL_FILE || die

pkcs15-crypt -s -k 4 --sha-256 -w -i $CHAL_FILE -R -o $SIG_FILE || die

openssl dgst -verify $PUB_KEY_FILE -signature $SIG_FILE $CHAL_FILE || die
