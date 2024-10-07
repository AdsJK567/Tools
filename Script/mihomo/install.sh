#!/bin/bash

#!name = mihomo 一键脚本 Beta
#!desc = 安装脚本
#!date = 2024-09-27 10:00
#!author = AdsJK567 ChatGPT

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

# 脚本版本
sh_ver="0.0.7"

# 全局变量路径
FOLDERS="/root/mihomo"
FILE="/root/mihomo/mihomo"
WEB_FILE="/root/mihomo/ui"
SYSCTL_FILE="/etc/sysctl.conf"
SCRIPT_FILE="/usr/local/mihomo"
CONFIG_FILE="/root/mihomo/config.yaml"
VERSION_FILE="/root/mihomo/version.txt"
SYSTEM_FILE="/etc/systemd/system/mihomo.service"

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
        'x86_64')    ARCH='amd64';;
        'x86' | 'i686' | 'i386')     ARCH='386';;
        'aarch64' | 'arm64') ARCH='arm64';;
        'armv7l')   ARCH='armv7';;
        's390x')    ARCH='s390x';;
        *)          echo -e "${Red}不支持的架构：${ARCH_RAW}${Reset}"; exit 1;;
    esac
}

# 检查和设置 IP 转发参数
Check_ip_forward() {
    # 要检查的设置
    local IPV4_FORWARD="net.ipv4.ip_forward = 1"
    # 检查是否已存在 net.ipv4.ip_forward = 1
    if grep -q "^${IPV4_FORWARD}$" "$SYSCTL_FILE"; then
        # 不执行 sysctl -p，因为设置已经存在
        return
    fi
    # 如果设置不存在，则添加并执行 sysctl -p
    echo "$IPV4_FORWARD" >> "$SYSCTL_FILE"
    # 立即生效
    sysctl -p
    echo -e "${Green}IP 转发开启成功${Reset}"
}

# 更新系统并安装基本插件
Install_base() {
    apt-get update && apt-get dist-upgrade -y
    # 安装常用插件
    apt-get install -y unzip git wget vim dnsutils coreutils grep gawk iptables
}

# 安装
Install_mihomo() {
    # 清理旧的目录（如果存在）
    if [[ -e $FOLDERS ]]; then
        rm -rf $FOLDERS
    fi
    # 检查和设置 IP 转发参数
    Check_ip_forward
    # 创建文件夹
    mkdir -p $FOLDERS && cd $FOLDERS || { echo -e "${Red}创建或进入 $FOLDERS 目录失败${Reset}"; exit 1; }
    # 获取架构
    Get_the_schema
    echo -e "当前架构：[ ${Green}${ARCH_RAW}${Reset} ]"
    # 获取版本信息
    VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt"
    VERSION=$(curl -sSL "$VERSION_URL" || { echo -e "${Red}获取版本信息失败${Reset}"; exit 1; })
    # 构造文件名
    case "$ARCH" in
        'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${VERSION}.gz";;
        'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${VERSION}.gz";;
        *)       echo -e "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
    esac
    # 开始下载
    DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"
    echo -e "当前版本：[ ${Green}${VERSION}${Reset} ]"
    # 等待3秒
    sleep 3s
    # 开始下载
    wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red}下载失败${Reset}"; exit 1; }
    echo -e "[ ${Green}${VERSION}${Reset} ] 下载完成，开始安装"
    # 解压文件
    gunzip "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
    # 重命名
    if [ -f "mihomo-linux-${ARCH}-${VERSION}" ]; then
        mv "mihomo-linux-${ARCH}-${VERSION}" mihomo
    elif [ -f "mihomo-linux-${ARCH}-compatible-${VERSION}" ]; then
        mv "mihomo-linux-${ARCH}-compatible-${VERSION}" mihomo
    else
        echo -e "${Red}找不到解压后的文件${Reset}"
        exit 1
    fi
    # 授权
    chmod 755 mihomo
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 下载 UI
    Panel
    # 下载系统配置文件
    echo -e "${Green}开始下载 mihomo 的 Service 系统配置${Reset}"
    SERVICE_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Service/mihomo.service"
    wget -O "$SYSTEM_FILE" "$SERVICE_URL" && chmod 755 "$SYSTEM_FILE"
    echo -e "${Green}mihomo 安装完成，开始配置${Reset}"
    # 删除旧的 /usr/bin/mihomo 文件（如果存在）
    if [ -e /usr/bin/mihomo ]; then
        rm -f /usr/bin/mihomo
    fi
    # 下载脚本并设置执行权限
    INSTALL_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/mihomo/mihomo.sh"
    curl -s -o /usr/bin/mihomo "$INSTALL_URL" && chmod +x /usr/bin/mihomo
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
    systemctl enable mihomo
    echo -e "${Green}已设置开机自启动${Reset}"
    echo -e ""
    echo -e ""
    echo -e "mihomo 管理脚本使用方法"
    echo "========================================"
    echo "mihomo            - 显示管理菜单 (功能更多)"
    echo "----------------------------------------"
    echo -e ""
    echo -e ""
    # 询问是否配置文件
    read -rp "安装完成，是否开始配置 config 文件？(y/n): " confirm
    if [[ $confirm == [Yy] ]]; then
        Configure
    else
        echo -e "配置文件生成已被取消"
        echo -e "你需要自己上传配置文件到${Green} $CONFIG_FILE 位置${Reset}"
    fi
}

