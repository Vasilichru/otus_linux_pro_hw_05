# otus_linux_pro_hw_05

Домашнее задание
Работа с mdadm

Цель:
научиться использовать утилиту для управления программными RAID-массивами в Linux
Работа с mdadm

Что нужно сделать?
    добавить в Vagrantfile еще дисков;
    сломать/починить raid;
    собрать R0/R5/R10 на выбор;
    прописать собранный рейд в конф, чтобы рейд собирался при загрузке;
    создать GPT раздел и 5 партиций.


 Доп. задание*

    Vagrantfile, который сразу собирает систему с подключенным рейдом и смонтированными разделами. После перезагрузки стенда разделы должны автоматически примонтироваться.



Задание повышенной сложности**
    перенести работающую систему с одним диском на RAID 1. Даунтайм на загрузку с нового диска предполагается.

    На проверку отправьте
    вывод команды lsblk до и после и описание хода решения (можно воспользоваться утилитой Script).


1. добавление дисков
MACHINES = {
  :otuslinux => {
        :box_name => "ubuntu/jammy64",
        :ip_addr => '192.168.56.101',
	:disks => {
		:sata1 => {
			:dfile => './sata1.vdi',
			:size => 250,
			:port => 1
		},
		:sata2 => {
      :dfile => './sata2.vdi',
      :size => 250, # Megabytes
			:port => 2
		},
    :sata3 => {
      :dfile => './sata3.vdi',
      :size => 250,
      :port => 3
    },
    :sata4 => {
      :dfile => './sata4.vdi',
      :size => 250, # Megabytes
      :port => 4
    },
    :sata5 => {
      :dfile => './sata5.vdi',
      :size => 250,
      :port => 5
    },
    :sata6 => {
      :dfile => './sata6.vdi',
      :size => 250, # Megabytes
      :port => 6
    }

	}
  },
}


2. 