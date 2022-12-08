#!/bin/bash -f
#
echo Шаг 0 создаем /usr/local/bin/firefox
#
[ ! -f /usr/local/bin/firefox ] && { cat >/usr/local/bin/firefox <<EOL
#!/bin/bash -f
exec sudo /usr/local/bin/nsFF.sh \$USER "\$@"
EOL
chmod +x /usr/local/bin/firefox
}
#
echo Шаг 1 настраиваем в /etc/sudoers вызов по sudo /usr/local/bin/nsFF.sh
#
grep -qs "UGFF=" /etc/sudoers
[ 0 != $? ]  && {
cat >>/etc/sudoers <<EOL
Cmnd_Alias UGFF=/usr/local/bin/nsFF.sh
ALL ALL=NOPASSWD: UGFF
EOL
}
#
echo Шаг 2 настраиваем иконку /usr/share/applications/firefox.desktop
#
grep -qs Exec=firefox /usr/share/applications/firefox.desktop
[ 0 == $? ]  && {  sed -i  s?Exec=firefox?Exec=/usr/local/bin/firefox?  /usr/share/applications/firefox.desktop ; }
#
echo Шаг 3 настраиваем поиск firefox из /usr/local/bin
#
grep -qs UGFF /etc/skel/.profile
[ 0 != $? ]  && {
cat >>/etc/skel/.profile <<EOL
#
# set PATH for UGFF /usr/local/bin
#
if [ -d "/usr/local/bin" ] ; then
    PATH="/usr/local/bin:\$PATH"
fi
EOL
}
#
echo Шаг 4 создаем коммутатор  для сети firefox
#
[ ! -f /etc/NetworkManager/system-connections/brFF ]  && {
cat > /etc/NetworkManager/system-connections/brFF << EOL
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
echo Шаг 5 создаем карту eth1 в сторону UserGate
#
[ ! -f /etc/NetworkManager/system-connections/eth1 ] &&  {
cat > /etc/NetworkManager/system-connections/eth1 << EOL
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
echo Шаг 6 установить запуск firefox со своим IP  /usr/local/bin/nsFF.sh
# GW=192.168.0.1
# IP="192.168.$(((${i}>>8)%256)).$((${i}%256))/16"
[ ! -f /usr/local/bin/nsFF.sh ] && {
cp  nsFF.sh /usr/local/bin/nsFF.sh
chmod +x /usr/local/bin/nsFF.sh
}
#
echo Шаг 7 Проверить: sudo nsFF.sh xrdp ip a
#
