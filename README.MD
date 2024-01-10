# Домашнее задание: практические навыки работы с ZFS

Цель:
отработать навыки работы с созданием томов export/import и установкой параметров;

определить алгоритм с наилучшим сжатием;
определить настройки pool’a;
найти сообщение от преподавателей.
составить список команд, которыми получен результат с их выводами.

---

## Решение:

Задание выполнено на машине vagrant с помощью Ansible.

Скрипт `deploy.sh`:
 - создаёт виртуальную машину с помощью Vagrantfile;
 - заускает роль, которая выполняет действия над машиной согласно заданию и записывает каждый шаг в лог;
 - получает лог из виртуальной машины. 

Файл с логом, полученный после отработки роли находится в директории со скриптом `deploy.sh`

<details>
<summary>Содержимое лога</summary>

```bash
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0  512M  0 disk 
sdc                       8:32   0  512M  0 disk 
sdd                       8:48   0  512M  0 disk 
sde                       8:64   0  512M  0 disk 
sdf                       8:80   0  512M  0 disk 
sdg                       8:96   0  512M  0 disk 
sdh                       8:112  0  512M  0 disk 
sdi                       8:128  0  512M  0 disk 


 Посмотрим информацию о пулах (zpool list) 

NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   120K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   120K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   120K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   120K   480M        -         -     0%     0%  1.00x    ONLINE  -


 Посмотрим информацию о пулах (zpool list) 

NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   129K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   129K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   129K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   129K   480M        -         -     0%     0%  1.00x    ONLINE  -


 Посмотрим информацию о сжатии (zfs get all | grep compression) 

otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip                   local
otus4  compression           zle                    local


 Посмотрим на полученный файл (ls -l /otus*) 

/otus1:
total 22066
-rw-r--r--. 1 root root 41006995 Jan  2 08:53 pg2600.converter.log

/otus2:
total 17993
-rw-r--r--. 1 root root 41006995 Jan  2 08:53 pg2600.converter.log

/otus3:
total 11069
-rw-r--r--. 1 root root 41006995 Jan  2 08:53 pg2600.converter.log

/otus4:
total 39836
-rw-r--r--. 1 root root 41006995 Jan  2 08:53 pg2600.converter.log


 Проверим степень сжатия файлов (zfs get all | grep compressratio | grep -v ref) 

otus1  compressratio         1.81x                  -
otus2  compressratio         2.22x                  -
otus3  compressratio         3.61x                  -
otus4  compressratio         1.00x                  -


 Проверим, можно ли импортировать полученный каталог в пул (zpool import -d zpoolexport/) 

   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
	some features will not be available without an explicit 'zpool upgrade'.
 config:

	otus                                 ONLINE
	  mirror-0                           ONLINE
	    /home/vagrant/zpoolexport/filea  ONLINE
	    /home/vagrant/zpoolexport/fileb  ONLINE


 Сделаем импорт данного пула к нам в ОС и посмотрим его статус (zpool import -d zpoolexport/ otus && zpool status 

  pool: otus
 state: ONLINE
status: Some supported features are not enabled on the pool. The pool can
	still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
	the pool may no longer be accessible by software that does not support
	the features. See zpool-features(5) for details.
config:

	NAME                                 STATE     READ WRITE CKSUM
	otus                                 ONLINE       0     0     0
	  mirror-0                           ONLINE       0     0     0
	    /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
	    /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	otus1       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	otus2       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	otus3       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdf     ONLINE       0     0     0
	    sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	otus4       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdh     ONLINE       0     0     0
	    sdi     ONLINE       0     0     0

errors: No known data errors


 Запросим все параметры файловой системы (zfs get all otus) 

NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclmode               discard                default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              off                    default
otus  redundant_metadata    all                    default
otus  overlay               on                     default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default


 Получим несколько конкретных параметров (zfs get available otus) 

NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -


 zfs get readonly otus 

NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default


 zfs get recordsize otus 

NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local


 zfs get compression otus 

NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local


 zfs get checksum otus 

NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local


 Поищем сообщение и добавим его в лог (find /otus/test -name secret_message)  

/otus/test/task1/file_mess/secret_message

```
</details>