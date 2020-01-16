FROM python:3.8.1

COPY ./webroot /webroot

# 启用清华apt源
RUN sed -i "s@deb.debian.org@mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && apt-get update

# 安装nginx和supervisor
RUN apt-get install -y \
    vim \
    nano \
    nginx \
    supervisor

WORKDIR /webroot
# 添加一个nginx的用户，方便nginx启动
RUN adduser --system --no-create-home --disabled-password --group nginx
# 调整到中国上海时区
RUN cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

# 添加wait脚本，用来确保其他容器的服务启动完后再执行后面的command
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.5.1/wait /wait
RUN chmod +x /wait

CMD ["python"]

