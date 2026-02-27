#!/bin/bash

# mdfiles 同步功能安装脚本
# 在新设备上快速设置同步功能

set -e

echo "=== mdfiles 同步功能安装 ==="
echo

# 检查git
if ! command -v git &> /dev/null; then
    echo "错误: 需要安装 git"
    echo "请运行: sudo apt install git"
    exit 1
fi

# 检查是否在git仓库中
if [ ! -d ".git" ]; then
    echo "当前目录不是git仓库"
    read -p "是否要克隆mdfiles仓库? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在克隆仓库..."
        git clone https://github.com/Chengjike/mdfiles.git
        cd mdfiles
        echo "克隆完成，已切换到仓库目录"
    else
        echo "请在mdfiles仓库目录中运行此脚本"
        exit 1
    fi
fi

# 检查远程仓库配置
echo "检查远程仓库配置..."
if ! git remote | grep -q origin; then
    echo "未配置远程仓库"
    read -p "请输入远程仓库URL (默认: https://github.com/Chengjike/mdfiles.git): " remote_url
    remote_url=${remote_url:-"https://github.com/Chengjike/mdfiles.git"}
    git remote add origin "$remote_url"
    echo "已添加远程仓库: $remote_url"
fi

# 检查同步脚本
echo "检查同步脚本..."
if [ ! -f "sync.sh" ]; then
    echo "同步脚本不存在，从远程拉取..."
    git pull origin main || echo "注意: 可能需要先设置上游分支"
fi

# 设置执行权限
chmod +x sync.sh 2>/dev/null || true
chmod +x .git/hooks/post-commit 2>/dev/null || true

# 检查GitHub CLI
echo "检查GitHub CLI..."
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "✓ GitHub CLI 已认证"
    else
        echo "GitHub CLI 未认证"
        read -p "是否要现在认证? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
        fi
    fi
else
    echo "未安装GitHub CLI (可选)"
    echo "要安装请运行:"
    echo "  sudo apt install gh  # Ubuntu/Debian"
    echo "  或访问: https://github.com/cli/cli#installation"
fi

# 设置自动推送
echo
read -p "是否启用自动推送? (提交后自动推送到远程) (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    touch .auto-push-enabled
    echo "✓ 已启用自动推送"
else
    echo "自动推送未启用，可使用: touch .auto-push-enabled 启用"
fi

# 测试同步
echo
read -p "是否测试同步功能? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "测试同步..."
    ./sync.sh status
fi

echo
echo "=== 安装完成 ==="
echo
echo "使用说明:"
echo "1. 添加文件: git add <文件>"
echo "2. 提交更改: git commit -m '描述'"
echo "3. 同步到远程: ./sync.sh push"
echo "4. 从远程更新: ./sync.sh pull"
echo
echo "更多选项: ./sync.sh --help"
echo "详细文档: 查看 SYNC-README.md"