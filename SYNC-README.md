# mdfiles 仓库同步功能

## 已实现的功能

### 1. GitHub 仓库
- 仓库地址: https://github.com/Chengjike/mdfiles
- 远程名称: origin
- 主分支: main

### 2. 同步脚本 (`sync.sh`)

这是一个多功能同步脚本，提供以下功能：

```bash
# 自动同步（先拉取后推送）
./sync.sh
./sync.sh auto

# 推送本地更改到远程
./sync.sh push

# 从远程拉取更改
./sync.sh pull

# 显示同步状态
./sync.sh status
```

**脚本特点**:
- 自动检测并提交未提交的更改
- 智能处理分支同步
- 日志记录到 `sync.log`
- 错误处理和状态报告

### 3. Git 钩子（可选自动推送）

已配置 `post-commit` 钩子，可以在每次提交后自动推送到远程。

**启用自动推送**:
```bash
# 创建启用标志文件
touch .auto-push-enabled

# 禁用自动推送
rm .auto-push-enabled
```

### 4. 手动同步示例

```bash
# 添加并提交所有更改
git add .
git commit -m "更新说明"

# 使用脚本推送
./sync.sh push

# 或直接推送
git push origin main
```

## 设置定时同步（可选）

### 使用 cron 定时同步

编辑 crontab:
```bash
crontab -e
```

添加以下行（每天凌晨2点自动同步）:
```
0 2 * * * cd /home/cjk-dev/cjk-workspace/mdfiles && ./sync.sh auto
```

### 使用 systemd 定时器（Linux）

创建服务文件 `/etc/systemd/system/mdfiles-sync.service`:
```ini
[Unit]
Description=mdfiles Sync Service

[Service]
Type=oneshot
User=cjk-dev
WorkingDirectory=/home/cjk-dev/cjk-workspace/mdfiles
ExecStart=/home/cjk-dev/cjk-workspace/mdfiles/sync.sh auto
```

创建定时器 `/etc/systemd/system/mdfiles-sync.timer`:
```ini
[Unit]
Description=Daily mdfiles Sync Timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

启用定时器:
```bash
sudo systemctl enable mdfiles-sync.timer
sudo systemctl start mdfiles-sync.timer
```

## 故障排除

### 1. 同步失败
- 检查网络连接
- 验证 GitHub 认证: `gh auth status`
- 检查远程仓库: `git remote -v`

### 2. 冲突处理
如果拉取时出现冲突:
```bash
# 查看冲突文件
git status

# 手动解决冲突后
git add .
git commit -m "解决冲突"
git push origin main
```

### 3. 权限问题
确保脚本有执行权限:
```bash
chmod +x sync.sh
chmod +x .git/hooks/post-commit
```

## 安全注意事项

1. **令牌安全**: GitHub 令牌存储在 `~/.config/gh/hosts.yml`
2. **日志文件**: 同步日志存储在 `sync.log`
3. **钩子安全**: 只有受信任的钩子才会被执行

## 扩展建议

1. **多设备同步**: 在不同设备上克隆此仓库，使用同步脚本保持一致性
2. **备份策略**: 定期导出仓库到其他存储服务
3. **监控**: 设置邮件通知同步状态