# 命令 {id=command}

[[toc]]

## 查看版本 {id=version}

### kubectl {id=kubectl-version}

::: code-group

```shell [yaml]
kubectl version -o yaml
```

```shell [yaml result]
[root@xuxiaowei-bilibili ~]# kubectl version -o yaml
clientVersion:
  buildDate: "2023-06-14T09:53:42Z"
  compiler: gc
  gitCommit: 25b4e43193bcda6c7328a6d147b1fb73a33f1598
  gitTreeState: clean
  gitVersion: v1.27.3
  goVersion: go1.20.5
  major: "1"
  minor: "27"
  platform: linux/amd64
kustomizeVersion: v5.0.1
serverVersion:
  buildDate: "2023-06-14T09:47:40Z"
  compiler: gc
  gitCommit: 25b4e43193bcda6c7328a6d147b1fb73a33f1598
  gitTreeState: clean
  gitVersion: v1.27.3
  goVersion: go1.20.5
  major: "1"
  minor: "27"
  platform: linux/amd64

[root@xuxiaowei-bilibili ~]# 
```

```shell [json]
kubectl version -o json
```

```shell [json result]
[root@xuxiaowei-bilibili ~]# kubectl version -o json
{
  "clientVersion": {
    "major": "1",
    "minor": "27",
    "gitVersion": "v1.27.3",
    "gitCommit": "25b4e43193bcda6c7328a6d147b1fb73a33f1598",
    "gitTreeState": "clean",
    "buildDate": "2023-06-14T09:53:42Z",
    "goVersion": "go1.20.5",
    "compiler": "gc",
    "platform": "linux/amd64"
  },
  "kustomizeVersion": "v5.0.1",
  "serverVersion": {
    "major": "1",
    "minor": "27",
    "gitVersion": "v1.27.3",
    "gitCommit": "25b4e43193bcda6c7328a6d147b1fb73a33f1598",
    "gitTreeState": "clean",
    "buildDate": "2023-06-14T09:47:40Z",
    "goVersion": "go1.20.5",
    "compiler": "gc",
    "platform": "linux/amd64"
  }
}
[root@xuxiaowei-bilibili ~]# 
```

:::

### kubernetesVersion {id=kubernetesVersion}

::: code-group

```shell
kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion
```

```shell [result]
[root@xuxiaowei-bilibili ~]# kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion
kubernetesVersion: v1.27.3
[root@xuxiaowei-bilibili ~]# 
```

:::

### calico {id=calico-version}

::: code-group

```shell [image]
kubectl -n kube-system get deployment calico-kube-controllers -o jsonpath='{.spec.template.spec.containers[0].image}' && echo
```

```shell [result]
[root@xuxiaowei-bilibili ~]# kubectl -n kube-system get deployment calico-kube-controllers -o jsonpath='{.spec.template.spec.containers[0].image}' && echo
docker.io/calico/kube-controllers:v3.25.0
[root@xuxiaowei-bilibili ~]#
```

:::

### Ingress Nginx {id=ingress-nginx-version}

::: code-group

```shell [image]
kubectl -n ingress-nginx get deployments.apps ingress-nginx-controller -o jsonpath='{.spec.template.spec.containers[0].image}' && echo
```

```shell [result]
[root@xuxiaowei-bilibili ~]# kubectl -n ingress-nginx get deployments.apps ingress-nginx-controller -o jsonpath='{.spec.template.spec.containers[0].image}' && echo
registry.k8s.io/ingress-nginx/controller:v1.11.3
[root@xuxiaowei-bilibili ~]# 
```

```shell [labels]
kubectl -n ingress-nginx get deployments.apps ingress-nginx-controller -o jsonpath='{.metadata.labels.app\.kubernetes\.io\/version}' && echo
```

```shell [labels result]
[root@xuxiaowei-bilibili ~]# kubectl -n ingress-nginx get deployments.apps ingress-nginx-controller -o jsonpath='{.metadata.labels.app\.kubernetes\.io\/version}' && echo
1.11.3
[root@xuxiaowei-bilibili ~]# 
```

:::

### Metrics Server {id=metrics-server-version}

::: code-group

```shell [image]
kubectl -n kube-system get deployments.apps metrics-server -o jsonpath='{.spec.template.spec.containers[0].image}' && echo
```

```shell [result]
[root@xuxiaowei-bilibili ~]# kubectl -n kube-system get deployments.apps metrics-server -o jsonpath='{.spec.template.spec.containers[0].image}' && echo
registry.k8s.io/metrics-server/metrics-server:v0.7.2
[root@xuxiaowei-bilibili ~]# 
```

:::
