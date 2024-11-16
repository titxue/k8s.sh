const axios= require('axios')
const semver= require('semver')
const fs = require('fs')
const path = require('path')
const { SocksProxyAgent } = require('socks-proxy-agent')

// 自动下载所有 kubernetes/dashboard deploy yaml

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const folderName = path.resolve(__dirname, '../../mirrors/kubernetes/dashboard')

async function tags(page, per_page) {
    const tagUrl = `https://api.github.com/repos/kubernetes/dashboard/tags?page=${page}&per_page=${per_page}`
    const downloadUrl = 'https://raw.githubusercontent.com/kubernetes/dashboard/refs/tags'
    const minimumVersion = 'v2.6.0'

    const fileNameList = ['aio/deploy/recommended.yaml']

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
        if (name.includes('/')) {
            continue
        }

        if (semver.gte(name, minimumVersion)) {
            for (const fileName of fileNameList) {

                const url = `${downloadUrl}/${name}/${fileName}`
                const filePath = path.join(folderName, name, fileName)

                const dirPath = path.dirname(filePath)

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
        if (name.includes('/')) {
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
