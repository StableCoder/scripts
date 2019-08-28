#!/bin/bash

sudo yum update -y

sudo yum install -y docker git python3-pip

sudo systemctl enable docker
sudo systemctl start docker

sudo amazon-linux-extras install -y nginx1.12
sudo yum install -y nginx

sudo systemctl enable nginx

sudo systemctl start nginx

sudo pip3 install awscli docker-compose certbot certbot-nginx

git clone https://github.com/stablecoder/scripts.git

sudo fallocate -l 4G /4GB.swap
sudo dd if=/dev/zero of=/4GB.swap bs=1024 count=4194304
sudo chmod 0600 /4GB.swap
sudo mkswap /4GB.swap
sudo swapon /4GB.swap
sudo echo "/4GB.swap none swap sw 0 0" >> /etc/fstab
sudo swapon -s

sudo sed -i '/#Port 22/c\Port 5022' /etc/ssh/sshd_config

sudo reboot