# docker python 3.11.1 镜像构建包

## 系统版本
Linux c212985ddc2b 4.4.0-91-generic #114-Ubuntu SMP Tue Aug 8 11:56:56 UTC 2017 x86_64 GNU/Linux

## 构建方案

### 1、直接使用做好的镜像（推荐）
```sh
  demo:
    image: pcloth/python-nginx-supervisord:py311-wait
    container_name: demo
    hostname: demo
    ports:
      - 5050:5050
    volumes:
      - d:/demo:/root
    restart: always
    links:
      - redis:redis
      - mysql:mysql
    environment:
      WAIT_HOSTS: redis:6379, mysql:3306
      PYTHONUNBUFFERED: 0
    command: bash -c "/wait && pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple && supervisord -c conf/supervisor-dev.conf && while true; do echo hello world; sleep 60; done"
    depends_on:
      - mysql
      - redis
```

### 2、使用Dockerfile构建 
### 下方-t后面的参数改成你自己的镜像名称
```sh
docker build -t pcloth/python-nginx-supervisord:py311-wait .
```

### 2.1、然后使用本地镜像构建容器
```sh
docker run --name py311 -p 8888:8888  pcloth/python-nginx-supervisord:py311-wait sh -c "while true; do echo hello world; sleep 60; done"
```
