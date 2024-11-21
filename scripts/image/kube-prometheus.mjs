import axios from 'axios'
import semver from 'semver'
import { SocksProxyAgent } from 'socks-proxy-agent'
import yaml from 'js-yaml'
import { imageInfo, sleep } from './common.mjs'
import https from 'https'

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 用于自动创建仓库分支，根据仓库分支可自动同步镜像
const gitlabToken = process.env.GITLAB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const tagUrl = 'https://api.github.com/repos/prometheus-operator/kube-prometheus/tags'
const rawUrl = 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags'
const ref = 'registry.k8s.io/kube-state-metrics/kube-state-metrics/v2.13.0'
// https://gitlab.xuxiaowei.com.cn/hub.docker.com/github.com/prometheus-operator/kube-prometheus 项目 ID: 348
const gitlabRepositoryBranchesUrl = 'https://gitlab.xuxiaowei.com.cn/api/v4/projects/348/repository/branches'
const minimumVersion = 'v0.11.0'
const manifests = [
  'manifests/prometheusOperator-deployment.yaml',
  'manifests/blackboxExporter-deployment.yaml',
  'manifests/alertmanager-alertmanager.yaml',
  'manifests/kubeStateMetrics-deployment.yaml',
  'manifests/prometheus-prometheus.yaml',
  'manifests/prometheusAdapter-deployment.yaml',
  'manifests/grafana-deployment.yaml',
  'manifests/nodeExporter-daemonset.yaml',
]

const images = new Set();

async function createBranches(gitlabToken, gitlabRepositoryBranchesUrl, to) {
  if (gitlabToken) {
    await sleep(5_000)
    await axios.post(`${gitlabRepositoryBranchesUrl}?ref=${ref}&branch=${to}`, {}, {
      headers: {
        'PRIVATE-TOKEN': gitlabToken,
      },
      httpsAgent: new https.Agent({
        rejectUnauthorized: false
      })
    }).then((resp) => {
      console.log(`分支 ${to} 已创建完成`, resp.data)
    }).catch((error) => {
      if (error.status === 400) {
        console.log(`创建分支 ${to}`, error.response.data)
      } else if (error.status === 401) {
        console.log(`创建分支 ${to}`, error.response.data)
      } else {
        console.log(error)
      }
    })
  } else {
    console.log(`缺少 GitLab Token，不创建分支 ${to}`)
  }
}

async function tags(page, per_page) {

  const headers = {}
  if (githubToken) {
    headers.Authorization = `token ${githubToken}`
  }

  const axiosConfig = {headers}
  if (proxyUrl) {
    const agent = new SocksProxyAgent(proxyUrl)
    axiosConfig.httpAgent = agent
    axiosConfig.httpsAgent = agent
  }

  const response = await axios.get(`${tagUrl}?page=${page}&per_page=${per_page}`, axiosConfig)
  const data = response.data

  for (const item of data) {
    const name = item.name

    if (semver.gte(name, minimumVersion)) {
      for (const manifest of manifests) {
        const manifestsRawUrl = `${rawUrl}/${name}/${manifest}`
        await axios.get(manifestsRawUrl, axiosConfig).then((resp) => {
          const data = yaml.load(resp.data)
          const kind = data.kind
          if (kind === 'Alertmanager' || kind === 'Prometheus') {

            const image = data.spec.image

            images.add(`${image}`)

            const split = image.split(':')
            try {
              imageInfo('registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/' + split[0].split('/')[split[0].split('/').length - 1], split[1])
              console.log(`已存在镜像 ${image}`)
            } catch {
              console.log(`缺少 ${image}:${name} 镜像，准备创建分支 ${image.replace(':', '/')}`)
              createBranches(gitlabToken, gitlabRepositoryBranchesUrl, image.replace(':', '/'))
            }
          } else {
            const containers = data.spec.template.spec.containers
            for (const container of containers) {

              const image = container.image

              images.add(`${image}`)

              const split = image.split(':')
              try {
                imageInfo('registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/' + split[0].split('/')[split[0].split('/').length - 1], split[1])
                console.log(`已存在镜像 ${image}`)
              } catch {
                console.log(`缺少 ${image}:${name} 镜像，准备创建分支 ${image.replace(':', '/')}`)
                createBranches(gitlabToken, gitlabRepositoryBranchesUrl, image.replace(':', '/'))
              }
            }
          }
        }).catch((error) => {
          console.log(error)
        })
      }
    }
  }

  return data.length
}

async function main() {
  let page = 1
  let per_page = 100
  let total = per_page
  do {
    total = await tags(page++, per_page)
  } while (total === per_page)
  console.log(images.size)
}

main()
