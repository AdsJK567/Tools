#!/bin/bash
#!name = mihomo 一键脚本 Beta
#!desc = 支持，安装、更新、卸载等
#!date = 2024-09-09 18:50
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

# 定义脚本版本
sh_ver="1.4.7"

# 全局变量路径
FOLDERS="/root/mihomo"
FILE="/root/mihomo/mihomo"
WEB_FILE="/root/mihomo/ui"
SYSCTL_FILE="/etc/sysctl.conf"
SCRIPT_FILE="/root/mihomo-install.sh"
CONFIG_FILE="/root/mihomo/config.yaml"
VERSION_FILE="/root/mihomo/version.txt"
SYSTEM_FILE="/etc/systemd/system/mihomo.service"

# 获取本机 IP
GetLocal_ip(){
    # 获取本机的 IPv4 地址
    ipv4=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    # 获取本机的 IPv6 地址
    ipv6=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet6 ' | awk '{print $2}' | cut -d/ -f1)
}

# 返回主菜单
Start_Main() {
    echo && echo -n -e "${Red}* 按回车返回主菜单 *${Reset}" && read temp
    Main
}

# 检查是否安装
Check_install(){
    if [ ! -f "$FILE" ]; then
        echo "${Red}mihomo 未安装${Reset}"
        Start_Main
    fi
}

# 检查服务状态
Check_status() {
    if pgrep -x "mihomo" > /dev/null; then
        status="running"
    else
        status="stopped"
    fi
}

# 获取安装版本
Get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "mihomo 未安装"
    fi
}

# 显示脚本版本、服务状态和开机设置
Show_Status() {
    if [ ! -f "$FILE" ]; then
        status="${Red}未安装${Reset}"
        run_status="${Red}未运行${Reset}"
        auto_start="${Red}未设置${Reset}"
    else
        Check_status
        if [ "$status" == "running" ]; then
            status="${Green}已安装${Reset}"
            run_status="${Green}运行中${Reset}"
        else
            status="${Green}已安装${Reset}"
            run_status="${Red}未运行${Reset}"
        fi
        Check_os
        case "$OS" in
            "debian" | "ubuntu" | "centos")
                if systemctl is-enabled mihomo.service &>/dev/null; then
                    auto_start="${Green}已设置${Reset}"
                else
                    auto_start="${Red}未设置${Reset}"
                fi
                ;;
            "alpine")
                if rc-update show | grep -q "mihomo"; then
                    auto_start="${Green}已设置${Reset}"
                else
                    auto_start="${Red}未设置${Reset}"
                fi
                ;;
            *)
                echo "${Red}不支持的操作系统${Reset}"
                exit 1
                ;;
        esac
    fi
    # 显示输出效果
    echo "脚本版本：${Green}${sh_ver}${Reset}"
    echo "安装状态：${status}"
    echo "运行状态：${run_status}"
    echo "开机自启：${auto_start}"
}

# 检查操作系统
Check_os() {
    if [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/lsb-release ] && grep -q "DISTRIB_ID=Ubuntu" /etc/lsb-release; then
        OS="ubuntu"
    elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
        OS="centos"
    elif [ -f /etc/alpine-release ]; then
        OS="alpine"
    else
        echo "${Red}不支持的操作系统${Reset}"
        exit 1
    fi
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
        *)          echo "${Red}不支持的架构：${ARCH_RAW}${Reset}"; exit 1;;
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
    echo "${Green}IP 转发开启成功${Reset}"
}

