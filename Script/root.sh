#!/bin/bash
#!name = 开启 ROOT 一键脚本
#!desc = 支持，debian、ubuntu、centos、alpine
#!date = 2024-09-12 11:30
#!author = AdsJK567 ChatGPT

# 颜色设置
Green='\033[0;32m'
Red='\033[0;31m'
Reset='\033[0m'

# 检查操作系统类型
Check_os() {
    if [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/lsb-release ]; then
        OS="ubuntu"
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
    elif [ -f /etc/alpine-release ]; then
        OS="alpine"
    else
        echo -e "${Red}不支持的操作系统${Reset}"
        exit 1
    fi
}

# 配置 SSH 以允许 root 登录
Configure_SSH() {
    Check_os
    case "$OS" in
        "debian" | "ubuntu" )
            # 允许 root 用户通过 SSH 登录
            echo "PermitRootLogin yes" | tee -a /etc/ssh/sshd_config > /dev/null
            # 重新启动 SSH 服务
            systemctl restart ssh || { echo -e "${Red}重新启动 SSH 服务失败${Reset}"; exit 1; }
            ;;
        "centos" )
            # 允许 root 用户通过 SSH 登录
            echo "PermitRootLogin yes" | tee -a /etc/ssh/sshd_config > /dev/null
            # 重新启动 SSH 服务
            systemctl restart sshd || { echo -e "${Red}重新启动 SSH 服务失败${Reset}"; exit 1; }
            ;;
        "alpine" )
            # 允许 root 用户通过 SSH 登录
            echo "PermitRootLogin yes" | tee -a /etc/ssh/sshd_config > /dev/null
            # 重新启动 SSH 服务
            /etc/init.d/sshd restart || { echo -e "${Red}重新启动 SSH 服务失败${Reset}"; exit 1; }
            ;;
        * )
            echo -e "${Red}不支持的操作系统${Reset}"
            exit 1
            ;;
    esac
    echo -e "${Green}SSH 配置已更新，服务已重新启动${Reset}"
}

# 执行系统更新和配置
Configure_SSH
