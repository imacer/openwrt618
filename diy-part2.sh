#!/bin/bash

# --- 内核升级 6.18 逻辑 ---
# 1. 强制内核版本
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' target/linux/x86/Makefile
# 2. 跳过 Hash 校验 (因为 6.18 的哈希不在官方库中)
sed -i 's/HASH:=.*/HASH:=skip/g' include/kernel-defaults.mk
# 3. 移除旧补丁以防冲突 (6.18 采用原生编译)
rm -rf target/linux/generic/backport-6.*
rm -rf target/linux/generic/pending-6.*
rm -rf target/linux/generic/hack-6.*
# 4. 复制内核配置模板
cp target/linux/x86/config-6.12 target/linux/x86/config-6.18 || cp target/linux/x86/config-6.6 target/linux/x86/config-6.18

# --- 软件包与镜像配置 ---
# 5. 移除冲突包
sed -i 's/dnsmasq //g' include/target.mk

# 6. 写入 .config 配置文件
cat >> .config <<EOF
# 目标设备设定
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y

# 镜像格式：生成你需要的 squashfs-combined-efi
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_GRUB_EFI_IMAGES=y
CONFIG_GRUB_IMAGES=y
CONFIG_TARGET_IMAGES_GZIP=y

# 核心安全与证书
CONFIG_PACKAGE_libustream-openssl=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y

# 网络组件 (Dnsmasq-full)
CONFIG_PACKAGE_dnsmasq_full=y
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_dnsmasq_full_ipset=y
CONFIG_PACKAGE_dnsmasq_full_nftset=y
CONFIG_PACKAGE_dnsmasq_full_tproxy=y

# 内核模块
CONFIG_PACKAGE_kmod-nft-socket=y
CONFIG_PACKAGE_kmod-nft-tproxy=y

# 磁盘管理与兼容性
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_iptables-zz-legacy=y
CONFIG_PACKAGE_ipset=y

# 汉化
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y

# 分区大小调整 (建议值，EFI 模式需要更大的引导分区)
CONFIG_TARGET_KERNEL_PARTSIZE=128
CONFIG_TARGET_ROOTFS_PARTSIZE=800
EOF
