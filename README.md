# otus_linux_pro_hw_05

Домашнее задание
Работа с mdadm

Цель:
научиться использовать утилиту для управления программными RAID-массивами в Linux
Работа с mdadm

Что нужно сделать?
    добавить в Vagrantfile еще дисков; +
    сломать/починить raid; +
    собрать R0/R5/R10 на выбор; +
    прописать собранный рейд в конф, чтобы рейд собирался при загрузке; +
    создать GPT раздел и 5 партиций. +


 Доп. задание*

    Vagrantfile, который сразу собирает систему с подключенным рейдом и смонтированными разделами. После перезагрузки стенда разделы должны автоматически примонтироваться.



Задание повышенной сложности**
    перенести работающую систему с одним диском на RAID 1. Даунтайм на загрузку с нового диска предполагается.

    На проверку отправьте
    вывод команды lsblk до и после и описание хода решения (можно воспользоваться утилитой Script).


1. добавление дисков на тот же контроллер(!)

      (0..4).each do |i|
      box.vm.disk :disk, size: "250MB", name: "hdd-#{i}"
      end


2. создание рейда 6
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


3. сломать/починить рейд
#fail device
sudo mdadm /dev/md0 --fail /dev/sde

#check raid
cat /proc/mdstat 

#show devices
sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon May 20 13:08:45 2024
        Raid Level : raid6
        Array Size : 507904 (496.00 MiB 520.09 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Mon May 20 13:29:01 2024
             State : clean, degraded 
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raidtest:0  (local to host raidtest)
              UUID : 4fe1bbb0:0bebe1f6:65617181:286619e2
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       -       0        0        2      removed
       3       8       80        3      active sync   /dev/sdf

       2       8       64        -      faulty   /dev/sde


#remove bad device
vagrant@raidtest:~$ sudo mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0

#check raid
cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid6 sdf[3] sdd[1] sdc[0]
      507904 blocks super 1.2 level 6, 512k chunk, algorithm 2 [4/3] [UU_U]
      
unused devices: <none>

#check raid status
sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon May 20 13:08:45 2024
        Raid Level : raid6
        Array Size : 507904 (496.00 MiB 520.09 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 4
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Mon May 20 13:31:49 2024
             State : clean, degraded 
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : raidtest:0  (local to host raidtest)
              UUID : 4fe1bbb0:0bebe1f6:65617181:286619e2
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       -       0        0        2      removed
       3       8       80        3      active sync   /dev/sdf

#lsblk
lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0    7:0    0  63.3M  1 loop  /snap/core20/1879
loop1    7:1    0 111.9M  1 loop  /snap/lxd/24322
loop2    7:2    0  53.2M  1 loop  /snap/snapd/19122
sda      8:0    0    40G  0 disk  
└─sda1   8:1    0    40G  0 part  /
sdb      8:16   0    10M  0 disk  
sdc      8:32   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 
sdd      8:48   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 
sde      8:64   0   250M  0 disk  
sdf      8:80   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 
sdg      8:96   0   250M  0 disk  



#add new disk to raid
sudo mdadm /dev/md0 --add /dev/sdg
mdadm: added /dev/sdg

#check raid
cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid6 sdg[4] sdf[3] sdd[1] sdc[0]
      507904 blocks super 1.2 level 6, 512k chunk, algorithm 2 [4/4] [UUUU]
      
unused devices: <none>


lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0    7:0    0  63.3M  1 loop  /snap/core20/1879
loop1    7:1    0 111.9M  1 loop  /snap/lxd/24322
loop2    7:2    0  53.2M  1 loop  /snap/snapd/19122
sda      8:0    0    40G  0 disk  
└─sda1   8:1    0    40G  0 part  /
sdb      8:16   0    10M  0 disk  
sdc      8:32   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 
sdd      8:48   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 
sde      8:64   0   250M  0 disk  
sdf      8:80   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 
sdg      8:96   0   250M  0 disk  
└─md0    9:0    0   496M  0 raid6 


#raid is ok

4.создать ГПТ раздел, пять партиций, смонтировать их на диск

#create
sudo parted -s /dev/md0 mklabel gpt

#check
sudo fdisk -l /dev/md0
Disk /dev/md0: 496 MiB, 520093696 bytes, 1015808 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 524288 bytes / 1048576 bytes
Disklabel type: gpt
Disk identifier: 2ECAF497-F2F0-4A8C-9334-42278050219

#create partitions
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

#check is ok
lsblk                                                 
NAME      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0       7:0    0  63.3M  1 loop  /snap/core20/1879
loop1       7:1    0 111.9M  1 loop  /snap/lxd/24322
loop2       7:2    0  53.2M  1 loop  /snap/snapd/19122
sda         8:0    0    40G  0 disk  
└─sda1      8:1    0    40G  0 part  /
sdb         8:16   0    10M  0 disk  
sdc         8:32   0   250M  0 disk  
└─md0       9:0    0   496M  0 raid6 
  ├─md0p1 259:1    0    98M  0 part  
  ├─md0p2 259:4    0    99M  0 part  
  ├─md0p3 259:5    0   100M  0 part  
  ├─md0p4 259:8    0    99M  0 part  
  └─md0p5 259:9    0    98M  0 part  
sdd         8:48   0   250M  0 disk  
└─md0       9:0    0   496M  0 raid6 
  ├─md0p1 259:1    0    98M  0 part  
  ├─md0p2 259:4    0    99M  0 part  
  ├─md0p3 259:5    0   100M  0 part  
  ├─md0p4 259:8    0    99M  0 part  
  └─md0p5 259:9    0    98M  0 part  
sde         8:64   0   250M  0 disk  
sdf         8:80   0   250M  0 disk  
└─md0       9:0    0   496M  0 raid6 
  ├─md0p1 259:1    0    98M  0 part  
  ├─md0p2 259:4    0    99M  0 part  
  ├─md0p3 259:5    0   100M  0 part  
  ├─md0p4 259:8    0    99M  0 part  
  └─md0p5 259:9    0    98M  0 part  
sdg         8:96   0   250M  0 disk  
└─md0       9:0    0   496M  0 raid6 
  ├─md0p1 259:1    0    98M  0 part  
  ├─md0p2 259:4    0    99M  0 part  
  ├─md0p3 259:5    0   100M  0 part  
  ├─md0p4 259:8    0    99M  0 part  
  └─md0p5 259:9    0    98M  0 part  


#make fs
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

#check fs are presents
lsblk -f
NAME      FSTYPE            FSVER            LABEL           UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0     squashfs          4.0                                                                         0   100% /snap/core20/1879
loop1     squashfs          4.0                                                                         0   100% /snap/lxd/24322
loop2     squashfs          4.0                                                                         0   100% /snap/snapd/19122
sda                                                                                                              
└─sda1    ext4              1.0              cloudimg-rootfs 797d6024-2abd-47cc-9d72-a7f203baad82   37.3G     4% /
sdb       iso9660           Joliet Extension cidata          2023-05-10-02-43-13-00                              
sdc       linux_raid_member 1.2              raidtest:0      4fe1bbb0-0beb-e1f6-6561-7181286619e2                
└─md0                                                                                                            
  ├─md0p1 ext4              1.0                              05016bc4-bd7c-47f5-9c8d-62ae1c0bb9e7                
  ├─md0p2 ext4              1.0                              3f01127a-456f-4c1d-845f-764982582c35                
  ├─md0p3 ext4              1.0                              9c23360c-c360-4fc2-9bbc-507ad6e14328                
  ├─md0p4 ext4              1.0                              7c304cad-f958-46c2-abbe-ce89a099011e                
  └─md0p5 ext4              1.0                              9b908a0c-b427-482f-aa97-fedec2b6f612                
sdd       linux_raid_member 1.2              raidtest:0      4fe1bbb0-0beb-e1f6-6561-7181286619e2                
└─md0                                                                                                            
  ├─md0p1 ext4              1.0                              05016bc4-bd7c-47f5-9c8d-62ae1c0bb9e7                
  ├─md0p2 ext4              1.0                              3f01127a-456f-4c1d-845f-764982582c35                
  ├─md0p3 ext4              1.0                              9c23360c-c360-4fc2-9bbc-507ad6e14328                
  ├─md0p4 ext4              1.0                              7c304cad-f958-46c2-abbe-ce89a099011e                
  └─md0p5 ext4              1.0                              9b908a0c-b427-482f-aa97-fedec2b6f612                
sde       linux_raid_member 1.2              raidtest:0      4fe1bbb0-0beb-e1f6-6561-7181286619e2                
sdf       linux_raid_member 1.2              raidtest:0      4fe1bbb0-0beb-e1f6-6561-7181286619e2                
└─md0                                                                                                            
  ├─md0p1 ext4              1.0                              05016bc4-bd7c-47f5-9c8d-62ae1c0bb9e7                
  ├─md0p2 ext4              1.0                              3f01127a-456f-4c1d-845f-764982582c35                
  ├─md0p3 ext4              1.0                              9c23360c-c360-4fc2-9bbc-507ad6e14328                
  ├─md0p4 ext4              1.0                              7c304cad-f958-46c2-abbe-ce89a099011e                
  └─md0p5 ext4              1.0                              9b908a0c-b427-482f-aa97-fedec2b6f612                
sdg       linux_raid_member 1.2              raidtest:0      4fe1bbb0-0beb-e1f6-6561-7181286619e2                
└─md0                                                                                                            
  ├─md0p1 ext4              1.0                              05016bc4-bd7c-47f5-9c8d-62ae1c0bb9e7                
  ├─md0p2 ext4              1.0                              3f01127a-456f-4c1d-845f-764982582c35                
  ├─md0p3 ext4              1.0                              9c23360c-c360-4fc2-9bbc-507ad6e14328                
  ├─md0p4 ext4              1.0                              7c304cad-f958-46c2-abbe-ce89a099011e                
  └─md0p5 ext4              1.0                              9b908a0c-b427-482f-aa97-fedec2b6f612  

#mount fs
sudo mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
