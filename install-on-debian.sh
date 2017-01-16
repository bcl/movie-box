#!/bin/bash
set -e
set -o pipefail

echo "Configuring services for package installation"
# Turn off dnsmasq, ignoring any errors (may not be installed)
systemctl stop dnsmasq || :
# Make sure we can connect to the LAN to download packages
systemctl start dhcpcd

echo "Installing required packages"
apt-get -y install dnsmasq lighttpd python3 python3-venv zip make
cp config/debian/dnsmasq.conf /etc/
cp config/debian/interfaces /etc/network/
cp config/debian/lighttpd.conf /etc/lighttpd/
[ -e "/mnt/movie-box/" ] || mkdir /mnt/movie-box/

echo "Setting up required services"
pyvenv /root/clortho-venv
[ -e "/root/clortho" ] || mkdir /root/clortho
cp -r ./clortho/* /root/clortho/
/root/clortho-venv/bin/pip3 install -r /root/clortho/requirements.txt
cp ./config/clortho/clortho.service "$(pkg-config systemd --variable=systemdsystemunitdir)"
systemctl enable clortho
systemctl start clortho

echo "=====>"
echo "Unplug your LAN from the Movie Box and plug in the Roku player."
echo "Press ENTER to continue"
read

[ -e /var/log/lighttpd/access.log ] && rm /var/log/lighttpd/access.log

echo "Starting DHCP Server"
systemctl stop dhcpcd
systemctl disable dhcpcd
systemctl enable dnsmasq
systemctl restart dnsmasq
systemctl enable lighttpd
systemctl restart lighttpd

grep -q movie-box /etc/fstab
if [ $? -gt 0 ]; then
    echo "LABEL=movie-box /mnt/movie-box auto defaults,noatime,auto,nofail 0 2" >> /etc/fstab
    systemctl daemon-reload
fi

echo "=====>"
echo "Apply power to your Roku player, or cycle the power to the Roku"
echo "Waiting for Roku IP address assignment"

# TODO Find the Roku in the lighttpd access logs
ROKU_DEV_TARGET=""
while [ "$ROKU_DEV_TARGET" == "" ]; do
    if [ -e /var/log/lighttpd/access.log ]; then
        ROKU_DEV_TARGET=$(tail -1 /var/log/lighttpd/access.log | grep Roku | awk '{ print $1 }' || :)
    fi
done
r=$(curl -s http://$ROKU_DEV_TARGET/ > /dev/null || echo "FAIL")
if [ "$r" == "FAIL" ]; then
    echo "Roku does not appear to be in developer mode. You need to activate deceloper mode before HMS can be uploaded."
    echo "This can be done using the Roku remote: HOME HOME HOME UP UP RIGHT LEFT RIGHT LEFT RIGHT"
    exit 1
fi

echo "Roku device found at $ROKU_DEV_TARGET, uploading HMS"

# Upload latest version of HMS to the roku
ROKU_DEV_USER=rokudev
ROKU_DEV_PASSWORD=password
cd ./HMS/HMS/
make install
