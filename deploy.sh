# /bin/bash


## Убираем всё из known_hosts, потому что не получилось сделать так,
## чтобы при выполнении ansible-playbook known_hosts не проверялся 
echo "" > ~/.ssh/known_hosts 

echo "Создаём виртуальную машину vagrant"
cd vagrant && vagrant up

sleep 60
vagrant snapshot push

echo "Выполняем действия над zfs"
cd ..
ansible-playbook ansible/playbooks/manage_zfs.yaml -i ansible/inventory/hosts -b  -v
mv ansible/centos_zfs/tmp/logfile .
rm -rf ansible/centos_zfs
echo "Файл с логом находится рядом со скриптом"