#!/usr/bin/env bash
# install.sh — cac 一键安装脚本
set -euo pipefail

REPO="https://raw.githubusercontent.com/nmhjklnm/cac/master"
BIN_DIR="$HOME/bin"
CAC_BIN="$HOME/.cac/bin"

# 颜色
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red() { printf '\033[31m%s\033[0m\n' "$*"; }

echo "=== cac — Claude Code Cloak 安装 ==="
echo

# 1. 下载 cac 到 ~/bin
mkdir -p "$BIN_DIR"
printf "下载 cac ... "
curl -fsSL "$REPO/cac" -o "$BIN_DIR/cac"
chmod +x "$BIN_DIR/cac"
green "✓"

# 2. 写入 PATH（检测用哪个 rc 文件）
RC_FILE=""
if [[ -f "$HOME/.zshrc" ]]; then
    RC_FILE="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    RC_FILE="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    RC_FILE="$HOME/.bash_profile"
fi

if [[ -n "$RC_FILE" ]]; then
    if ! grep -q 'cac/bin' "$RC_FILE" 2>/dev/null; then
        printf "写入 PATH 到 %s ... " "$RC_FILE"
        cat >> "$RC_FILE" << 'EOF'

# cac — Claude Code Cloak
export PATH="$HOME/bin:$PATH"          # cac 命令
export PATH="$HOME/.cac/bin:$PATH"     # claude wrapper（必须最前）
EOF
        green "✓"
    else
        yellow "PATH 已存在，跳过"
    fi
else
    yellow "⚠ 未找到 shell 配置文件，请手动添加："
    echo '  export PATH="$HOME/bin:$PATH"'
    echo '  export PATH="$HOME/.cac/bin:$PATH"'
fi

# 3. 初始化 wrapper 和 fake ioreg
printf "初始化 ... "
export PATH="$BIN_DIR:$PATH"
"$BIN_DIR/cac" setup --quiet 2>/dev/null || "$BIN_DIR/cac" setup
green "✓"

echo
green "✓ 安装完成"
echo
echo "执行以下命令使配置生效："
echo "  source $RC_FILE"
echo
echo "然后添加第一个代理配置："
echo "  cac add <名字> <host:port:user:pass>"
