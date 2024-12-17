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
readonly EMOJI_FAILURE="\U0001F61E"

# 文档简介链接
readonly DOCS_README_LINK=https://k8s-sh.xuxiaowei.com.cn/README.html
# 文档配置链接
readonly DOCS_CONFIG_LINK=https://k8s-sh.xuxiaowei.com.cn/config.html

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
echo -e "${COLOR_BLUE}系统类型: ${COLOR_GREEN}$os_type${COLOR_RESET}"

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
echo -e "${COLOR_BLUE}系统版本: ${COLOR_GREEN}$os_version${COLOR_RESET}"

readonly kylin_release_id=$(grep -w "KYLIN_RELEASE_ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
if [[ $kylin_release_id ]]; then
  echo -e "${COLOR_BLUE}银河麒麟代码版本: ${COLOR_GREEN}$kylin_release_id${COLOR_RESET}"
fi

# 代码版本
readonly code_name=$(grep -w "VERSION_CODENAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
if [[ $code_name ]]; then
  echo -e "${COLOR_BLUE}代码版本: ${COLOR_GREEN}$code_name${COLOR_RESET}"
fi

if [[ $os_type == 'centos' ]]; then
  readonly centos_os_version=$(cat /etc/redhat-release | awk '{print $4}')
  echo -e "${COLOR_BLUE}CentOS 系统具体版本: ${COLOR_GREEN}$centos_os_version${COLOR_RESET}"
fi

if [ -e "/etc/debian_version" ]; then
  readonly debian_os_version=$(cat /etc/debian_version)
  echo -e "${COLOR_BLUE}Debian 系统具体版本: ${COLOR_GREEN}$debian_os_version${COLOR_RESET}"
fi

# apt 锁超时时间
dpkg_lock_timeout=120

# Kubernetes 具体版本，包含: 主版本号、次版本号、修正版本号
kubernetes_version=v1.31.4
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

helm_version=v3.16.3
# https://mirrors.huaweicloud.com/helm/v3.16.3/helm-v3.16.3-linux-amd64.tar.gz
# https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz
helm_mirrors=("https://mirrors.huaweicloud.com/helm" "https://get.helm.sh")

kubernetes_dashboard_charts=("http://k8s-sh.xuxiaowei.com.cn/charts/kubernetes/dashboard" "https://kubernetes.github.io/dashboard")
kubernetes_dashboard_chart=${kubernetes_dashboard_charts[0]}
kubernetes_dashboard_version=7.10.0
kubernetes_dashboard_auth_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-auth" "docker.io/kubernetesui/dashboard-auth")
kubernetes_dashboard_auth_image=${kubernetes_dashboard_auth_images[0]}
kubernetes_dashboard_api_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-api" "docker.io/kubernetesui/dashboard-api")
kubernetes_dashboard_api_image=${kubernetes_dashboard_api_images[0]}
kubernetes_dashboard_web_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-web" "docker.io/kubernetesui/dashboard-web")
kubernetes_dashboard_web_image=${kubernetes_dashboard_web_images[0]}
kubernetes_dashboard_metrics_scraper_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-metrics-scraper" "docker.io/kubernetesui/dashboard-metrics-scraper")
kubernetes_dashboard_metrics_scraper_image=${kubernetes_dashboard_metrics_scraper_images[0]}
kubernetes_dashboard_kong_images=("registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kong" "docker.io/library/kong")
kubernetes_dashboard_kong_image=${kubernetes_dashboard_kong_images[0]}
kubernetes_dashboard_ingress_enabled=true
kubernetes_dashboard_ingress_host=kubernetes.dashboard.xuxiaowei.com.cn

etcd_version=v3.5.17
etcd_mirrors=("https://mirrors.huaweicloud.com/etcd" "https://storage.googleapis.com/etcd" "https://github.com/etcd-io/etcd/releases/download")
etcd_url=${etcd_mirrors[0]}/${etcd_version}/etcd-${etcd_version}-linux-amd64.tar.gz
etcd_join_port=22

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
  echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type${COLOR_RESET}"
  echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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
        anolis_docker_version=8
        echo -e "${COLOR_BLUE}$os_type $os_version 使用 $docker_repo_name $anolis_docker_version Docker 安装包${COLOR_RESET}"
        sudo sed -i "s#\$releasever#$anolis_docker_version#" /etc/yum.repos.d/docker-ce.repo
        ;;
      *) ;;
      esac
    fi

    if [[ $os_type == 'openEuler' ]]; then
      case "$os_version" in
      '20.03' | '22.03' | '24.03')
        openEuler_docker_version=8
        echo -e "${COLOR_BLUE}$os_type $os_version 使用 $docker_repo_name $openEuler_docker_version Docker 安装包${COLOR_RESET}"
        sudo sed -i "s#\$releasever#$openEuler_docker_version#" /etc/yum.repos.d/docker-ce.repo
        ;;
      *) ;;
      esac
    fi

  elif [[ $package_type == 'apt' ]]; then

    sudo mkdir -p /etc/apt/sources.list.d

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
        openkylin_docker_version=bookworm
        echo -e "${COLOR_BLUE}$os_type $os_version $code_name 使用 $docker_repo_name $openkylin_docker_version Docker 安装包${COLOR_RESET}"
        sed -i "s#$code_name#$openkylin_docker_version#" /etc/apt/sources.list.d/docker.list
        ;;
      *) ;;
      esac
    fi

    if [[ $os_type == 'kylin' ]]; then
      case "$os_version" in
      v10)
        kylin_docker_version=bullseye
        echo -e "${COLOR_BLUE}$os_type $os_version $code_name 使用 $docker_repo_name $kylin_docker_version Docker 安装包${COLOR_RESET}"
        sed -i "s#$code_name#$kylin_docker_version#" /etc/apt/sources.list.d/docker.list
        ;;
      *) ;;
      esac
    fi

    if [[ $os_type == 'Deepin' ]]; then
      case "$code_name" in
      apricot)
        deepin_docker_version=bullseye
        echo -e "${COLOR_BLUE}$os_type $code_name $os_version 使用 $docker_repo_name $deepin_docker_version Docker 安装包${COLOR_RESET}"
        sed -i "s#$code_name#$deepin_docker_version#" /etc/apt/sources.list.d/docker.list
        ;;
      *) ;;
      esac
    fi

    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update

  else

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}配置 Docker 源${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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
  kylin)
    if [[ $os_version == 'v10' ]]; then
      for pkg in docker.io docker-doc docker-compose containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    else
      for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout remove -y $pkg; done
    fi
    ;;
  *)
    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}卸载旧版 Docker${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
    exit 1
    ;;
  esac
}

