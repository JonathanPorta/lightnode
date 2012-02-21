#!/bin/bash

#Installs includes needed to build crosslight, couchdb, node.js, etc
#Only for Fedora... Only tested on F15

#Abort on Error
set -e

#Specific to App
APPNAME="yum-deps"

#Abort on Error
set -e

#Generic Variables
ROOT=`pwd`
TEMPDIR="$ROOT/temp"
LOGDIR="$TEMPDIR/logs"
ERRORLOG="$LOGDIR/error-$APPNAME"

#General Development Tools
echo "Installing Development Dependencies"
	yum -y groupinstall 'Development Tools' 2>>$ERRORLOG

#Crosslight
echo "Installing Crosslight Dependencies"
	yum -y install pcre-devel zlib-devel bzip2-devel libxml2-devel openssl-devel libcurl-devel libpng-devel libjpeg-devel libtidy-devel 2>>$ERRORLOG

#CouchDB
echo "Installing CouchDB Dependencies"
	yum -y install icu libicu-devel js js-devel erlang 2>>$ERRORLOG

#Node.js
echo "Installing Node.js Dependencies"
#None that we know of yet!
