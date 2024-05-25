
bash -c "$(wget -qLO - https://github.com/Motopacker/media/raw/main/build/ct/mediapc.sh)"
cat /etc/pve/lxc/101.conf
nano /etc/pve/lxc/101.conf


#Run against host:
    mkdir -p /mnt/docker /mnt/data
    chown 1000:1000 /mnt/docker -R
    chown 1000:1000 /mnt/data -R  

grep -qxF 'include "/etc/subuid"' root:1000:1 || echo 'include "/etc/subuid"' >> root:1000:1
grep -qxF 'include "/etc/subgid"' root:1000:1 || echo 'include "/etc/subgid"' >> root:1000:1  

# Run against LXC:
msg_info "Creating user account"
$STD useradd -u 1000 -m -s /usr/bin/bash "$USERNAME"
sudo adduser "$USERNAME" sudo
 $STD groupadd -g 11000 lxc_gpu_shares
 $STD gpasswd -a "$USERNAME" lxc_gpu_shares


#Add maps to LXC config. Run against host:
Ask for container ID
cat <<EOF >>/etc/pve/lxc/$LXC_ID.conf
lxc.mount.entry: /mnt/docker mnt/home/$USER_NAME/docker none bind 0 0
lxc.mount.entry: /mnt/data data none bind 0 0
EOF

#Run on LXC
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