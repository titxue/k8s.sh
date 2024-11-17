import axios from 'axios'

const wwwAuthenticate = async (image, tag, config = {}) => {
  const url = new URL('https://' + image)
  url.pathname = `/v2${url.pathname}/manifests/${tag}`

  return await axios.get(url.toString(), config)
    .catch((err) => {
      const map = {}
      const authenticate = err.response.headers['www-authenticate']
      authenticate.substring('Bearer'.length + 1).split(',').forEach((item) => {
        const tmp = item.split('=')
        map[tmp[0]] = tmp[1].slice(1, -1)
      })
      return map
    })
}

const tokenMap = async function (image, tag, config = {}) {
  const map = await wwwAuthenticate(image, tag, config)
  return await axios.get(`${map.realm}?service=${map.service}&scope=${map.scope}`, config)
    .then(response => response.data)
}

const imageInfo = async function (image, tag, config = {}) {
  const url = new URL('https://' + image)
  url.pathname = `/v2${url.pathname}/manifests/${tag}`
  const map = await tokenMap(image, tag)
  if (config.headers) {
    config.headers.Authorization = `Bearer ${map.token}`
  } else {
    config.headers = { Authorization: `Bearer ${map.token}` }
  }
  return await axios.get(url.toString(), config)
    .then(response => response.data)
}

export {
  wwwAuthenticate,
  tokenMap,
  imageInfo
}