# JCG Q30 Pro 多源码固件构建

本项目通过 GitHub Actions 为 **JCG Q30 Pro** 构建 OpenWrt 固件。每次可以选择一个源码单独构建，也可以并行构建全部三个源码，成功后统一发布到 GitHub Release。

## 支持的源码

| Actions 选项 | 上游仓库 | 分支 | TurboACC 包 |
| --- | --- | --- | --- |
| `padavan` | [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) | `openwrt-24.10-6.6` | `luci-app-turboacc-mtk` |
| `lede` | [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) | `master` | `luci-app-turboacc` |
| `rebase` | [chasey-dev/immortalwrt-mt798x-rebase](https://github.com/chasey-dev/immortalwrt-mt798x-rebase) | `25.12` | `luci-app-turboacc-mtk` |

三个上游均使用 `mediatek/filogic/jcg_q30-pro` profile。工作流在 `make defconfig` 后会再次校验设备和核心插件；上游改名或移除包时，构建会直接失败并指出缺少的包，不会发布一个功能不完整的固件。

默认配置和包可用性的核对快照为 2026-09-23：padavan `ec9ef10`、LEDE `ab2f391`、rebase `cea9e56`。工作流使用上述活动分支的最新提交，因此未来上游变化仍以实际构建时的 `source-info` 为准。

## 核心 LuCI 能力

以下能力在三个构建中都强制开启：

| 功能 | 配置包 | padavan 默认 | LEDE 默认 | rebase 默认 |
| --- | --- | :---: | :---: | :---: |
| 策略路由 | `luci-app-pbr` | 否 | 否 | 否 |
| 动态 DNS | `luci-app-ddns` | 否 | 是 | 否 |
| WireGuard | `luci-proto-wireguard` | 否 | 否 | 否 |
| ACME 证书 | `luci-app-acme` | 否 | 否 | 否 |
| 网络唤醒 | `luci-app-wol` | 否 | 是 | 否 |
| 组播转发 | `luci-app-msd_lite` | 否 | 否 | 否 |
| UPnP | `luci-app-upnp` | 否 | 是 | 否 |
| TurboACC | 源码相关，见上表 | 否 | 是 | 否 |

三个构建均显式启用 `pbr`、`luci-app-pbr` 和 `luci-i18n-pbr-zh-cn`，关闭 mwan3 及其辅助插件。构建校验会拒绝残留的 mwan3 包选择，包括模块形式。这里仅预装 PBR 软件包，具体线路、Nikki 兼容和分流规则由路由器配置管理，不在固件中自动写入或启用。PBR 选包变更仍需在各上游的 `make defconfig` 后确认依赖和包可用性。

> LuCI 当前没有 `luci-app-wireguard`。WireGuard 的 Web 配置入口由 `luci-proto-wireguard` 提供，它会带入相应的 WireGuard 依赖。

“默认”是指对应上游在 JCG Q30 Pro 目标上的直接默认包。LEDE 的 router 默认集合额外自带 DDNS、UPnP、WOL 和通用 TurboACC；padavan 默认提供 LuCI 基础界面、包管理和 TTYD，rebase 默认提供 LuCI 基础界面。两个 ImmortalWrt 源码的 8 个核心能力都不是目标默认项，因此工作流显式补齐。

## 当前 padavan 配置与兼容处理

根目录 [`.config`](./.config) 继续作为 padavan 构建配置，以保留现有完整功能。当前启用的 `luci-app-*` 为：

- 核心：`acme`、`ddns`、`msd_lite`、`pbr`、`turboacc-mtk`、`upnp`、`wol`
- 通用/管理：`firewall`、`package-manager`、`ttyd`
- MTK/当前源码特有：`eqos-mtk`、`mtwifi-cfg`、`wrtbwmon`
- WireGuard 界面：`luci-proto-wireguard`

另外两个源码遵循“核心能力必须一致，额外插件只在兼容时保留”的规则：

| 当前额外插件 | LEDE | rebase | 处理方式 |
| --- | :---: | :---: | --- |
| `luci-app-firewall` | 有 | 有 | 两边显式开启 |
| `luci-app-package-manager` | 有 | 有 | 两边显式开启 |
| `luci-app-ttyd` | 有 | 有 | 两边显式开启 |
| `luci-app-eqos-mtk` | 无 | 有 | 仅 rebase 开启 |
| `luci-app-mtwifi-cfg` | 无 | 有 | 仅 rebase 开启 |
| `luci-app-wrtbwmon` | 无 | 无 | 仅 padavan 保留 |

与最早一次完整配置相比，当前已经关闭 `luci-app-argon-config`、`aria2`、`ddns-go`、`diskman`、`docker`、`dockerman`、`filetransfer`、`ksmbd`、`opkg`、`uhttpd` 和 `usb-printer` 等应用。旧脚本虽然还会下载 Lucky/OpenList2，但当前配置并未启用它们；现已移除这两个无效下载，避免增加网络失败点。Argon 主题本身仍保留。

## 手动构建

1. 打开仓库的 **Actions** 页面。
2. 选择 **Build JCG Q30 Pro**。
3. 点击 **Run workflow**。
4. 在 `source` 中选择 `padavan`、`lede`、`rebase` 或 `all`。

`repository_dispatch` 也支持相同的 `source` 值，参数放在 `client_payload.source` 中；未提供时默认构建 `all`。

## 产物与 Release

- 每个矩阵任务先上传名为 `jcg-q30-pro-<source>` 的临时 Artifact。
- 所有选中的源码构建成功后，Release 任务合并产物并只创建一个 Release。
- 每个文件都添加 `padavan-`、`lede-` 或 `rebase-` 前缀，避免三个上游的同名固件相互覆盖。
- 每个源码同时附带 `source-info`、`diffconfig` 和重新生成的 `SHA256SUMS`，便于确认上游 commit、实际配置和文件完整性。
- Release 标签格式为 `日期时间-jcg-q30-pro-选择-r运行编号`。

## 配置文件

| 文件 | 用途 |
| --- | --- |
| [`.config`](./.config) | padavan 当前完整配置 |
| [`configs/lede.config`](./configs/lede.config) | LEDE 最小配置片段 |
| [`configs/rebase.config`](./configs/rebase.config) | rebase 最小配置片段 |
| [`scripts/verify-config.sh`](./scripts/verify-config.sh) | `defconfig` 后的设备与核心插件校验 |

LEDE 和 rebase 使用最小配置片段，由各自源码的 `make defconfig` 补齐默认值和依赖。这样不会把某个上游的内核、驱动或私有包配置错误地复制到另一个上游。
