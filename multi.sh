#!/bin/sh
subscription-manager register --username denniscrawvbov --password Pmataga1@ --auto-attach
subscription-manager list
subscription-manager list --available
subscription-manager attach --pool=8a85f999759ed5b40175b7309df54fad
subscription-manager attach --auto
cd /etc/ssh
chattr -ais sshd_config
cd
yum install readline-devel -y
yum install openssl-devel -y
yum install lzo-devel -y
yum install pam-devel -y
yum install make cmake -y
yum install wget -y
yum install nano -y
yum install bzip2 -y
yum install net-tools -y
yum install screen -y
yum install expect squid httpd-tools -y

cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

rm -f /etc/squid/squid.conf

echo 'auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/squid_passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_port 8080
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all
' > /etc/squid/squid.conf
cat /etc/squid/squid.conf

touch /etc/squid/squid_passwd
useradd proxy
chown proxy /etc/squid/squid_passwd
wget -O - https://raw.githubusercontent.com/chadpetersen1337/rhelmultiscript/master/setsquidpassword.sh | bash

service squid restart

sed -i 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
#sed -i 's/#Port 22/Port 222/' /etc/ssh/sshd_config
service sshd restart
echo "root:Pmataga87465622" | chpasswd
wget https://matt.ucc.asn.au/dropbear/dropbear-2020.81.tar.bz2
bzip2 -cd dropbear-2020.81.tar.bz2 | tar xvf -
cd dropbear-2020.81
./configure && make && make install
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
mkdir /etc/dropbear
echo 'OPTIONS="-p 444"
' > /etc/sysconfig/dropbear
echo '[Unit]
Description=Dropbear SSH Server Daemon
Documentation=man:dropbear(8)
Wants=dropbear-keygen.service
After=network.target

[Service]
EnvironmentFile=-/etc/sysconfig/dropbear
ExecStart=/usr/sbin/dropbear -E -F $OPTIONS

[Install]
WantedBy=multi-user.target
' > /usr/lib/systemd/system/dropbear.service
echo '[Unit]
Description=Dropbear SSH Key Generator
Documentation=man:dropbearkey(8)
Before=dropbear.service
ConditionPathExists=!/etc/dropbear/dropbear_rsa_host_key
ConditionPathExists=!/etc/dropbear/dropbear_dss_host_key
ConditionPathExists=!/etc/dropbear/dropbear_ecdsa_host_key

[Service]
Type=oneshot
ExecStart=/usr/local/bin/dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
ExecStart=/usr/local/bin/dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
ExecStart=/usr/local/bin/dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key
RemainAfterExit=yes
' > /usr/lib/systemd/system/dropbear-keygen.service
systemctl start dropbear-keygen.service; systemctl enable dropbear.service; systemctl start dropbear.service

cd

yum install stunnel -y
wget -O /etc/stunnel/stunnel.conf "https://raw.githubusercontent.com/chadpetersen1337/rhelmultiscript/master/stunnel.conf"
wget -O /etc/stunnel/stunnel.pem "https://raw.githubusercontent.com/chadpetersen1337/rhelmultiscript/master/stunnel.pem"

stunnel

wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-src-v4.29-9680-rtm.tar.gz
tar xzf softether-src-v4.29-9680-rtm.tar.gz
cd v4.29-9680
echo "2" |./configure --stdin
make && make install

cd ~/
/usr/bin/vpnserver start

wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/badvpn/badvpn-1.999.128.tar.bz2
tar xf badvpn-1.999.128.tar.bz2
mkdir badvpn-build
cd badvpn-build
cmake ~/badvpn-1.999.128 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make && make install
/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/null &

cd ~/
echo '#!/bin/sh
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
' > /etc/init.d/flush.sh
chmod +x /etc/init.d/flush.sh
bash /etc/init.d/flush.sh

iptables -L


echo '[Unit]
Description=/etc/rc.local compatibility

[Service]
Type=oneshot
ExecStart=/etc/rc.local

TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/rc-local.service

echo '#!/bin/sh
service squid restart
/usr/bin/vpnserver start
badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/null &
stunnel
sleep 60 && sh /etc/init.d/flush.sh
' > /etc/rc.local

chmod +x /etc/rc.local
ls -l /etc/rc.local
systemctl enable rc-local;systemctl status rc-local.service

iptables -L
netstat -ntlp
