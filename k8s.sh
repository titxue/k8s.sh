#!/bin/bash

# 作者：徐晓伟 xuxiaowei@xuxiaowei.com.cn
# 微信群：
# https://work.weixin.qq.com/gm/75cfc47d6a341047e4b6aca7389bdfa8
#
# 一键安装交互式页面：
# https://k8s-sh.xuxiaowei.com.cn
#
# 仓库：
# https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh
# https://gitee.com/xuxiaowei-com-cn/k8s.sh
# https://github.com/xuxiaowei-com-cn/k8s.sh
#
# 自动化测试流水线：
# https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/pipelines
#
# 环境：
# https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/folders/kubernetes
#
# 如果发现脚本不能正常运行，可尝试执行：sed -i 's/\r$//' k8s.sh
#
# 代码格式使用：
# https://github.com/mvdan/sh
# 代码格式化命令：
# shfmt -l -w -i 2 k8s.sh

# 一旦有命令返回非零值，立即退出脚本
set -e

# 颜色定义
readonly COLOR_BLUE='\033[34m'
readonly COLOR_GREEN='\033[92m'
readonly COLOR_RED='\033[31m'
readonly COLOR_RESET='\033[0m'
readonly COLOR_YELLOW='\033[93m'

# 定义表情
readonly EMOJI_CONGRATS="\U0001F389"

# 查看系统类型、版本、内核
hostnamectl || true

# 当前系统类型，可能的值:
# almalinux
# anolis
# centos
# debian
# openEuler
# openkylin
# ubuntu
# uos
readonly os_type=$(grep -w "ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo "系统类型: $os_type"

# 当前系统版本，可能的值:
# AlmaLinux: 8.10、9.4
# Anolis OS: 7.7、7.9、8.2、8.4、8.6、8.8、8.9、23
# CentOS: 7、8、9
# Debian: 10、11、12
# OpenEuler: 20.03、22.03、24.03
# OpenKylin: 1.0、1.0.1、1.0.2、2.0
# Ubuntu: 18.04、20.04、22.04、24.04
# UOS:
readonly os_version=$(grep -w "VERSION_ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo "系统版本: $os_version"

# 代码版本
readonly code_name=$(grep -w "VERSION_CODENAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
if [[ $code_name ]]; then
  echo "代码版本: $code_name"
fi

if [[ $os_type == 'centos' && $os_version == '8' ]]; then
  readonly centos_os_version=$(cat /etc/redhat-release | awk '{print $4}')
  echo "CentOS 系统具体版本: $centos_os_version"
fi

if [ -e "/etc/debian_version" ]; then
  readonly debian_os_version=$(cat /etc/debian_version)
  echo "Debian 系统具体版本: $debian_os_version"
fi

# apt 锁超时时间
dpkg_lock_timeout=120

# Kubernetes 具体版本，包含: 主版本号、次版本号、修正版本号
kubernetes_version=v1.31.1
# Kubernetes 具体版本后缀
kubernetes_version_suffix=1.1
# Kubernetes 仓库
kubernetes_mirrors=("https://mirrors.aliyun.com/kubernetes-new/core/stable" "https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:" "https://pkgs.k8s.io/core:/stable:")
# Kubernetes 仓库: 默认仓库，取第一个
kubernetes_baseurl=${kubernetes_mirrors[0]}
# Kubernetes 镜像仓库
kubernetes_images_mirrors=("registry.aliyuncs.com/google_containers" "registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn" "registry.k8s.io")
# Kubernetes 镜像仓库: 默认仓库，取第一个
kubernetes_images=${kubernetes_images_mirrors[0]}
# pause 镜像
pause_image=${kubernetes_images_mirrors[0]}/pause

# Docker 仓库
docker_mirrors=("https://mirrors.aliyun.com/docker-ce/linux" "https://mirrors.cloud.tencent.com/docker-ce/linux" "https://download.docker.com/linux")
# Docker 仓库: 默认仓库，取第一个
docker_baseurl=${docker_mirrors[0]}
# 自定义 container-selinux 安装包，仅在少数系统中使用，如：OpenEuler 20.03
container_selinux_rpm=https://mirrors.aliyun.com/centos-altarch/7.9.2009/extras/i386/Packages/container-selinux-2.107-3.el7.noarch.rpm
# Docker 仓库类型
docker_repo_name=$os_type
case "$os_type" in
anolis | almalinux | openEuler | rocky)
  docker_repo_name='centos'
  ;;
kylin | openkylin | Deepin)
  docker_repo_name='debian'
  ;;
*) ;;
esac

calico_mirrors=("https://k8s-sh.xuxiaowei.com.cn/mirrors/projectcalico/calico" "https://gitlab.xuxiaowei.com.cn/mirrors/github.com/projectcalico/calico/-/raw" "https://raw.githubusercontent.com/projectcalico/calico/refs/tags")
calico_mirror=${calico_mirrors[0]}
calico_version=v3.29.0
calico_node_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-node" "docker.io/calico/node")
calico_node_image=${calico_node_images[0]}
calico_cni_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-cni" "docker.io/calico/cni")
calico_cni_image=${calico_cni_images[0]}
calico_kube_controllers_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-kube-controllers" "docker.io/calico/kube-controllers")
calico_kube_controllers_image=${calico_kube_controllers_images[0]}

