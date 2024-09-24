#!/bin/bash

#!name = v2ray 一键脚本 Beta
#!desc = 支持，安装、更新、卸载等
#!date = 2024-09-24 15:00
#!author = thNylHx ChatGPT

set -e -o pipefail

# 颜色代码
Red="\033[31m"  ## 红色
Green="\033[32m"  ## 绿色 
Reset="\033[0m"  ## 黑色

# 定义脚本版本
sh_ver="1.0.5"

# 定义全局变量
FOLDERS="/root/v2ray"
FILE="/root/v2ray/v2ray"
ACME_FILE="/root/.acme.sh"
SSL_FILE="/root/v2ray/ssl"
CONFIG_FILE="/root/v2ray/config.json"
VERSION_FILE="/root/v2ray/version.txt"
SYSTEM_FILE="/etc/systemd/system/v2ray.service"

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
        echo -e "${Red}v2ray 未安装${Reset}"
        Start_Main
    fi
}

# 检查服务状态
Check_status() {
    if pgrep -x "v2ray" > /dev/null; then
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
        echo "v2ray 未安装"
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
        if systemctl is-enabled v2ray.service &>/dev/null; then
            auto_start="${Green}已设置${Reset}"
        else
            auto_start="${Red}未设置${Reset}"
        fi
    fi
    # 输出状态
    echo -e "脚本版本：${Green}${sh_ver}${Reset}"
    echo -e "安装状态：${status}"
    echo -e "运行状态：${run_status}"
    echo -e "开机自启：${auto_start}"
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

# 显示当前配置
View() {
    # 检查是否安装
    Check_install
    echo -e "${Red}v2ray 配置信息${Reset}"
    # 读取并显示 port、UUID、path
    if [[ -f "${CONFIG_FILE}" ]]; then
        port=$(jq -r '.inbounds[0].port // "未设置"' "${CONFIG_FILE}")
        id=$(jq -r '.inbounds[0].settings.clients[0].id // "未设置"' "${CONFIG_FILE}")
        path=$(jq -r '.inbounds[0].streamSettings.wsSettings.path // "未设置"' "${CONFIG_FILE}")
        # 如果 path 为 "null" 或空，则显示“TCP 协议不需要设置”
        if [[ "$path" == "null" || -z "$path" ]]; then
            path="TCP 协议不需要设置"
        fi
        # 显示信息
        echo -e "port: ${Green}${port}${Reset}"
        echo -e "id: ${Green}${id}${Reset}"
        echo -e "path: ${Green}${path}${Reset}"
    else
        echo -e "${Red}找不到配置文件 ${CONFIG_FILE}，请检查路径是否正确${Reset}"
    fi
    Start_Main
}

# 启动
Start() {
    # 检查是否安装
    Check_install
    # 检查运行状态
    if systemctl is-active --quiet v2ray; then
        echo -e "${Green}v2ray 正在运行中${Reset}"
        Start_Main
    fi
    echo -e "${Green}v2ray 准备启动中${Reset}"
    # 发送启动命令
    systemctl enable v2ray
    # 启动服务
    if systemctl start v2ray; then
        echo -e "${Green}v2ray 启动命令已发出${Reset}"
    else
        echo -e "${Red}v2ray 启动失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet v2ray; then
        echo -e "${Green}v2ray 启动成功${Reset}"
    else
        echo -e "${Red}v2ray 启动失败${Reset}"
        exit 1
    fi
    Start_Main
}

# 停止
Stop() {
    # 检查是否安装
    Check_install
    # 检查运行状态
    if ! systemctl is-active --quiet v2ray; then
        echo -e "${Green}v2ray 已经停止${Reset}"
        Start_Main
    fi
    echo -e "${Green}v2ray 准备停止中${Reset}"
    # 尝试停止服务
    if systemctl stop v2ray; then
        echo -e "${Green}v2ray 停止命令已发出${Reset}"
    else
        echo -e "${Red}v2ray 停止失败${Reset}"
        exit 1
    fi
    # 等待服务停止
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet v2ray; then
        echo -e "${Red}v2ray 停止失败${Reset}"
        exit 1
    else
        echo -e "${Green}v2ray 停止成功${Reset}"
    fi
    Start_Main
}

# 重启
Restart() {
    # 检查是否安装
    Check_install
    echo -e "${Green}v2ray 准备重启中${Reset}"
    # 重启服务
    if systemctl restart v2ray; then
        echo -e "${Green}v2ray 重启命令已发出${Reset}"
    else
        echo -e "${Red}v2ray 重启失败${Reset}"
        exit 1
    fi
    # 等待服务重启
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet v2ray; then
        echo -e "${Green}v2ray 重启成功${Reset}"
    else
        echo -e "${Red}v2ray 重启失败${Reset}"
        exit 1
    fi
    Start_Main
}

# 卸载
Uninstall() {
    # 检查是否安装
    Check_install
    # 询问是否确认卸载
    read -rp "确认卸载 v2ray 吗？(y/n, 默认n): " confirm
    if [[ -z $confirm || $confirm =~ ^[Nn]$ ]]; then
        echo "卸载已取消。"
        exit 0
    fi
    echo -e "${Green}v2ray 开始卸载${Reset}"
    echo -e  "${Green}v2ray 卸载命令已发出${Reset}"
    # 停止服务
    systemctl stop v2ray 2>/dev/null || { echo -e "${Red}停止 v2ray 服务失败${Reset}"; exit 1; }
    systemctl disable v2ray 2>/dev/null || { echo -e "${Red}禁用 v2ray 服务失败${Reset}"; exit 1; }
    # 删除服务文件
    rm -f "$SYSTEM_FILE" || { echo -e "${Red}删除服务文件失败${Reset}"; exit 1; }
    # 删除证书
    rm -rf "$ACME_FILE" || { echo -e "${Red}删除证书失败${Reset}"; exit 1; }
    # 删除相关文件夹
    rm -rf $FOLDERS || { echo -e "${Red}删除相关文件夹失败${Reset}"; exit 1; }
    # 重新加载 systemd
    systemctl daemon-reload || { echo -e "${Red}重新加载 systemd 配置失败${Reset}"; exit 1; }
    # 等待服务停止
    sleep 3s
    # 检查卸载是否成功
    if [ ! -f "$SYSTEM_FILE" ] && [ ! -d "$FOLDERS" ]; then
        echo -e "${Green}v2ray 卸载完成${Reset}"
    else
        echo -e "${Red}卸载过程中出现问题，请手动检查${Reset}"
    fi
    exit 0
}

# 更新脚本
Update_Shell() {
    # 获取当前版本
    echo -e "${Green}开始检查是否有更新${Reset}"
    # 获取最新版本号
    sh_ver_url="https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/v2ray/v2ray.sh"
    sh_new_ver=$(wget --no-check-certificate -qO- "$sh_ver_url" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    # 最新版本无需更新
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo -e "当前版本：[ ${Green}${sh_ver}${Reset} ]"
        echo -e "最新版本：[ ${Green}${sh_new_ver}${Reset} ]"
        echo -e "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
    fi
    echo -e "当前版本：[ ${Green}${sh_ver}${Reset} ]"
    echo -e "最新版本：[ ${Green}${sh_new_ver}${Reset} ]"
    # 开始更新
    while true; do
        read -p "是否升级到最新版本？(y/n)： " confirm
        case $confirm in
            [Yy]* )
                echo -e "开始下载最新版本 [ ${Green}${sh_new_ver}${Reset} ]"
                # 删除旧的 /usr/bin/v2ray 文件
                if [ -f "/usr/bin/v2ray" ]; then
                    rm /usr/bin/v2ray
                fi
                # 下载新的 v2ray 文件并移动到 /usr/bin
                wget -O /usr/bin/v2ray --no-check-certificate "$sh_ver_url"
                # 赋予可执行权限
                chmod +x /usr/bin/v2ray
                # 确保 /usr/bin 在 PATH 中
                if [[ ":$PATH:" != *":/usr/bin:"* ]]; then
                    export PATH=$PATH:/usr/bin
                fi
                # 刷新可执行文件缓存
                hash -r
                echo -e "更新完成，当前版本已更新为 ${Green}[ v${sh_new_ver} ]${Reset}"
                echo -e "5 秒后执行新脚本"
                sleep 5s
                # 执行新脚本
                /usr/bin/v2ray
                break
                ;;
            [Nn]* )
                echo -e "${Red}更新已取消 ${Reset}"
                exit 1
                ;;
            * )
                echo -e "${Red}无效的输入，请输入 y 或 n ${Reset}"
                ;;
        esac
    done
    Start_Main
}

