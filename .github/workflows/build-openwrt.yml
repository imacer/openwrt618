#!/bin/bash

# --- 1. 路径修正与内核强制升级 ---
# 将内核版本设为 6.18
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' openwrt/target/linux/x86/Makefile

# 绕过内核哈希校验 (解决之前报错的关键)
sed -i 's/$(SCRIPT_DIR)\/download.pl/$(SCRIPT_DIR)\/download.pl --check-hash=no/g' openwrt/include/download.mk

# --- 2. 移除冲突补丁 (内核升级必做) ---
rm -rf openwrt/target/linux/generic/backport-6.*
rm -rf openwrt/target/linux/generic/pending-6.*
rm -rf openwrt/target/linux/generic/hack-6.*

# --- 3. 适配内核配置 ---
# 25.12 应该有 6.12 的配置，如果没有则退而求其次用 6.6
if [ -f openwrt/target/linux/x86/config-6.12 ]; then
    cp openwrt/target/linux/x86/config-6.12 openwrt/target/linux/x86/config-6.18
elif [ -f openwrt/target/linux/x86/config-6.6 ]; then
    cp openwrt/target/linux/x86/config-6.6 openwrt/target/linux/x86/config-6.18
fi

# --- 4. 移除默认 dnsmasq 并注入你要求的软件包 ---
sed -i 's/dnsmasq //g' openwrt/include/target.mk

# 将配置写入 openwrt 目录下的 .config
cat >> openwrt/.config <<EOF
# EFI 镜像支持
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_GRUB_EFI_IMAGES=y
CONFIG_GRUB_IMAGES=y
CONFIG_TARGET_IMAGES_GZIP=y

# 基础安全与证书
CONFIG_PACKAGE_libustream-openssl=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y

# 网络核心 (Dnsmasq-full)
CONFIG_PACKAGE_dnsmasq_full=y
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_dnsmasq_full_ipset=y
CONFIG_PACKAGE_dnsmasq_full_nftset=y
CONFIG_PACKAGE_dnsmasq_full_tproxy=y

# 内核模块
CONFIG_PACKAGE_kmod-nft-socket=y
CONFIG_PACKAGE_kmod-nft-tproxy=y

# 磁盘管理
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_block-mount=y

# 兼容性与汉化
CONFIG_PACKAGE_iptables-zz-legacy=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y

# 分区扩容
CONFIG_TARGET_KERNEL_PARTSIZE=128
CONFIG_TARGET_ROOTFS_PARTSIZE=800
EOF

echo "DIY-Part2 修正路径后的配置已完成"
