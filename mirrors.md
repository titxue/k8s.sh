# 镜像文件

[[toc]]

### kubernetes/dashboard

<el-select v-model="dashboard" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in dashboardOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="dashboard-md"></div>

## kubernetes-sigs/metrics-server

<el-select v-model="metricsServer" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in metricsServerOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="metrics-server-md"></div>

## projectcalico/calico

<el-select v-model="calico" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in calicoOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="calico-md"></div>

<script lang="ts" setup>
import { ref, onMounted, watch } from 'vue'
import markdownit from 'markdown-it'
import { ElSelect, ElOption } from 'element-plus'

import 'element-plus/dist/index.css'

const md = markdownit()

const dashboard = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/dashboard')
const metricsServer = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes-sigs/metrics-server')
const calico = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/projectcalico/calico')

const dashboardOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/dashboard',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/SNAPSHOT/2.0.0/mirrors/kubernetes/dashboard',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/SNAPSHOT/2.0.0/mirrors/kubernetes/dashboard',
    label: 'gitee.com',
  },
  {
    value: 'https://raw.githubusercontent.com/kubernetes/dashboard/refs/tags',
    label: 'github.com',
  }
]

const metricsServerOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes-sigs/metrics-server',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/SNAPSHOT/2.0.0/mirrors/kubernetes-sigs/metrics-server',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/SNAPSHOT/2.0.0/mirrors/kubernetes-sigs/metrics-server',
    label: 'gitee.com',
  },
  {
    value: 'https://github.com/kubernetes-sigs/metrics-server/releases/download',
    label: 'github.com',
  }
]

const calicoOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/projectcalico/calico',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/SNAPSHOT/2.0.0/mirrors/projectcalico/calico',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/SNAPSHOT/2.0.0/mirrors/projectcalico/calico',
    label: 'gitee.com',
  },
  {
    value: 'https://raw.githubusercontent.com/projectcalico/calico/refs/tags',
    label: 'github.com',
  }
]

const command = function () {

  const dashboardMdResult = md.render(`
| 版本     | recommended.yaml                                                                    |
|--------|-------------------------------------------------------------------------------------|
| v2.7.0 | [recommended.yaml](${dashboard.value}/v2.7.0/aio/deploy/recommended.yaml) |
| v2.6.1 | [recommended.yaml](${dashboard.value}/v2.6.1/aio/deploy/recommended.yaml) |
| v2.6.0 | [recommended.yaml](${dashboard.value}/v2.6.0/aio/deploy/recommended.yaml) |
  `)

  const metricsServerMdResult = md.render(`
| 版本     | components.yaml                                                  | high-availability-1.21+.yaml                                                               |
|--------|------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| v0.7.2 | [components.yaml](${metricsServer.value}/v0.7.2/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.7.2/high-availability-1.21+.yaml) |
| v0.7.1 | [components.yaml](${metricsServer.value}/v0.7.1/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.7.1/high-availability-1.21+.yaml) |
| v0.7.0 | [components.yaml](${metricsServer.value}/v0.7.0/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.7.0/high-availability-1.21+.yaml) |
| v0.6.4 | [components.yaml](${metricsServer.value}/v0.6.4/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.6.4/high-availability-1.21+.yaml) |
| v0.6.3 | [components.yaml](${metricsServer.value}/v0.6.3/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.6.3/high-availability-1.21+.yaml) |
| v0.6.2 | [components.yaml](${metricsServer.value}/v0.6.2/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.6.2/high-availability-1.21+.yaml) |
| v0.6.1 | [components.yaml](${metricsServer.value}/v0.6.1/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.6.1/high-availability-1.21+.yaml) |
| v0.6.0 | [components.yaml](${metricsServer.value}/v0.6.0/components.yaml) | [high-availability-1.21+.yaml](${metricsServer.value}/v0.6.0/high-availability-1.21+.yaml) |
| v0.5.2 | [components.yaml](${metricsServer.value}/v0.5.2/components.yaml) |                                                                                            |
| v0.5.1 | [components.yaml](${metricsServer.value}/v0.5.1/components.yaml) |                                                                                            |
| v0.5.0 | [components.yaml](${metricsServer.value}/v0.5.0/components.yaml) |                                                                                            |
| v0.4.5 | [components.yaml](${metricsServer.value}/v0.4.5/components.yaml) |                                                                                            |
| v0.4.4 | [components.yaml](${metricsServer.value}/v0.4.4/components.yaml) |                                                                                            |
| v0.4.3 | [components.yaml](${metricsServer.value}/v0.4.3/components.yaml) |                                                                                            |
| v0.4.2 | [components.yaml](${metricsServer.value}/v0.4.2/components.yaml) |                                                                                            |
| v0.4.1 | [components.yaml](${metricsServer.value}/v0.4.1/components.yaml) |                                                                                            |
| v0.4.0 | [components.yaml](${metricsServer.value}/v0.4.0/components.yaml) |                                                                                            |
  `)

  const calicoMdResult = md.render(`
| 版本      | components.yaml                                              |
|---------|--------------------------------------------------------------|
| v3.29.0 | [calico.yaml](${calico.value}/v3.29.0/manifests/calico.yaml) |
| v3.28.2 | [calico.yaml](${calico.value}/v3.28.2/manifests/calico.yaml) |
| v3.28.1 | [calico.yaml](${calico.value}/v3.28.1/manifests/calico.yaml) |
| v3.28.0 | [calico.yaml](${calico.value}/v3.28.0/manifests/calico.yaml) |
| v3.27.4 | [calico.yaml](${calico.value}/v3.27.4/manifests/calico.yaml) |
| v3.27.3 | [calico.yaml](${calico.value}/v3.27.3/manifests/calico.yaml) |
| v3.27.2 | [calico.yaml](${calico.value}/v3.27.2/manifests/calico.yaml) |
| v3.27.1 | [calico.yaml](${calico.value}/v3.27.1/manifests/calico.yaml) |
| v3.24.5 | [calico.yaml](${calico.value}/v3.24.5/manifests/calico.yaml) |
| v3.24.4 | [calico.yaml](${calico.value}/v3.24.4/manifests/calico.yaml) |
| v3.24.3 | [calico.yaml](${calico.value}/v3.24.3/manifests/calico.yaml) |
| v3.24.2 | [calico.yaml](${calico.value}/v3.24.2/manifests/calico.yaml) |
| v3.24.1 | [calico.yaml](${calico.value}/v3.24.1/manifests/calico.yaml) |
| v3.24.0 | [calico.yaml](${calico.value}/v3.24.0/manifests/calico.yaml) |
  `)

  document.getElementById('dashboard-md').innerHTML = dashboardMdResult
  document.getElementById('metrics-server-md').innerHTML = metricsServerMdResult
  document.getElementById('calico-md').innerHTML = calicoMdResult
}

onMounted(async () => {
  command()
})

watch(() => [ dashboard.value, metricsServer.value, calico.value ], () => {
  command()
})
</script>