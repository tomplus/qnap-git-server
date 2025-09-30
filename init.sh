#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
  echo "Initializes the required environment in your QNAP NAS."
  echo "Requires admin access."
  echo
  echo "Usage: $0 <user>@<qnap-address> <ssh-public-key-path>"
  echo " e.g.: $0 admin@my-qnap.local ~/.ssh/id_rsa.pub"
  exit 1
fi

public_key=$(cat "$2")

embedded_script="cd /share &&
mkdir -p git/.ssh &&
mkdir -p git/pub &&
echo \"$public_key\" > git/.ssh/authorized_keys &&
chown 1000:1000 -R git/ &&
chmod 700 git/ &&
chmod 700 git/.ssh/ &&
chmod 600 git/.ssh/authorized_keys"

output=$(ssh "$1" -v -t "/bin/sh" "-c" "'$embedded_script'" 2>&1)
echo $output
