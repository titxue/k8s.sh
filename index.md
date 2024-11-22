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
      text: 简介
      link: /README
    - theme: alt
      text: 参数说明
      link: /config
    - theme: alt
      text: 镜像文件
      link: /mirrors

features:
  - title: Kubernetes
    details: 支持从 1.24 到 1.31 的所有版本，使用国内镜像加速安装配置
  - title: 操作系统
    details: 支持主流操作系统，支持国产操作系统（龙蜥 AnolisOS、欧拉 OpenEuler、银河麒麟 Kylin、开放麒麟 OpenKylin、优麒麟 Ubuntu Kylin、深度 Deepin 等）
  - title: 自动化测试
    details: 现已支持超过 45+ 种不同系统版本，提供超过 73+ 个不同流水线配置自动化测试 Kubernetes 安装
  - title: 镜像文件与 charts 仓库
    details: 提供常用的 Kubernetes 部署文件及 charts 仓库
  - title: Containerd
    details: 使用 Containerd 作为容器运行时，使用国内镜像加速安装配置
  - title: Calico
    details: 基于参数配置网络插件 Calico，使用国内镜像加速安装配置
  - title: Ingress Nginx
    details: 基于参数配置 Ingress Nginx，使用国内镜像加速安装配置
---

