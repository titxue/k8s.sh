# 参数配置 {id=parameter-config}

[[toc]]

## 参数介绍 {id=intro}

1. `参数的顺序` 不影响结果，脚本内置固定顺序
2. 可直接使用参数名，也可使用 `-`、`--` 开头
    - 如：`kubernetes-version=v1.31.1`、`-kubernetes-version=v1.31.1`、`--kubernetes-version=v1.31.1` 都是合法值
3. 参数名中单词中间使用 `-` 分隔，脚本中单词中间使用 `_` 分隔
    - 如：`Kubernetes` 版本，参数中使用 `kubernetes-version=v1.31.1`，脚本中使用 `kubernetes_version=v1.31.1`

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

### standalone {id=standalone}

- 类型：`Boolean`
- 说明：`单机模式`，开箱即用，无需任何配置
- 相关：此参数会创建一个 <strong><font color="red">已删除污点</font></strong> 的 k8s 单机模式，
  并且安装 `calico`、`Ingress Nginx` 等， `Ingress Nginx` 使用宿主机网络（`80`/`443`）
- 参数组合：
    1. 可与其他参数组合使用，如：自定义 `Kubernetes` 版本 `kubernetes-version=v1.30.3`
    2. 如果未指定 `kubernetes-init-node-name` `初始化节点名称`，将使用默认值 `k8s-1`
    3. 存在默认行为（无法取消）：
        - <strong><font color="red">删除污点</font></strong>
        - `控制节点`（`控制平面`） 初始化
        - `calico` 网络插件 安装配置
        - `Ingress Nginx` 负载均衡器 安装配置
        - `Metrics Server` 安装配置
        - 等等

### cluster {id=cluster}

::: warning 警告

- 在 `集群模式` 中，`工作节点` 加入集群之前，集群不可使用

:::

- 类型：`Boolean`
- 说明：`集群模式`
- 相关：此参数会创建一个 <strong><font color="red">未删除污点</font></strong> 的 k8s 单机模式，
  并且安装 `calico`、`Ingress Nginx` 等， `Ingress Nginx` 使用宿主机网络（`80`/`443`）
- 类似参数：`standalone` `单机模式`，唯一不同的是 <strong><font color="red">未删除污点</font></strong>
- 参数组合：
    1. 可与其他参数组合使用，如：自定义 `Kubernetes` 版本 `kubernetes-version=v1.30.3`
    2. 如果未指定 `kubernetes-init-node-name` `初始化节点名称`，将使用默认值 `k8s-1`
    3. 存在默认行为（无法取消）：
        - `控制节点`（`控制平面`） 初始化
        - `calico` 网络插件 安装配置
        - `Ingress Nginx` 负载均衡器 安装配置
        - `Metrics Server` 安装配置
        - 等等

### node {id=node}

- 类型：`Boolean`
- 说明：工作节点加入集群前的准备工作
- 相关：此参数会与 `控制节点`（`控制平面`）
  安装、配置相同的内容，不同的在于 `不进行节点初始化`、`不进行初始化以后的插件安装配置`，
  用于在 `工作节点` 中安装和配置 `Kubernetes` 相关内容，然后此节点即可加入集群
- 参数组合：
    1. 可与其他参数组合使用，如：自定义 `Kubernetes` 版本 `kubernetes-version=v1.30.3`
    2. <strong><font color="red">不可组合的参数</font></strong>（无效组合：与 `控制节点`（`控制平面`）有关的配置组合时无效）：
        - `控制节点`（`控制平面`） 初始化
        - `calico` 网络插件安装配置
        - `Ingress Nginx` 安装配置
        - 等等

### config {id=config}

::: warning 警告

- 如果配置了 `配置文件`，先读取 `配置文件`，再读取 `参数`，`参数` 可覆盖 `配置文件`
- 如果要将参数转为配置文件的写法，需要将参数中的 `-` 替换为 `_` 并写入到指定的 `配置文件` 中

:::

