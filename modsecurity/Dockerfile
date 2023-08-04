FROM centos:7

# ######################################################################################################################
# Setup systemd
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# ######################################################################################################################
# Network Setup
COPY ssl.crt /etc/pki/ca-trust/source/anchors/ssl.crt
RUN update-ca-trust

# ######################################################################################################################
# Installation
RUN yum install epel-release -y
RUN yum install epel-release -y 
RUN yum install wget -y
RUN yum install gcc -y
RUN yum install pcre -y
RUN yum install pcre-devel -y
RUN yum install gd -y
RUN yum install gd-devel -y
RUN yum install libtool -y
RUN yum install git -y
RUN yum groupinstall -y "Development Tools"
RUN yum install libxml2 -y
RUN yum install libxml2-devel  -y
RUN yum install curl  -y
RUN yum install vim -y
RUN yum install curl-devel  -y
RUN yum install openssl  -y
RUN yum install openssl-devel -y
RUN yum install httpd -y
RUN yum install httpd-devel -y
# COPY nginx.conf /root/nginx.conf

WORKDIR /usr/src/
RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git

WORKDIR /usr/src
RUN wget http://nginx.org/download/nginx-1.20.0.tar.gz
RUN tar -zxvf nginx-1.20.0.tar.gz && rm -f nginx-1.20.0.tar.gz

# ######################################################################################################################
# == Compile ModSecurity
# COPY ModSecurity-nginx_refactoring /usr/src/ModSecurity
WORKDIR /usr/src
RUN git clone -b nginx_refactoring https://github.com/SpiderLabs/ModSecurity.git
WORKDIR /usr/src/ModSecurity
RUN sed -i '/AC_PROG_CC/a\AM_PROG_CC_C_O' configure.ac
RUN sed -i '1 i\AUTOMAKE_OPTIONS = subdir-objects' Makefile.am
RUN ./autogen.sh
RUN ./configure --enable-standalone-module --disable-mlogc
RUN make

# ######################################################################################################################
# == Compile Nginx
RUN groupadd -r nginx
RUN useradd -r -g nginx -s /sbin/nologin -M nginx
 
WORKDIR /usr/src/nginx-1.20.0
RUN ./configure --user=nginx --group=nginx --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --add-module=/usr/src/ModSecurity/nginx/modsecurity --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module
# ./configure --user=nginx --group=nginx --add-module=/usr/src/ModSecurity/nginx/modsecurity --with-http_ssl_module
RUN make
RUN make install
 

# ######################################################################################################################
# === Configure NGINX
COPY nginx.conf /etc/nginx/nginx.conf 
COPY nginx.service /lib/systemd/system/nginx.service

RUN sed -i "s/#user  nobody;/user nginx nginx;/" /etc/nginx/nginx.conf

#RUN mkdir /etc/nginx/certificate

# ######################################################################################################################
# === Configure Certificate SSL
WORKDIR /etc/nginx
 
RUN openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out nginx-certificate.crt -keyout nginx.key -subj "/C=AA/ST=AA/L=AA/O=AA/CN=www.aaa.com"

COPY update-includes.sh /root/update-includes.sh
RUN /root/update-includes.sh

# ######################################################################################################################
# === Configure modsecurity logs etc
RUN cp /usr/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.conf
RUN cp /usr/src/ModSecurity/unicode.mapping /etc/nginx/

RUN sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/nginx/modsecurity.conf
RUN sed -i "s/SecAuditLogType Serial/SecAuditLogType Concurrent/" /etc/nginx/modsecurity.conf
RUN mkdir /etc/nginx/logs
RUN touch /var/log/nginx/modsec_audit.log
#RUN touch /etc/nginx/logs/modsec_audit.log

RUN chown nginx.root /var/log/nginx

# ######################################################################################################################
## === Setup OWASP
# COPY owasp-modsecurity-crs /etc/nginx/owasp-modsecurity-crs
WORKDIR /etc/nginx
RUN cp -R /usr/src/owasp-modsecurity-crs /etc/nginx/owasp-modsecurity-crs
WORKDIR /etc/nginx/owasp-modsecurity-crs
RUN mv crs-setup.conf.example crs-setup.conf
WORKDIR /etc/nginx/owasp-modsecurity-crs/rules
RUN mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
RUN mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

COPY modsecurity.conf /etc/nginx/modsecurity.conf
COPY crs-setup.conf /etc/nginx/owasp-modsecurity-crs/crs-setup.conf

VOLUME [ "/sys/fs/cgroup" ]
#RUN /usr/sbin/init
RUN systemctl enable nginx
