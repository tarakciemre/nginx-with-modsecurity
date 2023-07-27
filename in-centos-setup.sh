function installation() {
update-ca-trust

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* 
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* 


# == Installations 
yum install epel-release -y
yum install wget -y
yum install gcc -y
yum install pcre -y
yum install pcre-devel -y
yum install openssl -y
yum install openssl-devel -y
yum install gd -y
yum install gd-devel -y
yum install libtool -y
yum install git -y
yum groupinstall -y "Development Tools"
yum install libxml2 -y 
yum install libxml2-devel  -y 
yum install curl  -y 
yum install vim -y
yum install curl-devel  -y 
yum install openssl  -y 
yum install openssl-devel -y 
yum install httpd -y
yum install httpd-devel -y
# yum install apache2-dev -y
}
# == ModSecurity

function setMod() {

cd /usr/src/ModSecurity
sed -i '/AC_PROG_CC/a\AM_PROG_CC_C_O' configure.ac
sed -i '1 i\AUTOMAKE_OPTIONS = subdir-objects' Makefile.am
./autogen.sh
./configure --enable-standalone-module --disable-mlogc
make
}

# == NGINX

function setNginx() {

cd /usr/src
wget http://nginx.org/download/nginx-1.20.0.tar.gz
tar -zxvf nginx-1.20.0.tar.gz && rm -f nginx-1.20.0.tar.gz

groupadd -r nginx
useradd -r -g nginx -s /sbin/nologin -M nginx

cd nginx-1.20.0
./configure --user=nginx --group=nginx --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --add-module=/usr/src/ModSecurity/nginx/modsecurity --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module
# ./configure --user=nginx --group=nginx --add-module=/usr/src/ModSecurity/nginx/modsecurity --with-http_ssl_module
make
make install

# cp /root/nginx.conf /etc/nginx/nginx.conf
sed -i "s/#user  nobody;/user nginx nginx;/" /etc/nginx/nginx.conf

mkdir /etc/nginx/certificate
cd /etc/nginx/certificate

openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx-certificate.crt -keyout nginx.key -subj "/C=AA/ST=AA/L=AA/O=AA/CN=www.aaa.com"
}

# systemctl enable nginx

#wget https://github.com/SpiderLabs/ModSecurity/releases/download/v3.0.10/modsecurity-v3.0.10.tar.gz
#tar xvf modsecurity-v3.0.10.tar.gz

#cd modsecurity-v3.0.10

# == Setup ModSecurity
function setupModSecurity() {

cat <<EOF>> /usr/local/nginx/conf/modsec_includes.conf
include modsecurity.conf
include owasp-modsecurity-crs/crs-setup.conf
include owasp-modsecurity-crs/rules/*.conf
EOF

cp /usr/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.conf
cp /usr/src/ModSecurity/unicode.mapping /etc/nginx/

sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/nginx/modsecurity.conf
sed -i "s/SecAuditLogType Serial/SecAuditLogType Concurrent/" /etc/nginx/modsecurity.conf
sed -i "s|SecAuditLog /var/log/modsec_audit.log|SecAuditLog /usr/local/nginx/logs/modsec_audit.log|"        /etc/nginx/modsecurity.conf

chown nginx.root /usr/local/nginx/logs
cd /etc/nginx/owasp-modsecurity-crs
mv crs-setup.conf.example crs-setup.conf
cd rules
mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf



#cat <<EOF>> /lib/systemd/system/nginx.service
#[Unit]
#Description=The NGINX HTTP and reverse proxy server
#After=syslog.target network.target remote-fs.target nss-lookup.target
#[Service]
#Type=forking
#PIDFile=/var/run/nginx.pid
#ExecStartPre=/usr/local/nginx/sbin/nginx -t
#ExecStart=/usr/local/nginx/sbin/nginx
#ExecReload=/bin/kill -s HUP $MAINPID
#ExecStop=/bin/kill -s QUIT $MAINPID
#PrivateTmp=true
#[Install]
#WantedBy=multi-user.target
#EOF

systemctl daemon-reload
}

setupModSecurity
