# mdfiles 同步功能速查表

## 常用命令

### 基础Git命令
```bash
# 添加文件
git add <文件>
git add .                      # 添加所有文件

# 提交更改
git commit -m "描述"

# 查看状态
git status
git status --short            # 简洁模式
```

### 同步脚本命令
```bash
# 自动同步（推荐）
./sync.sh                     # 或 ./sync.sh auto

# 推送更改
./sync.sh push

# 拉取更改
./sync.sh pull

# 查看状态
./sync.sh status

# 检查同步设置
./check-sync.sh
```

### 远程仓库操作
```bash
# 查看远程仓库
git remote -v

# 添加远程仓库
git remote add origin https://github.com/Chengjike/mdfiles.git

# 拉取远程更改
git pull origin main

# 推送本地更改
git push origin main
```

## 快速设置

### 新设备设置
```bash
# 克隆仓库
git clone https://github.com/Chengjike/mdfiles.git
cd mdfiles

# 安装同步功能
./setup-sync.sh

# 验证设置
./check-sync.sh
```

### 启用自动推送
```bash
# 启用
touch .auto-push-enabled

# 禁用
rm .auto-push-enabled

# 检查状态
[ -f .auto-push-enabled ] && echo "已启用" || echo "未启用"
```

## 故障排除

### 常见问题

**问题**: 同步失败
```bash
# 检查网络
ping github.com

# 检查认证
gh auth status

# 检查远程
git remote -v
```

**问题**: 有冲突
```bash
# 查看冲突
git status

# 手动解决冲突后
git add .
git commit -m "解决冲突"
./sync.sh push
```

**问题**: 权限错误
```bash
# 修复脚本权限
chmod +x sync.sh
chmod +x .git/hooks/post-commit
```

## 定时同步

### cron示例（每天凌晨2点）
```bash
0 2 * * * cd /path/to/mdfiles && ./sync.sh auto
```

### systemd定时器
```bash
# 启用每日同步
sudo systemctl enable mdfiles-sync.timer
sudo systemctl start mdfiles-sync.timer
```

## 工作流示例

### 日常使用
```bash
# 1. 从远程获取最新更改
./sync.sh pull

# 2. 编辑文件
vim my-note.md

# 3. 提交更改
git add my-note.md
git commit -m "更新笔记"

# 4. 推送到远程（如果启用了自动推送则自动完成）
./sync.sh push
```

### 多设备同步
1. **设备A**：编辑并推送
2. **设备B**：拉取最新更改
3. **设备B**：编辑并推送
4. **设备A**：拉取设备B的更改

## 高级功能

### 选择性同步
```bash
# 只同步特定文件
git add file1.md file2.md
git commit -m "更新特定文件"
./sync.sh push
```

### 查看同步历史
```bash
# 查看日志
tail -f sync.log

# 查看Git历史
git log --oneline -10
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
```

### 分支管理（高级）
```bash
# 创建功能分支
git checkout -b feature/new-feature

# 切换回主分支
git checkout main

# 合并分支
git merge feature/new-feature

# 删除分支
git branch -d feature/new-feature
```

## 安全提示

1. **定期备份**: 重要文件本地备份
2. **检查日志**: 定期查看sync.log
3. **监控状态**: 使用check-sync.sh定期检查
4. **更新令牌**: 定期更新GitHub访问令牌

---

**提示**: 更多详细信息请查看 [SYNC-README.md](./SYNC-README.md)