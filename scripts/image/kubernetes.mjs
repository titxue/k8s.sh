import axios from 'axios'
import semver from 'semver'
import { SocksProxyAgent } from 'socks-proxy-agent'
import { sleep, imageInfo } from './common.mjs'
import https from 'https'

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 用于自动创建仓库分支，根据仓库分支可自动同步镜像
const gitlabToken = process.env.GITLAB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

let sum = 0

async function tags(page, per_page) {
  const tagUrl = `https://api.github.com/repos/kubernetes/kubernetes/tags?page=${page}&per_page=${per_page}`
  const ref = 'registry.k8s.io/kube-apiserver/v1.24.0'
  // https://gitlab.xuxiaowei.com.cn/hub.docker.com/github.com/kubernetes/kubernetes 项目 ID: 229
  const gitlabRepositoryBranchesUrl = `https://gitlab.xuxiaowei.com.cn/api/v4/projects/229/repository/branches?ref=${ref}&branch=`
  const minimumVersion = 'v1.24.0'
  const k8sImages = [
    'registry.k8s.io/kube-apiserver',
    'registry.k8s.io/kube-controller-manager',
    'registry.k8s.io/kube-proxy',
    'registry.k8s.io/kube-scheduler'
  ]
  const images = [
    'registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-apiserver',
    'registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-controller-manager',
    'registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-proxy',
    'registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kube-scheduler'
  ]

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

  const response = await axios.get(tagUrl, axiosConfig)
  const data = response.data

  for (const item of data) {
    const name = item.name

    if (name.includes('-')) {
      continue
    }

    // 版本号规则（最小长度：7）：v1.24.0
    if (name.length < 7) {
      continue
    }

    if (semver.gte(name, minimumVersion)) {
      for (let i = 0; i < images.length; i++) {

        sum++

        const image = images[i]
        try {
          await imageInfo(image, name)
          console.log(`已存在镜像 ${image}:${name}`)
        } catch (Exception) {
          console.log(`缺少 ${image}:${name} 镜像`)
          if (gitlabToken) {
            await sleep(5_000)
            await axios.post(`${gitlabRepositoryBranchesUrl}${k8sImages[i]}/${name}`, {}, {
              headers: {
                'PRIVATE-TOKEN': gitlabToken,
              },
              httpsAgent: new https.Agent({
                rejectUnauthorized: false
              })
            }).then((resp) => {
              console.log(`分支 ${k8sImages[i]}/${name} 已创建完成`, resp.data)
            }).catch((error) => {
              if (error.status === 400) {
                console.log(`创建分支 ${k8sImages[i]}/${name}`, error.response.data)
              } else if (error.status === 401) {
                console.log(`创建分支 ${k8sImages[i]}/${name}`, error.response.data)
              } else {
                console.log(error)
              }
            })
          } else {
            console.log('缺少 GitLab Token，不创建分支')
          }
        }
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
  console.log(sum)
}

main()
