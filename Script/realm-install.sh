#!/bin/bash
#!name = realm 一键脚本 Beta
#!desc = 支持，安装、更新、卸载等
#!date = 2024-08-2297 18:50
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
sh_ver="1.0.5"

# 全局变量路径
FOLDERS="/root/realm"
FILE="/root/realm/realm"
CONFIG_FILE="/root/realm/config.toml"
VERSION_FILE="/root/realm/version.txt"
SYSTEM_FILE="/etc/systemd/system/realm.service"

# 返回主菜单
Start_Main() {
    echo && echo -n -e "${Red}* 按回车返回主菜单 *${Reset}" && read temp
    Main
}

# 检查是否安装
Check_install(){
    if [ ! -f "$FILE" ]; then
        echo -e "${Red}realm 未安装${Reset}"
        Start_Main
    fi
}

# 检查服务状态
Check_status() {
    if pgrep -x "realm" > /dev/null; then
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
        echo "realm 未安装"
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
        if systemctl is-enabled realm.service &>/dev/null; then
            auto_start="${Green}已设置${Reset}"
        else
            auto_start="${Red}未设置${Reset}"
        fi
    fi
    # 显示输出效果
    echo -e "脚本版本：${Green}${sh_ver}${Reset}"
    echo -e "安装状态：${status}"
    echo -e "运行状态：${run_status}"
    echo -e "开机自启：${auto_start}"
}

# 获取当前架构
Get_the_schema(){
    ARCH_RAW=$(uname -m)
    case "${ARCH_RAW}" in
        'x86_64')    ARCH='x86_64';;
        'aarch64' | 'arm64') ARCH='aarch64';;
        'armv7l')   ARCH='armv7';;
        *)          echo -e "${Red}不支持的架构：${ARCH_RAW}${Reset}"; exit 1;;
    esac
}

# 启动服务
Start() {
    # 检查是否安装
    Check_install
    if systemctl is-active --quiet realm; then
        echo -e "${Green}realm 正在运行中${Reset}"
        Start_Main
    fi
    echo -e "${Green}realm 准备启动中${Reset}"
    # 重新加载
    systemctl enable realm
    # 启动服务
    if systemctl start realm; then
        echo -e "${Green}realm 启动命令已发出${Reset}"
    else
        echo -e "${Red}realm 启动失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet realm; then
        echo -e "${Green}realm 启动成功${Reset}"
    else
        echo -e "${Red}realm 启动失败${Reset}"
        exit 1
    fi
    Start_Main
}

# 停止服务
Stop() {
    # 检查是否安装
    Check_install
    # 检查是否运行
    if ! systemctl is-active --quiet realm; then
        echo -e "${Green}realm 已经停止${Reset}"
        exit 0
    fi
    echo -e "${Green}realm 准备停止中${Reset}"
    # 停止服务
    if systemctl stop realm; then
        echo -e "${Green}realm 停止命令已发出${Reset}"
    else
        echo -e "${Red}realm 停止失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet realm; then
        echo -e "${Red}realm 停止失败${Reset}"
        exit 1
    else
        echo -e "${Green}realm 停止成功${Reset}"
    fi
    Start_Main
}

# 重启服务
Restart() {
    # 检查是否安装
    Check_install
    echo -e "${Green}realm 准备重启中${Reset}"
    # 重启服务
    if systemctl restart realm; then
        echo -e "${Green}realm 重启命令已发出${Reset}"
    else
        echo -e "${Red}realm 重启失败${Reset}"
        exit 1
    fi
    # 等待服务启动
    sleep 3s
    # 检查服务状态
    if systemctl is-active --quiet realm; then
        echo -e "${Green}realm 重启成功${Reset}"
    else
        echo -e "${Red}realm 启动失败${Reset}"
        exit 1
    fi
    Start_Main
}

