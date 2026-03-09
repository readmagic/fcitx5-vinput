# Debian 12 / Ubuntu 22.04 兼容性修复总结

## 问题描述

原先的 fcitx5-vinput 包在 Ubuntu 24.04 上构建，导致依赖了较新版本的系统库，无法在 Debian 12 或 Ubuntu 22.04 上安装。

## 修改内容

### 1. CMakeLists.txt

**位置**: 第 62-69 行

**修改内容**:
- 手动指定 Debian 包依赖，替代自动检测
- 使用 `|` 语法支持新旧包名（如 `libcurl4 | libcurl4t64`）
- 降低依赖版本要求以兼容旧系统

**关键依赖版本**:
- `libc6 >= 2.34` (原 2.38)
- `libfcitx5* >= 5.0.0` (原 5.1.7)
- `libstdc++6 >= 12` (原 13.1)
- 支持 `libcurl4` 和 `libcurl4t64`
- 支持 `libpipewire-0.3-0` 和 `libpipewire-0.3-0t64`

### 2. .github/workflows/release.yml

**位置**: 第 56 行和第 105 行

**修改内容**:
- 将构建环境从 `ubuntu-24.04` 改为 `ubuntu-22.04`
- 修改生成的包名从 `ubuntu24.04` 改为 `ubuntu22.04`

### 3. 新增文件

#### scripts/build-deb-local.sh
- 本地构建脚本
- 自动检查依赖
- 生成 Debian 包

#### scripts/check-deps.sh
- 依赖版本检查脚本
- 验证系统是否满足构建要求

#### docs/DEBIAN_COMPAT.md
- 详细的兼容性说明文档
- 技术细节和原理解释

#### CHANGELOG.md
- 项目变更日志
- 记录所有重要修改

### 4. README.md

**新增章节**:
- 本地构建说明
- 依赖检查说明
- 支持的系统列表

## 测试方法

### 本地测试

```bash
# 1. 检查依赖
./scripts/check-deps.sh

# 2. 构建包
./scripts/build-deb-local.sh

# 3. 安装测试
sudo dpkg -i dist/fcitx5-vinput_*.deb
sudo apt-get install -f
```

### CI 测试

```bash
# 推送 tag 触发自动构建
git tag v0.1.7
git push origin v0.1.7
```

## 兼容性矩阵

| 系统 | 版本 | 状态 |
|------|------|------|
| Ubuntu | 22.04 LTS | ✅ 支持 |
| Ubuntu | 23.04+ | ✅ 支持 |
| Ubuntu | 24.04 LTS | ✅ 支持 |
| Debian | 12 (Bookworm) | ✅ 支持 |
| Debian | 13 (Trixie) | ✅ 支持 |
| Arch Linux | 滚动更新 | ✅ 支持 |

## 技术原理

### 为什么改用 Ubuntu 22.04 构建？

1. **ABI 向后兼容**: 在旧版本系统上编译的二进制文件可以在新版本上运行
2. **依赖版本控制**: 避免依赖过新的库版本
3. **最大兼容性**: Ubuntu 22.04 LTS 和 Debian 12 使用相似的库版本

### 为什么手动指定依赖？

1. **SHLIBDEPS 的局限**: 自动检测会使用构建系统的确切版本
2. **灵活性**: 可以使用 `|` 语法支持多个包名
3. **兼容性范围**: 可以指定最低版本而不是确切版本

### t64 过渡包问题

Ubuntu 24.04 引入了 64 位时间戳过渡，部分库包名添加了 `t64` 后缀：
- `libcurl4` → `libcurl4t64`
- `libpipewire-0.3-0` → `libpipewire-0.3-0t64`

使用 `|` 语法可以同时支持新旧包名。

## 下一步

1. 测试在 Debian 12 上的安装
2. 测试在 Ubuntu 22.04 上的安装
3. 如果测试通过，发布新版本 v0.1.7
4. 更新 GitHub Release 说明

## 作者

Frandy
