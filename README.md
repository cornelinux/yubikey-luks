Yubikey for LUKS
================

This package is inspired and based on https://github.com/tfheen/ykfde.

This enables you to use the yubikey as 2FA for LUKS.
The Password you enter is used as challenge for the yubikey

The keyscript allows to boot the machine with either
the password and the Yubikey or with a normal password
from any key slot.

luksSuspend/luksResume integration is inspired and based on https://github.com/zhongfu/ubuntu-luks-suspend

Initialize Yubikey
------------------

Initialize the Yubikey for challenge response in slot 2

    ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible

Install package
---------------

Build the package (without signing it):

    make builddeb NO_SIGN=1

Install the package:

    dpkg -i DEBUILD/yubikey-luks_0.*-1_all.deb

Assign a Yubikey to an LUKS slot
--------------------------------

You can now assign the Yubikey to a slot using the tool

    yubikey-luks-enroll

Technically this is done by writing the response to your password (1st factor
knowledge) created by the Yubikey (2nd factor possession) to a key slot.

Admitted - If the attacker was able to phish this response which looks like
this:
    bd438575f4e8df965c80363f8aa6fe1debbe9ea9
it can be used as normal password.

If you set CONCATENATE=1 option in the file /etc/ykluks.cfg then both your password and Yubikey response will be bundled together and written to key slot: passwordbd438575f4e8df965c80363f8aa6fe1debbe9ea9

If you set HASH=1 option in the file /etc/ykluks.cfg then your password will be hashed with sha256 algorithm before using as challenge for yubikey: printf password | sha256sum | awk '{print $1}'
5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8


Changing the welcome text
-------------------------

If you want to change the welcome text a.k.a. the passphrase prompt you can edit
the file /etc/ykluks.cfg.

After changing this file, you need to run

    update-initramfs -u

so that the changes get transferred to the initramfs.

Use "weak" 1FA to allow unattended, passwordless boot on any hardware
---------------------------------------------------------------------

In order to bypass the password prompt and allow the system to boot when the paired Yubikey is present without requiring interactive input of the challenge password, then you must edit /etc/ykluks.cfg to contain the challenge password that you previously enrolled (and which should be bypassed). Example: 

    YUBIKEY_CHALLENGE="enrolled-challenge-password"

Leave this empty, if you want to do 2FA -- i.e. being asked for the password during boot time.

Note that 1FA, when using this feature, will weaken security as it no longer prompts for the chalenge password and will decrypt the volume with only the Yubikey being present at boot time.

After changing this file, you need to run

    update-initramfs -u

so that the changes get transferred to the initramfs.

Use "more-secure" 1FA to allow passwordless boot only on certain hardware
-------------------------------------------------------------------------

In order to bypass the password prompt and allow the system to boot when the paired Yubikey is present without requiring interactive input of the challenge password, the challenge password is calculated based on a hash of the output of a command which returns hardware info and serial numbers (`dmidecode -t system`). To enable, uncomment this line in /etc/ykluks.cfg

    YUBIKEY_CHALLENGE_HARDWARE_HASH=1

The challenge password is calculated based off the hash of the dmidecode output like this:

    dmidecode -t system | sha256sum | awk '{print $1}')

Notes: 
 - To make this work with multiple machines, run `yubikey-luks-enroll -s <LUKS slot>` with a different LUKS slot for each machine (default is 7). 
 - An added degree of security is optained as an attacker will need access to all of: 
   - Your bootable medium (eg your SSD)
   - Computer that you use (for the `dmidecode` output)
   - Yubikey in order to decrypt the LUKS encrypted partition
 - The `YUBIKEY_CHALLENGE` setting has no effect if `YUBIKEY_CHALLENGE_HARDWARE_HASH=1` uncommented

Enable yubikey-luks initramfs module
------------------------------------

In order to use yubikey-luks for unlocking LUKS encrypted volume at boot you must append keyscript=/usr/share/yubikey-luks/ykluks-keyscript to the /etc/crypttab file. Example:

    cryptroot /dev/sda none  luks,keyscript=/usr/share/yubikey-luks/ykluks-keyscript

After changing this file, you need to run

    update-initramfs -u

so that the changes get transferred to the initramfs.

Alternatively you may add keyscript=/sbin/ykluks-keyscript to your boot cmdline in cryptoptions. Example:

    cryptoptions=target=cryptroot,source=/dev/sda,keyscript=/sbin/ykluks-keyscript

Enable yubikey-luks-suspend module
----------------------------------

You can enable yubikey-luks-suspend module which allows for automatically locking encrypted LUKS containers and wiping keys from memory on suspend and unlocking them on resume by using luksSuspend, luksResume commands.
 
    systemctl enable yubikey-luks-suspend.service

Open LUKS container protected with yubikey-luks
-----------------------------------------------

You can open LUKS container protected with yubikey-luks on running system

    yubikey-luks-open

Manage several Yubikeys and Machines
------------------------------------

It is possible to manage several Yubikeys and machines.
You need to use privacyIDEA to manage the Yubikeys and
the privacyIDEA admin client to push the Yubikey responses
to the LUKS slots.

See https://github.com/privacyidea/privacyideaadm and
https://github.com/privacyidea/privacyidea
