#!/bin/bash

SSH_USER="pahmil"
KEY_PATH="/home/pahmil/.ssh/id_rsa"

if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
fi

if ! ssh-add -l | grep -q "$KEY_PATH"; then
    echo "Adding SSH key to agent..."
    ssh-add "$KEY_PATH"
    if [ $? -ne 0 ]; then
        echo "❌ Gagal menambahkan SSH key. Pastikan path dan passphrase benar."
        exit 1
    fi
fi

for ip in $(cat ip.txt); do
    echo -n "Checking $ip... "
    ssh -o BatchMode=yes \
    -o ConnectTimeout=5 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    -o HostKeyAlgorithms=+ssh-rsa \
    "$SSH_USER@$ip" "echo OK" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo "$ip: ❌ SSH access FAILED"
    fi
done