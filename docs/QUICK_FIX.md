# 快速修复指南

## 问题
Debian 包在 Debian 12 / Ubuntu 22.04 上无法安装，提示依赖错误。

## 解决方案
已修改构建配置以兼容旧版本系统。

## 立即使用

### 方法 1: 等待新版本发布

下一个版本（v0.1.7+）将自动兼容 Debian 12 和 Ubuntu 22.04。

### 方法 2: 本地构建

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/fcitx5-vinput.git
cd fcitx5-vinput

# 构建
./scripts/build-deb-local.sh

# 安装
sudo dpkg -i dist/fcitx5-vinput_*.deb
sudo apt-get install -f
```

## 修改内容

1. ✅ 降低依赖版本要求
2. ✅ 支持新旧包名（t64 过渡）
3. ✅ 改用 Ubuntu 22.04 构建环境
4. ✅ 添加本地构建脚本

## 支持的系统

- ✅ Debian 12 (Bookworm)
- ✅ Ubuntu 22.04 LTS
- ✅ Ubuntu 23.04+
- ✅ Ubuntu 24.04 LTS

## 需要帮助？

查看详细文档：
- [docs/DEBIAN_COMPAT.md](DEBIAN_COMPAT.md) - 技术细节
- [docs/COMPAT_FIX_SUMMARY.md](COMPAT_FIX_SUMMARY.md) - 修改总结
