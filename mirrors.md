# 镜像文件

[[toc]]

### kubernetes/dashboard

<el-select v-model="dashboard" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in dashboardOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="dashboard-md"></div>

### kubernetes/ingress-nginx

<el-select v-model="ingressNginx" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in ingressNginxOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<el-select v-model="ingressNginxFileName" size="large" style="width: 328px; margin-top: 20px;">
    <el-option v-for="item in ingressNginxFileNameOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="ingress-nginx-md"></div>

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

## prometheus-operator/kube-prometheus

<el-select v-model="kubePrometheus" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in kubePrometheusOptions" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="kube-prometheus-md"></div>

<script lang="ts" setup>
import { ref, onMounted, watch } from 'vue'
import markdownit from 'markdown-it'
import { ElSelect, ElOption } from 'element-plus'

import 'element-plus/dist/index.css'

const md = markdownit()

const dashboard = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/dashboard')
const ingressNginx = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/ingress-nginx')
const ingressNginxFileName = ref('deploy/static/provider/cloud/deploy.yaml')
const metricsServer = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes-sigs/metrics-server')
const calico = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/projectcalico/calico')
const kubePrometheus = ref('https://k8s-sh.xuxiaowei.com.cn/mirrors/prometheus-operator/kube-prometheus')

const dashboardOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/dashboard',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/2.0.0/mirrors/kubernetes/dashboard',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/2.0.0/mirrors/kubernetes/dashboard',
    label: 'gitee.com',
  },
  {
    value: 'https://raw.githubusercontent.com/kubernetes/dashboard/refs/tags',
    label: 'github.com',
  }
]

const ingressNginxOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes/ingress-nginx',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/2.0.0/mirrors/kubernetes/ingress-nginx',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/2.0.0/mirrors/kubernetes/ingress-nginx',
    label: 'gitee.com',
  },
  {
    value: 'https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags',
    label: 'github.com',
  }
]

const ingressNginxFileNameOptions = [
  {
    value: 'deploy/static/provider/aws/nlb-with-tls-termination/deploy.yaml',
    label: 'deploy/static/provider/aws/nlb-with-tls-termination/deploy.yaml',
  },
  {
    value: 'deploy/static/provider/aws/deploy.yaml',
    label: 'deploy/static/provider/aws/deploy.yaml',
  },
  {
    value: 'deploy/static/provider/baremetal/deploy.yaml',
    label: 'deploy/static/provider/baremetal/deploy.yaml',
  },
  {
    value: 'deploy/static/provider/cloud/deploy.yaml',
    label: 'deploy/static/provider/cloud/deploy.yaml',
  },
  {
    value: 'deploy/static/provider/do/deploy.yaml',
    label: 'deploy/static/provider/do/deploy.yaml',
  },
  {
    value: 'deploy/static/provider/exoscale/deploy.yaml',
    label: 'deploy/static/provider/exoscale/deploy.yaml',
  },
  {
    value: 'deploy/static/provider/scw/deploy.yaml',
    label: 'deploy/static/provider/scw/deploy.yaml',
  },
]

const metricsServerOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/kubernetes-sigs/metrics-server',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/2.0.0/mirrors/kubernetes-sigs/metrics-server',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/2.0.0/mirrors/kubernetes-sigs/metrics-server',
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
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/2.0.0/mirrors/projectcalico/calico',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/2.0.0/mirrors/projectcalico/calico',
    label: 'gitee.com',
  },
  {
    value: 'https://raw.githubusercontent.com/projectcalico/calico/refs/tags',
    label: 'github.com',
  }
]