# 安装
Install() {
    # 检查是否安装 
    if [ -f "$FILE" ]; then
        echo -e "${Green}v2ray 已经安装，请勿重复安装${Reset}"
        Start_Main
    fi
    bash <(curl -Ls https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/v2ray/install.sh)
}

# 更新
Update() {
    # 检查是否安装
    Check_install
    echo -e "${Green}开始检查是否有更新${Reset}"
    cd $FOLDERS
    # 获取当前版本
    CURRENT_VERSION=$(Get_current_version)
    # 获取最新版本
    LATEST_VERSION_URL="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"
    LATEST_VERSION=$(curl -sSL "$LATEST_VERSION_URL" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
    # 开始更新
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
        echo -e "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
        echo -e "当前已是最新版本，无需更新！"
        Start_Main
    fi
    echo -e "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
    echo -e "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
    while true; do
        read -p "是否要更新到最新版本？(y/n): " confirm
        case $confirm in
            [Yy]* )
                # 获取架构
                Get_the_schema
                # 构造文件名
                case "$ARCH" in
                    'arm64-v8a' | 'arm64-v7a' | 's390x' | '32' | '64') FILENAME="v2ray-linux-${ARCH}.zip";;
                    *)       echo -e "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
                esac
                # 开始下载
                DOWNLOAD_URL="https://github.com/v2fly/v2ray-core/releases/download/v${VERSION}/${FILENAME}"
                echo -e "开始下载最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
                wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red}下载失败${Reset}"; exit 1; }
                echo -e "[ ${Green}${LATEST_VERSION}${Reset} ] 下载完成，开始更新"
                # 解压文件
                unzip "$FILENAME" && rm "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
                # 授权
                chmod 755 v2ray
                # 更新版本信息
                echo "$LATEST_VERSION" > "$VERSION_FILE"
                # 重新加载
                systemctl daemon-reload
                # 重启 
                systemctl restart v2ray
                echo -e "更新完成，当前版本已更新为：[ ${Green}v${LATEST_VERSION}${Reset} ]"
                # 检查并显示服务状态
                if systemctl is-active --quiet v2ray; then
                    echo -e "当前状态：[ ${Green}运行中${Reset} ]"
                else
                    echo -e "当前状态：[ ${Red}未运行${Reset} ]"
                    Start_Main
                fi
                Start_Main
                ;;
            [Nn]* )
                echo -e "${Red}更新已取消${Reset}"
                Start_Main
                ;;
            * )
                echo -e "${Red}无效的输入，请输入 y 或 n${Reset}"
                ;;
        esac
    done
    Start_Main
}