- 类型：`String`
- 默认值：无
- 说明：配置文件模式，指定配置文件位置，配置文件内容必须是合法的键值对
- 相关：用于高度自定义时配置参数
- 示例：
    1. `String` 类型：指定 `Kubernetes` 版本的参数 `kubernetes-version=v1.30.3` 转为
       配置文件的键值对是 `kubernetes_version=v1.30.3`
    2. `Boolean` 类型：启用 `Ingress Nginx` 安装的参数 `ingress-nginx-install` 转为
       配置文件的键值对是 `ingress-nginx-install=true`

### dpkg-lock-timeout {id=dpkg-lock-timeout}

- 类型：`Number`
- 默认值：`120`
- 单位：`秒`
- 说明：apt 锁等待时间
- 用途：`apt` 安装软件时，锁等待时间，防止锁异常退出程序
- 相关：仅在包管理器是 `apt` 时有效

### swap-off {id=swap-off}

- 类型：`Boolean`
- 说明：关闭交换空间
- 相关：启用交换空间时，`Kubernetes` 默认无法进行初始化。交换空间会影响 `Kubernetes` 的调度计算

### curl {id=curl}

- 类型：`Boolean`
- 说明：启用安装 curl
- 用途：`下载脚本`、`下载 gpg 签名`、`下载 Kubernetes manifests 文件`
- 相关：某些操作系统无 `curl`

### ca-certificates {id=ca-certificates}

- 类型：`Boolean`
- 说明：启用安装 ca-certificates

### firewalld-stop {id=firewalld-stop}

- 类型：`Boolean`
- 说明：关闭防火墙
- 范围：关闭 `firewalld` 软件，关闭 `firewalld` 开机自启，仅在包管理工具为 `yum` 时生效
- 用途：局域网通信，Kubernetes 默认需要使用 `6443`、`30000-32767`、`10250`、`10259`、`10257`

### selinux-disabled {id=selinux-disabled}

- 类型：`Boolean`
- 说明：关闭 `selinux`
- 范围：关闭 `selinux` 软件，仅在包管理工具为 `yum` 时生效

### bash-completion {id=bash-completion}

- 类型：`Boolean`
- 说明：启用安装 `bash-completion`
- 用途：`Shell 自动补全功能` 所需软件

### docker-repo {id=docker-repo}

::: danger 危险

- 配置 docker 仓库时，会删除 `旧版 Docker`
    1. `旧版 Docker`: `docker.io`
    2. `新版 Docker`: `docker-ce`

:::

- 类型：`Boolean`
- 说明：配置 Docker 仓库
- 用途：安装 `containerd` 或 `docker` 所需仓库

### docker-repo-type {id=docker-repo-type}

- 类型：`String`
- 说明：选择配置 Docker 仓库类型
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

### container-selinux-rpm {id=container-selinux-rpm}

- 类型：`String`
- 默认值：
  `https://mirrors.aliyun.com/centos-altarch/7.9.2009/extras/i386/Packages/container-selinux-2.107-3.el7.noarch.rpm`
- 说明：自定义 `container-selinux` 安装包，仅在少数系统中使用，如：`OpenEuler` `20.03`
- 相关：在 `OpenEuler` `20.03` 中安装 `containerd`、`docker` 时会依赖 `container-selinux`，而 `OpenEuler` `20.03`
  中的 `container-selinux` 版本过低，无法使用，所以采用了自定义。除 `OpenEuler` `20.03` 以外的系统，无需关注

### docker-install {id=docker-install}

- 类型：`Boolean`
- 说明：启动安装 `Docker`
- 相关：安装 `Docker` 时，会自动安装 `containerd`

### containerd-install {id=containerd-install}

- 类型：`Boolean`
- 说明：启用安装 `containerd`
- 用途：`Kubernetes` `1.24` 及之后的 `容器运行时`
- 相关：安装 `Docker` 时，会自动安装 `containerd`

### pause-image {id=pause-image}

- 类型：`String`
- 说明：配置 pause 镜像地址
- 用途：`containerd` 配置时使用的镜像
- 默认值：`registry.aliyuncs.com/google_containers/pause`
- 可选值：
    1. `registry.aliyuncs.com/google_containers/pause`
    2. `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/pause`
    3. `registry.k8s.io/pause`
    4. 自定义镜像

### containerd-config {id=containerd-config}

