#!/bin/bash

#Abort on Error
set -e

ROOT=`pwd`
BUILDSCRIPTS="$ROOT/build"
TEMPDIR="$ROOT/temp"
LOGDIR="$TEMPDIR/logs"
INSTALLROOT=$1

DEPS="$BUILDSCRIPTS/yum_dependencies.sh"
CROSSLIGHT="$BUILDSCRIPTS/crosslight.sh"
COUCH="$BUILDSCRIPTS/couchdb.sh"
NODE="$BUILDSCRIPTS/nodejs.sh"

echo "Going to install in $INSTALLROOT"

#Need to be root
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root." 1>&2
	exit 1
fi

#Clear Temp Directory
echo -n "Removing and recreating temp directory: $TEMPDIR..."
	rm -rf $TEMPDIR
	mkdir -p $TEMPDIR $LOGDIR $INSTALLROOT
echo "Done!"

#Install Dependencies
echo "Installing yum dependencies:"
	$DEPS $ROOT
echo "Yum dependencies installed."

#Build Crosslight
echo "Installing Crosslight:"
	$CROSSLIGHT $ROOT $INSTALLROOT
echo "Crosslight installed."

##Build CouchDB
#echo -n "Installing CouchDB..."
#	$COUCH $ROOT $INSTALLROOT
#echo "Done!"

#Build Node.js
echo -n "Installing Node.js..."
	$NODE $ROOT $INSTALLROOT
echo "Done!"

echo "All installations complete!  Logs are viewable in $LOGDIR"
