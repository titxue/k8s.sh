import axios from 'axios'
import semver from 'semver'
import { SocksProxyAgent } from 'socks-proxy-agent'
import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 自动下载所有 kubernetes-sigs/metrics-server deploy yaml

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const folderName = path.resolve(__dirname, '../../mirrors/kubernetes-sigs/metrics-server')
const tagUrl = 'https://api.github.com/repos/kubernetes-sigs/metrics-server/tags'
const downloadUrl = 'https://github.com/kubernetes-sigs/metrics-server/releases/download'
const minimumVersion = 'v0.4.0'
const fileNameList = ['components.yaml', 'high-availability.yaml', 'high-availability-1.21+.yaml']

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
    }

    if (semver.gte(name, minimumVersion)) {
      for (const fileName of fileNameList) {

        if (fileName === 'high-availability.yaml' || fileName === 'high-availability-1.21+.yaml') {
          if (semver.lt(name, 'v0.6.0')) {
            // 小于 v0.6.0 的版本，不提供高可用配置
            continue
          }
        }

        const url = `${downloadUrl}/${name}/${fileName}`
        const dirPath = path.join(folderName, name)
        const filePath = path.join(dirPath, fileName)

        if (!fs.existsSync(dirPath)) {
          fs.mkdirSync(dirPath, {recursive: true})
        }

        console.log(url)

        await axios({url, method: 'GET', responseType: 'stream', ...axiosConfig}).then((response) => {
          const writeStream = fs.createWriteStream(filePath)
          response.data.pipe(writeStream).on('finish', () => {
          })
        }).catch((error) => {
          console.log(error)
        })
      }
    }
  }

  // 倒叙打印
  for (const item of data) {
    const name = item.name

    if (name.includes('-')) {
      continue
    }

    if (semver.gte(name, minimumVersion)) {
      console.log(name)
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
}

main()