ingress_nginx_mirrors=("https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/ingress-nginx" "https://gitlab.xuxiaowei.com.cn/mirrors/github.com/kubernetes/ingress-nginx/-/raw" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags")
ingress_nginx_mirror=${ingress_nginx_mirrors[0]}
ingress_nginx_version=v1.11.3
ingress_nginx_controller_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-controller" "registry.k8s.io/ingress-nginx/controller")
ingress_nginx_controller_image=${ingress_nginx_controller_images[0]}
ingress_nginx_kube_webhook_certgen_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen" "registry.k8s.io/ingress-nginx/kube-webhook-certgen")
ingress_nginx_kube_webhook_certgen_image=${ingress_nginx_kube_webhook_certgen_images[0]}

metrics_server_version=v0.7.2
metrics_server_mirrors=("https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes-sigs/metrics-server" "https://github.com/kubernetes-sigs/metrics-server/releases/download")
metrics_server_mirror=${metrics_server_mirrors[0]}
metrics_server_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/metrics-server" "registry.k8s.io/metrics-server/metrics-server")
metrics_server_image=${metrics_server_images[0]}

# 包管理类型
package_type=
case "$os_type" in
ubuntu | debian | kylin | openkylin | Deepin)
  package_type=apt
  ;;
centos | anolis | almalinux | openEuler | rocky)
  package_type=yum
  ;;
*)
  echo "不支持的发行版: $os_type"
  exit 1
  ;;
esac

_docker_repo() {

  if [[ $package_type == 'yum' ]]; then

    docker_gpgcheck=0
    case "$docker_repo_type" in
    "" | aliyun | tencent | docker)
      docker_gpgcheck=1
      ;;
    *) ;;
    esac

    sudo tee /etc/yum.repos.d/docker-ce.repo <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=$docker_baseurl/$docker_repo_name/\$releasever/\$basearch/stable
enabled=1
gpgcheck=$docker_gpgcheck
gpgkey=$docker_baseurl/$docker_repo_name/gpg

EOF

    if [[ $os_type == 'anolis' ]]; then
      case "$os_version" in
      '23')
        sudo sed -i 's/$releasever/8/g' /etc/yum.repos.d/docker-ce.repo
        ;;
      *) ;;
      esac
    fi

    if [[ $os_type == 'openEuler' ]]; then
      case "$os_version" in
      '20.03' | '22.03' | '24.03')
        sudo sed -i 's/$releasever/8/g' /etc/yum.repos.d/docker-ce.repo
        ;;
      *) ;;
      esac
    fi

  elif [[ $package_type == 'apt' ]]; then

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL $docker_baseurl/$docker_repo_name/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $docker_baseurl/$docker_repo_name \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    if [[ $os_type == 'openkylin' ]]; then
      case "$code_name" in
      yangtze | nile)
        sed -i "s#$code_name#bookworm#" /etc/apt/sources.list.d/docker.list
        ;;
      *) ;;
      esac
    fi

    if [[ $os_type == 'Deepin' ]]; then
      case "$code_name" in
      apricot)
        sed -i "s#$code_name#buster#" /etc/apt/sources.list.d/docker.list
        ;;
      *) ;;
      esac
    fi

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update

  else

    echo "不支持的发行版: $os_type 配置 Docker 源"
    exit 1

  fi

}

_remove_apt_ord_docker() {
  case "$os_type" in
  ubuntu)
    if [[ $os_version == '18.04' ]]; then
      for pkg in docker.io docker-doc docker-compose containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    elif [[ $os_version == '20.04' ]]; then
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    else
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    fi
    ;;
  openkylin)
    if [[ $os_version == '1.0' || $os_version == '1.0.1' || $os_version == '1.0.2' ]]; then
      for pkg in docker.io docker-doc docker-compose containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    else
      for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    fi
    ;;
  debian)
    if [[ $os_version == '10' ]]; then
      for pkg in docker.io docker-doc docker-compose containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    elif [[ $os_version == '11' ]]; then
      for pkg in docker.io docker-doc docker-compose containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    else
      for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    fi
    ;;
  Deepin)
    if [[ $os_version == '20.9' ]]; then
      for pkg in docker.io docker-doc docker-compose containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    else
      for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    fi
    ;;
  *)
    echo "不支持的发行版: $os_type 卸载旧版 Docker"
    exit 1
    ;;
  esac
}

_containerd_install() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

    if [[ $os_type == 'openEuler' && $os_version == '20.03' ]]; then
      sudo yum install -y $container_selinux_rpm
    fi

    sudo yum install -y containerd.io

  elif [[ $package_type == 'apt' ]]; then

    _remove_apt_ord_docker
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y containerd.io

  else

    echo "不支持的发行版: $os_type 安装 Containerd"
    exit 1

  fi

  sudo systemctl start containerd
  sudo systemctl status containerd -l --no-pager
  sudo systemctl enable containerd

}

