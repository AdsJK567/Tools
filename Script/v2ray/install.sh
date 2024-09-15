#!/bin/bash

#!name = v2ray 一键脚本 Beta
#!desc = 支持，安装、更新、卸载等
#!date = 2024-09-15 16:10
#!author = thNylHx ChatGPT

set -e -o pipefail

# 颜色代码
Red="\033[31m"  ## 红色
Green="\033[32m"  ## 绿色 
Yellow="\033[33m"  ## 黄色
Blue="\033[34m"  ## 蓝色
Magenta="\033[35m"  ## 洋红
Cyan="\033[36m"  ## 青色
White="\033[37m"  ## 白色
Reset="\033[0m"  ## 黑色

# 定义脚本版本
sh_ver="1.0.5"

# 定义全局变量
FOLDERS="/root/v2ray"
FILE="/root/v2ray/v2ray"
CONFIG_FILE="/root/v2ray/config.json"
VERSION_FILE="/root/v2ray/version.txt"
SYSTEM_FILE="/etc/systemd/system/v2ray.service"

# 检测是否是 Root 用户
[[ $EUID -ne 0 ]] && echo -e "${Red}错误：${Reset} 必须使用root用户运行此脚本！\n" && exit 1

# 获取本机 IP
GetLocal_ip(){
    # 获取本机的 IPv4 地址
    ipv4=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    # 获取本机的 IPv6 地址
    ipv6=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet6 ' | awk '{print $2}' | cut -d/ -f1)
}

# 获取当前架构
Get_the_schema(){
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='64';;
        'x86' | 'i686' | 'i386')     ARCH='32';;
        'aarch64' | 'arm64') ARCH='arm64-v8a';;
        'armv7' | 'armv7l')   ARCH='arm32-v7a';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red}不支持的架构: ${ARCH_RAW}${Reset}"; exit 1;;
    esac
}

# 更新系统并安装基本插件
Install_base() {
    apt-get update && apt-get dist-upgrade -y
    # 安装常用插件
    apt-get install -y jq unzip curl git wget dnsutils openssl coreutils grep gawk
}

# 安装
Install_v2ray() {
    # 清理旧的目录（如果存在）
    if [[ -e $FOLDERS ]]; then
        rm -rf $FOLDERS
    fi
    # 创建文件夹
    mkdir -p $FOLDERS && cd $FOLDERS || { echo -e "${Red}创建或进入 $FOLDERS 目录失败${Reset}"; exit 1; }
    # 获取架构
    Get_the_schema
    echo -e "当前架构：[ ${Green}${ARCH_RAW}${Reset} ]"
    # 获取版本信息
    VERSION_URL="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"
    VERSION=$(curl -sSL "$VERSION_URL" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//' || { echo -e "${Red}获取最新版本信息失败${Reset}"; exit 1; })
    # 构造文件名
    case "$ARCH" in
            'arm64-v8a' | 'arm64-v7a' | 's390x' | '32' | '64') FILENAME="v2ray-linux-${ARCH}.zip";;
            *)       echo -e "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
    esac
    # 开始下载
    DOWNLOAD_URL="https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/${FILENAME}"
    echo -e "当前版本：[ ${Green}${VERSION}${Reset} ]"
    # 等待3秒
    sleep 3s
    wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red}下载失败${Reset}"; exit 1; }
    echo -e "[ ${Green}${VERSION}${Reset} ] 下载完成，开始安装"
    # 解压文件
    unzip "$FILENAME" && rm "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
    # 授权
    chmod 755 v2ray
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 下载系统配置文件
    echo -e "${Green}开始下载 v2ray 的 Service 系统配置${Reset}"
    SERVICE_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Service/v2ray.service"
    wget -O "$SYSTEM_FILE" "$SERVICE_URL" && chmod 755 "$SYSTEM_FILE"
    echo -e "${Green}v2ray 安装完成，开始配置${Reset}"
    # 删除旧的 /usr/bin/v2ray 文件（如果存在）
    if [ -e /usr/bin/v2ray ]; then
        rm -f /usr/bin/v2ray
    fi
    # 下载脚本并设置执行权限
    INSTALL_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/v2ray/v2ray.sh"
    curl -s -o /usr/bin/v2ray "$INSTALL_URL" && chmod +x /usr/bin/v2ray
    # 确保 /usr/bin 在 PATH 中
    if [[ ":$PATH:" != *":/usr/bin:"* ]]; then
        export PATH=$PATH:/usr/bin
    fi
    # 刷新可执行文件缓存
    hash -r
    # 删除 install.sh 脚本
    if [ -f /root/install.sh ]; then
        rm -f /root/install.sh
    fi
    # 设置开机启动
    systemctl enable v2ray
    echo -e "${Green}已设置开机自启动${Reset}"
    echo -e ""
    echo -e "v2ray 管理脚本使用方法"
    echo "========================================"
    echo "v2ray            - 显示管理菜单 (功能更多)"
    echo "----------------------------------------"
    echo -e ""
    echo -e ""
    # 询问是否立即配置 v2ray
    read -rp "安装完成，是否立即配置 v2ray？(y/n，默认 y): " confirm
    confirm=${confirm:-y}
    if [[ $confirm == [Yy] ]]; then
        curl -o ./inconfig.sh -Ls https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/v2ray/inconfig.sh
        source inconfig.sh
        rm inconfig.sh -f
        generate_config_file
    fi
}

echo -e "${Green}开始安装${Reset}"
Install_base
Install_v2ray
