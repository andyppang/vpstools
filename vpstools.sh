#!/bin/bash

# 控制台字体
green() {
	echo -e "\033[32m\033[01m$1\033[0m"
}

red() {
	echo -e "\033[31m\033[01m$1\033[0m"
}

yellow() {
	echo -e "\033[33m\033[01m$1\033[0m"
}

function frp()
{
        wget -O /root/frp.tar.gz https://github.com/fatedier/frp/releases/download/v0.43.0/frp_0.43.0_linux_amd64.tar.gz
        tar -xzvf /root/frp.tar.gz
	mv frp* /root/frp
	rm /root/frp.tar.gz
	read -p '请输入token：' token
	echo token = $token >> /root/frp/frps.ini
	read -p '请输入域名：' url
	echo subdomain_host = $url >> /root/frp/frps.ini
	cp /root/frp/frps /usr/bin/frps
	mkdir /etc/frp
	cp /root/frp/frps.ini /etc/frp/frps.ini
	touch /etc/systemd/system/frps.service
	cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frps -c /etc/frp/frps.ini
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
	systemctl start frps
	systemctl status frps
	green '主程序在/root/frp，添加了/etc/systemd/system/frps.service'
	green '设置文件在/etc/frp,系统命令在/usr/bin/下面'
	yellow '如果出错可以尝试systemctl daemon-reload && systemctl start frps' 
}

