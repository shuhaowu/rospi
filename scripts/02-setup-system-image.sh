#!/bin/bash

image=$1
hostname=$2
size_adjustment=$3

build_dir=$(dirname $image)
rootfs_dir=$build_dir/rootfs
boot_dir=$build_dir/boot

set -xe

echo "Expanding partition by $size_adjustment"
truncate -s $size_adjustment $image
partition_end=$(parted $image print | grep $(basename $image) | cut -f 2 -d ":" | grep -o '[0-9]\+')
parted $image resizepart 2 $partition_end

echo "Setting up loop device"
loop_device=$(losetup -P --show -f $image)
ls ${loop_device}*
if [ "$(ls ${loop_device}* | wc -w)" != 3 ]; then
  echo "ERROR: there are not enough loop devices setup" >&2
  echo "ERROR: ls -l $loop_device shows:" >&2
  ls -l ${loop_device}* >&2
  losetup -d $loop_device
  exit 1
fi

e2fsck -f ${loop_device}p2
resize2fs ${loop_device}p2

echo "Mounting image..."
mount ${loop_device}p1 ${boot_dir}
mount ${loop_device}p2 ${rootfs_dir}

df -h $rootfs_dir

cp /usr/bin/qemu-arm-static ${rootfs_dir}/usr/bin/
mv ${rootfs_dir}/etc/resolv.conf ${rootfs_dir}/etc/resolv.conf.bak
echo "nameserver 1.1.1.1" >> ${rootfs_dir}/etc/resolv.conf
echo "nameserver 8.8.8.8" >> ${rootfs_dir}/etc/resolv.conf
cp scripts/03-setup-in-chroot-core.sh ${rootfs_dir}/setup-core.sh
cp custom/authorized_keys ${rootfs_dir}/authorized_keys

cp -r system-image/rootfs/. ${rootfs_dir}

mount -o bind /dev ${rootfs_dir}/dev
mount -o bind /dev/pts ${rootfs_dir}/dev/pts
mount -o bind /sys ${rootfs_dir}/sys
mount -o bind /proc ${rootfs_dir}/proc

chroot ${rootfs_dir} env -i HOME=/root /setup-core.sh $hostname

if [ -d custom/rootfs ]; then
  cp -r custom/rootfs/. ${rootfs_dir}
fi

if [ -f custom/setup-in-chroot-custom.sh ]; then
  cp custom/setup-in-chroot-custom.sh ${rootfs_dir}/setup-custom.sh
  chroot ${rootfs_dir} env -i HOME=/root /setup-custom.sh
fi

pushd ${rootfs_dir}
rm etc/resolv.conf
mv etc/resolv.conf.bak /etc/resolv.conf
rm setup-core.sh
rm -f setup-custom.sh
rm usr/bin/qemu-arm-static

umount -fl dev/pts
umount -fl dev
umount -fl sys
umount -fl proc
popd

umount ${rootfs_dir}
umount ${boot_dir}

losetup -d ${loop_device}
