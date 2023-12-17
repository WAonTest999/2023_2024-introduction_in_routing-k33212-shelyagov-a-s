#!/bin/bash
mkdir /root/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAO8lVSwDTQ11hg2FWAQmCMPI1yLzVLdYxkE0n4QvyIq' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

apt-get update > /dev/null

DEBIAN_FRONTEND=noninteractive apt-get install -y iproute2 iputils-ping sudo net-tools isc-dhcp-client openssh-server mtr > /dev/null

echo "ubuntu" | sudo adduser "ubuntu"
echo  "ubuntu:ubuntu" | sudo chpasswd

usermod -aG sudo "ubuntu"
service ssh start

sudo dhclient eth1
