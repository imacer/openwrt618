#!/bash
# 1. 修改内核版本为 6.18
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' target/linux/x86/Makefile

# 2. 修改默认 IP (可选，默认为 192.168.1.1)
# sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 3. 强制移除默认 dnsmasq 并集成 dnsmasq-full
sed -i 's/dnsmasq //g' include/target.mk

# 4. 写入软件包配置到 .config
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
CONFIG_PACKAGE_dnsmasq_full_dnssec=y
CONFIG_PACKAGE_dnsmasq_full_ipset=y
CONFIG_PACKAGE_dnsmasq_full_nftset=y

# 透明代理内核模块
CONFIG_PACKAGE_kmod-nft-socket=y
CONFIG_PACKAGE_kmod-nft-tproxy=y

# 磁盘管理
CONFIG_PACKAGE_cfdisk=y
CONFIG_PACKAGE_block-mount=y

# 兼容性工具
CONFIG_PACKAGE_iptables-zz-legacy=y
CONFIG_PACKAGE_ipset=y

# 界面汉化
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
EOF

# 5. 解决内核配置冲突 (针对 6.18)
# 这一步会尝试同步 6.12 的配置作为 6.18 的基础
if [ ! -f target/linux/x86/config-6.18 ]; then
    cp target/linux/x86/config-6.12 target/linux/x86/config-6.18 || true
fi
