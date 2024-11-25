import axios from 'axios'
import { SocksProxyAgent } from 'socks-proxy-agent'
import { imageInfo, sleep } from './common.mjs'
import https from 'https'

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 用于自动创建仓库分支，根据仓库分支可自动同步镜像
const gitlabToken = process.env.GITLAB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const tagUrl = 'https://api.github.com/repos/Kong/kong/tags'
const ref = 'kong/3.6'
// https://gitlab.xuxiaowei.com.cn/hub.docker.com/github.com/kubernetes/dashboard 项目 ID: 347
const gitlabRepositoryBranchesUrl = 'https://gitlab.xuxiaowei.com.cn/api/v4/projects/347/repository/branches'

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
    const name = item.name

    if (name.includes('-')) {
      continue
    } else if (name.includes('rc')) {
      continue
    }

    images.add(`kong:${name}`)

    try {
      await imageInfo('registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kong', name)
      console.log(`已存在镜像 registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kong:${name}`)
    } catch {
      console.log(`缺少 registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kong:${name} 镜像，准备创建分支 kong/${name}`)
      if (gitlabToken) {
        await sleep(5_000)
        await axios.post(`${gitlabRepositoryBranchesUrl}?ref=${ref}&branch=kong/${name}`, {}, {
          headers: {
            'PRIVATE-TOKEN': gitlabToken,
          }, httpsAgent: new https.Agent({
            rejectUnauthorized: false
          })
        }).then((resp) => {
          console.log(`分支 kong/${name} 已创建完成`, resp.data)
        }).catch((error) => {
          if (error.status === 400) {
            console.log(`创建分支 kong/${name}`, error.response.data)
          } else if (error.status === 401) {
            console.log(`创建分支 kong/${name}`, error.response.data)
          } else {
            console.log(error)
          }
        })
      } else {
        console.log(`缺少 GitLab Token，不创建分支 kong/${name}`)
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
