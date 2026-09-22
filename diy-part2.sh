#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

set -euo pipefail

# padavan 24.10 继续沿用当前项目已验证过的 Go 工具链覆盖；LEDE master 和
# rebase 25.12 必须使用各自 feed 中匹配的 Go 版本，不能套用 24.x 分支。
if [ "${SOURCE_ID:-}" = "padavan" ]; then
  rm -rf feeds/packages/lang/golang
  git clone --depth=1 --branch 24.x \
    https://github.com/sbwml/packages_lang_golang \
    feeds/packages/lang/golang
fi