- 类型：`Boolean`
- 说明：配置 `containerd`
- 用途：配置 `containerd`，用于支持 `Kubernetes` `容器运行时`
- 备份：每次配置时，都会将 `containerd` 原配置文件备份一次，路径 `/etc/containerd/`，文件名增加当前时间作为后缀名

### kubernetes-repo {id=kubernetes-repo}

- 类型：`Boolean`
- 说明：配置 Kubernetes 仓库
- 用途：安装 `Kubernetes` 所需仓库

### kubernetes-repo-type {id=kubernetes-repo-type}

- 类型：`String`
- 说明：选择下载 `Kubernetes` 软件的仓库
- 用途：用于下载 `Kubernetes` 软件
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

### kubernetes-install {id=kubernetes-install}

- 类型：`Boolean`
- 说明：安装 `Kubernetes`
- 用途：安装 `Kubernetes` 所需软件

### kubernetes-version {id=kubernetes-version}

- 类型：`String`
- 说明：安装 `Kubernetes` 版本
- 用途：自定义安装 `Kubernetes` 的版本
- 默认值：`v1.31.4`
- 可选值：`v1.24.0` 到 `v1.32.0`

### kubernetes-version-suffix {id=kubernetes-version-suffix}

- 类型：`String`
- 说明：安装 `Kubernetes` 版本后缀
- 用途：自定义安装 `Kubernetes` 的版本的后缀，`yum` 包管理器 `无需关注`，`apt` 包管理器 `一般无需关注`
- 默认值：`1.1`
- 相关：
    1. 由于 `apt` 包管理器的机制以及构建等问题，`Kubernetes` 可能不是 `1.1`，例如：在 apt
       包管理器中安装 `Kubernetes` `v1.29.4`，需要使用 `2.1`
        - 此问题出现情况极小，详情见 https://mirrors.aliyun.com/kubernetes-new/core/stable/ 中 deb 安装包的名称
    2. yum 包管理器无需关心

### kubernetes-images {id=kubernetes-images}

- 类型：`String`
- 说明：`Kubernetes` 镜像地址
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

### kubernetes-images-pull {id=kubernetes-images-pull}

- 类型：`Boolean`
- 说明：拉取 Kubernetes 镜像
- 用途：用于`控制节点`（`控制平面`）初始化 `Kubernetes` 前拉取镜像、用于工作节点加入 `Kubernetes` 集群前拉取镜像
- 相关：在 `Kubernetes` 初始化时、在工作节点加入 `Kubernetes` 集群时会自动拉取，此参数仅用于提前拉取 `Kubernetes`
  镜像，加速初始化、加入集群的速度

### kubernetes-config {id=kubernetes-config}

- 类型：`Boolean`
- 说明：配置 `Kubernetes`
- 用途：在初始化 `Kubernetes`、加入 `Kubernetes` 集群 之前对软件进行相关的配置、安装必要的软件，防止出现警告和错误
- 相关：`控制节点`（`控制平面`）初始化前、工作节点加入集群前，均需要配置 `Kubernetes`

### kubernetes-init {id=kubernetes-init}

- 类型：`Boolean`
- 说明：初始化 `Kubernetes`
- 用途：初始化 `Kubernetes`
- 相关：工作节点不需要此参数。如果要重置 `Kubernetes` 清空数据及配置，请执行 `kubeadm reset`，并在提示中输入 `y`，
  重置完成需要删除 `/etc/cni/net.d` 文件夹、`$HOME/.kube/config` 文件

### kubernetes-init-node-name {id=kubernetes-init-node-name}

- 类型：`String`
- 说明：初始化节点名称
- 用途：用于`控制节点`（`控制平面`）初始化时自定义当前节点的名称
- 相关：如果未定义，将使用宿主机的名称作为节点名称。整个集群唯一。

### kubernetes-init-congrats {id=kubernetes-init-congrats}

- 类型：`Boolean`
- 说明：初始化完成后的提示
- 用途：用于提示 `刷新环境变量` 或 `SSH 重新连接` 后，才能正常控制 `Kubernetes`

### helm-install

- 类型：`Boolean`
- 说明：是否安装 `helm`
- 安装路径：`/usr/local/bin/helm`

### helm-url

