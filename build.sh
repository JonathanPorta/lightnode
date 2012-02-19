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

#Clear Temp Directory
echo "Must be root to remove clean temp directory: $TEMPDIR"
	sudo echo -n "Removing and recreating temp directory: $TEMPDIR..."
		sudo rm -rf $TEMPDIR
		mkdir -p $TEMPDIR $LOGDIR
	echo "Done!"

	sudo echo -n "Removing and recreating install directories..."
		sudo rm -rf "$ROOT/crosslight" "$ROOT/couchdb" "$ROOT/nodejs"
		mkdir -p "$ROOT/crosslight" "$ROOT/couchdb" "$ROOT/nodejs"
	echo "Done!"

#Install Dependencies
echo -n "Installing yum dependencies..."
	$DEPS
echo "Done!"

#Build Crosslight
echo -n "Installing Crosslight..."
	$CROSSLIGHT
echo "Done!"

##Build CouchDB
#echo -n "Installing CouchDB..."
#	$COUCH
#echo "Done!"

##Build Node.js
#echo -n "Installing Node.js..."
#	$NODE
#echo "Done!"
