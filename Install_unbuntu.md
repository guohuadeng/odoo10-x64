#odoo 10 在ubuntu 下优化安装，以阿里云为例

本安装说明可在ubuntu及debian系统实现，CentOS会略有不同，强烈推荐使用ubuntu
本文档基于安装环境
1.Ubuntu 16 64位，阿里云主机/腾讯云主机
2.Odoo 10 2017-10-08最新社区版
3.Postgres 9.6
4.Python 2.7.12，操作系统原生
5.Nginx 1.12，使用AMH面板安装
6.SecureCRT，用于远程登录

## 前期准备
1.http://www.cr173.com/soft/4697.html
2.在secureCRT处理好中文乱码问题，同时颜色方案选“绿/黑”，字体选大点，会让你在接下来的操作中舒服很多
https://jingyan.baidu.com/article/948f59245be128d80ff5f9aa.html
3.了解下vi操作指令
Linux中vi编辑器的使用详解_百度经验
https://jingyan.baidu.com/article/59703552e2e1e38fc107405a.html
vim 常用快捷键 - 轻典 - 博客园
http://www.cnblogs.com/tianyajuanke/archive/2012/04/25/2470002.html
4.了解postgres常用指令
postgresql 常用命令 - RocTian - 博客园
http://www.cnblogs.com/tzp_8/archive/2012/11/08/2760746.html
5.以下操作使用secureCRT登录至主机操作

###更换主机 ssh 端口 22 to 8022
这会让你减少很多网络攻击，改 sshd_config 文件，大概第4行将22改为8022
记得要把云服务器的安全策略中的8022端口打开
```
sudo vi /etc/ssh/sshd_config
sudo service sshd restart 
sudo service ssh restart 
```

###更换为阿里云的源，下载与安装会快不少
http://blog.csdn.net/Hehailiang_Dream/article/details/54094634
```
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo vi /etc/apt/sources.list

sudo apt-get update
```

### 安装性能监控[非必要]
便于后期优化。也可以直接用阿里云自带的高级监控，十分方便
```
sudo apt install -y htop && sudo apt install -y iotop && sudo apt install -y vmstat && sudo apt install -y lsof
sudo apt install -y tcpdump && sudo apt install -y iostat && sudo apt install -y iotop
sudo apt install -y iptraf && sudo apt install -y iotop && sudo apt install -y acct && sudo apt install -y psacct 
sudo apt install -y monit && sudo apt install -y nethogs && sudo apt install -y iftop
```

##下载，所有相关软件都放在当前用户 src 目录下
```
mkdir src && cd src
wget http://nightly.odoocdn.com/10.0/nightly/deb/odoo_10.0.latest_all.deb
```
##装sudo http://chenpeng.info/html/964[一般不用，如果服务器上没有则需安装]
```
apt-get install -y sudo
```
##中文化
默认环境与字体选择 zh_CN.UTF-8 UTF-8
```
sudo apt install -y aptitude;sudo aptitude install -y locales;sudo dpkg-reconfigure locales
```
###，安装中文字体
```
sudo apt-get install -y ttf-wqy-*;
sudo apt-get install ttf-wqy-zenhei;sudo apt-get install ttf-wqy-microhei
```
###安装pip工具，用于快速安装odoo库
```
sudo apt-get install -y python-pip python-dev build-essential;
sudo pip install --upgrade pip;sudo pip install --upgrade virtualenv
vi /etc/default/locale
```
###确定文件改为如下，然后重启
==========
LANG="zh_CN.UTF-8"
==========

