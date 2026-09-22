#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

set -euo pipefail

# 当前配置没有启用 luci-app-lucky 或 luci-app-openlist2，因此不再下载未使用的
# 第三方源码。三个上游均直接使用各自 feeds.conf.default，以减少交叉版本问题。
echo "Using default feeds for ${SOURCE_ID:-unknown}"
