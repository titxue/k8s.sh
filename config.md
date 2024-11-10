# 参数配置 {id=config}

[[toc]]

## 参数介绍 {id=intro}

1. `参数的顺序` 不影响结果，脚本内置固定顺序
2. 可直接使用参数名，也可使用 `-`、`--` 开头

### `Boolean 类型` 的参数 {id=intro-boolean}

1. 传递参数时为 `true`，表示启动
2. 不传递参数时为 `false`，表示不启动

### `String 类型` 的参数 {id=intro-string}

1. 传递参数时，将覆盖 `默认值`
2. 不传递参数时，将使用 `默认值`

### `Number 类型` 的参数 {id=intro-number}

1. 传递参数时，将覆盖 `默认值`
2. 不传递参数时，将使用 `默认值`

## 参数 {id=arguments}

### apt 锁等待时间 dpkg-lock-timeout {id=dpkg-lock-timeout}

- 类型：`Number`
- 默认值：`120`
- 单位：`秒`
- 用途：`apt` 安装软件时，锁等待时间，防止锁异常
- 相关：仅在包管理器是 `apt` 时有效

### 关闭交换空间 swap-off {id=swap-off}

- 类型：`Boolean`
- 相关：启用交换空间时，`Kubernetes` 默认无法进行初始化。交换空间会影响 `Kubernetes` 的调度计算

### 启用安装 curl {id=curl}

- 类型：`Boolean`
- 用途：`下载脚本`、`下载 gpg 签名`、`下载 Kubernetes manifests 文件`

### 启用安装 ca-certificates {id=ca-certificates}

- 类型：`Boolean`

### 关闭防火墙 firewalld-stop {id=firewalld-stop}

- 类型：`Boolean`
- 范围：关闭 `firewalld` 软件，关闭 `firewalld` 开机自启，仅在包管理工具为 `yum` 时生效
- 用途：局域网通信，Kubernetes 默认需要使用 `6443`、`30000-32767`、`10250`、`10259`、`10257`

### 关闭 selinux-disabled {id=selinux-disabled}

- 类型：`Boolean`
- 范围：关闭 `selinux` 软件，仅在包管理工具为 `yum` 时生效

### 启用安装 bash-completion {id=bash-completion}

- 类型：`Boolean`
- 用途：`Shell 自动补全功能` 所需软件

### 配置 Docker 仓库 docker-repo {id=docker-repo}

- 类型：`Boolean`
- 用途：安装 `containerd` 或 `docker` 所需仓库

### 配置 Docker 仓库类型 docker-repo-type {id=docker-repo-type}

- 类型：`String`
- 用途：选择下载 `containerd` 或 `Docker` 软件的仓库
- 默认值：`aliyun`
- 可选值：
    1. `aliyun`（`阿里云`）
        - 实际下载地址：https://mirrors.aliyun.com/docker-ce/linux
    2. `tencent`（`腾讯`）
        - 实际下载地址：https://mirrors.cloud.tencent.com/docker-ce/linux
    3. `kubernetes`（`官方`）
        - https://download.docker.com/linux
    4. 自定义仓库
        - 需要与 https://mirrors.aliyun.com/docker-ce/linux
          或 https://mirrors.cloud.tencent.com/docker-ce/linux 结构相同
        - 自定义仓库时，地址结尾不要有 `/`

### 启用安装 docker-install {id=docker-install}

- 类型：`Boolean`
- 用途：启动安装 `Docker`
- 相关：安装 `Docker` 时，会自动安装 `containerd`

### 启用安装 containerd-install {id=containerd-install}

- 类型：`Boolean`
- 用途：启用安装 `containerd`，`Kubernetes` `1.24` 及之后的 `容器运行时`
- 相关：安装 `Docker` 时，会自动安装 `containerd`

### 配置 pause 镜像地址 pause-image {id=pause-image}

- 类型：`String`
- 用途：`containerd` 配置时使用的镜像
- 默认值：`registry.aliyuncs.com/google_containers/pause`
- 可选值：
    1. `registry.aliyuncs.com/google_containers/pause`
    2. `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/pause`
    3. `registry.k8s.io/pause`
    4. 自定义镜像

### 配置 containerd-config {id=containerd-config}

- 类型：`Boolean`
- 用途：配置 `containerd`，用于支持 `Kubernetes` `容器运行时`
- 备份：每次配置时，都会将 `containerd` 原配置文件备份一次，路径 `/etc/containerd/`，文件名增加当前时间作为后缀名

### 配置 Kubernetes 仓库 kubernetes-repo {id=kubernetes-repo}

- 类型：`Boolean`
- 用途：安装 `Kubernetes` 所需仓库

### Kubernetes 仓库类型 kubernetes-repo-type {id=kubernetes-repo-type}

- 类型：`String`
- 用途：选择下载 `Kubernetes` 软件的仓库
- 默认值：`aliyun`
- 可选值：
    1. `aliyun`（`阿里云`）
        - 实际下载地址：https://mirrors.aliyun.com/kubernetes-new/core/stable
    2. `tsinghua`（`清华大学`）
        - 实际下载地址：https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core%3A/stable%3A/
        - 更新速度慢，版本较新时可能不存在，建议选择阿里云
    3. `kubernetes`（`官方`）
        - https://pkgs.k8s.io/core:/stable:/
    4. 自定义仓库
        - 需要与 https://mirrors.aliyun.com/kubernetes-new/core/stable
          或 https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core%3A/stable%3A/ 结构相同
        - 自定义仓库时，地址结尾不要有 `/`

### 安装 kubernetes-install {id=kubernetes-install}

- 类型：`Boolean`
- 用途：安装 `Kubernetes` 所需软件

