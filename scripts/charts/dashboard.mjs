import axios from 'axios'
import { SocksProxyAgent } from 'socks-proxy-agent'
import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'
import yaml from 'js-yaml'
import { imageInfo, sleep } from "../image/common.mjs"
import https from "https";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 用于自动创建仓库分支，根据仓库分支可自动同步镜像
const gitlabToken = process.env.GITLAB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const tagUrl = 'https://api.github.com/repos/kubernetes/dashboard/tags'
const ref = 'kubernetesui/dashboard-web/1.6.0'
// https://gitlab.xuxiaowei.com.cn/hub.docker.com/github.com/kubernetes/dashboard 项目 ID: 347
const gitlabRepositoryBranchesUrl = 'https://gitlab.xuxiaowei.com.cn/api/v4/projects/347/repository/branches'
const chartsUrl = 'https://kubernetes.github.io/dashboard/index.yaml'
const downloadUrl = 'https://github.com/kubernetes/dashboard/releases/download'
const mirrorsUrl = 'http://k8s-sh.xuxiaowei.com.cn/charts/kubernetes/dashboard'
const folderName = path.resolve(__dirname, '../../charts/kubernetes/dashboard')
const filePath = path.join(folderName, 'index.yaml')

async function tags(tagUrl, page, per_page) {

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

    if (name.includes('rc')) {
      continue
    } else if (name.includes('alpha')) {
      continue
    } else if (name.includes('beta')) {
      continue
    } else if (name.includes('kubernetes-dashboard-')) {
      continue
    } else if (name.startsWith('v')) {
      continue
    }

    const split = name.split('/')

    try {
      await imageInfo(`registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-${split[0]}`, split[1].substring(1))
      console.log(`已存在镜像 registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-${split[0]}:${split[1].substring(1)}`)
    } catch {
      console.log(`缺少 registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/kubernetesui-dashboard-${split[0]}:${split[1].substring(1)} 镜像，准备创建分支 kubernetesui/dashboard-${split[0]}:${split[1].substring(1)}`)

      if (gitlabToken) {
        await sleep(5_000)
        await axios.post(`${gitlabRepositoryBranchesUrl}?ref=${ref}&branch=kubernetesui/dashboard-${split[0]}/${split[1].substring(1)}`, {}, {
          headers: {
            'PRIVATE-TOKEN': gitlabToken,
          }, httpsAgent: new https.Agent({
            rejectUnauthorized: false
          })
        }).then((resp) => {
          console.log(`分支 kubernetesui/dashboard-${split[0]}/${split[1].substring(1)} 已创建完成`, resp.data)
        }).catch((error) => {
          if (error.status === 400) {
            console.log(`创建分支 kubernetesui/dashboard-${split[0]}/${split[1].substring(1)}`, error.response.data)
          } else if (error.status === 401) {
            console.log(`创建分支 kubernetesui/dashboard-${split[0]}/${split[1].substring(1)}`, error.response.data)
          } else {
            console.log(error)
          }
        })
      } else {
        console.log(`缺少 GitLab Token，不创建分支 kubernetesui/dashboard-${split[0]}/${split[1].substring(1)}`)
      }

    }

  }

  return data.length
}

async function main() {

  const axiosConfig = {}
  if (proxyUrl) {
    const agent = new SocksProxyAgent(proxyUrl)
    axiosConfig.httpAgent = agent
    axiosConfig.httpsAgent = agent
  }

  let page = 1
  let per_page = 100
  let total = per_page
  do {
    total = await tags(tagUrl, page++, per_page)
  } while (total === per_page)

  const dirPath = path.dirname(filePath)

  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, {recursive: true})
  }

  await axios.get(chartsUrl, axiosConfig).then(async (response) => {
    const data = response.data
    const dataJson = yaml.load(data)
    for (const item of dataJson.entries['kubernetes-dashboard']) {
      for (const url of item.urls) {
        if (url.startsWith(downloadUrl)) {

          console.log(url)

          const downloadFileName = url.replace(downloadUrl, folderName)
          const downloadFileDirPath = path.dirname(downloadFileName)
          if (!fs.existsSync(downloadFileDirPath)) {
            fs.mkdirSync(downloadFileDirPath, {recursive: true})
          }

          await axios({url, method: 'GET', responseType: 'stream', ...axiosConfig}).then((response) => {
            const writeStream = fs.createWriteStream(downloadFileName)
            response.data.pipe(writeStream).on('finish', () => {
            })
          }).catch((error) => {
            console.log(error)
          })
        }
      }
    }

    fs.writeFileSync(filePath, data.replaceAll(downloadUrl, mirrorsUrl))

    console.log()
    console.log()
    console.log()
    console.log('| 版本 | 镜像地址 |')
    console.log('|----|------|')
    for (const item of dataJson.entries['kubernetes-dashboard']) {
      for (const url of item.urls) {
        if (url.startsWith(downloadUrl)) {
          console.log(`| ${url.split('/')[7]} | [${url.split('/')[8]}](${url.replaceAll(downloadUrl, mirrorsUrl)}) |`)
        }
      }
    }
  })

}

main()
