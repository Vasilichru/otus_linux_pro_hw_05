#!/bin/bash
#raid script

#superblock cleaning
sudo mdadm --zero-superblock --force /dev/sd{c,d,e,f,g}

#creating raid 6
sudo mdadm --create --verbose /dev/md0 -l 6 -n 4 /dev/sd{c,d,e,f}

#check raid 
cat /proc/mdstat

#check raid
sudo mdadm -D /dev/md0

#check raid info
mdadm --detail --scan --verbose

#creating mdadm.conf
sudo -i
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
exit