# 卸载服务
Uninstall() {
    # 检查是否安装
    Check_install
    echo -e "${Green}realm 开始卸载${Reset}"
    echo -e "${Green}realm 卸载命令已发出${Reset}"
    # 停止服务
    systemctl stop realm.service 2>/dev/null || { echo -e "${Red}停止 realm 服务失败${Reset}"; exit 1; }
    systemctl disable realm.service 2>/dev/null || { echo -e "${Red}禁用 realm 服务失败${Reset}"; exit 1; }
    # 删除服务文件
    rm -f "$SYSTEM_FILE" || { echo -e "${Red}删除服务文件失败${Reset}"; exit 1; }
    # 删除相关文件夹
    rm -rf "$FOLDERS" || { echo -e "${Red}删除相关文件夹失败${Reset}"; exit 1; }
    # 重新加载 systemd
    systemctl daemon-reload || { echo -e "${Red}重新加载 systemd 配置失败${Reset}"; exit 1; }
    # 等待服务停止
    sleep 3s
    # 检查卸载是否成功
    if [ ! -f "$SYSTEM_FILE" ] && [ ! -d "$FOLDERS" ]; then
        echo -e "${Green}realm 卸载完成${Reset}"
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
    sh_ver_url="https://raw.githubusercontent.com/AdsJK567/Tools/main/Script/realm-cdn.sh"
    sh_new_ver=$(wget --no-check-certificate -qO- "$sh_ver_url" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
    # 最新版本无需更新
    if [ "$sh_ver" == "$sh_new_ver" ]; then
        echo -e "当前版本：[ ${Green}${sh_ver}${Reset} ]"
        echo -e "最新版本：[ ${Green}${sh_new_ver}${Reset} ]"
        echo -e "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
    fi
    echo -e "${Green}检查到已有新版本${Reset}"
    echo -e "当前版本：[ ${Green}${sh_ver}${Reset} ]"
    echo -e "最新版本：[ ${Green}${sh_new_ver}${Reset} ]"
    # 开始更新
    while true; do
        read -p "是否升级到最新版本？(y/n)：" confirm
        case $confirm in
            [Yy]* )
                echo -e "开始下载最新版本 [ ${Green}${sh_new_ver}${Reset} ]"
                wget -O realm-cdn.sh --no-check-certificate "$sh_ver_url"
                chmod +x realm-cdn.sh
                echo -e "更新完成，当前版本已更新为 ${Green}[ v${sh_new_ver} ]${Reset}"
                echo -e "5 秒后执行新脚本"
                sleep 5s
                bash realm-cdn.sh
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

# 安装服务
Install() {
    # 检查是否安装 
    if [ -f "$FILE" ]; then
        echo -e "${Green}realm 已经安装${Reset}"
        Start_Main
    fi
    # 更新系统
    apt update && apt dist-upgrade -y
    # 安装插件
    apt-get install unzip curl git wget -y
    # 创建文件夹
    mkdir -p $FOLDERS && cd $FOLDERS || { echo -e "${Red}创建或进入 $FOLDERS 目录失败${Reset}"; exit 1; }
    # 获取架构
    Get_the_schema
    echo -e "当前架构：[ ${Green}${ARCH_RAW}${Reset} ]"
    # 获取版本信息
    VERSION_URL="https://api.github.com/repos/zhboner/realm/releases/latest"
    VERSION=$(curl -sSL "$VERSION_URL" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//' || { echo -e "${Red}获取版本信息失败${Reset}"; exit 1; })
    # 构造文件名
    case "$ARCH" in
        'aarch64' | 'armv7' | 'x86_64') FILENAME="realm-${ARCH}-unknown-linux-gnu.tar.gz";;
        *)       echo -e "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
    esac
    # 开始下载
    DOWNLOAD_URL="https://github.com/zhboner/realm/releases/download/v${VERSION}/${FILENAME}"
    echo -e "当前版本：[ ${Green}${VERSION}${Reset} ]"
    wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red}下载失败${Reset}"; exit 1; }
    # 解压文件
    tar -xzvf "$FILENAME" && rm -f "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
    # 授权
    chmod 755 realm
    # 记录版本信息
    echo "$VERSION" > "$VERSION_FILE"
    # 下载配置文件
    echo -e "${Green}开始下载 realm 配置文件${Reset}"
    CONFIG_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Config/config.toml"
    wget -O "$CONFIG_FILE" "$CONFIG_URL" || { echo -e "${Red}下载配置文件失败${Reset}"; exit 1; }
    # 下载系统配置文件
    echo -e "${Green}开始下载 realm 的 Service 系统配置${Reset}"
    SERVICE_URL="https://raw.githubusercontent.com/AdsJK567/Tools/main/Service/realm.service"
    wget -O "$SYSTEM_FILE" "$SERVICE_URL" && chmod 755 "$SYSTEM_FILE"
    echo -e "${Green}realm 安装完成${Reset}"
    # 重新加载 systemd
    systemctl daemon-reload
    # 立即启动 realm 服务
    systemctl start realm
    # # 检查 realm 服务状态
    # systemctl status realm
    echo -e "${Green}已设置开机自启${Reset}"
    # 设置开机启动
    systemctl enable realm
    Start_Main
}

