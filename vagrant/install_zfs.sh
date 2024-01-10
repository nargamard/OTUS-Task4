# /bin/bash

yum erase zfs zfs-dkms libzfs2 spl spl-dkms libzpool2 -y
yum install zfs -y
/sbin/modprobe zfs