# 容器运行时
# https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/
# https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/
_containerd_config() {
  sudo mkdir -p /etc/containerd
  sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.$(date +%Y%m%d%H%M%S) || true
  sudo containerd config default | sudo tee /etc/containerd/config.toml

  # 兼容 OpenKylin 2.0，防止在 /etc/containerd/config.toml 生成无关配置
  if [[ $os_type == 'openkylin' && $os_version == '2.0' ]]; then
    sudo sed -i 's/^User/#&/' /etc/containerd/config.toml
  fi

  sudo sed -i "s#registry.k8s.io/pause#$pause_image#g" /etc/containerd/config.toml
  sudo sed -i "s#SystemdCgroup = false#SystemdCgroup = true#g" /etc/containerd/config.toml

  sudo systemctl restart containerd
  sudo systemctl status containerd -l --no-pager
  sudo systemctl enable containerd
}

_docker_install() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

    if [[ $os_type == 'openEuler' && $os_version == '20.03' ]]; then
      sudo yum install -y $container_selinux_rpm
    fi

    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  elif [[ $package_type == 'apt' ]]; then

    _remove_apt_ord_docker
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  else

    echo "不支持的发行版: $os_type 安装 Docker"
    exit 1

  fi

  sudo systemctl restart docker.socket
  sudo systemctl restart docker.service
  sudo systemctl status docker.socket -l --no-pager
  sudo systemctl status docker.service -l --no-pager
  sudo systemctl enable docker.socket
  sudo systemctl enable docker.service
  sudo docker info
  sudo docker ps
  sudo docker images

}

_socat() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum -y install socat

  elif [[ $package_type == 'apt' ]]; then

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y socat

  else

    echo "不支持的发行版: $os_type 安装 socat"
    exit 1

  fi
}

_kubernetes_repo() {

  # Kubernetes 仓库版本号，包含: 主版本号、次版本号
  kubernetes_repo_version=$(echo $kubernetes_version | cut -d. -f1-2)

  if [[ $package_type == 'yum' ]]; then

    kubernetes_gpgcheck=0
    case "$kubernetes_repo_type" in
    "" | aliyun | tsinghua | kubernetes)
      kubernetes_gpgcheck=1
      ;;
    *) ;;
    esac

    sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=$kubernetes_baseurl/$kubernetes_repo_version/rpm/
enabled=1
gpgcheck=$kubernetes_gpgcheck
gpgkey=$kubernetes_baseurl/$kubernetes_repo_version/rpm/repodata/repomd.xml.key

EOF

  elif [[ $package_type == 'apt' ]]; then

    case "$kubernetes_repo_type" in
    "" | aliyun | tsinghua | kubernetes)

      sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
      sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y ca-certificates curl

      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL $kubernetes_baseurl/$kubernetes_repo_version/deb/Release.key -o /etc/apt/keyrings/kubernetes.asc
      sudo chmod a+r /etc/apt/keyrings/kubernetes.asc

      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/kubernetes.asc] $kubernetes_baseurl/$kubernetes_repo_version/deb/ /" |
        sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
      ;;
    *)
      echo \
        "deb [arch=$(dpkg --print-architecture) trusted=yes] $kubernetes_baseurl/$kubernetes_repo_version/deb/ /" |
        sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
      ;;

    esac

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update

  else

    echo "不支持的发行版: $os_type 配置 Kubernetes 源"
    exit 1

  fi
}

_swap_off() {
  free -h
  sudo swapoff -a
  free -h
  cat /etc/fstab
  sudo sed -i 's/.*swap.*/#&/' /etc/fstab
  cat /etc/fstab
}

_curl() {

  if [[ $package_type == 'yum' ]]; then

    sudo yum -y install curl

  elif [[ $package_type == 'apt' ]]; then

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y curl

  else

    echo "不支持的发行版: $os_type 安装 curl"
    exit 1

  fi
}

_ca_certificates() {

  if [[ $package_type == 'yum' ]]; then

    sudo yum -y install ca-certificates

  elif [[ $package_type == 'apt' ]]; then

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y ca-certificates

  else

    echo "不支持的发行版: $os_type 安装 ca-certificates"
    exit 1

  fi
}

_kubernetes_install() {

  version=${kubernetes_version:1}

  if [[ $package_type == 'yum' ]]; then
    sudo yum install -y kubelet-"$version" kubeadm-"$version" kubectl-"$version"
  elif [[ $package_type == 'apt' ]]; then
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y kubelet="$version"-$kubernetes_version_suffix kubeadm="$version"-$kubernetes_version_suffix kubectl="$version"-$kubernetes_version_suffix
  else

    echo "不支持的发行版: $os_type 安装 Kubernetes"
    exit 1

  fi
}

