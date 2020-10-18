#!/usr/bin/env sh

yay -S --noconfirm --nodiffmenu --noeditmenu --noupgrademenu --afterclean looking-glass obs-plugin-looking-glass-git

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
