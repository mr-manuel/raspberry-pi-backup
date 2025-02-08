# Raspberry Pi backup script

<small>GitHub repository: [mr-manuel/raspberry-pi-backup](https://github.com/mr-manuel/raspberry-pi-backup)</small>

### Disclaimer

I wrote this script for myself. I'm not responsible, if you damage something using my script.


### Supporting/Sponsoring this project

You like the project and you want to support me?

[<img src="https://github.md0.eu/uploads/donate-button.svg" height="50">](https://www.paypal.com/donate/?hosted_button_id=3NEVZBDM5KABW)


### Purpose

The script backups the whole SD card (also empty blocks) of a Raspberry Pi to a SMB/CIFS share on a NAS/computer without the need to remove the SD card. It works also with Venus OS from Victron Energy.

NOTE: It's not possible to change the used method to not backup empty blocks. The backup will always have the same size as your SD card is. Therefore it works on many systems without installing additional software.


### Config

Copy the `backup.sample.conf` to `backup.conf` and change the variables in the `backup.conf` with `nano`, `vi`, `vim` or the editor of your choise.

Standard install path `/opt/raspberry-pi-backup`

Venus OS install path `/data/etc/raspberry-pi-backup`


### Install

1. Execute this commands to download and install the script:
    ```bash
    wget -O install-backup.sh https://raw.githubusercontent.com/mr-manuel/raspberry-pi-backup/master/install-backup.sh
    bash install-backup.sh
    ```

2. Modify the needed parameters by changing the `backup.sh` script.

3. Run the script on demand or setup a cronjob, if you want to run the backup automatically. You can use the [Contab Generator](https://crontab-generator.org/).

    Command to execute:

    On standard Linux `/opt/raspberry-pi-backup/backup.sh`

    On Venus OS `/data/etc/raspberry-pi-backup/backup.sh`

    NOTE: After a Venus OS update you have to setup the cronjob again.

### Uninstall

Remove the cronjob (if any) and delete the folder with the script.

### Debugging

Run the script directly and check the output.

### Restore SD card

Turn off the Raspberry Pi, remove the SD card and insert it in your computer. Write the backup image file to the SD card with [Balena Etcher](https://github.com/balena-io/etcher) or the tool you prefer.