_kubernetes_images_pull() {
  kubeadm config images list --image-repository="$kubernetes_images" --kubernetes-version="$kubernetes_version"
  kubeadm config images pull --image-repository="$kubernetes_images" --kubernetes-version="$kubernetes_version"
}

# 启用 IPv4 数据包转发
# https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/
# https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/
_enable_ipv4_packet_forwarding() {
  # Kubernetes 版本号，包含: 主版本号、次版本号
  kubernetes_version_tmp=$(echo $kubernetes_version | cut -d. -f1-2)

  ipv4_ip_forward=$(grep -w "net.ipv4.ip_forward" /etc/sysctl.conf | cut -d'=' -f2 | tr -d ' ')
  if [[ $ipv4_ip_forward == '0' ]]; then
    # 如果 IPv4 数据包转发 已关闭: 注释已存在的配置，防止冲突
    sudo sed -i 's|net.ipv4.ip_forward|#net.ipv4.ip_forward|g' /etc/sysctl.conf
  fi

  ipv4_ip_forward=$(grep -w "net.ipv4.ip_forward" /etc/sysctl.d/99-sysctl.conf | cut -d'=' -f2 | tr -d ' ')
  if [[ $ipv4_ip_forward == '0' ]]; then
    # 如果 IPv4 数据包转发 已关闭: 注释已存在的配置，防止冲突
    sudo sed -i 's|net.ipv4.ip_forward|#net.ipv4.ip_forward|g' /etc/sysctl.d/99-sysctl.conf
  fi

  case "$kubernetes_version_tmp" in
  "v1.24" | "v1.25" | "v1.26" | "v1.27" | "v1.28" | "v1.29")

    # https://kubernetes-v1-24.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
    # https://kubernetes-v1-25.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
    # https://kubernetes-v1-26.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
    # https://kubernetes-v1-27.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
    # https://kubernetes-v1-28.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
    # https://kubernetes-v1-29.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    # 设置所需的 sysctl 参数，参数在重新启动后保持不变
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    # 应用 sysctl 参数而不重新启动
    sudo sysctl --system

    lsmod | grep br_netfilter
    lsmod | grep overlay
    ;;
  *)

    # https://kubernetes-v1-30.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites
    # https://kubernetes-v1-31.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/#install-and-configure-prerequisites

    # 设置所需的 sysctl 参数，参数在重新启动后保持不变
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

    # 应用 sysctl 参数而不重新启动
    sudo sysctl --system
    ;;
  esac
}

_kubernetes_config() {

  _enable_ipv4_packet_forwarding

  _socat

  systemctl enable kubelet.service

  if [[ $os_type == 'centos' ]]; then
    case "$centos_os_version" in
    '8.1.1911' | '8.2.2004' | '8.3.2011' | '8.4.2105' | '8.5.2111')
      sudo yum install -y iproute-tc
      ;;
    *) ;;
    esac
  elif [[ $os_type == 'rocky' ]]; then
    case "$os_version" in
    '8.10')
      sudo yum install -y iproute-tc
      ;;
    *) ;;
    esac
  elif [[ $os_type == 'anolis' ]]; then
    case "$os_version" in
    '8.2' | '8.4' | '8.6' | '8.8' | '8.9')
      sudo yum install -y iproute-tc
      ;;
    *) ;;
    esac
  fi

}

_kubernetes_init() {
  if [[ $kubernetes_init_node_name ]]; then
    kubernetes_init_node_name="--node-name=$kubernetes_init_node_name"
  fi

  if [[ $control_plane_endpoint ]]; then
    control_plane_endpoint="--control-plane-endpoint=$control_plane_endpoint"
  fi

  if [[ $service_cidr ]]; then
    service_cidr="--service-cidr=$service_cidr"
  fi

  if [[ $pod_network_cidr ]]; then
    pod_network_cidr="--pod-network-cidr=$pod_network_cidr"
  fi

  kubeadm init --image-repository=$kubernetes_images $control_plane_endpoint $kubernetes_init_node_name $service_cidr $pod_network_cidr --kubernetes-version=$kubernetes_version

  KUBECONFIG=$(grep -w "KUBECONFIG" /etc/profile | cut -d'=' -f2)
  if [[ $KUBECONFIG != '/etc/kubernetes/admin.conf' ]]; then
    sudo sed -i 's/.*KUBECONFIG.*/#&/' /etc/profile
    echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >>/etc/profile
  fi

  # 此处兼容 AnolisOS 23.1，防止退出
  source /etc/profile || true

  # 查看集群配置
  kubectl -n kube-system get cm kubeadm-config -o yaml

  kubectl get node -o wide
  kubectl get svc -o wide
  kubectl get pod -A -o wide

  echo
  echo
  echo
  echo -e "${COLOR_BLUE}${EMOJI_CONGRATS}${EMOJI_CONGRATS}${EMOJI_CONGRATS}${COLOR_RESET}"
  echo -e "${COLOR_BLUE}Kubernetes 已完成安装${COLOR_RESET}"
  echo
  echo -e "${COLOR_BLUE}请选择下列方式之一，重载环境变量后，即可直接控制 Kubernetes${COLOR_RESET}"
  echo
  echo -e "${COLOR_BLUE}1. 执行命令刷新环境变量: ${COLOR_GREEN}source /etc/profile${COLOR_RESET}"
  echo -e "${COLOR_BLUE}2. 重新连接 SSH${COLOR_RESET}"
  echo
  echo
  echo
}