- 类型：`String`
- 说明：安装 `helm` 时的下载地址
- 相关：优先级高于 `helm-version`、`helm-repo-type`

### helm-version

- 类型：`String`
- 说明：安装 `helm` 时下载的版本
- 默认值：`v3.16.3`

### helm-repo-type

- 类型：`String`
- 说明：安装 `helm` 时下载的仓库
- 默认值：`huawei`
- 可选值：
    1. `huawei`：从 https://mirrors.huaweicloud.com/helm 下载
    2. `helm`：从 https://get.helm.sh 下载

### control-plane-endpoint {id=control-plane-endpoint}

::: warning 警告

- `kubeadm` `不支持` 将 `没有` `--control-plane-endpoint` 参数的单个 `控制平面` 集群转换为 `高可用性集群`。
- 如果要在现有集群中将加入的节点设置为 `控制节点`（`控制平面`），必须在首次初始化集群时配置此参数
    1. 如果要在现有集群中将加入的节点设置为 `工作节点`（默认行为），则无需配置此选项
- 此配置属于`高可用`方案中的配置，`--control-plane-endpoint` 应该使用 `VIP`（`虚拟 IP`，
  `VIP` 所在的机器故障、`Kubernetes` 故障时，自动转移到其他可用的 `控制节点` 上），
  如果将 `--control-plane-endpoint` 设置的是某个 `控制平面` 上的固定 IP，
  如果这台机器宕机、机器上的 `Kubernetes` 宕机，则整个集群将宕机。
  如果是 `VIP`，则不受单一 `控制节点`（`控制平面`）节点故障的影响（宕机数量要 `小于 50%`）

:::

- 类型：`String`
- 说明：初始化 `Kubernetes` 时为所有 `控制节点`（`控制平面`）设置共享端点
- 相关：
    - 一般设置为负载均衡器代理的 `控制节点`（`控制平面`）的 `6443` 端口的地址
        1. 如果非要在不是`高可用`方案中配置，或将来可能把 `单机模式`、`集群模式` 转化为 `高可用模式`，
           或将后来加入集群的节点角色设置为 `控制节点`（`控制平面`），
           可暂时设置为 初始化 `Kubernetes` 集群的地址，
           如：`192.168.1.12:6443`，其中 `192.168.1.12` 是 初始化 `Kubernetes` 集群的 IP

### service-cidr {id=service-cidr}

- 类型：`String`
- 默认值：`10.96.0.0/12`
- 说明：自定义 `Kubernetes` `Service` `CIDR`

### pod-network-cidr {id=pod-network-cidr}

- 类型：`String`
- 说明：自定义 `Kubernetes` `Pod` `CIDR`

### print-join-command {id=print-join-command}

::: warning 警告

- 只能在 `控制节点`（`控制平面`）中使用，默认情况下 `工作节点` 不可使用
- `控制节点`（`控制平面`）需要能正常控制 `Kubernetes`

:::

- 类型：`Boolean`
- 说明：在 `控制节点`（`控制平面`）打印 `工作节点` 加入集群的命令
- 用途：工作节点环境准备完成后，在 `控制节点`（`控制平面`）打印 `工作节点` 加入集群的命令，复制到工作节点运行即可

### interface-name {id=interface-name}

- 类型：`String`
- 说明：自定义网卡名称
- 默认值：无，会联网访问 `阿里云 DNS` `223.5.5.5` 自动检测上网网卡
- 用途：在 `calico` 安装配置时使用

### calico-install {id=calico-install}

- 类型：`Boolean`
- 说明：是否安装 `calico`

### calico-url {id=calico-url}

- 类型：`String`
- 说明：`calico` 安装（初始化）时，使用的 `manifests` 文件 `URL`，支持本地文件
- 默认值：空
- 相关：优先级高于 `calico-mirror`、`calico-version`

### calico-mirror {id=calico-mirror}

- 类型：`String`
- 说明：`calico` 安装（初始化）时，拼接生成 `calico-url`，
  拼接规则：`calico_url=$calico_mirror/$calico_version/manifests/calico.yaml`