# 配置
Configure() {
    # 检查是否安装
    Check_install
    # 下载基础配置文件
    CONFIG_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/v2ray.json"
    curl -s -o "$CONFIG_FILE" "$CONFIG_URL"
    echo -e ""
    echo -e "${Green}开始配置 v2ray ${Reset}"
    echo -e ""
    # 询问是否快速配置，默认值为 y
    read -rp "是否快速生成配置文件？(y/n 默认[y]): " confirm
    confirm=${confirm:-y}  # 如果用户未输入，默认值为 y
    if [[ "$confirm" == [Yy] ]]; then
        # 快速配置：选择协议
        echo -e "请选择协议："
        echo -e "${Green}1${Reset}、vmess+tcp"
        echo -e "${Green}2${Reset}、vmess+ws"
        echo -e "${Green}3${Reset}、vmess+tcp+tls"
        echo -e "${Green}4${Reset}、vmess+ws+tls"
        read -rp "输入数字选择协议 (1-4 默认[1]): " confirm
        confirm=${confirm:-1}  # 默认为 1
        # 随机生成配置项
        PORT=$(shuf -i 10000-65000 -n 1)
        UUID=$(cat /proc/sys/kernel/random/uuid)
        # 如果选择了 WebSocket 协议
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
        fi
        # 显示生成的配置
        echo -e "配置文件已生成："
        case $confirm in
            1) echo -e "  - 协议: ${Green}vmess+tcp${Reset}" ;;
            2) echo -e "  - 协议: ${Green}vmess+ws${Reset}" ;;
            3) echo -e "  - 协议: ${Green}vmess+tcp+tls${Reset}" ;;
            4) echo -e "  - 协议: ${Green}vmess+ws+tls${Reset}" ;;
            *) echo -e "${Red}无效选项${Reset}" && exit 1 ;;
        esac
        echo -e "  - 端口: ${Green}$PORT${Reset}"
        echo -e "  - UUID: ${Green}$UUID${Reset}"
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            echo -e "  - WebSocket 路径: ${Green}/$WS_PATH${Reset}"
        fi
    else
        # 手动配置
        echo -e "请选择协议："
        echo -e "${Green}1${Reset}、vmess+tcp"
        echo -e "${Green}2${Reset}、vmess+ws"
        echo -e "${Green}3${Reset}、vmess+tcp+tls"
        echo -e "${Green}4${Reset}、vmess+ws+tls"
        read -rp "输入数字选择协议 (1-4 默认[1]): " confirm
        confirm=${confirm:-1}  # 默认为 1
        # 端口处理
        read -p "请输入监听端口 (留空以随机生成端口): " PORT
        if [[ -z "$PORT" ]]; then
            PORT=$(shuf -i 10000-65000 -n 1)
            echo -e "随机生成的监听端口: ${Green}$PORT${Reset}"
        elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
            echo -e "${Red}端口号必须在10000到65000之间。${Reset}"
            exit 1
        fi
        # UUID 处理
        read -p "请输入 v2ray UUID (留空以生成随机UUID): " UUID
        if [[ -z "$UUID" ]]; then
            UUID=$(cat /proc/sys/kernel/random/uuid)
            echo -e "随机生成的UUID: ${Green}$UUID${Reset}"
        fi
        # WebSocket 路径处理 (仅限选择2或4时)
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            read -p "请输入 WebSocket 路径 (留空以生成随机路径): " WS_PATH
            if [[ -z "$WS_PATH" ]]; then
                WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
                echo -e "随机生成的 WebSocket 路径: ${Green}/$WS_PATH${Reset}"
            else
                WS_PATH="${WS_PATH#/}"
                echo -e "WebSocket 路径: ${Green}/$WS_PATH${Reset}"
            fi
        fi
    fi
    # 读取配置文件
    echo -e "${Green}读取配置文件${Reset}"
    config=$(cat "$CONFIG_FILE")
    # 修改配置文件
    echo -e "${Green}修改配置文件${Reset}"
    case $confirm in
        1)  # vmess + tcp
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "tcp" |
                del(.inbounds[0].streamSettings.wsSettings) |
                del(.inbounds[0].streamSettings.tlsSettings)
            ')
            ;;
        2)  # vmess + ws
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" --arg ws_path "/$WS_PATH" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "ws" |
                .inbounds[0].streamSettings.wsSettings.path = $ws_path |
                del(.inbounds[0].streamSettings.tlsSettings) |
                del(.inbounds[0].streamSettings.wsSettings.headers)
            ')
            ;;
        3)  # vmess + tcp + tls
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "tcp" |
                .inbounds[0].streamSettings.security = "tls" |
                .inbounds[0].streamSettings.tlsSettings = {
                    "certificates": [
                        {
                            "certificateFile": "/root/v2ray/ssl/server.crt",
                            "keyFile": "/root/v2ray/ssl/server.key"
                        }
                    ]
                }
            ')
            ;;
        4)  # vmess + ws + tls
            config=$(echo "$config" | jq --arg port "$PORT" --arg uuid "$UUID" --arg ws_path "/$WS_PATH" '
                .inbounds[0].port = ($port | tonumber) |
                .inbounds[0].settings.clients[0].id = $uuid |
                .inbounds[0].streamSettings.network = "ws" |
                .inbounds[0].streamSettings.wsSettings.path = $ws_path |
                .inbounds[0].streamSettings.security = "tls" |
                .inbounds[0].streamSettings.tlsSettings = {
                    "certificates": [
                        {
                            "certificateFile": "/root/v2ray/ssl/server.crt",
                            "keyFile": "/root/v2ray/ssl/server.key"
                        }
                    ]
                } |
                del(.inbounds[0].streamSettings.wsSettings.headers)
            ')
            ;;
        *)
            echo -e "${Red}无效选项${Reset}"
            exit 1
            ;;
    esac
    # 写入配置文件
    echo -e "${Green}写入配置文件${Reset}"
    echo "$config" > "$CONFIG_FILE"
    # 验证修改后的配置文件
    echo -e "${Green}验证修改后的配置文件格式${Reset}"
    if ! jq . "$CONFIG_FILE" >/dev/null 2>&1; then
        echo -e "${Red}修改后的配置文件格式无效，请检查文件${Reset}"
        exit 1
    fi
    # 提示保存位置
    echo -e "${Green}v2ray 配置已完成并保存到 ${CONFIG_FILE} 文件夹${Reset}"
    echo -e "${Green}v2ray 配置完成，正在启动中${Reset}"
    # 获取本地 IP 地址
    GetLocal_ip
    # 获取 IP 地址的位置信息
    echo -e "${Green}获取IP地址位置信息${Reset}"
    GEO_INFO=$(curl -s "https://ipinfo.io/$ipv4")
    CITY=$(echo "$GEO_INFO" | jq -r .city)
    COUNTRY=$(echo "$GEO_INFO" | jq -r .country)
    PS="${CITY}-${COUNTRY}"
    # 生成 vmess:// 链接
    json=$(jq -n \
        --arg v "2" \
        --arg ps "$PS" \
        --arg add "$ipv4" \
        --arg port "$PORT" \
        --arg id "$UUID" \
        --arg aid "0" \
        --arg net "$(jq -r '.inbounds[0].streamSettings.network' "$CONFIG_FILE")" \
        --arg path "$(jq -r '.inbounds[0].streamSettings.wsSettings.path // empty' "$CONFIG_FILE")" \
        --arg tls "$(jq -r '.inbounds[0].streamSettings.security // empty' "$CONFIG_FILE")" \
        '{v: $v, ps: $ps, add: $add, port: ($port | tonumber), id: $id, aid: ($aid | tonumber), net: $net, type: "none", path: $path, tls: $tls}' | jq -c .)       
    # 你的链接
    vmess_link=$(echo -n "$json" | base64 | tr -d '\n')
    echo -e "VMESS 链接: [ ${Green}vmess://$vmess_link${Reset} ]"
    # 生成二维码 URL
    # 注意：URL 编码的部分需要转义
    vmess_link_encoded="vmess://$vmess_link"
    SSQRcode="https://cli.im/api/qrcode/code?text=${vmess_link_encoded}"
    echo -e "二维码链接: [ ${Green}$SSQRcode${Reset} ]"
    # 重新加载系统服务
    systemctl daemon-reload
    # 立即启动
    systemctl start v2ray
    # # 运行状况
    # systemctl status v2ray
    echo -e "${Green}已设置开机自启${Reset}"
    # 设置为开机自启
    systemctl enable v2ray
    # 引导语
    echo -e "${Green}恭喜你，你的 v2ray 已经配置完成${Reset}"
    echo -e "${Red}如果选择带有 tls 选项，申请证书完成，选择 5 启动 v2ray 即可${Reset}"
    # 检查并显示服务状态
    if systemctl is-active --quiet v2ray; then
        echo -e "当前状态：[ ${Green}运行中${Reset} ]"
    else
        echo -e "当前状态：[ ${Red}未运行${Reset} ]"
        Start_Main
    fi
    # 返回主菜单
    Start_Main
}

