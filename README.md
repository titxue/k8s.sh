# Kubernetes（k8s）自动安装配置脚本

## 支持系统/版本

- 测试流水线：https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/pipelines
    - 测试原理
        1. 每次执行均创建一个对应系统的虚拟机：最小化安装系统（防止干扰，减小开销）
        2. 执行安装配置：安装 `Kubernetes` 必要的软件及配置，如：`Containerd`、`Calico`、`Ingress nginx` 等
        3. 执行测试：验证相关功能是否可用，如：部署 `Deployment`、`Service`、`Ingress` 等
- 标注：
    1. ✅：支持，已完成自动化测试
    2. 空：未增加自动化测试，理论上支持
    3. ❌：不支持
- 如果使用异常，请提交议题，请附上 `原始的完整日志`（有敏感信息可隐藏）
    1. [Gitee](https://gitee.com/xuxiaowei-com-cn/k8s.sh/issues)
    2. [GitHub](https://github.com/xuxiaowei-com-cn/k8s.sh/issues)
- 如果要支持其他操作系统，请提交议题，建议提供 `系统下载的原始地址`，节省查找时间
    1. [Gitee](https://gitee.com/xuxiaowei-com-cn/k8s.sh/issues)
    2. [GitHub](https://github.com/xuxiaowei-com-cn/k8s.sh/issues)
- 按照名称排序、按照版本倒叙

| Linux/Kubernetes                | 1.31 | 1.30 | 1.29 | 1.28 | 1.27 | 1.26 | 1.25 | 1.24 |
|---------------------------------|------|------|------|------|------|------|------|------|
| AlmaLinux 8.10                  | ✅    |      |      |      |      |      |      |      |
| AlmaLinux 9.4                   | ✅    |      |      |      |      |      |      | ✅    |
| AlmaLinux 9.5                   | ✅    |      |      |      |      |      |      |      |
| AnolisOS 7.7                    | ✅    | ✅    | ✅    | ✅    | ✅    | ✅    | ✅    | ✅    |
| 龙蜥 AnolisOS 7.9                 | ✅    |      |      |      |      |      |      | ✅    |
| 龙蜥 AnolisOS 8.2                 | ✅    |      |      |      |      |      |      |      |
| 龙蜥 AnolisOS 8.4                 | ✅    |      |      |      |      |      |      |      |
| 龙蜥 AnolisOS 8.6                 | ✅    |      |      |      |      |      |      |      |
| 龙蜥 AnolisOS 8.8                 | ✅    |      |      |      |      |      |      |      |
| 龙蜥 AnolisOS 8.9                 | ✅    |      |      |      |      |      |      |      |
| 龙蜥 AnolisOS 23.0                | ✅    |      |      |      |      |      |      |      |
| 龙蜥 AnolisOS 23.1                | ✅    |      |      |      |      |      |      |      |
| CentOS 7.9.2009                 | ✅    |      |      |      |      |      |      |      |
| CentOS 7.9.2207                 | ✅    |      |      |      |      |      |      |      |
| CentOS 8.1.1911                 | ✅    |      |      |      |      |      |      |      |
| CentOS 8.2.2004                 | ✅    |      |      |      |      |      |      |      |
| CentOS 8.3.2011                 | ✅    |      |      |      |      |      |      |      |
| CentOS 8.4.2105                 | ✅    |      |      |      |      |      |      |      |
| CentOS 8.5.2111                 | ✅    |      |      |      |      |      |      |      |
| CentOS 9-20241028.0             | ✅    |      |      |      |      |      |      | ✅    |
| Debian 10.10.0 buster           | ✅    |      |      |      |      |      |      | ✅    |
| Debian 11.7.0 bullseye          | ✅    |      |      |      |      |      |      |      |
| Debian 12.4.0 bookworm          | ✅    |      |      |      |      |      |      |      |
| Debian 12.7.0 bookworm          | ✅    |      |      |      |      |      |      |      |
| Deepin 20.9 apricot             | ✅    |      |      |      |      |      |      |      |
| 欧拉 OpenEuler 20.03              | ✅    |      |      |      |      |      |      |      |
| 欧拉 OpenEuler 22.03              | ✅    |      |      |      |      |      |      |      |
| 欧拉 OpenEuler 24.03              | ✅    |      |      |      |      |      |      |      |
| 开放麒麟 OpenKylin 1.0 yangtze      | ✅    |      |      |      |      |      |      |      |
| 开放麒麟 OpenKylin 1.0.1 yangtze    | ✅    |      |      |      |      |      |      |      |
| 开放麒麟 OpenKylin 1.0.2 yangtze    | ✅    |      |      |      |      |      |      |      |
| 开放麒麟 OpenKylin 2.0 nile         | ✅    |      |      |      |      |      |      |      |
| Rocky 8.10 Green Obsidian       | ✅    |      |      |      |      |      |      |      |
| Rocky 9.4 Blue Onyx             | ✅    |      |      |      |      |      |      |      |
| 乌班图 Ubuntu 18.04 bionic         | ✅    |      |      |      |      |      |      |      |
| 乌班图 Ubuntu 20.04 focal          | ✅    |      |      |      |      |      |      |      |
| 乌班图 Ubuntu 22.04 jammy          | ✅    |      |      |      |      |      |      |      |
| 乌班图 Ubuntu 24.04 noble          | ✅    |      |      |      |      |      |      | ✅    |
| 优麒麟 Ubuntu Kylin 18.04.5 bionic | ✅    |      |      |      |      |      |      |      |
| 优麒麟 Ubuntu Kylin 20.04.6 focal  | ✅    |      |      |      |      |      |      |      |
| 优麒麟 Ubuntu Kylin 22.04.5 jammy  | ✅    |      |      |      |      |      |      |      |
| 优麒麟 Ubuntu Kylin 24.04.1 noble  | ✅    |      |      |      |      |      |      |      |

| kubernetes 版本 | 流水线环境                                                                                                                |
|---------------|----------------------------------------------------------------------------------------------------------------------|
| 1.31          | [kubernetes/v1.31](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/43?tab=deployment-history) |
| 1.30          | [kubernetes/v1.30](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/36?tab=deployment-history) |
| 1.29          | [kubernetes/v1.29](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/37?tab=deployment-history) |
| 1.28          | [kubernetes/v1.28](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/38?tab=deployment-history) |
| 1.27          | [kubernetes/v1.27](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/39?tab=deployment-history) |
| 1.26          | [kubernetes/v1.26](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/40?tab=deployment-history) |
| 1.25          | [kubernetes/v1.25](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/41?tab=deployment-history) |
| 1.24          | [kubernetes/v1.24](https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/environments/42?tab=deployment-history) |

## 原则

1. 最小化修改系统配置
    - 针对每种系统、每个版本有特定的配置，而不是直接在所有系统和版本中添加固定的配置
2. 最小原则安装软件
    - 只安装需要用到的软件

## kubernetes 一键安装交互式网站

|                | 网站                                         | 说明 |
|----------------|--------------------------------------------|----|
| 自建服务器          | https://k8s-sh.xuxiaowei.com.cn            | 国内 |
| GitHub Pages   | https://xuxiaowei-com-cn.github.io/k8s.sh/ | 国际 |
| FramaGit Pages | https://xuxiaowei-com-cn.frama.io/k8s.sh/  | 国际 |

## 文档

- [GitLab/Kubernetes 知识库](https://gitlab-k8s.xuxiaowei.com.cn)
- [Kubernetes 中文文档国内镜像-最新版](https://kubernetes.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.30](https://kubernetes-v1-30.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.29](https://kubernetes-v1-29.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.28](https://kubernetes-v1-28.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.27](https://kubernetes-v1-27.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.26](https://kubernetes-v1-26.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.25](https://kubernetes-v1-25.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.24](https://kubernetes-v1-24.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.23](https://kubernetes-v1-23.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.22](https://kubernetes-v1-22.xuxiaowei.com.cn/zh-cn/)
- [Kubernetes 中文文档国内镜像-v1.21](https://kubernetes-v1-21.xuxiaowei.com.cn/zh-cn/)

## [分支与历史版本](history.md)

## 国内镜像支持的范围

1. `Kubernetes` 从 `1.24.0` 到 `最新版`，一共 105 个版本及 `国内镜像`
    1. 截止 `2024-10-30`，`Kubernetes` 最高版是 `v1.31.2`
    2. 具体支持的版本及 `国内镜像` 参见：
       [kubernetes-version.json](https://gitee.com/xuxiaowei-com-cn/k8s.sh/blob/SNAPSHOT/2.0.0/.vitepress/components/json/kubernetes-version.json)
2. `calico` 一共 `24` 个版本及 `国内镜像`
    1. 截止 `2024-10-30`
    2. 具体支持的版本及 `国内镜像` 参见：
       [calico-version.json](https://gitee.com/xuxiaowei-com-cn/k8s.sh/blob/SNAPSHOT/2.0.0/.vitepress/components/json/calico-version.json)
3. `ingress nginx` 一共 `24` 个版本及 `国内镜像`
    1. 截止 `2024-10-30`
    2. 具体支持的版本及 `国内镜像` 参见：
       [ingress-nginx-version.json](https://gitee.com/xuxiaowei-com-cn/k8s.sh/blob/SNAPSHOT/2.0.0/.vitepress/components/json/ingress-nginx-version.json)

## [赞助](https://docs.xuxiaowei.cloud/spring-cloud-xuxiaowei/guide/contributes.html)
