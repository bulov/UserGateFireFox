
 Запуск firefox с уникальным IP для учета в UserGate на терминальном сервере AstraLinux
 на основе https://blogs.igalia.com/dpino/2016/05/02/network-namespaces-ipv6/

   Схема взаимодействия:
 Internet <-> UserGate <-> eth1-ts-dmz-eth0 <-> LAN <-> ПК1...ПКN
                            |
                           brFF
                            |-firefox1 IP 192.168.X.Y
                            |-...
                            |-firefoxN IP 192.168.x.y

 ts-dmz терминальный сервер на AstraLinux c поддержкой xrdp
 ПК-машины с ОС Linux или Windows

   Описание работы:
 По rdp или remmina входим на терминальный сервер
 При вызове firefox создается network namespace c IP как функция от id
 Со стороны UserGate все выглядит как пользователь работает со своего ПК

   Посмотреть:
 ls -l /run/netns
 -r--r--r-- 1 root root 0 дек  6 09:03 1000
 -r--r--r-- 1 root root 0 дек  6 09:42 442658651
 -r--r--r-- 1 root root 0 дек  7 10:10 442657190
 -r--r--r-- 1 root root 0 дек  7 18:45 442658056

   Установить:
 git clone https://github.com/bulov/UserGateFireFox
 cd UserGateFireFox
 sudo nsFF_install.sh
Шаг 0 создаем /usr/local/bin/firefox
Шаг 1 настраиваем в /etc/sudoers вызов по sudo /usr/local/bin/nsFF.sh
Шаг 2 настраиваем иконку /usr/share/applications/firefox.desktop
Шаг 3 настраиваем поиск firefox из /usr/local/bin
Шаг 4 создаем коммутатор для сети firefox
Шаг 5 создаем карту eth1 в сторону UserGate
Шаг 6 установить запуск firefox со своим IP /usr/local/bin/nsFF.sh
Шаг 7 Проверить: sudo nsFF.sh xrdp ip a

 sudo nsFF.sh xrdp ip a 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
66: v-117@if67: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000 link-netnsid 0
    inet 192.168.323.200/24 scope global v-442658056
       valid_lft forever preferred_lft forever

   Доработать напильником под свою LAN /usr/local/bin/nsFF.sh ;)

 GW=192.168.0.1
 IP="192.168.$(((${i}>>8)%256)).$((${i}%256))/16"

   Как делается основные шаги:
ip netns del   ${ID} &>/dev/null                       # Удаляем пространство имен
ip link  del e-${ID} &>/dev/null                       # Удаляем устройство
ip netns add   ${ID}                                   # Создаем пространство имен
ip link  add name e-${ID} type veth peer name v-${ID}  # Создаем пару виртуальных устройств
ip link  set dev  e-${ID} master ${BR}                 # Привязываем к мосту (host)
ip link  set dev  e-${ID} up                           # Активизируем устройство (host)
ip link  set dev  v-${ID} netns ${ID}                  # Передаем v-${ID} в пространство имен (network namespace)
ip netns exec ${ID} ip link set dev lo up              # Активизируем lo в пространстве имен.
ip netns exec ${ID} ip addr add ${IP} dev v-${ID}      # Назначаем адрес.
ip netns exec ${ID} ip link set dev v-${ID} up         # Активизируем устройство.
ip netns exec ${ID} ip route add default via ${GW} dev v-${ID} # Маршрут по умолчанию.
exec ip netns exec ${ID} $Prog                         # Запускаем прогу в пространство имен ${ID}
#unshare --net=/run/netns/${ID} --pid --uts --ipc --fork bash  # Для будущих наработак ;)

