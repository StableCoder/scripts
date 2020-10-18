#!/usr/bin/env bash
set -e

RED='\033[0;31m'
DEFAULT='\033[0m'

if [ $SUDO_USER ]; then user=$SUDO_USER; else user=$(whoami); fi
if [ "$user" == "root" ] || [ "$user" == "" ]; then
    echo -e "${RED}Don't run this as root! Create a user and run this as sudo.${DEFAULT}"
    exit 1
fi

runuser -l $user -c 'yay -S --noconfirm --nodiffmenu --noeditmenu --noupgrademenu --afterclean looking-glass obs-plugin-looking-glass-git'

cat >/usr/local/bin/init-looking-glass-file.sh <<EOF
#!/usr/bin/env sh
touch /dev/shm/looking-glass
chmod 0660 /dev/shm/looking-glass
chown rarity:kvm /dev/shm/looking-glass
EOF

chmod +x /usr/local/bin/init-looking-glass-file.sh

cat >/etc/systemd/system/looking-glass-file.service <<EOF
[Unit]
Description=Looking Glass File Setup
 
[Service]
ExecStart=/usr/local/bin/init-looking-glass-file.sh
 
[Install]
WantedBy=multi-user.target
EOF

systemctl enable looking-glass-file.service