function startone()
{
	echo -e '——————————————————\n1.docker一键安装（可选docker-compose）\n2.x-ui面板\n3.Txray（Linux系统xray客户端）\n4.acmesh\n5.frp\n6.hysteria\n0.返回上级菜单\n——————————————————'
	read -p '请输入你的选择：' input
	case $input in
		1)
			bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh) ;;
		2)
			bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh) ;;
		3)
			wget https://github.com/hsernos/Txray/releases/download/v3.0.5/Txray-linux-64.zip
			unzip ./*Txray*.zip
			rm *Txray*.zip
			cd Txray*
			chmod +x Txray
			wget https://github.com/XTLS/Xray-core/releases/download/v1.5.5/Xray-linux-64.zip
			unzip Xray*.zip  ;;
		4)
			read -p '请输入邮箱：' email
			curl  https://get.acme.sh | sh -s email=$email
			alias acme.sh=~/.acme.sh/acme.sh
			green 'acmesh已安装到~/.acme.sh文件夹下，自动ssl脚本请到常用脚本下运行' ;;
		5)
			frp ;;
		6)	
			yellow '选择自签证书的话，请准备好一个域名'
			read -s -n1 -p '按任意键继续'
			bash <(curl -fsSL https://git.io/hysteria.sh) ;;
		0)
			startmenu
	esac
}

function starttwo()
{
	echo -e '———————————————————\n1.portainer\n2.aria2pro\n3.ariang\n4.cloudreve\n5.flare\n6.caddy\n7.mariadb\n8.plex\n0.返回上级菜单\n——————————————————'
	read -p '请输入你的选择：' input
	case $input in
		1) docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock --restart=always --name prtainer portainer/portainer;;
		2) read -p '请输入token:' token
			docker run -d \
    			--name aria2-pro \
    			--restart unless-stopped \
    			--log-opt max-size=1m \
    			--network host \
    			-e PUID=$UID \
    			-e PGID=$GID \
    			-e RPC_SECRET=$token \
    			-e RPC_PORT=6800 \
    			-e LISTEN_PORT=6888 \
    			-v /opt/aria2/aria2-config:/config \
    			-v /opt/aria2/aria2-downloads:/downloads \
    			p3terx/aria2-pro
		   green '映射目录在/opt/aria2' ;;
		3)
			docker run -d \
    			--name ariang \
    			--restart unless-stopped \
    			--log-opt max-size=1m \
    			-p 6880:6880 \
    			p3terx/ariang
		   green '访问ip:6880端口即可' ;;
		4)
			docker run -d \
			--name cloudreve \
			-v /opt/cloudreve:/etc/cloudreve \
		 	-v /opt/cloudreve:/data \
			-p 8081:8080 \
			littleplus/cloudreve-3.0.0-rc-1:sqlite
		   green '映射目录在/opt/cloudreve'
		   green '映射端口8081:8080'
		   green '访问ip:8081' 
		   green '默认登录邮箱为admin@cloudreve.org'
		   green '默认密码请用命令查看 docker logs -f cloudreve' ;;
		5)
			docker run -d \
			--name flare \
			--restart unless-stopped \
			-p 5005:5005 \
			-v /opt/flare:/app \
			soulteary/flare
		   green '映射目录在/opt/flare'
		   green '访问ip:5005'
		   green '后台修改ip:5005/editor' ;;
		6)
			docker run -d \
			--name caddy \
			-v /opt/caddy/site:/srv \
			-v /opt/caddy/data:/data \
			-v /opt/caddy/config:/config \
			-v /opt/caddy/Caddyfile:/etc/caddy/Caddyfile \
			caddy
		   green '映射目录在/opt/caddy' ;;
		7) mkdir /opt/mariadb
		   docker network create mariadb-network 
		   read -p '请输入root密码：' pass
			docker run --detach \
			--name mariadb \
			--network mariadb-network \
			-v /opt/mariadb:/var/lib/mysql \
			--env MARIADB_ROOT_PASSWORD=$pass \
			mariadb:latest
		   green '映射关系：/opt/mariadb:/var/lib/mysql'
		   green '为了方便后续建站等需求，建立了mariadb-network'
		   green '运行docker exec -it mariadb bash进入容器'
		   green "运行docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb查看容器ip"
		   green '运行mysql -h x.x.x.x -u root -p从容器外部连接数据库' ;;
		8)
		   yellow '首先请到https://plex.com/claim 准备好claimid备用'
		   read -p '请粘贴claim id：' claimid
		   read -p '请输入影视目录的绝对路径：' moviepath
			   docker run -d \
			   --name plex \
			   --network host \
			   -e PUID=1000 \
			   -e PGID=1000 \
			   -e VERSION=docker \
			   -e PLEX_CLAIM=$claimid \
			   -v /opt/plex:/config \
			   -v /opt/aria2/aria2-downloads:/tv \
			   -v $moviepath:/movies \
			   --restart unless-stopped \
			   lscr.io/linuxserver/plex:latest
		   green '磁盘映射在/opt/plex' ;;
		0) startmenu
	esac
}


function startthree()
{
	echo -e '———————————————————\n1.acmesh手动dns脚本\n2.开启root登录\n3.安装wireguard-go\n4.开启双栈warp脚本\n5.ls命令添加颜色\n6.添加bannedip任务\n0.返回上级菜单\n—————————————————————'
	read -p '请输入你的选择：' input
	case $input in
		1)
			read -p '请输入域名：' domain
			~/.acme.sh/acme.sh  --issue  --dns  --force -d $domain \
 			--yes-I-know-dns-manual-mode-enough-go-ahead-please
		  green '请在cloudflare手动添加txt记录后'
		  green '可以在电脑上执行nslookup -qt=txt xx.com查看解析是否成功'
		  	read -s -n1 -p '解析成功后按任意键继续'
			~/.acme.sh/acme.sh  --renew --force  -d $domain \
  			--yes-I-know-dns-manual-mode-enough-go-ahead-please
		  green 'acme.sh --info -d example.com 查看已安装证书信息'
		  	~/.acme.sh/acme.sh --info -d $domain ;;
		2)
		  yellow '请输入root密码：\n'
			read -p '请输入root密码：' pass
			echo root:$pass|sudo chpasswd root
			sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
			sudo sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		  green '现在你可以尝试用root+密码登录了'
			read -s -n1 -p '按任意键重启sshd服务'
			service sshd restart  ;;
		3)
		  yellow '本脚本安装vps各种架构都通用的wireguard-go'
		  yellow '如果要安装内核请google p3terx wireguard'
		  yellow '理论网络性能：内核集成 ≥ 内核模块 ＞ wireguard-go'
			read -s -n1 -p '按任意键继续'
			curl -fsSL git.io/wireguard-go.sh | sudo bash ;;
		4)
			wget -N https://raw.githubusercontent.com/fscarmen/warp/main/warp-go.sh	;;
		5)
		  	# Check if the alias for ls already exists
			if ! grep -q "alias ls='ls --color=auto'" ~/.bashrc; then
			# Add the alias to ~/.bashrc
			echo "alias ls='ls --color=auto'" >> ~/.bashrc
			# Reload the ~/.bashrc file
			source ~/.bashrc 
			echo "The alias for ls has been added." >&2
			else echo "The alias for ls already exists." >&2
			fi ;;
		6)	
		  yellow '本脚本将尝试恶意连接vps的ip抓取出来拒绝连接，具体在/root目录下添加bannedip.py文件，并添加定时任务'
			# 定义要使用的文件路径和名称
			LOG_FILE="/var/log/auth.log"
			DENY_FILE="/etc/hosts.deny"
			SCRIPT_FILE="/root/bannedip.py"
			
			# 编写Python脚本文件
			cat > $SCRIPT_FILE <<EOF
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
			
			
			echo "已添加bannedip任务到crontab中。" ;;
		0)
			startmenu
	esac
}

function startmenu()
{
	yellow '———————————————————\n1.常用软件\n2.docker容器\n3.常用脚本\n0.退出\n———————————————————'
	read -p '请输入你的选择：' input
	case $input in
		1)
			startone;;
		2)
			starttwo;;
		3)
			startthree;;
		0)
			exit
	esac
}

startmenu