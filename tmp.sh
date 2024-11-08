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
# Docker 仓库类型
docker_repo_name=$os_type
case "$os_type" in
anolis)
  docker_repo_name='centos'
  ;;
kylin)
  docker_repo_name='debian'
  ;;
*) ;;
esac

calico_manifests_mirrors=("https://gitlab.xuxiaowei.com.cn/mirrors/github.com/projectcalico/calico/-/raw" "https://raw.githubusercontent.com/projectcalico/calico/refs/tags")
calico_manifests_mirror=${calico_manifests_mirrors[0]}
calico_version=v3.29.0
calico_node_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-node" "docker.io/calico/node")
calico_node_image=${calico_node_images[0]}
calico_cni_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-cni" "docker.io/calico/cni")
calico_cni_image=${calico_cni_images[0]}
calico_kube_controllers_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-kube-controllers" "docker.io/calico/kube-controllers")
calico_kube_controllers_image=${calico_kube_controllers_images[0]}

ingress_nginx_manifests_mirrors=("https://gitlab.xuxiaowei.com.cn/mirrors/github.com/kubernetes/ingress-nginx/-/raw" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags")
ingress_nginx_manifests_mirror=${ingress_nginx_manifests_mirrors[0]}
ingress_nginx_version=v1.11.3
ingress_nginx_controller_mirrors=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-controller" "registry.k8s.io/ingress-nginx/controller")
ingress_nginx_controller_mirror=${ingress_nginx_controller_mirrors[0]}
ingress_nginx_kube_webhook_certgen_mirrors=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen" "registry.k8s.io/ingress-nginx/kube-webhook-certgen")
ingress_nginx_kube_webhook_certgen_mirror=${ingress_nginx_kube_webhook_certgen_mirrors[0]}

# 包管理类型
package_type=
case "$os_type" in
ubuntu | debian | kylin)
  package_type=apt
  ;;
centos | anolis)
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
    case "$kubernetes_repo_type" in
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

  elif [[ $package_type == 'apt' ]]; then

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL $docker_baseurl/$docker_repo_name/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $docker_baseurl/$docker_repo_name \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update

  else

    echo "不支持的发行版: $os_type 配置 Docker 源"
    exit 1

  fi

}

_containerd_install() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    sudo yum install -y containerd.io

  elif [[ $package_type == 'apt' ]]; then

    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    sudo apt-get install -y containerd.io

  else

    echo "不支持的发行版: $os_type 安装 Containerd"
    exit 1

  fi

  sudo systemctl start containerd
  sudo systemctl status containerd -l --no-pager
  sudo systemctl enable containerd

}

# https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/
# https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/container-runtimes/
_containerd_config() {
  sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.$(date +%Y%m%d%H%M%S)
  sudo containerd config default | sudo tee /etc/containerd/config.toml
  sudo sed -i "s#registry.k8s.io/pause#$pause_image#g" /etc/containerd/config.toml
  sudo sed -i "s#SystemdCgroup = false#SystemdCgroup = true#g" /etc/containerd/config.toml

  sudo systemctl restart containerd
  sudo systemctl status containerd -l --no-pager
  sudo systemctl enable containerd
}

_docker_install() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  elif [[ $package_type == 'apt' ]]; then

    case "$os_type" in
    ubuntu)
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
      ;;
    debian)
      for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
      ;;
    *)
      echo "不支持的发行版: $os_type 卸载旧版 Docker"
      exit 1
      ;;
    esac

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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

      sudo apt-get update
      sudo apt-get install -y ca-certificates curl

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

    sudo apt-get update

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

    sudo apt-get update
    sudo apt-get -y install curl

  else

    echo "不支持的发行版: $os_type 安装 curl"
    exit 1

  fi
}

_ca_certificates() {

  if [[ $package_type == 'yum' ]]; then

    sudo yum -y install ca-certificates

  elif [[ $package_type == 'apt' ]]; then

    sudo apt-get update
    sudo apt-get -y install ca-certificates

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
    sudo apt-get install -y kubelet="$version"-$kubernetes_version_suffix kubeadm="$version"-$kubernetes_version_suffix kubectl="$version"-$kubernetes_version_suffix
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
  # 设置所需的 sysctl 参数，参数在重新启动后保持不变
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

  # 应用 sysctl 参数而不重新启动
  sudo sysctl --system
}

_kubernetes_config() {

  _enable_ipv4_packet_forwarding

  systemctl enable kubelet.service

}