# 创建存储证书的目录
mkdir -p $SSL_FILE

# 检查是否安装 acme.sh
Install_acme_if_needed(){
    if ! command -v ~/.acme.sh/acme.sh &>/dev/null; then
        echo "acme.sh 未安装，正在安装..."
        curl https://get.acme.sh | sh || { echo "安装失败"; exit 1; }
    else
        echo "acme.sh 已经安装"
    fi
}

# 检查是否已有该域名的证书
Check_domain_name(){
    local currentCert=$(~/.acme.sh/acme.sh --list | grep ${DOMAIN} | wc -l)
    if [ ${currentCert} -ne 0 ]; then
        local certInfo=$(~/.acme.sh/acme.sh --list)
        echo -e "${Red}错误：当前环境已有对应域名的证书，无法重复申请${Reset}"
        echo "$certInfo"
        exit 1
    else
        echo "域名合法性校验通过"
    fi
}

# 自签证书申请函数
Request_self_cert() {
    echo -e "${Green}申请自签名证书中${Reset}" 
    # 读取用户输入的域名，如果未输入则默认使用 bing.com
    read -p "请输入伪装域名（默认：bing.com）： " DOMAIN
    DOMAIN=${DOMAIN:-bing.com}
    # 生成自签名证书
    openssl req -newkey rsa:2048 -nodes -keyout $SSL_FILE/server.key -x509 -days 365 -out $SSL_FILE/server.crt -subj "/CN=$DOMAIN"
    echo -e "${Green}自签名证书生成完成${Reset}"
}

