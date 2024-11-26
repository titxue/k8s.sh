# 如何使用 control-plane 角色加入集群？

[[toc]]

## 必要条件 {id=requirements}

::: warning 警告

- [工作节点软件安装配置说明](how-to-join-a-cluster-using-the-node-role.md)
- 需要加入集群的现有 `控制节点`（`控制平面`）初始化时，必须有 `--control-plane-endpoint` 参数
- 无论后续节点加入集群的角色是 `工作节点` 还是 `控制节点`（`控制平面`），都不能进行初始化，安装配置与 `工作节点` 相同，
  区别在于加入集群时的参数不同
- 无论后续节点加入集群的角色是 `工作节点` 还是 `控制节点`（`控制平面`），都不能进行初始化，安装配置与 `工作节点` 相同，
  区别在于加入集群时的参数不同
- 无论后续节点加入集群的角色是 `工作节点` 还是 `控制节点`（`控制平面`），都不能进行初始化，安装配置与 `工作节点` 相同，
  区别在于加入集群时的参数不同
- 相关内容
    - 参数配置：[control-plane-endpoint](../config.md#control-plane-endpoint)
    - 关于 `apiserver-advertise-address` 和 `ControlPlaneEndpoint` 的注意事项：
        1. [官方中文文档](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#considerations-about-apiserver-advertise-address-and-controlplaneendpoint)
        2. [作者国内镜像中文文档](https://kubernetes.xuxiaowei.com.cn/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#considerations-about-apiserver-advertise-address-and-controlplaneendpoint)

:::

### 查看集群是否使用了 --control-plane-endpoint 参数

::: code-group

```shell [命令]
# 返回为空时，说明没有配置
kubectl -n kube-system get cm kubeadm-config -o yaml | grep controlPlaneEndpoint
```

```shell [示例结果]
[root@rocky-8-10 ~]# kubectl -n kube-system get cm kubeadm-config -o yaml | grep controlPlaneEndpoint
    controlPlaneEndpoint: 172.25.25.71:6443
[root@rocky-8-10 ~]# 
```

:::

## 操作步骤

### 创建节点加入集群的命令

::: warning 警告

- 此命令执行的结果直接运行时，`默认角色` 是 `工作节点`
- 此命令执行的结果直接运行时，`默认节点名称` 是 `主机名`，自定义使用参数 `--node-name=xxx`

:::

::: code-group

```shell [命令]
kubeadm token create --print-join-command
```

```shell [示例结果]
[root@rocky-8-10 ~]# kubeadm token create --print-join-command
kubeadm join 172.25.25.71:6443 --token qaub8r.7axpojf3dc0lnf4z --discovery-token-ca-cert-hash sha256:eeb14a64d3d717fcb2bbe9fd8e4e1a456c5d90e6d3b364930af69577a9b03e94 
[root@rocky-8-10 ~]# 
```

:::

### 创建节点加入集群时更新证书的凭证

::: warning 警告

- 无更新证书的凭证，无法将加入集群的节点设置为`控制节点`（`控制平面`）
    - 凭证长度为 64

:::

::: code-group

```shell [命令]
kubeadm init phase upload-certs --upload-certs
```

```shell [示例结果]
[root@rocky-8-10 ~]# kubeadm init phase upload-certs --upload-certs
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
11f522caf08648c506f5509fd8a03470ed762e13802584057c859f6d42a0a14f
[root@rocky-8-10 ~]# 
```

:::

### 使用 control-plane 角色加入集群

::: warning 警告

- 使用 `kubeadm token create --print-join-command` 生成的命令
    1. 拼接 `--control-plane`
    2. 拼接参数名 `--certificate-key`，参数值是 `kubeadm init phase upload-certs --upload-certs` 返回的 `64` 位凭证
- 如果未指定加入集群的新节点名称 `--node-name=xxx` 参数，将使用 `默认节点名称`，`默认节点名称` 是 `主机名`

:::

::: code-group

```shell [命令]
kubeadm join 172.25.25.71:6443 --node-name=k8s-2 --control-plane --certificate-key 11f522caf08648c506f5509fd8a03470ed762e13802584057c859f6d42a0a14f --token qaub8r.7axpojf3dc0lnf4z --discovery-token-ca-cert-hash sha256:eeb14a64d3d717fcb2bbe9fd8e4e1a456c5d90e6d3b364930af69577a9b03e94 
```

```shell [示例结果]
[root@rocky-9-4 ~]# kubeadm join 172.25.25.71:6443 --node-name=k8s-2 --control-plane --certificate-key 11f522caf08648c506f5509fd8a03470ed762e13802584057c859f6d42a0a14f --token qaub8r.7axpojf3dc0lnf4z --discovery-token-ca-cert-hash sha256:eeb14a64d3d717fcb2bbe9fd8e4e1a456c5d90e6d3b364930af69577a9b03e94 
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "k8s-2" could not be reached
	[WARNING Hostname]: hostname "k8s-2": lookup k8s-2 on 114.114.114.114:53: no such host
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W1116 21:59:29.359229    1266 checks.go:846] detected that the sandbox image "registry.aliyuncs.com/google_containers/pause:3.8" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.aliyuncs.com/google_containers/pause:3.10" as the CRI sandbox image.
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[download-certs] Saving the certificates to the folder: "/etc/kubernetes/pki"
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-2 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.25.25.72 172.25.25.71]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-2 localhost] and IPs [172.25.25.72 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-2 localhost] and IPs [172.25.25.72 127.0.0.1 ::1]
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[check-etcd] Checking that the etcd cluster is healthy
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 1.001502763s
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap
[etcd] Announced new etcd member joining to the existing etcd cluster
[etcd] Creating static Pod manifest for "etcd"
{"level":"warn","ts":"2024-11-16T21:59:32.991526+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:33.492057+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:33.991657+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:34.491999+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:34.991782+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:35.492347+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:35.992644+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:36.492357+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:36.992123+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:37.492128+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:37.992088+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
{"level":"warn","ts":"2024-11-16T21:59:38.492479+0800","logger":"etcd-client","caller":"v3@v3.5.14/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0001403c0/172.25.25.71:2379","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
[etcd] Waiting for the new etcd member to join the cluster. This can take up to 40s
[mark-control-plane] Marking the node k8s-2 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-2 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.

[root@rocky-9-4 ~]# 
```

:::

### 在新加入的控制节点增加配置，控制集群

::: code-group

```shell [使用环境变量模式]
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile
source /etc/profile
```

```shell [使用当前用户配置文件模式]
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

:::

### 查看现有集群的节点

::: warning 警告

- 可以看到，节点 1、2 的 `角色` 均是 `control-plane`，即：`控制节点`（`控制平面`），说明 `配置正确`
- 可以看到，节点 1、2 的 `状态` 均是 正常，说明 `集群正常`

:::

::: code-group

```shell [在控制节点 1 上查看]
[root@rocky-8-10 ~]# kubectl get node -o wide
NAME    STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                            KERNEL-VERSION                 CONTAINER-RUNTIME
k8s-1   Ready    control-plane   8m58s   v1.31.1   172.25.25.71   <none>        Rocky Linux 8.10 (Green Obsidian)   4.18.0-553.el8_10.x86_64       containerd://1.6.32
k8s-2   Ready    control-plane   5m46s   v1.31.1   172.25.25.72   <none>        Rocky Linux 9.4 (Blue Onyx)         5.14.0-427.13.1.el9_4.x86_64   containerd://1.7.23
[root@rocky-8-10 ~]# 
```

```shell [在控制节点 2 上查看]
[root@rocky-9-4 ~]# kubectl get node -o wide
NAME    STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                            KERNEL-VERSION                 CONTAINER-RUNTIME
k8s-1   Ready    control-plane   9m19s   v1.31.1   172.25.25.71   <none>        Rocky Linux 8.10 (Green Obsidian)   4.18.0-553.el8_10.x86_64       containerd://1.6.32
k8s-2   Ready    control-plane   6m7s    v1.31.1   172.25.25.72   <none>        Rocky Linux 9.4 (Blue Onyx)         5.14.0-427.13.1.el9_4.x86_64   containerd://1.7.23
[root@rocky-9-4 ~]# 
```

:::

### 查看现有集群的容器

::: code-group

```shell [在控制节点 1 上查看]
[root@rocky-8-10 ~]# kubectl get pod -o wide -A
NAMESPACE       NAME                                        READY   STATUS      RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
ingress-nginx   ingress-nginx-admission-create-vjwwl        0/1     Completed   0          9m46s   172.16.231.193   k8s-1   <none>           <none>
ingress-nginx   ingress-nginx-admission-patch-jqv9r         0/1     Completed   0          9m46s   172.16.231.194   k8s-1   <none>           <none>
ingress-nginx   ingress-nginx-controller-59ddcfdbb7-vhldv   1/1     Running     0          9m46s   172.25.25.71     k8s-1   <none>           <none>
kube-system     calico-kube-controllers-d4647f8d6-gvq22     1/1     Running     0          9m53s   172.16.231.196   k8s-1   <none>           <none>
kube-system     calico-node-p2nrz                           1/1     Running     0          9m54s   172.25.25.71     k8s-1   <none>           <none>
kube-system     calico-node-q9l4m                           1/1     Running     0          6m49s   172.25.25.72     k8s-2   <none>           <none>
kube-system     coredns-855c4dd65d-c76qd                    1/1     Running     0          9m53s   172.16.231.197   k8s-1   <none>           <none>
kube-system     coredns-855c4dd65d-hx9sx                    1/1     Running     0          9m53s   172.16.231.198   k8s-1   <none>           <none>
kube-system     etcd-k8s-1                                  1/1     Running     2          9m59s   172.25.25.71     k8s-1   <none>           <none>
kube-system     etcd-k8s-2                                  1/1     Running     0          6m44s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-apiserver-k8s-1                        1/1     Running     2          9m59s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-apiserver-k8s-2                        1/1     Running     0          6m44s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-controller-manager-k8s-1               1/1     Running     2          9m59s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-controller-manager-k8s-2               1/1     Running     0          6m44s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-proxy-bjk7q                            1/1     Running     0          6m49s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-proxy-vm8g7                            1/1     Running     0          9m54s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-scheduler-k8s-1                        1/1     Running     2          9m59s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-scheduler-k8s-2                        1/1     Running     0          6m44s   172.25.25.72     k8s-2   <none>           <none>
kube-system     metrics-server-7689864f79-clx9k             1/1     Running     0          9m46s   172.16.231.195   k8s-1   <none>           <none>
[root@rocky-8-10 ~]# 
```

```shell [在控制节点 2 上查看]
[root@rocky-9-4 ~]# kubectl get pod -o wide -A
NAMESPACE       NAME                                        READY   STATUS      RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
ingress-nginx   ingress-nginx-admission-create-vjwwl        0/1     Completed   0          9m32s   172.16.231.193   k8s-1   <none>           <none>
ingress-nginx   ingress-nginx-admission-patch-jqv9r         0/1     Completed   0          9m32s   172.16.231.194   k8s-1   <none>           <none>
ingress-nginx   ingress-nginx-controller-59ddcfdbb7-vhldv   1/1     Running     0          9m32s   172.25.25.71     k8s-1   <none>           <none>
kube-system     calico-kube-controllers-d4647f8d6-gvq22     1/1     Running     0          9m39s   172.16.231.196   k8s-1   <none>           <none>
kube-system     calico-node-p2nrz                           1/1     Running     0          9m40s   172.25.25.71     k8s-1   <none>           <none>
kube-system     calico-node-q9l4m                           1/1     Running     0          6m35s   172.25.25.72     k8s-2   <none>           <none>
kube-system     coredns-855c4dd65d-c76qd                    1/1     Running     0          9m39s   172.16.231.197   k8s-1   <none>           <none>
kube-system     coredns-855c4dd65d-hx9sx                    1/1     Running     0          9m39s   172.16.231.198   k8s-1   <none>           <none>
kube-system     etcd-k8s-1                                  1/1     Running     2          9m45s   172.25.25.71     k8s-1   <none>           <none>
kube-system     etcd-k8s-2                                  1/1     Running     0          6m30s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-apiserver-k8s-1                        1/1     Running     2          9m45s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-apiserver-k8s-2                        1/1     Running     0          6m30s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-controller-manager-k8s-1               1/1     Running     2          9m45s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-controller-manager-k8s-2               1/1     Running     0          6m30s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-proxy-bjk7q                            1/1     Running     0          6m35s   172.25.25.72     k8s-2   <none>           <none>
kube-system     kube-proxy-vm8g7                            1/1     Running     0          9m40s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-scheduler-k8s-1                        1/1     Running     2          9m45s   172.25.25.71     k8s-1   <none>           <none>
kube-system     kube-scheduler-k8s-2                        1/1     Running     0          6m30s   172.25.25.72     k8s-2   <none>           <none>
kube-system     metrics-server-7689864f79-clx9k             1/1     Running     0          9m32s   172.16.231.195   k8s-1   <none>           <none>
[root@rocky-9-4 ~]# 
```

:::
