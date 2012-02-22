#!/bin/sh

echo "Run this from the crosslight root directory.";

if [ ! -z etc/ssl/ ] ; then mkdir --parents etc/ssl ; fi

SITE="localhost:3000"

cd etc/ssl
openssl genrsa -des3 -out $SITE.key 1024  #Build our key
openssl req -new -key $SITE.key -out $SITE.csr #Build the cert request
cp $SITE.key{,.orig} 
openssl rsa -in $SITE.key.orig -out $SITE.key #Ignore the passphrase
openssl x509 -req -days 365 -in $SITE.csr -signkey $SITE.key -out $SITE.crt #Build the cert
#cat crosslight.key crosslight.crt > crosslight.pem #Build the pem
#cd ../..
#echo "include \"lighttpd.ssl.conf\"" >> lighttpd.conf

echo "After running this script, you will need to use https://localhost:3000/ unless you change your configuration."
