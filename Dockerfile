ARG PYTHON_BASE_IMAGE=python:3.8.20-bookworm
FROM ${PYTHON_BASE_IMAGE}

ENV TZ=Asia/Shanghai \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}"

# Replace the base image's deb822 sources to avoid duplicate/mixed repositories.
RUN set -eux; \
    rm -f /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
        'deb https://mirrors.tuna.tsinghua.edu.cn/debian bookworm main contrib non-free non-free-firmware' \
        'deb https://mirrors.tuna.tsinghua.edu.cn/debian bookworm-updates main contrib non-free non-free-firmware' \
        'deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware' \
        > /etc/apt/sources.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        build-essential \
        pkg-config \
        default-libmysqlclient-dev \
        libssl-dev \
        libffi-dev \
        libpcre3-dev \
        zlib1g-dev \
        libjpeg-dev \
        poppler-utils \
        libreoffice \
        vim \
        nano \
        nginx \
        supervisor \
        cron \
        mariadb-client \
        tzdata; \
    rm -rf /var/lib/apt/lists/*; \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    printf '%s\n' Asia/Shanghai > /etc/timezone; \
    if ! id nginx >/dev/null 2>&1; then \
        adduser --system --no-create-home --disabled-password --group nginx; \
    fi; \
    nginx -t

WORKDIR /webroot

COPY ./webroot /webroot
COPY ./wait /wait
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /wait /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["python"]