# 启动服务
Start() {
    # 检查是否安装
    Check_install
    # 获取当前系统
    Check_os
    case "$OS" in
        "debian" | "ubuntu" | "centos")
            if systemctl is-active --quiet mihomo; then
                echo "${Green}mihomo 正在运行中${Reset}"
                Start_Main
            fi
            echo "${Green}mihomo 准备启动中${Reset}"
            # 启动服务
            if systemctl start mihomo; then
                echo "${Green}mihomo 启动命令已发出${Reset}"
            else
                echo "${Red}mihomo 启动失败${Reset}"
                exit 1
            fi
            # 等待服务启动
            sleep 3s
            # 检查服务状态
            if systemctl is-active --quiet mihomo; then
                echo "${Green}mihomo 启动成功${Reset}"
            else
                echo "${Red}mihomo 启动失败${Reset}"
                exit 1
            fi
            ;;
        "alpine")
            if rc-service mihomo status > /dev/null 2>&1; then
                echo "${Green}mihomo 正在运行中${Reset}"
                Start_Main
            fi
            echo "${Green}mihomo 准备启动中${Reset}"
            # 启动服务
            if rc-service mihomo start; then
                echo "${Green}mihomo 启动命令已发出${Reset}"
            else
                echo "${Red}mihomo 启动失败${Reset}"
                exit 1
            fi
            # 等待服务启动
            sleep 3s
            # 检查服务状态
            if rc-service mihomo status > /dev/null 2>&1; then
                echo "${Green}mihomo 启动成功${Reset}"
            else
                echo "${Red}mihomo 启动失败${Reset}"
                exit 1
            fi
            ;;
        *)
            echo "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    
    Start_Main
}

# 停止服务
Stop() {
    # 检查是否安装
    Check_install
    # 获取当前系统
    Check_os
    case "$OS" in
        "debian" | "ubuntu" | "centos")
            # 检查是否运行
            if ! systemctl is-active --quiet mihomo; then
                echo "${Green}mihomo 已经停止${Reset}"
                exit 0
            fi
            echo "${Green}mihomo 准备停止中${Reset}"
            # 停止服务
            if systemctl stop mihomo; then
                echo "${Green}mihomo 停止命令已发出${Reset}"
            else
                echo "${Red}mihomo 停止失败${Reset}"
                exit 1
            fi
            # 等待服务停止
            sleep 3s
            # 检查服务状态
            if systemctl is-active --quiet mihomo; then
                echo "${Red}mihomo 停止失败${Reset}"
                exit 1
            else
                echo "${Green}mihomo 停止成功${Reset}"
            fi
            ;;
        "alpine")
            # 检查是否运行
            if ! rc-service mihomo status > /dev/null 2>&1; then
                echo "${Green}mihomo 已经停止${Reset}"
                exit 0
            fi
            echo "${Green}mihomo 准备停止中${Reset}"
            # 停止服务
            if rc-service mihomo stop; then
                echo "${Green}mihomo 停止命令已发出${Reset}"
            else
                echo "${Red}mihomo 停止失败${Reset}"
                exit 1
            fi
            # 等待服务停止
            sleep 3s
            # 检查服务状态
            if rc-service mihomo status > /dev/null 2>&1; then
                echo "${Red}mihomo 停止失败${Reset}"
                exit 1
            else
                echo "${Green}mihomo 停止成功${Reset}"
            fi
            ;;
        *)
            echo "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    
    Start_Main
}

# 重启服务
Restart() {
    # 检查是否安装
    Check_install
    # 获取当前系统
    Check_os
    case "$OS" in
        "debian" | "ubuntu" | "centos")
            echo "${Green}mihomo 准备重启中${Reset}"
            # 重启服务
            if systemctl restart mihomo; then
                echo "${Green}mihomo 重启命令已发出${Reset}"
            else
                echo "${Red}mihomo 重启失败${Reset}"
                exit 1
            fi
            # 等待服务重启
            sleep 3s
            # 检查服务状态
            if systemctl is-active --quiet mihomo; then
                echo "${Green}mihomo 重启成功${Reset}"
            else
                echo "${Red}mihomo 启动失败${Reset}"
                exit 1
            fi
            ;;
        "alpine")
            echo "${Green}mihomo 准备重启中${Reset}"
            # 重启服务
            if rc-service mihomo restart; then
                echo "${Green}mihomo 重启命令已发出${Reset}"
            else
                echo "${Red}mihomo 重启失败${Reset}"
                exit 1
            fi
            # 等待服务重启
            sleep 3s
            # 检查服务状态
            if rc-service mihomo status > /dev/null 2>&1; then
                echo "${Green}mihomo 重启成功${Reset}"
            else
                echo "${Red}mihomo 启动失败${Reset}"
                exit 1
            fi
            ;;
        *)
            echo "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    
    Start_Main
}

