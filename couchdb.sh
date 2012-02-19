#!/bin/bash

#Builds and installs the version of CouchDB at the specified tag.

#Specific to App
APPNAME="couchdb"
REPO="http://git-wip-us.apache.org/repos/asf/couchdb.git"
REPOTAG="1.1.1"
CONFIGPARAMS="--with-erlang=/usr/lib64/erlang/usr/include/"

#Abort on Error
set -e

#Generic Variables
ROOT=`pwd`
TEMPDIR="$ROOT/temp"
LOGDIR="$TEMPDIR/logs"
ERRORLOG="$LOGDIR/error-$APPNAME"
BUILDLOG="$LOGDIR/build-$APPNAME"
SRCDIR="$TEMPDIR/$APPNAME"
SRCCONFIGDIR="$ROOT/configs/$APPNAME"
INSTALLDIR="$ROOT/$APPNAME"
INSTALLCONFIGDIR="$ROOT/$APPNAME"
LOGSPACER="---------------------------------------------------------------------------------------------------------------------"

#Write error logs and mkdir install directory.
mkdir -p $INSTALLDIR
touch $ERRORLOG $BUILDLOG

#Clone the repository
echo -n "Cloning $REPO to $SRCDIR..."
	git clone $REPO $SRCDIR  > /dev/null 2>&1
echo "Done!"

echo "Entering $SRCDIR."
	cd $SRCDIR

#Checkout the correct revision
echo -n "Checking out tag $REPOTAG..."
	git checkout $REPOTAG > /dev/null 2>&1
echo "Done!"

#Bootstrap gets us ready to run...err...ready to...Relax!
echo -n "Bootstrapping $APPNAME..."
	./bootstrap >> $BUILDLOG 2>>$ERRORLOG
	echo $LOGSPACER >> $BUILDLOG
	echo $LOGSPACER >> $ERRORLOG
echo "Done!"

#Configure the makefile
echo -n "Configuring $APPNAME to build..."
	./configure $CONFIGPARAMS --prefix=$INSTALLDIR >> $BUILDLOG 2>>$ERRORLOG
	echo $LOGSPACER >> $BUILDLOG
	echo $LOGSPACER >> $ERRORLOG
echo "Done!"

#Finally, time to actually build!
echo -n "Building $APPNAME..."
	make >> $BUILDLOG 2>>$ERRORLOG
echo "Done!"

#Now, we must install.
echo -n "Installing $APPNAME..."
	make install >> $BUILDLOG 2>>$ERRORLOG
	echo $LOGSPACER >> $BUILDLOG
	echo $LOGSPACER >> $ERRORLOG
echo "Done!"
#Return to root directory.  Leave things where they were when we arrived.
cd $ROOT
