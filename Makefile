

CFLAGS=-g -O0  -Wno-deprecated-declarations

LDFLAGS=-lcrypto

all: ecdsa-pkcs11-to-asn1


clean:
	$(RM) ecdsa-pkcs11-to-asn1
