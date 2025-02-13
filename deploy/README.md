# 部署说明

## 说明

1. 使用通配符域名证书，减少配置，申请方法参见：
    1. [使用 acme.sh 生成证书](https://xuxiaowei-com-cn.gitee.io/gitlab-k8s/docs/ssl/acme.sh)
2. 服务器配置：40C256G7440H
3. 服务器系统：PVE 8.0-4
4. 数据使用 NFS 储存在 PVE 中
    1. NFS IP：172.25.25.5
    2. NFS 路径：/nfs
    3. 每个 k8s 节点都需要安装 NFS
5. k8s 节点系统：Anolis OS release 23
6. k8s 资源配置、软件版本
    1. k8s 主节点：2C4G100H
    2. k8s 工作节点：8C16G100H
    3. k8s 主节点 VIP：172.25.25.210
    4. k8s 工作节点 VIP：172.25.25.220

```shell
[root@k8s-control-plane-1 ~]# kubectl get node -o wide
NAME                  STATUS   ROLES           AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION              CONTAINER-RUNTIME
k8s-control-plane-1   Ready    control-plane   17d    v1.27.4   172.25.25.211   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-control-plane-2   Ready    control-plane   17d    v1.27.4   172.25.25.212   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-control-plane-3   Ready    control-plane   17d    v1.27.4   172.25.25.213   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-1            Ready    <none>          17d    v1.27.4   172.25.25.221   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-2            Ready    <none>          17d    v1.27.4   172.25.25.222   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-3            Ready    <none>          15d    v1.27.4   172.25.25.223   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-4            Ready    <none>          14d    v1.27.4   172.25.25.224   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-5            Ready    <none>          12d    v1.27.4   172.25.25.225   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-6            Ready    <none>          4h8m   v1.27.4   172.25.25.226   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
k8s-node-7            Ready    <none>          4h7m   v1.27.4   172.25.25.227   <none>        Anolis OS 23   5.10.134-14.1.an23.x86_64   containerd://1.6.22
[root@k8s-control-plane-1 ~]# kubectl get svc --all-namespaces -o wide
NAMESPACE              NAME                                           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         AGE     SELECTOR
default                kubernetes                                     ClusterIP      10.96.0.1        <none>        443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         38d     <none>
dependabot-helm        dependabot-helm-dependabot-gitlab              ClusterIP      10.99.169.190    <none>        3000/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        3d21h   app.kubernetes.io/component=web,app.kubernetes.io/instance=dependabot-helm,app.kubernetes.io/name=dependabot-gitlab
dependabot-helm        dependabot-helm-mongodb                        ClusterIP      10.102.42.242    <none>        27017/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       3d21h   app.kubernetes.io/component=mongodb,app.kubernetes.io/instance=dependabot-helm,app.kubernetes.io/name=mongodb
dependabot-helm        dependabot-helm-redis-headless                 ClusterIP      None             <none>        6379/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        3d21h   app.kubernetes.io/instance=dependabot-helm,app.kubernetes.io/name=redis
dependabot-helm        dependabot-helm-redis-master                   ClusterIP      10.106.34.63     <none>        6379/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        3d21h   app.kubernetes.io/component=master,app.kubernetes.io/instance=dependabot-helm,app.kubernetes.io/name=redis
gitlab-helm            gitlab-helm-certmanager                        ClusterIP      10.106.183.194   <none>        9402/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/component=controller,app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=certmanager
gitlab-helm            gitlab-helm-certmanager-webhook                ClusterIP      10.101.119.160   <none>        443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         9d      app.kubernetes.io/component=webhook,app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=webhook
gitlab-helm            gitlab-helm-gitaly                             ClusterIP      None             <none>        8075/TCP,9236/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               9d      app=gitaly,release=gitlab-helm
gitlab-helm            gitlab-helm-gitlab-exporter                    ClusterIP      10.105.64.10     <none>        9168/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app=gitlab-exporter,release=gitlab-helm
gitlab-helm            gitlab-helm-gitlab-pages                       ClusterIP      10.102.65.100    <none>        8090/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        7d22h   app=gitlab-pages,release=gitlab-helm
gitlab-helm            gitlab-helm-gitlab-pages-metrics               ClusterIP      10.102.85.196    <none>        9235/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        7d22h   app=gitlab-pages,release=gitlab-helm
gitlab-helm            gitlab-helm-gitlab-shell                       ClusterIP      10.102.164.107   <none>        22/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          9d      app=gitlab-shell,release=gitlab-helm
gitlab-helm            gitlab-helm-kas                                ClusterIP      10.99.226.223    <none>        8150/TCP,8153/TCP,8154/TCP,8151/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             9d      app=kas,release=gitlab-helm
gitlab-helm            gitlab-helm-minio-svc                          ClusterIP      10.108.79.10     <none>        9000/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app=minio,component=app,release=gitlab-helm
gitlab-helm            gitlab-helm-nginx-ingress-controller           LoadBalancer   10.108.9.124     <pending>     80:31543/TCP,443:30721/TCP,22:30295/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         9d      app=nginx-ingress,component=controller,release=gitlab-helm
gitlab-helm            gitlab-helm-nginx-ingress-controller-metrics   ClusterIP      10.99.244.90     <none>        10254/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       9d      app=nginx-ingress,component=controller,release=gitlab-helm
gitlab-helm            gitlab-helm-postgresql                         ClusterIP      10.99.16.87      <none>        5432/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/component=primary,app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=postgresql
gitlab-helm            gitlab-helm-postgresql-hl                      ClusterIP      None             <none>        5432/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/component=primary,app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=postgresql
gitlab-helm            gitlab-helm-postgresql-metrics                 ClusterIP      10.98.239.143    <none>        9187/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/component=primary,app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=postgresql
gitlab-helm            gitlab-helm-prometheus-server                  ClusterIP      10.107.108.52    <none>        80/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          9d      app=prometheus,component=server,release=gitlab-helm
gitlab-helm            gitlab-helm-redis-headless                     ClusterIP      None             <none>        6379/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=redis
gitlab-helm            gitlab-helm-redis-master                       ClusterIP      10.108.134.175   <none>        6379/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/component=master,app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=redis
gitlab-helm            gitlab-helm-redis-metrics                      ClusterIP      10.103.79.158    <none>        9121/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app.kubernetes.io/instance=gitlab-helm,app.kubernetes.io/name=redis
gitlab-helm            gitlab-helm-registry                           ClusterIP      10.109.8.116     <none>        5000/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        9d      app=registry,release=gitlab-helm
gitlab-helm            gitlab-helm-webservice-default                 ClusterIP      10.104.21.50     <none>        8080/TCP,8181/TCP,8083/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      9d      app=webservice,gitlab.com/webservice-name=default,release=gitlab-helm
gitlab                 docker-service                                 NodePort       10.106.244.26    <none>        2375:30375/TCP,2376:30376/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   29d     app=docker
gitlab                 gitlab-ce-service                              NodePort       10.98.41.219     <none>        80:31111/TCP,443:31112/TCP,22:31113/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         36d     app=gitlab-ce
gitlab                 gitlab-ee-service                              NodePort       10.97.231.174    <none>        80:31211/TCP,443:31212/TCP,22:31213/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         36d     app=gitlab-ee
gitlab                 gitlab-jh-service                              NodePort       10.104.1.6       <none>        80:31301/TCP,443:31302/TCP,22:31303/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         36d     app=gitlab-jh
ingress-nginx          ingress-nginx-controller                       LoadBalancer   10.110.209.138   <pending>     80:31974/TCP,443:31467/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      36d     app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
ingress-nginx          ingress-nginx-controller-admission             ClusterIP      10.101.191.140   <none>        443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         36d     app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
jenkins                jenkins-service                                NodePort       10.111.132.224   <none>        8080:30201/TCP,50000:30202/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  31d     app=jenkins
kube-system            kube-dns                                       ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          38d     k8s-app=kube-dns
kube-system            kubelet                                        ClusterIP      None             <none>        10250/TCP,10255/TCP,4194/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    4d4h    <none>
kube-system            metrics-server                                 ClusterIP      10.101.158.114   <none>        443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         38d     k8s-app=metrics-server
kubernetes-dashboard   dashboard-metrics-scraper                      ClusterIP      10.109.12.2      <none>        8000/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        38d     k8s-app=dashboard-metrics-scraper
kubernetes-dashboard   kubernetes-dashboard                           NodePort       10.97.228.26     <none>        443:30320/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   38d     k8s-app=kubernetes-dashboard
minio-operator         console                                        NodePort       10.105.243.243   <none>        9090:32326/TCP,9443:30151/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   37d     app=console
minio-operator         operator                                       ClusterIP      10.107.178.90    <none>        4221/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        37d     name=minio-operator,operator=leader
minio-operator         sts                                            ClusterIP      10.110.109.236   <none>        4223/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        37d     name=minio-operator
monitoring             alertmanager-main                              NodePort       10.107.80.169    <none>        9093:30439/TCP,8080:32203/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   4d4h    app.kubernetes.io/component=alert-router,app.kubernetes.io/instance=main,app.kubernetes.io/name=alertmanager,app.kubernetes.io/part-of=kube-prometheus
monitoring             alertmanager-operated                          ClusterIP      None             <none>        9093/TCP,9094/TCP,9094/UDP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      4d4h    app.kubernetes.io/name=alertmanager
monitoring             blackbox-exporter                              ClusterIP      10.103.238.236   <none>        9115/TCP,19115/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              4d4h    app.kubernetes.io/component=exporter,app.kubernetes.io/name=blackbox-exporter,app.kubernetes.io/part-of=kube-prometheus
monitoring             grafana                                        NodePort       10.103.104.176   <none>        3000:30419/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  4d4h    app.kubernetes.io/component=grafana,app.kubernetes.io/name=grafana,app.kubernetes.io/part-of=kube-prometheus
monitoring             kube-state-metrics                             ClusterIP      None             <none>        8443/TCP,9443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               4d4h    app.kubernetes.io/component=exporter,app.kubernetes.io/name=kube-state-metrics,app.kubernetes.io/part-of=kube-prometheus
monitoring             node-exporter                                  ClusterIP      None             <none>        9100/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        4d4h    app.kubernetes.io/component=exporter,app.kubernetes.io/name=node-exporter,app.kubernetes.io/part-of=kube-prometheus
monitoring             prometheus-adapter                             ClusterIP      10.99.241.136    <none>        443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         4d4h    app.kubernetes.io/component=metrics-adapter,app.kubernetes.io/name=prometheus-adapter,app.kubernetes.io/part-of=kube-prometheus
monitoring             prometheus-k8s                                 NodePort       10.97.106.133    <none>        9090:32607/TCP,8080:32470/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   4d4h    app.kubernetes.io/component=prometheus,app.kubernetes.io/instance=k8s,app.kubernetes.io/name=prometheus,app.kubernetes.io/part-of=kube-prometheus
monitoring             prometheus-operated                            ClusterIP      None             <none>        9090/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        4d4h    app.kubernetes.io/name=prometheus
monitoring             prometheus-operator                            ClusterIP      None             <none>        8443/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        4d4h    app.kubernetes.io/component=controller,app.kubernetes.io/name=prometheus-operator,app.kubernetes.io/part-of=kube-prometheus
nexus                  minio-service                                  NodePort       10.96.97.172     <none>        9000:31561/TCP,9001:31562/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   36d     app=minio
nexus                  nexus-service                                  NodePort       10.107.234.44    <none>        8081:31501/TCP,8443:31502/TCP,8001:31581/TCP,9001:31591/TCP,8002:31582/TCP,9002:31592/TCP,8003:31583/TCP,9003:31593/TCP,8004:31584/TCP,9004:31594/TCP,8005:31585/TCP,9005:31595/TCP,8006:31586/TCP,9006:31596/TCP,8007:31587/TCP,9007:31597/TCP,8008:31588/TCP,9008:31598/TCP,8009:31589/TCP,9009:31599/TCP,8010:31510/TCP,9010:31520/TCP,8011:31511/TCP,9011:31521/TCP,8012:31512/TCP,9012:31522/TCP,8013:31513/TCP,9013:31523/TCP,8014:31514/TCP,9014:31524/TCP,8015:31515/TCP,9015:31525/TCP,8016:31516/TCP,9016:31526/TCP   36d     app=nexus
sonar                  postgres-service                               NodePort       10.103.225.60    <none>        5432:31669/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  20d     app=postgres
sonar                  sonarqube-service                              NodePort       10.101.202.155   <none>        9000:31666/TCP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  20d     app=sonarqube
[root@k8s-control-plane-1 ~]# 
```

## 脚本说明

### gitlab 命名空间

1. [gitlab-ce.yaml](gitlab-ce.yaml)
    1. 部署 gitlab-ce（社区版）
2. [gitlab-ee.yaml](gitlab-ee.yaml)
    1. 部署 gitlab-ee（企业版）
3. [gitlab-jh.yaml](gitlab-jh.yaml)
    1. 部署 gitlab-jh（极狐版）
4. [gitlab-ingress.yaml](gitlab-ingress.yaml)
    1. 配置 gitlab 域名、证书
    2. 只使用 80/443 端口，使用不同域名区分访问目的地

### nexus 命名空间

1. [nexus.yaml](nexus.yaml)
    1. 部署 nexus，搭建个人私库
    2. 支持的私库类型（其中 hosted 代表宿主仓库，可以自己上传；proxy 代表代理仓库；group 代表分组仓库，可以将多个仓库聚合成一个仓库）：
        1. apt (hosted)
        2. apt (proxy)
        3. bower (group)
        4. bower (hosted)
        5. bower (proxy)
        6. cocoapods (proxy)
        7. conan (proxy)
        8. conda (proxy)
        9. docker (group)
        10. docker (hosted)
        11. docker (proxy)
        12. gitlfs (hosted)
        13. go (group)
        14. go (proxy)
        15. helm (hosted)
        16. helm (proxy)
        17. maven2 (group)
        18. maven2 (hosted)
        19. maven2 (proxy)
        20. npm (group)
        21. npm (hosted)
        22. npm (proxy)
        23. nuget (group)
        24. nuget (hosted)
        25. nuget (proxy)
        26. p2 (proxy)
        27. pypi (group)
        28. pypi (hosted)
        29. pypi (proxy)
        30. r (group)
        31. r (hosted)
        32. r (proxy)
        33. raw (group)
        34. raw (hosted)
        35. raw (proxy)
        36. rubygems (group)
        37. rubygems (hosted)
        38. rubygems (proxy)
        39. yum (group)
        40. yum (hosted)
        41. yum (proxy)
2. [minio.yaml](minio.yaml)
    1. MinIO（支持 S3 协议），用户储存 nexus 文件/数据
3. [nexus-ingress.yaml](nexus-ingress.yaml)
    1. 配置 nexus 域名、证书
    2. 主要用于 docker 私库域名证书的配置

### jenkins 命名空间

1. [jenkins.yaml](jenkins.yaml)
    1. 部署 jenkins
    2. 文档
        1. [GitHub](https://github.com/jenkinsci/docker/blob/master/README.md)
        2. [Gitee](https://gitee.com/mirrors-github/jenkins/blob/master/README.md)
2. [jenkins-ingress.yaml](jenkins-ingress.yaml)
    1. 配置 jenkins 域名、证书

## GitLab 配置

- 此配置仅供研究使用，已使用 helm gitlab
  替换，文档：[使用 helm 安装 gitlab](https://gitlab-k8s.xuxiaowei.com.cn/gitlab-k8s/docs/helm/gitlab/install/)

| Name      | Version     | Domain                 |
|-----------|-------------|------------------------|
| gitlab-ce | 16.3.2-ce.0 | gitlab.ce.xuxiaowei.cn |
| gitlab-ee | 16.3.2-ee.0 | gitlab.ee.xuxiaowei.cn |
| gitlab-jh | 16.3.2      | gitlab.jh.xuxiaowei.cn |

## Nexus 私库配置

1. 使用 MinIO（S3协议）储存文件
2. 原则上 `每个仓库类型` + `每个代理地址` 使用独立的 MinIO 桶储存文件/数据

### apt 私库配置

| Name                        | Format | Type  | URL	                                                               | APT Distribution | Proxy Remote storage               | Blob store    |
|-----------------------------|--------|-------|--------------------------------------------------------------------|------------------|------------------------------------|---------------|
| apt-aliyun                  | apt    | proxy | https://nexus.xuxiaowei.cn/repository/apt-aliyun/                  | lunar            | http://mirrors.aliyun.com          | apt-aliyun    |
| apt-tencent                 | apt    | proxy | https://nexus.xuxiaowei.cn/repository/apt-tencent/                 | lunar            | http://mirrors.cloud.tencent.com   | apt-tencent   |
| apt-docker                  | apt    | proxy | https://nexus.xuxiaowei.cn/repository/apt-docker/                  | lunar            | https://download.docker.com        | apt-docker    |
| apt-openkylin-software      | apt    | proxy | https://nexus.xuxiaowei.cn/repository/apt-openkylin-software/      | default          | http://software.openkylin.top      | apt-openkylin |
| apt-openkylin-archive-build | apt    | proxy | https://nexus.xuxiaowei.cn/repository/apt-openkylin-archive-build/ | yangtze          | http://archive.build.openkylin.top | apt-openkylin |
| apt-openkylin-ppa-build     | apt    | proxy | https://nexus.xuxiaowei.cn/repository/apt-openkylin-ppa-build/     | yangtze          | http://ppa.build.openkylin.top     | apt-openkylin |

| 系统名称   | 系统版本  | 安装源类型      | 代理镜像 | 安装源配置文件                                                                        |
|--------|-------|------------|------|--------------------------------------------------------------------------------|
| Ubuntu | 22.10 | 默认 apt     | 阿里云  | [/etc/apt/22.10/aliyun-sources.list](/etc/apt/22.10/aliyun-sources.list)       |
| Ubuntu | 22.10 | docker     | 阿里云  | [/etc/apt/22.10/aliyun-docker.list](/etc/apt/22.10/aliyun-docker.list)         |
| Ubuntu | 22.10 | kubernetes | 阿里云  | [/etc/apt/22.10/aliyun-kubernetes.list](/etc/apt/22.10/aliyun-kubernetes.list) |

- 使用说明
    1. apt-aliyun 代理整个阿里云 apt 镜像的域名，通过 URL 后面不同的路径，可直接使用不同的源，如：ubuntu、debian
    2. apt-tencent 代理整个腾讯云 apt 镜像的域名，通过 URL 后面不同的路径，可直接使用不同的源，如：ubuntu、debian
    3. 阿里云存在 openkylin 的安装源 https://mirrors.aliyun.com/openkylin/
       ，只不过在 https://developer.aliyun.com/mirror/ 没有列举出来
- 使用方式
    1. 备份 `/etc/apt/` 中的源
        ```shell
        cd /etc/apt/
        ll
        sudo mv sources.list sources.list.bak
        ll
        ```
    2. 根据当前系统，选择所需的配置文件，上传至 `/etc/apt/` 或 `/etc/apt/sources.list.d` 文件夹

    3. 清理所有本地仓库

        ```shell
        sudo apt-get clean
        ```

    4. 重建索引测试

        ```shell
        sudo apt-get update
        ```

    5. CentOS 安装依赖测试

        ```shell
        # 可使用搜索进行测试
        # sudo apt-cache madison autoconf
        sudo apt-get -y install autoconf gcc gettext libcurl4-gnutls-dev libexpat1-dev libnl-3-dev libpcre3-dev libssl-dev make zlib1g-dev
        ```

    6. docker 安装依赖测试

        ```shell
        # 可使用搜索进行测试
        # sudo apt-cache madison docker-ce
        sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```

    7. kubernetes 安装依赖测试

        ```shell
        # 可使用搜索进行测试
        # sudo apt-cache madison kubelet
        sudo apt-get -y install kubelet kubeadm kubectl
        ```

### docker 私库配置

| Domain                        | Name             | Format | Type   | URL                                                     | Repository Connectors HTTP | Repository Connectors HTTPS | Allow anonymous docker pull | Enable Docker V1 API | Proxy Remote storage                 | Blob store       |
|-------------------------------|------------------|--------|--------|---------------------------------------------------------|----------------------------|-----------------------------|-----------------------------|----------------------|--------------------------------------|------------------|
| jihulab.docker.xuxiaowei.cn   | docker-jihulab   | docker | proxy  | https://nexus.xuxiaowei.cn/repository/docker-jihulab/   | 8001                       | 9001                        | ✅                           | ✅                    | https://registry.jihulab.com         | docker-jihulab   |
| io.docker.xuxiaowei.cn        | docker-io        | docker | proxy  | https://nexus.xuxiaowei.cn/repository/docker-io/        | 8002                       | 9002                        | ✅                           | ✅                    | https://registry-1.docker.io         | docker-io        |
| gitlab-jh.docker.xuxiaowei.cn | docker-gitlab-jh | docker | proxy  | https://nexus.xuxiaowei.cn/repository/docker-gitlab-jh/ | 8003                       | 9003                        | ✅                           | ✅                    | https://registry.gitlab.cn           | docker-gitlab-jh |
| hosted.docker.xuxiaowei.cn    | docker-hosted    | docker | hosted | https://nexus.xuxiaowei.cn/repository/docker-hosted/    | 8004                       | 9004                        | ✅                           | ✅                    |                                      | docker-hosted    |
| 163.docker.xuxiaowei.cn       | docker-163       | docker | proxy  | https://nexus.xuxiaowei.cn/repository/docker-163/       | 8005                       | 9005                        | ✅                           | ✅                    | https://hub-mirror.c.163.com         | docker-163       |
| group.docker.xuxiaowei.cn     | docker-group     | docker | group  | https://nexus.xuxiaowei.cn/repository/docker-group/     | 8006                       | 9006                        | ✅                           | ✅                    |                                      | docker-group     |
| aliyuncs.docker.xuxiaowei.cn  | docker-aliyuncs  | docker | proxy  | https://nexus.xuxiaowei.cn/repository/docker-aliyuncs/  | 8007                       | 9007                        | ✅                           | ✅                    | https://hnkfbj7x.mirror.aliyuncs.com | docker-aliyuncs  |
| elastic.docker.xuxiaowei.cn   | docker-elastic   | docker | proxy  | https://nexus.xuxiaowei.cn/repository/docker-elastic/   | 8008                       | 9008                        | ✅                           | ✅                    | https://docker.elastic.co            | docker-elastic   |

- 使用说明
    1. 此处拉取 docker 镜像时，使用不同的域名拉取不同的仓库
- docker 信任证书
    1. 参见：https://xuxiaowei-com-cn.gitee.io/gitlab-k8s/docs/nexus/docker-https-configuration
- containerd 信任证书（k8s 使用 containerd）
    1. 参见：https://xuxiaowei-com-cn.gitee.io/gitlab-k8s/docs/k8s/containerd-mirrors/
- 使用方式
    1. 待更新

### maven 私库配置

| Name                 | Format | Type  | URL                                                         | Version policy | Proxy Remote storage                                           | Blob store           |
|----------------------|--------|-------|-------------------------------------------------------------|----------------|----------------------------------------------------------------|----------------------|
| maven-aliyun-central | maven2 | proxy | https://nexus.xuxiaowei.cn/repository/maven-aliyun-central/ | Release        | https://maven.aliyun.com/repository/central                    | maven-aliyun         |
| maven-aliyun-public  | maven2 | proxy | https://nexus.xuxiaowei.cn/repository/maven-aliyun-public/  | Release        | https://maven.aliyun.com/repository/public                     | maven-aliyun         |
| maven-tencent-public | maven2 | proxy | https://nexus.xuxiaowei.cn/repository/maven-tencent-public/ | Release        | http://mirrors.cloud.tencent.com/nexus/repository/maven-public | maven-tencent-public |
| maven-group          | maven2 | group | https://nexus.xuxiaowei.cn/repository/maven-group/          | Release        |                                                                | maven-group          |

- 使用方式
    1. 待更新

### yum 私库配置

| Name           | Format | Type  | URL                                                   | Proxy Remote storage             | Blob store     |
|----------------|--------|-------|-------------------------------------------------------|----------------------------------|----------------|
| yum-aliyun     | yum    | proxy | https://nexus.xuxiaowei.cn/repository/yum-aliyun/     | http://mirrors.aliyun.com        | yum-aliyun     |
| yum-tencent    | yum    | proxy | https://nexus.xuxiaowei.cn/repository/yum-tencent/    | http://mirrors.cloud.tencent.com | yum-tencent    |
| yum-docker     | yum    | proxy | https://nexus.xuxiaowei.cn/repository/yum-docker/     | https://download.docker.com      | yum-docker     |
| yum-openanolis | yum    | proxy | https://nexus.xuxiaowei.cn/repository/yum-openanolis/ | https://mirrors.openanolis.cn    | yum-openanolis |

| 系统名称         | 系统版本 | 安装源类型      | 代理镜像 | 安装源配置文件                                                                                                  |
|--------------|------|------------|------|----------------------------------------------------------------------------------------------------------|
| CentOS       | 7    | 默认 yum     | 阿里云  | [/etc/yum.repos.d/aliyun-centos-7.repo](/etc/yum.repos.d/aliyun-centos-7.repo)                           |
| CentOS       | 8    | 默认 yum     | 阿里云  | [/etc/yum.repos.d/aliyun-centos-8.repo](/etc/yum.repos.d/aliyun-centos-8.repo)                           |
| CentOS vault | 8    | 默认 yum     | 阿里云  | [/etc/yum.repos.d/aliyun-centos-vault-8.5.2111.repo](/etc/yum.repos.d/aliyun-centos-vault-8.5.2111.repo) |
| CentOS       | 7/8  | docker     | 阿里云  | [/etc/yum.repos.d/aliyun-docker-ce.repo](/etc/yum.repos.d/aliyun-docker-ce.repo)                         |
| CentOS       | 7/8  | kubernetes | 阿里云  | [/etc/yum.repos.d/aliyun-kubernetes.repo](/etc/yum.repos.d/aliyun-kubernetes.repo)                       |
| AnolisOS     | all  | 默认 yum     | 阿里云  | [/etc/yum.repos.d/aliyun-anolis.repo](/etc/yum.repos.d/aliyun-anolis.repo)                               |

- 使用说明
    1. yum-aliyun 代理整个阿里云 yum 镜像的域名，通过 URL 后面不同的路径，可直接使用不同的源，如：centos、centos-vault
    2. yum-tencent 代理整个腾讯云 yum 镜像的域名，通过 URL 后面不同的路径，可直接使用不同的源，如：centos、centos-vault
- 使用方式
    1. 备份 `/etc/yum.repos.d` 中的源
        ```shell
        cd /etc/yum.repos.d
        ll
        for file in *.repo; do mv "$file" "${file}.bak"; done
        ll
        ```
    2. 根据当前系统，选择所需的配置文件，上传至 `/etc/yum.repos.d/` 文件夹

    3. 清理所有本地仓库

        ```shell
        yum clean all
        ```

    4. 重建索引测试

        ```shell
        yum makecache
        ```

    5. CentOS 安装依赖测试

        ```shell
        # 可使用搜索进行测试
        # yum --showduplicates list autoconf
        yum -y install autoconf bash-completion curl-devel expat-devel gcc git libnl3-devel libtool make openssl-devel svn systemd-devel tar tcl vim wget zlib-devel
        ```

    6. docker 安装依赖测试

        ```shell
        # 可使用搜索进行测试
        # yum --showduplicates list docker-ce
        yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```

    7. kubernetes 安装依赖测试

        ```shell
        # 可使用搜索进行测试
        # yum --showduplicates list kubelet
        yum -y install kubelet kubeadm kubectl --disableexcludes=kubernetes --nogpgcheck
        ```

    8. AnolisOS 安装依赖测试

       ```shell
       # 可使用搜索进行测试
       # yum --showduplicates list autoconf
       yum -y install autoconf bash-completion curl-devel expat-devel gcc git libnl3-devel libtool make openssl-devel svn systemd-devel tar tcl vim wget zlib-devel
       ```
