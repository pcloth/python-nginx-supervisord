FROM python:3.11.11-bookworm

COPY ./webroot /webroot

RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian bookworm main contrib non-free" > /etc/apt/sources.list
# RUN sed -i 's/non-free/non-free non-free-firmware/g' /etc/apt/sources.list

# 接受debconf警告
RUN apt-get update --allow-releaseinfo-change

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