_kubernetes_taint() {
  kubectl get nodes -o wide
  kubectl get pod -A -o wide
  kubectl get node -o yaml | grep taint -A 10
  kubernetes_version_tmp=$(echo $kubernetes_version | cut -d. -f1-2)
  if [[ $kubernetes_version_tmp == 'v1.24' ]]; then
    kubectl taint nodes --all node-role.kubernetes.io/master- || true
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
  else
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  fi
  kubectl get node -o yaml | grep taint -A 10 | true
  kubectl get nodes -o wide
  kubectl get pod -A -o wide
}

_print_join_command() {
  kubeadm token create --print-join-command
}

_bash_completion() {
  if [[ $package_type == 'yum' ]]; then
    sudo yum -y install bash-completion
    # 此处兼容 AnolisOS 23.1，防止退出
    source /etc/profile || true
  elif [[ $package_type == 'apt' ]]; then
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y bash-completion
    # 此处兼容 Debian 11.7.0，防止退出
    source /etc/profile || true
  fi
}

# kubectl 的可选配置和插件
# 启用 shell 自动补全功能
# https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations
# https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations
_enable_shell_autocompletion() {

  _bash_completion

  if [[ $package_type == 'yum' ]]; then

    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
    sudo chmod a+r /etc/bash_completion.d/kubectl
    source /etc/bash_completion.d/kubectl

  elif [[ $package_type == 'apt' ]]; then

    sudo mkdir -p /etc/bash_completion.d
    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
    sudo chmod a+r /etc/bash_completion.d/kubectl
    source /etc/bash_completion.d/kubectl

  else

    echo "不支持的发行版: $os_type 启用 shell 自动补全功能"
    exit 1

  fi

}

_interface_name() {
  if ! [[ $interface_name ]]; then
    interface_name=$(ip route get 223.5.5.5 | grep -oP '(?<=dev\s)\w+' | head -n 1)
    if [[ "$interface_name" ]]; then
      echo -e "${COLOR_BLUE}上网网卡是 ${COLOR_RESET}${COLOR_GREEN}${interface_name}${COLOR_RESET}"
    else
      echo -e "${COLOR_RED}未找到上网网卡，停止安装${COLOR_RESET}"
      exit 1
    fi
  fi
}

