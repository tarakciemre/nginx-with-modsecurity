update-ca-trust

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* 
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* 

yum install epel-release -y
 
yum install wget -y

# == Start the setup
mkdir /root/ModSecurity
cd /root/ModSecurity

# cd /opt && git clone https://github.com/SpiderLabs/ModSecurity

# == Setup 

yum install pcre gcc -y
yum install pcre-devel -y
yum install openssl -y
yum install openssl-devel -y
yum install gd -y
yum install gd-devel -y
yum install libtool -y
yum install git -y
yum groupinstall -y "Development Tools"
yum install -y httpd httpd-devel pcre pcre-devel libxml2 libxml2-devel curl curl-devel openssl openssl-devel

# == ModSecurity

cd /root/ModSecurityNginx
sed -i '/AC_PROG_CC/a\AM_PROG_CC_C_O' configure.ac
sed -i '1 i\AUTOMAKE_OPTIONS = subdir-objects' Makefile.am
./autogen.sh
./configure --enable-standalone-module --disable-mlogc
make

# == NGINX

cd /root/

wget http://nginx.org/download/nginx-1.20.0.tar.gz
tar -zxvf nginx-1.20.0.tar.gz
cd nginx-1.20.0
./configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --add-module=/root/ModSecurityNginx/nginx/modsecurity --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module
make
make install

#wget https://github.com/SpiderLabs/ModSecurity/releases/download/v3.0.10/modsecurity-v3.0.10.tar.gz
#tar xvf modsecurity-v3.0.10.tar.gz

#cd modsecurity-v3.0.10

