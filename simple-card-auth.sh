#!/bin/sh

CHAL_FILE=chal.tmp
CHALHASH_FILE=chalhash.tmp
CERT_FILE=cert.pem
PUB_KEY_FILE=pub_key.pem
SIG_FILE=sig.tmp

KEY_ID=4

die() {
	echo ""
	echo "ACCESS DENIED."
	rm $CHAL_FILE 2> /dev/null
	rm $CERT_FILE 2> /dev/null
	rm $CHALHASH_FILE 2> /dev/null
	rm $PUB_KEY_FILE 2> /dev/null
	rm $SIG_FILE 2> /dev/null
	exit 1
}

#set -x

# Extract the certificate
pkcs15-tool -w --read-certificate $KEY_ID -o $CERT_FILE || die

# Extract the public key
openssl x509 -pubkey -noout -in $CERT_FILE > $PUB_KEY_FILE || die

# Print out the subject name
#openssl x509 -in $CERT_FILE -noout -subject || die
openssl x509 -in cert.pem -text || die

# Calculate a challenge
dd if=/dev/random of=$CHAL_FILE bs=32 count=1 2> /dev/null || die

# Calculate the hash of the challenge
openssl sha -sha256 -binary < $CHAL_FILE > $CHALHASH_FILE || die

# Calculate the response for the challenge
if ( openssl x509 -in cert.pem -text | grep -q -s "Signature Algorithm: ecdsa" ) ;
then
	pkcs15-crypt -s -k $KEY_ID --sha-256 -i $CHALHASH_FILE -R | ./ecdsa-pkcs11-to-asn1 > $SIG_FILE || die
else
	pkcs15-crypt -s -k $KEY_ID --sha-256 --pkcs1 -i $CHALHASH_FILE -o  $SIG_FILE || die
fi

# Verify the response
openssl dgst -sha256 -verify $PUB_KEY_FILE -signature $SIG_FILE $CHAL_FILE || die

echo ""
echo "ACCESS GRANTED."
rm $CHAL_FILE 2> /dev/null
rm $CERT_FILE 2> /dev/null
rm $CHALHASH_FILE 2> /dev/null
rm $PUB_KEY_FILE 2> /dev/null
rm $SIG_FILE 2> /dev/null
exit 0
