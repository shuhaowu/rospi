#!/bin/bash --login

HOSTNAME=$1
PASSWORD=$2

ROS_RELEASE=kinetic

if [ -z "$HOSTNAME" ]; then
  echo "ERROR: must pass hostname as the first argument." >&2
  exit 1
fi

addgroup_if_not_exists() {
  if ! grep $1 /etc/group; then
    addgroup --system $1
  fi
}

set -xe

# Installing base ROS stuff
# =========================

apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
apt-get update
apt-get install -y ros-$ROS_RELEASE-ros-base

# User management
# ===============

# Adding the robot user
# ---------------------

adduser --gecos "" --disabled-password --shell /bin/bash robot
addgroup_if_not_exists dialout
addgroup_if_not_exists input
addgroup_if_not_exists plugdev
addgroup_if_not_exists spi
addgroup_if_not_exists i2c
addgroup_if_not_exists gpio
addgroup_if_not_exists netdev

usermod -a -G dialout,input,plugdev,spi,i2c,gpio,netdev robot

mkdir -p /home/robot/.ros
chown -R robot:robot /home/robot/.ros

# Adding the human user
# ---------------------

adduser --gecos "" --disabled-password human

mkdir -p /home/human/.ssh
chown -R human:human /home/human/.ssh
cp /authorized_keys /home/human/.ssh/authorized_keys
chmod 0700 /home/human/.ssh
chmod 0600 /home/human/.ssh/authorized_keys

echo "human ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/human-sudoer

if [ ! -z "$PASSWORD" ]; then
  echo "human:$PASSWORD" | chpasswd
fi

# Configuring the hostname
# ========================

echo $HOSTNAME > /etc/hostname

cat <<EOF >/etc/hosts
127.0.0.1 localhost
127.0.1.1 $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

# Setting up quirks and services
# ==============================

systemctl enable roscore
systemctl disable systemd-networkd-wait-online
systemctl mask systemd-networkd-wait-online

# Not quite sure why this is needed:
# https://github.com/bmwcarit/meta-ros/pull/225
touch /opt/ros/$ROS_RELEASE/.catkin
chown robot:robot /opt/ros/$ROS_RELEASE/.catkin

# https://bugs.launchpad.net/ubuntu-pi-flavour-maker/+bug/1585335
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
