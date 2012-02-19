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
ROOT=`pwd`
TEMPDIR="$ROOT/temp"
LOGDIR="$TEMPDIR/logs"
ERRORLOG="$LOGDIR/error-$APPNAME"
BUILDLOG="$LOGDIR/build-$APPNAME"
SRCDIR="$TEMPDIR/$APPNAME"
SRCCONFIGDIR="$ROOT/configs/$APPNAME"
SRCSCRIPTDIR="$ROOT/scripts"
INSTALLDIR="$ROOT/$APPNAME"
INSTALLCONFIGDIR="$ROOT/$APPNAME/etc"
INSTALLSCRIPTDIR="$ROOT/$APPNAME"
LOGSPACER="---------------------------------------------------------------------------------------------------------------------"

CONFIGPARAMS="--with-openssl --with-openssl-libs=/usr/lib --sbindir=$INSTALLDIR/bin/ --libdir=$INSTALLDIR/bin/lib/"

#Clear Temp Directory
echo "Must be root to remove clean temp directory: $TEMPDIR"
#	su -c "echo -n 'Removing and recreating temp directory: $TEMPDIR...'    ;    rm -rf '$TEMPDIR'"
	sudo echo -n "Removing and recreating temp and install directories..."
	sudo rm -rf $TEMPDIR $INSTALLDIR
	mkdir -p $TEMPDIR $LOGDIR $INSTALLDIR
echo "Done!"

#Write error logs and mkdir install directory.
mkdir -p $INSTALLDIR "$INSTALLDIR/bin/lib" "$INSTALLDIR/etc" $INSTALLCONFIGDIR
touch $ERRORLOG $BUILDLOG

echo -n "Downloading $APPNAME..."
	wget -O "$TEMPDIR/$SRCTAR"  "$SRCURL/$SRCTAR" 1>$BUILDLOG 2>$ERRORLOG.
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
	mkdir -p $INSTALLDIR/var/tmp/upload $INSTALLDIR/var/tmp/compressed $INSTALLDIR/var/www $INSTALLDIR/var/log >> $BUILDLOG 2>>$ERRORLOG
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

#Install config
echo -n "Installing config..."
	cp -Rf $SRCCONFIGDIR/* $INSTALLCONFIGDIR
	#Set Crosslights root dir, username and groupname
	echo "rootdir='$INSTALLDIR'" >> $INSTALLCONFIGDIR/lighttpd.conf.local
	echo "server.username='$USERNAME'" >> $INSTALLCONFIGDIR/lighttpd.conf.local
	echo "server.groupname='$USERNAME'" >> $INSTALLCONFIGDIR/lighttpd.conf.local
echo "Done!"

#Install scripts
echo -n "Installing scripts..."
	cp "$SRCSCRIPTDIR/$APPNAME.sh" "$INSTALLSCRIPTDIR/"
echo "Done!"

#Configure permissions
echo "Configuring permissions."
	sudo chown -R $USERNAME:$USERNAME $INSTALLDIR
	sudo chmod -R 755 $INSTALLDIR
echo "Permissions configured."
