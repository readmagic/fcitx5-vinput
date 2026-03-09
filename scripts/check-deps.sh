#!/bin/bash
# 验证 Debian 包依赖兼容性
# 作者: Frandy

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Debian 包依赖验证 ===${NC}"

# 检测系统版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${YELLOW}系统: ${NC}$PRETTY_NAME"
else
    echo -e "${RED}无法检测系统版本${NC}"
    exit 1
fi

# 检查关键依赖包版本
echo -e "\n${YELLOW}检查关键依赖包版本:${NC}"

check_version() {
    local pkg=$1
    local min_ver=$2

    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        local ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
        echo -e "  ${GREEN}✓${NC} $pkg: $ver (需要 >= $min_ver)"
    else
        echo -e "  ${RED}✗${NC} $pkg: 未安装 (需要 >= $min_ver)"
    fi
}

# 检查 libc6
check_version "libc6" "2.34"

# 检查 libcurl (可能是 libcurl4 或 libcurl4t64)
if dpkg -l "libcurl4t64" 2>/dev/null | grep -q "^ii"; then
    check_version "libcurl4t64" "7.16.2"
elif dpkg -l "libcurl4" 2>/dev/null | grep -q "^ii"; then
    check_version "libcurl4" "7.16.2"
else
    echo -e "  ${RED}✗${NC} libcurl4/libcurl4t64: 未安装"
fi

# 检查 fcitx5 相关库
check_version "libfcitx5config6" "5.0.0"
check_version "libfcitx5core7" "5.0.0"
check_version "libfcitx5utils2" "5.0.0"

# 检查 pipewire (可能是 libpipewire-0.3-0 或 libpipewire-0.3-0t64)
if dpkg -l "libpipewire-0.3-0t64" 2>/dev/null | grep -q "^ii"; then
    check_version "libpipewire-0.3-0t64" "0.3.6"
elif dpkg -l "libpipewire-0.3-0" 2>/dev/null | grep -q "^ii"; then
    check_version "libpipewire-0.3-0" "0.3.6"
else
    echo -e "  ${RED}✗${NC} libpipewire-0.3-0/libpipewire-0.3-0t64: 未安装"
fi

# 检查 libstdc++6
check_version "libstdc++6" "12"

# 检查 libsystemd0
check_version "libsystemd0" "0"

echo -e "\n${GREEN}验证完成${NC}"