_kubernetes_init() {
  kubeadm init --image-repository="$kubernetes_images" --kubernetes-version="$kubernetes_version"
  echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >>/etc/profile
  source /etc/profile
  kubectl get node -o wide
  kubectl get svc -o wide
  kubectl get pod -A -o wide
}

_kubernetes_taint() {
  kubectl get nodes -o wide
  kubectl get pod -A -o wide
  kubectl get node -o yaml | grep taint -A 10
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  kubectl get node -o yaml | grep taint -A 10 | true
  kubectl get nodes -o wide
  kubectl get pod -A -o wide
}

# https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations
# https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations
_enable_shell_autocompletion() {

  if [[ $package_type == 'yum' ]]; then

    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
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
    calico_url="$calico_manifests_mirror"/"$calico_version"/manifests/calico.yaml
  fi
  echo "calico manifests url: $calico_url"
  curl -k -o calico.yaml $calico_url

  _interface_name

  sed -i '/k8s,bgp/a \            - name: IP_AUTODETECTION_METHOD\n              value: "interface=INTERFACE_NAME"' calico.yaml
  sed -i "s#INTERFACE_NAME#$interface_name#g" calico.yaml

  sed -i "s#${calico_node_images[-1]}#$calico_node_image#g" calico.yaml
  sed -i "s#${calico_cni_images[-1]}#$calico_cni_image#g" calico.yaml
  sed -i "s#${calico_kube_controllers_images[-1]}#$calico_kube_controllers_image#g" calico.yaml

  kubectl apply -f calico.yaml
  kubectl get pod -A -o wide
  kubectl wait --for=condition=Ready --all pods -A --timeout=300s || true
}

_ingress_nginx_install() {
  if ! [[ $ingress_nginx_url ]]; then
    ingress_nginx_url="$ingress_nginx_manifests_mirror"/controller-"$ingress_nginx_version"/deploy/static/provider/cloud/deploy.yaml
  fi
  echo "ingress nginx manifests url: $ingress_nginx_url"
  curl -k -o deploy.yaml $ingress_nginx_url

  sudo sed -i 's/@.*$//' deploy.yaml
  sudo sed -i "s#${ingress_nginx_controller_mirrors[-1]}#$ingress_nginx_controller_mirror#g" deploy.yaml
  sudo sed -i "s#${ingress_nginx_kube_webhook_certgen_mirrors[-1]}#$ingress_nginx_kube_webhook_certgen_mirror#g" deploy.yaml

  kubectl apply -f deploy.yaml
  kubectl get pod -A -o wide
}

_ingress_nginx_host_network() {
  kubectl -n ingress-nginx patch deployment ingress-nginx-controller --patch '{"spec": {"template": {"spec": {"hostNetwork": true}}}}'
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

_bash_completion() {
  if [[ $package_type == 'yum' ]]; then
    sudo yum -y install bash-completion
    source /etc/profile
  elif [[ $package_type == 'apt' ]]; then
    sudo apt-get -y install bash-completion
    source /etc/profile
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in

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

  calico-install | -calico-install | --calico-install)
    calico_install=true
    ;;

  calico-url=* | -calico-url=* | --calico-url=*)
    calico_url="${1#*=}"
    ;;

  calico-manifests-mirror=* | -calico-manifests-mirror=* | --calico-manifests-mirror=*)
    calico_manifests_mirror="${1#*=}"
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

  ingress-nginx-manifests-mirror=* | -ingress-nginx-manifests-mirror=* | --ingress-nginx-manifests-mirror=*)
    ingress_nginx_manifests_mirror="${1#*=}"
    ;;

  ingress-nginx-version=* | -ingress-nginx-version=* | --ingress-nginx-version=*)
    ingress_nginx_version="${1#*=}"
    ;;

  ingress-nginx-controller-image=* | -ingress-nginx-controller-image=* | --ingress-nginx-controller-image=*)
    ingress_nginx_controller_mirror="${1#*=}"
    ;;

  ingress-nginx-kube-webhook-certgen-image=* | -ingress-nginx-kube-webhook-certgen-image=* | --ingress-nginx-kube-webhook-certgen-image=*)
    ingress_nginx_kube_webhook_certgen_mirror="${1#*=}"
    ;;

  *)
    echo -e "${COLOR_RED}无效参数: $1，退出程序${COLOR_RESET}"
    exit 1
    ;;
  esac
  shift
done

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
