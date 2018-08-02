Yubikey for LUKS
================

This package is inspired and based on https://github.com/tfheen/ykfde.

This enables you to use the yubikey as 2FA for LUKS.
The Password you enter is used as challenge for the yubikey

The keyscript allows to boot the machine with either
the password and the Yubikey or with a normal password
from any key slot.

luksSuspend/luksResume integration is inspired and based on https://github.com/zhongfu/ubuntu-luks-suspend

initialize Yubikey
------------------

Initialize the Yubikey for challenge response in slot 2

	ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible

install package
---------------

Build the package (without signing it):

	make builddeb NO_SIGN=1

Install the package:

	dpkg -i DEBUILD/yubikey-luks_0.?-1_all.deb

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

If you set HASH=1 option in the file /etc/ykluks.cfg then your password will be hashed with sha256 algorithm or your configured hashing command before using as challenge for yubikey: printf password | $HASH_COMMAND $HASH_ARGS | awk '{print $1}'
5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8

If you set HASH_COMMAND in the file /etc/ykluks.cfg then your password will be hashed with the custom command instead of sha256sum. This must be the full path to the binary without arguments such as HASH_COMMAND=/usr/bin/custom-hasher

If you set HASH_ARGS in the file /etc/ykluks.cfg the arguments will be passed to $HASH_COMMAND when it is run to hash the password.

```
HASH_COMMAND=/usr/bin/custom-hasher
HASH_ARGS="--cost=14 --salt=99bcda088e1aec8934aafb6c7f49f284"
printf password | /usr/bin/custom-hasher --cost=14 --salt=99bcda088e1aec8934aafb6c7f49f284 | awk '{print $1}'
```

Changing the welcome text
-------------------------

If you want to change the welcome text a.k.a. the passphrase prompt you can edit
the file /etc/ykluks.cfg.

After changing this file, you need to run

  update-initramfs -u

so that the changes get transferred to the initramfs.

Enable yubikey-luks-suspend module
------------------------------------

You can enable yubikey-luks-suspend module which allows for automatically locking encrypted LUKS containers and wiping keys from memory on suspend and unlocking them on resume by using luksSuspend, luksResume commands.

        systemctl enable yubikey-luks-suspend.service

Open LUKS container protected with yubikey-luks
------------------------------------

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
