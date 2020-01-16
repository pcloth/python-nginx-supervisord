# python 3.6.8 web项目部署包

## 这个目录下放你项目的各种配置和代码

## 推荐架构如下

```sh
--- webroot/
    --- log/ # 用来放各种日志
    --- conf/ # 用来放nginx.conf之类的配置文件
    --- app/ # 你的web app项目文件
    
```


> 构建容器成功后，会在容器/webroot目录里

