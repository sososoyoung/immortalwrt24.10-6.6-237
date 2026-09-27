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

# nikki（mihomo 透明代理 + LuCI 界面）通过官方 feed 集成，要求 OpenWrt >= 24.10
# 且使用 firewall4；三个源（24.10 基座 / lede master / 25.12）均满足。
# mihomo-meta 内核为本地 Go 源码编译（PROVIDES:=mihomo），依赖 packages feed
# 的 golang 与 yq，与 diy-part2.sh 的 padavan golang 覆盖使用相同路径。
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" \
  >> feeds.conf.default
