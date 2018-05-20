#!/bin/bash

if [ ! -f "custom/authorized_keys" ]; then
  echo "ERROR: must have custom/authorized_keys for SSH keys"
  echo ""
  exit 1
fi

if [ ! -f "custom/setup-in-chroot-custom.sh" ]; then
  echo "WARNING: no custom setup procedures detected, only base rospi img will be created"
  echo ""
else
  if [ ! -x "custom/setup-in-chroot-custom.sh" ]; then
    echo "ERROR: custom/setup-in-chroot-custom.sh must be executable"
    echo ""
    exit 1
  fi
fi

if [ "$(whoami)" != "root" ]; then
  echo "ERROR: must build system image as root"
  echo ""
  exit 1
fi

echo "all checks passed: build should be able to complete normally"