_calico_install() {
  if ! [[ $calico_url ]]; then
    calico_url=$calico_mirror/$calico_version/manifests/calico.yaml
  fi
  echo "calico manifests url: $calico_url"

  calico_local_path=calico.yaml
  if [[ $calico_url =~ ^https?:// ]]; then
    curl -k -o $calico_local_path $calico_url
  else
    calico_local_path=$calico_url
  fi

  if grep -q "interface=" "$calico_local_path"; then
    echo "已配置 calico 使用的网卡，脚本跳过网卡配置"
  else
    _interface_name

    sed -i '/k8s,bgp/a \            - name: IP_AUTODETECTION_METHOD\n              value: "interface=INTERFACE_NAME"' $calico_local_path
    sed -i "s#INTERFACE_NAME#$interface_name#g" $calico_local_path
  fi

  sed -i "s#${calico_node_images[-1]}#$calico_node_image#g" $calico_local_path
  sed -i "s#${calico_cni_images[-1]}#$calico_cni_image#g" $calico_local_path
  sed -i "s#${calico_kube_controllers_images[-1]}#$calico_kube_controllers_image#g" $calico_local_path

  kubectl apply -f $calico_local_path
  kubectl get pod -A -o wide
  if [[ $cluster != true ]]; then
    kubectl wait --for=condition=Ready --all pods -A --timeout=300s || true
  fi
}

_ingress_nginx_install() {
  if ! [[ $ingress_nginx_url ]]; then
    ingress_nginx_url=$ingress_nginx_mirror/controller-$ingress_nginx_version/deploy/static/provider/cloud/deploy.yaml
  fi
  echo "ingress nginx manifests url: $ingress_nginx_url"

  ingress_nginx_local_path=ingress_nginx.yaml
  if [[ $ingress_nginx_url =~ ^https?:// ]]; then
    curl -k -o $ingress_nginx_local_path $ingress_nginx_url
  else
    ingress_nginx_local_path=$ingress_nginx_url
  fi

  sudo sed -i 's/@.*$//' $ingress_nginx_local_path
  sudo sed -i "s#${ingress_nginx_controller_images[-1]}#$ingress_nginx_controller_image#g" $ingress_nginx_local_path
  sudo sed -i "s#${ingress_nginx_kube_webhook_certgen_images[-1]}#$ingress_nginx_kube_webhook_certgen_image#g" $ingress_nginx_local_path

  kubectl apply -f $ingress_nginx_local_path
  kubectl get pod -A -o wide
}

_ingress_nginx_host_network() {
  kubectl -n ingress-nginx patch deployment ingress-nginx-controller --patch '{"spec": {"template": {"spec": {"hostNetwork": true}}}}'
}

# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#allow-snippet-annotations
# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#stream-snippet
# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#configuration-snippet
# CVE-2021-25742：https://github.com/kubernetes/kubernetes/issues/126811
_ingress_nginx_allow_snippet_annotations() {
  kubectl -n ingress-nginx patch configmap ingress-nginx-controller --type merge -p '{"data":{"allow-snippet-annotations":"true"}}'
}

_metrics_server_install() {

  if ! [[ $metrics_server_url ]]; then
    metrics_server_url=$metrics_server_mirror/$metrics_server_version/components.yaml
  fi
  echo "metrics server manifests url: $metrics_server_url"

  metrics_server_local_path=metrics_server.yaml
  if [[ $metrics_server_url =~ ^https?:// ]]; then
    curl -k -o $metrics_server_local_path $metrics_server_url
  else
    metrics_server_local_path=$metrics_server_url
  fi

  sudo sed -i "s#${metrics_server_images[-1]}#$metrics_server_image#g" $metrics_server_local_path

  if [[ $metrics_server_secure_tls != true ]]; then
    sed -i '/- args:/a \ \ \ \ \ \ \ \ - --kubelet-insecure-tls' $metrics_server_local_path
  fi

  kubectl apply -f $metrics_server_local_path
  kubectl get pod -A -o wide
}

_firewalld_stop() {
  if [[ $package_type == 'yum' ]]; then
    sudo systemctl stop firewalld.service
    sudo systemctl disable firewalld.service
  fi
}

_selinux_disabled() {
  if [[ $package_type == 'yum' ]]; then
    getenforce
    sudo setenforce 0 || true
    sudo getenforce
    cat /etc/selinux/config
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
    cat /etc/selinux/config
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in

  config=* | -config=* | --config=*)
    config="${1#*=}"
    echo '启用了配置文件: $config'
    source $config
    ;;

  standalone | -standalone | --standalone)
    standalone=true
    ;;

  cluster | -cluster | --cluster)
    cluster=true
    ;;

  node | -node | --node)
    node=true
    ;;

  dpkg-lock-timeout=* | -dpkg-lock-timeout=* | --dpkg-lock-timeout=*)
    dpkg_lock_timeout="${1#*=}"
    ;;

  firewalld-stop | -firewalld-stop | --firewalld-stop)
    firewalld_stop=true
    ;;

  selinux-disabled | -selinux-disabled | --selinux-disabled)
    selinux_disabled=true
    ;;

  bash-completion | -bash-completion | --bash-completion)
    bash_completion=true
    ;;

  kubernetes-repo | -kubernetes-repo | --kubernetes-repo)
    kubernetes_repo=true
    ;;

  kubernetes-repo-type=* | -kubernetes-repo-type=* | --kubernetes-repo-type=*)
    kubernetes_repo_type="${1#*=}"
    case "$kubernetes_repo_type" in
    aliyun)
      kubernetes_baseurl=${kubernetes_mirrors[0]}
      ;;
    tsinghua)
      kubernetes_baseurl=${kubernetes_mirrors[1]}
      ;;
    kubernetes)
      kubernetes_baseurl=${kubernetes_mirrors[-1]}
      ;;
    *)
      echo "使用自定义 Kubernetes 仓库地址: $kubernetes_repo_type"
      kubernetes_baseurl=$kubernetes_repo_type
      ;;
    esac
    ;;

  kubernetes-images=* | -kubernetes-images=* | --kubernetes-images=*)
    kubernetes_images="${1#*=}"
    case "$kubernetes_images" in
    aliyun)
      kubernetes_images=${kubernetes_images_mirrors[0]}
      ;;
    xuxiaoweicomcn)
      kubernetes_images=${kubernetes_images_mirrors[1]}
      ;;
    kubernetes)
      kubernetes_images=${kubernetes_images_mirrors[-1]}
      ;;
    *)
      echo "不支持自定义 Kubernetes 镜像仓库: $kubernetes_images"
      exit 1
      ;;
    esac
    ;;

  swap-off | -swap-off | --swap-off)
    swap_off=true
    ;;

  curl | -curl | --curl)
    curl=true
    ;;

  ca-certificates | -ca-certificates | --ca-certificates)
    ca_certificates=true
    ;;

  kubernetes-install | -kubernetes-install | --kubernetes-install)
    kubernetes_install=true
    ;;

  kubernetes-images-pull | -kubernetes-images-pull | --kubernetes-images-pull)
    kubernetes_images_pull=true
    ;;

  kubernetes-config | -kubernetes-config | --kubernetes-config)
    kubernetes_config=true
    ;;

  kubernetes-init | -kubernetes-init | --kubernetes-init)
    kubernetes_init=true
    ;;

  kubernetes-init-node-name=* | -kubernetes-init-node-name=* | --kubernetes-init-node-name=*)
    kubernetes_init_node_name="${1#*=}"
    ;;

  control-plane-endpoint=* | -control-plane-endpoint=* | --control-plane-endpoint=*)
    # 关于 apiserver-advertise-address 和 ControlPlaneEndpoint 的注意事项
    # https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#considerations-about-apiserver-advertise-address-and-controlplaneendpoint
    # https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#considerations-about-apiserver-advertise-address-and-controlplaneendpoint
    control_plane_endpoint="${1#*=}"
    ;;

  service-cidr=* | -service-cidr=* | --service-cidr=*)
    # kubeadm init
    # --service-cidr string     默认值："10.96.0.0/12"
    # https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-init/
    # https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-init/
    service_cidr="${1#*=}"
    ;;

  pod-network-cidr=* | -pod-network-cidr=* | --pod-network-cidr=*)
    pod_network_cidr="${1#*=}"
    ;;

  print-join-command | -print-join-command | --print-join-command)
    print_join_command=true
    ;;

  kubernetes-taint | -kubernetes-taint | --kubernetes-taint)
    kubernetes_taint=true
    ;;

  kubernetes-version=* | -kubernetes-version=* | --kubernetes-version=*)
    kubernetes_version="${1#*=}"
    ;;

  kubernetes-version-suffix=* | -kubernetes-version-suffix=* | --kubernetes-version-suffix=*)
    kubernetes_version_suffix="${1#*=}"
    ;;

  enable-shell-autocompletion | -enable-shell-autocompletion | --enable-shell-autocompletion)
    enable_shell_autocompletion=true
    ;;

  docker-repo | -docker-repo | --docker-repo)
    docker_repo=true
    ;;

  docker-repo-type=* | -docker-repo-type=* | --docker-repo-type=*)
    docker_repo_type="${1#*=}"
    case "$docker_repo_type" in
    aliyun)
      docker_baseurl=${docker_mirrors[0]}
      ;;
    tencent)
      docker_baseurl=${docker_mirrors[1]}
      ;;
    docker)
      docker_baseurl=${docker_mirrors[-1]}
      ;;
    *)
      echo "使用自定义 Docker 仓库地址: $docker_repo_type"
      docker_baseurl=$docker_repo_type
      ;;
    esac
    ;;

  container-selinux-rpm=* | -container-selinux-rpm=* | --container-selinux-rpm=*)
    container_selinux_rpm="${1#*=}"
    ;;

  containerd-install | -containerd-install | --containerd-install)
    containerd_install=true
    ;;

  pause-image=* | -pause-image=* | --pause-image=*)
    pause_image="${1#*=}"
    ;;

  containerd-config | -containerd-config | --containerd-config)
    containerd_config=true
    ;;

  docker-install | -docker-install | --docker-install)
    docker_install=true
    ;;

  interface-name=* | -interface-name=* | --interface-name=*)
    interface_name="${1#*=}"
    ;;

  calico-install | -calico-install | --calico-install)
    calico_install=true
    ;;

  calico-url=* | -calico-url=* | --calico-url=*)
    calico_url="${1#*=}"
    ;;

  calico-mirror=* | -calico-mirror=* | --calico-mirror=*)
    calico_mirror="${1#*=}"
    ;;

  calico-version=* | -calico-version=* | --calico-version=*)
    calico_version="${1#*=}"
    ;;

  calico-node-image=* | -calico-node-image=* | --calico-node-image=*)
    calico_node_image="${1#*=}"
    ;;

  calico-cni-image=* | -calico-cni-image=* | --calico-cni-image=*)
    calico_cni_image="${1#*=}"
    ;;

  calico-kube-controllers-image=* | -calico-kube-controllers-image=* | --calico-kube-controllers-image=*)
    calico_kube_controllers_image="${1#*=}"
    ;;

  ingress-nginx-install | -ingress-nginx-install | --ingress-nginx-install)
    ingress_nginx_install=true
    ;;

  ingress-nginx-host-network | -ingress-nginx-host-network | --ingress-nginx-host-network)
    ingress_nginx_host_network=true
    ;;

  ingress-nginx-url=* | -ingress-nginx-url=* | --ingress-nginx-url=*)
    ingress_nginx_url="${1#*=}"
    ;;

  ingress-nginx-mirror=* | -ingress-nginx-mirror=* | --ingress-nginx-mirror=*)
    ingress_nginx_mirror="${1#*=}"
    ;;

  ingress-nginx-version=* | -ingress-nginx-version=* | --ingress-nginx-version=*)
    ingress_nginx_version="${1#*=}"
    ;;

  ingress-nginx-controller-image=* | -ingress-nginx-controller-image=* | --ingress-nginx-controller-image=*)
    ingress_nginx_controller_image="${1#*=}"
    ;;

  ingress-nginx-kube-webhook-certgen-image=* | -ingress-nginx-kube-webhook-certgen-image=* | --ingress-nginx-kube-webhook-certgen-image=*)
    ingress_nginx_kube_webhook_certgen_image="${1#*=}"
    ;;

  ingress-nginx-allow-snippet-annotations | -ingress-nginx-allow-snippet-annotations | --ingress-nginx-allow-snippet-annotations)
    ingress_nginx_allow_snippet_annotations=true
    ;;

  metrics-server-install | -metrics-server-install | --metrics-server-install)
    metrics_server_install=true
    ;;

  metrics-server-url=* | -metrics-server-url=* | --metrics-server-url=*)
    metrics_server_url="${1#*=}"
    ;;

  metrics-server-version=* | -metrics-server-version=* | --metrics-server-version=*)
    metrics_server_version="${1#*=}"
    ;;

  metrics-server-mirror=* | -metrics-server-mirror=* | --metrics-server-mirror=*)
    metrics_server_mirror="${1#*=}"
    ;;

  metrics-server-image=* | -metrics-server-image=* | --metrics-server-image=*)
    metrics_server_image="${1#*=}"
    ;;

  metrics-server-secure-tls | -metrics-server-secure-tls | --metrics-server-secure-tls)
    metrics_server_secure_tls=true
    ;;

  *)
    echo -e "${COLOR_RED}无效参数: $1，退出程序${COLOR_RESET}"
    exit 1
    ;;
  esac
  shift