# 卸载服务
Uninstall() {
    # 检查是否安装
    Check_install
    # 获取当前系统
    Check_os
    echo "${Green}mihomo 开始卸载${Reset}"
    case "$OS" in
        "debian" | "ubuntu" | "centos")
            echo "${Green}mihomo 卸载命令已发出${Reset}"
            # 停止服务
            systemctl stop mihomo.service 2>/dev/null || { echo "${Red}停止 mihomo 服务失败${Reset}"; exit 1; }
            systemctl disable mihomo.service 2>/dev/null || { echo "${Red}禁用 mihomo 服务失败${Reset}"; exit 1; }
            # 删除服务文件
            rm -f "$SYSTEM_FILE" || { echo "${Red}删除服务文件失败${Reset}"; exit 1; }
            # 删除相关文件夹
            rm -rf "$FOLDERS" || { echo "${Red}删除相关文件夹失败${Reset}"; exit 1; }
            # 重新加载 systemd
            systemctl daemon-reload || { echo "${Red}重新加载 systemd 配置失败${Reset}"; exit 1; }
            ;;
        "alpine")
            echo "${Green}mihomo 卸载命令已发出${Reset}"
            # 停止服务
            rc-service mihomo stop 2>/dev/null || { echo "${Red}停止 mihomo 服务失败${Reset}"; exit 1; }
            rc-update delete mihomo 2>/dev/null || { echo "${Red}禁用 mihomo 服务失败${Reset}"; exit 1; }
            # 删除服务文件
            rm -f "$SYSTEM_FILE" || { echo "${Red}删除服务文件失败${Reset}"; exit 1; }
            # 删除相关文件夹
            rm -rf "$FOLDERS" || { echo "${Red}删除相关文件夹失败${Reset}"; exit 1; }
            ;;
        *)
            echo "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    # 等待服务停止
    sleep 3s
    # 检查卸载是否成功
    if [ ! -f "$SYSTEM_FILE" ] && [ ! -d "$FOLDERS" ]; then
        echo "${Green}mihomo 卸载完成${Reset}"
    else
        echo "${Red}卸载过程中出现问题，请手动检查${Reset}"
    fi
    exit 0
}

# 更新脚本
Update_Shell() {
    echo "${Green}开始检查是否有更新${Reset}"
    # 获取最新版本号
    sh_ver_url="https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/mihomo-install.sh"
    sh_new_ver=$(wget --no-check-certificate -qO- "$sh_ver_url" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    # 当前脚本版本号
    sh_ver=$(grep 'sh_ver="' "$SCRIPT_FILE" | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo "当前版本：[ ${Green}${sh_ver}${Reset} ]"
        echo "最新版本：[ ${Green}${sh_new_ver}${Reset} ]"
        echo "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
        exit 0
    fi
    echo "${Green}检查到已有新版本${Reset}"
    echo "当前版本：[ ${Green}${sh_ver}${Reset} ]"
    echo "最新版本：[ ${Green}${sh_new_ver}${Reset} ]"
    while true; do
        read -p "是否升级到最新版本？(y/n)：" confirm
        case $confirm in
            [Yy]* )
                echo "开始下载最新版本 [ ${Green}${sh_new_ver}${Reset} ]"
                wget -O $SCRIPT_FILE --no-check-certificate "$sh_ver_url"
                chmod +x $SCRIPT_FILE
                
                Check_os
                case "$OS" in
                    "debian" | "ubuntu" | "centos")
                        # 将脚本移动到 /usr/local/bin
                        if [ -f "$SCRIPT_FILE" ]; then
                            cp $SCRIPT_FILE /usr/local/bin/mihomo
                            chmod +x /usr/local/bin/mihomo
                            echo "更新完成，当前版本已更新为 ${Green}[ v${sh_new_ver} ]${Reset}"
                            echo "5 秒后执行新脚本"
                            sleep 5s
                            bash /usr/local/bin/mihomo
                        else
                            echo "${Red}当前脚本文件不存在: $SCRIPT_FILE${Reset}"
                            exit 1
                        fi
                        ;;
                    "alpine")
                        # 将脚本移动到 /usr/local/bin
                        if [ -f "$SCRIPT_FILE" ]; then
                            cp $SCRIPT_FILE /usr/local/bin/mihomo
                            chmod +x /usr/local/bin/mihomo
                            echo "更新完成，当前版本已更新为 ${Green}[ v${sh_new_ver} ]${Reset}"
                            echo "5 秒后执行新脚本"
                            sleep 5s
                            /usr/local/bin/mihomo
                        else
                            echo "${Red}当前脚本文件不存在: $SCRIPT_FILE${Reset}"
                            exit 1
                        fi
                        ;;
                    *)
                        echo "${Red}不支持的操作系统${Reset}"
                        exit 1
                        ;;
                esac
                break
                ;;
            [Nn]* )
                echo "${Red}更新已取消 ${Reset}"
                exit 1
                ;;
            * )
                echo "${Red}无效的输入，请输入 y 或 n ${Reset}"
                ;;
        esac
    done
    Start_Main
}


