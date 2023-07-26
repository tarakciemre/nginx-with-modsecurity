update-ca-trust

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* 
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* 

yum install epel-release -y
 
yum install wget -y
 
yum install nginx bison build-essential ca-certificates curl dh-autoreconf doxygen \
  flex gawk git iputils-ping libcurl4-gnutls-dev libexpat1-dev libgeoip-dev liblmdb-dev \
  libpcre3-dev libpcre++-dev libssl-dev libtool libxml2 libxml2-dev libyajl-dev locales \
  lua5.3-dev pkg-config wget zlib1g-dev zlibc libxslt libgd-dev -y

cd /opt && git clone https://github.com/SpiderLabs/ModSecurity

