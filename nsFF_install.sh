#!/bin/bash -f
#
# Шаг 1 создаем /usr/local/bin/firefox
#
[ ! -f /usr/local/bin/firefox ] && { cat >/usr/local/bin/firefox <<EOL
#!/bin/bash -f
exec sudo /usr/local/bin/nsFF.sh \$USER "\$@"
EOL
chmod +x /usr/local/bin/firefox
}
#
# Шаг 2 настраиваем в /etc/sudoers вызов по sudo /usr/local/bin/ns-FF.sh
#
grep -s "UGFF=" /etc/sudoers
[ 0 != $? ]  && { cat >>/etc/sudoers <<EOL
Cmnd_Alias UGFF=/usr/local/bin/ns-FF.sh
ALL ALL=NOPASSWD: UGFF
EOL
}
#
# Шаг 3 настраиваем иконку /usr/share/applications/firefox.desktop
#
grep Exec=firefox /usr/share/applications/firefox.desktop
[ 0 == $? ]  && {  sed -i  s?Exec=firefox?Exec=/usr/local/bin/firefox?  /usr/share/applications/firefox.desktop ; }
#
# Шаг 4 настраиваем поиск firefox из /usr/local/bin
#
grep UGFF /etc/skel/.profile
[ 0 != $? ]  && { cat >>/etc/sudoers <<EOL
#
# set PATH for UGFF /usr/local/bin
#
if [ -d "/usr/local/bin" ] ; then
    PATH="/usr/local/bin:\$PATH"
fi
EOL
#
# Шаг 5 создаем коммутатор  для сети firefox
#
[ -f /etc/NetworkManager/system-connections/brFF ]  cat > /etc/NetworkManager/system-connections/brFF << EOL
[connection]
id=brFF
interface-name=brFF
type=bridge
[ipv4]
method=disabled
[ipv6]
method=ignore
[bridge]
stp=false
EOL
chmod 0600 /etc/NetworkManager/system-connections/brFF
}
#
# Шаг 6 создаем карту eth1 в сторону UserGate
#
[ -f /etc/NetworkManager/system-connections/eth1 ]  cat > /etc/NetworkManager/system-connections/eth1 << EOL
[connection]
id=eth1
interface-name=eth1
type=ethernet
master=brFF
slave-type=bridge
[ipv4]
method=disabled
[ipv6]
method=ignore
EOL
chmod 0600 /etc/NetworkManager/system-connections/eth1
nmcli c re
}
#
# Шаг 7 установить запуск firefox со своим IP  /usr/local/bin/nsFF.sh
# GW=192.168.0.1
# IP="192.168.$(((${i}>>8)%256)).$((${i}%256))/16"
#
[ ! -f /usr/local/bin/nsFF.sh ] && {
cp  nsFF.sh /usr/local/bin/nsFF.sh
chmod +x /usr/local/bin/nsFF.sh
}
