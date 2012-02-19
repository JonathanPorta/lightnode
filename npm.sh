#!/bin/bash

#Builds and installs the version of NPM at the specified tag.

#Specific to App
APPNAME="npm"
REPO="https://github.com/isaacs/npm.git"
REPOTAG="v1.1.1"
CONFIGPARAMS=""

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

##Bootstrap gets us ready to run...err...ready to...Relax!
#echo -n "Bootstrapping $APPNAME..."
#	./bootstrap >> $BUILDLOG 2>>$ERRORLOG
#	echo $LOGSPACER >> $BUILDLOG
#	echo $LOGSPACER >> $ERRORLOG
#echo "Done!"

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
#echo "Must be root to install!"
#	su -c "
	echo -n "Installing $APPNAME..."    ;    make install >> $BUILDLOG 2>>$ERRORLOG    ;    echo 'Done!'
#	"
	echo $LOGSPACER >> $BUILDLOG
	echo $LOGSPACER >> $ERRORLOG

#Return to root directory.  Leave things where they were when we arrived.
cd $ROOT