- 默认值：https://k8s-sh.xuxiaowei.com.cn/mirrors/projectcalico/calico
- 可选值：
    1. https://k8s-sh.xuxiaowei.com.cn/mirrors/projectcalico/calico
    2. https://gitlab.xuxiaowei.com.cn/mirrors/github.com/projectcalico/calico/-/raw
    3. https://raw.githubusercontent.com/projectcalico/calico/refs/tags
- 相关：优先级低于 `calico-url`

### calico-node-image {id=calico-node-image}

- 类型：`String`
- 说明：`calico` 需要使用的镜像 `docker.io/calico/node` 下载地址
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-node`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-node`
    - `docker.io/calico/node`

### calico-cni-image {id=calico-cni-image}

- 类型：`String`
- 说明：`calico` 需要使用的镜像 `docker.io/calico/cni` 下载地址
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-cni`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-cni`
    - `docker.io/calico/cni`

### calico-kube-controllers-image {id=calico-kube-controllers-image}

- 类型：`String`
- 说明：`calico` 需要使用的镜像 `docker.io/calico/kube-controllers` 下载地址
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-kube-controllers`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/calico-kube-controllers`
    - `docker.io/calico/kube-controllers`

### calico-version {id=calico-version}

- 类型：`String`
- 说明：`calico` 安装（初始化）时，拼接生成 `calico-url`，
  拼接规则：`calico_url=$calico_mirror/$calico_version/manifests/calico.yaml`
- 默认值：`v3.29.0`
- 可选值：
    - 查看 https://gitlab.xuxiaowei.com.cn/mirrors/github.com/projectcalico/calico/-/tags 中的标签
    - 查看 https://github.com/projectcalico/calico/tags 中的标签
- 相关：优先级低于 `calico-url`

### calico-init {id=calico-init}

- 类型：`Boolean`
- 说明：网络插件 `calico` 初始化
- 用途：安装 `calico`，初始化 `Kubernetes` 集群中的网络，如果网络未初始化，`Kubernetes` 则不可使用
- 相关：网络插件有多种，此处使用 `calico` 为例

### kubernetes-taint {id=kubernetes-taint}

- 类型：`Boolean`
- 说明：`Kubernetes` `控制节点`（`控制平面`）去污
- 用途：此操作会将所有控制节点去污，即：将 `控制节点`（`控制平面`）作为工作节点使用
- 相关：默认情况下，`控制节点`（`控制平面`）无法部署`常规容器`，去污后可随意部署容器

### enable-shell-autocompletion {id=enable-shell-autocompletion}

- 类型：`Boolean`
- 说明：启用 shell 自动补全功能
- 用途：使用 `kubectl` 命令时，按 `Tab` 键可快速补充命令

### ingress-nginx-install {id=ingress-nginx-install}

- 类型：`Boolean`
- 说明：安装 `Ingress Nginx`
- 用途：用于在 `Kubernetes` 中使用 `Nginx` 代理 `Service`

### ingress-nginx-version {id=ingress-nginx-version}

- 类型：`String`
- 说明：`Ingress Nginx` 安装时，拼接生成 `ingress-nginx-url`，
  拼接规则：
  `ingress_nginx_url=$ingress_nginx_mirror/controller-$ingress_nginx_version/deploy/static/provider/cloud/deploy.yaml`
- 默认值：`v1.11.3`
- 可选值：
    - 查看 https://gitlab.xuxiaowei.com.cn/mirrors/github.com/kubernetes/ingress-nginx/-/tags?search=controller
      中名称包含 `controller` 的标签
    - 查看 https://github.com/kubernetes/ingress-nginx/tags 中名称包含 `controller` 的标签
- 相关：优先级低于 `ingress-nginx-url`

### ingress-nginx-url {id=ingress-nginx-url}

- 类型：`String`
- 说明：`Ingress Nginx` 安装时，使用的 `manifests` 文件 `URL`，支持本地文件
- 默认值：空
- 相关：优先级高于 `ingress-nginx-mirror`、`ingress-nginx-version`

### ingress-nginx-mirror {id=ingress-nginx-mirror}

- 类型：`String`
- 说明：`Ingress Nginx` 安装时，拼接生成 `ingress-nginx-url`，
  拼接规则：
  `ingress_nginx_url=$ingress_nginx_mirror/controller-$ingress_nginx_version/deploy/static/provider/cloud/deploy.yaml`
