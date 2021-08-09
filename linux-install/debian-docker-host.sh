#!/usr/bin/env sh

apt update
apt upgrade -y

# Docker
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker

# QEMU Arch Support
apt install -y binfmt-support qemu qemu-user-static

# Gitlab runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
apt install -y gitlab-runner

systemctl enable gitlab-runner
systemctl start gitlab-runner
usermod -aG docker gitlab-runner

rm /home/gitlab-runner/.bash_logout

# Buildx
mkdir -p ~/.docker/cli-plugins
export DOCKER_BUILDKIT=1
docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p /home/gitlab-runner/.docker/cli-plugins
# Copy to root
cp buildx ~/.docker/cli-plugins/docker-buildx
# Move to gitlab-runner user
mv buildx /home/gitlab-runner/.docker/cli-plugins/docker-buildx

# Gitlab-runner user configuration
chown -R gitlab-runner:gitlab-runner /home/gitlab-runner