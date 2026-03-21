# ── utils: 颜色、读写、UUID、proxy 解析 ───────────────────────

_read()   { [[ -f "$1" ]] && tr -d '[:space:]' < "$1" || echo "${2:-}"; }
_bold()   { printf '\033[1m%s\033[0m' "$*"; }
_green()  { printf '\033[32m%s\033[0m' "$*"; }
_red()    { printf '\033[31m%s\033[0m' "$*"; }
_yellow() { printf '\033[33m%s\033[0m' "$*"; }

_detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

_new_uuid()    { uuidgen | tr '[:lower:]' '[:upper:]'; }
_new_sid()     { uuidgen | tr '[:upper:]' '[:lower:]'; }
_new_user_id() { python3 -c "import os; print(os.urandom(32).hex())"; }
_new_machine_id() { uuidgen | tr -d '-' | tr '[:upper:]' '[:lower:]'; }
_new_hostname() { echo "host-$(uuidgen | cut -d- -f1 | tr '[:upper:]' '[:lower:]')"; }
_new_mac() { od -An -tx1 -N5 /dev/urandom | awk '{printf "02:%s:%s:%s:%s:%s",$1,$2,$3,$4,$5}'; }

# host:port:user:pass → http://user:pass@host:port
# 或直接传入完整 URL（http://、https://、socks5://）
_parse_proxy() {
    local raw="$1"
    # 如果已经是完整 URL，直接返回
    if [[ "$raw" =~ ^(http|https|socks5):// ]]; then
        echo "$raw"
        return
    fi
    # 否则解析 host:port:user:pass 格式
    local host port user pass
    host=$(echo "$raw" | cut -d: -f1)
    port=$(echo "$raw" | cut -d: -f2)
    user=$(echo "$raw" | cut -d: -f3)
    pass=$(echo "$raw" | cut -d: -f4)
    if [[ -z "$user" ]]; then
        echo "http://${host}:${port}"
    else
        echo "http://${user}:${pass}@${host}:${port}"
    fi
}

# socks5://user:pass@host:port → host:port
_proxy_host_port() {
    echo "$1" | sed 's|.*@||' | sed 's|.*://||'
}

_proxy_reachable() {
    local hp host port
    hp=$(_proxy_host_port "$1")
    host=$(echo "$hp" | cut -d: -f1)
    port=$(echo "$hp" | cut -d: -f2)
    (echo >/dev/tcp/"$host"/"$port") 2>/dev/null
}

_current_env()  { _read "$CAC_DIR/current"; }
_env_dir()      { echo "$ENVS_DIR/$1"; }

_require_setup() {
    [[ -f "$CAC_DIR/real_claude" ]] || {
        echo "错误：请先运行 'cac setup'" >&2; exit 1
    }
}

_require_env() {
    [[ -d "$ENVS_DIR/$1" ]] || {
        echo "错误：环境 '$1' 不存在，用 'cac ls' 查看" >&2; exit 1
    }
}

_find_real_claude() {
    PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$CAC_DIR/bin" | tr '\n' ':') \
        command -v claude 2>/dev/null || true
}

_update_statsig() {
    local statsig="$HOME/.claude/statsig"
    [[ -d "$statsig" ]] || return 0
    for f in "$statsig"/statsig.stable_id.*; do
        [[ -f "$f" ]] && printf '"%s"' "$1" > "$f"
    done
}

_update_claude_json_user_id() {
    local user_id="$1"
    local claude_json="$HOME/.claude.json"
    [[ -f "$claude_json" ]] || return 0
    python3 - "$claude_json" "$user_id" << 'PYEOF'
import json, sys
fpath, uid = sys.argv[1], sys.argv[2]
with open(fpath) as f:
    d = json.load(f)
d['userID'] = uid
with open(fpath, 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
PYEOF
    [[ $? -eq 0 ]] || echo "警告：更新 ~/.claude.json userID 失败" >&2
}
