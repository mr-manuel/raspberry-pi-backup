#!/bin/bash

# script version 0.0.2 (2023.06.07)

# uncomment for debugging
#set -x

echo ""

# check if the system is a Venus OS
if [ -f "/opt/victronenergy/version" ]
then
    echo "Recognized OS: \"Venus OS $(head -n 1 /opt/victronenergy/version)\""
    INSTALL_DIR=/data/etc
else
    echo "Recognized OS: \"$(uname -a)\""
    INSTALL_DIR=/opt
fi

echo ""

# check if archive already exists
TMP_FILE=/tmp/master.zip
if [ -f $TMP_FILE ]; then
    echo "delete existing $TMP_FILE"
    rm -f $TMP_FILE
    echo ""
fi

# check if folder already exists
TMP_DIR=/tmp/raspberry-pi-backup-master
if [ -d $TMP_DIR ]; then
    echo "delete existing $TMP_DIR"
    rm -rf $TMP_DIR
    echo ""
fi

# download latest copy of repository
echo "Download latest version..."
wget -P /tmp https://github.com/mr-manuel/raspberry-pi-backup/archive/refs/heads/master.zip

if [ $? -ne 0 ]; then
    echo "Error during downloading the file."
    exit
else
    echo "done."
fi

echo ""

# unzip archive
echo "Extracting archive..."
unzip /tmp/master.zip -d /tmp

if [ $? -ne 0 ]; then
    echo "Error during extracting the file."
    exit
else
    echo "done."
fi

echo ""

# copy archive
cp -rf /tmp/raspberry-pi-backup-master/raspberry-pi-backup/ $INSTALL_DIR

# make file executable
chmod +x $INSTALL_DIR/raspberry-pi-backup/backup.sh
chmod +x $INSTALL_DIR/raspberry-pi-backup/ext/dd

# copy mount.cifs if missing on system (like on Venus OS)
if [ ! -f "/sbin/mount.cifs" ]; then
    echo "Copy missing \"mount.cifs\" to \"/sbin/mount.cifs\""
    cp $INSTALL_DIR/raspberry-pi-backup/ext/mount.cifs /sbin
    chmod +x /sbin/mount.cifs
    chmod u+s /sbin/mount.cifs
fi

# copy mount.nfs if missing on system (like on Venus OS)
if [ ! -f "/sbin/mount.nfs" ]; then
    echo "Copy missing \"mount.nfs\" to \"/sbin/mount.nfs\""
    cp $INSTALL_DIR/raspberry-pi-backup/ext/mount.nfs /sbin
    chmod +x /sbin/mount.nfs
    chmod u+s /sbin/mount.nfs
fi

echo ""
echo ""

if [ -f "$INSTALL_DIR/raspberry-pi-backup/backup.sh" ] && [ -f "/sbin/mount.cifs" ] && [ -f "/sbin/mount.nfs" ]; then
    echo "The installation was successful."
    echo "Now you have to change the default parameters of the script and setup a cronjob to run automatically \"$INSTALL_DIR/raspberry-pi-backup/backup.sh\" on your desire."
else

    echo "Something went wrong with the installation. Try to reboot your system."
fi

echo ""
