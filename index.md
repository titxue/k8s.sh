---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Kubernetes 一键安装文档"
  text: "一行命令快速安装 Kubernetes，无需关心拉取镜像、配置问题"
  tagline:
  actions:
    - theme: brand
      text: 快速开始
      link: /getting-started
    - theme: alt
      text: 参数说明
      link: /config

features:
  - title: Kubernetes
    details: 支持从 1.24 到 1.31 的所有版本，使用国内镜像加速安装配置
  - title: 操作系统
    details: 支持主流操作系统，支持国产操作系统（龙蜥 AnolisOS、欧拉 OpenEuler、麒麟 OpenKylin 等），现已支持超过 33 中不同系统版本，提供超过 58+ 个流水线自动化测试
  - title: Containerd
    details: 使用 Containerd 作为容器运行时，使用国内镜像加速安装配置
  - title: Calico
    details: 基于参数配置网络插件 Calico，使用国内镜像加速安装配置
  - title: Ingress Nginx
    details: 基于参数配置 Ingress Nginx，使用国内镜像加速安装配置
---