_containerd_install() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

    if [[ $os_type == 'openEuler' && $os_version == '20.03' ]]; then
      echo -e "${COLOR_BLUE}$os_type $os_version 安装 ${COLOR_GREEN}$container_selinux_rpm${COLOR_RESET}"
      sudo yum install -y $container_selinux_rpm
    fi

    sudo yum install -y containerd.io

  elif [[ $package_type == 'apt' ]]; then

    _remove_apt_ord_docker
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y containerd.io

  else

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}安装 Containerd${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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
  containerd_config_backup_path=/etc/containerd/config.toml.$(date +%Y%m%d%H%M%S)
  echo -e "${COLOR_BLUE}containerd 备份历史配置路径: ${COLOR_GREEN}$containerd_config_backup_path${COLOR_RESET}"
  sudo cp /etc/containerd/config.toml $containerd_config_backup_path || true
  sudo containerd config default | sudo tee /etc/containerd/config.toml

  # 兼容 OpenKylin 2.0，防止在 /etc/containerd/config.toml 生成无关配置
  if [[ $os_type == 'openkylin' && $os_version == '2.0' ]]; then
    echo -e "${COLOR_BLUE}$os_type $os_version 注释 /etc/containerd/config.toml 无用配置${COLOR_RESET}"
    sudo sed -i 's/^User/#&/' /etc/containerd/config.toml
  fi

  echo -e "${COLOR_BLUE}containerd 配置中，registry.k8s.io/pause 使用: ${COLOR_GREEN}$pause_image ${COLOR_BLUE}镜像${COLOR_RESET}"
  sudo sed -i "s#registry.k8s.io/pause#$pause_image#g" /etc/containerd/config.toml

  echo -e "${COLOR_BLUE}containerd 配置中，SystemdCgroup 设置为: ${COLOR_GREEN}true ${COLOR_RESET}"
  sudo sed -i "s#SystemdCgroup = false#SystemdCgroup = true#g" /etc/containerd/config.toml

  sudo systemctl restart containerd
  sudo systemctl status containerd -l --no-pager
  sudo systemctl enable containerd
}

