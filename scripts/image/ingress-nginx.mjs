import axios from 'axios'
import semver from 'semver'
import { SocksProxyAgent } from 'socks-proxy-agent'
import { imageInfo, sleep } from './common.mjs'
import https from 'https'

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 用于自动创建仓库分支，根据仓库分支可自动同步镜像
const gitlabToken = process.env.GITLAB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const tagUrl = 'https://api.github.com/repos/kubernetes/ingress-nginx/tags'
const yamlUrl = 'https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags/controller-'
const regex = /registry.k8s.io\/ingress-nginx\/kube-webhook-certgen:([^:]+)(?=@)/;
const ref = 'registry.k8s.io/ingress-nginx/controller/v1.3.1'
// https://gitlab.xuxiaowei.com.cn/hub.docker.com/github.com/kubernetes/ingress-nginx 项目 ID: 230
const gitlabRepositoryBranchesUrl = 'https://gitlab.xuxiaowei.com.cn/api/v4/projects/230/repository/branches'
const minimumVersion = 'v1.3.1'
const sourceImages = [
  'registry.k8s.io/ingress-nginx/controller',
]
const targetImages = [
  'registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-controller',
]

const images = new Set();

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
    let name = item.name

    if (name.includes('beta')) {
      continue
    }
    if (!name.includes('controller-')) {
      continue
    }

    name = name.replace('controller-', '')

    if (semver.gte(name, minimumVersion)) {
      for (let i = 0; i < targetImages.length; i++) {

        const image = targetImages[i]

        images.add(`${image}:${name}`)

        try {
          await imageInfo(image, name)
          console.log(`已存在镜像 ${image}:${name}`)
        } catch {
          console.log(`缺少 ${image}:${name} 镜像，准备创建分支 ${sourceImages[i]}/${name}`)
          if (gitlabToken) {
            await sleep(5_000)
            await axios.post(`${gitlabRepositoryBranchesUrl}?ref=${ref}&branch=${sourceImages[i]}/${name}`, {}, {
              headers: {
                'PRIVATE-TOKEN': gitlabToken,
              },
              httpsAgent: new https.Agent({
                rejectUnauthorized: false
              })
            }).then((resp) => {
              console.log(`分支 ${sourceImages[i]}/${name} 已创建完成`, resp.data)
            }).catch((error) => {
              if (error.status === 400) {
                console.log(`创建分支 ${sourceImages[i]}/${name}`, error.response.data)
              } else if (error.status === 401) {
                console.log(`创建分支 ${sourceImages[i]}/${name}`, error.response.data)
              } else {
                console.log(error)
              }
            })
          } else {
            console.log(`缺少 GitLab Token，不创建分支 ${sourceImages[i]}/${name}`)
          }
        }

        await axios.get(`${yamlUrl}${name}/deploy/static/provider/cloud/deploy.yaml`, axiosConfig).then(async (resp) => {
          const match = resp.data.match(regex)
          if (match) {
            const kubeWebhookCertgenImage = match[0]
            const split = kubeWebhookCertgenImage.split(':')

            try {
              await imageInfo('registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen', split[1])
              console.log(`已存在镜像 registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen:${split[1]}`)
            } catch {
              console.log(`缺少 registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/ingress-nginx-kube-webhook-certgen:${split[1]} 镜像`)
              if (gitlabToken) {
                await sleep(5_000)
                await axios.post(`${gitlabRepositoryBranchesUrl}registry.k8s.io/ingress-nginx/kube-webhook-certgen/${split[1]}`, {}, {
                  headers: {
                    'PRIVATE-TOKEN': gitlabToken,
                  },
                  httpsAgent: new https.Agent({
                    rejectUnauthorized: false
                  })
                }).then((resp) => {
                  console.log(`分支 registry.k8s.io/ingress-nginx/kube-webhook-certgen/${split[1]} 已创建完成`, resp.data)
                }).catch((error) => {
                  if (error.status === 400) {
                    console.log(`创建分支 registry.k8s.io/ingress-nginx/kube-webhook-certgen/${split[1]}`, error.response.data)
                  } else if (error.status === 401) {
                    console.log(`创建分支 registry.k8s.io/ingress-nginx/kube-webhook-certgen/${split[1]}`, error.response.data)
                  } else {
                    console.log(error)
                  }
                })
              } else {
                console.log('缺少 GitLab Token，不创建分支')
              }
            }

          }
        }).catch((error) => {
          console.log('获取 yaml 异常', error)
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