- 默认值：https://gitlab.xuxiaowei.com.cn/mirrors/github.com/kubernetes/ingress-nginx/-/raw
- 可选值：
    1. https://gitlab.xuxiaowei.com.cn/mirrors/github.com/kubernetes/ingress-nginx/-/raw
    2. https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags
- 相关：优先级低于 `ingress-nginx-url`

### ingress-nginx-controller-image {id=ingress-nginx-controller-image}

- 类型：`String`
- 说明：`Ingress Nginx` 需要使用的镜像 `registry.k8s.io/ingress-nginx/controller` 下载地址
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-controller`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-controller`
    - `registry.k8s.io/ingress-nginx/controller`
    - 自定义

### ingress-nginx-kube-webhook-certgen-image {id=ingress-nginx-kube-webhook-certgen-image}

- 类型：`String`
- 说明：`Ingress Nginx` 需要使用的镜像 `registry.k8s.io/ingress-nginx/kube-webhook-certgen` 下载地址
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen`
    - `registry.k8s.io/ingress-nginx/kube-webhook-certgen`

### ingress-nginx-host-network {id=ingress-nginx-host-network}

- 类型：`Boolean`
- 说明：配置 `Ingress Nginx` 使用宿主机网络
- 用途：`Ingress Nginx` 使用宿主机的 `80`、`443` 端口
- 相关：请确保 `Kubernetes` 工作节点的宿主机 `80`、`443` 端口 没有被其他应用占用

### ingress-nginx-allow-snippet-annotations {id=ingress-nginx-allow-snippet-annotations}

::: danger 危险

- `Ingress Nginx` 正常情况下只代理到 `Service`，无需手写代理，不用增加此配置
- 如果要手写代理，需要增加此配置，此时要严格管理 `Kubernetes` 的 `Ingress` 权限，避免敏感信息泄露，
  参见：CVE-2021-25742：https://github.com/kubernetes/kubernetes/issues/126811

:::

- 类型：`Boolean`
- 说明：允许 `Ingress Nginx` 使用 `代码片段`
- 用途：允许在 `Ingress Nginx` 中使用自定义代理，如：
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        nginx.ingress.kubernetes.io/server-snippet: |
          location ~ /(.*) {
            rewrite ^/(.*) /$1 break;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header X-real-ip $remote_addr;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_pass http://10.97.34.18:8080;
            proxy_connect_timeout 60s;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
          }
    
    ...
    
    ```

### metrics-server-install {id=metrics-server-install}

- 类型：`Boolean`
- 说明：安装 `Metrics Server`
- 用途：支持 `Kubernetes` 运行 `kubectl top node`、`kubectl top pod` 命令

### metrics-server-url {id=metrics-server-url}

- 类型：`String`
- 说明：`Metrics Server` 安装时，使用的 `manifests` 文件 `URL`，支持本地文件
- 默认值：空
- 相关：优先级高于 `metrics-server-mirror`、`metrics-server-version`

### metrics-server-version {id=metrics-server-version}

- 类型：`String`
- 说明：`Metrics Server` 安装时，拼接生成 `metrics-server-url`，
  拼接规则：`metrics_server_url=$metrics_server_mirror/$metrics_server_version/components.yaml`
- 默认值：`v0.7.2`

### metrics-server-mirror {id=metrics-server-mirror}

- 类型：`String`
- 说明：`Metrics Server` 安装时，拼接生成 `metrics-server-url`，
  拼接规则：`metrics_server_url=$metrics_server_mirror/$metrics_server_version/components.yaml`
- 默认值：https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes-sigs/metrics-server

### metrics-server-image {id=metrics-server-image}

- 类型：`String`
- 说明：`Metrics Server` 需要使用的镜像 `registry.k8s.io/metrics-server/metrics-server` 下载地址
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/metrics-server`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/metrics-server`
    - `registry.k8s.io/metrics-server/metrics-server`

### metrics-server-secure-tls {id=metrics-server-secure-tls}