_docker_install() {
  if [[ $package_type == 'yum' ]]; then

    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

    if [[ $os_type == 'openEuler' && $os_version == '20.03' ]]; then
      echo -e "${COLOR_BLUE}$os_type $os_version 安装 ${COLOR_GREEN}$container_selinux_rpm${COLOR_RESET}"
    fi

    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  elif [[ $package_type == 'apt' ]]; then

    _remove_apt_ord_docker
    sudo apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  else

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}安装 Docker${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}安装 socat${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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
      echo -e "${COLOR_BLUE}开启了 gpg 检查${COLOR_RESET}"
      kubernetes_gpgcheck=1
      ;;
    *)
      echo -e "${COLOR_BLUE}未开启 gpg 检查${COLOR_RESET}"
      ;;
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

    sudo mkdir -p /etc/apt/sources.list.d

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

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}配置 Kubernetes 源${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}安装 curl${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}安装 ca-certificates${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}安装 Kubernetes${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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
    echo -e "${COLOR_YELLOW}/etc/sysctl.conf 文件中关闭了 net.ipv4.ip_forward，将注释此配置${COLOR_RESET}"
    # 如果 IPv4 数据包转发 已关闭: 注释已存在的配置，防止冲突
    sudo sed -i 's|net.ipv4.ip_forward|#net.ipv4.ip_forward|g' /etc/sysctl.conf
  fi

  ipv4_ip_forward=$(grep -w "net.ipv4.ip_forward" /etc/sysctl.d/99-sysctl.conf | cut -d'=' -f2 | tr -d ' ')
  if [[ $ipv4_ip_forward == '0' ]]; then
    echo -e "${COLOR_YELLOW}/etc/sysctl.d/99-sysctl.conf 文件中关闭了 net.ipv4.ip_forward，将注释此配置${COLOR_RESET}"
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
  elif [[ $os_type == 'almalinux' ]]; then
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

_kubernetes_init_congrats() {
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

  if [[ $standalone == true ]]; then
    # 单机模式，在下方 $standalone == true 时执行 _kubernetes_init_congrats
    echo
  elif [[ $cluster == true ]]; then
    # 集群模式，在下方 $cluster == true 时执行 _kubernetes_init_congrats
    echo
  elif [[ $node == true ]]; then
    # 工作节点准备，不执行 _kubernetes_init_congrats
    echo
  else
    _kubernetes_init_congrats
  fi
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

    echo -e "${COLOR_RED}不支持的发行版: ${COLOR_GREEN}$os_type ${COLOR_RED}启用 shell 自动补全功能${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看已支持的发行版: ${COLOR_GREEN}$DOCS_README_LINK${COLOR_RESET}"
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
      echo -e "${COLOR_RED}请阅读文档，查看网卡配置 interface-name: ${COLOR_GREEN}${DOCS_CONFIG_LINK}#interface-name${COLOR_RESET}"
      exit 1
    fi
  fi
}

_calico_install() {
  if ! [[ $calico_url ]]; then
    calico_url=$calico_mirror/$calico_version/manifests/calico.yaml
  fi
  echo -e "${COLOR_BLUE}calico manifests url: ${COLOR_GREEN}$calico_url${COLOR_RESET}"

  calico_local_path=calico.yaml
  if [[ $calico_url =~ ^https?:// ]]; then
    curl -k -o $calico_local_path $calico_url
  else
    calico_local_path=$calico_url
  fi

  if grep -q "interface=" "$calico_local_path"; then
    echo -e "${COLOR_BLUE}已配置 calico 使用的网卡，脚本跳过网卡配置${COLOR_RESET}"
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
  echo -e "${COLOR_BLUE}ingress nginx manifests url: ${COLOR_GREEN}$ingress_nginx_url${COLOR_RESET}"

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
  echo -e "${COLOR_BLUE}metrics server manifests url: ${COLOR_GREEN}$metrics_server_url${COLOR_RESET}"

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

_tar_install() {
  if ! command -v 'tar' &>/dev/null; then
    if [[ $package_type == 'yum' ]]; then
      echo -e "${COLOR_BLUE}tar 未安装，正在安装...${COLOR_RESET}"
      sudo yum install -y tar
      echo -e "${COLOR_BLUE}tar 安装完成${COLOR_RESET}"
    elif [[ $package_type == 'apt' ]]; then
      echo -e "${COLOR_BLUE}tar 未安装，正在安装...${COLOR_RESET}"
      apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
      apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y tar
      echo -e "${COLOR_BLUE}tar 安装完成${COLOR_RESET}"
    fi
  fi
}

_helm_install() {

  if ! [[ $helm_url ]]; then
    case "$helm_repo_type" in
    "" | huawei)
      helm_url=${helm_mirrors[0]}/$helm_version/helm-$helm_version-linux-amd64.tar.gz
      ;;
    helm)
      helm_url=${helm_mirrors[-1]}/helm-$helm_version-linux-amd64.tar.gz
      ;;
    *) ;;
    esac
  fi
  echo -e "${COLOR_BLUE}helm url: ${COLOR_GREEN}$helm_url${COLOR_RESET}"

  helm_local_path=helm-$helm_version-linux-amd64.tar.gz
  helm_local_folder=helm-$helm_version-linux-amd64
  if [[ $helm_url =~ ^https?:// ]]; then
    curl -k -o $helm_local_path $helm_url
  else
    helm_local_path=$helm_url
  fi

  _tar_install

  mkdir -p $helm_local_folder
  tar -zxvf $helm_local_path --strip-components=1 -C $helm_local_folder

  $helm_local_folder/helm version
  mv $helm_local_folder/helm /usr/local/bin/helm
  /usr/local/bin/helm version
  /usr/local/bin/helm ls -A
}

# https://github.com/kubernetes/dashboard?tab=readme-ov-file#installation
# https://github.com/kubernetes/dashboard/blob/master/charts/kubernetes-dashboard/values.yaml
# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
_helm_install_kubernetes_dashboard() {
  echo -e "${COLOR_BLUE}准备清理已存在的 kubernetes-dashboard charts 仓库 ...${COLOR_RESET}"
  helm repo remove kubernetes-dashboard || echo -e "${COLOR_BLUE}本地未安装 kubernetes-dashboard 仓库${COLOR_RESET}"
  echo -e "${COLOR_BLUE}准备安装 kubernetes-dashboard charts 仓库: ${COLOR_GREEN}$kubernetes_dashboard_chart${COLOR_RESET}"
  helm repo add kubernetes-dashboard $kubernetes_dashboard_chart

  echo -e "${COLOR_BLUE}准备生成 kubernetes-dashboard charts 仓库安装配置 ...${COLOR_RESET}"
  cat <<EOF | sudo tee kubernetes_dashboard.yml
app:
  ingress:
    enabled: $kubernetes_dashboard_ingress_enabled
    hosts:
      - localhost
      - $kubernetes_dashboard_ingress_host
    # Default: internal-nginx
    ingressClassName: nginx
auth:
  image:
    repository: $kubernetes_dashboard_auth_image
api:
  image:
    repository: $kubernetes_dashboard_api_image
web:
  image:
    repository: $kubernetes_dashboard_web_image
metricsScraper:
  image:
    repository: $kubernetes_dashboard_metrics_scraper_image
kong:
  image:
    repository: $kubernetes_dashboard_kong_image

EOF

  echo -e "${COLOR_BLUE}准备使用自定义配置安装 kubernetes-dashboard charts ...${COLOR_RESET}"
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard --version $kubernetes_dashboard_version -f kubernetes_dashboard.yml

  echo -e "${COLOR_BLUE}准备生成 kubernetes-dashboard service account yml ...${COLOR_RESET}"
  cat <<EOF | sudo tee kubernetes_dashboard_service_account.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

EOF

  echo -e "${COLOR_BLUE}准备生成 kubernetes-dashboard cluster role binding yml ...${COLOR_RESET}"
  cat <<EOF | sudo tee kubernetes_dashboard_cluster_role_binding.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard

EOF

  echo -e "${COLOR_BLUE}准备生成 kubernetes-dashboard secret yml ...${COLOR_RESET}"
  cat <<EOF | sudo tee kubernetes_dashboard_secret.yml
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token

EOF

  echo -e "${COLOR_BLUE}准备创建 kubernetes-dashboard service account yml ...${COLOR_RESET}"
  kubectl apply -f kubernetes_dashboard_service_account.yml
  echo -e "${COLOR_BLUE}准备创建 kubernetes-dashboard cluster role binding yml ...${COLOR_RESET}"
  kubectl apply -f kubernetes_dashboard_cluster_role_binding.yml
  echo -e "${COLOR_BLUE}准备创建 kubernetes-dashboard secret yml ...${COLOR_RESET}"
  kubectl apply -f kubernetes_dashboard_secret.yml

  echo -e "${COLOR_BLUE}准备创建 kubernetes-dashboard token（默认有效期 1h） ...${COLOR_RESET}"
  echo -e "${COLOR_BLUE}使用: ${COLOR_GREEN}kubectl -n kubernetes-dashboard create token admin-user --duration=86400s ${COLOR_BLUE}创建指定有效时间的 token${COLOR_RESET}"
  echo -e "${COLOR_BLUE}使用: ${COLOR_GREEN}kubectl -n kubernetes-dashboard get secret admin-user -o jsonpath={".data.token"} | base64 -d ${COLOR_BLUE}获取长期 token${COLOR_RESET}"
  echo ''
  kubectl -n kubernetes-dashboard create token admin-user
  echo ''
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

_etcd_binary_install() {

  _firewalld_stop

  mkdir -p /root/.ssh

  if ! [[ $etcd_current_ip ]]; then
    etcd_current_ip=$(hostname -I | awk '{print $1}')
  fi

  # 当存在 etcd_ips 参数时，当前机器的 IP 必须在 etcd_ips 参数内
  if [[ $etcd_ips ]]; then
    if ! [[ "${etcd_ips[*]}" =~ ${etcd_current_ip} ]]; then
      echo "当前机器的 IP: $etcd_current_ip 不在 etcd 集群 IP 列表中，终止 etcd 安装"
      for etcd_ip in "${etcd_ips[@]}"; do
        echo "$etcd_ip"
      done
      exit 1
    fi
  fi

  # etcd_ips 参数的个数
  etcd_ips_length=${#etcd_ips[@]}
  # etcd_ips 参数中 @ 的数量
  etcd_ips_at_num=0
  # etcd_ips 参数中，自定义的 ETCD 节点 名称
  etcd_ips_names=()
  # etcd_ips 参数中，自定义的 ETCD 节点 IP
  etcd_ips_tmp=()
  for etcd_ip in "${etcd_ips[@]}"; do
    etcd_ip_tmp=$(echo $etcd_ip | awk -F'@' '{print $1}')
    etcd_ip_name_tmp=$(echo $etcd_ip | awk -F'@' '{print $2}')

    if [[ $etcd_ip_name_tmp ]]; then
      etcd_ips_names+=("$etcd_ip_name_tmp")
      etcd_ips_at_num=$(($etcd_ips_at_num + 1))
    fi

    etcd_ips_tmp+=("$etcd_ip_tmp")
  done

  if [[ $etcd_ips_at_num != 0 && "$etcd_ips_at_num" != "$etcd_ips_length" ]]; then
    echo "ETCD 名称配置错误：只能全部忽略名称或全部自定义名称"
    echo "etcd_ips: ${etcd_ips[*]}"
    exit 1
  fi

  etcd_ips=("${etcd_ips_tmp[@]}")
  etcd_ips_names_length=${#etcd_ips_names[@]}

  echo "当前 etcd 节点的 IP: $etcd_current_ip"
  echo "etcd 集群配置:"
  local etcd_num=0
  etcd_initial_cluster=''
  for etcd_ip in "${etcd_ips[@]}"; do
    etcd_num=$(($etcd_num + 1))
    if [[ $etcd_ips_names_length == 0 ]]; then
      etcd_name="etcd-$etcd_num"
    else
      etcd_name="${etcd_ips_names[$etcd_num - 1]}"
    fi

    echo "$etcd_name: $etcd_ip:2379"
    etcd_initial_cluster+=$etcd_name=https://$etcd_ip:2380,
  done
  etcd_initial_cluster="${etcd_initial_cluster%,}"

  _tar_install

  echo "etcd_url=$etcd_url"

  curl -L "${etcd_url}" -o etcd-${etcd_version}-linux-amd64.tar.gz
  tar xzvf etcd-${etcd_version}-linux-amd64.tar.gz

  etcd-${etcd_version}-linux-amd64/etcd --version
  etcd-${etcd_version}-linux-amd64/etcdctl version
  etcd-${etcd_version}-linux-amd64/etcdutl version

  cp etcd-${etcd_version}-linux-amd64/etcd /usr/local/bin/
  cp etcd-${etcd_version}-linux-amd64/etcdctl /usr/local/bin/
  cp etcd-${etcd_version}-linux-amd64/etcdutl /usr/local/bin/

  /usr/local/bin/etcd --version
  /usr/local/bin/etcdctl version
  /usr/local/bin/etcdutl version

  if ! command -v 'openssl' &>/dev/null; then
    if [[ $package_type == 'yum' ]]; then
      echo -e "${COLOR_BLUE}openssl 未安装，正在安装...${COLOR_RESET}"
      sudo yum install -y openssl
      echo -e "${COLOR_BLUE}openssl 安装完成${COLOR_RESET}"
    elif [[ $package_type == 'apt' ]]; then
      echo -e "${COLOR_BLUE}openssl 未安装，正在安装...${COLOR_RESET}"
      apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
      apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y openssl
      echo -e "${COLOR_BLUE}openssl 安装完成${COLOR_RESET}"
    fi
  fi

  openssl genrsa -out etcd-ca.key 2048
  openssl req -x509 -new -nodes -key etcd-ca.key -subj "/CN=$etcd_current_ip" -days 36500 -out etcd-ca.crt

  mkdir -p /etc/kubernetes/pki/etcd
  cp etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
  cp etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
  ls -lh /etc/kubernetes/pki/etcd/ca.key
  ls -lh /etc/kubernetes/pki/etcd/ca.crt

  cat >etcd_ssl.cnf <<EOF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[ req_distinguished_name ]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]

EOF

  cat etcd_ssl.cnf

  local etcd_num=1
  echo "IP.$etcd_num = $etcd_current_ip" >>etcd_ssl.cnf
  for etcd_ip in "${etcd_ips[@]}"; do
    etcd_num=$(($etcd_num + 1))
    echo "IP.$etcd_num = $etcd_ip" >>etcd_ssl.cnf
  done

  cat etcd_ssl.cnf

  mkdir -p /etc/etcd/pki/

  # 创建 etcd 服务端 CA 证书
  openssl genrsa -out etcd_server.key 2048
  openssl req -new -key etcd_server.key -config etcd_ssl.cnf -subj "/CN=etcd-server" -out etcd_server.csr
  openssl x509 -req -in etcd_server.csr -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -days 36500 -extensions v3_req -extfile etcd_ssl.cnf -out etcd_server.crt
  cp etcd_server.crt /etc/etcd/pki/
  cp etcd_server.key /etc/etcd/pki/
  ls -lh /etc/etcd/pki/etcd_server.crt
  ls -lh /etc/etcd/pki/etcd_server.key

  # 创建 etcd 客户端 CA 证书
  openssl genrsa -out etcd_client.key 2048
  openssl req -new -key etcd_client.key -config etcd_ssl.cnf -subj "/CN=etcd-client" -out etcd_client.csr
  openssl x509 -req -in etcd_client.csr -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -days 36500 -extensions v3_req -extfile etcd_ssl.cnf -out etcd_client.crt
  cp etcd_client.crt /etc/etcd/pki/
  cp etcd_client.key /etc/etcd/pki/
  ls -lh /etc/etcd/pki/etcd_client.crt
  ls -lh /etc/etcd/pki/etcd_client.key

  etcd_ips_names_length=${#etcd_ips_names[@]}
  etcd_init_name=etcd-1
  if [[ $etcd_ips_names_length != 0 ]]; then
    etcd_init_name=${etcd_ips_names[0]}
  fi

  cat >/etc/etcd/etcd.conf <<EOF
# 节点名称，每个节点不同
ETCD_NAME=$etcd_init_name
# 数据目录
ETCD_DATA_DIR=/etc/etcd/data

# etcd 服务端CA证书-crt
ETCD_CERT_FILE=/etc/etcd/pki/etcd_server.crt
# etcd 服务端CA证书-key
ETCD_KEY_FILE=/etc/etcd/pki/etcd_server.key
ETCD_TRUSTED_CA_FILE=/etc/kubernetes/pki/etcd/ca.crt
# 是否启用客户端证书认证
ETCD_CLIENT_CERT_AUTH=true
# 客户端提供的服务监听URL地址
ETCD_LISTEN_CLIENT_URLS=https://$etcd_current_ip:2379
ETCD_ADVERTISE_CLIENT_URLS=https://$etcd_current_ip:2379

# 集群各节点相互认证使用的CA证书-crt
ETCD_PEER_CERT_FILE=/etc/etcd/pki/etcd_server.crt
# 集群各节点相互认证使用的CA证书-key
ETCD_PEER_KEY_FILE=/etc/etcd/pki/etcd_server.key
# CA 根证书
ETCD_PEER_TRUSTED_CA_FILE=/etc/kubernetes/pki/etcd/ca.crt
# 为本集群其他节点提供的服务监听URL地址
ETCD_LISTEN_PEER_URLS=https://$etcd_current_ip:2380
ETCD_INITIAL_ADVERTISE_PEER_URLS=https://$etcd_current_ip:2380

# 集群名称
ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
# 集群各节点endpoint列表
ETCD_INITIAL_CLUSTER="$etcd_initial_cluster"
# 初始集群状态
ETCD_INITIAL_CLUSTER_STATE=new

EOF

  cat /etc/etcd/etcd.conf

  cat >/usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
EnvironmentFile=/etc/etcd/etcd.conf
ExecStart=/usr/local/bin/etcd
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target

EOF

  cat /usr/lib/systemd/system/etcd.service

  systemctl daemon-reload
  systemctl enable etcd.service
  systemctl restart etcd.service
  systemctl status etcd.service -l --no-pager

  local test_etcd
  if ! [[ $etcd_ips ]]; then
    test_etcd=true
  fi
  if [[ $etcd_ips_length == 1 ]]; then
    test_etcd=true
  fi
  if [[ $test_etcd == true ]]; then
    etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/etcd/pki/etcd_client.crt --key=/etc/etcd/pki/etcd_client.key --endpoints=https://"$etcd_current_ip":2379 endpoint health
  fi
}

_etcd_binary_join() {

  _firewalld_stop

  if ! [[ $etcd_current_ip ]]; then
    etcd_current_ip=$(hostname -I | awk '{print $1}')
  fi

  if [[ -f /root/.ssh/id_rsa ]]; then
    mv /root/.ssh/id_rsa /root/.ssh/id_rsa.$(date +%Y%m%d%H%M%S)
  fi
  if [[ -f /root/.ssh/id_rsa.pub ]]; then
    mv /root/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub.$(date +%Y%m%d%H%M%S)
  fi

  ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' -q
  ssh-keyscan -H $etcd_join_ip -P $etcd_join_port >> /root/.ssh/known_hosts

  if [[ $etcd_join_password ]]; then
    if ! command -v 'sshpass' &>/dev/null; then
      if [[ $package_type == 'yum' ]]; then
        sudo yum install -y sshpass
      else
        apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y sshpass
      fi
    fi

    sshpass -p $etcd_join_password scp -P $etcd_join_port /root/.ssh/id_rsa.pub root@$etcd_join_ip:/root/.ssh/authorized_keys
  else

    scp -P $etcd_join_port /root/.ssh/id_rsa.pub root@$etcd_join_ip:/root/.ssh/authorized_keys
  fi

  mkdir -p /etc/kubernetes/pki/etcd
  mkdir -p /etc/etcd/pki/

  scp -P $etcd_join_port root@$etcd_join_ip:/usr/local/bin/etcd /usr/local/bin/
  scp -P $etcd_join_port root@$etcd_join_ip:/usr/local/bin/etcdctl /usr/local/bin/
  scp -P $etcd_join_port root@$etcd_join_ip:/usr/local/bin/etcdutl /usr/local/bin/

  scp -P $etcd_join_port root@$etcd_join_ip:/etc/kubernetes/pki/etcd/ca.key /etc/kubernetes/pki/etcd/
  scp -P $etcd_join_port root@$etcd_join_ip:/etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/

  scp -P $etcd_join_port root@$etcd_join_ip:/usr/lib/systemd/system/etcd.service /usr/lib/systemd/system/

  scp -P $etcd_join_port root@$etcd_join_ip:/etc/etcd/pki/etcd_server.crt /etc/etcd/pki/
  scp -P $etcd_join_port root@$etcd_join_ip:/etc/etcd/pki/etcd_server.key /etc/etcd/pki/
  scp -P $etcd_join_port root@$etcd_join_ip:/etc/etcd/pki/etcd_client.crt /etc/etcd/pki/
  scp -P $etcd_join_port root@$etcd_join_ip:/etc/etcd/pki/etcd_client.key /etc/etcd/pki/

  scp -P $etcd_join_port root@$etcd_join_ip:/etc/etcd/etcd.conf /etc/etcd/

  source /etc/etcd/etcd.conf

  echo $ETCD_INITIAL_CLUSTER

  etcd_from_name=$ETCD_NAME
  echo $etcd_from_name

  etcd_current_ip=$(hostname -I | awk '{print $1}')
  echo $etcd_current_ip

  IFS=',' read -ra etcd_nodes <<<"$ETCD_INITIAL_CLUSTER"
  for etcd_node in "${etcd_nodes[@]}"; do
    echo $etcd_node
    if [[ $etcd_node =~ $etcd_current_ip ]]; then
      node_name=$(echo $etcd_node | awk -F'=' '{print $1}')
      break
    fi
  done

  echo $node_name

  sudo sed -i "s#ETCD_NAME=$etcd_from_name#ETCD_NAME=$node_name#g" /etc/etcd/etcd.conf

  sudo sed -i "s#ETCD_LISTEN_CLIENT_URLS=https://$etcd_join_ip:2379#ETCD_LISTEN_CLIENT_URLS=https://$etcd_current_ip:2379#g" /etc/etcd/etcd.conf
  sudo sed -i "s#ETCD_ADVERTISE_CLIENT_URLS=https://$etcd_join_ip:2379#ETCD_ADVERTISE_CLIENT_URLS=https://$etcd_current_ip:2379#g" /etc/etcd/etcd.conf

  sudo sed -i "s#ETCD_LISTEN_PEER_URLS=https://$etcd_join_ip:2380#ETCD_LISTEN_PEER_URLS=https://$etcd_current_ip:2380#g" /etc/etcd/etcd.conf
  sudo sed -i "s#ETCD_INITIAL_ADVERTISE_PEER_URLS=https://$etcd_join_ip:2380#ETCD_INITIAL_ADVERTISE_PEER_URLS=https://$etcd_current_ip:2380#g" /etc/etcd/etcd.conf

  /usr/local/bin/etcd --version
  /usr/local/bin/etcdctl version
  /usr/local/bin/etcdutl version

  systemctl daemon-reload
  systemctl enable etcd.service
  systemctl restart etcd.service
  systemctl status etcd.service -l --no-pager
}

while [[ $# -gt 0 ]]; do
  case "$1" in

  config=* | -config=* | --config=*)
    config="${1#*=}"
    echo -e "${COLOR_BLUE}启用了配置文件 ${COLOR_GREEN}$config${COLOR_RESET}"
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
      echo -e "${COLOR_BLUE}使用自定义 Kubernetes 仓库地址 ${COLOR_GREEN}$kubernetes_repo_type${COLOR_RESET}"
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
      echo -e "${COLOR_RED}不支持自定义 Kubernetes 镜像仓库: ${COLOR_GREEN}$kubernetes_images${COLOR_RESET}"
      echo -e "${COLOR_RED}请阅读文档，查看 Kubernetes 镜像仓库配置 kubernetes-images: ${COLOR_GREEN}${DOCS_CONFIG_LINK}#kubernetes-images${COLOR_RESET}"
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

  kubernetes-init-congrats | -kubernetes-init-congrats | --kubernetes-init-congrats)
    kubernetes_init_congrats=true
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
      echo -e "${COLOR_BLUE}使用自定义 Docker 仓库地址: ${COLOR_GREEN}$docker_repo_type${COLOR_RESET}"
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

  helm-install | -helm-install | --helm-install)
    helm_install=true
    ;;

  helm-version=* | -helm-version=* | --helm-version=*)
    helm_version="${1#*=}"
    ;;

  helm-url=* | -helm-url=* | --helm-url=*)
    helm_url="${1#*=}"
    ;;

  helm-repo-type=* | -helm-repo-type=* | --helm-repo-type=*)
    helm_repo_type="${1#*=}"
    case "$helm_repo_type" in
    "" | huawei | helm) ;;
    *)
      echo -e "${COLOR_RED}helm-repo-type 参数值: ${COLOR_GREEN}$helm_repo_type${COLOR_RED} 无效，合法值: 空、huawei、helm，或者使用 helm-url 自定义 helm 下载地址，退出程序${COLOR_RESET}"
      echo -e "${COLOR_RED}请阅读文档，查看 helm 仓库配置 helm-repo-type: ${COLOR_GREEN}${DOCS_CONFIG_LINK}#helm-repo-type${COLOR_RESET}"
      exit 1
      ;;
    esac
    ;;

  helm-install-kubernetes-dashboard | -helm-install-kubernetes-dashboard | --helm-install-kubernetes-dashboard)
    helm_install_kubernetes_dashboard=true
    ;;

  kubernetes-dashboard-chart=* | -kubernetes-dashboard-chart=* | --kubernetes-dashboard-chart=*)
    kubernetes_dashboard_chart="${1#*=}"
    ;;

  kubernetes-dashboard-version=* | -kubernetes-dashboard-version=* | --kubernetes-dashboard-version=*)
    kubernetes_dashboard_version="${1#*=}"
    ;;

  kubernetes-dashboard-auth-image=* | -kubernetes-dashboard-auth-image=* | --kubernetes-dashboard-auth-image=*)
    kubernetes_dashboard_auth_image="${1#*=}"
    ;;

  kubernetes-dashboard-api-image=* | -kubernetes-dashboard-api-image=* | --kubernetes-dashboard-api-image=*)
    kubernetes_dashboard_api_image="${1#*=}"
    ;;

  kubernetes-dashboard-web-image=* | -kubernetes-dashboard-web-image=* | --kubernetes-dashboard-web-image=*)
    kubernetes_dashboard_web_image="${1#*=}"
    ;;

  kubernetes-dashboard-metrics-scraper-image=* | -kubernetes-dashboard-metrics-scraper-image=* | --kubernetes-dashboard-metrics-scraper-image=*)
    kubernetes_dashboard_metrics_scraper_image="${1#*=}"
    ;;

  kubernetes-dashboard-kong-image=* | -kubernetes-dashboard-kong-image=* | --kubernetes-dashboard-kong-image=*)
    kubernetes_dashboard_kong_image="${1#*=}"
    ;;

  kubernetes-dashboard-ingress-enabled=* | -kubernetes-dashboard-ingress-enabled=* | --kubernetes-dashboard-ingress-enabled=*)
    kubernetes_dashboard_ingress_enabled="${1#*=}"
    if [[ $kubernetes_dashboard_ingress_enabled != 'true' && $kubernetes_dashboard_ingress_enabled != 'false' ]]; then
      echo -e "${COLOR_RED}无效参数: kubernetes-dashboard-ingress-enabled=$kubernetes_dashboard_ingress_enabled，合法值：true/false，退出程序${COLOR_RESET}"
    fi
    ;;

  kubernetes-dashboard-ingress-host=* | -kubernetes-dashboard-ingress-host=* | --kubernetes-dashboard-ingress-host=*)
    kubernetes_dashboard_ingress_host="${1#*=}"
    ;;

  etcd-binary-install | -etcd-binary-install | --etcd-binary-install)
    etcd_binary_install=true
    ;;

  etcd-ips=* | -etcd-ips=* | --etcd-ips=*)
    etcd_ips+=("${1#*=}")
    ;;

  etcd-url=* | -etcd-url=* | --etcd-url=*)
    etcd_url="${1#*=}"
    ;;

  etcd-current-ip=* | -etcd-current-ip=* | --etcd-current-ip=*)
    etcd_current_ip="${1#*=}"
    ;;

  etcd-binary-join | -etcd-binary-join | --etcd-binary-join)
    etcd_binary_join=true
    ;;

  etcd-join-ip=* | -etcd-join-ip=* | --etcd-join-ip=*)
    etcd_join_ip="${1#*=}"
    ;;

  etcd-join-port=* | -etcd-join-port=* | --etcd-join-port=*)
    etcd_join_port="${1#*=}"
    ;;

  *)
    echo -e "${COLOR_RED}无效参数: $1，退出程序${COLOR_RESET}"
    echo -e "${COLOR_RED}请阅读文档，查看参数配置: ${COLOR_GREEN}$DOCS_CONFIG_LINK${COLOR_RESET}"
    exit 1
    ;;
  esac
  shift