# ACME Standalone 证书申请
Request_acme_cert() {
    # 检查安装情况
    Install_acme_if_needed
    # 安装必要插件
    apt-get install -y socat curl dnsutils openssl coreutils grep gawk
    # 选择 CA 提供商
    Select_Cert_Provider
    # 生成随机邮箱地址
    Generate_random_email() {
        local RANDOM_NUMBER=$(openssl rand -hex 12 | tr -dc 'a-z0-9' | head -c 15)
        local EMAIL="${RANDOM_NUMBER}@spyemail.com"
        echo "$EMAIL"
    }
    # 获取用户输入的域名
    read -p "请输入你的域名（用于证书申请）: " DOMAIN
    # 获取用户输入的电子邮件
    read -p "请输入申请证书的电子邮件（默认为随机生成邮箱）： " EMAIL
    if [ -z "$EMAIL" ]; then
        EMAIL=$(Generate_random_email)
        echo "未输入电子邮件，使用生成的随机邮箱地址： $EMAIL"
    else
        echo "使用用户输入的邮箱地址： $EMAIL"
    fi
    # 检查是否已有该域名的证书
    Check_domain_name
    # 获取本机的公网 IP 地址
    LOCAL_IP_V4=$(curl -s ifconfig.me)
    LOCAL_IP_V6=$(curl -s ifconfig.co)
    # 获取域名的 A 记录和 AAAA 记录 IP 地址
    DOMAIN_IP_V4=$(dig +short A "$DOMAIN" | tail -n 1)
    DOMAIN_IP_V6=$(dig +short AAAA "$DOMAIN" | tail -n 1)
    # 检查域名是否解析到本机 IP 地址
    if [[ "$DOMAIN_IP_V4" == "$LOCAL_IP_V4" || "$DOMAIN_IP_V6" == "$LOCAL_IP_V6" ]]; then
        echo "域名验证通过，继续申请证书"
    else
        echo -e "${Red}错误：域名 $DOMAIN 未解析到本机 IP 地址。当前解析 IPv4 地址为 $DOMAIN_IP_V4，IPv6 地址为 $DOMAIN_IP_V6。${Reset}"
        exit 1
    fi 
    # 申请证书
    ~/.acme.sh/acme.sh --set-default-ca --server "$CA_SERVER"
    ~/.acme.sh/acme.sh --issue --standalone -d "$DOMAIN" --email "$EMAIL" --keylength ec-256 --log || { echo "证书申请失败！"; rm -rf ~/.acme.sh/${DOMAIN}; exit 1; }
    # 将证书和私钥复制到指定目录
    ~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" \
        --ecc \
        --cert-file $SSL_FILE/server.crt \
        --key-file $SSL_FILE/server.key \
        --fullchain-file $SSL_FILE/fullchain.crt || { echo "证书安装失败！"; rm -rf ~/.acme.sh/${DOMAIN}; exit 1; }
    # 启用证书自动更新
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade || { echo "自动更新设置失败"; chmod 755 $SSL_FILE; exit 1; }
    echo -e "${Green}ACME 证书申请完成并保存至 $SSL_FILE 目录，证书已开启自动更新${Reset}"
    ls -lah $SSL_FILE
    chmod 755 $SSL_FILE
}

