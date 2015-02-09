#include <openssl/x509.h>
#include <openssl/pem.h>
#include <stdio.h>
#include <stdint.h>


int main(int argc, char * argv[])
{
	uint8_t pkcs11_sig[512];
	int pkcs11_sig_len = 0;

	pkcs11_sig_len = fread((void*)pkcs11_sig, 1, sizeof(pkcs11_sig), stdin);

	int nLen;
	ECDSA_SIG * ecsig = NULL;
	unsigned char *p = NULL;
	int der_len;
	nLen = pkcs11_sig_len/2;
	ecsig = ECDSA_SIG_new();
	ecsig->r = BN_bin2bn(pkcs11_sig, nLen, ecsig->r);
	ecsig->s = BN_bin2bn(pkcs11_sig + nLen, nLen, ecsig->s);
	der_len = i2d_ECDSA_SIG(ecsig, &p);
	//fprintf(stderr,"Writing OpenSSL ECDSA_SIG\n");
	fwrite(p,1,der_len,stdout);
	free(p);
	ECDSA_SIG_free(ecsig);
	return 0;
}
