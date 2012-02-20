#!/bin/bash

#Builds and installs the version of Node.js at the specified tag.

#Specific to App
APPNAME="nodejs"
REPO="https://github.com/joyent/node.git"
REPOTAG="v0.6.11"
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

#Configure the makefile
echo -n "Configuring $APPNAME to build..."
	./configure --enable-static --prefix=$INSTALLDIR $CONFIGPARAMS >> $BUILDLOG 2>>$ERRORLOG
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

#Configure user and group permissions
echo "Configuring user and group."
	#Make sure we have a groupls -l
	if ! grep -c "^$USERNAME" /etc/group > /dev/null; then
		echo -n "Creating group $USERNAME..."
			sudo groupadd $USERNAME
		echo "Done!"
	fi

	#Make sure we have a user
	if ! grep -c "^$USERNAME" /etc/passwd > /dev/null; then
		echo -n "Creating user account $USERNAME..."
			sudo useradd --system -g $USERNAME --home $INSTALLDIR/$RELHOME --shell /sbin/nologin $USERNAME
		echo "Done!"
	fi
echo "User and group configuration complete!"

##Install config
#echo -n "Installing config..."
#	cp -Rf $SRCCONFIGDIR/* $INSTALLCONFIGDIR
#	#Set Crosslights root dir, username and groupname
#	echo "rootdir='$INSTALLDIR'" >> $INSTALLCONFIGDIR/lighttpd.conf.local
#	echo "server.username='$USERNAME'" >> $INSTALLCONFIGDIR/lighttpd.conf.local
#	echo "server.groupname='$USERNAME'" >> $INSTALLCONFIGDIR/lighttpd.conf.local
#echo "Done!"

##Install scripts
#echo -n "Installing scripts..."
#	cp "$SRCSCRIPTDIR/$APPNAME.sh" "$INSTALLSCRIPTDIR/"
#echo "Done!"

#Configure permissions
echo -n "Configuring permissions..."
	sudo chown -R $USERNAME:$USERNAME $INSTALLDIR
	sudo chmod -R 755 $INSTALLDIR
echo "Done!"
#Return to root directory.  Leave things where they were when we arrived.
cd $ROOT
