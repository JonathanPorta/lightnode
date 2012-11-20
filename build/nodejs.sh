#!/bin/bash

#Builds and installs the version of Node.js at the specified tag.

#Specific to App
APPNAME="nodejs"
USERNAME="nodejs"
REPO="https://github.com/joyent/node.git"
REPOTAG="v0.8.14"
CONFIGPARAMS=""

#Abort on Error
set -e

#Generic Variables
ROOT=$1
INSTALLROOT="$2"

TEMPDIR="$ROOT/temp"
LOGDIR="$TEMPDIR/logs"
ERRORLOG="$LOGDIR/error-$APPNAME"
BUILDLOG="$LOGDIR/build-$APPNAME"
SRCDIR="$TEMPDIR/$APPNAME"

SRCCONFIGDIR="$ROOT/configs/$APPNAME"
SRCSCRIPTDIR="$ROOT/scripts/$APPNAME"

INSTALLDIR="$INSTALLROOT/$APPNAME"
INSTALLCONFIGDIR="$INSTALLROOT/$APPNAME"
INSTALLSCRIPTDIR="$INSTALLROOT/$APPNAME"

LOGSPACER="---------------------------------------------------------------------------------------------------------------------"

#Write error logs and make sure we have all of the directories we need
mkdir -p $INSTALLDIR $SRCCONFIGDIR $SRCSCRIPTDIR $INSTALLCONFIGDIR $INSTALLSCRIPTDIR
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
	./configure --prefix=$INSTALLDIR $CONFIGPARAMS >> $BUILDLOG 2>>$ERRORLOG
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

##Configure user and group permissions
#echo "Configuring user and group."
#	#Make sure we have a groupls -l
#	if ! grep -c "^$USERNAME" /etc/group > /dev/null; then
#		echo -n "Creating group $USERNAME..."
#			groupadd $USERNAME
#		echo "Done!"
#	fi

#	#Make sure we have a user
#	if ! grep -c "^$USERNAME" /etc/passwd > /dev/null; then
#		echo -n "Creating user account $USERNAME..."
#			useradd -g $USERNAME --home $INSTALLDIR $USERNAME
#		echo "Done!"
#	fi
#echo "User and group configuration complete!"

#Install config
echo -n "Installing config..."
	#We don't care if the copy fails, because it likely failed due to not having a configuration, which is actually ok.
	cp -Rf $SRCCONFIGDIR/* $INSTALLCONFIGDIR 2>/dev/null || :
echo "Done!"

#Install scripts
echo -n "Installing scripts..."
	cp -Rf $SRCSCRIPTDIR/* $INSTALLSCRIPTDIR 2>/dev/null || :
	echo "PATH=$PATH:$INSTALLDIR/bin" >> "$INSTALLSCRIPTDIR/.bashrc"
	echo "YAYAY!"
echo "Done!"

#Configure permissions
echo -n "Configuring permissions..."
	chown -R $USERNAME:$USERNAME $INSTALLDIR
	chmod -R 774 $INSTALLDIR
echo "Done!"
#Return to root directory.  Leave things where they were when we arrived.
cd $ROOT
