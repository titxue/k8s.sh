# 更新日志 {id=CHANGELOG}

## SNAPSHOT/2.0.1 {id=SNAPSHOT/2.0.1}

### 🔨 Dependency Upgrades | 依赖项升级 {id=SNAPSHOT/2.0.1-Dependency}

1. kubernetes 默认版本从 1.31.1 升级到 1.31.4
2. kubernetes 1.29.x 流水线从 1.29.11 升级到 1.29.12
3. kubernetes 1.30.x 流水线从 1.30.7 升级到 1.30.8
4. kubernetes 1.31.x 流水线从 1.31.3 升级到 1.31.4

### ⭐ New Features | 新功能 {id=SNAPSHOT/2.0.1-New-Features}

1. 新增 kubernetes 1.32.0/1.31.4/1.30.8/1.29.12 镜像
2. 新增 kubernetes 1.32.x 流水线
3. etcd 集群二进制安装：支持单机版、集群版，支持自动化测试 [#53](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/issues/53)

### 🐞 Bug Fixes | 漏洞修补 {id=SNAPSHOT/2.0.1-Bug-Fixes}

1. 修正 apt 安装 tar 命令
2. 解决部分系统无 /etc/apt/sources.list.d 目录异常 [#16](https://github.com/xuxiaowei-com-cn/k8s.sh/issues/16)

### 📔 Documentation | 文档 {id=SNAPSHOT/2.0.1-Documentation}

1. 新增 [历史版本](history.md) 流水线 链接
2. 新增 [Kubernetes 发布日历](question/k8s-release-cal.md)
3. 新增 [视频](videos.md) 链接
4. 新增 kubernetes 1.32.x 支持范围
5. 新增 kubernetes 1.31.x 国内中文文档地址
6. 新增 etcd 二进制安装文档：支持单机版、集群版 [#53](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/issues/53)
7. 更新文档，统一格式

## 2.0.0 {id=2.0.0}

### ⭐ New Features | 新功能 {id=2.0.0-New-Features}

1. 支持安装的 Kubernetes 版本: 1.24/1.25/1.26/1.27/1.28/1.29/1.30/1.31
2. 支持系统:

   | 系统               | 系统版本                                                                        |
   |------------------|-----------------------------------------------------------------------------|
   | AlmaLinux        | 8.10 Cerulean Leopard/9.4 Seafoam Ocelot/9.5 Teal Serval                    |
   | 龙蜥 AnolisOS      | 7.7/7.9/8.2/8.4/8.6/8.8/8.9/23.0/23.1                                       |
   | CentOS           | 7.9.2009/7.9.2207/8.1.1911/8.2.2004/8.3.2011/8.4.2105/8.5.2111/9-20241028.0 |
   | Debian           | 10.10.0 buster/11.7.0 bullseye/12.4.0 bookworm/12.7.0 bookworm              |
   | 深度 Deepin        | 20.9 apricot                                                                |
   | 银河麒麟 Kylin       | v10 sp1 2303/v10 sp1 2403                                                   |
   | 欧拉 OpenEuler     | 20.03/22.03/24.03                                                           |
   | 开放麒麟 OpenKylin   | 1.0 yangtze/1.0.1 yangtze/1.0.2 yangtze/2.0 nile                            |
   | Rocky            | 8.10 Green Obsidian/9.4 Blue Onyx/9.5 Blue Onyx                             |
   | 乌班图 Ubuntu       | 18.04 bionic/20.04 focal/22.04 jammy/24.04 noble                            |
   | 优麒麟 Ubuntu Kylin | 18.04.5 bionic/20.04.6 focal/22.04.5 jammy/24.04.1 noble                    |

3. 镜像文件

   | 仓库                                                     | 版本                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
   |--------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
   | https://github.com/kubernetes/dashboard                | v2.6.0/v2.6.1/v2.7.0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
   | https://github.com/kubernetes/ingress-nginx            | controller-v1.3.1/controller-v1.4.0/controller-v1.5.1/controller-v1.5.2/controller-v1.6.0/controller-v1.6.1/controller-v1.6.2/controller-v1.6.3/controller-v1.6.4/controller-v1.7.0/controller-v1.7.1/controller-v1.8.0/controller-v1.8.1/controller-v1.8.2/controller-v1.8.4/controller-v1.8.5/controller-v1.9.0/controller-v1.9.1/controller-v1.9.3/controller-v1.9.4/controller-v1.9.5/controller-v1.9.6/controller-v1.10.0/controller-v1.10.1/controller-v1.10.2/controller-v1.10.3/controller-v1.10.4/controller-v1.10.5/controller-v1.11.0/controller-v1.11.1/controller-v1.11.2/controller-v1.11.3 |
   | https://github.com/kubernetes-sigs/metrics-server      | v0.4.0/v0.4.1/v0.4.2/v0.4.3/v0.4.4/v0.4.5/v0.5.0/v0.5.1/v0.5.2/v0.6.0/v0.6.1/v0.6.2/v0.6.3/v0.6.4/v0.7.0/v0.7.1/v0.7.2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
   | https://github.com/projectcalico/calico                | v3.24.0/v3.24.1/v3.24.2/v3.24.3/v3.24.4/v3.24.5/v3.24.6/v3.25.0/v3.25.1/v3.25.2/v3.26.0/v3.26.1/v3.26.2/v3.26.3/v3.26.4/v3.26.5/v3.27.0/v3.27.1/v3.27.2/v3.27.3/v3.27.4/v3.28.0/v3.28.1/v3.28.2/v3.29.0/v3.29.1                                                                                                                                                                                                                                                                                                                                                                                           |
   | https://github.com/prometheus-operator/kube-prometheus | v0.11.0/v0.12.0/v0.13.0/v0.14.0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |

4. 同步 Docker 镜像（国内镜像地址见脚本）

   | 仓库                                                     | 数量（包含不同架构） |
   |--------------------------------------------------------|------------|
   | https://github.com/kubernetes/ingress-nginx            | 245        |
   | https://github.com/kubernetes/kubernetes               | 915        |
   | https://github.com/kubernetes-sigs/metrics-server      | 102        |
   | https://github.com/projectcalico/calico                | 289        |

5. [离线 Docker 镜像](https://xuxiaowei-my.sharepoint.com/:f:/g/personal/share_xuxiaowei_com_cn/EjjHOkWYEPdFlpOqfcza1fYBq6kPtWLJ8ZmdosSeGYBMKQ)

   | 镜像                                      | 数量（包含不同架构） |
   |-----------------------------------------|------------|
   | registry.k8s.io/coredns/coredns         | 105        |
   | registry.k8s.io/etcd                    | 126        |
   | registry.k8s.io/kube-apiserver          | 484        |
   | registry.k8s.io/kube-controller-manager | 484        |
   | registry.k8s.io/kube-proxy              | 484        |
   | registry.k8s.io/kube-scheduler          | 484        |
   | registry.k8s.io/pause                   | 51         |
