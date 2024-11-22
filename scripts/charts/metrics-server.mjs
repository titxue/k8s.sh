import axios from 'axios'
import { SocksProxyAgent } from 'socks-proxy-agent'
import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'
import yaml from 'js-yaml'

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const chartsUrl = 'https://kubernetes-sigs.github.io/metrics-server/index.yaml'
const downloadUrl = 'https://github.com/kubernetes-sigs/metrics-server/releases/download'
const mirrorsUrl = 'http://k8s-sh.xuxiaowei.com.cn/charts/kubernetes-sigs/metrics-server'
const folderName = path.resolve(__dirname, '../../charts/kubernetes-sigs/metrics-server')
const filePath = path.join(folderName, 'index.yaml')

async function main() {

  const axiosConfig = {}
  if (proxyUrl) {
    const agent = new SocksProxyAgent(proxyUrl)
    axiosConfig.httpAgent = agent
    axiosConfig.httpsAgent = agent
  }

  const dirPath = path.dirname(filePath)

  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, {recursive: true})
  }

  await axios.get(chartsUrl, axiosConfig).then(async (response) => {
    const data = response.data
    const dataJson = yaml.load(data)
    for (const item of dataJson.entries['metrics-server']) {
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
  })

}

main()