done

if ! command -v 'sudo' &>/dev/null; then
  if [[ $package_type == 'apt' ]]; then
    echo "sudo 未安装，正在安装..."
    apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
    apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y sudo
    echo "sudo 安装完成"
  fi
fi

_node() {
  _swap_off
  _curl
  _ca_certificates
  _firewalld_stop
  _selinux_disabled
  _bash_completion
  _docker_repo
  _containerd_install
  _containerd_config
  _kubernetes_repo
  _kubernetes_install
  _kubernetes_images_pull
  _kubernetes_config
}

if [[ $standalone == true ]]; then
  # 单机模式

  if ! [[ $kubernetes_init_node_name ]]; then
    kubernetes_init_node_name=k8s-1
  fi
  _node
  _kubernetes_init
  _calico_install
  _kubernetes_taint
  _ingress_nginx_install
  _ingress_nginx_host_network
  _metrics_server_install
  _enable_shell_autocompletion
  _print_join_command
elif [[ $cluster == true ]]; then
  # 集群模式

  if ! [[ $kubernetes_init_node_name ]]; then
    kubernetes_init_node_name=k8s-1
  fi
  _node
  _kubernetes_init
  _calico_install
  _ingress_nginx_install
  _ingress_nginx_host_network
  _metrics_server_install
  _enable_shell_autocompletion
  _print_join_command
