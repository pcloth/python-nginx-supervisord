# Python 3.8.20 + Nginx + Supervisor

基于 `python:3.8.20-bookworm`，保留 LibreOffice、Poppler、MariaDB 客户端、cron、编辑器和 `/wait`。补充常见 Python 扩展所需的编译器、MySQL、OpenSSL、libffi、PCRE、JPEG 和 zlib 开发库；不在构建时安装项目 Python 依赖。

Nginx 使用 Debian Bookworm 软件包，不安装或加载 njs/JavaScript 模块，也不再依赖 Nginx 官方软件源或本地 `.so` 文件。已有项目的 nginx.conf 若包含 `load_module modules/ngx_http_js_module.so;`，请同时删除该行及相关 `js_*` 配置。

## 构建与使用

```sh
docker compose build

# 首次安装项目依赖，安装结果保存在宿主机 ./python-packages 中。
docker compose run --rm demo python -m pip install -r requirements.txt

# 修改 compose.yaml 中的 command 为项目启动命令后启动。
docker compose up -d
```

`compose.yaml` 默认通过 `sleep infinity` 保持容器运行，便于先检查环境。实际项目可改为：

```yaml
command: ["supervisord", "-n", "-c", "conf/supervisor-dev.conf"]
```

使用 `/wait` 的项目可以配置 `WAIT_HOSTS`，并使用 `sh -c '/wait && exec supervisord -n -c conf/supervisor-dev.conf'` 启动。启动命令中无需再执行 `pip install`。

## 将 Python 项目依赖保存在宿主机

示例挂载关系：

```yaml
volumes:
  - ./webroot:/webroot
  - ./python-packages:/opt/venv
```

首次启动时，入口脚本自动在 `/opt/venv` 创建带 `--system-site-packages` 的虚拟环境。Python 标准库和镜像已有的全局包继续由镜像提供，不需要预先复制到宿主机。`python`、`pip` 和安装的命令行工具默认使用这个虚拟环境，新安装的项目包写入宿主机 `./python-packages`。

后续重启、删除或重新创建容器会复用该目录。依赖变更时手动执行：

```sh
docker compose exec demo python -m pip install -r requirements.txt
docker compose exec demo python -m pip check
docker compose restart demo
```

请按实际项目调整 `webroot/requirements.txt`；其中保留了原有 uWSGI 版本，并未自动升级。不要直接挂载覆盖 `/usr/local/lib/python3.8` 或其 `site-packages`，以免隐藏镜像已有内容。`python-packages` 由容器创建，仅供对应 Linux/Python 版本和 CPU 架构使用，不能直接作为宿主机 Windows 的虚拟环境；更换 Python 版本或架构后应换用新的目录并重新安装。

## 验证

```sh
docker compose run --rm demo python --version
docker compose run --rm demo python -m pip --version
docker compose run --rm demo python -m pip check
docker compose run --rm demo nginx -t
```

不使用 Compose 时：

```sh
docker build -t pcloth/python-nginx-supervisord:py3.8.20-wait .
docker run --rm -v "$PWD/python-packages:/opt/venv" \
  pcloth/python-nginx-supervisord:py3.8.20-wait python -m pip --version
```

## 项目演示配置 docker-compose.yml

仓库同时包含 `compose.yaml` 和 `docker-compose.yml`，以下命令显式指定项目演示文件，避免默认选中 `compose.yaml` 的 demo 服务。

演示服务 `qingruan` 使用新镜像 `py3.8.20-wait`，将宿主机 `C:/backup/data/qingruan/python-packages` 挂载到 `/opt/venv`。该目录首次可为空，由入口脚本初始化；保留它即可在重建容器后继续使用已安装的项目依赖。

该演示文件引用了 `mysql`、`redis`，但尚未包含它们的服务定义。先将真实定义补充到同一文件，或用多个 `-f` 参数合并包含这些服务的配置，再执行下面的命令：

```powershell
# 只需首次安装，或 requirements.txt 更新时执行。
# --no-deps 表示安装依赖时不启动 MySQL/Redis；此命令会覆盖服务启动命令。
docker compose -f docker-compose.yml run --rm --no-deps qingruan python -m pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/

# 正常启动，后续重建也不会再次执行 pip install。
docker compose -f docker-compose.yml up -d qingruan

# 检查 pip 使用的是 /opt/venv，以及已安装依赖是否一致。
docker compose -f docker-compose.yml exec qingruan python -m pip --version
docker compose -f docker-compose.yml exec qingruan python -m pip check

# 需要重建容器时，继续使用同一个宿主机依赖目录。
docker compose -f docker-compose.yml up -d --force-recreate qingruan
```

启动命令为 `/wait && exec supervisord -n -c conf/supervisor.conf`，Supervisor 在前台运行，由 Docker 直接管理其进程生命周期。如果 Supervisor 配置使用 Python 或 uWSGI 的绝对路径，项目程序应使用 `/opt/venv/bin/python`、`/opt/venv/bin/uwsgi`；镜像自带的 Supervisor 继续由系统包提供。

## Docker Hub 认证连接超时

如果构建在 `load metadata for docker.io/library/python:3.8.20-bookworm` 阶段报 `failed to fetch oauth token`、`auth.docker.io/token` 连接超时，说明 Docker 无法访问镜像仓库认证服务，此时尚未执行 Dockerfile 的安装步骤。修改 apt/pip 镜像源不能解决该错误。

先检查本地是否已有基础镜像：

```powershell
docker image inspect python:3.8.20-bookworm
docker compose build
```

默认构建不再加 `--pull`，可使用构建器可见的本地基础镜像；本地缺失时仍然需要访问仓库。使用独立的 buildx 构建器时，其镜像缓存可能与 Docker 本地镜像不同。

如果没有基础镜像，请在 Docker Desktop 的 Settings → Resources → Proxies 中配置能访问 Docker Hub 的系统代理或手动代理，应用设置后重试：

```powershell
docker pull python:3.8.20-bookworm
docker compose build
```

也可以在另一台能访问 Docker Hub、且与目标平台相同的机器上导出基础镜像：

```sh
docker pull --platform linux/amd64 python:3.8.20-bookworm
docker save -o python-3.8.20-bookworm.tar python:3.8.20-bookworm
```

将 tar 文件复制到当前机器，再导入并构建：

```powershell
docker load -i .\python-3.8.20-bookworm.tar
docker compose build
```

项目中的 `py3820` 归档标签为 `pcloth/python-nginx-supervisord:3.8.20-wait`，属于旧的完整应用镜像，不是 `python:3.8.20-bookworm` 基础镜像，不能通过直接导入它满足当前默认 FROM。

如果你有可访问的可信镜像仓库，可通过 PowerShell 临时指定同等 Python 3.8.20 Bookworm 基础镜像，无需修改 Dockerfile：

```powershell
$env:PYTHON_BASE_IMAGE = "你的仓库地址/library/python:3.8.20-bookworm"
docker compose build
Remove-Item Env:PYTHON_BASE_IMAGE
```

这里只解决基础镜像的获取；后续构建仍需访问配置的 Debian 清华源。

参考：[Compose build](https://docs.docker.com/reference/cli/docker/compose/build/)、[Docker Desktop 代理设置](https://docs.docker.com/desktop/settings-and-maintenance/settings/)。
