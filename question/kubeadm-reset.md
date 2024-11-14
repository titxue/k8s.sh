# Kubernetes 重置 {id=kubeadm-reset}

## 使用场景 {id=usage-scenario}

1. `Kubernetes` 安装失败
2. 清空 `Kubernetes` 历史配置及相关数据
3. 重新安装

## 重置步骤 {id=reset-step}

### 运行 kubeadm reset {id=kubeadm-reset-step}

::: warning 警告

1. 删除文件夹 `/var/lib/etcd` 下的文件
2. 删除文件夹 `/etc/kubernetes/manifests`、`/var/lib/kubelet`、`/etc/kubernetes/pki` 下的文件
3. 删除文件 `/etc/kubernetes/admin.conf`、`/etc/kubernetes/super-admin.conf`、`/etc/kubernetes/kubelet.conf`、
   `/etc/kubernetes/bootstrap-kubelet.conf`、`/etc/kubernetes/controller-manager.conf`、`/etc/kubernetes/scheduler.conf`
4. 重置过程，不会删除 `CNI` 配置，需要手动删除 `/etc/cni/net.d` 文件夹
5. 重置过程，不会重置 `iptables` 或 `IPVS` 表
    - 如果需要重置 `iptables`，需要手动执行 `iptables` 命令
6. 重置过程，不会删除 `kubeconfig` 文件，需要手动删除，如：`$HOME/.kube/config` 文件

:::

::: code-group

```shell [运行命令]
# 此步骤执行命令后，需要手动输入 y 进行确认
kubeadm reset
```

```shell [示例日志]
[root@anolis-8-2 ~]# kubeadm reset
[reset] Reading configuration from the cluster...
[reset] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
W1114 20:39:05.119307   96951 preflight.go:56] [reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
[reset] Are you sure you want to proceed? [y/N]: y
[preflight] Running pre-flight checks
[reset] Deleted contents of the etcd data directory: /var/lib/etcd
[reset] Stopping the kubelet service
[reset] Unmounting mounted directories in "/var/lib/kubelet"
W1114 20:39:49.513872   96951 cleanupnode.go:105] [reset] Failed to remove containers: [failed to stop running pod 7976b2614a9579c1ddb275f5b4424b051742b2c6ccad04a99aa598431742ae44: rpc error: code = DeadlineExceeded desc = context deadline exceeded, failed to stop running pod 24beeb48d9da573ddef75cb04a7237a486b14a2c99756870b6562c4d9627aa11: rpc error: code = DeadlineExceeded desc = context deadline exceeded, failed to stop running pod 0e3f5e6ec584a4c24534f719e52e10bd16da0055eb5e711a40d87b1b41d30a19: rpc error: code = DeadlineExceeded desc = context deadline exceeded, failed to stop running pod bf60bbede450945aa51138be709000340df58ffa8d99eaaadef6f2cf07ef31b0: rpc error: code = DeadlineExceeded desc = context deadline exceeded, failed to stop running pod c965d87c2df724e828268e856683a34957d3727a3891a791aed397144f002743: rpc error: code = Unknown desc = failed to destroy network for sandbox "c965d87c2df724e828268e856683a34957d3727a3891a791aed397144f002743": plugin type="calico" failed (delete): error getting ClusterInformation: Get "https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default": dial tcp 10.96.0.1:443: connect: connection refused, failed to stop running pod b936bac6e01f2c041dd89c3131abbc02510d2234b3d3a2517b94265dab90dbb6: rpc error: code = Unknown desc = failed to destroy network for sandbox "b936bac6e01f2c041dd89c3131abbc02510d2234b3d3a2517b94265dab90dbb6": plugin type="calico" failed (delete): error getting ClusterInformation: Get "https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default": dial tcp 10.96.0.1:443: connect: connection refused]
[reset] Deleting contents of directories: [/etc/kubernetes/manifests /var/lib/kubelet /etc/kubernetes/pki]
[reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/super-admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]

The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually by using the "iptables" command.

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
[root@anolis-8-2 ~]#
```

:::

### 删除遗留文件 {id=rm-legacy-file}

```shell [运行命令]
rm /etc/cni/net.d -rf 
```
