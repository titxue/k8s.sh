# 二进制安装路径 {id=binary-install-path}

[[toc]]

| 二进制文件  | 安装路径                  |
|--------|-----------------------|
| `helm` | `/usr/local/bin/helm` |

## 为什么脚本中安装 `helm` 完成后，使用 `/usr/local/bin/helm version` 测试，而非 `helm version` 测试？{id=helm-version}

1. 从下面不同情况输出 `$PATH` 可知，使用 `sudo` 执行 `Shell` 脚本时，`$PATH` 中无 `/usr/local/sbin:/usr/local/bin`
2. 所以脚本中使用 `/usr/local/bin/helm version` 而非 `helm version` 测试，是防止使用 `sudo` 执行 `Shell` 脚本时，避免无法正确找到文件

```shell
[root@anolis-8-9 ~]# id
uid=0(root) gid=0(root) groups=0(root)
[root@anolis-8-9 ~]# echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
[root@anolis-8-9 ~]# cat a.sh
echo $PATH
[root@anolis-8-9 ~]# ./a.sh
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
[root@anolis-8-9 ~]# sudo ./a.sh
/sbin:/bin:/usr/sbin:/usr/bin
[root@anolis-8-9 ~]#
```
