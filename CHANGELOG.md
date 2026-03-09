# Changelog

所有重要的项目变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### Changed
- 修改 Debian 包依赖以兼容 Debian 12 和 Ubuntu 22.04
- 将 GitHub Actions 构建环境从 Ubuntu 24.04 改为 Ubuntu 22.04
- 手动指定包依赖版本，支持新旧包名（如 libcurl4/libcurl4t64）

### Added
- 添加本地构建脚本 `scripts/build-deb-local.sh`
- 添加依赖检查脚本 `scripts/check-deps.sh`
- 添加 Debian 兼容性文档 `docs/DEBIAN_COMPAT.md`
- 添加 `GetDigitSelection()` 函数以兼容 fcitx5 5.0.x

### Fixed
- 修复在 Debian 12 上无法安装的依赖问题
- 修复在 Ubuntu 22.04 上无法安装的依赖问题
- 修复在 fcitx5 5.0.x 上编译失败的问题（`Key::digitSelection()` 方法不存在）

## [0.1.6] - 2026-03-09

### Changed
- 在保存时规范化 LLM Base URL，而不是在请求层回退

### Added
- 添加 `.ace-tool/` 到 `.gitignore`

### Removed
- 移除许可证安装步骤

### Added
- 添加 GPL-3.0 许可证和第三方声明

## [0.1.5] 及更早版本

请参考 Git 提交历史。
