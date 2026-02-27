#!/bin/bash

# mdfiles 同步脚本
# 用法: ./sync.sh [push|pull|status]

set -e  # 遇到错误退出

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$REPO_DIR/sync.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理
error_exit() {
    log "错误: $1"
    exit 1
}

# 检查是否在git仓库中
check_git_repo() {
    if [ ! -d "$REPO_DIR/.git" ]; then
        error_exit "当前目录不是git仓库"
    fi
}

# 推送本地更改到远程
push_changes() {
    log "开始推送更改到远程仓库..."

    # 检查是否有未提交的更改
    if git status --porcelain | grep -q .; then
        log "检测到未提交的更改"

        # 添加所有文件
        git add .

        # 提交更改
        commit_msg="同步更新 $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$commit_msg" || {
            log "提交失败，可能没有实际更改"
            return 0
        }

        log "已提交更改: $commit_msg"
    else
        log "没有未提交的更改"
    fi

    # 推送到远程
    if git push origin main; then
        log "成功推送到远程仓库"
    else
        error_exit "推送失败"
    fi
}

# 从远程拉取更改
pull_changes() {
    log "开始从远程仓库拉取更改..."

    if git pull origin main; then
        log "成功从远程仓库拉取更改"
    else
        error_exit "拉取失败，可能有冲突需要手动解决"
    fi
}

# 显示同步状态
show_status() {
    log "检查同步状态..."

    echo "=== 本地仓库状态 ==="
    git status --short

    echo -e "\n=== 远程仓库信息 ==="
    git remote -v

    echo -e "\n=== 分支信息 ==="
    git branch -avv

    echo -e "\n=== 最新提交 ==="
    git log --oneline -5
}

# 自动同步（先拉取后推送）
auto_sync() {
    log "开始自动同步..."

    # 先拉取远程更改
    if git fetch origin; then
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        BASE=$(git merge-base @ @{u})

        if [ $LOCAL = $REMOTE ]; then
            log "本地与远程相同"
        elif [ $LOCAL = $BASE ]; then
            log "需要拉取远程更改"
            pull_changes
        elif [ $REMOTE = $BASE ]; then
            log "本地有未推送的更改"
            push_changes
        else
            log "分支出现分叉，需要手动合并"
            git pull --rebase origin main || {
                log "注意：有冲突需要手动解决"
                return 1
            }
            push_changes
        fi
    else
        log "无法获取远程信息，尝试推送"
        push_changes
    fi

    log "自动同步完成"
}

# 主函数
main() {
    check_git_repo

    cd "$REPO_DIR"

    case "${1:-auto}" in
        push)
            push_changes
            ;;
        pull)
            pull_changes
            ;;
        status)
            show_status
            ;;
        auto)
            auto_sync
            ;;
        *)
            echo "用法: $0 [push|pull|status|auto]"
            echo "  push    - 推送本地更改到远程"
            echo "  pull    - 从远程拉取更改"
            echo "  status  - 显示同步状态"
            echo "  auto    - 自动同步（默认）"
            exit 1
            ;;
    esac
}

main "$@"