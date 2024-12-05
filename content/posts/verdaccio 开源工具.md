---
date: 2024-12-03
tags:
- verdaccio
title: verdaccio 开源工具
UID: 20241203192901
---

## 内容

### 工具介绍

[官方文档](https://verdaccio.org) [github地址](https://github.com/verdaccio/verdaccio)  
verdaccio 是一款高效、易用的私有 npm 仓库管理工具，特别适合中小型团队使用。它可以显著提升包管理的安全性、效率和稳定性

### 工具部署

#### 部署组件

1.  sing-box
    sing-box 可以作为verdaccio 拉取上游依赖的代理程序，这是个可选组件， 当服务器访问npm官方仓库网络不好时是必要的， 使用docker部署
2.  verdaccio
    官方仓库有docker-compose.yaml 文件， 这里使用docker部署
    [官方docker-compose.yaml](https://github.com/verdaccio/verdaccio/blob/master/docker-compose.yaml)

#### 配置文件

1.  docker-compose.yaml

<!-- -->

    version: '3'

    services:
      verdaccio:
        restart: always
        image: verdaccio/verdaccio:nightly-master
        environment:
          VERDACCIO_PUBLIC_URL: "https://npm.example.com"
        container_name: verdaccio
        ports:
          - "4873:4873"
        volumes:
            - "./storage:/verdaccio/storage"
            - "./conf:/verdaccio/conf"
            - "./plugins:/verdaccio/plugins"
        deploy:
          resources:
            limits:
              cpus: '2'
              memory: 3G
      sing-box:
        image: ghcr.io/sagernet/sing-box:v1.10.3
        container_name: sing-box
        restart: always
        ports:
          - "1080:1080"
        volumes:
          - /etc/sing-box:/etc/sing-box
          - /var/lib/sing-box:/var/lib/sing-box
        command: 
          - run
          - -D
          - /var/lib/sing-box
          - -C
          - /etc/sing-box

说明：
- verdaccio 支持http代理， 这里使用docker 部署， verdaccio使用容器名称访问sing-box
- storage 配置缓存目录持久化
- plugins 插件目录持久化
- resources 配置资源
- sing-box 监听本地端口 1080 代理地址http://127.0.0.1:1080

2.  config.yaml

<!-- -->

    storage: /verdaccio/storage

    uplinks:
      npmjs:
        url: https://registry.npmjs.org/
        max_fails: 10
        timeout: 60s
        fail_timeout: 10m

    publish:
      allow_offline: true

    packages:
      '@*/*':
        access: $all
        publish: $authenticated
        proxy: npmjs
      '**':
        # allow all users (including non-authenticated users) to read and
        # publish all packages
        #
        # you can specify usernames/groupnames (depending on your auth plugin)
        # and three keywords: "$all", "$anonymous", "$authenticated"
        access: $all

        # allow all known users to publish packages
        # (anyone can register by default, remember?)
        publish: $authenticated

    registry
        proxy: npmjs 

    http_proxy: http://sing-box:1080/
    https_proxy: http://sing-box:1080/

    log: { type: stdout, format: pretty-timestamped, level: warn }

说明：
- uplinks 是上游地址配置，当verdaccio 缺失包的时候， 会从这会仓库地址拉取，并缓存
- 由于国内拉去官方npmjs 包很慢并且有时会报500网络错误， 需要sing-box 做一层代理
