import axios from 'axios'
import { SocksProxyAgent } from 'socks-proxy-agent'
import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const chartsUrl = 'https://kubernetes.github.io/dashboard/index.yaml'
const folderName = path.resolve(__dirname, '../../charts/kubernetes/dashboard')
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

  await axios.get(chartsUrl, axiosConfig).then((response) => {
    fs.writeFileSync(filePath, response.data)
  })

}

main()
