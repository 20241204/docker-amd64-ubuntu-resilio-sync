#!/usr/bin/env bash
set -e
set -u

# 修改镜像源函数
modify_sources(){
    # 备份原始的 sources.list 文件
    cp -fv /etc/apt/sources.list /etc/apt/sources.list.bak

    # ARM64 镜像源
    ARM64_SOURCE="deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-proposed main restricted universe multiverse"

    # AMD64 镜像源
    AMD64_SOURCE="deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-proposed main restricted universe multiverse"

    # 检查系统架构
    ARCH=$(uname -m)

    # 替换 sources.list 文件
    if [ "$ARCH" == "aarch64" ]; then
        echo "$ARM64_SOURCE" > /etc/apt/sources.list
    elif [ "$ARCH" == "x86_64" ]; then
        echo "$AMD64_SOURCE" > /etc/apt/sources.list
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi

}

init(){
    # 执行一些操作，例如更新软件包列表
    apt update

    # 安装 bash
    apt -fy install bash

    # 换成 bash
    chsh -s /bin/bash

    # 创建 sh 符号链接替换
    ln -fsv $(command -v bash) $(command -v sh)
    #ln -fsv /bin/bash /bin/sh
    #ln -fsv /bin/bash /usr/bin/sh
    #ln -fsv /usr/bin/bash /bin/sh
    #ln -fsv /usr/bin/bash /usr/bin/sh

    # 改时区 安装基本命令
    date '+%Y-%m-%d %T'
    TZ=':Asia/Shanghai' date '+%Y-%m-%d %T'
    rm -rfv /etc/localtime
    ln -fsv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" | tee /etc/timezone

    # 安装更新时间工具
    apt -fy install tzdata
    echo "tzdata tzdata/Zones/Asia select Shanghai" | debconf-set-selections
    dpkg-reconfigure tzdata
    date '+%Y-%m-%d %T'

    # 安装 eatmydata 和 aptitude
    apt -fy install eatmydata
    apt -fy install aptitude
    eatmydata aptitude --without-recommends -o APT::Get::Fix-Missing=true -fy update
    eatmydata aptitude --without-recommends -o APT::Get::Fix-Missing=true -fy upgrade
    
    # 安装一些必备工具
    local packages=(
        ca-certificates
        wget
        locales
    )
    # 合并安装
    # eatmydata aptitude --without-recommends -o APT::Get::Fix-Missing=true -fy install "${packages[@]}"
    # 使用 for 循环逐个安装包
    for package in "${packages[@]}"; do
        echo "正在安装: $package"
        eatmydata aptitude --without-recommends -o APT::Get::Fix-Missing=true -fy install "$package" || {
            echo "安装 $package 时出错，停止安装。"
            exit 1
        }
    done
    # 配置简体中文字符集支持
    perl -pi -e 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
    perl -pi -e 's/^en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen
    perl -pi -e 's/^zh_CN GB2312/# zh_CN GB2312/g' /etc/locale.gen
    locale-gen zh_CN.UTF-8

    # 加载简体中文字符集环境变量
    LANGUAGE=zh_CN.UTF-8
    LC_ALL=zh_CN.UTF-8
    LANG=zh_CN.UTF-8
    LC_CTYPE=zh_CN.UTF-8

    # 将简体中文字符集支持写入到环境变量
    cat << 20241204 | tee -a /etc/default/locale /etc/environment $HOME/.bashrc $HOME/.profile
LANGUAGE=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
LANG=zh_CN.UTF-8
LC_CTYPE=zh_CN.UTF-8
20241204
    update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8
    # 检查字符集支持
    locale
    locale -a
    cat /etc/default/locale

    # 检查系统架构
    ARCH=$(uname -m)
    
    # 替换 sources.list 文件
    if [ "$ARCH" == "aarch64" ]; then
        echo "$ARCH"
        wget https://download-cdn.resilio.com/stable/linux/arm64/0/resilio-sync_arm64.tar.gz -O"/tmp/sync.tar.gz"
    elif [ "$ARCH" == "x86_64" ]; then
        echo "$ARCH"
        wget https://download-cdn.resilio.com/stable/linux/x64/0/resilio-sync_x64.tar.gz -O"/tmp/sync.tar.gz"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
    
    tar xf /tmp/sync.tar.gz -C /usr/bin rslsync
    mv -fv /tmp/sync.conf /etc/
    mv -fv /tmp/ResilioSyncPro.btskey /etc/
    mv -fv /tmp/run_sync /usr/bin/
    chmod -v +x /usr/bin/run_sync /usr/bin/rslsync
    rm -f /tmp/sync.tar.gz

    # 如果调用了修改镜像源函数，那么一定备份了镜像源
    # 因此判断镜像源原始文件备份，就能恢复原始镜像源
    # 定义镜像源文件路径
    FILE="/etc/apt/sources.list.bak"
    # 判断文件是否存在
    if [ -e "$FILE" ]; then
        # 存在则恢复原始的 sources.list 文件
        mv -fv /etc/apt/sources.list.bak /etc/apt/sources.list
    else
        echo "未调用国内镜像源修改函数 modify_sources()"
    fi
    apt-get -qy purge wget
    apt autoremove
    apt clean
    apt autoclean
    rm -frv /var/lib/apt/lists/*
}

export DEBIAN_FRONTEND=noninteractive
# 代理加速，替换成自己的 代理地址(IP) 和 端口(H_P)
#export IP=127.0.0.1 H_P=1234 S_P=12345 ; export http_proxy=http://${IP}:${H_P} https_proxy=http://${IP}:${H_P} all_proxy=socks5://${IP}:${S_P} HTTP_PROXY=http://${IP}:${H_P} HTTPS_PROXY=http://${IP}:${H_P} ALL_PROXY=socks5://${IP}:${S_P}
# 修改 sources 加速源
#modify_sources
init
# 解除代理加速
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