const kubePrometheusOptions = [
  {
    value: 'https://k8s-sh.xuxiaowei.com.cn/mirrors/prometheus-operator/kube-prometheus',
    label: 'k8s-sh.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw/2.0.0/mirrors/prometheus-operator/kube-prometheus',
    label: 'gitlab.xuxiaowei.com.cn',
  },
  {
    value: 'https://gitee.com/xuxiaowei-com-cn/k8s.sh/raw/2.0.0/mirrors/prometheus-operator/kube-prometheus',
    label: 'gitee.com',
  },
  {
    value: 'https://github.com/prometheus-operator/kube-prometheus/archive/refs/tags/',
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

  const ingressNginxMdResult = md.render(`
| 版本                 | ${ingressNginxFileName.value}                                                                           |
|--------------------|---------------------------------------------------------------------------------------------------------|
| controller-v1.11.3 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.11.3/${ingressNginxFileName.value}) |
| controller-v1.11.2 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.11.2/${ingressNginxFileName.value}) |
| controller-v1.11.1 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.11.1/${ingressNginxFileName.value}) |
| controller-v1.11.0 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.11.0/${ingressNginxFileName.value}) |
| controller-v1.10.5 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.10.5/${ingressNginxFileName.value}) |
| controller-v1.10.4 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.10.4/${ingressNginxFileName.value}) |
| controller-v1.10.3 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.10.3/${ingressNginxFileName.value}) |
| controller-v1.10.2 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.10.2/${ingressNginxFileName.value}) |
| controller-v1.10.1 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.10.1/${ingressNginxFileName.value}) |
| controller-v1.10.0 | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.10.0/${ingressNginxFileName.value}) |
| controller-v1.9.6  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.9.6/${ingressNginxFileName.value})  |
| controller-v1.9.5  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.9.5/${ingressNginxFileName.value})  |
| controller-v1.9.4  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.9.4/${ingressNginxFileName.value})  |
| controller-v1.9.3  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.9.3/${ingressNginxFileName.value})  |
| controller-v1.9.1  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.9.1/${ingressNginxFileName.value})  |
| controller-v1.9.0  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.9.0/${ingressNginxFileName.value})  |
| controller-v1.8.5  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.8.5/${ingressNginxFileName.value})  |
| controller-v1.8.4  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.8.4/${ingressNginxFileName.value})  |
| controller-v1.8.2  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.8.2/${ingressNginxFileName.value})  |
| controller-v1.8.1  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.8.1/${ingressNginxFileName.value})  |
| controller-v1.8.0  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.8.0/${ingressNginxFileName.value})  |
| controller-v1.7.1  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.7.1/${ingressNginxFileName.value})  |
| controller-v1.7.0  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.7.0/${ingressNginxFileName.value})  |
| controller-v1.6.4  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.6.4/${ingressNginxFileName.value})  |
| controller-v1.6.3  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.6.3/${ingressNginxFileName.value})  |
| controller-v1.6.2  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.6.2/${ingressNginxFileName.value})  |
| controller-v1.6.1  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.6.1/${ingressNginxFileName.value})  |
| controller-v1.6.0  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.6.0/${ingressNginxFileName.value})  |
| controller-v1.5.2  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.5.2/${ingressNginxFileName.value})  |
| controller-v1.5.1  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.5.1/${ingressNginxFileName.value})  |
| controller-v1.4.0  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.4.0/${ingressNginxFileName.value})  |
| controller-v1.3.1  | [${ingressNginxFileName.value}](${ingressNginx.value}/controller-v1.3.1/${ingressNginxFileName.value})  |
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

  const kubePrometheusMdResult = md.render(`
| 版本      | kube-prometheus.tar.gz                                                                         |
|---------|------------------------------------------------------------------------------------------------|
| v0.14.0 | [kube-prometheus-0.14.0.tar.gz](${kubePrometheus.value}/v0.14.0/kube-prometheus-0.14.0.tar.gz) |
| v0.13.0 | [kube-prometheus-0.13.0.tar.gz](${kubePrometheus.value}/v0.13.0/kube-prometheus-0.13.0.tar.gz) |
| v0.12.0 | [kube-prometheus-0.12.0.tar.gz](${kubePrometheus.value}/v0.12.0/kube-prometheus-0.12.0.tar.gz) |
| v0.11.0 | [kube-prometheus-0.11.0.tar.gz](${kubePrometheus.value}/v0.11.0/kube-prometheus-0.11.0.tar.gz) |
  `)

  document.getElementById('dashboard-md').innerHTML = dashboardMdResult
  document.getElementById('ingress-nginx-md').innerHTML = ingressNginxMdResult
  document.getElementById('metrics-server-md').innerHTML = metricsServerMdResult
  document.getElementById('calico-md').innerHTML = calicoMdResult
  document.getElementById('kube-prometheus-md').innerHTML = kubePrometheusMdResult
}

onMounted(async () => {
  command()
})

watch(() => [ dashboard.value, ingressNginx.value, ingressNginxFileName.value, metricsServer.value, calico.value, kubePrometheus.value ], () => {
  command()
})
</script>