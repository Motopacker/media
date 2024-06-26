#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/Motopacker/media/main/build/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

███    ███ ███████ ██████  ██  █████      ██████   ██████ 
████  ████ ██      ██   ██ ██ ██   ██     ██   ██ ██      
██ ████ ██ █████   ██   ██ ██ ███████     ██████  ██      
██  ██  ██ ██      ██   ██ ██ ██   ██     ██      ██      
██      ██ ███████ ██████  ██ ██   ██     ██       ██████ 
                                                          
EOF
}
header_info
echo -e "Loading..."
APP="MediaPC"
var_disk="10"
var_cpu="2"
var_ram="2048"
var_os="ubuntu"
var_version="22.04"
var_dockerdir="/mnt/docker"
var_lansubnet="192.168.1.0/24"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW="password"
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  DOCKERDIR="var_dockerdir"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="yes"
  LAN_SUBNET="$var_lansubnet"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -d /var ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP} LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated ${APP} LXC"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"