done

if ! command -v 'sudo' &>/dev/null; then
  if [[ $package_type == 'apt' ]]; then
    echo -e "${COLOR_BLUE}sudo 未安装，正在安装...${COLOR_RESET}"
    apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout update
    apt-get -o Dpkg::Lock::Timeout=$dpkg_lock_timeout install -y sudo
    echo -e "${COLOR_BLUE}sudo 安装完成${COLOR_RESET}"
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

# 三者互斥

count=0

if [[ $standalone == true ]]; then
  count=$(expr $count + 1)
fi

if [[ $cluster == true ]]; then
  count=$(expr $count + 1)
fi

if [[ $node == true ]]; then
  count=$(expr $count + 1)
fi

if [[ $count -gt 1 ]]; then
  echo ''
  echo ''
  echo ''
  echo -e "${COLOR_RED}${EMOJI_FAILURE}${EMOJI_FAILURE}${EMOJI_FAILURE}${COLOR_RESET}"
  echo -e "${COLOR_RED}参数 standalone、cluster、node 三者互斥${COLOR_RESET}"
  echo -e "${COLOR_RED}请阅读文档，查看配置: ${COLOR_GREEN}$DOCS_CONFIG_LINK${COLOR_RESET}"
  echo ''
  echo ''
  echo ''
  exit 1
