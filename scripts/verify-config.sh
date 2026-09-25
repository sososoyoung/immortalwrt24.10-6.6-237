#!/usr/bin/env bash

set -euo pipefail

source_id=${1:?source id is required}
config_file=${2:-.config}

required_packages=(
  pbr
  luci-app-pbr
  luci-i18n-pbr-zh-cn
  luci-app-ddns
  luci-proto-wireguard
  luci-app-acme
  luci-app-wol
  luci-app-msd_lite
  luci-app-upnp
)

case "$source_id" in
  lede)
    required_packages+=(luci-app-turboacc)
    ;;
  padavan|rebase)
    required_packages+=(luci-app-turboacc-mtk)
    ;;
  *)
    echo "Unsupported source id: $source_id" >&2
    exit 1
    ;;
esac

selected_devices=$(grep '^CONFIG_TARGET_.*_DEVICE_.*=y$' "$config_file" || true)
selected_device_count=$(grep -c '^CONFIG_TARGET_.*_DEVICE_.*=y$' "$config_file" || true)
if [ "$selected_device_count" -ne 1 ] || \
  [ "$selected_devices" != 'CONFIG_TARGET_mediatek_filogic_DEVICE_jcg_q30-pro=y' ]; then
  printf 'Configuration must select only jcg_q30-pro; selected: %s\n' \
    "${selected_devices:-none}" >&2
  exit 1
fi

missing=()
for package in "${required_packages[@]}"; do
  if ! grep -q "^CONFIG_PACKAGE_${package}=y$" "$config_file"; then
    missing+=("$package")
  fi
done

if [ "${#missing[@]}" -ne 0 ]; then
  printf 'Required packages missing after defconfig: %s\n' "${missing[*]}" >&2
  exit 1
fi

legacy_packages=$(grep -E '^CONFIG_PACKAGE_.*mwan3.*=[ym]$' "$config_file" || true)
if [ -n "$legacy_packages" ]; then
  printf 'mwan3 packages must be disabled when building with PBR:\n%s\n' \
    "$legacy_packages" >&2
  exit 1
fi

printf 'Verified %s: jcg_q30-pro, PBR and required LuCI packages are enabled; mwan3 is disabled.\n' "$source_id"
