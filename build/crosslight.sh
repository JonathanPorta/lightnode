#!/bin/bash

#Crosslight linux build script

#Abort on Error
set -e

#Specific to App
APPNAME="crosslight"
USERNAME="crosslight"
RELHOME="var/www" #Relative to install dir
SRCURL="http://download.lighttpd.net/lighttpd/releases-1.4.x"
SRCPKG="lighttpd"
SRCVER="-1.4.30"
SRCEXT=".tar.gz"
SRCTAR="$SRCPKG$SRCVER$SRCEXT"

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

CONFIGPARAMS="--with-openssl --with-openssl-libs=/usr/lib --sbindir=$INSTALLDIR/bin/ --libdir=$INSTALLDIR/bin/lib/"

#Write error logs and make sure we have all of the directories we need
mkdir -p $INSTALLDIR "$INSTALLDIR/bin/lib" $SRCCONFIGDIR $SRCSCRIPTDIR $INSTALLCONFIGDIR $INSTALLSCRIPTDIR
touch $ERRORLOG $BUILDLOG

echo -n "Downloading $APPNAME..."
	wget -O "$TEMPDIR/$SRCTAR"  "$SRCURL/$SRCTAR" 1>$BUILDLOG 2>$ERRORLOG
echo "Done!"

echo -n "Preparing $APPNAME source..."
	tar -C $TEMPDIR -xf "$TEMPDIR/$SRCTAR" 1>$BUILDLOG 2>$ERRORLOG
	mv $TEMPDIR/$SRCPKG$SRCVER $SRCDIR/ 1>$BUILDLOG 2>$ERRORLOG
	rm -f $TEMPDIR/$SRCTAR 1>$BUILDLOG 2>$ERRORLOG
echo "Done!"

echo "Entering $SRCDIR."
	cd "$SRCDIR"

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

#Cleanup and build directory tree
echo -n "Cleaning up install..."
	#Clean up everything we don't need, but can't turn off in the ./configure scripts.
	BIN="$INSTALLDIR/bin"
	SBIN="$INSTALLDIR/sbin"
	rm -rf "$INSTALLDIR/include/php/ext/" >> $BUILDLOG 2>>$ERRORLOG
	rm -rf "$INSTALLDIR/lib" "$INSTALLDIR/man" "$INSTALLDIR/share" "$INSTALLDIR/include" >> $BUILDLOG 2>>$ERRORLOG
	rm -rf $BIN/{lighttpd-angel,pear,peardev,pecl,phar,phar.phar,php,php-config,phpize} $SBIN "$INSTALLDIR/etc/pear.conf" >> $BUILDLOG 2>>$ERRORLOG

	#Make sure we have our necessary var/ directories
	mkdir -p $INSTALLDIR/var/tmp/upload $INSTALLDIR/var/tmp/compressed $INSTALLDIR/var/www $INSTALLDIR/var/log $INSTALLDIR/var/log/localhost >> $BUILDLOG 2>>$ERRORLOG
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
#			useradd -g $USERNAME --home $INSTALLDIR --shell /sbin/nologin $USERNAME
#		echo "Done!"
#	fi
#echo "User and group configuration complete!"

#Install config
echo -n "Installing config..."
	#We don't care if the copy fails, because it likely failed due to not having a configuration, which is actually ok.
	cp -Rf $SRCCONFIGDIR/* $INSTALLCONFIGDIR 2>/dev/null || :
	#Set Crosslights root dir, username and groupname
	echo "rootdir=\"$INSTALLDIR\"" >> $INSTALLCONFIGDIR/etc/lighttpd.conf.local
	echo "server.username=\"$USERNAME\"" >> $INSTALLCONFIGDIR/etc/lighttpd.conf.local
	echo "server.groupname=\"$USERNAME\"" >> $INSTALLCONFIGDIR/etc/lighttpd.conf.local
echo "Done!"

#Install scripts
echo -n "Installing scripts..."
	cp -Rf $SRCSCRIPTDIR/* $INSTALLSCRIPTDIR 2>/dev/null || :
echo "Done!"

#Configure permissions
echo -n "Configuring permissions..."
	chown -R $USERNAME:$USERNAME $INSTALLDIR
	chmod -R 700 $INSTALLDIR
#	chmod 760 "$INSTALLSCRIPTDIR/$APPNAME.sh"
echo "Done!"
