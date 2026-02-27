# mdfiles

Markdown 文件同步仓库

## GitHub 仓库
- **地址**: https://github.com/Chengjike/mdfiles
- **状态**: 已同步

## 同步功能

本仓库已配置自动同步功能，包含以下工具：

### 1. 同步脚本 (`sync.sh`)
多功能同步脚本，支持自动同步、推送、拉取和状态检查。

```bash
# 基本使用
./sync.sh           # 自动同步（默认）
./sync.sh push      # 推送本地更改
./sync.sh pull      # 拉取远程更改
./sync.sh status    # 查看同步状态
```

### 2. Git 钩子
可选自动推送功能，提交后自动推送到远程。

**启用自动推送**:
```bash
touch .auto-push-enabled
```

**禁用自动推送**:
```bash
rm .auto-push-enabled
```

### 3. 定时同步（可选）
支持 cron 或 systemd 定时器实现定期同步。

## 快速开始

1. **克隆仓库**:
   ```bash
   git clone https://github.com/Chengjike/mdfiles.git
   cd mdfiles
   ```

2. **添加文件**:
   ```bash
   # 添加你的markdown文件
   cp your-file.md .

   # 提交更改
   git add .
   git commit -m "添加新文件"
   ```

3. **同步到远程**:
   ```bash
   ./sync.sh push
   # 或启用自动推送后直接提交即可
   ```

## 详细文档
- [同步功能详细说明](./SYNC-README.md)
