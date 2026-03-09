# Debian/Ubuntu 兼容性构建说明

## 问题描述

原先的构建流程在 Ubuntu 24.04 上进行，导致生成的 .deb 包依赖了较新版本的系统库，无法在 Debian 12 或 Ubuntu 22.04 上安装。

主要依赖冲突：
- `libc6 >= 2.38` (Debian 12 只有 2.36)
- `libcurl4t64` (Ubuntu 24.04 的 t64 过渡包)
- `libfcitx5* >= 5.1.7` (Debian 12 只有 5.0.21)
- `libpipewire-0.3-0t64` (t64 过渡包)
- `libstdc++6 >= 13.1` (Debian 12 只有 12.2.0)

主要 API 兼容性问题：
- `fcitx::Key::digitSelection()` 方法在 fcitx5 5.0.x 中不存在（5.1.x 引入）

## 解决方案

### 1. 修改 CMakeLists.txt

在 `CMakeLists.txt` 中手动指定了兼容的依赖版本：

```cmake
set(CPACK_DEBIAN_PACKAGE_DEPENDS "fcitx5, libc6 (>= 2.34), libcurl4 (>= 7.16.2) | libcurl4t64 (>= 7.16.2), libfcitx5config6 (>= 5.0.0), libfcitx5core7 (>= 5.0.0), libfcitx5utils2 (>= 5.0.0), libpipewire-0.3-0 (>= 0.3.6) | libpipewire-0.3-0t64 (>= 0.3.6), libstdc++6 (>= 12), libsystemd0")
```

关键改动：
- 降低 `libc6` 要求到 2.34（Debian 12 和 Ubuntu 22.04 都满足）
- 使用 `|` 语法支持新旧包名（如 `libcurl4 | libcurl4t64`）
- 降低 `libfcitx5*` 要求到 5.0.0
- 降低 `libstdc++6` 要求到 12

### 2. 修改 GitHub Actions 工作流

将构建环境从 `ubuntu-24.04` 改为 `ubuntu-22.04`，确保生成的二进制文件兼容旧版本系统。

### 3. 代码兼容性修复

在 `src/addon/vinput.cpp` 中添加了 `GetDigitSelection()` 函数，兼容 fcitx5 5.0.x：

```cpp
// 兼容 fcitx5 5.0.x：实现 digitSelection 功能
int GetDigitSelection(const fcitx::Key& key) {
    if (key.states() != fcitx::KeyState::NoState) {
        return -1;
    }
    const auto sym = key.sym();
    if (sym >= FcitxKey_0 && sym <= FcitxKey_9) {
        return (sym - FcitxKey_0 + 9) % 10;
    }
    if (sym >= FcitxKey_KP_0 && sym <= FcitxKey_KP_9) {
        return (sym - FcitxKey_KP_0 + 9) % 10;
    }
    return -1;
}
```

### 4. 本地构建脚本

创建了 `scripts/build-deb-local.sh` 脚本，方便在本地进行测试构建。

## 使用方法

### 本地构建

```bash
# 运行构建脚本
./scripts/build-deb-local.sh

# 安装生成的包
sudo dpkg -i dist/fcitx5-vinput_*.deb

# 如果有依赖问题，运行
sudo apt-get install -f
```

### GitHub Actions 构建

推送 tag 时会自动触发构建：

```bash
git tag v0.1.7
git push origin v0.1.7
```

生成的包将命名为 `fcitx5-vinput_*_ubuntu22.04_amd64.deb`，兼容：
- Ubuntu 22.04 LTS
- Ubuntu 23.04+
- Debian 12 (Bookworm)
- Debian 13 (Trixie)

## 测试

在目标系统上测试安装：

```bash
# Debian 12
sudo dpkg -i fcitx5-vinput_*_ubuntu22.04_amd64.deb
sudo apt-get install -f

# Ubuntu 22.04
sudo dpkg -i fcitx5-vinput_*_ubuntu22.04_amd64.deb
sudo apt-get install -f
```

## 技术细节

### 依赖版本选择原则

1. **向后兼容**: 选择 Debian 12 和 Ubuntu 22.04 都满足的最低版本
2. **包名过渡**: 使用 `|` 语法同时支持新旧包名
3. **ABI 兼容**: 在 Ubuntu 22.04 上编译确保 ABI 兼容性

### 为什么不使用 SHLIBDEPS

虽然 `CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON` 可以自动检测依赖，但它会使用构建系统的确切版本，导致过于严格的依赖要求。手动指定依赖可以更好地控制兼容性范围。

## 作者

Frandy