- 类型：`Boolean`
- 说明：使用 `安全` 的 `Kubernetes` 的 `apiserver` 接口的 `TLS` 证书，`强烈不推荐配置此选项`，
  这里涉及 `Kubernetes` 需要使用 `权威机构` 颁发的证书，
  并且 `Metrics Server` 容器内还要包含、信任该证书的证书链（根证书）
- 相关：`Metrics Server` 官方默认配置情况下需要使用 `安全` 的 `TLS` 证书，
  这将导致 `Metrics Server` 无法正常连接到 `Kubernetes` 的 `apiserver`，所以安装时存在默认行为：
  忽略 `TLS` 证书验证 `--kubelet-insecure-tls`

### helm-install-kubernetes-dashboard {id=helm-install-kubernetes-dashboard}

- 类型：`Boolean`
- 说明：是否启用 `helm` 安装 `Kubernetes Dashboard`
- 默认值：`false`

### kubernetes-dashboard-chart

- 类型：`String`
- 说明：`Kubernetes Dashboard` `chart` 仓库地址
- 默认值：`http://k8s-sh.xuxiaowei.com.cn/charts/kubernetes/dashboard`
- 可选值：
    - http://k8s-sh.xuxiaowei.com.cn/charts/kubernetes/dashboard
    - https://kubernetes.github.io/dashboard

### kubernetes-dashboard-version

- 类型：`String`
- 说明：`Kubernetes Dashboard` `chart` 版本
- 默认值：`7.10.0`

### kubernetes-dashboard-auth-image

- 类型：`String`
- 说明：`Kubernetes Dashboard` 所需镜像
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-auth`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-auth`
    - `docker.io/kubernetesui/dashboard-auth`

### kubernetes-dashboard-api-image

- 类型：`String`
- 说明：`Kubernetes Dashboard` 所需镜像
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-api`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-api`
    - `docker.io/kubernetesui/dashboard-api`

### kubernetes-dashboard-web-image

- 类型：`String`
- 说明：`Kubernetes Dashboard` 所需镜像
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-web`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-web`
    - `docker.io/kubernetesui/dashboard-web`

### kubernetes-dashboard-metrics-scraper-image

- 类型：`String`
- 说明：`Kubernetes Dashboard` 所需镜像
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-metrics-scraper`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-metrics-scraper`
    - `docker.io/kubernetesui/dashboard-metrics-scraper`

### kubernetes-dashboard-kong-image

- 类型：`String`
- 说明：`Kubernetes Dashboard` 所需镜像
- 默认值：`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kong`
- 可选值：
    - `registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kong`
    - `docker.io/library/kong`

### kubernetes-dashboard-ingress-enabled

- 类型：`String`
- 说明：`Kubernetes Dashboard` 是否启用 `ingress`
- 默认值：`true`
- 可选值：
    - `true`
    - `false`

### kubernetes-dashboard-ingress-host

- 类型：`String`
- 说明：`Kubernetes Dashboard` `ingress` 所需域名
- 默认值：`kubernetes.dashboard.xuxiaowei.com.cn`

### etcd-binary-install

::: warning 警告

- 仅在 `首台` `初始化集群` 的节点中使用
- `后续节点` `加入集群` 时，请使用 `etcd-binary-join` 参数
- 此配置用于独立安装 `二进制` `etcd`
- 支持 `单节点`
- `多节点` 安装时，请在所有节点完成安装后，执行
  `etcdctl --cacert=/etc/etcd/pki/ca.crt --cert=/etc/etcd/pki/etcd_client.crt --key=/etc/etcd/pki/etcd_client.key --endpoints=$ETCD_ENDPOINTS endpoint health`
  进行测试，其中 `ETCD_ENDPOINTS` 示例 `https://172.25.25.53:2379,https://172.25.25.54:2379,https://172.25.25.55:2379`，
  多个节点使用 `,` 分隔
- 单节点会自动测试

:::

- 类型：`Boolean`
- 说明：启用 `etcd` `二进制` 初始化集群

### etcd-ips

::: warning 警告

- 仅在 `首台` `初始化集群` 的节点中使用
- `后续节点` `加入集群` 时，无需配置（脚本会根据已有的配置，分析并自动配置后续节点的配置）
- `后续节点` 的 IP 必须在此配置中

:::