# 安装
Install() {
    # 检查是否安装 
    if [ -f "$FILE" ]; then
        echo "${Green}mihomo 已经安装${Reset}"
        Start_Main
    fi
    # 获取系统
    Check_os
    echo "当前系统：[ ${Green}${OS}${Reset} ]"
    # 获取架构
    Get_the_schema
    echo "当前架构：[ ${Green}${ARCH_RAW}${Reset} ]"
    case "$OS" in
        "debian" | "ubuntu")
            # 更新系统
            apt-get update && apt-get dist-upgrade -y
            # 安装必要软件
            apt-get install -y jq unzip curl git wget vim dnsutils openssl coreutils grep gawk iptables
            ;;
        "centos")
            # 更新系统
            yum update -y
            # 安装必要软件
            yum install -y jq unzip curl git wget vim bind-utils openssl coreutils grep gawk iptables-services
            ;;
        "alpine")
            # 更新系统
            apk update && apk upgrade
            # 安装必要软件
            apk add jq unzip curl git wget vim bind-tools openssl coreutils grep gawk iptables
            ;;
        *)
            echo "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    # 创建文件夹
    mkdir -p $FOLDERS && cd $FOLDERS || { echo "${Red}创建或进入 $FOLDERS 目录失败${Reset}"; exit 1; }
    # 获取版本信息
    VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt"
    VERSION=$(curl -sSL "$VERSION_URL" || { echo "${Red}获取版本信息失败${Reset}"; exit 1; })
    # 构造文件名
    case "$ARCH" in
        'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${VERSION}.gz";;
        'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${VERSION}.gz";;
        *)       echo "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
    esac
    # 开始下载
    DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"
    echo "当前版本：[ ${Green}${VERSION}${Reset} ]"
    wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo "${Red}下载失败${Reset}"; exit 1; }
    echo "[ ${Green}${VERSION}${Reset} ] 下载完成，开始安装"
    # 解压文件
    gunzip "$FILENAME" || { echo "${Red}解压失败${Reset}"; exit 1; }
    # 重命名
    if [ -f "mihomo-linux-${ARCH}-${VERSION}" ]; then
        mv "mihomo-linux-${ARCH}-${VERSION}" mihomo
    elif [ -f "mihomo-linux-${ARCH}-compatible-${VERSION}" ]; then
        mv "mihomo-linux-${ARCH}-compatible-${VERSION}" mihomo
    else
        echo "${Red}找不到解压后的文件${Reset}"
        exit 1
    fi
    # 授权
    chmod 755 mihomo
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 下载 UI
    echo "${Green}开始下载 mihomo 管理面板${Reset}"
    WEB_URL="https://github.com/metacubex/metacubexd.git"
    git clone "$WEB_URL" -b gh-pages "$WEB_FILE"
    # 下载系统配置文件
    echo "${Green}开始下载 mihomo 的 Service 系统配置${Reset}"
    SERVICE_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Service/mihomo.service"
    wget -O "$SYSTEM_FILE" "$SERVICE_URL" && chmod 755 "$SYSTEM_FILE"
    echo "${Green}mihomo 安装完成，开始配置${Reset}"
    # 开始配置 config 文件
    Configure
}