# 面板
Panel(){
    WEB_URL1="https://github.com/MetaCubeX/Yacd-meta.git"
    WEB_URL2="https://github.com/metacubex/metacubexd.git"
    WEB_URL2="https://github.com/MetaCubeX/Razord-meta.git"
    # 选择模式
    while true; do
        echo -e "请选择面板："
        echo -e "${Green}1${Reset}. Yacd 面板"
        echo -e "${Green}2${Reset}. metacubexd 面板"
        echo -e "${Green}3${Reset}. dashboard 面板"
        read -rp "输入数字选择协议 (1-3 默认[1]): " confirm
        confirm=${confirm:-1}  # 默认为 1
        case "$confirm" in
            1) WEB_URL="$WEB_URL1"; break ;;
            2) WEB_URL="$WEB_URL2"; break ;;
            3) WEB_URL="$WEB_URL3"; break ;;
            *) echo -e "${Red}无效的选择，请输入 1、2 或 3。${Reset}" ;;
        esac
    done
    echo -e "${Green}开始下载 mihomo 管理面板${Reset}"
    git clone "$WEB_URL" -b gh-pages "$WEB_FILE"
}

# 配置
Configure() {
    # 配置文件 URL
    CONFIG_URL1="https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/mihomo.yaml"
    CONFIG_URL2="https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/mihomo-tp.yaml"
    # 选择模式
    while true; do
        echo -e "请选择运行模式："
        echo -e "${Green}1${Reset}. TUN 模式"
        echo -e "${Green}2${Reset}. TProxy 模式"
        read -rp "输入数字选择协议 (1-2 默认[1]): " confirm
        confirm=${confirm:-1}  # 默认为 1
        case "$confirm" in
            1) CONFIG_URL="$CONFIG_URL1"; break ;;
            2) CONFIG_URL="$CONFIG_URL2"; break ;;
            *) echo -e "${Red}无效的选择，请输入 1 或 2。${Reset}" ;;
        esac
    done
    # 下载配置文件
    curl -s -o "$CONFIG_FILE" "$CONFIG_URL"
    # 获取用户输入的机场数量，默认为 1，且限制为 5 个以内
    while true; do
        read -p "请输入需要配置的机场数量（默认 1 个，最多 5 个）：" airport_count
        airport_count=${airport_count:-1}
        # 验证输入是否为 1 到 5 之间的正整数
        if [[ "$airport_count" =~ ^[0-9]+$ ]] && [ "$airport_count" -ge 1 ] && [ "$airport_count" -le 5 ]; then
            break
        else
            echo -e "${Red}无效的数量，请输入 1 到 5 之间的正整数。${Reset}"
        fi
    done
    # 读取配置文件
    echo -e "${Green}读取配置文件${Reset}"
    # 初始化 proxy-providers 部分
    proxy_providers="proxy-providers:"
    # 动态添加机场
    for ((i=1; i<=airport_count; i++))
    do
        read -p "请输入第 $i 个机场的订阅连接：" airport_url
        read -p "请输入第 $i 个机场的名称：" airport_name
        
        proxy_providers="$proxy_providers
  Airport_0$i:
    <<: *pr
    url: \"$airport_url\"
    override:
      additional-prefix: \"[$airport_name]\""
    done
    # 修改配置文件
    echo -e "${Green}正在修改配置文件${Reset}"
    # 写入配置文件
    echo -e "${Green}开始写入配置文件${Reset}"
    # 使用 awk 将 proxy-providers 插入到指定位置
    awk -v providers="$proxy_providers" '
    /^# 机场订阅/ {
        print
        print providers
        next
    }
    { print }
    ' "$CONFIG_FILE" > temp.yaml && mv temp.yaml "$CONFIG_FILE"
    # 验证修改后的配置文件格式
    echo -e "${Green}验证修改后的配置文件格式${Reset}"
    # 提示保存位置
    echo -e "${Green}mihomo 配置已完成并保存到 ${CONFIG_FILE} 文件夹${Reset}"
    echo -e "${Green}mihomo 配置完成，正在启动中${Reset}"
    # 重新加载 systemd
    systemctl daemon-reload
    # 立即启动 mihomo 服务
    systemctl start mihomo
    # 调用函数获取
    GetLocal_ip
    # 引导语
    echo -e "恭喜你，你的 mihomo 已经配置完成"
    echo -e "使用 ${Green}http://$ipv4:9090/ui${Reset} 访问你的 mihomo 管理面板面板"
}

echo -e "${Green}开始安装${Reset}"
Install_base
Install_mihomo