- 说明：`etcd` `二进制` `初始化集群` 时，集群内各节点的 `IP` 及 `节点名称`
- 默认值：空
- 示例：
    - `etcd-ips=172.25.25.53 etcd-ips=172.25.25.54 etcd-ips=172.25.25.55`
        1. etcd 集群中存在三个节点，IP 分别是：`172.25.25.53`、`172.25.25.54`、`172.25.25.55`
        2. etcd 每个节点的名称分别是：`etcd-1`、`etcd-2`、`etcd-3`
            - 脚本会根据读取到的 `etcd-ips` 的顺序，分配 etcd 节点名称，名称前缀 `etcd-`，后缀为读取到的顺序，从 `1` 开始
    - `etcd-ips=172.25.25.53@etcd-node-1 etcd-ips=172.25.25.54@etcd-node-2 etcd-ips=172.25.25.55@etcd-node-3`
        1. etcd 集群中存在三个节点，IP 分别是：`172.25.25.53`、`172.25.25.54`、`172.25.25.55`
        2. etcd 每个节点的名称分别是：`etcd-node-1`、`etcd-node-2`、`etcd-node-3`
        3. 如果要设置节点名称，请使用 `@` 分隔
        4. 如果要设置节点名称，请将所有 IP 设置节点名称
           （只允许 `全部忽略名称` 或 `全部设置名称` 两种情况，如果出现部分 IP 设置了名称，程序将终止运行）

### etcd-client-port-2379

- 说明：自定义 `etcd` `client` 端口
- 默认值：`2379`

### etcd-peer-port-2380

- 说明：自定义 `etcd` `peer` 端口
- 默认值：`2380`

### etcd-url

- 类型：`String`
- 说明：`etcd` `二进制` 安装时，下载二进制压缩包的地址，仅在 `首台` `初始化集群` 的节点中使用
- 默认值：空
- 相关：优先级高于 `etcd-mirror`、`etcd-version`

### etcd-mirror

- 类型：`String`
- 说明：`etcd` `二进制` 安装时，用于拼接生成 `etcd-url`，仅在 `首台` `初始化集群` 的节点中使用
- 默认值：https://mirrors.huaweicloud.com/etcd
- 可选值：
    1. https://mirrors.huaweicloud.com/etcd
    2. https://storage.googleapis.com/etcd
    3. https://github.com/etcd-io/etcd/releases/download

### etcd-version

- 类型：`String`
- 说明：`etcd` `二进制` 安装时，下载 `etcd` 的版本，用于拼接 `etcd-url`，
  拼接规则：`etcd_url=$etcd_mirror/$etcd_version/etcd-$etcd_version-linux-amd64.tar.gz`
  仅在 `首台` `初始化集群` 的节点中使用
- 默认值：v3.5.17

### etcd-current-ip

- 类型：`String`
- 说明：`etcd` `初始化集群`、`加入集群` 时，当前机器的 IP
- 默认值：使用 `$(hostname -I | awk '{print $1}')` 自动获取
- 注意：
    1. 此配置可为空，为空时使用 `$(hostname -I | awk '{print $1}')` 获取
    2. 如果当前执行命令的宿主机存在多个网卡，请配置此选项，否则自动获取的 IP 可能不满足要求
    3. 如果是安装 `etcd` 集群，此配置必须在 `etcd-ips` 列表中，否则将终止安装

### etcd-binary-join

- 类型：`Boolean`
- 说明：启用 `etcd` `后续节点` `加入集群`

### etcd-join-ip

- 类型：`String`

### etcd-join-port

- 类型：`Number`
- 说明：`etcd` `后续节点` `加入集群` 时，首台初始化的 `etcd` 节点 `SSH` `端口`
- 默认值：`22`

### etcd_join_password

::: warning 警告

- `etcd_join_password` 属于配置文件中的配置，不属于 `参数`，仅能在 `config` 参数指定的 `配置文件` 中使用
- 如果要使用，请在配置文件中使用键值对表示
- 解释：在参数中使用，存在密码泄露风险

:::

- 类型：`String`
- 说明：`etcd` `后续节点` `加入集群` 时，首台初始化的 `etcd` 节点 `SSH` `密码`
- 默认值：空，为空时需要在提示中手动设置密码
