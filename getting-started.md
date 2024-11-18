# 快速开始 {id=getting-started}

[[toc]]

## 快速安装 {id=getting-started-install}

::: warning 警告

1. `单机模式`、`集群模式` 会卸载 `旧版 Docker`
    - `旧版 Docker`: `docker.io`
    - `新版 Docker`: `docker-ce`

2. `单机模式`、`集群模式` 会卸载 `containerd`，然后重新安装、配置 `containerd`

3. `单机模式`、`集群模式` 安装完成后，需要运行 `source /etc/profile` 才能控制 `Kubernetes`，
   也可以重新连接 `SSH` 后 控制 `Kubernetes`

4. 在 `控制节点`（`控制平面`）中运行 `kubeadm token create --print-join-command` 命令后，可得到 `工作节点` 加入集群的命令，
   也可以使用脚本参数 `./k8s.sh print-join-command` 生成

:::

### 单机模式 {id=standalone}

::: warning 警告

1. `控制节点`（`控制平面`）会去污，开箱即用

:::

<el-select v-model="source" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in sources" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div class="language-shell vp-adaptive-theme">
  <button title="Copy Code" class="copy"></button><span class="lang">shell</span>
  <div id="standalone-code"></div>
</div>

### 集群模式 {id=cluster}

::: warning 警告

1. `工作节点` 未加入集群时，`Kubernetes` 集群将无法正常使用

:::

<el-select v-model="source" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in sources" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div class="language-shell vp-adaptive-theme">
  <button title="Copy Code" class="copy"></button><span class="lang">shell</span>
  <div id="cluster-code"></div>
</div>

### 工作节点 {id=node}

::: warning 警告

1. `工作节点` 无法独立使用，需要加入集群后才能使用

:::

<el-select v-model="source" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in sources" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div class="language-shell vp-adaptive-theme">
  <button title="Copy Code" class="copy"></button><span class="lang">shell</span>
  <div id="node-code"></div>
</div>

## 参数说明 {id=parameter-description}

- 提供强大的自定参数配置，请阅读：[参数配置](config.md)

<script lang="ts" setup>
import { ref, onMounted, watch } from 'vue'
import markdownit from 'markdown-it'
import { ElSelect, ElOption } from 'element-plus'

import 'element-plus/dist/index.css'

const md = markdownit()

const source = ref('https://k8s-sh.xuxiaowei.com.cn/k8s.sh')

const sources = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/k8s.sh',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/SNAPSHOT/2.0.0/k8s.sh',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/SNAPSHOT/2.0.0/k8s.sh',
    label: 'gitee.com',
  },
  {
    value: 'https://raw.githubusercontent.com/xuxiaowei-com-cn/k8s.sh/refs/heads/SNAPSHOT/2.0.0/k8s.sh',
    label: 'github.com',
  }
]

const command = function () {

  const standaloneResult = md.render(`
    curl -k -o k8s.sh ${source.value}
    chmod +x k8s.sh
    sudo ./k8s.sh standalone
    
    # 等效命令
    # sudo ./k8s.sh swap-off curl ca-certificates firewalld-stop selinux-disabled bash-completion docker-repo containerd-install containerd-config kubernetes-repo kubernetes-install kubernetes-images-pull kubernetes-config kubernetes-init kubernetes-init-node-name=k8s-1 calico-install kubernetes-taint ingress-nginx-install ingress-nginx-host-network metrics-server-install enable-shell-autocompletion print-join-command kubernetes-init-congrats
  `, { lang: 'shell' })

  const clusterResult = md.render(`
    curl -k -o k8s.sh ${source.value}
    chmod +x k8s.sh
    sudo ./k8s.sh cluster
    
    # 等效命令
    # sudo ./k8s.sh swap-off curl ca-certificates firewalld-stop selinux-disabled bash-completion docker-repo containerd-install containerd-config kubernetes-repo kubernetes-install kubernetes-images-pull kubernetes-config kubernetes-init kubernetes-init-node-name=k8s-1 calico-install ingress-nginx-install ingress-nginx-host-network metrics-server-install enable-shell-autocompletion print-join-command kubernetes-init-congrats
  `, { lang: 'shell' })

  const nodeResult = md.render(`
    curl -k -o k8s.sh ${source.value}
    chmod +x k8s.sh
    sudo ./k8s.sh node
    
    # 等效命令
    # sudo ./k8s.sh swap-off curl ca-certificates firewalld-stop selinux-disabled bash-completion docker-repo containerd-install containerd-config kubernetes-repo kubernetes-install kubernetes-images-pull kubernetes-config
  `, { lang: 'shell' })

  document.getElementById('standalone-code').innerHTML = standaloneResult
  document.getElementById('cluster-code').innerHTML = clusterResult
  document.getElementById('node-code').innerHTML = nodeResult
}

onMounted(async () => {
  command()
})

watch(() => [ source.value ], () => {
  command()
})
</script>