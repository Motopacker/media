#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y net-tools
$STD apt-get install -y acl
msg_ok "Installed Dependencies"

msg_info "Setting Up Hardware Acceleration"
$STD apt-get -y install {va-driver-all,ocl-icd-libopencl1,intel-opencl-icd,vainfo,intel-gpu-tools}

msg_info "Tweak VM for performance"
$STD echo "vm.swappiness=10" >> /etc/systemctl.conf
$STD echo "vm.vfs_cache_pressure = 50" >> /etc/systemctl.conf
$STD echo "fs.inotify.max_user_watches=262144" >> /etc/systemctl.conf

if [[ "$LAN" != "" ]]; then
msg_info "Turning on UFW (Uncomplicated Firewall)"
$STD sudo ufw default deny incoming
$STD sudo ufw default allow outgoing
$STD sudo ufw allow from "$LAN"
$STD ufw enable
$STD ufw status
else
msg_info "No LAN subnet specified. Skipping firewall setup"
fi

msg_info "Installing Docker and Docker Compose"
$STD curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
$STD sh /tmp/get-docker.sh

msg_info "Cloning Docker Repo"
#$STD wget -O - https://github.com/Motopacker/docker/archive/master.tar.gz | tar xz -C "$DOCDIR" --strip-components 1
wget -O - https://github.com/Motopacker/docker/archive/master.tar.gz | tar xz -C "$DOCDIR" --strip-components 1

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"