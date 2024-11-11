# Kubernetes（k8s）自动安装配置脚本

## 支持系统/版本

- 测试流水线：https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/pipelines
    - 测试原理
        1. 每次执行均创建一个对应系统的虚拟机：最小化安装系统（防止干扰，减小开销）
        2. 执行安装：验证相关功能是否可用
- 未标注：只是还未增加自动化测试，不代表不支持

| Linux/Kubernetes       | 1.31 | 1.30 | 1.29 | 1.28 | 1.27 | 1.26 | 1.25 | 1.24 |
|------------------------|------|------|------|------|------|------|------|------|
| AlmaLinux 9.4          | ✅    |      |      |      |      |      |      | ✅    |
| AnolisOS 7.7           | ✅    | ✅    | ✅    | ✅    | ✅    | ✅    | ✅    | ✅    |
| AnolisOS 7.9           | ✅    |      |      |      |      |      |      | ✅    |
| AnolisOS 8.2           | ✅    |      |      |      |      |      |      |      |
| AnolisOS 8.4           | ✅    |      |      |      |      |      |      |      |
| AnolisOS 8.6           | ✅    |      |      |      |      |      |      |      |
| AnolisOS 8.8           | ✅    |      |      |      |      |      |      |      |
| AnolisOS 8.9           | ✅    |      |      |      |      |      |      |      |
| AnolisOS 23.0          | ✅    |      |      |      |      |      |      |      |
| AnolisOS 23.1          | ✅    |      |      |      |      |      |      |      |
| CentOS 7.9             | ✅    |      |      |      |      |      |      |      |
| CentOS 8.1             | ✅    |      |      |      |      |      |      |      |
| CentOS 8.2             | ✅    |      |      |      |      |      |      |      |
| CentOS 8.3             | ✅    |      |      |      |      |      |      |      |
| CentOS 8.4             | ✅    |      |      |      |      |      |      |      |
| CentOS 8.5             | ✅    |      |      |      |      |      |      |      |
| CentOS 9-20241028.0    | ✅    |      |      |      |      |      |      | ✅    |
| Debian 10.10.0 buster  | ✅    |      |      |      |      |      |      | ✅    |
| Debian 11.7.0 bullseye | ✅    |      |      |      |      |      |      |      |
| Debian 12.4.0 bookworm | ✅    |      |      |      |      |      |      |      |
| Debian 12.7.0 bookworm | ✅    |      |      |      |      |      |      |      |
| OpenKylin 2.0 nile     | ✅    |      |      |      |      |      |      |      |
| Ubuntu 18.04 bionic    | ✅    |      |      |      |      |      |      |      |
| Ubuntu 20.04 focal     | ✅    |      |      |      |      |      |      |      |
| Ubuntu 22.04 jammy     | ✅    |      |      |      |      |      |      |      |
| Ubuntu 24.04 noble     | ✅    |      |      |      |      |      |      | ✅    |

## kubernetes 一键安装交互式网站

|                | 网站                                         | 说明 |
|----------------|--------------------------------------------|----|
| 自建服务器          | https://k8s-sh.xuxiaowei.com.cn            | 国内 |
| GitHub Pages   | https://xuxiaowei-com-cn.github.io/k8s.sh/ | 国际 |
| FramaGit Pages | https://xuxiaowei-com-cn.frama.io/k8s.sh/  | 国际 |

## 文档

- https://k8s-sh.xuxiaowei.com.cn
- [GitLab/Kubernetes 知识库](https://gitlab-k8s.xuxiaowei.com.cn)

## [分支与历史版本](history.md)

## 支持的范围

1. `Kubernetes` 从 `1.24.0` 到 `最新版`，一共 105 个版本及 `国内镜像`
    1. 截止 `2024-10-30`，`Kubernetes` 最高版是 `v1.31.2`
    2. 具体支持的版本及 `国内镜像` 参见：
       [kubernetes-version.json](https://gitee.com/xuxiaowei-com-cn/k8s.sh/blob/docs/src/json/kubernetes-version.json)
2. `calico` 一共 `24` 个版本及 `国内镜像`
    1. 截止 `2024-10-30`
    2. 具体支持的版本及 `国内镜像` 参见：
       [calico-version.json](https://gitee.com/xuxiaowei-com-cn/k8s.sh/blob/docs/src/json/calico-version.json)
3. `ingress nginx` 一共 `24` 个版本及 `国内镜像`
    1. 截止 `2024-10-30`
    2. 具体支持的版本及 `国内镜像` 参见：
       [ingress-nginx-version.json](https://gitee.com/xuxiaowei-com-cn/k8s.sh/blob/docs/src/json/ingress-nginx-version.json)

## [赞助](https://docs.xuxiaowei.cloud/spring-cloud-xuxiaowei/guide/contributes.html)
