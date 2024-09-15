#!/bin/bash

#!name = v2ray 一键配置
#!desc = 配置文件
#!date = 2024-09-15 16:50
#!author = thNylHx ChatGPT

set -e -o pipefail

# 颜色代码
Red="\033[31m"     ## 红色
Green="\033[32m"   ## 绿色 
Reset="\033[0m"    ## 黑色

# 定义脚本版本
sh_ver="0.0.5"

# 定义全局变量
FOLDERS="/root/v2ray"
CONFIG_FILE="/root/v2ray/config.json"

# 获取本机 IP
GetLocal_ip(){
    # 获取本机的 IPv4 地址
    ipv4=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    # 获取本机的 IPv6 地址
    ipv6=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep 'inet6 ' | awk '{print $2}' | cut -d/ -f1)
}

# 配置
Configure() {
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
        elif [[ "$PORT" -lt 10000 || "$PORT" -gt 65000 ]]; then
            echo -e "${Red}端口号必须在10000到65000之间。${Reset}"
            exit 1
        fi
        # UUID 处理
        read -p "请输入 v2ray UUID (留空以生成随机UUID): " UUID
        if [[ -z "$UUID" ]]; then
            UUID=$(cat /proc/sys/kernel/random/uuid)
        fi
        # WebSocket 路径处理 (仅限选择2或4时)
        if [[ "$confirm" == "2" || "$confirm" == "4" ]]; then
            read -p "请输入 WebSocket 路径 (留空以生成随机路径): " WS_PATH
            if [[ -z "$WS_PATH" ]]; then
                WS_PATH=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
            else
                WS_PATH="${WS_PATH#/}"
            fi
        fi
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
    # 引导语
    echo -e "${Green}恭喜你，你的 v2ray 已经配置完成${Reset}"
    echo -e "${Red}如果选择带有 tls 选项，申请证书完成，选择 5 启动 v2ray 即可${Reset}"
}

Configure
