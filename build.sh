#!/bin/bash

#Abort on Error
set -e

ROOT=`pwd`
TEMPDIR="$ROOT/temp"
LOGDIR="$TEMPDIR/logs"

DEPS="$ROOT/yum_dependencies.sh"
CROSSLIGHT="$ROOT/crosslight.sh"
COUCH="$ROOT/couchdb.sh"
NODE="$ROOT/nodejs.sh"


#Need to be root
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root." 1>&2
	exit 1
fi

#Clear Temp Directory
echo -n "Removing and recreating temp directory: $TEMPDIR..."
	rm -rf $TEMPDIR
	mkdir -p $TEMPDIR $LOGDIR
echo "Done!"

#Install Dependencies
echo "Installing yum dependencies:"
	$DEPS
echo "Yum dependencies installed."

#Build Crosslight
echo "Installing Crosslight:"
	$CROSSLIGHT
echo "Crosslight installed."

#Build CouchDB
echo -n "Installing CouchDB..."
	$COUCH
echo "Done!"

#Build Node.js
echo -n "Installing Node.js..."
	$NODE
echo "Done!"

echo "All installations complete!  Logs are viewable in $LOGDIR"
