# 自建 Nexus 仓库配置 {id=nexus-repository}

## 自建仓库代理地址 {id=nexus-repository-proxy}

| Format | Type  | URL                                                              | Proxy Remote                                                   |
|--------|-------|------------------------------------------------------------------|----------------------------------------------------------------|
| yum    | proxy | http://172.25.25.14:48081/repository/almalinux/                  | https://mirrors.aliyun.com/almalinux                           |
| yum    | proxy | http://172.25.25.14:48081/repository/anolis/                     | http://mirrors.openanolis.cn/anolis                            |
| yum    | proxy | http://172.25.25.14:48081/repository/centos/                     | https://mirrors.aliyun.com/centos                              |
| yum    | proxy | http://172.25.25.14:48081/repository/centos-stream/              | https://mirrors.aliyun.com/centos-stream                       |
| yum    | proxy | http://172.25.25.14:48081/repository/centos-stream-SIGs/         | https://mirrors.aliyun.com/centos-stream/SIGs                  |
| yum    | proxy | http://172.25.25.14:48081/repository/centos-vault/               | http://mirrors.aliyun.com/centos-vault                         |
| apt    | proxy | http://172.25.25.14:48081/repository/debian/                     | https://mirrors.aliyun.com/debian                              |
| apt    | proxy | http://172.25.25.14:48081/repository/debian-security/            | http://mirrors.aliyun.com/debian-security                      |
| apt    | proxy | http://172.25.25.14:48081/repository/docker-apt/                 | https://mirrors.aliyun.com/docker-ce/linux                     |
| yum    | proxy | http://172.25.25.14:48081/repository/docker-yum/                 | https://mirrors.aliyun.com/docker-ce/linux                     |
| apt    | proxy | http://172.25.25.14:48081/repository/kubernetes-new-apt/         | https://mirrors.aliyun.com/kubernetes-new/core/stable          |
| yum    | proxy | http://172.25.25.14:48081/repository/kubernetes-new-yum/         | https://mirrors.aliyun.com/kubernetes-new/core/stable          |
| yum    | proxy | http://172.25.25.14:48081/repository/openeuler/                  | https://repo.openeuler.org                                     |
| apt    | proxy | http://172.25.25.14:48081/repository/openkylin/                  | http://archive.build.openkylin.top/openkylin                   |
| apt    | proxy | http://172.25.25.14:48081/repository/openkylin-anything/         | http://ppa.build.openkylin.top/kylinsoft/anything/openkylin    |
| apt    | proxy | http://172.25.25.14:48081/repository/openkylin-anything2.0/      | http://ppa.build.openkylin.top/kylinsoft/anything2.0/openkylin |
| apt    | proxy | http://172.25.25.14:48081/repository/openkylin-software/         | http://software.openkylin.top/openkylin                        |
| apt    | proxy | http://172.25.25.14:48081/repository/openkylin-software-yangtze/ | http://software.openkylin.top/openkylin/yangtze                |
| yum    | proxy | http://172.25.25.14:48081/repository/rockylinux/                 | https://mirrors.aliyun.com/rockylinux                          |
| apt    | proxy | http://172.25.25.14:48081/repository/ubuntu/                     | https://mirrors.aliyun.com/ubuntu                              |