### 安装 Kubernetes 版本 kubernetes-version {id=kubernetes-version}

- 类型：`String`
- 用途：自定义安装 `Kubernetes` 的版本
- 默认值：`v1.31.1`
- 可选值：`v1.24.0` 到 `v1.31.2`

### 安装 Kubernetes 版本后缀 kubernetes-version-suffix {id=kubernetes-version-suffix}

- 类型：`String`
- 用途：自定义安装 `Kubernetes` 的版本的后缀，`yum` 包管理器 `无需关注`，`apt` 包管理器 `一般无需关注`
- 默认值：`1.1`
- 相关：
    1. 由于 `apt` 包管理器的机制以及构建等问题，`Kubernetes` 可能不是 `1.1`，例如：在 apt
       包管理器中安装 `Kubernetes` `v1.29.4`，需要使用 `2.1`
        - 此问题出现情况极小，详情见 https://mirrors.aliyun.com/kubernetes-new/core/stable/ 中 deb 安装包的名称
    2. yum 包管理器无需关心

### Kubernetes 镜像地址 kubernetes-images {id=kubernetes-images}

- 类型：`String`
- 用途：`Kubernetes` `控制节点`（`控制平面`）初始化所需的镜像地址
- 默认值：`aliyun`
- 可选值：
    1. `aliyun`（`阿里云`）
        - 实际下载地址：`registry.aliyuncs.com/google_containers`
        - 下载镜像列表：
            - `registry.aliyuncs.com/google_containers/coredns`
            - `registry.aliyuncs.com/google_containers/etcd`
            - `registry.aliyuncs.com/google_containers/kube-apiserver`
            - `registry.aliyuncs.com/google_containers/kube-controller-manager`
            - `registry.aliyuncs.com/google_containers/kube-proxy`
            - `registry.aliyuncs.com/google_containers/kube-scheduler`
            - `registry.aliyuncs.com/google_containers/pause`
    2. `xuxiaoweicomcn`（`作者镜像`）
        - 实际下载地址：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn`
        - 下载镜像列表：
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/coredns`
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/etcd`
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-apiserver`
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-controller-manager`
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-proxy`
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-scheduler`
            - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/pause`
    3. `kubernetes`（`官方`）
        - 实际下载地址：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn`
        - 下载镜像列表：
            - `registry.k8s.io/coredns/coredns`
            - `registry.k8s.io/etcd`
            - `registry.k8s.io/kube-apiserver`
            - `registry.k8s.io/kube-controller-manager`
            - `registry.k8s.io/kube-scheduler`
            - `registry.k8s.io/kube-proxy`
            - `registry.k8s.io/pause`

### 拉取 Kubernetes 镜像 kubernetes-images-pull {id=kubernetes-images-pull}

- 类型：`Boolean`
- 用途：用于`控制节点`（`控制平面`）初始化 `Kubernetes` 前拉取镜像、用于工作节点加入 `Kubernetes` 集群前拉取镜像
- 相关：在 `Kubernetes` 初始化时、在工作节点加入 `Kubernetes` 集群时会自动拉取，此参数仅用于提前拉取 `Kubernetes`
  镜像，加速初始化、加入集群的速度

### 配置 kubernetes-config {id=kubernetes-config}

- 类型：`Boolean`
- 用途：在初始化 `Kubernetes`、加入 `Kubernetes` 集群 之前对软件进行相关的配置、安装必要的软件，防止出现警告和错误
- 相关：`控制节点`（`控制平面`）初始化前、工作节点加入集群前，均需要配置 `Kubernetes`

### 初始化 kubernetes-init {id=kubernetes-init}

- 类型：`Boolean`
- 用途：初始化 `Kubernetes` 集群
- 相关：工作节点不需要此参数。如果要重置 `Kubernetes` 清空数据及配置，请执行 `kubeadm reset`，并在提示中输入 `y`，
  重置完成需要删除 `/etc/cni/net.d` 文件夹、`$HOME/.kube/config` 文件

### 初始化节点名称 kubernetes-init-node-name {id=kubernetes-init-node-name}

- 类型：`String`
- 用途：用于`控制节点`（`控制平面`）初始化时自定义当前节点的名称
- 相关：如果未定义，将使用宿主机的名称作为节点名称。整个集群唯一。

### 网络插件 calico 初始化 calico-init {id=calico-init}

- 类型：`Boolean`
- 用途：初始化 `Kubernetes` 集群中的网络，如果网络未初始化，`Kubernetes` 则不可使用
- 相关：网络插件有多种，此处使用 `calico` 为例

### 初始化 kubernetes-taint {id=kubernetes-taint}

- 类型：`Boolean`
- 用途：`Kubernetes` `控制节点`（`控制平面`）去污，此操作会将所有控制节点去污，即：将 `控制节点`（`控制平面`）作为工作节点使用
- 相关：默认情况下，`控制节点`（`控制平面`）无法部署常规容器，去污后可随意部署容器

### 启用 shell 自动补全功能 enable-shell-autocompletion {id=enable-shell-autocompletion}

- 类型：`Boolean`
- 用途：使用 `kubectl` 命令时，按 `Tab` 键可快速补充命令

### 安装 ingress-nginx-install {id=ingress-nginx-install}

- 类型：`Boolean`
- 用途：用于在 `Kubernetes` 中使用 `Nginx` 代理 `Service`

### 配置 Ingress Nginx 使用宿主机网络 ingress-nginx-host-network {id=ingress-nginx-host-network}

- 类型：`Boolean`
- 用途：Ingress Nginx 使用宿主机的 `80`、`443` 端口
- 相关：请确保 `Kubernetes` 工作节点的宿主机 `80`、`443` 端口 没有被其他应用占用
