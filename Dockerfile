FROM python:3.11.1

COPY ./webroot /webroot

# 启用清华apt源
RUN sed -i "s@deb.debian.org@mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && apt-get update

# 安装常用工具
RUN apt-get install -y \
    vim \
    nano \
    nginx \
    supervisor \
    cron \
    mariadb-client

WORKDIR /webroot
# 添加一个nginx的用户，方便nginx启动
RUN adduser --system --no-create-home --disabled-password --group nginx
# 调整到中国上海时区
RUN cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

# 添加wait脚本，用来确保其他容器的服务启动完后再执行后面的command
# https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait
# 直接添加到了本地，避免无法加载的情况
ADD ./wait /wait
RUN chmod +x /wait

CMD ["python"]

