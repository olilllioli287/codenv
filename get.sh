#!/bin/zsh
# codenv 一行安裝 / 更新:把最新版下載到 ~/.codenv-kit,再執行裡面的 install.sh
# 用法: zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/get.sh)"
kit=~/.codenv-kit
tmp=$(mktemp -d) || exit 1
print "下載 codenv 最新版…"
if ! curl -fsSL https://github.com/olilllioli287/codenv/archive/refs/heads/main.tar.gz | tar -xz -C $tmp; then
  print "下載失敗,請確認網路連線後再試一次"
  rm -rf $tmp
  exit 1
fi
rm -rf $kit && mv $tmp/codenv-main $kit && rm -rf $tmp
zsh $kit/install.sh
