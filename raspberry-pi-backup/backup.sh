#!/bin/bash

# script version 0.0.10-gzip-pv (2025.10.13)

#set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

################## CONFIG | START ##################
if [ -f $SCRIPT_DIR/backup.conf ]; then
    . $SCRIPT_DIR/backup.conf
else
    BACKUP_REMOTE_MOUNT="//192.168.1.1/sharename"
    BACKUP_SUBFOLDER="Backups/"
    BACKUP_REMOTE_MOUNT_USER="username"
    BACKUP_REMOTE_MOUNT_PW="password"
    BACKUP_COUNT="5"
    BACKUP_HOSTNAME="$(hostname)"
    BACKUP_DEVICE="/dev/mmcblk0"
fi
################### CONFIG | END ###################

BACKUP_MOUNT="/mnt/backup"
BACKUP_PATH="${BACKUP_MOUNT}/${BACKUP_SUBFOLDER}${BACKUP_HOSTNAME}"
BACKUP_NAME="Backup_${BACKUP_HOSTNAME}"

echo

# create mount dir if not exists
[ ! -d ${BACKUP_MOUNT} ] && mkdir -p ${BACKUP_MOUNT}

# unmount if already mounted
if mount | grep -q ${BACKUP_MOUNT}; then
    echo "Unmounting existing mount on ${BACKUP_MOUNT}..."
    umount ${BACKUP_MOUNT}
fi

# mount remote share
echo "Mounting \"${BACKUP_REMOTE_MOUNT}\" to \"${BACKUP_MOUNT}\"..."
mount -t cifs -o user=${BACKUP_REMOTE_MOUNT_USER},password=${BACKUP_REMOTE_MOUNT_PW},rw,file_mode=0660,dir_mode=0660,nounix,noserverino ${BACKUP_REMOTE_MOUNT} ${BACKUP_MOUNT} || { echo "Mount failed"; exit 1; }

# create backup folder if it does not exist
mkdir -p "${BACKUP_PATH}"

# choose compression tool
COMPRESS_CMD=$(command -v pigz || echo gzip)

# check if pv exists
if ! command -v pv &> /dev/null; then
    PV_CMD=""
else
    PV_CMD="pv -s $(blockdev --getsize64 $BACKUP_DEVICE)"
fi

# check if dd is busybox symlink
DD_CMD="/bin/dd"
[ -L "/bin/dd" ] && DD_CMD="${SCRIPT_DIR}/ext/dd"

# check if backup already running
if pgrep -f "dd if=$BACKUP_DEVICE" &> /dev/null; then
    echo "Backup already running. Exiting..."
    exit
fi

# filename with timestamp
BACKUP_FILE="${BACKUP_PATH}/${BACKUP_NAME}_$(date +%Y%m%d_%H%M%S).img.gz"

# perform backup with pv + compression
echo "Starting backup with compression ($COMPRESS_CMD) and progress display..."
$DD_CMD if=$BACKUP_DEVICE bs=1M status=none | $PV_CMD | $COMPRESS_CMD > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi

# delete old backups
if [ "$BACKUP_COUNT" -gt 0 ]; then
    ((BACKUP_COUNT++))
    OLD_FILES=$(ls -t ${BACKUP_PATH}/${BACKUP_NAME}*.img.gz | tail -n +${BACKUP_COUNT})
    if [ -n "$OLD_FILES" ]; then
        echo "Deleting old backups:"
        echo "$OLD_FILES"
        echo "$OLD_FILES" | xargs rm
    fi
fi

# unmount remote share
umount ${BACKUP_MOUNT} || echo "Warning: could not unmount ${BACKUP_MOUNT}"

echo