# 更新
Update() {
    # 检查是否安装
    Check_install
    echo "${Green}开始检查是否有更新${Reset}"
    cd $FOLDERS
    # 获取当前版本
    CURRENT_VERSION=$(Get_current_version)
    # 获取最新版本
    LATEST_VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt"
    LATEST_VERSION=$(curl -sSL "$LATEST_VERSION_URL" || { echo "${Red}获取版本信息失败${Reset}"; exit 1; })
    # 开始更新
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
        echo "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
        echo "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
        exit 0
    fi
    echo "${Green}检查到已有新版本${Reset}"
    echo "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
    echo "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
    while true; do
        read -p "是否升级到最新版本？(y/n)：" confirm
        case $confirm in
            [Yy]* )
                # 获取架构
                Get_the_schema
                # 构造文件名
                case "$ARCH" in
                    'arm64' | 'armv7' | 's390x' | '386') FILENAME="mihomo-linux-${ARCH}-${LATEST_VERSION}.gz";;
                    'amd64') FILENAME="mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}.gz";;
                    *)       FILENAME="mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}.gz";;
                esac
                # 开始下载
                DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/${FILENAME}"
                echo "开始下载最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
                wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo "${Red}下载失败${Reset}"; exit 1; }
                echo "[ ${Green}${LATEST_VERSION}${Reset} ] 下载完成，开始更新"
                # 解压文件
                gunzip "$FILENAME" || { echo "${Red}解压失败${Reset}"; exit 1; }
                # 重命名
                if [ -f "mihomo-linux-${ARCH}-${LATEST_VERSION}" ]; then
                    mv "mihomo-linux-${ARCH}-${LATEST_VERSION}" mihomo
                elif [ -f "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" ]; then
                    mv "mihomo-linux-${ARCH}-compatible-${LATEST_VERSION}" mihomo
                else
                    echo "${Red}找不到下载后的文件${Reset}"
                    exit 1
                fi
                # 授权
                chmod 755 mihomo
                # 更新版本信息
                echo "$LATEST_VERSION" > "$VERSION_FILE"
                # 重新加载和重启服务
                case "$OS" in
                    "debian" | "ubuntu" | "centos")
                        systemctl daemon-reload
                        systemctl restart mihomo
                        ;;
                    "alpine")
                        # Alpine 不使用 systemctl
                        rc-service mihomo restart
                        ;;
                    *)
                        echo "${Red}不支持的操作系统${Reset}"
                        exit 1
                        ;;
                esac
                echo "更新完成，当前版本已更新为：[ ${Green}${LATEST_VERSION}${Reset} ]"
                # 检查并显示服务状态
                case "$OS" in
                    "debian" | "ubuntu" | "centos")
                        if systemctl is-active --quiet mihomo; then
                            echo "当前状态：[ ${Green}运行中${Reset} ]"
                        else
                            echo "当前状态：[ ${Red}未运行${Reset} ]"
                            Start_Main
                        fi
                        ;;
                    "alpine")
                        if rc-service mihomo status > /dev/null 2>&1; then
                            echo "当前状态：[ ${Green}运行中${Reset} ]"
                        else
                            echo "当前状态：[ ${Red}未运行${Reset} ]"
                            Start_Main
                        fi
                        ;;
                esac
                Start_Main
                ;;
            [Nn]* )
                echo "${Red}更新已取消${Reset}"
                Start_Main
                ;;
            * )
                echo "${Red}无效的输入，请输入 y 或 n${Reset}"
                ;;
        esac
    done
}

