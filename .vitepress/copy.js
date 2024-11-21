const fs = require('fs-extra')
const path = require('path')

const data = [
    {
        "source": "charts",
        "target": "charts"
    },
    {
        "source": "deploy",
        "target": "deploy"
    },
    {
        "source": "etc",
        "target": "etc"
    },
    {
        "source": "mirrors",
        "target": "mirrors"
    },
    {
        "source": "check.sh",
        "target": "check.sh"
    },
    {
        "source": "k8s.sh",
        "target": "k8s.sh"
    },
]

data.forEach(item => {

    const sourceDir = path.resolve(__dirname, '../', item.source)
    const destDir = path.resolve(__dirname, '../.vitepress/dist/', item.target)

    fs.copy(sourceDir, destDir, err => {
        if (err) {
            console.error('文件夹复制失败:', err)
            throw err
        }
        console.log('文件夹复制成功:', destDir)
    })
})
