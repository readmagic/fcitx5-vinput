#!/bin/bash
# 本地构建 Debian 包脚本
# 适用于 Debian 12 和 Ubuntu 22.04
# 作者: Frandy

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== fcitx5-vinput Debian 包构建脚本 ===${NC}"

# 检查依赖
echo -e "${YELLOW}检查构建依赖...${NC}"
MISSING_DEPS=()

check_package() {
    if ! dpkg -l "$1" 2>/dev/null | grep -q "^ii"; then
        MISSING_DEPS+=("$1")
    fi
}

check_package "cmake"
check_package "ninja-build"
check_package "pkg-config"
check_package "gettext"
check_package "dpkg-dev"
check_package "libcurl4-openssl-dev"
check_package "libpipewire-0.3-dev"
check_package "libsystemd-dev"
check_package "libfcitx5core-dev"
check_package "libfcitx5config-dev"
check_package "libfcitx5utils-dev"
check_package "fcitx5-modules-dev"
check_package "nlohmann-json3-dev"

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${RED}缺少以下构建依赖:${NC}"
    printf '%s\n' "${MISSING_DEPS[@]}"
    echo ""
    echo -e "${YELLOW}请运行以下命令安装:${NC}"
    echo "sudo apt-get update"
    echo "sudo apt-get install -y ${MISSING_DEPS[*]}"
    exit 1
fi

echo -e "${GREEN}所有依赖已满足${NC}"

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

# 清理旧的构建
echo -e "${YELLOW}清理旧的构建文件...${NC}"
rm -rf build dist

# 创建构建目录
mkdir -p build

# 配置 CMake
echo -e "${YELLOW}配置 CMake...${NC}"
cmake -S . -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr

# 构建
echo -e "${YELLOW}开始构建...${NC}"
cmake --build build

# 打包
echo -e "${YELLOW}生成 Debian 包...${NC}"
mkdir -p dist
cpack --config build/CPackConfig.cmake -G DEB -B dist

# 查找生成的包
DEB_FILE=$(find dist -maxdepth 1 -name '*.deb' -print -quit)

if [ -z "${DEB_FILE}" ]; then
    echo -e "${RED}错误: 未找到生成的 .deb 包${NC}"
    exit 1
fi

echo -e "${GREEN}构建成功!${NC}"
echo -e "生成的包: ${GREEN}${DEB_FILE}${NC}"
echo ""
echo -e "${YELLOW}安装命令:${NC}"
echo "sudo dpkg -i ${DEB_FILE}"
echo ""
echo -e "${YELLOW}如果遇到依赖问题，运行:${NC}"
echo "sudo apt-get install -f"
