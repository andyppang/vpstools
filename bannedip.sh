#!/bin/bash

# 定义要使用的文件路径和名称
LOG_FILE="/var/log/auth.log"
DENY_FILE="/etc/hosts.deny"
SCRIPT_FILE="/root/bannedip.py"

# 编写Python脚本文件
cat <<EOF > $SCRIPT_FILE
import os

# 读取hosts.deny文件中已经拒绝的IP地址
with open("$DENY_FILE") as f:
    deny = f.read().split("\n")

# 读取auth.log文件中的日志
with open("$LOG_FILE") as f:
    log = f.read().split("\n")

# 存储要添加到hosts.deny文件中的IP地址
ipset = set()

# 从auth.log文件中提取所有失败的登录尝试的IP地址
for each in log:
    if 'Failed password' in each:
        ip = each.split(' from ')[1].split(' port ')[0]
        writein = 'ALL: ' + ip
        ipset.add(writein)

# 将新的IP地址添加到hosts.deny文件中
with open('$DENY_FILE', 'a') as f:
    for each in ipset:
        if each not in deny:
            print("Adding " + each + " to $DENY_FILE")
            f.write(each + '\n')
EOF

# 赋予Python脚本文件可执行权限
chmod +x $SCRIPT_FILE

# 添加crontab任务
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python3 $SCRIPT_FILE >> /var/log/bannedip.log 2>&1") | crontab -


echo "已添加bannedip任务到crontab中。"