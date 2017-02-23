
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>


#include <stdio.h>
#include <stdlib.h>
#include <openssl/evp.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/crypto.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/conf.h>
#include <openssl/rand.h>
#include <openssl/ssl.h>
#include <openssl/pkcs12.h>


#ifndef MAX_PATH
#define MAX_PATH 256
#endif

const char * base64char = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static char * base64_encode( const unsigned char * bindata, int binlength  , char * base64 )
{
    int i, j;
    unsigned char current;

    for ( i = 0, j = 0 ; i < binlength ; i += 3 )
    {
        current = (bindata[i] >> 2) ;
        current &= (unsigned char)0x3F;
        base64[j++] = base64char[(int)current];

        current = ( (unsigned char)(bindata[i] << 4 ) ) & ( (unsigned char)0x30 ) ;
        if ( i + 1 >= binlength )
        {
            base64[j++] = base64char[(int)current];
            base64[j++] = '=';
            base64[j++] = '=';
            break;
        }
        current |= ( (unsigned char)(bindata[i+1] >> 4) ) & ( (unsigned char) 0x0F );
        base64[j++] = base64char[(int)current];

        current = ( (unsigned char)(bindata[i+1] << 2) ) & ( (unsigned char)0x3C ) ;
        if ( i + 2 >= binlength )
        {
            base64[j++] = base64char[(int)current];
            base64[j++] = '=';
            break;
        }
        current |= ( (unsigned char)(bindata[i+2] >> 6) ) & ( (unsigned char) 0x03 );
        base64[j++] = base64char[(int)current];

        current = ( (unsigned char)bindata[i+2] ) & ( (unsigned char)0x3F ) ;
        base64[j++] = base64char[(int)current];
    }
    base64[j] = '\0';
    return base64;
}




// gcc -o test  demo_open_ssl.c -lssl -lcrypto
// gcc -g -o test  demo_open_ssl.c -lssl -lcrypto -O3 -DUSE_MMAP -fPIC


static EVP_PKEY *openssl_evp_from_buffer(char *val_buf,int val_lenth)
{
	EVP_PKEY * key = NULL;
	X509 * cert = NULL;
	BIO  *in;
	// ./bio.h:BIO *BIO_new_mem_buf(void *buf, int len);
	in = BIO_new_mem_buf(val_buf,val_lenth); // 系统函数
	if (in == NULL) {
		return NULL;
	}
	cert = (X509 *) PEM_ASN1_read_bio((char *(*)())d2i_X509, PEM_STRING_X509, in, NULL, NULL, NULL);
	BIO_free(in);
	if(!cert){
		BIO* in;
		in = BIO_new_mem_buf(val_buf,val_lenth);
		if (in == NULL) {
			return NULL;
		}
		key = PEM_read_bio_PUBKEY(in, NULL,NULL, NULL);
		BIO_free(in);
		return key;
	}
	key = (EVP_PKEY *) X509_get_pubkey(cert);
	X509_free(cert);
	if(!key)
	{
		return NULL;
	}
}

static int openssl_is_private_key(EVP_PKEY *pkey)
{
	if(!pkey)
	{
		return 1;
	}

	if(pkey->type != 6 )
	{
		// current is private key
		// php_openssl_is_private_key
		// printf("current evp_pkey is private , check failed!\r\n");
		return 0;
	}
	return 1;
}

static int rsa_public_encrypt(EVP_PKEY *pkey, unsigned char *data, int data_len, char *buffer, int *temp_buffer_len)
{
	if(!pkey)
	{
		return 0;
	}

	int successful = 0;
	int cryptedlen;
	unsigned char *cryptedbuf;

	cryptedlen = EVP_PKEY_size(pkey);
	cryptedbuf = malloc(cryptedlen + 1);

	long padding = RSA_PKCS1_PADDING;
	switch (pkey->type) {
		case EVP_PKEY_RSA:
		case EVP_PKEY_RSA2:
			// ok
			successful = (RSA_public_encrypt(data_len, 
						(unsigned char *)data, 
						cryptedbuf, 
						pkey->pkey.rsa, 
						padding) == cryptedlen);
			break;
		default:
			{
				//php_error_docref(NULL TSRMLS_CC, E_WARNING, "key type not supported in this PHP build!");
				printf("pkey->type:%d is not support \n",pkey->type);
			}
	}
	if(successful)
	{
		*temp_buffer_len = cryptedlen;
		memcpy(buffer,cryptedbuf,cryptedlen);
	}
	free(cryptedbuf);
	return successful;
}

// 1) pem buff
// 2) pem buf length 
static int openssl_pkey_get_public_encrypt(lua_State *L)
{
	if(lua_gettop(L) != 4)
	{
		lua_pushnil(L);
		lua_pushstring(L,"args count is error");
		return 2;
	}

	const char *pem_buffer  = luaL_checkstring(L, 1);
	const int  pem_length = (int)luaL_checkint(L, 2);
	if(strlen(pem_buffer) != pem_length)
	{
		lua_pushnil(L);
		lua_pushstring(L,"pem buffer length is error");
		return 2;
	}

	const char *data_buffer  = luaL_checkstring(L, 3);
	const int  data_length = (int)luaL_checkint(L, 4);
	if(strlen(data_buffer) != data_length )
	{
		lua_pushnil(L);
		lua_pushstring(L,"data buffer length is error");
		return 2;
	}

	EVP_PKEY *pkey = openssl_evp_from_buffer((char *)pem_buffer,pem_length);

	if(!pkey)
	{
		lua_pushnil(L);
		lua_pushstring(L,"openssl_evp_from_buffer is error");
		return 2;
	}

	// 注意buf可以能太小
	char temp_buffer[2048] = {0}; 
	int temp_buffer_len = 0;
	int ret = rsa_public_encrypt(pkey ,  (char*)data_buffer, data_length , temp_buffer,&temp_buffer_len);

	// fixed 
	EVP_PKEY_free(pkey);

	if(ret == 1 && temp_buffer_len > 0 )
	{

		char base64[4096];
		base64_encode( temp_buffer,temp_buffer_len,base64 );

		lua_pushnumber(L,1);
		lua_pushlstring(L,base64, strlen(base64));
		return 2;
	}

	lua_pushnil(L);
	lua_pushstring(L,"rsa_public_encrypt is error");
	return 2;
}


static const luaL_Reg lib[] = {
	{"openssl_pkey_get_public_encrypt", openssl_pkey_get_public_encrypt},
	{NULL, NULL}
};


int luaopen_libOpenSSLPaySign(lua_State *L) {

	luaL_register(L, "libOpenSSLPaySign", lib);

	return 0;
}
