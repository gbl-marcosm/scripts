#!/usr/bin/env bash

set -e

UBUNTU_CODENAME=$(lsb_release --codename | awk -F ' ' '{print $2}')

echo -n "1/2 - Checking if OpenVPN client is installed... "
INSTALL_CHECK=$(apt -qq list openvpn3 2>/dev/null | grep "openvpn3/$(lsb_release --codename | awk -F ' ' '{print $2}')" | awk -F '[' '{print $2}' | tr -d ']')
if [ ${INSTALL_CHECK} == "installed" ] && [ -f "/usr/bin/openvpn3" ]; then
    echo "INSTALLED!"
else
    echo "NOT INSTALLED!"
    echo -n "    - Installing OpenVPN 3 Client... "
    apt update &>/dev/null \
    && apt install -y apt-transport-https wget &>/dev/null \
    && wget https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub &>/dev/null \
    && apt-key add openvpn-repo-pkg-key.pub &>/dev/null \
    && rm -f openvpn-repo-pkg-key.pub &>/dev/null \
    && wget -O /etc/apt/sources.list.d/openvpn3.list https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-${UBUNTU_CODENAME}.list &>/dev/null \
    && apt update &>/dev/null \
    && apt install -y openvpn3 &>/dev/null \
    && echo "DONE!" || echo "ERROR!" && exit 1;
fi

echo -n "2/2 - Applying fix for OpenVPN DNS service... "
sed -i 's/--systemd-resolved/--resolv-conf \/etc\/resolv.conf/g' /usr/share/dbus-1/system-services/net.openvpn.v3.netcfg.service \
&& echo "DONE!"

echo " "
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
NORMAL=$(tput sgr0)
echo "Please access the link ${UNDERLINE}https://myaccount.openvpn.com/cvpn/member/gblio/login${NORMAL} and download your VPN profile if you don't already have it. And use the commands below to interact to the VPN server:"
echo "${BOLD}To connect, run:${NORMAL} openvpn3 session-start --config [path/to/your/profile]"
echo "${BOLD}To disconnect, run:${NORMAL} openvpn3 session-manage --disconnect --config [path/to/your/profile]"
echo "${BOLD}To see the connection stats, run:${NORMAL} openvpn3 session-stats --config [path/to/your/profile]"
echo " "
echo "### Please restart you machine to apply the new config before trying to connect. ###"
