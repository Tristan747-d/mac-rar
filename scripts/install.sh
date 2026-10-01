#!/bin/zsh
# mac-rar 一键安装脚本
# 为访达添加右键「解压 RAR」，并在系统中注册 .rar UTI
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> 1/4 检查依赖"
if [ ! -x "$HOME/bin/unrar" ]; then
  echo "    未找到 ~/bin/unrar，开始下载 unrar 源码并编译（约 30 秒）..."
  TMP=$(mktemp -d)
  curl -sL -o "$TMP/unrar.tar.gz" https://www.rarlab.com/rar/unrarsrc-7.1.6.tar.gz
  tar xzf "$TMP/unrar.tar.gz" -C "$TMP"
  make -C "$TMP/unrar" -j8 >/dev/null
  mkdir -p "$HOME/bin"
  cp "$TMP/unrar/unrar" "$HOME/bin/unrar"
  rm -rf "$TMP"
  echo "    unrar 7.11 已安装到 ~/bin/unrar"
else
  echo "    已有 ~/bin/unrar，跳过"
fi

if [ ! -x /opt/homebrew/bin/7z ]; then
  echo "    提示：未检测到 /opt/homebrew/bin/7z（7z 兜底引擎）"
  echo "    可运行 brew install p7zip 安装；没有它 unrar 也能正常工作"
else
  echo "    已有 7z 兜底引擎，跳过"
fi

echo "==> 2/4 安装访达快速操作"
mkdir -p "$HOME/Library/Services"
rm -rf "$HOME/Library/Services/解压 RAR.workflow"
cp -R "$SCRIPT_DIR/解压 RAR.workflow" "$HOME/Library/Services/"
echo "    已安装到 ~/Library/Services/解压 RAR.workflow"

echo "==> 3/4 注册 .rar UTI"
APP="$HOME/Library/Application Support/RARFix"
rm -rf "$APP"
mkdir -p "$APP"
cp -R "$SCRIPT_DIR/RARFixer.app" "$APP/"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP/RARFixer.app"
echo "    .rar 已绑定 com.rarlab.rar-archive UTI"

echo "==> 4/4 刷新服务缓存"
/System/Library/CoreServices/pbs -flush
killall Finder 2>/dev/null || true

echo ""
echo "✅ 安装完成！右键 RAR 文件 → 快速操作 → 解压 RAR"
echo "   输出位置：压缩包同目录的「文件名 — 解压」文件夹"
