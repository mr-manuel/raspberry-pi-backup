#!/bin/bash

# script version 0.0.2 (2023.06.07)

# uncomment for debugging
#set -x

################## CONFIG | START ##################
# specify the remote mount
BACKUP_REMOTE_MOUNT="//192.168.1.1/sharename"

# specify a subfolder (with ending /) if needed, else
# leave completely empty
# NOTE: an additional subfolder with the hostname of
#       the device is automatically created
BACKUP_SUBFOLDER="Backups/"

# specify the username for the remote mount
BACKUP_REMOTE_MOUNT_USER="username"

# specify the password for the remote mount
BACKUP_REMOTE_MOUNT_PW="password"

# how may backups should be kept?
BACKUP_COUNT="5"

# backup hostname (default gets the hostname from the system)
BACKUP_HOSTNAME="$(hostname)"
################### CONFIG | END ###################



SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BACKUP_MOUNT="/mnt/backup"
BACKUP_PATH="$BACKUP_MOUNT/$BACKUP_SUBFOLDER$BACKUP_HOSTNAME"
BACKUP_NAME="Backup_$BACKUP_HOSTNAME"

# create mount dir if not exists
if [ ! -d $BACKUP_MOUNT ]; then
    mkdir $BACKUP_MOUNT
fi

# mount harddisk
mount -t cifs -o user=$BACKUP_REMOTE_MOUNT_USER,password=$BACKUP_REMOTE_MOUNT_PW,rw,file_mode=0777,dir_mode=0777 $BACKUP_REMOTE_MOUNT $BACKUP_MOUNT

if [ $? -ne 0 ]; then
    echo "Error during mounting the remote path."
    exit
fi

# create folder if it does not exist
if [ ! -d "$BACKUP_PATH" ]; then
    mkdir "$BACKUP_PATH"
fi

# check if dd is a symlink like in busybox
if [[ -L "/bin/dd" ]] || [[ -f "/opt/victronenergy/version" ]]
# if not use the system dd
then
    # create backup
    $SCRIPT_DIR/ext/dd if=/dev/mmcblk0 of=${BACKUP_PATH}/${BACKUP_NAME}_$(date +%Y%m%d_%H%M%S).img bs=1MB status=progress

# if yes then probably the argument "status=progress" will not work, use own dd
else
    # create backup
    dd if=/dev/mmcblk0 of=${BACKUP_PATH}/${BACKUP_NAME}_$(date +%Y%m%d_%H%M%S).img bs=1MB status=progress
fi

if [ $? -ne 0 ]; then
    echo "Error during backup of the system."
    exit
fi


# delete old backups
BACKUP_FILES_TO_DELETE_COUNT=$(ls -tr ${BACKUP_PATH}/${BACKUP_NAME}* | head -n -${BACKUP_COUNT} | wc -l)
if [ "$BACKUP_FILES_TO_DELETE_COUNT" -ne "0" ]; then
    pushd ${BACKUP_PATH}; ls -tr ${BACKUP_PATH}/${BACKUP_NAME}* | head -n -${BACKUP_COUNT} | xargs rm; popd
    echo -e "$BACKUP_FILES_TO_DELETE_COUNT old backups deleted."
fi

# unmount harddisk
umount $BACKUP_MOUNT