# CF DNS API 证书申请
Request_cf_cert() {
    # 检查安装情况
    Install_acme_if_needed
    # 安装必要插件
    apt-get install -y curl dnsutils openssl coreutils grep gawk
    # 选择 CA 提供商
    Select_Cert_Provider
    # 使用说明
    echo -e ""
    echo "******使用说明******"
    echo "该脚本将使用 Acme 脚本申请证书，使用时需保证:"
    echo "1. 知晓 Cloudflare 注册邮箱"
    echo "2. 知晓 Cloudflare Global API Key"
    echo "3. 域名已通过 Cloudflare 进行解析到当前服务器"
    echo "4. 该脚本申请证书默认安装路径为 /root/v2ray/ssl 目录"
    read -p "我已确认以上内容 [y/n]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "操作已取消。"
        exit 0
    fi
    # 获取用户输入的域名、Cloudflare API 密钥和邮箱
    read -p "请输入域名（用于证书申请）: " CF_Domain
    read -p "请输入 Cloudflare Global API Key: " CF_GlobalKey
    read -p "请输入 Cloudflare 注册邮箱: " CF_AccountEmail
    # 设置 Cloudflare API 凭据
    export CF_Key="$CF_GlobalKey"
    export CF_Email="$CF_AccountEmail"
    # 注册账户
    ~/.acme.sh/acme.sh --register-account -m "$CF_AccountEmail" || { echo "账户注册失败！"; exit 1; }
    # 设置默认 CA 为 ZeroSSL
    ~/.acme.sh/acme.sh --set-default-ca --server zerossl || { echo "修改默认 CA 失败！"; exit 1; }
    # 检查是否已有该域名的证书
    Check_domain_name
    # 申请证书
    ~/.acme.sh/acme.sh --set-default-ca --server "$CA_SERVER"
    ~/.acme.sh/acme.sh --issue --dns dns_cf -d "$CF_Domain" -d "*.$CF_Domain" --email "$CF_AccountEmail" --keylength ec-256 || { echo "证书申请失败！"; rm -rf ~/.acme.sh/${CF_Domain}; exit 1; }
    # 将证书和私钥复制到指定目录
    ~/.acme.sh/acme.sh --install-cert -d "$CF_Domain" -d "*.$CF_Domain" \
        --ecc \
        --cert-file $SSL_FILE/server.crt \
        --key-file $SSL_FILE/server.key \
        --fullchain-file $SSL_FILE/fullchain.crt || { echo "证书安装失败！"; rm -rf ~/.acme.sh/${CF_Domain}; exit 1; }
    # 启用证书自动更新
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade || { echo "自动更新设置失败"; chmod 755 $SSL_FILE; exit 1; }
    echo -e "${Green}ACME 证书申请完成并保存至 $SSL_FILE 目录，证书已开启自动更新${Reset}"
    ls -lah $SSL_FILE
    chmod 755 $SSL_FILE
}

