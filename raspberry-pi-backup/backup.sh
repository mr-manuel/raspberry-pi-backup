#!/bin/bash

# script version 0.0.3 (2023.09.21)

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
# Use 0 to disable old backup deletion
BACKUP_COUNT="5"

# backup hostname (default gets the hostname from the system)
BACKUP_HOSTNAME="$(hostname)"
################### CONFIG | END ###################



SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BACKUP_MOUNT="/mnt/backup"
BACKUP_PATH="$BACKUP_MOUNT/$BACKUP_SUBFOLDER$BACKUP_HOSTNAME"
BACKUP_NAME="Backup_$BACKUP_HOSTNAME"

echo

# create mount dir if not exists
if [ ! -d $BACKUP_MOUNT ]; then
    echo "$BACKUP_MOUNT does not exist. Creating folder..."
    mkdir $BACKUP_MOUNT
    echo
fi

# check if something is already mounted
if [ 1 -eq "$(mount -v | grep -c $BACKUP_MOUNT)" ]; then
    echo "WARNING: There is already mounted something to \"$BACKUP_MOUNT\". This will be unmounted now."
    echo
    mount -v | grep $BACKUP_MOUNT
    umount $BACKUP_MOUNT
    echo
fi

# mount harddisk
echo "Mounting \"$BACKUP_REMOTE_MOUNT\" to \"$BACKUP_MOUNT\"..."
mount -t cifs -o user=$BACKUP_REMOTE_MOUNT_USER,password=$BACKUP_REMOTE_MOUNT_PW,rw,file_mode=0660,dir_mode=0660,nounix,noserverino $BACKUP_REMOTE_MOUNT $BACKUP_MOUNT

if [ $? -ne 0 ]; then
    echo "Error when mounting the remote path."
    exit
fi

echo

# create folder if it does not exist
if [ ! -d "$BACKUP_PATH" ]; then
    echo "Creating \"$BACKUP_SUBFOLDER\" on backup mount..."
    mkdir -p "$BACKUP_PATH"
    if [ $? -ne 0 ]; then
        echo "Error when creating of the backup folder on the remote path."
        echo
        exit
    fi
    echo
fi

# check if dd is a symlink like in busybox
# if yes then probably the argument "status=progress" will not work, use own dd
if [[ -L "/bin/dd" ]] || [[ -f "/opt/victronenergy/version" ]]; then
    # check if backup is already running
    if [ "$(ps | grep -c 'dd if=/dev/mmcblk0')" -gt 1 ]; then
        echo "Backup already running. Exiting..."
        echo
        exit
    fi
    # create backup
    echo "Using script dd for backup."
    "$SCRIPT_DIR/ext/dd" if=/dev/mmcblk0 of="${BACKUP_PATH}/${BACKUP_NAME}_$(date +%Y%m%d_%H%M%S).img" bs=1MB status=progress

# if not use the system dd
else
    # check if backup is already running
    if [ "$(ps -aux | grep -c 'dd if=/dev/mmcblk0')" -gt 1 ]; then
        echo "Backup already running. Exiting..."
        echo
        exit
    fi
    # create backup
    echo "Using system dd for backup."
    /bin/dd if=/dev/mmcblk0 of="${BACKUP_PATH}/${BACKUP_NAME}_$(date +%Y%m%d_%H%M%S).img" bs=1MB status=progress
fi

if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
    echo
else
    echo "Error when backup of the system."
    echo
    exit
fi


# delete old backups
BACKUP_FILES_TO_DELETE_COUNT=$(ls -tr ${BACKUP_PATH}/${BACKUP_NAME}* | head -n -${BACKUP_COUNT} | wc -l)
if [ "$BACKUP_FILES_TO_DELETE_COUNT" -ne "0" ]; then
    pushd ${BACKUP_PATH} || exit
    ls -tr ${BACKUP_PATH}/${BACKUP_NAME}* | head -n ${BACKUP_COUNT} | xargs rm
    popd || exit
    echo -e "$BACKUP_FILES_TO_DELETE_COUNT old backups deleted."
fi

# unmount harddisk
umount $BACKUP_MOUNT

if [ $? -ne 0 ]; then
    echo "Error when unmounting the remote path."
fi

echo
echo