##pg安装，9.6，正常ubuntu 用默认的9.5，但是如果进行过update，可以找到9.6
```
sudo apt-get install -y python-software-properties software-properties-common;sudo apt-get install -y add-apt-repository
```
###执行如下内容，debian，或者改文件 vi /etc/apt/sources.list.d/pgdg.list，改为如下内容，适用于ubuntu 16
```
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
sudo apt-get install -y wget ca-certificates
```
###密钥更新，只用以root用户进行
```
su root
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sudo apt-get update
reboot
```
####升级，不熟悉linux的请一定不操作，容易有麻烦。
```
sudo apt-get -y upgrade
```
###正常ubuntu 用默认的9.5，进行过update后，可以找到9.6，
```
sudo apt-get install -y postgresql-9.6
```
ubuntu/debian装完后已初始化库，如果是centos要initdb 。注意中文支持，当更改了locale.conf后，默认用文件中LANG指定的
###加入自动启动，启动pg
```
sudo systemctl enable postgresql.service && sudo systemctl start postgresql.service && sudo systemctl restart postgresql.service
```
###创建pg的用户 odoo，暂时使用密码 demo.123 ，可自行设定
```
sudo -i -u postgres
createuser --createdb --no-createrole --no-superuser --pwprompt odoo
```
###指令例子，管理postgresql，删除数据库f1
```
sudo -i -u postgres
psql;
\l;
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = 'f1';
drop database f1;
```

##下载odoo后，安装，企业版可以本地下载企业版后，上传到服务器
### 普通安装以及升级安装，在 src 下载目录下操作
```
sudo dpkg -i odoo_10.0.latest_all.deb;sudo apt-get -f -y install
/lib/systemd/systemd-sysv-install enable odoo
sudo systemctl enable odoo
sudo systemctl start odoo
```
### 卸载odoo
sudo apt-get remove --purge odoo
##npm 安装, ubuntu 请看提示,为求速度可能使用cnpm
```
sudo apt install -y npm
sudo npm install -g cnpm -registry=https://registry.npm.taobao.org
sudo curl -sL https://deb.nodesource.com/setup_4.x | bash -;sudo apt-get install -y nodejs;
sudo npm install -g less less-plugin-clean-css
sudo ln -s /usr/bin/nodejs /usr/bin/node
```
##安装报表所需的wkhtmltopdf，注意一定要安装官方推荐的0.12.1版本。win下，设置->参数->系统参数，设置 webkit_path 键值为安装目录+exe执行文件。
```
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin 
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
```

##处理workers>0时，longpolling端口
除了在nginx反向代理配置8072代理外，要确定已装 gevent,psycogreen，正常odoo已安装，如果没装则执行
```
sudo apt-get purge python-gevent
sudo pip install gevent
pip install psycogreen==1.0
```

##cron 配置时间同步，必须要做，避免多数问题，最好停用本机ntpd服务器
```
sudo systemctl disable ntpd;sudo /etc/init.d/ntp stop;sudo /usr/sbin/ntpdate cn.pool.ntp.org
sudo vi /etc/crontab
```
在 crontab 中添加如果下语句,每2小时同步一次
`
0  */2  * * *   root    /usr/sbin/ntpdate cn.pool.ntp.org
`
##[暂时不操作此项]设置时区为UTC，在o10版本中已有改进，服务器设置为utc+8也正常。
```
dpkg-reconfigure tzdata
```

##改配置文件及相关目录
##odoo配置文件
```
sudo vi /etc/odoo/odoo.conf
```
##数据库配置及数据目录，debian与centos不同
###ubuntu/debian
/etc/postgresql/9.6/main
/var/lib/postgresql/9.6/main
###centos
/var/lib/pgsql/9.6/data
##odoo安装目录
###ubuntu/debian
/usr/lib/python2.7/dist-packages/odoo
###centos
/usr/lib/python2.7/site-packages/odoo
##使用文件存储时处理权限，假设使用odoofile为odoo的文件存储目录
###ubuntu/debian
```
sudo mkdir /usr/lib/python2.7/dist-packages/odoo/odoofile
sudo chmod 777 /usr/lib/python2.7/dist-packages/odoo/odoofile
```
###centos
```
sudo mkdir /usr/lib/python2.7/site-packages/odoo/odoofile
sudo chmod 777 /usr/lib/python2.7/site-packages/odoo/odoofile
```
##看log是否正常
```
sudo cat /var/log/odoo/odoo-server.log
```
##清理log
```
sudo rm /var/log/odoo/odoo-server.log
```

##相关指令
pg 启动停止
```
su postgres
postgres -D /opt/postgresql/data/ > /opt/postgresql/log/pg_server.log 2>&1 &
```
#安装结束
访问 http://www.myserver.com:8069 ，即可初始化数据库使用odll

#翻译团队
https://www.transifex.com/odoo/odoo-10/