fi

if [[ $standalone == true ]]; then
  # 单机模式

  if ! [[ $kubernetes_init_node_name ]]; then
    kubernetes_init_node_name=k8s-1
  fi
  _node
  _kubernetes_init
  _helm_install
  _calico_install
  _kubernetes_taint
  _ingress_nginx_install
  _ingress_nginx_host_network
  _metrics_server_install
  _enable_shell_autocompletion
  _print_join_command
  _kubernetes_init_congrats
elif [[ $cluster == true ]]; then
  # 集群模式

  if ! [[ $kubernetes_init_node_name ]]; then
    kubernetes_init_node_name=k8s-1
  fi
  _node
  _kubernetes_init
  _helm_install
  _calico_install
  _ingress_nginx_install
  _ingress_nginx_host_network
  _metrics_server_install
  _enable_shell_autocompletion
  _print_join_command
  _kubernetes_init_congrats
elif [[ $node == true ]]; then
  # 工作节点准备

  _node

  echo
  echo
  echo
  echo -e "${COLOR_BLUE}${EMOJI_CONGRATS}${EMOJI_CONGRATS}${EMOJI_CONGRATS}${COLOR_RESET}"
  echo -e "${COLOR_BLUE}Kubernetes 节点已配置完成${COLOR_RESET}"
  echo
  echo -e "${COLOR_BLUE}请选择下列方式之一：${COLOR_RESET}"
  echo
  echo -e "${COLOR_BLUE}1. 初始化为控制节点（控制平面）${COLOR_RESET}"
  echo -e "${COLOR_BLUE}2. 作为工作节点加入集群${COLOR_RESET}"
  echo
  echo
  echo

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

  if [[ $helm_install == true ]]; then
    _helm_install
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

  if [[ $kubernetes_init_congrats == true ]]; then
    _kubernetes_init_congrats
  fi

  if [[ $helm_install_kubernetes_dashboard == true ]]; then
    _helm_install_kubernetes_dashboard
  fi

  if [[ $etcd_binary_install == true ]]; then
    _etcd_binary_install
  fi

  if [[ $etcd_binary_join == true ]]; then
    _etcd_binary_join
  fi

fi
