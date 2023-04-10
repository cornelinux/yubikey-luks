fido2-luks
==========

This package is forked from https://github.com/cornelinux/yubikey-luks.

This package lets you use a FIDO2 token with the hmac-secret extension
as a strong single factor for LUKS.

Well-known examples of such tokens include all FIDO2 models of Yubikey,
the Google Titan key, the Nitrokey FIDO2, any SoloKey,
and any other [Microsoft-compatible FIDO2 key](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-fido2-hardware-vendor#current-partners).

The keyscript lets you boot the machine with either the FIDO2 token and its PIN,
or with a normal password from any key slot.
For security and to avoid having to support multiple separate use cases,
PIN entry is mandatory for decryption.


Install package
---------------

Build the package (without signing it):

    make builddeb NO_SIGN=1

Install the package:

    dpkg -i DEBUILD/fido2-luks_0.*-1_all.deb


Assign a FIDO2 token to a LUKS slot
-----------------------------------

You can now assign the Yubikey to a slot using the tool

    fido2-luks-enroll

This will cause a few things to happen:
0. (If `-c` was specified) the LUKS keyslot into which to enroll your FIDO2 token is cleared.
   By default, this is keyslot 7.
1. If a FIDO2 credential is not already configured, a new credential is created
   and its corresponding credential identifier and public key are stored in `/etc/fido2-luks.cfg`.
   You will be prompted for your FIDO2 token's PIN and asked to verify your presence.
   If a credential _is_ already configured, it will be reused for subsequent operations.
2. The FIDO2 token computes a HMAC over the UUID of the LUKS volume for which the token is to be
   enrolled and the secret corresponding to the FIDO2 credential created in step 1.
   You will be prompted for your FIDO2 token's PIN and asked to verify your presence.
3. The resulting HMAC is enrolled as a LUKS passphrase on the encrypted device.

This has a few implications:
1. To decrypt a device using your FIDO2 token, you will need the device itself (obviously),
   the token, the token's PIN, and the credential configured in `/etc/fido2-luks.cfg`.
2. If either the credential or the UUID of the encrypted device changes, you will no longer
   be able to decrypt the device using your token until you re-enroll it.
3. If an attacker is able to intercept the HMAC secret (e.g. using an evil maid attack),
   the secret can be used as a normal passphrase to unlock the disk.

It is therefore recommended that you keep a separate recovery key, if you should lose either
your token or your configuration file.


Configuring encrypted root
--------------------------

In order to use your FIDO2 token to decrypt your root disk at boot time, there are still
a few hoops to jump through:

1. Add `ROOT_DISK=<device>` to `/etc/fido2-luks.cfg`, where `<device>` is your encrypted
   root device. `ROOT_DISK` defaults to `/dev/nvme0n1p3`, so if this is your root device
   you do not need to update your configuration file.
2. Add `keyscript=/usr/share/fido2-luks/fido2-luks-keyscript` to the options section of
   the entry in `/etc/crypttab` that corresponds to your encrypted root device.
3. Run `update-initramfs -u`, to make the above changes take effect during boot.


Non-root decryption
-------------------

Any partitions except the root partition can be unlocked at any time using
the `fido2-luks-open` command. This also applies to image files, USB memory sticks, or
anything else that uses LUKS for encryption.

Keep in mind that you will still need the your token, its PIN, and the credential
used to enroll the token, in order to unlock any such device;
make sure to keep a copy of your configuration file along with any encrypted device
intended to be decrypted on a computer other than the one used to enroll your FIDO2 token.


Using multiple FIDO2 tokens
---------------------------
You can configure multiple FIDO2 tokens to unlock your disk, as long as you use a different
LUKS slot for each token.

Only one token may be plugged in during decryption however, as there is no reliable way of
distinguishing one token from another.