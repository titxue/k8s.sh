import axios from 'axios'
import semver from 'semver'
import { SocksProxyAgent } from 'socks-proxy-agent'
import { sleep } from '../image/common.mjs'
import https from 'https'
import fs from 'fs'

// 配置 GitHub Token 作为环境变量，否则将限速
const githubToken = process.env.GITHUB_TOKEN
// 用于自动创建仓库分支，根据仓库分支可自动同步镜像
const gitlabToken = process.env.GITLAB_TOKEN
// 支持配置代理，如：socks5://127.0.0.1:1080
const proxyUrl = process.env.HTTP_PROXY || process.env.HTTPS_PROXY

const tagUrl = 'https://api.github.com/repos/kubernetes/kubernetes/tags'

// https://framagit.org/xuxiaowei-com-cn/kubernetes-binary 项目 ID: 111178
const gitlabRepositoryBranchesUrl = 'https://framagit.org/api/v4/projects/111178/repository/branches'
const gitlabPipelinesUrl = 'https://framagit.org/api/v4/projects/111178/pipelines'
const gitlabJobUrl = 'https://framagit.org/xuxiaowei-com-cn/kubernetes-binary/-/jobs'
const minimumVersion = 'v1.24.0'

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

    // 版本号规则（最小长度：7）：v1.24.0
    if (name.length < 7) {
      continue
    }

    if (semver.gte(name, minimumVersion)) {

      // 获取分支
      await axios.get(`${gitlabRepositoryBranchesUrl}/${name}`, {
        headers: {
          'PRIVATE-TOKEN': gitlabToken,
        }, httpsAgent: new https.Agent({
          rejectUnauthorized: false
        })
      }).then(async (resp) => {
        console.log(`分支 ${name} 已存在`, resp.status)

        // 获取分支的流水线
        await axios.get(`${gitlabPipelinesUrl}?ref=${name}`, {
          headers: {
            'PRIVATE-TOKEN': gitlabToken,
          }, httpsAgent: new https.Agent({
            rejectUnauthorized: false
          })
        }).then(async (resp) => {
          const data = resp.data
          if (data.size === 0) {
            console.log(`分支 ${name} 没有流水线`)
          } else {
            const pipeline = data[0]

            console.log(`分支 ${name} 最新流水线: id: ${pipeline.id}, iid: ${pipeline.iid}, 状态: ${pipeline.status}`)

            if (pipeline.status === 'success') {

              // 获取流水线中的作业
              await axios.get(`${gitlabPipelinesUrl}/${pipeline.id}/jobs`, {
                headers: {
                  'PRIVATE-TOKEN': gitlabToken,
                }, httpsAgent: new https.Agent({
                  rejectUnauthorized: false
                })
              }).then(async (resp) => {

                const url = `${gitlabJobUrl}/${resp.data[0].id}/artifacts/raw/kubernetes/_output/local/bin/linux/amd64/kubeadm`
                console.log(url)
                // 下载产物
                await axios({url, method: 'GET', responseType: 'stream', ...axiosConfig}).then((response) => {
                  const writeStream = fs.createWriteStream(`kubeadm-${name}`)
                  response.data.pipe(writeStream).on('finish', () => {
                  })
                }).catch((error) => {
                  console.log(error)
                })

              }).catch((error) => {
                console.log(error)
              })
            }
          }
        }).catch((error) => {
          console.log(error)
        })

      }).catch(async (error) => {
        if (error.status === 400) {
          console.log(`获取分支 ${name}`, error.response.data)
        } else if (error.status === 401) {
          console.log(`获取分支 ${name}`, error.response.data)
        } else if (error.status === 404) {
          console.log(`获取分支 ${name}`, error.response.data)

          let ref
          if (semver.gte(name, 'v1.31.0')) {
            ref = 'v1.31.0'
          } else {
            ref = 'v1.24.0'
          }

          await sleep(5_000)

          await axios.post(`${gitlabRepositoryBranchesUrl}?ref=${ref}&branch=${name}`, {}, {
            headers: {
              'PRIVATE-TOKEN': gitlabToken,
            }, httpsAgent: new https.Agent({
              rejectUnauthorized: false
            })
          }).then((resp) => {
            console.log(`分支 ${name} 已创建完成`, resp.data)
          }).catch((error) => {
            if (error.status === 400) {
              console.log(`创建分支 ${name}`, error.response.data)
            } else if (error.status === 401) {
              console.log(`创建分支 ${name}`, error.response.data)
            } else {
              console.log(error)
            }
          })

        } else {
          console.log(error)
        }
      })
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
