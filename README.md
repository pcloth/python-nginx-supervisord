# docker python 3.8.1 镜像构建包

## 系统版本
Linux c212985ddc2b 4.4.0-91-generic #114-Ubuntu SMP Tue Aug 8 11:56:56 UTC 2017 x86_64 GNU/Linux

## 构建步骤

### 
```sh
  demo:
    image: pcloth/sina-clound-python:py38-wait
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