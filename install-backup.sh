#!/bin/bash

# check if the system is a Venus OS
if [ -f "/opt/victronenergy/version" ]
then
    INSTALL_DIR=/data/etc
else
    INSTALL_DIR=/opt
fi

# check if archive already exists
TMP_FILE=/tmp/master.zip
if [ -f $TMP_FILE ]; then
    echo "delete existing $TMP_FILE"
    rm -f $TMP_FILE
fi

# check if folder already exists
TMP_DIR=/tmp/raspberry-pi-backup-master
if [ -d $TMP_DIR ]; then
    echo "delete existing $TMP_DIR"
    rm -rf $TMP_DIR
fi

# download latest copy of repository
wget -P /tmp https://github.com/mr-manuel/raspberry-pi-backup/archive/refs/heads/master.zip

# unzip archive
unzip /tmp/master.zip -d /tmp

# copy archive
cp -rf /tmp/raspberry-pi-backup-master/raspberry-pi-backup/ $INSTALL_DIR

# make file executable
chmod +x $INSTALL_DIR/raspberry-pi-backup/backup.sh
chmod +x $INSTALL_DIR/raspberry-pi-backup/ext/dd

# copy mount.cifs if missing on system (like on Venus OS)
if [ ! -f "/sbin/mount.cifs" ]; then
    cp $INSTALL_DIR/raspberry-pi-backup/ext/mount.cifs /sbin
    chmod +x /sbin/mount.cifs
    chmod u+s /sbin/mount.cifs
fi

echo ""
echo ""

if [ -f "$INSTALL_DIR/raspberry-pi-backup/backup.sh" ]
then
    echo "The installation was successful."
    echo "Now you have to change the default parameters of the script and setup a cronjob to run automatically \"$INSTALL_DIR/raspberry-pi-backup/backup.sh\" on your desire."
else

    echo "Something went wrong with the installation. Try to reboot your system."
fi

echo ""
