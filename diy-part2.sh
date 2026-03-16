#!/bin/bash

# 1. 强制修改内核版本为 6.18
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' target/linux/x86/Makefile

# 2. 移除默认 dnsmasq 避免冲突
sed -i 's/dnsmasq //g' include/target.mk

# 3. 核心软件包集成 (写入 .config)
cat >> .config <<EOF
# 基础架构
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y

# 核心安全与证书
CONFIG_PACKAGE_libustream-openssl=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y

# 网络组件 (Dnsmasq-full)
CONFIG_PACKAGE_dnsmasq_full=y
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_dnsmasq_full_ipset=y
CONFIG_PACKAGE_dnsmasq_full_nftset=y

# 透明代理内核模块 (6.18 内核支持)
CONFIG_PACKAGE_kmod-nft-socket=y
CONFIG_PACKAGE_kmod-nft-tproxy=y

# 磁盘与挂载工具
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_block-mount=y

# 界面与兼容性
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_iptables-zz-legacy=y
CONFIG_PACKAGE_ipset=y

# 增大固件分区空间 (建议，否则内核太大可能装不下)
CONFIG_TARGET_KERNEL_PARTSIZE=64
CONFIG_TARGET_ROOTFS_PARTSIZE=512
EOF

# 4. 内核配置文件适配
# 由于 6.18 没有官方补丁，我们借用 6.12 的配置作为模板
if [ -d target/linux/x86/config-6.12 ]; then
    cp -r target/linux/x86/config-6.12 target/linux/x86/config-6.18
else
    # 如果是更旧的分支
    cp target/linux/x86/config-6.6 target/linux/x86/config-6.18 || true
fi
