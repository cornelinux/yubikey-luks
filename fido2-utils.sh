#!/bin/sh
FIDO2_RELYING_PARTY="yubikey-luks.cornelinux.github.com"
FIDO2_USERNAME="ykluks"
FIDO2_CREDENTIAL_ID=
FIDO2_CREDENTIAL_PUBKEY=

sha256_base64() {
    # Computes SHA256 over the given argument, converts the hash to a binary blob, and returns the
    # base64 encoding of said blob.
    /usr/bin/printf $(printf '%s' "$1" | sha256sum | awk '{print $1}' | sed -e 's/\([0-9a-f]\{2\}\)/\\x\1/g') | base64 -w0
}

fido2_salt_from_blkid() {
    sha256_base64 "$(blkid -o value "$1" | head -1)"
}

fido2_device() {
    fido2-token -L | sed 's/:.*//'
}

fido2() {
    [ "$YUBIKEY_LUKS_SLOT" = "fido2" ]
}

fido2_temp_keyfile() {
    local keyfile=$(mktemp)
    echo "$FIDO2_CREDENTIAL_PUBKEY" | base64 -d > $keyfile
    echo $keyfile
}

fido2_authenticate() {
    param_file=$(mktemp)
    dd if=/dev/urandom bs=1 count=32 2> /dev/null | base64 > $param_file
    echo "$FIDO2_RELYING_PARTY" >> $param_file
    echo "$FIDO2_CREDENTIAL_ID" >> $param_file
    fido2_salt_from_blkid >> $param_file

    assertion=$(echo "$1" | setsid fido2-assert -G -h -v -i "$param_file" $(fido2_device) 2> /dev/null || (rm -f $param_file ; echo "Wrong PIN." 1>&2 ; exit 1))
    rm -f $param_file

    keyfile=$(fido2_temp_keyfile)
    echo "$assertion" | head -n4 | fido2-assert -V -h "$keyfile" || (rm -f $keyfile ; exit 1)
    rm -f $keyfile
    printf '%s' "$assertion" | tail -1
}
