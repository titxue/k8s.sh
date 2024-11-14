const axios= require('axios')
const semver= require('semver')
const fs = require('fs')
const path = require('path')
const { SocksProxyAgent } = require('socks-proxy-agent')

// 自动下载所有 projectcalico/calico deploy yaml

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const folderName = path.resolve(__dirname, '../mirrors/projectcalico/calico')

async function tags() {
  const tagUrl = 'https://api.github.com/repos/projectcalico/calico/tags?page=1&per_page=50'
  const downloadUrl = 'https://raw.githubusercontent.com/projectcalico/calico/refs/tags'
  const fileNameList = ['calico.yaml']

  const headers = {}
  if (githubToken) {
    headers.Authorization = `token ${githubToken}`
  }

  const axiosConfig = { headers }
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

    if (semver.gte(name, 'v3.24.0')) {
      for (const fileName of fileNameList) {

        const url = `${downloadUrl}/${name}/manifests/${fileName}`
        const dirPath = path.join(folderName, name, 'manifests')
        const filePath = path.join(dirPath, fileName)

        if (!fs.existsSync(dirPath)) {
          fs.mkdirSync(dirPath, { recursive: true })
        }

        console.log(url)

        axios({ url, method: 'GET', responseType: 'stream', ...axiosConfig }).then((response) => {
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

    if (semver.gte(name, 'v3.24.0')) {
      console.log(name)
    }
  }
}

tags()
