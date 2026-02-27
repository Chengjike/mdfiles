#!/bin/bash

# 同步功能验证脚本

echo "=== mdfiles 同步功能验证 ==="
echo

check_passed=0
check_failed=0

# 检查函数
check() {
    local description="$1"
    local command="$2"
    local expected="${3:-0}"

    echo -n "检查: $description ... "
    if eval "$command" &>/dev/null; then
        echo "✓ 通过"
        ((check_passed++))
        return 0
    else
        echo "✗ 失败"
        ((check_failed++))
        return 1
    fi
}

# 1. Git仓库检查
echo "--- Git仓库检查 ---"
check "当前目录是git仓库" "[ -d .git ]"
check "git命令可用" "git --version"

# 2. 远程仓库检查
echo -e "\n--- 远程仓库检查 ---"
check "已配置远程仓库" "git remote | grep -q origin"
if check "远程仓库可达" "git remote -v"; then
    echo "  远程URL: $(git remote get-url origin)"
fi

# 3. 同步脚本检查
echo -e "\n--- 同步脚本检查 ---"
check "同步脚本存在" "[ -f sync.sh ]"
check "同步脚本可执行" "[ -x sync.sh ]"
check "同步日志文件存在" "[ -f sync.log ]"

# 4. Git钩子检查
echo -e "\n--- Git钩子检查 ---"
check "post-commit钩子存在" "[ -f .git/hooks/post-commit ]"
check "post-commit钩子可执行" "[ -x .git/hooks/post-commit ]"
if [ -f .auto-push-enabled ]; then
    echo "  自动推送: ✓ 已启用"
else
    echo "  自动推送: ✗ 未启用 (可选)"
fi

# 5. GitHub CLI检查
echo -e "\n--- GitHub CLI检查 ---"
if command -v gh &>/dev/null; then
    check "GitHub CLI已安装" "true"
    if gh auth status &>/dev/null; then
        echo "  GitHub认证: ✓ 已认证"
        echo "  登录用户: $(gh api user -q .login 2>/dev/null || echo '未知')"
    else
        echo "  GitHub认证: ✗ 未认证 (可选)"
    fi
else
    echo "  GitHub CLI: ✗ 未安装 (可选)"
fi

# 6. 分支状态
echo -e "\n--- 分支状态检查 ---"
current_branch=$(git branch --show-current)
echo "  当前分支: $current_branch"
check "在主分支上" "[ \"$current_branch\" = \"main\" ]"

# 7. 同步测试
echo -e "\n--- 同步功能测试 ---"
echo "测试同步状态..."
./sync.sh status > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  同步脚本: ✓ 正常工作"
else
    echo "  同步脚本: ✗ 存在问题"
    ((check_failed++))
fi

# 总结
echo -e "\n=== 验证结果 ==="
echo "通过: $check_passed"
echo "失败: $check_failed"

if [ $check_failed -eq 0 ]; then
    echo "✓ 所有关键检查通过，同步功能正常"
    exit 0
else
    echo "✗ 发现 $check_failed 个问题"
    echo
    echo "建议:"
    if [ ! -d .git ]; then
        echo "  - 当前目录不是git仓库，请运行: git init"
    fi
    if ! git remote | grep -q origin; then
        echo "  - 未配置远程仓库，请运行: git remote add origin <仓库URL>"
    fi
    if [ ! -x sync.sh ]; then
        echo "  - 同步脚本不存在或不可执行，请从仓库获取: git pull origin main"
    fi
    exit 1
fi