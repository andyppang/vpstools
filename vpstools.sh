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

function startone()
{
	echo -e '——————————————————\n1.docker一键安装（可选docker-compose）\n2.x-ui面板\n3.Txray（Linux系统xray客户端）\n4.acmesh\n0.返回上级菜单\n——————————————————'
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
		0)
			startmenu
	esac
}

function starttwo()
{
	echo -e '———————————————————\n1.portainer\n2.aria2pro\n3.ariang\n4.cloudreve\n5.flare\n6.caddy\n0.返回上级菜单\n——————————————————'
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
		   green '访问ip:8081' ;;
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
		0) startmenu
	esac
}

function startthree()
{
	echo -e '———————————————————\n1.acmesh手动dns脚本\n2.开启root登录\n0.返回上级菜单\n—————————————————————'
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
