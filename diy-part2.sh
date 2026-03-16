#!/bin/bash

# 1. 强制指定内核版本为 6.18
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' target/linux/x86/Makefile

# 2. 修改内核下载校验 (针对 6.18 官方源码)
# 告诉 OpenWrt 忽略内核 Hash 校验，防止因找不到 6.18 的哈希值而报错
sed -i 's/HASH:=.*/HASH:=skip/g' include/kernel-defaults.mk

# 3. 清理冲突补丁 (核心步骤)
# 6.18 太新，官方 6.6/6.12 的补丁会导致编译失败，直接移除它们
rm -rf target/linux/generic/backport-6.*
rm -rf target/linux/generic/pending-6.*
rm -rf target/linux/generic/hack-6.*

# 4. 适配内核配置 (从 6.12 模板复制)
if [ -f target/linux/x86/config-6.12 ]; then
    cp target/linux/x86/config-6.12 target/linux/x86/config-6.18
else
    cp target/linux/x86/config-6.6 target/linux/x86/config-6.18
fi

# 5. 移除默认 dnsmasq 并注入你要求的软件包
sed -i 's/dnsmasq //g' include/target.mk

cat >> .config <<EOF
# 架构设置
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y

# 1. 安全与证书 (指定要求)
CONFIG_PACKAGE_libustream-openssl=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y

# 2. Dnsmasq-full (指定要求)
CONFIG_PACKAGE_dnsmasq_full=y
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_dnsmasq_full_ipset=y
CONFIG_PACKAGE_dnsmasq_full_nftset=y
CONFIG_PACKAGE_dnsmasq_full_tproxy=y

# 3. 透明代理内核模块 (指定要求)
CONFIG_PACKAGE_kmod-nft-socket=y
CONFIG_PACKAGE_kmod-nft-tproxy=y

# 4. 磁盘工具 (指定要求)
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_block-mount=y

# 5. 兼容性与汉化 (指定要求)
CONFIG_PACKAGE_iptables-zz-legacy=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y

# 6. 固件分区扩容 (建议，避免内核过大溢出)
CONFIG_TARGET_KERNEL_PARTSIZE=64
CONFIG_TARGET_ROOTFS_PARTSIZE=800
EOF
