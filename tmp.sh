#!/bin/bash

# 一旦有命令返回非零值，立即退出脚本
set -e

# 颜色定义
readonly COLOR_BLUE='\033[34m'
readonly COLOR_GREEN='\033[92m'
readonly COLOR_RED='\033[31m'
readonly COLOR_RESET='\033[0m'
readonly COLOR_YELLOW='\033[93m'

# 当前系统类型，可能的值:
# anolis
# centos
# debian
# openEuler
# ubuntu
# uos
readonly os_type=$(grep -w "ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo "系统类型: $os_type"

# 当前系统版本，可能的值:
# Anolis OS: 7.9、8.8
# CentOS: 7、8
# Debian: 11、12
# OpenEuler:
# Ubuntu: 22.04、23.10
# UOS:
readonly os_version=$(grep -w "VERSION_ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo "系统版本: $os_version"

# Kubernetes 具体版本，包含: 主版本号、次版本号、修正版本号
kubernetes_version=v1.31.1
# Kubernetes 仓库版本号，包含: 主版本号、次版本号
kubernetes_repo_version=$(echo $kubernetes_version | cut -d. -f1-2)
# Kubernetes 仓库
kubernetes_mirrors=("https://mirrors.aliyun.com/kubernetes-new/core/stable" "https://mirrors.cloud.tencent.com/kubernetes" "https://pkgs.k8s.io/core:/stable:")
# Kubernetes 仓库: 默认仓库，取第一个
kubernetes_baseurl=${kubernetes_mirrors[0]}

# Docker 仓库
docker_mirrors=("https://mirrors.aliyun.com/docker-ce/linux" "https://mirrors.cloud.tencent.com/docker-ce/linux" "https://download.docker.com/linux")
# Docker 仓库: 默认仓库，取第一个
docker_baseurl=${docker_mirrors[0]}
# Docker 仓库类型
docker_repo_type=$os_type
case "$os_type" in
  anolis)
    docker_repo_type='centos'
    ;;
  *)
esac

# 包管理类型
package_type=
case "$os_type" in
  ubuntu|debian)
    package_type=apt
    ;;
  centos|anolis)
    package_type=yum
    ;;
  *)
    echo "不支持的发行版: $os_type"
    exit 1
    ;;
esac

_docker_repo() {

  if [ $package_type == 'yum' ]; then

    sudo tee /etc/yum.repos.d/docker-ce.repo <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=$docker_baseurl/$docker_repo_type/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=$docker_baseurl/centos/gpg

EOF

  elif [ $package_type == 'apt' ]; then

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL $docker_baseurl/$docker_repo_type/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $docker_baseurl/$docker_repo_type \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

  else

    echo "不支持的发行版: $os_type 配置 Docker 源"
    exit 1

  fi

}

_kubernetes_repo() {
  if [ $package_type == 'yum' ]; then

    sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=$kubernetes_baseurl/$kubernetes_repo_version/rpm/
enabled=1
gpgcheck=1
gpgkey=$kubernetes_baseurl/$kubernetes_repo_version/rpm/repodata/repomd.xml.key

EOF

  elif [ $package_type == 'apt' ]; then

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL $kubernetes_baseurl/$kubernetes_repo_version/deb/Release.key -o /etc/apt/keyrings/kubernetes.asc
    sudo chmod a+r /etc/apt/keyrings/kubernetes.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/kubernetes.asc] $kubernetes_baseurl/$kubernetes_repo_version/deb/ /" | \
      sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

    sudo apt-get update

  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in

  kubernetes-repo | -kubernetes-repo | --kubernetes-repo)
    kubernetes_repo=true
    ;;

  docker-repo | -docker-repo | --docker-repo)
    docker_repo=true
    ;;

  *)
    echo -e "${COLOR_RED}无效参数: $1，退出程序${COLOR_RESET}"
    exit 1
    ;;
  esac
  shift
done

if [[ $kubernetes_repo == true ]]; then
  _kubernetes_repo
fi

if [[ $docker_repo == true ]]; then
  _docker_repo
fi
