# OpenSUSE Tumbleweed

## Installation
1. Boot into the USB (or other bootable media containing the Linux Mint install ISO) and select Linux Mint.

2. You will get a small screen showing some options, such as **Start Linux Mint** (normal and compatibility mode), **OEM install** and **Memory test** among others. Select the normal **Start Linux Mint**. It's usually the first option.

3. After a few seconds, you will be shown the Linux Mint desktop with a single lonely icon - **Install Linux Mint**. Run this.

4. Select your language and keyboard settings, click **Continue**.

5. Connect to your WiFi, click **Continue**.

6. Check **Install multimedia codecs**, click **Continue**
	1. If you do see this, don't worry. This can be done after the device has been installed as well. Simply go to **Sound & Video** and click on **Install Multimedia Codecs**.

7. Select **Erase disk and install Linux Mint**.
	1. Here, also click on **Advanced Features** and check both **Use LVM with the new Linux Mint installation** as well as **Encrypt the new Linux Mint installation for security**. Click **OK**.
	2. With this done, click **Continue**.

8. You will be prompted to enter a **security key** and a **recovery key**.
	1. For **security key**, enter your encryption password.
		-  **NOTE**: If you are installing a laptop for someone else, you can put a temporary password here, just remember to change it afterwards.
	2. For the **recovery key**, enable it and let the installer generate a secure key. Make sure this is saved in `home/mind/recovery.key` which should be the default.

9. Click on **Install Now** and allow the installer to decide your partitions.
	1. This will most likely result in a swap partition of just 2 gigabytes. We will increase this later, as the advanced partition manager is quite a pain in the ass to do this in.

10. Enter your name, password and username.
	1. Enable **Require my password to log in** and also check **Encrypt my home folder**.
	2. Click **Continue**.

11. The system should now install. Wait for this to complete.
	1. When done, you will be prompted to either continue testing or restart to finish the installation. Here, choose to continue testing and find the `recovery.key` that you previously saved. Save this in 1Password in case it is ever needed. Then delete the file from your laptop and restart the system (it is usually deleted right away after restarting out of the testing mode, but you can never be too sure).

12. Installation done. After logging in, you should see a **"First steps"** window. Some of these can be quite useful. Go through them: 
		1. **Update manager** to install any updates that can be applied.
		2. **Driver manager** to install any drivers that are still missing.
		3. **Firewall** to enable the firewall and change it to the office rule.
    	4. **Timeshift** to enable filesystem backups and make sure they are saved to the correct drive. Check the [Timeshift section](#timeshift) for more info on this.

## TimeShift
Linux Mint comes bundled with Timeshift, a utility used for creating and managing system snapshots. If left unchanged, Timeshift for some reason defaults its backup location to a 1GB partition and runs full within a day. Backups are cool though, so we would 
rather keep this functionality. To set this up, open up Timeshift and click on **Wizard** in the header menu. Then, follow the wizard.

- For snapshot type, select RSYNC.
- For snapshot location, select the largest partiton.
- For snapshot levels, select whatever you feel like. Daily snapshots feels best for me. Keeping 5 means you have a full workweek of backups in case a random update or incorrect install bricks the device.
- For user home directories, stick with the default and exclude everything.
- Finish and exit Timeshift.