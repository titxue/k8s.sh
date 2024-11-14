# 镜像

## kubernetes-sigs/metrics-server

<el-select v-model="source" size="large" style="width: 240px; margin-top: 20px;">
    <el-option v-for="item in sources" :key="item.value" :label="item.label" :value="item.value" />
</el-select>

<div id="metrics-server-md"></div>

<script lang="ts" setup>
import { ref, onMounted, watch } from 'vue'
import markdownit from 'markdown-it'
import { ElSelect, ElOption } from 'element-plus'

import 'element-plus/dist/index.css'

const md = markdownit()

const source = ref('https://gitlab.xuxiaowei.com.cn/xuxiaowei-com-cn/k8s.sh/-/raw')

const sources = [
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

const command = function () {
  // ${source.value}
  const metricsServerMdResult = md.render(`
| 版本     | components.yaml                                           | high-availability-1.21+.yaml                                                        |
|--------|-----------------------------------------------------------|-------------------------------------------------------------------------------------|
| v0.7.2 | [components.yaml](${source.value}/v0.7.2/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.7.2/high-availability-1.21+.yaml) |
| v0.7.1 | [components.yaml](${source.value}/v0.7.1/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.7.1/high-availability-1.21+.yaml) |
| v0.7.0 | [components.yaml](${source.value}/v0.7.0/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.7.0/high-availability-1.21+.yaml) |
| v0.6.4 | [components.yaml](${source.value}/v0.6.4/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.6.4/high-availability-1.21+.yaml) |
| v0.6.3 | [components.yaml](${source.value}/v0.6.3/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.6.3/high-availability-1.21+.yaml) |
| v0.6.2 | [components.yaml](${source.value}/v0.6.2/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.6.2/high-availability-1.21+.yaml) |
| v0.6.1 | [components.yaml](${source.value}/v0.6.1/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.6.1/high-availability-1.21+.yaml) |
| v0.6.0 | [components.yaml](${source.value}/v0.6.0/components.yaml) | [high-availability-1.21+.yaml](${source.value}/v0.6.0/high-availability-1.21+.yaml) |
| v0.5.2 | [components.yaml](${source.value}/v0.5.2/components.yaml) |                                                                                     |
| v0.5.1 | [components.yaml](${source.value}/v0.5.1/components.yaml) |                                                                                     |
| v0.5.0 | [components.yaml](${source.value}/v0.5.0/components.yaml) |                                                                                     |
| v0.4.5 | [components.yaml](${source.value}/v0.4.5/components.yaml) |                                                                                     |
| v0.4.4 | [components.yaml](${source.value}/v0.4.4/components.yaml) |                                                                                     |
| v0.4.3 | [components.yaml](${source.value}/v0.4.3/components.yaml) |                                                                                     |
| v0.4.2 | [components.yaml](${source.value}/v0.4.2/components.yaml) |                                                                                     |
| v0.4.1 | [components.yaml](${source.value}/v0.4.1/components.yaml) |                                                                                     |
| v0.4.0 | [components.yaml](${source.value}/v0.4.0/components.yaml) |                                                                                     |
  `)

  document.getElementById('metrics-server-md').innerHTML = metricsServerMdResult
}

onMounted(async () => {
  command()
})

watch(() => [ source.value ], () => {
  command()
})
</script>