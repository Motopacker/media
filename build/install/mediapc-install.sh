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

msg_info "Creating user account"
$STD useradd -u 1000 -m -s /usr/bin/bash "$USERNAME"
sudo adduser "$USERNAME" sudo

if [[ "$CTTYPE" == "1" ]]; then
 $STD groupadd -g 11000 lxc_gpu_shares
 $STD gpasswd -a "$USERNAME" lxc_gpu_shares
fi

msg_info "Tweak VM for performance"
$STD "{ vm.swappiness=10; vm.vfs_cache_pressure = 50; fs.inotify.max_user_watches=262144 }" >> /etc/systemctl.conf

if [[ "$LAN_SUBNET" != "" ]]; then
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
$STD bash -c "$(curl -fsSL https://get.docker.com -o get-docker.sh)"

msg_info "Adding user account to docker group"
$STD sudo adduser "$USERNAME" docker

msg_info "Creating Docker directories if they don't exist and setting permissions"
#if [ ! -d /home/mlzboy/b2c2/shared/db ]; then
#  mkdir -p /home/mlzboy/b2c2/shared/db;
#fi

$STD mkdir -p /home/"$USERNAME"/docker/appdata /home/"$USERNAME"/docker/compose /home/"$USERNAME"/docker/logs /home/"$USERNAME"/docker/scripts /home/"$USERNAME"/docker/secrets /home/"$USERNAME"/docker/shared
$STD sudo chown root:root /home/"$USERNAME"/docker/secrets
$STD sudo chmod 600 /home/"$USERNAME"/docker/secrets
$STD sudo setfacl -Rdm u:xrpilot:rwx /home/"$USERNAME"/docker
$STD sudo setfacl -Rm u:xrpilot:rwx /home/"$USERNAME"/docker
$STD sudo setfacl -Rdm g:docker:rwx /home/"$USERNAME"/docker
$STD sudo setfacl -Rm g:docker:rwx /home/"$USERNAME"/docker

$STD touch /home/"$USERNAME"/docker/.env
$STD sudo chown root:root /home/"$USERNAME"/docker/.env
$STD sudo chown 600 /home/"$USERNAME"/docker/.env

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"