#!/bin/bash
#
# Copyright (c) 2019-2026 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 1. (可选) 添加第三方插件源
# 如果官方源的插件不满足你，可以取消下面这一行的注释来添加常用的大神源
# echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >> feeds.conf.default
# echo 'src-git small https://github.com/kenzok8/small' >> feeds.conf.default

# 2. 确保使用官方 25.12 的核心源 (通常源码自带，此处为双重保险)
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# 3. 示例：如果你有特定的私有包，可以在这里添加
# echo 'src-git my_packages https://github.com/your_username/my_repo' >> feeds.conf.default

echo "DIY-Part1 脚本执行完毕，插件源已就绪。"
