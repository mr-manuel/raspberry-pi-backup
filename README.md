# Raspberry Pi backup script

<small>GitHub repository: [eckonator/raspberry-pi-backup](https://github.com/eckonator/raspberry-pi-backup)</small>

---

### Changelog

**v0.0.10-gzip-pv** – 2025-10-13  

- Backups are now automatically compressed using `gzip` or `pigz` to save disk space.  
- Live progress and estimated completion time are displayed using `pv`.  
- Old backup deletion logic updated to handle `.img.gz` files.  
- Maintains full SD card backup including empty blocks.  

---

### Disclaimer

I wrote this script for myself. I'm not responsible if you damage something using my script.

---

### Supporting/Sponsoring this project

You like the project and you want to support the original author?

[<img src="https://github.md0.eu/uploads/donate-button.svg" height="50">](https://www.paypal.com/donate/?hosted_button_id=3NEVZBDM5KABW)

---

### Purpose

The script backups the whole SD card (including empty blocks) of a Raspberry Pi to a SMB/CIFS share on a NAS or computer without removing the SD card. It works also with Venus OS from Victron Energy.

**Note:** The backup will always have the same size as your SD card. This ensures compatibility on many systems without installing additional software.

---

### Config

Copy the `backup.sample.conf` to `backup.conf` and modify the variables in `backup.conf` using `nano`, `vi`, `vim`, or your preferred editor.

- Standard install path: `/opt/raspberry-pi-backup`  
- Venus OS install path: `/data/etc/raspberry-pi-backup`

---

### Install

1. Download and install the script:

    ```bash
    wget -O install-backup.sh https://raw.githubusercontent.com/eckonator/raspberry-pi-backup/master/install-backup.sh
    bash install-backup.sh
    ```

2. Modify the needed parameters in `backup.conf`.

3. Run the script manually or set up a cronjob to run the backup automatically. You can use the [Crontab Generator](https://crontab-generator.org/).

    **Command to execute:**

    - On standard Linux: `/opt/raspberry-pi-backup/backup.sh`  
    - On Venus OS: `/data/etc/raspberry-pi-backup/backup.sh`  

    **Note:** After a Venus OS update, you may need to set up the cronjob again.

---

### Uninstall

Remove the cronjob (if any) and delete the folder with the script.

---

### Debugging

Run the script directly and check the output. If `pv` is installed, a live progress display will show the backup status.

---

### Restore SD card

Turn off the Raspberry Pi, remove the SD card, and insert it into your computer. Write the backup image file (compressed `.img.gz`) to the SD card with [Balena Etcher](https://github.com/balena-io/etcher) or another tool you prefer.

If the backup file is compressed, decompress it first:

```bash
gzip -d Backup_hostname_YYYYMMDD_HHMMSS.img.gz