elif [[ $node == true ]]; then
  # 工作节点准备

  _node
else

  if [[ $swap_off == true ]]; then
    _swap_off
  fi

  if [[ $curl == true ]]; then
    _curl
  fi

  if [[ $ca_certificates == true ]]; then
    _ca_certificates
  fi

  if [[ $firewalld_stop == true ]]; then
    _firewalld_stop
  fi

  if [[ $selinux_disabled == true ]]; then
    _selinux_disabled
  fi

  if [[ $bash_completion == true ]]; then
    _bash_completion
  fi

  if [[ $docker_repo == true ]]; then
    _docker_repo
  fi

  if [[ $docker_install == true ]]; then
    _docker_install
  fi

  if [[ $containerd_install == true ]]; then
    _containerd_install
  fi

  if [[ $containerd_config == true ]]; then
    _containerd_config
  fi

  if [[ $kubernetes_repo == true ]]; then
    _kubernetes_repo
  fi

  if [[ $kubernetes_install == true ]]; then
    _kubernetes_install
  fi

  if [[ $kubernetes_images_pull == true ]]; then
    _kubernetes_images_pull
  fi

  if [[ $kubernetes_config == true ]]; then
    _kubernetes_config
  fi

  if [[ $kubernetes_init == true ]]; then
    _kubernetes_init
  fi

  if [[ $calico_install == true ]]; then
    _calico_install
  fi

  if [[ $kubernetes_taint == true ]]; then
    _kubernetes_taint
  fi

  if [[ $enable_shell_autocompletion == true ]]; then
    _enable_shell_autocompletion
  fi

  if [[ $ingress_nginx_install == true ]]; then
    _ingress_nginx_install
  fi

  if [[ $ingress_nginx_host_network == true ]]; then
    _ingress_nginx_host_network
  fi

  if [[ $ingress_nginx_allow_snippet_annotations == true ]]; then
    _ingress_nginx_allow_snippet_annotations
  fi

  if [[ $metrics_server_install == true ]]; then
    _metrics_server_install
  fi

  if [[ $print_join_command == true ]]; then
    _print_join_command
  fi
fi