# 选择证书提供商函数
Select_Cert_Provider() {
    echo "请选择证书提供商，默认使用 Let's Encrypt"
    echo "-----------------------------------"
    echo -e "${Green}1${Reset}、Let's Encrypt"
    echo -e "${Green}2${Reset}、ZeroSSL"
    echo -e "${Green}3${Reset}、Buypass"
    echo "==================================="
    read -p "输入数字选择 (1-3，默认1): " confirm
    confirm=${confirm:-1}
    # 设置证书提供商
    case $confirm in
        1) CA_SERVER="letsencrypt"; echo "选择了 Let's Encrypt 作为证书提供商";;
        2) CA_SERVER="zerossl"; echo "选择了 ZeroSSL 作为证书提供商";;
        3) CA_SERVER="buypass"; echo "选择了 Buypass 作为证书提供商";;
        *) CA_SERVER="letsencrypt"; echo "无效选择，默认使用 Let's Encrypt 作为证书提供商";;
    esac
}

# 申请证书
Request_Cert() {
    clear
    echo "==================================="
    echo -e "${Green}欢迎使用 ACME 一键 SSL 证书申请脚本 Beta 版${Reset}"
    echo -e "${Green}作者：${Reset}${Red}thNylHx${Reset}"
    echo -e "${Green}安装过程中可以按 ctrl+c 强制退出${Reset}"
    echo "==================================="
    echo "使用说明书："
    echo "1. 该脚本提供三种方式实现证书签发"
    echo "2. 使用 ACME Standalone 的方式申请证书，需要开放端口"
    echo "3. 使用 DNS API 的方式申请证书，需要对 DNS 提供商的 API 进行配置（如 Cloudflare API 密钥）"
    echo "4. 使用自签申请证书，适用于没有域名"
    echo "==================================="
    echo -e "${Green}1${Reset}、自签证书申请"
    echo -e "${Green}2${Reset}、DNS API 证书申请"
    echo -e "${Green}3${Reset}、Standalone 证书申请"
    echo "==================================="
    # 默认选择 2（DNS API 证书申请）
    read -p "请选择证书申请方式（默认2）: " confirm
    confirm=${confirm:-2}
    # 选择方式
    echo -e "${Green}你选择了 ${confirm}${Reset}"
    case $confirm in
        1) Request_self_cert ;;
        2) Request_cf_cert ;;
        3) Request_acme_cert ;;
        *) echo -e "${Red}无效选择，默认使用 DNS API 证书申请${Reset}"; Request_cf_cert ;;
    esac
}

