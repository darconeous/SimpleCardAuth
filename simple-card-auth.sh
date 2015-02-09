#!/bin/sh

CHAL_FILE=chal.tmp
CHALHASH_FILE=chalhash.tmp
CERT_FILE=cert.pem
PUB_KEY_FILE=pub_key.pem
SIG_FILE=sig.tmp
SIG2_FILE=sig2.tmp
ATR_FILE=ATR.tmp
SUBJECT_DN_FILE=subject-dn.tmp
SERIAL_FILE=serial.tmp
TMP_FILE=temporary.tmp

STRICT_CHECK=1

KEY_ID=4

cleanup() {
	rm $CHAL_FILE 2> /dev/null
	rm $CERT_FILE 2> /dev/null
	rm $CHALHASH_FILE 2> /dev/null
	rm $PUB_KEY_FILE 2> /dev/null
	rm $SIG_FILE 2> /dev/null
	rm $SIG2_FILE 2> /dev/null
	rm $ATR_FILE 2> /dev/null
	rm $SERIAL_FILE 2> /dev/null
	rm $TMP_FILE 2> /dev/null
}

die() {
	echo ""
	echo "ACCESS DENIED."
	cleanup
	exit 1
}

#set -x

# Get ATR
opensc-tool -w -a 2> /dev/null | tee $ATR_FILE || die

# Get Serial
opensc-tool --serial 2> /dev/null | tee $SERIAL_FILE || die

# Extract the certificate
pkcs15-tool --no-prompt --read-certificate $KEY_ID -o $CERT_FILE 2> /dev/null || die

# Verify the certificate
#openssl verify [-CApath directory] [-CAfile file] [-purpose purpose] [-untrusted file] [-help] [-issuer_checks] [-verbose] [-] [certificates]
cat $CERT_FILE | openssl verify -CAfile ca.crt -verbose -purpose sslclient | tee $TMP_FILE || die

[ $STRICT_CHECK = 1 ] && [ "`cat $TMP_FILE`" '!=' "stdin: OK" ] && die

# Print out the subject name
openssl x509 -in $CERT_FILE -nameopt RFC2253 -noout -subject | tee $SUBJECT_DN_FILE || die

# Extract the public key
openssl x509 -pubkey -noout -in $CERT_FILE > $PUB_KEY_FILE || die

# Calculate a challenge
dd if=/dev/random of=$CHAL_FILE bs=32 count=1 2> /dev/null || die

# Calculate the hash of the challenge
openssl sha -sha256 -binary < $CHAL_FILE > $CHALHASH_FILE || die

# Calculate the response for the challenge
if ( openssl x509 -in cert.pem -text | grep -q -s "Signature Algorithm: ecdsa" ) ;
then
	# ECDSA signatures need to be converted to DER format.
	pkcs15-crypt -s -k $KEY_ID --sha-256 -i $CHALHASH_FILE -o $SIG2_FILE 2> /dev/null || die
	./ecdsa-pkcs11-to-asn1 < $SIG2_FILE > $SIG_FILE || die
else
	pkcs15-crypt -s -k $KEY_ID --sha-256 --pkcs1 -i $CHALHASH_FILE -o $SIG_FILE 2> /dev/null || die
fi

# Verify the response
openssl dgst -sha256 -verify $PUB_KEY_FILE -signature $SIG_FILE $CHAL_FILE || die

echo ""
echo "ACCESS GRANTED."
cleanup
exit 0