# 更新
Update() {
    # 检查是否安装
    Check_install
    echo -e "${Green}开始检查是否有更新${Reset}"
    cd $FOLDERS
    # 获取当前版本
    CURRENT_VERSION=$(Get_current_version)
    # 获取版本信息
    VERSION_URL="https://api.github.com/repos/zhboner/realm/releases/latest"
    VERSION=$(curl -sSL "$VERSION_URL" | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//' || { echo -e "${Red}获取版本信息失败${Reset}"; exit 1; })
    # 开始更新
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
        echo -e "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
        echo -e "${Green}当前已是最新版本，无需更新${Reset}"
        Start_Main
    fi
    echo -e "${Green}检查到已有新版本${Reset}"
    echo -e "当前版本：[ ${Green}${CURRENT_VERSION}${Reset} ]"
    echo -e "最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
    while true; do
        read -p "是否升级到最新版本？(y/n)：" confirm
        case $confirm in
            [Yy]* )
                # 获取架构
                Get_the_schema
                # 构造文件名
                case "$ARCH" in
                    'aarch64' | 'armv7' | 'x86_64') FILENAME="realm-${ARCH}-unknown-linux-gnu.tar.gz";;
                    *)       echo -e "不支持的架构：[ ${Red}${ARCH}${Reset} ]"; exit 1;;
                esac
                # 开始下载
                DOWNLOAD_URL="https://github.com/zhboner/realm/releases/download/v${VERSION}/${FILENAME}"
                echo -e "开始下载最新版本：[ ${Green}${LATEST_VERSION}${Reset} ]"
                wget -t 3 -T 30 "${DOWNLOAD_URL}" -O "${FILENAME}" || { echo -e "${Red}下载失败${Reset}"; exit 1; }
                echo -e "[ ${Green}${LATEST_VERSION}${Reset} ] 下载完成，开始更新"
                # 解压文件
                tar -xzvf "$FILENAME" && rm -f "$FILENAME" || { echo -e "${Red}解压失败${Reset}"; exit 1; }
                # 授权
                chmod 755 realm
                # 更新版本信息
                echo "$LATEST_VERSION" > "$VERSION_FILE"
                # 重新加载 systemd
                systemctl daemon-reload
                # 重启 realm 服务
                systemctl restart realm
                echo -e "更新完成，当前版本已更新为：[ ${Green}${LATEST_VERSION}${Reset} ]"
                # 检查并显示服务状态
                if systemctl is-active --quiet realm; then
                    echo -e "当前状态：[ ${Green}运行中${Reset} ]"
                else
                    echo -e "当前状态：[ ${Red}未运行${Reset} ]"
                    Start_Main
                fi
                Start_Main
                ;;
            [Nn]* )
                echo -e "${Red}更新已取消 ${Reset}"
                Start_Main
                ;;
            * )
                echo -e "${Red}无效的输入，请输入 y 或 n ${Reset}"
                ;;
        esac
    done
    Start_Main
}

# 主菜单
Main() {
    clear
    echo "================================="
    echo -e "${Green}欢迎使用 realm 一键脚本 Beta 加速版${Reset}"
    echo -e "${Green}作者：${Reset}${Red}AdsJK567${Reset}"
    echo -e "${Green}请保证科学上网已经开启${Reset}"
    echo -e "${Green}安装过程中可以按 ctrl+c 强制退出${Reset}"
    echo "================================="
    echo -e "${Green}0${Reset}、更新脚本"
    echo "---------------------------------"
    echo -e "${Green}1${Reset}、安装 realm"
    echo -e "${Green}2${Reset}、更新 realm"
    echo -e "${Green}3${Reset}、卸载 realm"
    echo "---------------------------------"
    echo -e "${Green}5${Reset}、启动 realm"
    echo -e "${Green}6${Reset}、停止 realm"
    echo -e "${Green}7${Reset}、重启 realm"
    echo -e "${Green}8${Reset}、退出脚本"
    echo "================================="
    Show_Status
    echo "================================="
    read -p "请输入选项[0-8]：" num
    case "$num" in
        1) Install ;;
        2) Update ;;
        3) Uninstall ;;
        5) Start ;;
        6) Stop ;;
        7) Restart ;;
        8) exit 0 ;;
        0) Update_Shell ;;
        *) echo -e "${Red}无效选项，请重新选择${Reset}" 
           exit 1 ;;
    esac
}

# 启动主菜单
Main
