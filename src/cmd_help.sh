# ── cmd: help ──────────────────────────────────────────────────

cmd_help() {
cat <<EOF
$(_bold "cac") — Claude Anti-fingerprint Cloak

$(_bold "用法：")
  cac setup                         首次安装
  cac add <名字> <host:port:u:p>    添加新环境（需要 yes 确认）
  cac <名字>                        切换到指定环境
  cac ls                            列出所有环境
  cac check                         核查当前环境（代理 + 安全防护）
  cac stop                          临时停用，claude 裸跑
  cac -c                            恢复停用

$(_bold "代理格式：")
  host:port:user:pass    带认证的 SOCKS5
  host:port              无认证的 SOCKS5

$(_bold "安全防护：")
  NS 层级 DNS 拦截       拦截 statsig.anthropic.com 等遥测域名
  fetch 遥测拦截         替换原生 fetch，防止绕过 DNS 拦截
  多层环境变量保护       DO_NOT_TRACK / OTEL_SDK_DISABLED 等 12 层遥测阻断
  mTLS 客户端证书        自签 CA + 客户端证书 + https.globalAgent 注入

$(_bold "示例：")
  cac add us1 1.2.3.4:1080:username:password
  cac us1
  cac check
  cac stop

$(_bold "文件目录：")
  ~/.cac/bin/claude           wrapper（拦截所有 claude 调用）
  ~/.cac/shim-bin/            ioreg / hostname / ifconfig shim
  ~/.cac/cac-dns-guard.js     NS 层级 DNS 拦截 + DoH + mTLS 注入模块
  ~/.cac/blocked_hosts        HOSTALIASES 遥测域名拦截
  ~/.cac/ca/                  mTLS 自签 CA 证书
  ~/.cac/current              当前激活的环境名
  ~/.cac/envs/<name>/         各环境：proxy / uuid / stable_id / client_cert
EOF
}
