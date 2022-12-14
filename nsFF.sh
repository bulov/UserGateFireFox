#!/bin/bash -f
#
#  Запуск firefox с уникальным IP для учета в UserGate на терминальном сервере AstraLinux
#
#set -x
[ $EUID -ne 0 ] && { echo "You must run this script as root." ; exit 1  ; }
BR=brFF
GW=192.168.0.1
User=${1}
ID=$(id -u ${1})
shift
i=$((${ID}%100000))
IP="192.168.$(((${i}>>8)%256)).$((${i}%256))/16"
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
						       # Запускаем прогу в пространство имен ${ID}
[ _"${1}" == _"" ]           && exec ip netns exec ${ID} exec sudo -u ${User} /usr/bin/firefox
[ _"${1}" == _"/bin/bash"  ] && exec ip netns exec ${ID} /bin/bash --rcfile <(echo "PS1=\"${ID}> \"" )
				exec ip netns exec ${ID} "$@"
#unshare --net=/run/netns/${ID} --pid --uts --ipc --fork bash  # Для будущих наработак ;)
