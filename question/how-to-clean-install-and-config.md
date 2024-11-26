# 如何清理 安装与配置？{id=how-to-clean-install-and-config}

::: warning 警告

- 没有人有能力 `完美还原` Linux 安装配置前的状态，如果有人敢这样说，他肯定是在吹牛，理由如下：
    1. 假设在 CentOS 7.9 中执行 `yum -y install iproute-tc` 安装 `iproute-tc` 时，当前系统 `没有安装` `iproute`，
       而 `iproute-tc` 依赖于 `iproute`：
        - `yum -y install iproute-tc` 会安装 `iproute`
        - `yum -y remove iproute-tc` 不会卸载 `iproute`
    2. 假设在 CentOS 7.9 中执行 `yum -y install iproute-tc` 安装 `iproute-tc` 时，
       当前系统 `已安装` `iproute` 的版本是 `1.0`，而安装的 `iproute-tc` 依赖于 `iproute` `2.0`：
        - `yum -y install iproute-tc` 会升级 `iproute`
        - `yum -y remove iproute-tc` 不会卸载 `iproute`，如果选择卸载，则无法安装 `iproute` `1.0`，
          因为公开仓库中 `iproute` `1.0` 可能已经被删除了（公开仓库默认仅保存最新的一个或几个版本，历史版本会删除）

:::

## 本脚本清理规则 {id=clean}

1. 如果不追求 `极致清理`，只进行 `Kubernetes 重置` 即可
2. [Kubernetes 重置](kubeadm-reset.md)
3. `Kubernetes` 软件卸载
    1. `apt remove -y kubelet kubeadm kubectl`
    2. `yum remove -y kubelet kubeadm kubectl`
4. 仓库删除
    1. `rm /etc/apt/sources.list.d/docker.list -rf`
    2. `rm /etc/apt/sources.list.d/kubernetes.list -rf`
    3. `rm /etc/apt/keyrings/docker.asc -rf`
    4. `rm /etc/apt/keyrings/kubernetes.asc -rf`
5. `containerd` 配置还原
    1. 不支持 `containerd` 版本还原、卸载：脚本执行时不记录 containerd 是否安装以及安装版本
    2. containerd 配置还原：脚本每次执行时，都会备份历史 containerd 配置，文件名后缀是脚本执行的时间，备份文件夹与原配置文件夹相同，
       备份文件路径示例： `/etc/containerd/config.toml.20241125210423`
6. `docker` 还原
    1. `docker` 版本介绍：
        - `旧版 Docker`: `docker.io`
        - `新版 Docker`: `docker-ce`
    2. 脚本安装 `docker`、`containerd` 时，会卸载旧版 `docker`，默认安装最新版，
       无法还原 `旧版 Docker`、`老版本 Docker`、`containerd` 等
7. 容器、镜像清理
    1. `Kubernetes` `1.24.0` 及之后，默认使用 `containerd`，不使用 `docker`
    2. `Kubernetes` 镜像查看命令：`ctr -n=k8s.io i ls`
    3. `Kubernetes` 镜像删除命令：`ctr -n=k8s.io i rm`
    4. `Kubernetes` 容器查看命令：`ctr -n=k8s.io c ls`
    5. `Kubernetes` 容器停止命令：`ctr -n=k8s.io c kill`
    6. `Kubernetes` 任务停止命令：`ctr -n=k8s.io t kill`
    7. `Kubernetes` 任务删除命令：`ctr -n=k8s.io t rm`
