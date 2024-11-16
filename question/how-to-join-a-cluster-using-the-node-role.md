# 如何使用 node 角色加入集群？

[[toc]]

## <font color="unset">控制节点</font> 与 <font color="unset">工作节点</font> 在 <font color="unset">环境准备</font> 的区别

- `工作节点` 与 `控制节点` 唯一的区别在于，`控制节点` 是 `初始化集群`，`工作节点` 是 `加入集群`
    1. 言外之意就是：`工作节点` 的安装与配置与 `控制节点` 初始化前一模一样

- 是否支持使用不同的操作系统
    1. 理论上没有问题，下方演示的就是使用两种不同的系统，但还是建议使用相同的系统

## 在 <font color="unset">控制节点</font> 创建 <font color="unset">工作节点</font> 使用 <font color="unset">加入集群命令</font>

::: code-group

```shell [命令]
kubeadm token create --print-join-command
```

```shell [示例结果]
[root@xuxiaowei-k8s-1 ~]# kubeadm token create --print-join-command
kubeadm join 172.25.25.71:6443 --token lubbqe.jy6prtkng5nxv9p8 --discovery-token-ca-cert-hash sha256:3e7a30fe1b93dfc97f26cffb7d347573fa2ccecd9fdddb85c937a1d711b58e70 
[root@xuxiaowei-k8s-1 ~]#
```

:::

## 在 <font color="unset">工作节点</font> 使用 <font color="unset">加入集群命令</font>

::: warning 警告

- 如果 `工作节点` 曾经

:::

::: code-group

```shell [使用当前主机名作为集群节点名称]
kubeadm join 172.25.25.71:6443 --token lubbqe.jy6prtkng5nxv9p8 --discovery-token-ca-cert-hash sha256:3e7a30fe1b93dfc97f26cffb7d347573fa2ccecd9fdddb85c937a1d711b58e70 
```

```shell [自定义名称作为集群节点名称]
kubeadm join 172.25.25.71:6443 --node-name=k8s-2 --token lubbqe.jy6prtkng5nxv9p8 --discovery-token-ca-cert-hash sha256:3e7a30fe1b93dfc97f26cffb7d347573fa2ccecd9fdddb85c937a1d711b58e70 
```

```shell [加入集群示例]
[root@xuxiaowei-k8s-2 ~]# kubeadm join 172.25.25.71:6443 --node-name=k8s-2 --token lubbqe.jy6prtkng5nxv9p8 --discovery-token-ca-cert-hash sha256:3e7a30fe1b93dfc97f26cffb7d347573fa2ccecd9fdddb85c937a1d711b58e70 
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "k8s-2" could not be reached
	[WARNING Hostname]: hostname "k8s-2": lookup k8s-2 on 114.114.114.114:53: no such host
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 1.001575783s
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

[root@xuxiaowei-k8s-2 ~]# 
```

:::

## 在 <font color="unset">控制节点</font> 查看集群信息

- 等待几分钟后，工作节点才能加入集群成功

::: code-group

```shell [查看节点]
[root@xuxiaowei-k8s-1 ~]# kubectl get node -o wide
NAME    STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                            KERNEL-VERSION                 CONTAINER-RUNTIME
k8s-1   Ready    control-plane   3m37s   v1.31.1   172.25.25.71   <none>        Rocky Linux 8.10 (Green Obsidian)   4.18.0-553.el8_10.x86_64       containerd://1.6.32
k8s-2   Ready    <none>          73s     v1.31.1   172.25.25.72   <none>        Rocky Linux 9.4 (Blue Onyx)         5.14.0-427.13.1.el9_4.x86_64   containerd://1.7.23
[root@xuxiaowei-k8s-1 ~]# kubectl top node
NAME    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-1   154m         3%     1698Mi          47%       
k8s-2   53m          1%     412Mi           11%       
[root@xuxiaowei-k8s-1 ~]# 
```

:::

::: code-group

```shell [查看节点容器]
[root@xuxiaowei-k8s-1 ~]# kubectl get pod -o wide -A
NAMESPACE       NAME                                        READY   STATUS      RESTARTS   AGE     IP                NODE    NOMINATED NODE   READINESS GATES
ingress-nginx   ingress-nginx-admission-create-stznm        0/1     Completed   0          3m20s   192.168.231.193   k8s-1   <none>           <none>
ingress-nginx   ingress-nginx-admission-patch-9gdj8         0/1     Completed   0          3m20s   192.168.231.198   k8s-1   <none>           <none>
ingress-nginx   ingress-nginx-controller-59ddcfdbb7-w84ng   1/1     Running     0          3m19s   172.25.25.71      k8s-1   <none>           <none>
kube-system     calico-kube-controllers-d4647f8d6-x6f5j     1/1     Running     0          3m31s   192.168.231.197   k8s-1   <none>           <none>
kube-system     calico-node-hj94c                           1/1     Running     0          3m31s   172.25.25.71      k8s-1   <none>           <none>
kube-system     calico-node-ntzx8                           1/1     Running     0          75s     172.25.25.72      k8s-2   <none>           <none>
kube-system     coredns-855c4dd65d-6sv87                    1/1     Running     0          3m31s   192.168.231.194   k8s-1   <none>           <none>
kube-system     coredns-855c4dd65d-c9cjr                    1/1     Running     0          3m31s   192.168.231.195   k8s-1   <none>           <none>
kube-system     etcd-k8s-1                                  1/1     Running     0          3m37s   172.25.25.71      k8s-1   <none>           <none>
kube-system     kube-apiserver-k8s-1                        1/1     Running     0          3m38s   172.25.25.71      k8s-1   <none>           <none>
kube-system     kube-controller-manager-k8s-1               1/1     Running     0          3m37s   172.25.25.71      k8s-1   <none>           <none>
kube-system     kube-proxy-76vb9                            1/1     Running     0          75s     172.25.25.72      k8s-2   <none>           <none>
kube-system     kube-proxy-tflvh                            1/1     Running     0          3m31s   172.25.25.71      k8s-1   <none>           <none>
kube-system     kube-scheduler-k8s-1                        1/1     Running     0          3m37s   172.25.25.71      k8s-1   <none>           <none>
kube-system     metrics-server-7689864f79-fpq8z             1/1     Running     0          3m19s   192.168.231.196   k8s-1   <none>           <none>
[root@xuxiaowei-k8s-1 ~]# 
```

:::
