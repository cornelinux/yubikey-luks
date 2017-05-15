Yubikey for LUKS
================

This package is inspired and based on https://github.com/tfheen/ykfde.

This enables you to use the yubikey as 2FA for LUKS.
The Password you enter is used as challenge for the yubikey

The keyscript allows to boot the machine with either
the password and the Yubikey or with a normal password
from any key slot.

initialize Yubikey
------------------

Initialize the Yubikey for challenge response in slot 2

	ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible

install package
---------------

Build the package:

	make builddeb

Install the package:

	dpkg -i DEBUILD/yubikey-luks_0.?-1_all.deb

Assign a Yubikey to an LUKS slot
--------------------------------

You can now assign the Yubikey to a slot using the tool

	yubikey-luks-enroll

Technically this is done by writing the response to your password (1st factor
knowlege) created by the Yubikey (2nd factor possession) to a key slot.

Admitted - If the attacker was able to phish this response which looks like
this:
	bd438575f4e8df965c80363f8aa6fe1debbe9ea9
it can be used as normal password.

Changing the welcome text
-------------------------

If you want to change the welcome text a.k.a. the passphrase prompt you can edit
the file /etc/ykluks.cfg.

After changing this file, you need to run

  update-initramfs -u

so that the changes get transferred to the initramfs.

Manage several Yubikeys and Machines
------------------------------------

It is possible to manage several Yubikeys and machines.
You need to use privacyIDEA to manage the Yubikeys and
the privacyIDEA admin client to push the Yubikey responses
to the LUKS slots.

See https://github.com/privacyidea/privacyideaadm and
https://github.com/privacyidea/privacyidea