# 配置
Configure() {
    # 检查是否安装
    Check_install
    # 下载配置文件
    CONFIG_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/mihomo.yaml"
    curl -s -o "$CONFIG_FILE" "$CONFIG_URL"
    # 获取用户输入的机场数量，默认为 1，且限制为 5 个以内
    while true; do
        read -p "请输入需要配置的机场数量（默认 1 个，最多 5 个）：" airport_count
        airport_count=${airport_count:-1}
        # 验证输入是否为 1 到 5 之间的正整数
        if echo "$airport_count" | grep -E '^[0-9]+$' > /dev/null && [ "$airport_count" -ge 1 ] && [ "$airport_count" -le 5 ]; then
            break
        else
            echo "\033[31m无效的数量，请输入 1 到 5 之间的正整数。\033[0m"
        fi
    done
    # 读取配置文件
    echo "${Green}读取配置文件${Reset}"
    # 初始化 proxy-providers 部分
    proxy_providers="proxy-providers:"
    # 动态添加机场
    i=1
    while [ "$i" -le "$airport_count" ]; do
        read -p "请输入第 $i 个机场的订阅连接：" airport_url
        read -p "请输入第 $i 个机场的名称：" airport_name
        
        proxy_providers="$proxy_providers
  Airport_0$i:
    <<: *pr
    url: \"$airport_url\"
    override:
      additional-prefix: \"[$airport_name]\""
        
        i=$((i + 1))
    done
    # 修改配置文件
    echo "${Green}正在修改配置文件${Reset}"
    # 写入配置文件
    echo "${Green}开始写入配置文件${Reset}"
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
    echo "${Green}验证修改后的配置文件格式${Reset}"
    # 提示保存位置
    echo "${Green}mihomo 配置已完成并保存到 ${CONFIG_FILE} 文件夹${Reset}"
    echo "${Green}mihomo 配置完成，正在启动中${Reset}"
    # 启动和配置服务
    case "$OS" in
        "debian" | "ubuntu" | "centos")
            # 重新加载 systemd
            systemctl daemon-reload
            # 立即启动 mihomo 服务
            systemctl start mihomo
            # 设置开机启动
            systemctl enable mihomo
            ;;
        "alpine")
            # 启动服务并设置开机启动
            rc-service mihomo start
            rc-update add mihomo
            ;;
        *)
            echo "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    echo "${Green}已设置开机自启动${Reset}"
    # 调用函数获取
    GetLocal_ip
    # 引导语
    echo "${Green}恭喜你，你的 mihomo 已经配置完成${Green}"
    echo "${Red}输入 mihomo 就能启动面板${Green}"
    echo "使用 ${Red}http://$ipv4:9090/ui${Reset} 访问你的 mihomo 管理面板面板"
    # 返回主菜单
    Start_Main
}

# 主菜单
Main() {
    clear
    echo "================================="
    echo "${Green}欢迎使用 mihomo 一键脚本 Beta 版${Reset}"
    echo "${Green}作者：${Yellow}${Red}AdsJK567${Reset}"
    echo "${Green}请保证科学上网已经开启${Reset}"
    echo "${Green}选项3，可以修改你的机场订阅链接${Reset}"
    echo "${Green}安装过程中可以按 ctrl+c 强制退出${Reset}"
    echo "================================="
    echo "${Green} 0${Reset}、更新脚本"
    echo "${Green} 8${Reset}、退出脚本"
    echo "---------------------------------"
    echo "${Green} 1${Reset}、安装 mihomo"
    echo "${Green} 2${Reset}、更新 mihomo"
    echo "${Green} 3${Reset}、配置 mihomo"
    echo "${Green} 4${Reset}、卸载 mihomo"
    echo "---------------------------------"
    echo "${Green} 5${Reset}、启动 mihomo"
    echo "${Green} 6${Reset}、停止 mihomo"
    echo "${Green} 7${Reset}、重启 mihomo"
    echo "================================="
    Show_Status
    echo "================================="
    read -p "请输入选项[0-8]：" num
    case "$num" in
        1) Check_ip_forward; Install ;;
        2) Update ;;
        3) Configure ;;
        4) Uninstall ;;
        5) Start ;;
        6) Stop ;;
        7) Restart ;;
        8) exit 0 ;;
        0) Update_Shell ;;
        *) echo "${Red}无效选项，请重新选择${Reset}" 
           exit 1 ;;
    esac
}

# 启动主菜单
Main