# 主菜单
Main() {
    clear
    echo "==================================="
    echo -e "${Green}欢迎使用 v2ray 一键脚本 Beta 版${Reset}"
    echo -e "${Green}作者：${Reset}${Red}thNylHx${Reset}"
    echo -e "${Green}请保证科学上网已经开启${Reset}"
    echo -e "${Green}安装过程中可以按 ctrl+c 强制退出${Reset}"
    echo "==================================="
    echo -e "${Green} 0${Reset}、更新脚本"
    echo -e "${Green}10${Reset}、退出脚本"
    echo "-----------------------------------"
    echo -e "${Green} 1${Reset}、安装 v2ray"
    echo -e "${Green} 2${Reset}、更新 v2ray"
    echo -e "${Green} 3${Reset}、卸载 v2ray"
    echo "-----------------------------------"
    echo -e "${Green} 4${Reset}、启动 v2ray"
    echo -e "${Green} 5${Reset}、停止 v2ray"
    echo -e "${Green} 6${Reset}、重启 v2ray"
    echo "-----------------------------------"
    echo -e "${Green} 7${Reset}、修改配置"
    echo -e "${Green} 8${Reset}、查看配置"
    echo -e "${Green} 9${Reset}、申请证书"
    echo "==================================="
    Show_Status
    echo "==================================="
    read -p "请输入选项[0-10]：" num
    case "$num" in
        1) Install ;;
        2) Update ;;
        3) Uninstall ;;
        4) Start ;;
        5) Stop ;;
        6) Restart ;;
        7) Configure ;;
        8) View ;;
        9) Request_Cert ;;
        0) Update_Shell ;;
        10) exit 0 ;; 
        *) echo -e "${Red}无效选项，请重新选择${Reset}"
           exit 1 ;;
    esac
}

# 启动主菜单
Main
